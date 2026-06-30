#!/usr/bin/env bash
# recovery-manager.sh
# 
# Atomic recovery and rollback for Harness V3 execution
# Manages state snapshots, rollback, and validation
#
# Commands:
#   snapshot --state <json> [--note <text>]     Create snapshot, return snapshot_id
#   rollback --to <snapshot_id> [--output <file>]  Restore state from snapshot
#   validate --snapshot <snapshot_id>            Verify snapshot integrity
#   list-snapshots [--change <change_id>]        List all snapshots
#
# Storage: .specs/changes/<change_id>/snapshots/
# Format: snap-<timestamp>-<random>.json

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

CHANGE_ID="${CHANGE_ID:-waves-7-17-implementation}"
SNAPSHOTS_DIR=".specs/changes/${CHANGE_ID}/snapshots"
JQ_CMD="jq"

# ============================================================================
# Utility Functions
# ============================================================================

err() {
  echo "ERROR: $*" >&2
  return 1
}

info() {
  echo "[recovery-manager] $*" >&2
}

random_suffix() {
  head -c 3 /dev/urandom | od -An -tx1 | tr -d ' '
}

iso8601_now() {
  date -u +'%Y-%m-%dT%H:%M:%SZ'
}

# ============================================================================
# Snapshot Functions
# ============================================================================

cmd_snapshot() {
  local state_json=""
  local note="manual_snapshot"
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --state)
        state_json="$2"
        shift 2
        ;;
      --note)
        note="$2"
        shift 2
        ;;
      *)
        err "Unknown argument: $1"
        return 1
        ;;
    esac
  done
  
  # Validate
  if [[ -z "$state_json" ]]; then
    err "snapshot: --state is required"
    return 1
  fi
  
  # Validate JSON
  if ! echo "$state_json" | "$JQ_CMD" . > /dev/null 2>&1; then
    err "snapshot: --state is not valid JSON"
    return 1
  fi
  
  # Ensure snapshots directory exists
  mkdir -p "$SNAPSHOTS_DIR" || err "snapshot: cannot create $SNAPSHOTS_DIR" || return 1
  
  # Generate snapshot_id
  timestamp=$(iso8601_now)
  suffix=$(random_suffix)
  snapshot_id="snap-${timestamp}-${suffix}"
  
  # Compute state hash
  state_hash="sha256:$(echo "$state_json" | "$JQ_CMD" '.' | sha256sum | awk '{print $1}')"
  
  # Create snapshot structure
  snapshot=$(cat <<EOF
{
  "snapshot_id": "$snapshot_id",
  "created_at": "$timestamp",
  "state_hash": "$state_hash",
  "components": $state_json,
  "notes": "$note"
}
EOF
)
  
  # Atomic write: temp + move
  tmp=$(mktemp "${SNAPSHOTS_DIR}/.snap-XXXXXX.tmp") || {
    err "snapshot: cannot create temp file"
    return 1
  }
  
  if ! echo "$snapshot" | "$JQ_CMD" '.' > "$tmp" 2>/dev/null; then
    rm -f "$tmp"
    err "snapshot: cannot format snapshot JSON"
    return 1
  fi
  
  if ! chmod 644 "$tmp"; then
    rm -f "$tmp"
    err "snapshot: cannot chmod temp file"
    return 1
  fi
  
  if ! mv "$tmp" "${SNAPSHOTS_DIR}/${snapshot_id}.json"; then
    rm -f "$tmp"
    err "snapshot: cannot move temp to snapshot file"
    return 1
  fi
  
  # Return snapshot_id on stdout
  echo "$snapshot_id"
  info "snapshot: created $snapshot_id"
}

# ============================================================================
# Rollback Functions
# ============================================================================

cmd_rollback() {
  local snapshot_id=""
  local output_file=""
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --to)
        snapshot_id="$2"
        shift 2
        ;;
      --output)
        output_file="$2"
        shift 2
        ;;
      *)
        err "Unknown argument: $1"
        return 1
        ;;
    esac
  done
  
  # Validate
  if [[ -z "$snapshot_id" ]]; then
    err "rollback: --to is required"
    return 1
  fi
  
  # Check snapshot file exists
  snapshot_file="${SNAPSHOTS_DIR}/${snapshot_id}.json"
  if [[ ! -f "$snapshot_file" ]]; then
    err "rollback: snapshot not found: $snapshot_id"
    return 1
  fi
  
  # Validate snapshot
  if ! cmd_validate --snapshot "$snapshot_id" > /dev/null 2>&1; then
    err "rollback: snapshot validation failed: $snapshot_id"
    return 1
  fi
  
  # Read snapshot
  if ! snapshot_json=$(<"$snapshot_file"); then
    err "rollback: cannot read snapshot file"
    return 1
  fi
  
  # Extract components
  if ! components=$(echo "$snapshot_json" | "$JQ_CMD" '.components' 2>/dev/null); then
    err "rollback: cannot extract components from snapshot"
    return 1
  fi
  
  # Check timestamp: snapshot must be in past
  created_at=$(echo "$snapshot_json" | "$JQ_CMD" -r '.created_at' 2>/dev/null)
  now=$(iso8601_now)
  if [[ "$created_at" > "$now" ]]; then
    err "rollback: snapshot is in future: $created_at > $now"
    return 1
  fi
  
  # Atomic write: temp + move
  if [[ -n "$output_file" ]]; then
    output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir" || {
      err "rollback: cannot create output directory"
      return 1
    }
    tmp=$(mktemp "${output_dir}/.rollback-XXXXXX.tmp") || {
      err "rollback: cannot create temp file"
      return 1
    }
    if ! echo "$components" | "$JQ_CMD" '.' > "$tmp" 2>/dev/null; then
      rm -f "$tmp"
      err "rollback: cannot format components JSON"
      return 1
    fi
    if ! mv "$tmp" "$output_file"; then
      rm -f "$tmp"
      err "rollback: cannot move temp to output file"
      return 1
    fi
  else
    # Output to stdout
    echo "$components"
  fi
  
  info "rollback: restored from $snapshot_id (created: $created_at)"
}

# ============================================================================
# Validation Functions
# ============================================================================

cmd_validate() {
  local snapshot_id=""
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --snapshot)
        snapshot_id="$2"
        shift 2
        ;;
      *)
        err "Unknown argument: $1"
        return 1
        ;;
    esac
  done
  
  # Validate
  if [[ -z "$snapshot_id" ]]; then
    err "validate: --snapshot is required"
    return 1
  fi
  
  # Check file exists
  snapshot_file="${SNAPSHOTS_DIR}/${snapshot_id}.json"
  if [[ ! -f "$snapshot_file" ]]; then
    err "validate: snapshot not found: $snapshot_id"
    return 1
  fi
  
  # Read snapshot
  if ! snapshot_json=$(<"$snapshot_file"); then
    err "validate: cannot read snapshot file"
    return 1
  fi
  
  # Validate JSON
  if ! echo "$snapshot_json" | "$JQ_CMD" '.' > /dev/null 2>&1; then
    err "validate: snapshot JSON is corrupted"
    return 1
  fi
  
  # Check required fields
  for field in snapshot_id created_at state_hash components; do
    if ! echo "$snapshot_json" | "$JQ_CMD" -e ".$field" > /dev/null 2>&1; then
      err "validate: missing required field: $field"
      return 1
    fi
  done
  
  # Validate snapshot_id format
  stored_id=$(echo "$snapshot_json" | "$JQ_CMD" -r '.snapshot_id')
  if [[ "$stored_id" != "$snapshot_id" ]]; then
    err "validate: snapshot_id mismatch: stored=$stored_id, expected=$snapshot_id"
    return 1
  fi
  
  # Validate ISO8601 timestamp
  created_at=$(echo "$snapshot_json" | "$JQ_CMD" -r '.created_at')
  if ! date -d "$created_at" > /dev/null 2>&1; then
    err "validate: invalid ISO8601 timestamp: $created_at"
    return 1
  fi
  
  # Validate state_hash format
  state_hash=$(echo "$snapshot_json" | "$JQ_CMD" -r '.state_hash')
  if [[ ! "$state_hash" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    err "validate: invalid state_hash format: $state_hash"
    return 1
  fi
  
  # Validate phase and status
  phase=$(echo "$snapshot_json" | "$JQ_CMD" -r '.components.altitude_phase // empty')
  status=$(echo "$snapshot_json" | "$JQ_CMD" -r '.components.altitude_status // empty')
  
  if [[ -n "$phase" && ! "$phase" =~ ^(Intent|Structure|Design|Execution|Validate|Ship)$ ]]; then
    err "validate: invalid altitude_phase: $phase"
    return 1
  fi
  
  if [[ -n "$status" && ! "$status" =~ ^(blocked|ready|in_progress|implemented|validated)$ ]]; then
    err "validate: invalid altitude_status: $status"
    return 1
  fi
  
  # Verify checksum: recompute and compare
  components=$(echo "$snapshot_json" | "$JQ_CMD" '.components')
  computed_hash="sha256:$(echo "$components" | "$JQ_CMD" '.' | sha256sum | awk '{print $1}')"
  
  if [[ "$state_hash" != "$computed_hash" ]]; then
    err "validate: checksum mismatch: stored=$state_hash, computed=$computed_hash"
    return 1
  fi
  
  info "validate: snapshot OK: $snapshot_id"
  echo "OK"
}

# ============================================================================
# List Snapshots
# ============================================================================

cmd_list_snapshots() {
  local change_id="$CHANGE_ID"
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --change)
        change_id="$2"
        shift 2
        ;;
      *)
        err "Unknown argument: $1"
        return 1
        ;;
    esac
  done
  
  local list_dir=".specs/changes/${change_id}/snapshots"
  
  if [[ ! -d "$list_dir" ]]; then
    info "list-snapshots: no snapshots directory: $list_dir"
    return 0
  fi
  
  if [[ -z "$(ls -A "$list_dir" 2>/dev/null)" ]]; then
    info "list-snapshots: no snapshots found in $list_dir"
    return 0
  fi
  
  # List snapshots with metadata
  echo "Snapshots in $list_dir:"
  echo ""
  
  for snapshot_file in "$list_dir"/snap-*.json; do
    if [[ ! -f "$snapshot_file" ]]; then
      continue
    fi
    
    filename=$(basename "$snapshot_file")
    snapshot_id="${filename%.json}"
    
    if snapshot_json=$(<"$snapshot_file" 2>/dev/null); then
      created_at=$(echo "$snapshot_json" | "$JQ_CMD" -r '.created_at // "unknown"' 2>/dev/null)
      notes=$(echo "$snapshot_json" | "$JQ_CMD" -r '.notes // ""' 2>/dev/null)
      phase=$(echo "$snapshot_json" | "$JQ_CMD" -r '.components.altitude_phase // "-"' 2>/dev/null)
      
      printf "  %-50s | %s | %s | %s\n" "$snapshot_id" "$created_at" "$phase" "$notes"
    fi
  done
}

# ============================================================================
# Main Dispatch
# ============================================================================

main() {
  if [[ $# -eq 0 ]]; then
    cat >&2 <<EOF
recovery-manager.sh — Atomic recovery and rollback for Harness V3

Usage:
  recovery-manager.sh snapshot --state <json> [--note <text>]
  recovery-manager.sh rollback --to <snapshot_id> [--output <file>]
  recovery-manager.sh validate --snapshot <snapshot_id>
  recovery-manager.sh list-snapshots [--change <change_id>]

Commands:
  snapshot      Create a snapshot, return snapshot_id to stdout
  rollback      Restore state from snapshot
  validate      Verify snapshot integrity
  list-snapshots  List all snapshots

Environment:
  CHANGE_ID     Change directory (default: waves-7-17-implementation)

EOF
    return 1
  fi
  
  local cmd="$1"
  shift
  
  case "$cmd" in
    snapshot)
      cmd_snapshot "$@"
      ;;
    rollback)
      cmd_rollback "$@"
      ;;
    validate)
      cmd_validate "$@"
      ;;
    list-snapshots)
      cmd_list_snapshots "$@"
      ;;
    *)
      err "Unknown command: $cmd"
      return 1
      ;;
  esac
}

main "$@"
