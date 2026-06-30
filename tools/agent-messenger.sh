#!/usr/bin/env bash

###############################################################################
# agent-messenger.sh — Multi-Agent Communication Protocol
#
# Usage:
#   agent-messenger.sh send --to <agent> --msg <json>
#   agent-messenger.sh list-queue [--agent <agent>]
#   agent-messenger.sh ack --msg-id <id>
#   agent-messenger.sh poll-queue --agent <agent>
#   agent-messenger.sh register-agent --name <agent>
#   agent-messenger.sh status [--agent <agent>]
#
# Queue Directory: .specs/changes/waves-7-17-implementation/queue/
###############################################################################

set -eu

# Configuration
QUEUE_BASE="${QUEUE_BASE:-.specs/changes/waves-7-17-implementation/queue}"
AGENT_REGISTRY="${QUEUE_BASE}/agent-registry.json"
MESSAGE_AUDIT="${QUEUE_BASE}/message-audit.log"

# Ensure queue directory exists
mkdir -p "$QUEUE_BASE"

###############################################################################
# Utility Functions
###############################################################################

log_audit() {
  local action="$1" message_id="$2" agent_from="$3" agent_to="$4" details="${5:-}"
  local timestamp
  timestamp=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
  
  cat >> "$MESSAGE_AUDIT" <<EOF
{"timestamp":"$timestamp","action":"$action","message_id":"$message_id","agent_from":"$agent_from","agent_to":"$agent_to"${details:+,"details":$details}}
EOF
}

generate_uuid() {
  # Simple UUID v4 generator
  local random_bytes
  random_bytes=$(od -An -tx1 -N16 /dev/urandom | tr -d ' ')
  # Format as UUID
  echo "${random_bytes:0:8}-${random_bytes:8:4}-${random_bytes:12:4}-${random_bytes:16:4}-${random_bytes:20:12}"
}

validate_agent_registry() {
  if [[ ! -f "$AGENT_REGISTRY" ]]; then
    # Create default registry if missing
    cat > "$AGENT_REGISTRY" <<'EOF'
{
  "agents": [
    { "name": "altitude-execution", "status": "active" },
    { "name": "altitude-plan", "status": "active" },
    { "name": "altitude-structure", "status": "active" },
    { "name": "altitude-validation", "status": "active" },
    { "name": "altitude-report", "status": "active" },
    { "name": "altitude-memory", "status": "active" },
    { "name": "altitude-intent", "status": "active" }
  ]
}
EOF
  fi
}

agent_exists() {
  local agent="$1"
  validate_agent_registry
  grep -q "\"name\": \"$agent\"" "$AGENT_REGISTRY" || return 1
}

agent_is_active() {
  local agent="$1"
  validate_agent_registry
  # Simple heuristic: if agent exists, assume active (in Wave 14 scope)
  agent_exists "$agent"
}

###############################################################################
# Commands
###############################################################################

cmd_send() {
  local agent_to="" msg_json=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --to)
        agent_to="$2"
        shift 2
        ;;
      --msg)
        msg_json="$2"
        shift 2
        ;;
      *)
        echo "Error: Unknown option $1" >&2
        return 1
        ;;
    esac
  done
  
  if [[ -z "$agent_to" || -z "$msg_json" ]]; then
    echo "Error: --to and --msg are required" >&2
    return 1
  fi
  
  # Validate recipient
  if ! agent_is_active "$agent_to"; then
    echo "Error: INVALID_RECIPIENT ($agent_to)" >&2
    return 1
  fi
  
  # Parse and validate message JSON
  if ! echo "$msg_json" | jq . > /dev/null 2>&1; then
    echo "Error: INVALID_MESSAGE (invalid JSON)" >&2
    return 1
  fi
  
  # Ensure agent_to is set in message
  msg_json=$(echo "$msg_json" | jq --arg to "$agent_to" '.agent_to |= ($to // .)' 2>/dev/null || echo "$msg_json")
  
  # Generate message ID and timestamp if missing
  local message_id
  message_id=$(echo "$msg_json" | jq -r '.message_id // empty')
  if [[ -z "$message_id" ]]; then
    message_id=$(generate_uuid)
    msg_json=$(echo "$msg_json" | jq --arg id "$message_id" '.message_id |= ($id // .)' 2>/dev/null || echo "$msg_json")
  fi
  
  local timestamp
  if ! echo "$msg_json" | jq -e '.timestamp' > /dev/null 2>&1; then
    timestamp=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    msg_json=$(echo "$msg_json" | jq --arg ts "$timestamp" '.timestamp |= ($ts // .)' 2>/dev/null || echo "$msg_json")
  fi
  
  # Create directory structure
  mkdir -p "$QUEUE_BASE/$agent_to/pending"
  
  # Write message atomically
  local msg_file="$QUEUE_BASE/$agent_to/pending/msg-$message_id.json"
  local temp_file="${msg_file}.tmp"
  
  echo "$msg_json" > "$temp_file"
  mv "$temp_file" "$msg_file"
  
  # Log audit
  local agent_from=$(echo "$msg_json" | jq -r '.agent_from // "unknown"')
  log_audit "enqueued" "$message_id" "$agent_from" "$agent_to"
  
  echo "OK: Message $message_id enqueued for $agent_to"
  return 0
}

cmd_list_queue() {
  local agent=""
  
  # Handle both positional and flag-based arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --agent)
        agent="$2"
        shift 2
        ;;
      *)
        # Treat as positional argument
        agent="$1"
        shift
        ;;
    esac
  done
  
  if [[ -n "$agent" ]]; then
    # List queue for specific agent
    if [[ ! -d "$QUEUE_BASE/$agent/pending" ]]; then
      echo "No messages for agent: $agent"
      return 0
    fi
    
    find "$QUEUE_BASE/$agent/pending" -name "msg-*.json" 2>/dev/null | while read -r msg_file; do
      cat "$msg_file"
    done
  else
    # List all queues
    find "$QUEUE_BASE" -path "*/pending/msg-*.json" 2>/dev/null | while read -r msg_file; do
      cat "$msg_file"
    done
  fi
}

cmd_ack() {
  local msg_id=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --msg-id)
        msg_id="$2"
        shift 2
        ;;
      *)
        echo "Error: Unknown option $1" >&2
        return 1
        ;;
    esac
  done
  
  if [[ -z "$msg_id" ]]; then
    echo "Error: --msg-id is required" >&2
    return 1
  fi
  
  # Find and move message from pending to processed
  local pending_file
  pending_file=$(find "$QUEUE_BASE" -path "*/pending/msg-$msg_id.json" 2>/dev/null | head -1)
  
  if [[ -z "$pending_file" ]]; then
    echo "Error: Message not found: $msg_id" >&2
    return 1
  fi
  
  local agent_dir
  agent_dir=$(dirname "$(dirname "$pending_file")")
  local processed_dir="$agent_dir/processed"
  
  mkdir -p "$processed_dir"
  
  # Move atomically
  mv "$pending_file" "$processed_dir/msg-$msg_id.json"
  
  # Log audit
  log_audit "acked" "$msg_id" "" ""
  
  echo "OK: Message $msg_id acknowledged"
  return 0
}

cmd_poll_queue() {
  local agent=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --agent)
        agent="$2"
        shift 2
        ;;
      *)
        echo "Error: Unknown option $1" >&2
        return 1
        ;;
    esac
  done
  
  if [[ -z "$agent" ]]; then
    echo "Error: --agent is required" >&2
    return 1
  fi
  
  # List pending messages for agent
  cmd_list_queue "$agent"
}

cmd_register_agent() {
  local agent_name=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name)
        agent_name="$2"
        shift 2
        ;;
      *)
        echo "Error: Unknown option $1" >&2
        return 1
        ;;
    esac
  done
  
  if [[ -z "$agent_name" ]]; then
    echo "Error: --name is required" >&2
    return 1
  fi
  
  validate_agent_registry
  
  # Create queue directories for this agent
  mkdir -p "$QUEUE_BASE/$agent_name/pending"
  mkdir -p "$QUEUE_BASE/$agent_name/processed"
  mkdir -p "$QUEUE_BASE/$agent_name/expired"
  
  # Add agent to registry if not already present
  if ! grep -q "\"name\": \"$agent_name\"" "$AGENT_REGISTRY"; then
    local temp_registry="${AGENT_REGISTRY}.tmp"
    jq ".agents += [{\"name\": \"$agent_name\", \"status\": \"active\"}]" "$AGENT_REGISTRY" > "$temp_registry"
    mv "$temp_registry" "$AGENT_REGISTRY"
  fi
  
  echo "OK: Agent $agent_name registered"
  return 0
}

cmd_status() {
  local agent="${1:-}"
  
  if [[ -n "$agent" ]]; then
    # Status for specific agent
    local pending_count=0
    local processed_count=0
    
    if [[ -d "$QUEUE_BASE/$agent/pending" ]]; then
      pending_count=$(find "$QUEUE_BASE/$agent/pending" -name "msg-*.json" 2>/dev/null | wc -l)
    fi
    
    if [[ -d "$QUEUE_BASE/$agent/processed" ]]; then
      processed_count=$(find "$QUEUE_BASE/$agent/processed" -name "msg-*.json" 2>/dev/null | wc -l)
    fi
    
    echo "Agent: $agent"
    echo "  Pending: $pending_count"
    echo "  Processed: $processed_count"
  else
    # Global status
    echo "Queue Status:"
    echo "  Base: $QUEUE_BASE"
    
    find "$QUEUE_BASE" -maxdepth 1 -type d -name "altitude-*" 2>/dev/null | while read -r agent_dir; do
      local agent
      agent=$(basename "$agent_dir")
      local pending_count=0
      local processed_count=0
      
      if [[ -d "$agent_dir/pending" ]]; then
        pending_count=$(find "$agent_dir/pending" -name "msg-*.json" 2>/dev/null | wc -l)
      fi
      
      if [[ -d "$agent_dir/processed" ]]; then
        processed_count=$(find "$agent_dir/processed" -name "msg-*.json" 2>/dev/null | wc -l)
      fi
      
      echo "  $agent:"
      echo "    Pending: $pending_count"
      echo "    Processed: $processed_count"
    done
  fi
}

###############################################################################
# Main
###############################################################################

main() {
  local cmd="${1:-}"
  shift || true
  
  case "$cmd" in
    send)
      cmd_send "$@"
      ;;
    list-queue)
      cmd_list_queue "$@"
      ;;
    ack)
      cmd_ack "$@"
      ;;
    poll-queue)
      cmd_poll_queue "$@"
      ;;
    register-agent)
      cmd_register_agent "$@"
      ;;
    status)
      cmd_status "$@"
      ;;
    *)
      echo "Usage: $0 <command> [options]"
      echo ""
      echo "Commands:"
      echo "  send --to <agent> --msg <json>     Enqueue message"
      echo "  list-queue [--agent <agent>]       List pending queue"
      echo "  ack --msg-id <id>                  Acknowledge message"
      echo "  poll-queue --agent <agent>         Poll agent queue"
      echo "  register-agent --name <agent>      Register agent"
      echo "  status [--agent <agent>]           Queue status"
      return 1
      ;;
  esac
}

main "$@"
