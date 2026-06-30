#!/bin/bash

# state-validator.sh — Harness V3 State Machine Validator
# Implements phase FSM validation, deadlock detection, and FSM visualization
# Version: 1.0

set -euo pipefail

# === State Machine Definition ===

declare -A STATES=(
  [Intent]=1
  [Structure]=2
  [Design]=3
  [Execution]=4
  [Validate]=5
  [Ship]=6
)

declare -A FORWARD_ONLY=(
  [Intent]="Structure"
  [Structure]="Design"
  [Design]="Execution Validate"
  [Execution]="Validate"
  [Validate]="Ship"
  [Ship]=""
)

# Rework loop exception: Validate → Design
declare -A ALLOWS_BACKTRACK=(
  [Validate]="Design"
)

# === Utility Functions ===

log_error() {
  echo "[ERROR] $*" >&2
}

log_info() {
  echo "[INFO] $*" >&2
}

# === Validation Function ===

validate_transition() {
  local current="$1"
  local next="$2"

  # Check if both states exist
  if [[ ! -v STATES[$current] ]]; then
    log_error "Unknown state: $current"
    return 3
  fi

  if [[ ! -v STATES[$next] ]]; then
    log_error "Unknown state: $next"
    return 3
  fi

  # Rule 1: No self-loops
  if [[ "$current" == "$next" ]]; then
    log_error "Self-loop not allowed: $current → $current"
    return 4
  fi

  # Rule 2: Check forward transitions
  local forward_targets="${FORWARD_ONLY[$current]:-}"
  if [[ " $forward_targets " =~ " $next " ]]; then
    return 0  # Valid forward transition
  fi

  # Rule 3: Check backward transitions (only Validate → Design allowed)
  if [[ "$current" == "Validate" && "$next" == "Design" ]]; then
    return 0  # Valid rework loop
  fi

  # Invalid transition
  log_error "Invalid transition: $current → $next"
  return 1
}

# === Command: validate ===

cmd_validate() {
  if [[ $# -ne 2 ]]; then
    log_error "Usage: state-validator validate <current-state> <next-state>"
    return 1
  fi

  validate_transition "$1" "$2"
}

# === Command: deadlock-check ===

cmd_deadlock_check() {
  local trace_file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --trace)
        trace_file="$2"
        shift 2
        ;;
      *)
        log_error "Unknown option: $1"
        return 1
        ;;
    esac
  done

  # If no trace file provided, check for stdin
  if [[ -z "$trace_file" ]] && [[ ! -t 0 ]]; then
    trace_file="/dev/stdin"
  fi

  # If still no trace, we can't check deadlocks (no operation, success)
  if [[ -z "$trace_file" ]]; then
    log_info "No trace provided; deadlock-check passed (no-op)"
    return 0
  fi

  # Verify trace file exists
  if [[ ! -f "$trace_file" ]]; then
    log_error "Trace file not found: $trace_file"
    return 2
  fi

  # Parse trace and build dependency graph
  # Format: each line is "state <state> waiting_for <event>"
  local -A waiting_for
  local -a all_states

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Extract state and what it's waiting for
    if [[ "$line" =~ state\ ([^ ]+)\ waiting_for\ ([^ ]+) ]]; then
      local state="${BASH_REMATCH[1]}"
      local event="${BASH_REMATCH[2]}"
      waiting_for["$state"]="$event"
      all_states+=("$state")
    fi
  done < "$trace_file"

  # Detect cycles using DFS
  local -A visited
  local -a cycle_path

  detect_cycle() {
    local current="$1"
    local path="$2"

    if [[ -v visited["$current"] ]]; then
      if [[ "$visited[$current]" == "in_progress" ]]; then
        # Found a cycle
        log_error "Deadlock detected in cycle: $path → $current"
        return 2
      fi
      return 0
    fi

    visited["$current"]="in_progress"

    # Follow dependency chain
    if [[ -v waiting_for["$current"] ]]; then
      local next_state="${waiting_for[$current]}"
      if ! detect_cycle "$next_state" "$path → $current"; then
        return 1
      fi
    fi

    visited["$current"]="done"
    return 0
  }

  # Run cycle detection from each state
  for state in "${all_states[@]}"; do
    if ! [[ -v visited["$state"] ]]; then
      if ! detect_cycle "$state" "$state"; then
        return 2
      fi
    fi
  done

  log_info "Deadlock check passed; no cycles detected"
  return 0
}

# === Command: dump-graph ===

cmd_dump_graph() {
  cat << 'EOF'
# Harness V3 Phase State Machine (FSM)

States (ordered numerically):
  1: Intent
  2: Structure
  3: Design
  4: Execution
  5: Validate
  6: Ship

Transitions (directed edges):
  Intent       → Structure           (forward only)
  Structure    → Design              (forward only)
  Design       → Execution           (forward, happy path)
  Design       → Validate            (forward, fast-track)
  Execution    → Validate            (forward only)
  Validate     → Ship                (forward)
  Validate     → Design              (BACKWARD - rework loop, only exception)
  Ship         → (terminal state)    (no outgoing edges)

State Machine Diagram:

    Intent
      ↓
  Structure
      ↓
    Design ←─────────────┐
      ├─→ Execution      │
      │     ↓            │
      └──→ Validate ─────┤
            ↓ (rework)   │
           Ship          │
                         │
         (rework via ────┘
          Design)

Forbidden Transitions (explicitly blocked):
  • All self-loops (X → X for any state X)
  • Ship → Intent (must start new change)
  • Backward jumps except Validate → Design:
    - Structure → Intent
    - Execution → Design or earlier
    - Validate → Execution or earlier (except Design)
    - Ship → any state except (none)

Deadlock Rules:
  • State A waiting for State B
  • State B waiting for State C
  • State C waiting for State A
  → Circular dependency = DEADLOCK

Invariants:
  • No state repeats in single change
  • Required phases: Intent → Structure → Design
  • Only backward edge: Validate → Design
  • All transitions logged to state.md

EOF
}

# === Main Dispatcher ===

main() {
  if [[ $# -lt 1 ]]; then
    log_error "Usage: state-validator <command> [args...]"
    log_error "Commands: validate, deadlock-check, dump-graph"
    return 1
  fi

  local command="$1"
  shift

  case "$command" in
    validate)
      cmd_validate "$@"
      ;;
    deadlock-check)
      cmd_deadlock_check "$@"
      ;;
    dump-graph)
      cmd_dump_graph "$@"
      ;;
    *)
      log_error "Unknown command: $command"
      return 1
      ;;
  esac
}

# Run main
main "$@"
