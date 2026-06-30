# agent-messenger.sh — Command Reference

**Version:** 1.0  
**Location:** `tools/agent-messenger.sh`  
**Backing Contract:** `.specs/shared/protocol-contract.md`

---

## Overview

The `agent-messenger.sh` script provides CLI access to the Agent Communication Protocol, enabling multi-agent messaging, routing, and acknowledgments within the Harness V3 architecture.

---

## Installation

```bash
chmod +x tools/agent-messenger.sh
```

---

## Commands

### send — Enqueue a Message

```bash
agent-messenger.sh send --to <agent> --msg <json>
```

**Purpose:** Send a message to another agent's queue.

**Options:**
- `--to <agent>` — Recipient agent name (required)
- `--msg <json>` — Message JSON payload (required)

**Returns:**
- Exit 0: `OK: Message <id> enqueued for <agent>`
- Exit 1: Error (invalid recipient, invalid JSON, etc.)

**Errors:**
- `INVALID_RECIPIENT` — Recipient not in agent registry
- `INVALID_MESSAGE` — Message JSON is malformed
- `QUEUE_FULL` — Queue at capacity (not implemented in v1)
- `PERSISTENCE_ERROR` — Could not write to disk

**Examples:**

```bash
# Send a task
agent-messenger.sh send --to altitude-plan --msg '{
  "agent_from": "altitude-execution",
  "message_type": "task",
  "payload": {
    "task_id": "W14-PROTOCOLS",
    "action": "execute"
  }
}'

# Send a state change
agent-messenger.sh send --to altitude-validation --msg '{
  "agent_from": "altitude-execution",
  "message_type": "state",
  "payload": {
    "entity": "phase",
    "to_state": "executing"
  }
}'

# Send with auto-generated message_id and timestamp
agent-messenger.sh send --to altitude-report --msg '{
  "agent_from": "altitude-execution",
  "message_type": "result",
  "payload": {
    "task_id": "W14-PROTOCOLS",
    "status": "success"
  }
}'
```

---

### list-queue — Show Pending Messages

```bash
agent-messenger.sh list-queue [--agent <agent>]
```

**Purpose:** List pending messages in the queue.

**Options:**
- `--agent <agent>` — Show queue for specific agent (optional)

**Returns:**
- Each message as JSON (one per line)
- Empty output if no messages

**Examples:**

```bash
# Show all pending messages
agent-messenger.sh list-queue

# Show pending messages for altitude-execution
agent-messenger.sh list-queue --agent altitude-execution
```

**Output:**

```json
{"message_id":"550e8400-e29b-41d4-a716-446655440000","timestamp":"2026-06-29T12:34:56Z","agent_from":"altitude-plan","agent_to":"altitude-execution","message_type":"task","payload":{"task_id":"W14-PROTOCOLS","action":"execute"}}
{"message_id":"550e8400-e29b-41d4-a716-446655440001","timestamp":"2026-06-29T12:35:00Z","agent_from":"altitude-validation","agent_to":"altitude-execution","message_type":"result","payload":{"task_id":"W7-RALPH-LOOP","status":"success"}}
```

---

### ack — Acknowledge a Message

```bash
agent-messenger.sh ack --msg-id <id>
```

**Purpose:** Acknowledge receipt of a message, moving it from pending to processed.

**Options:**
- `--msg-id <id>` — Message ID to acknowledge (required)

**Returns:**
- Exit 0: `OK: Message <id> acknowledged`
- Exit 1: Error (message not found, etc.)

**Errors:**
- Message not found in any pending queue

**Examples:**

```bash
agent-messenger.sh ack --msg-id 550e8400-e29b-41d4-a716-446655440000
```

---

### poll-queue — Poll Agent Queue

```bash
agent-messenger.sh poll-queue --agent <agent>
```

**Purpose:** Poll and return pending messages for an agent (alias for `list-queue --agent`).

**Options:**
- `--agent <agent>` — Agent to poll (required)

**Returns:**
- Each pending message as JSON (one per line)

**Examples:**

```bash
# Poll altitude-execution queue
agent-messenger.sh poll-queue --agent altitude-execution

# Typical workflow:
agent-messenger.sh poll-queue --agent altitude-execution | while read msg; do
  echo "Processing: $msg"
  msg_id=$(echo "$msg" | jq -r '.message_id')
  # ... process message ...
  agent-messenger.sh ack --msg-id "$msg_id"
done
```

---

### register-agent — Register an Agent

```bash
agent-messenger.sh register-agent --name <agent>
```

**Purpose:** Register an agent in the messaging system (creates directories).

**Options:**
- `--name <agent>` — Agent name (required)

**Returns:**
- Exit 0: `OK: Agent <agent> registered`
- Exit 1: Error

**Notes:**
- Called automatically by agents during initialization
- Creates: `pending/`, `processed/`, `expired/` directories

**Examples:**

```bash
agent-messenger.sh register-agent --name altitude-custom
```

---

### status — Show Queue Status

```bash
agent-messenger.sh status [--agent <agent>]
```

**Purpose:** Show queue statistics.

**Options:**
- `--agent <agent>` — Status for specific agent (optional)

**Returns:**
- Summary of pending and processed message counts

**Examples:**

```bash
# Global status
agent-messenger.sh status

# Sample output:
# Queue Status:
#   Base: .specs/changes/waves-7-17-implementation/queue
#   altitude-execution:
#     Pending: 3
#     Processed: 15
#   altitude-plan:
#     Pending: 1
#     Processed: 8

# Status for specific agent
agent-messenger.sh status --agent altitude-execution

# Sample output:
# Agent: altitude-execution
#   Pending: 3
#   Processed: 15
```

---

## Queue Directory Structure

```
.specs/changes/waves-7-17-implementation/queue/
├── agent-registry.json
├── message-audit.log
├── altitude-execution/
│   ├── pending/
│   │   ├── msg-550e8400-e29b-41d4-a716-446655440000.json
│   │   └── msg-550e8400-e29b-41d4-a716-446655440001.json
│   ├── processed/
│   │   ├── msg-550e8400-e29b-41d4-a716-446655440010.json
│   │   └── msg-550e8400-e29b-41d4-a716-446655440011.json
│   └── expired/
├── altitude-plan/
│   ├── pending/
│   ├── processed/
│   └── expired/
└── [other agents...]
```

**Files:**
- `agent-registry.json` — Registered agents and status
- `message-audit.log` — Audit trail of all operations
- `*/pending/` — Messages awaiting processing
- `*/processed/` — Acknowledged messages
- `*/expired/` — Expired messages

---

## Environment Variables

```bash
# Override queue base directory (default: .specs/changes/waves-7-17-implementation/queue)
export QUEUE_BASE="/custom/queue/path"
agent-messenger.sh send --to altitude-execution --msg '{...}'
```

---

## Integration Pattern

### Agent Initialization

```bash
# In agent startup:
agent-messenger.sh register-agent --name my-agent
```

### Message Processing Loop

```bash
# Poll and process messages:
agent-messenger.sh poll-queue --agent my-agent | while read msg; do
  # Parse and process
  msg_id=$(echo "$msg" | jq -r '.message_id')
  msg_type=$(echo "$msg" | jq -r '.message_type')
  
  case "$msg_type" in
    task)
      # Handle task message
      ;;
    state)
      # Handle state message
      ;;
    *)
      # Handle other types
      ;;
  esac
  
  # Acknowledge after processing
  agent-messenger.sh ack --msg-id "$msg_id"
done
```

### Sending a Message

```bash
# From one agent to another:
agent-messenger.sh send --to altitude-validation --msg "$(jq -n \
  --arg from "$(hostname)" \
  --arg task "$TASK_ID" \
  '{
    "agent_from": $from,
    "message_type": "result",
    "payload": {
      "task_id": $task,
      "status": "success"
    }
  }')"
```

---

## Error Handling

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `INVALID_RECIPIENT` | Agent not registered | Check agent-registry.json |
| `INVALID_MESSAGE` | Malformed JSON | Validate message JSON |
| `Message not found` | Already acked or expired | Check message ID |
| `Permission denied` | Cannot write to queue dir | Check directory permissions |

### Retry Logic

```bash
# Retry with exponential backoff
send_with_retry() {
  local agent="$1" msg="$2" attempt=0 max_attempts=5
  
  while (( attempt < max_attempts )); do
    if agent-messenger.sh send --to "$agent" --msg "$msg"; then
      return 0
    fi
    ((attempt++))
    sleep $((2 ** attempt))
  done
  
  return 1
}
```

---

## Audit Trail

All operations are logged to `.specs/changes/waves-7-17-implementation/queue/message-audit.log`:

```json
{"timestamp":"2026-06-29T12:34:56Z","action":"enqueued","message_id":"550e8400-e29b-41d4-a716-446655440000","agent_from":"altitude-execution","agent_to":"altitude-plan","details":{}}
{"timestamp":"2026-06-29T12:35:10Z","action":"acked","message_id":"550e8400-e29b-41d4-a716-446655440000","agent_from":"","agent_to":""}
```

**Actions:**
- `enqueued` — Message added to queue
- `delivered` — Message delivered (future)
- `acked` — Message acknowledged
- `expired` — Message expired
- `failed` — Send failed

---

## Performance Characteristics

- **Send latency:** ~10-50ms (filesystem I/O)
- **List-queue:** O(n) where n = message count
- **ACK latency:** ~5-20ms (rename operation)
- **Scalability:** Tested up to ~10K messages per agent

---

## References

- **Protocol Contract:** `.specs/shared/protocol-contract.md`
- **Test Fixture:** `test/fixtures/harness-v3/wave-14-protocols-smoke.fixture.md`
- **Agent Integration Points:**
  - `agents/altitude-execution.agent.md`
  - `agents/altitude-plan.agent.md`
  - `agents/altitude-structure.agent.md`
  - `agents/altitude-validation.agent.md`
