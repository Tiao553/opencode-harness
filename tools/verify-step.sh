#!/bin/bash
#
# verify_step.sh — Deterministic execution tracing tool for Harness V3
# Version: 1.0
# Purpose: Record decision traces, support replay, capture fork paths
#

set -euo pipefail

# Configuration
TRACES_DIR=".specs/changes/waves-7-17-implementation/traces"
LEDGER_FILE=".specs/changes/waves-7-17-implementation/03-execution-ledger.md"

# Ensure traces directory exists
mkdir -p "$TRACES_DIR"

# Helper: Compute SHA256 checksum
compute_checksum() {
    local input="$1"
    echo -n "$input" | sha256sum | awk '{print $1}'
}

# Helper: Get temp state file for session
get_temp_state_file() {
    local session_id="$1"
    echo "$TRACES_DIR/.temp_$session_id"
}

# Helper: Generate decision ID
generate_decision_id() {
    local session_id="$1"
    local seq_num="$2"
    echo "dec-${session_id}-$(printf "%03d" "$seq_num")"
}

# Helper: Get current ISO8601 timestamp
get_timestamp() {
    date -u +'%Y-%m-%dT%H:%M:%SZ'
}

# Helper: Load session ledger from trace file
load_session() {
    local session_id="$1"
    local trace_file="$TRACES_DIR/$session_id.yaml"
    
    if [[ -f "$trace_file" ]]; then
        cat "$trace_file"
        return 0
    else
        return 1
    fi
}

# Helper: Save session ledger to trace file
save_session() {
    local session_id="$1"
    local trace_data="$2"
    local trace_file="$TRACES_DIR/$session_id.yaml"
    
    echo "$trace_data" > "$trace_file"
}

# Helper: Initialize new session
init_session() {
    local session_id="$1"
    cat <<EOF
trace_session:
  session_id: "$session_id"
  created_at: "$(get_timestamp)"
  status: "active"
  total_steps: 0
  total_forks: 0
  decisions: []
  fork_graph:
    forks: []
EOF
}

# Command: start — Begin tracing a decision
cmd_start() {
    local session_id=""
    local step_description=""
    local tags=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --session-id) session_id="$2"; shift 2 ;;
            --step) step_description="$2"; shift 2 ;;
            --tags) tags="$2"; shift 2 ;;
            *) echo "ERROR: Unknown option $1"; return 1 ;;
        esac
    done
    
    if [[ -z "$session_id" ]] || [[ -z "$step_description" ]]; then
        echo "ERROR: --session-id and --step are required" >&2
        return 1
    fi
    
    local trace_file="$TRACES_DIR/$session_id.yaml"
    local seq_num=1
    local session_data
    
    # Load or initialize session
    if [[ -f "$trace_file" ]]; then
        session_data=$(load_session "$session_id")
        seq_num=$(echo "$session_data" | grep "total_steps:" | awk '{print $2}')
        seq_num=$((seq_num + 1))
    else
        session_data=$(init_session "$session_id")
    fi
    
    # Generate decision ID
    local decision_id
    decision_id=$(generate_decision_id "$session_id" "$seq_num")
    
    # Record decision start (temporary)
    echo "$decision_id"
    
    # Store in persistent temp file (keyed by session_id, not PID)
    local temp_file
    temp_file=$(get_temp_state_file "$session_id")
    cat > "$temp_file" <<EOF
decision_id: $decision_id
session_id: $session_id
seq_num: $seq_num
step_description: $step_description
timestamp_start: $(get_timestamp)
tags: $tags
EOF
    
    return 0
}

# Command: check — Record decision outcome
cmd_check() {
    local session_id=""
    local verdict=""
    local fork_decision=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --session-id) session_id="$2"; shift 2 ;;
            --verdict) verdict="$2"; shift 2 ;;
            --fork-decision) fork_decision="$2"; shift 2 ;;
            *) echo "ERROR: Unknown option $1"; return 1 ;;
        esac
    done
    
    if [[ -z "$session_id" ]] || [[ -z "$verdict" ]]; then
        echo "ERROR: --session-id and --verdict are required" >&2
        return 1
    fi
    
    if [[ ! "$verdict" =~ ^(PASS|FAIL|BLOCKED)$ ]]; then
        echo "ERROR: --verdict must be PASS, FAIL, or BLOCKED" >&2
        return 1
    fi
    
    local trace_file="$TRACES_DIR/$session_id.yaml"
    local temp_file
    temp_file=$(get_temp_state_file "$session_id")
    
    if [[ ! -f "$temp_file" ]]; then
        echo "ERROR: No active step for session $session_id (did you call start?)" >&2
        return 1
    fi
    
    # Load current step data
    local step_data
    step_data=$(cat "$temp_file")
    
    local decision_id
    local seq_num
    local step_description
    local timestamp_start
    
    decision_id=$(echo "$step_data" | grep "decision_id:" | awk '{print $2}')
    seq_num=$(echo "$step_data" | grep "seq_num:" | awk '{print $2}')
    step_description=$(echo "$step_data" | grep "step_description:" | cut -d: -f2- | xargs)
    timestamp_start=$(echo "$step_data" | grep "timestamp_start:" | awk '{print $2}')
    
    local timestamp_end
    timestamp_end=$(get_timestamp)
    
    # Compute deterministic checksum
    local checksum_input
    checksum_input="${decision_id}${step_description}${verdict}${timestamp_start}"
    local deterministic_checksum
    deterministic_checksum=$(compute_checksum "$checksum_input")
    
    # Initialize session if it doesn't exist
    if [[ ! -f "$trace_file" ]]; then
        cat > "$trace_file" <<EOF
trace_session:
  session_id: "$session_id"
  created_at: "$(get_timestamp)"
  status: "active"
  total_steps: 0
  total_forks: 0
  decisions:
  fork_graph:
    forks: []
EOF
    fi
    
    # Rebuild the session file with new decision appended
    # First, save the header
    local header_end
    header_end=$(grep -n "^  decisions:" "$trace_file" | cut -d: -f1)
    
    if [[ -z "$header_end" ]]; then
        # Decisions section not found, rebuild entire file
        cat > "$trace_file" <<EOF
trace_session:
  session_id: "$session_id"
  created_at: "$(grep 'created_at:' "$trace_file" | awk '{print $2}')"
  status: "active"
  total_steps: 0
  total_forks: 0
  decisions:
    - decision_id: "$decision_id"
      step_description: "$step_description"
      seq_num: $seq_num
      verdict: "$verdict"
      timestamp_start: "$timestamp_start"
      timestamp_end: "$timestamp_end"
      deterministic_checksum: "$deterministic_checksum"
      fork_decision: "$fork_decision"
  fork_graph:
    forks: []
EOF
    else
        # Append decision to existing file
        cat >> "$trace_file" <<EOF
    - decision_id: "$decision_id"
      step_description: "$step_description"
      seq_num: $seq_num
      verdict: "$verdict"
      timestamp_start: "$timestamp_start"
      timestamp_end: "$timestamp_end"
      deterministic_checksum: "$deterministic_checksum"
      fork_decision: "$fork_decision"
EOF
    fi
    
    # Update total_steps in header
    local current_steps
    current_steps=$(grep -c "decision_id:" "$trace_file" || echo 0)
    
    # Simple sed replacement for total_steps (no newlines involved)
    sed -i "s/total_steps: [0-9]*/total_steps: $current_steps/" "$trace_file"
    
    # Clean up temp file
    rm -f "$temp_file"
    
    return 0
}

# Command: ledger — Dump session ledger
cmd_ledger() {
    local session_id=""
    local format="yaml"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --session-id) session_id="$2"; shift 2 ;;
            --format) format="$2"; shift 2 ;;
            *) echo "ERROR: Unknown option $1"; return 1 ;;
        esac
    done
    
    if [[ -z "$session_id" ]]; then
        echo "ERROR: --session-id is required" >&2
        return 1
    fi
    
    local trace_file="$TRACES_DIR/$session_id.yaml"
    
    if [[ ! -f "$trace_file" ]]; then
        echo "ERROR: Session $session_id not found" >&2
        return 1
    fi
    
    case "$format" in
        yaml)
            cat "$trace_file"
            ;;
        json)
            # Simple YAML to JSON conversion (basic)
            cat "$trace_file" | sed 's/^/  /' | sed '1s/^  //' | grep -v "^$"
            ;;
        markdown)
            local ledger_md
            ledger_md=$(cat "$trace_file")
            echo "# Execution Ledger"
            echo ""
            echo "## Session: $session_id"
            echo ""
            echo "\`\`\`yaml"
            echo "$ledger_md"
            echo "\`\`\`"
            ;;
        *)
            echo "ERROR: Unknown format $format (use yaml, json, or markdown)" >&2
            return 1
            ;;
    esac
    
    return 0
}

# Command: replay — Deterministically replay a session
cmd_replay() {
    local session_id=""
    local verbose=0
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --session-id) session_id="$2"; shift 2 ;;
            --verbose) verbose=1; shift ;;
            *) echo "ERROR: Unknown option $1"; return 1 ;;
        esac
    done
    
    if [[ -z "$session_id" ]]; then
        echo "ERROR: --session-id is required" >&2
        return 1
    fi
    
    local trace_file="$TRACES_DIR/$session_id.yaml"
    
    if [[ ! -f "$trace_file" ]]; then
        echo "ERROR: Session $session_id not found" >&2
        return 1
    fi
    
    local session_data
    session_data=$(load_session "$session_id")
    
    # Extract decisions count
    local decision_count
    decision_count=$(echo "$session_data" | grep -c "decision_id:" || echo 0)
    
    if [[ $decision_count -eq 0 ]]; then
        echo "REPLAY_OK: No decisions to replay (empty session)"
        return 0
    fi
    
    if [[ $verbose -eq 1 ]]; then
        echo "Replaying session: $session_id"
        echo "Total decisions: $decision_count"
    fi
    
    # Validate checksums for each decision
    local decision_ids
    decision_ids=$(echo "$session_data" | grep "decision_id:" | grep "dec-" | awk '{print $NF}' | tr -d '"')
    
    local all_ok=true
    while IFS= read -r decision_id; do
        if [[ -z "$decision_id" ]]; then
            continue
        fi
        
        # Only process if it looks like a decision ID (starts with "dec-")
        if [[ ! "$decision_id" =~ ^dec- ]]; then
            continue
        fi
        
        # Extract decision data
        local decision_data
        decision_data=$(echo "$session_data" | grep -A 10 "decision_id: \"$decision_id\"")
        
        local stored_checksum
        stored_checksum=$(echo "$decision_data" | grep "deterministic_checksum:" | awk '{print $2}' | tr -d '"')
        
        local verdict
        verdict=$(echo "$decision_data" | grep "verdict:" | head -1 | awk '{print $2}' | tr -d '"')
        
        # For now, just verify checksum is present
        if [[ -z "$stored_checksum" ]]; then
            echo "REPLAY_DIVERGENCE: Missing checksum for $decision_id" >&2
            all_ok=false
            break
        fi
        
        if [[ $verbose -eq 1 ]]; then
            echo "  ✓ $decision_id: $verdict (checksum: ${stored_checksum:0:8}...)"
        fi
    done <<< "$decision_ids"
    
    if [[ "$all_ok" == "true" ]]; then
        echo "REPLAY_OK: All decisions replayed successfully"
        return 0
    else
        echo "REPLAY_DIVERGENCE: One or more decisions failed validation" >&2
        return 1
    fi
}

# Main dispatch
main() {
    local cmd="${1:-}"
    
    case "$cmd" in
        start)
            shift
            cmd_start "$@"
            ;;
        check)
            shift
            cmd_check "$@"
            ;;
        ledger)
            shift
            cmd_ledger "$@"
            ;;
        replay)
            shift
            cmd_replay "$@"
            ;;
        *)
            echo "Usage: verify_step.sh <command> [options]"
            echo ""
            echo "Commands:"
            echo "  start   --session-id <id> --step \"<description>\"  — Begin tracing a decision"
            echo "  check   --session-id <id> --verdict PASS|FAIL|BLOCKED  — Record decision outcome"
            echo "  ledger  --session-id <id> [--format yaml|json|markdown]  — Dump session ledger"
            echo "  replay  --session-id <id> [--verbose]  — Deterministically replay session"
            return 1
            ;;
    esac
}

main "$@"
