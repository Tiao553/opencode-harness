# Allocation Ledger Contract

## Overview

**Purpose:** Define schema and query semantics for allocation events recorded during Harness V3 execution.

**Where:** `.specs/changes/<change_id>/03-execution-ledger.md` (embedded YAML section)

**Owner:** `altitude-execution`, `altitude-validation`, all agents making file mutations

**Queries:** `tools/allocation-check.sh validate-scope <change_id>`

---

## Ledger Location

Allocation events live in the execution ledger under a dedicated section:

```markdown
# 3. Execution Ledger

## Allocation Events
[YAML block: allocation_events array]

## Task Events
[YAML block: task_events array]

## Validation Events
[YAML block: validation_events array]
```

---

## Event Schema

### Root Structure

```yaml
allocation_events:
  - event_id: allocation-event-20260629-042-001
    timestamp: 2026-06-29T02:45:00Z
    type: allocation_assigned | file_write_allowed | scope_expansion_requested | violation_blocked | warning
    
    # Context
    change_id: wave-5-allocation-enforcement
    phase: Intent | Structure | Design/Plan | Execution | Validate | Ship
    task_id: task-1 | null
    agent: altitude-execution | dbt-specialist | null
    
    # File/scope details
    file: <file-path>  # null for task-level events
    scope_delta: [<file-1>, <file-2>]  # null unless scope expansion
    
    # Decision/outcome
    decision: approved | aborted | escalated | null
    decided_by: <agent-name> | <human-name> | null
    
    # Context
    reason: <human-readable string>
    error: <error message if applicable>
    
    # Traceability
    parent_event_id: <event_id if escalated>
    linked_events: [<event_id>, ...]
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event_id` | string | ✓ | Unique identifier: `allocation-event-<timestamp>-<sequence>` |
| `timestamp` | ISO-8601 | ✓ | When event occurred |
| `type` | enum | ✓ | Event classification |
| `change_id` | string | ✓ | Change being executed |
| `phase` | enum | ✓ | Harness phase when event occurred |
| `task_id` | string | ✗ | Task if applicable (null for change-level) |
| `agent` | string | ✗ | Agent that triggered event |
| `file` | string | ✗ | File path (null for task/change-level) |
| `scope_delta` | array[string] | ✗ | Files added to scope (scope expansion events) |
| `decision` | enum | ✗ | User/specialist decision (if escalation) |
| `decided_by` | string | ✗ | Who made decision |
| `reason` | string | ✓ | Human-readable context |
| `error` | string | ✗ | Error message if applicable |
| `parent_event_id` | string | ✗ | Links to parent event (escalations) |
| `linked_events` | array[string] | ✗ | Related events (violations + approvals) |

---

## Event Types

### `allocation_assigned`

Fired when a task is assigned with a defined allocation.

**Triggers:**
- altitude-plan creates task with local allocation
- altitude-execution loads task from spec

**Schema:**
```yaml
type: allocation_assigned
file: null
task_id: task-5
scope_delta: null
decision: null
reason: "Task allocated with scope: [agents/altitude-execution.agent.md]"
```

**Queries:**
- "Show me all tasks assigned in this change"
- "Was this task allocated properly?"

**Example:**
```yaml
- event_id: allocation-event-20260629-042-001
  timestamp: 2026-06-29T02:00:00Z
  type: allocation_assigned
  change_id: wave-5
  phase: Design/Plan
  task_id: task-1
  agent: altitude-plan
  reason: "Task 1 assigned: scope=[agents/altitude-execution.agent.md]"
```

---

### `file_write_allowed`

Fired when a file write is validated and allowed to proceed.

**Triggers:**
- Agent calls `write()` tool
- Enforcement layer validates against allocation
- File matches allowed_files

**Schema:**
```yaml
type: file_write_allowed
file: agents/altitude-execution.agent.md
task_id: task-1
scope_delta: null
decision: null
reason: "Write allowed (file in allowed_files)"
```

**Queries:**
- "What files were written by this task?"
- "Show me all successful writes"
- "Did this file write stay within scope?"

**Example:**
```yaml
- event_id: allocation-event-20260629-042-042
  timestamp: 2026-06-29T02:15:00Z
  type: file_write_allowed
  change_id: wave-5
  phase: Execution
  task_id: task-1
  file: agents/altitude-execution.agent.md
  agent: altitude-execution
  reason: "File write allowed (agents/altitude-execution.agent.md in allowed_files)"
```

---

### `scope_expansion_requested`

Fired when user approves a scope expansion (write outside initial scope).

**Triggers:**
- Agent tries to write file outside allowed_files
- Enforcement layer blocks + asks user
- User selects "Approve"
- Allocation is expanded

**Schema:**
```yaml
type: scope_expansion_requested
file: AGENTS.md
task_id: task-1
scope_delta: [AGENTS.md]
decision: approved
decided_by: user
reason: "User approved scope expansion: adding AGENTS.md to allowed_files"
```

**Queries:**
- "What scope expansions occurred?"
- "Was AGENTS.md initially approved to be modified?"
- "Show all files modified outside original scope"

**Example:**
```yaml
- event_id: allocation-event-20260629-042-043
  timestamp: 2026-06-29T02:30:00Z
  type: scope_expansion_requested
  change_id: wave-5
  phase: Execution
  task_id: task-1
  file: AGENTS.md
  agent: altitude-execution
  scope_delta: [AGENTS.md]
  decision: approved
  decided_by: user
  reason: "User approved modification of AGENTS.md (critical doc update)"
```

---

### `violation_blocked`

Fired when a write violates scope and is blocked.

**Triggers:**
- Agent tries to write file outside allowed_files
- File NOT approved for scope expansion
- User selects "Abort" or "Escalate"

**Schema:**
```yaml
type: violation_blocked
file: .specs/memory/active-state.md
task_id: task-1
scope_delta: [.specs/memory/active-state.md]
decision: aborted | escalated
decided_by: user | escalation-specialist
reason: "Write blocked: .specs/memory/ not in allowed_files, user aborted"
```

**Queries:**
- "What violations were blocked?"
- "Which files did this task try to write outside scope?"
- "Show all escalated violations"

**Example (Aborted):**
```yaml
- event_id: allocation-event-20260629-042-044
  timestamp: 2026-06-29T02:35:00Z
  type: violation_blocked
  change_id: wave-5
  phase: Execution
  task_id: task-1
  file: .specs/memory/active-state.md
  agent: altitude-execution
  scope_delta: [.specs/memory/active-state.md]
  decision: aborted
  decided_by: user
  reason: "Write blocked (.specs/memory/ not in allowed_files), user aborted task"
```

**Example (Escalated):**
```yaml
- event_id: allocation-event-20260629-042-045
  timestamp: 2026-06-29T02:40:00Z
  type: violation_blocked
  change_id: wave-5
  phase: Execution
  task_id: task-1
  file: .secrets.yaml
  agent: altitude-execution
  scope_delta: [.secrets.yaml]
  decision: escalated
  decided_by: security-guardian
  reason: "Write blocked (.secrets.yaml is protected), escalated to security specialist"
  parent_event_id: allocation-event-20260629-042-044
```

---

### `warning`

Fired when a write occurs without allocation (backward compatibility mode).

**Triggers:**
- Task has no allocation contract
- Enforcement in advisory mode (Wave 5)
- Write allowed with warning

**Schema:**
```yaml
type: warning
file: agents/custom-agent.agent.md
task_id: task-99
scope_delta: null
decision: allowed_with_caveat
reason: "No allocation defined for this task; write allowed but untracked"
```

**Queries:**
- "Show me tasks without allocations"
- "Identify untracked writes"

---

## Ledger Queries

### Query 1: All writes within scope (safe)

```bash
tools/allocation-check.sh validate-scope wave-5-allocation-enforcement
# Output:
# Allocation Summary for wave-5-allocation-enforcement
# Total events: 42
# Safe writes (file_write_allowed): 38
# Scope expansions (approved): 2
# Violations (blocked): 1
# Warnings (no allocation): 1
```

---

### Query 2: Scope expansions

```bash
# Using yq directly
yq '.allocation_events[] | select(.type == "scope_expansion_requested")' 03-execution-ledger.md
# Output:
# event_id: allocation-event-20260629-042-043
# file: AGENTS.md
# decision: approved
# reason: "User approved scope expansion..."
```

---

### Query 3: Violations

```bash
yq '.allocation_events[] | select(.type == "violation_blocked")' 03-execution-ledger.md
# Output: List of blocked violations
```

---

### Query 4: Files modified outside initial scope

```bash
yq '.allocation_events[] | select(.type == "scope_expansion_requested") | .file' 03-execution-ledger.md
# Output: [AGENTS.md, ...]
```

---

### Query 5: Audit trail (task → events)

```bash
TASK_ID=task-1
yq ".allocation_events[] | select(.task_id == \"$TASK_ID\")" 03-execution-ledger.md | sort -k2
# Shows chronological order of all allocation events for task-1
```

---

## Ledger Format Example

```markdown
# 3. Execution Ledger

## Allocation Events

allocation_events:
  - event_id: allocation-event-20260629-042-001
    timestamp: 2026-06-29T02:00:00Z
    type: allocation_assigned
    change_id: wave-5
    phase: Design/Plan
    task_id: task-1
    agent: altitude-plan
    file: null
    scope_delta: null
    decision: null
    decided_by: null
    reason: "Task 1 assigned with scope: [agents/altitude-execution.agent.md, .specs/shared/allocation-*.md]"
    error: null
    parent_event_id: null
    linked_events: []

  - event_id: allocation-event-20260629-042-042
    timestamp: 2026-06-29T02:15:00Z
    type: file_write_allowed
    change_id: wave-5
    phase: Execution
    task_id: task-1
    agent: altitude-execution
    file: agents/altitude-execution.agent.md
    scope_delta: null
    decision: null
    decided_by: null
    reason: "Write allowed (file in allowed_files)"
    error: null
    parent_event_id: null
    linked_events: []

  - event_id: allocation-event-20260629-042-043
    timestamp: 2026-06-29T02:30:00Z
    type: scope_expansion_requested
    change_id: wave-5
    phase: Execution
    task_id: task-1
    agent: altitude-execution
    file: AGENTS.md
    scope_delta: [AGENTS.md]
    decision: approved
    decided_by: user
    reason: "User approved modification to AGENTS.md for Wave 5 integration"
    error: null
    parent_event_id: null
    linked_events:
      - allocation-event-20260629-042-044  # Write after approval

  - event_id: allocation-event-20260629-042-044
    timestamp: 2026-06-29T02:31:00Z
    type: file_write_allowed
    change_id: wave-5
    phase: Execution
    task_id: task-1
    agent: altitude-execution
    file: AGENTS.md
    scope_delta: null
    decision: null
    decided_by: null
    reason: "Write allowed after scope expansion approval"
    error: null
    parent_event_id: null
    linked_events: [allocation-event-20260629-042-043]

  - event_id: allocation-event-20260629-042-045
    timestamp: 2026-06-29T02:45:00Z
    type: violation_blocked
    change_id: wave-5
    phase: Execution
    task_id: task-1
    agent: altitude-execution
    file: .specs/memory/active-state.md
    scope_delta: [.specs/memory/active-state.md]
    decision: aborted
    decided_by: user
    reason: "Write blocked (.specs/memory/ not in allowed_files), user aborted task"
    error: "File not in allowed_files; scope expansion rejected by user"
    parent_event_id: null
    linked_events: []
```

---

## Audit Trail Integrity

### Verification Queries

**Q: Did this task only write files within scope?**
```bash
TASK_ID=task-1
yq ".allocation_events[] | select(.task_id == \"$TASK_ID\" and .type == \"violation_blocked\")" ledger.md
# If empty → YES, all writes were within scope
# If not empty → NO, some writes were blocked
```

**Q: What's the complete history of this file?**
```bash
FILE=AGENTS.md
yq ".allocation_events[] | select(.file == \"$FILE\")" ledger.md | jq -s 'sort_by(.timestamp)'
# Shows: when allocated, when written, when expanded, etc.
```

**Q: Were all scope expansions approved?**
```bash
yq ".allocation_events[] | select(.type == \"scope_expansion_requested\" and .decision != \"approved\")" ledger.md
# If empty → YES, all expansions were approved
# If not empty → NO, some were escalated/aborted
```

---

## Backward Compatibility

### Old Tasks (No Allocation)

Events for tasks without allocation:
- Type: `warning`
- Decision: `allowed_with_caveat`
- Reason: "No allocation defined; write allowed but untracked"

Example:
```yaml
- event_id: allocation-event-20260629-042-099
  timestamp: 2026-06-29T03:00:00Z
  type: warning
  task_id: null
  file: old_file.md
  reason: "No allocation defined; write allowed for backward compatibility"
```

---

## Performance

- **Event creation:** < 1ms (append to array)
- **Query (all events):** < 10ms (linear scan)
- **Query (specific type):** < 10ms (yq filter)
- **Storage:** ~1KB per event (negligible)

No significant performance impact.

---

## Related Documents

- `.specs/shared/allocation-enforcement-contract.md` — Matching + validation rules
- `.specs/shared/local-allocation-contract.md` — Task allocation schema
- `.specs/shared/global-allocation-contract.md` — Change allocation schema
- `tools/allocation-check.sh` — Query utilities

---

**Last Updated:** June 29, 2026  
**Version:** 1.0.0 (Wave 5)  
**Status:** Design Phase
