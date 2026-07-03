#!/bin/bash

###############################################################################
# headroom-validator.sh — Context Budget & Headroom Validation Tool
#
# Purpose: Validate context/token budgets before heavy work; prevent unsafe
#          context loading; track Headroom usage
#
# Usage:
#   headroom-validator.sh check-budget <task.yaml>
#   headroom-validator.sh estimate-context <context_list.txt>
#   headroom-validator.sh validate-safe <context_list.yaml>
#   headroom-validator.sh ledger-add <event.yaml>
#   headroom-validator.sh report <change_id>
#
# Exit Codes:
#   0 = OK (proceed)
#   1 = WARN (proceed with warning)
#   2 = BLOCK (cannot proceed)
#   3 = ERROR (validation error)
#
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############################################################################
# Utility Functions
###############################################################################

log_ok() {
  echo -e "${GREEN}✓${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $*" >&2
}

log_error() {
  echo -e "${RED}✗${NC} $*" >&2
}

log_info() {
  echo -e "${BLUE}ℹ${NC} $*"
}

###############################################################################
# Core Validation Functions
###############################################################################

# Calculate headroom thresholds
calculate_headroom() {
  local available=$1
  local mode=${2:-advisory}

  # Headroom = max(available * 15%, 30000 absolute)
  local headroom_percent=$(awk "BEGIN {print int($available * 0.15)}")
  local headroom_absolute=30000
  local headroom_min=$([[ $headroom_percent -gt $headroom_absolute ]] && echo "$headroom_percent" || echo "$headroom_absolute")
  local safety_margin=5000

  echo "$headroom_min:$safety_margin"
}

# Determine budget status
get_budget_status() {
  local available=$1
  local headroom_min=$2
  local safety_margin=$3

  if [[ $available -ge $headroom_min ]]; then
    echo "OK"
  elif [[ $available -gt $safety_margin ]]; then
    echo "WARN"
  else
    echo "BLOCK"
  fi
}

# Estimate tokens for a file
estimate_file_tokens() {
  local file=$1

  if [[ ! -f "$file" ]]; then
    echo "0"
    return 0
  fi

  # Estimate: lines * 3.5 tokens/line + 250 overhead
  local lines=$(wc -l < "$file")
  local estimated=$(awk "BEGIN {print int($lines * 3.5) + 250}")
  echo "$estimated"
}

# Classify pattern as safe or unsafe
classify_pattern() {
  local item=$1

  # Safe patterns
  case "$item" in
    ".specs/memory/kb-index.md"|".specs/memory/"*"-index.md")
      echo "safe:kb_index"
      return 0
      ;;
    "skills/"*"SKILL.md")
      echo "safe:skill"
      return 0
      ;;
    ".specs/shared/"*"-contract.md")
      echo "safe:contract"
      return 0
      ;;
    ".specs/changes/"*"/allocation.yaml")
      echo "safe:allocation"
      return 0
      ;;
    ".specs/changes/"*"/DESIGN.md"|".specs/changes/"*"/PRD.md")
      echo "safe:phase_artifact"
      return 0
      ;;
    "artifact-generation-registry.yaml")
      echo "safe:registry"
      return 0
      ;;
    *)
      # Unsafe patterns
      if [[ "$item" == ".specs/"* ]] || [[ "$item" == "skills/" ]] || [[ "$item" == "agents/" ]] || [[ "$item" == ".git/"* ]]; then
        echo "unsafe:bulk_load"
        return 0
      fi
      echo "safe:unknown"
      return 0
      ;;
  esac
}

###############################################################################
# Command: check-budget
###############################################################################

cmd_check_budget() {
  local task_yaml=$1

  if [[ ! -f "$task_yaml" ]]; then
    log_error "Task file not found: $task_yaml"
    return 3
  fi

  # Parse YAML (simplified)
  local allocated=$(grep "allocated_tokens:" "$task_yaml" | awk '{print $2}' | tr -d '\r' || echo "50000")
  local available=$(grep "available_tokens:" "$task_yaml" | awk '{print $2}' | tr -d '\r' || echo "95000")
  local mode=$(grep "mode:" "$task_yaml" | awk '{print $2}' | tr -d '\r' || echo "advisory")

  # Calculate headroom
  local headroom_data=$(calculate_headroom "$available" "$mode")
  local headroom_min=$(echo "$headroom_data" | cut -d: -f1)
  local safety_margin=$(echo "$headroom_data" | cut -d: -f2)

  # Get status
  local status=$(get_budget_status "$available" "$headroom_min" "$safety_margin")

  # Output result
  log_info "Budget Check Result"
  log_info "Available: $available tokens"
  log_info "Headroom min: $headroom_min tokens"
  log_info "Safety margin: $safety_margin tokens"
  log_info "Status: $status"

  # Determine action and exit code
  local action=""
  local exit_code=0

  if [[ "$status" == "OK" ]]; then
    action="proceed"
    exit_code=0
  elif [[ "$status" == "WARN" ]]; then
    action="warn_user"
    exit_code=1
    log_warn "Budget warning: approaching limit"
  else
    action="blocked"
    exit_code=2
    log_error "Budget exceeded: cannot proceed"
  fi

  log_info "Action: $action"

  # Output YAML for downstream processing
  cat <<EOF
budget_check_result:
  status: $status
  action: $action
  available_tokens: $available
  headroom_minimum: $headroom_min
  safety_margin: $safety_margin
  mode: $mode
EOF

  return $exit_code
}

###############################################################################
# Command: estimate-context
###############################################################################

cmd_estimate_context() {
  local context_list=$1

  if [[ ! -f "$context_list" ]]; then
    log_error "Context list not found: $context_list"
    return 3
  fi

  local total_tokens=0
  local includes_unsafe=false

  log_info "Estimating context tokens..."

  while IFS= read -r item; do
    # Skip empty lines and comments
    [[ -z "$item" ]] && continue
    [[ "$item" =~ ^# ]] && continue

    # Classify pattern
    local classification=$(classify_pattern "$item")
    local pattern=$(echo "$classification" | cut -d: -f1)
    local type=$(echo "$classification" | cut -d: -f2)

    # Estimate tokens
    local estimated=0
    if [[ -f "$item" ]]; then
      estimated=$(estimate_file_tokens "$item")
    else
      # Directory or glob pattern
      estimated=$([[ "$pattern" == "unsafe" ]] && echo "50000" || echo "10000")
    fi

    log_info "  $item: $estimated tokens ($pattern/$type)"

    total_tokens=$((total_tokens + estimated))

    if [[ "$pattern" == "unsafe" ]]; then
      includes_unsafe=true
    fi
  done < "$context_list"

  log_info "Total estimated: $total_tokens tokens (unsafe: $includes_unsafe)"

  # Output YAML
  cat <<EOF
context_estimation_result:
  total_estimated_tokens: $total_tokens
  includes_unsafe: $includes_unsafe
  context_items: $(wc -l < "$context_list")
EOF

  return 0
}

###############################################################################
# Command: validate-safe
###############################################################################

cmd_validate_safe() {
  local context_list=$1

  if [[ ! -f "$context_list" ]]; then
    log_error "Context list not found: $context_list"
    return 3
  fi

  local has_unsafe=false
  local unsafe_items=()

  log_info "Validating context patterns..."

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    [[ "$item" =~ ^# ]] && continue

    local classification=$(classify_pattern "$item")
    local pattern=$(echo "$classification" | cut -d: -f1)

    if [[ "$pattern" == "unsafe" ]]; then
      has_unsafe=true
      unsafe_items+=("$item")
      log_warn "Unsafe pattern: $item"
    fi
  done < "$context_list"

  if [[ "$has_unsafe" == true ]]; then
    log_error "Found $(echo "${#unsafe_items[@]}") unsafe pattern(s)"
    cat <<EOF
pattern_validation_result:
  patterns_ok: false
  unsafe_patterns:
$(printf '    - "%s"\n' "${unsafe_items[@]}")
EOF
    return 2
  else
    log_ok "All patterns are safe"
    cat <<EOF
pattern_validation_result:
  patterns_ok: true
  unsafe_patterns: []
EOF
    return 0
  fi
}

###############################################################################
# Command: ledger-add
###############################################################################

cmd_ledger_add() {
  local event_yaml=$1
  local change_id=${2:-wave-6}

  if [[ ! -f "$event_yaml" ]]; then
    log_error "Event file not found: $event_yaml"
    return 3
  fi

  local ledger_file="$ROOT_DIR/.specs/changes/$change_id/03-budget-ledger.md"

  # Ensure ledger file exists
  if [[ ! -f "$ledger_file" ]]; then
    log_info "Creating budget ledger: $ledger_file"
    mkdir -p "$(dirname "$ledger_file")"
    cat > "$ledger_file" <<'EOF'
# Budget Ledger

budget_events:
EOF
  fi

  # Append event (simplified: just add as comment for now)
  log_info "Recording budget event"
  {
    echo ""
    echo "# Event: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    cat "$event_yaml"
  } >> "$ledger_file"

  log_ok "Budget event recorded"
  return 0
}

###############################################################################
# Command: report
###############################################################################

cmd_report() {
  local change_id=$1

  local ledger_file="$ROOT_DIR/.specs/changes/$change_id/03-budget-ledger.md"

  if [[ ! -f "$ledger_file" ]]; then
    log_error "Ledger not found: $ledger_file"
    return 3
  fi

  log_info "Budget Report: $change_id"
  log_info ""

  # Count events
  local event_count=$(grep -c "Event:" "$ledger_file" || echo "0")
  log_info "Total budget events: $event_count"

  # Show last few events
  log_info ""
  log_info "Recent events:"
  tail -20 "$ledger_file"

  return 0
}

###############################################################################
# Main Entry Point
###############################################################################

main() {
  local command=${1:-}

  case "$command" in
    check-budget)
      cmd_check_budget "${2:-}"
      ;;
    estimate-context)
      cmd_estimate_context "${2:-}"
      ;;
    validate-safe)
      cmd_validate_safe "${2:-}"
      ;;
    ledger-add)
      cmd_ledger_add "${2:-}" "${3:-wave-6}"
      ;;
    report)
      cmd_report "${2:-wave-6}"
      ;;
    --help|-h|help)
      cat <<EOF
Usage: headroom-validator.sh <command> [args]

Commands:
  check-budget <task.yaml>           Check current budget status
  estimate-context <context.txt>     Estimate tokens for context items
  validate-safe <context.yaml>       Validate context patterns
  ledger-add <event.yaml> [change]   Record budget event in ledger
  report <change_id>                 Generate budget report
  help                               Show this help

Exit Codes:
  0 = OK (safe to proceed)
  1 = WARN (warning, can proceed with caution)
  2 = BLOCK (blocked, cannot proceed)
  3 = ERROR (validation error)

Examples:
  # Check if task has budget
  headroom-validator.sh check-budget .specs/changes/wave-6/task.yaml

  # Estimate tokens for context items
  headroom-validator.sh estimate-context context-list.txt

  # Validate patterns are safe
  headroom-validator.sh validate-safe safe-contexts.yaml

  # Record event in ledger
  headroom-validator.sh ledger-add event.yaml wave-6

  # Generate budget report
  headroom-validator.sh report wave-6
EOF
      exit 0
      ;;
    *)
      log_error "Unknown command: $command"
      echo "Use 'headroom-validator.sh help' for usage information"
      exit 3
      ;;
  esac
}

main "$@"
