# Allocation Enforcement Contract

## Overview

**Purpose:** Define scope matching, validation rules, and escalation paths for file-level allocation enforcement.

**Applies to:** All coordinators, agents, and tasks operating under Harness V3.

**Phase:** Execution and Validation (real-time enforcement).

---

## Scope Model

### Pattern Types

Allocations use **patterns** to define allowed and forbidden files. Patterns support:

#### 1. Glob Patterns
Match multiple files using wildcards.

```yaml
allowed_files:
  - agents/*.agent.md          # All agents
  - .specs/shared/             # All files in shared
  - tools/*.sh                 # All shell scripts
```

**Syntax:**
- `*` = match any characters except `/`
- `**` = match any characters including `/`
- `?` = match single character
- `[abc]` = match a, b, or c

#### 2. Exact Paths
Match specific files.

```yaml
allowed_files:
  - AGENTS.md                  # Exact file
  - README.md
  - .gitignore
```

#### 3. Directory Patterns
Match all files in a directory tree.

```yaml
allowed_files:
  - .specs/shared/             # All files under .specs/shared/
  - agents/                    # All files under agents/
```

#### 4. Negation Patterns
Exclude files from a broader pattern.

```yaml
allowed_files:
  - agents/*.agent.md          # All agent files

forbidden_files:
  - agents/DEFAULT.AGENT.agent.md  # Except DEFAULT
```

---

## Scope Matching Algorithm

### Rule Order

Patterns are evaluated **in order**. First match determines outcome.

```yaml
allowed_files:
  - agents/*.agent.md          # Rule 1: ALLOW agents
  - tools/                     # Rule 2: ALLOW tools

forbidden_files:
  - agents/DEFAULT.AGENT.agent.md  # Rule 3: FORBID DEFAULT
  - AGENTS.md                  # Rule 4: FORBID AGENTS.md
```

**Query:** Is `agents/altitude-execution.agent.md` allowed?

```
1. Check allowed_files (in order):
   Rule 1: agents/*.agent.md? → YES → ALLOW

Result: ALLOW
```

**Query:** Is `agents/DEFAULT.AGENT.agent.md` allowed?

```
1. Check allowed_files (in order):
   Rule 1: agents/*.agent.md? → YES → ALLOW

2. Check forbidden_files (in order):
   Rule 3: agents/DEFAULT.AGENT.agent.md? → YES → FORBID

Result: FORBID (forbidden overrides allowed)
```

### Matching Function

```python
def matches_pattern(file_path, pattern):
    """
    Returns True if file_path matches pattern.

    Patterns:
      - Glob: agents/*.agent.md
      - Exact: AGENTS.md
      - Directory: .specs/shared/
      - Negation: handled by caller (not this function)
    """
    import fnmatch

    # If pattern ends with /, it's a directory
    if pattern.endswith('/'):
        # Match directory prefix
        return file_path.startswith(pattern) or file_path.startswith(pattern.rstrip('/') + '/')

    # Otherwise use glob matching
    return fnmatch.fnmatch(file_path, pattern)


def is_file_allowed(file_path, allocation):
    """
    Returns (is_allowed: bool, rule_matched: str | None)

    Algorithm:
      1. Check allowed_files in order (first match wins)
      2. If match found in allowed: return True
      3. Check forbidden_files in order (override)
      4. If match found in forbidden: return False
      5. If no match: return False (default deny)
    """
    # Check allowed rules first
    for rule in allocation.get('allowed_files', []):
        if matches_pattern(file_path, rule):
            # Check if forbidden overrides
            for forbidden_rule in allocation.get('forbidden_files', []):
                if matches_pattern(file_path, forbidden_rule):
                    return (False, forbidden_rule)
            return (True, rule)

    # Check forbidden rules (if not already allowed)
    for forbidden_rule in allocation.get('forbidden_files', []):
        if matches_pattern(file_path, forbidden_rule):
            return (False, forbidden_rule)

    # Default deny: if not in allowed list, deny
    return (False, None)
```

---

## Validation Rules

### Safe: Write Within Scope

**Condition:** File is in `allowed_files` AND not in `forbidden_files`

**Behavior:**
- ✓ Write allowed
- Log: `file_write_allowed` event
- Continue execution

**Example:**
```yaml
allowed_files: [agents/*.agent.md, .specs/shared/]
forbidden_files: []

Write: agents/altitude-execution.agent.md
Result: ✓ ALLOWED
Event: file_write_allowed
```

---

### Safe Narrowing: Local Scope ⊂ Global Scope

**Condition:** Task's `allowed_files` is strict subset of task's global allocation

**Behavior:**
- ✓ Assignment allowed
- Log: `allocation_assigned` event
- Narrowed scope enforced during execution

**Example:**
```yaml
Global allowed: [agents/, .specs/shared/, tools/]
Global forbidden: []

Task allowed: [agents/altitude-execution.agent.md]
Task forbidden: []

Result: ✓ SAFE NARROWING (agents/altitude-execution.agent.md ⊂ agents/)
Event: allocation_assigned
```

---

### Unsafe: Broadening Global Scope

**Condition:** Task tries to write file outside global `allowed_files`

**Behavior:**
- ✗ Write blocked (pre-check)
- Ask user: approve scope expansion or abort
- If approved: record `scope_expansion_requested` event + expand allocation
- If abort: record `violation_blocked` event + restore state

**Example:**
```yaml
Global allowed: [agents/, .specs/shared/]
Global forbidden: [AGENTS.md]

Task allowed: [agents/altitude-execution.agent.md]

Attempt write: AGENTS.md
Check: Is AGENTS.md in global allowed? → NO
Check: Is AGENTS.md in global forbidden? → YES

Result: ✗ VIOLATION (AGENTS.md explicitly forbidden globally)
Action: Block write, ask user
```

---

### Validation Rules Summary

| Scenario | Check | Decision | Action |
|----------|-------|----------|--------|
| File in allowed_files | ✓ | ALLOW | Write allowed, log event |
| File in forbidden_files | ✗ | FORBID | Block write, ask user |
| File outside both | ✗ | DENY (default) | Block write, ask user |
| Task scope ⊂ global | ✓ | ASSIGN | Allocate task, log event |
| Task scope ⊃ global | ✗ | REJECT | Ask user before assignment |
| Local forbids, global allows | ✗ | FORBID (local wins) | Block write |

---

## Escalation: Scope Expansion

When a write violates scope, the enforcement layer asks the user for a decision.

### Escalation Flow

```
Agent tries: write AGENTS.md
  ↓
Check: Is AGENTS.md allowed?
  ↓ NO → compute_delta()
  ↓
delta = {
  file: AGENTS.md,
  currently_allowed: [agents/, .specs/shared/],
  reason: "adding AGENTS.md to allowed_files expands scope"
}
  ↓
Ask user:
  A. Approve — expand allocation + allow write
  B. Abort — block write + return to phase start
  C. Escalate — route to security specialist
```

### Ask-User Options

#### Option A: Approve Scope Expansion

**When:** User confirms the write is legitimate and necessary.

**Actions:**
1. Expand allocation: add file to `allowed_files`
2. Log event: `scope_expansion_requested` + `approved`
3. Allow write to proceed
4. Continue execution

**Ledger Entry:**
```yaml
- event_id: allocation-event-20260629-042
  timestamp: 2026-06-29T02:45:00Z
  type: scope_expansion_requested
  file: AGENTS.md
  decision: approved
  agent: altitude-execution
  reason: "User approved scope expansion for critical doc update"
```

---

#### Option B: Abort Write

**When:** User wants to stop the write and return to phase start.

**Actions:**
1. Block write (do not execute)
2. Log event: `violation_blocked` + `aborted`
3. Stop task execution
4. Return to previous phase (Design/Plan)

**Ledger Entry:**
```yaml
- event_id: allocation-event-20260629-043
  timestamp: 2026-06-29T02:46:00Z
  type: violation_blocked
  file: AGENTS.md
  decision: aborted
  agent: altitude-execution
  reason: "User aborted write, scope violation"
```

---

#### Option C: Escalate to Specialist

**When:** User wants human review (security, architecture) before approving.

**Actions:**
1. Block write temporarily
2. Route to appropriate specialist (e.g., security-guardian, architect)
3. Specialist reviews and decides: approve or reject
4. Log: `violation_blocked` + `escalated` + specialist decision

**Ledger Entry:**
```yaml
- event_id: allocation-event-20260629-044
  timestamp: 2026-06-29T02:47:00Z
  type: violation_blocked
  decision: escalated
  file: AGENTS.md
  escalated_to: security-guardian
  reason: "Scope expansion requires security review"
```

---

## Ledger Events

Allocation events are recorded in `.specs/changes/<change_id>/03-execution-ledger.md`.

### Event Schema

```yaml
allocation_events:
  - event_id: allocation-event-<timestamp>-<sequence>
    timestamp: <ISO-8601>
    type: allocation_assigned | file_write_allowed | scope_expansion_requested | violation_blocked
    change_id: <change-slug>
    task_id: <task-id>
    file: <file-path>

    # Optional: for scope expansion
    scope_delta: [<new-file-1>, <new-file-2>, ...]
    reason: <human-readable reason>

    # Optional: for decisions
    decision: approved | aborted | escalated
    decided_by: <agent> | <human>

    agent: <agent-name>
    phase: Intent | Structure | Design/Plan | Execution | Validate | Ship
```

### Event Types

#### `allocation_assigned`
Fired when a task is assigned with allocation scope.

```yaml
type: allocation_assigned
task_id: task-5
file: null  # Task-level event
reason: "Task allocated with scope: agents/altitude-execution.agent.md"
```

#### `file_write_allowed`
Fired when a file write is validated and allowed.

```yaml
type: file_write_allowed
file: agents/altitude-execution.agent.md
reason: "Write allowed (in allowed_files)"
```

#### `scope_expansion_requested`
Fired when user approves scope expansion.

```yaml
type: scope_expansion_requested
file: AGENTS.md
scope_delta: [AGENTS.md]
decision: approved
reason: "User approved adding AGENTS.md to allowed_files"
```

#### `violation_blocked`
Fired when a write violates scope and is blocked.

```yaml
type: violation_blocked
file: AGENTS.md
decision: aborted  # or: escalated
reason: "Write blocked (AGENTS.md not in allowed_files)"
```

---

## Backward Compatibility

### Tasks Without Allocation

If a task does not have an allocation contract:
- Enforcement is **advisory** (warn, don't block)
- Write allowed with a caveat: "No allocation defined; write allowed but untracked"
- Logged: `warning` event (not violation)

### Old Code Paths

Existing coordinators/agents continue to work:
- Allocation enforcement is **opt-in during Wave 5** (configurable)
- Made **mandatory in Wave 6+** with migration period

### Migration Path

1. **Wave 5 (current):** Enforcement available; opt-in
2. **Wave 5.1:** Enforcement on by default; can disable with `--skip-allocation-check`
3. **Wave 6:** Enforcement mandatory; no disable flag

---

## Examples

### Example 1: Safe Write (Agent Within Scope)

```yaml
# Global allocation
allowed_files:
  - agents/
  - .specs/shared/
forbidden_files:
  - AGENTS.md

# Local allocation (task-1)
allowed_files:
  - agents/altitude-execution.agent.md
forbidden_files: []

# Action: Agent writes agents/altitude-execution.agent.md
is_allowed = is_file_allowed('agents/altitude-execution.agent.md', local_allocation)
# Check allowed_files: agents/altitude-execution.agent.md matches agents/*.agent.md? → YES
# Check forbidden_files: agents/altitude-execution.agent.md matches AGENTS.md? → NO
# Result: (True, 'agents/altitude-execution.agent.md')

# Outcome: ✓ ALLOWED
# Event: file_write_allowed
```

---

### Example 2: Safe Narrowing (Task Scope ⊂ Global)

```yaml
# Global
allowed_files: [agents/, .specs/shared/, tools/]
forbidden_files: []

# Local (task-2)
allowed_files: [agents/altitude-validation.agent.md]
forbidden_files: []

# Check: Is local ⊂ global?
# agents/altitude-validation.agent.md ⊂ agents/ → YES

# Outcome: ✓ SAFE NARROWING
# Event: allocation_assigned
```

---

### Example 3: Unsafe Broadening (Task Violates Global)

```yaml
# Global
allowed_files: [agents/, .specs/shared/]
forbidden_files: [AGENTS.md]

# Local (task-3)
allowed_files: [agents/, AGENTS.md]
forbidden_files: []

# Check: Is local ⊂ global?
# AGENTS.md ⊂ allowed_files? → NO
# AGENTS.md ∈ forbidden_files? → YES

# Outcome: ✗ UNSAFE BROADENING
# Action: Ask user
#   A. Approve (expand global scope)
#   B. Abort task
#   C. Escalate to security
```

---

### Example 4: Violation + User Approval

```yaml
# User runs task that tries to write AGENTS.md
Agent attempts: write AGENTS.md

# Check allocation:
is_allowed = is_file_allowed('AGENTS.md', task_allocation)
# Result: (False, 'AGENTS.md in forbidden_files')

# Block write + ask user
ask_user([
  {label: 'Approve scope expansion', description: 'Allow write to AGENTS.md'},
  {label: 'Abort write', description: 'Stop task, return to phase start'},
  {label: 'Escalate', description: 'Route to security specialist'}
])

# User selects: Approve
# Actions:
#   1. Expand allocation: add AGENTS.md to allowed_files
#   2. Log: scope_expansion_requested (approved)
#   3. Write allowed to proceed

# Event:
# - type: scope_expansion_requested
#   file: AGENTS.md
#   decision: approved
#   reason: "User approved scope expansion"
```

---

## Testing

Golden fixtures validate:
1. Safe writes (file in allowed)
2. Safe narrowing (task scope ⊂ global)
3. Unsafe broadening (task violates global)
4. Violation + approval (expand scope)
5. Violation + abort (block + return to phase)
6. End-to-end (assign → execute → validate → audit)

See: `test/fixtures/harness-v3/wave-5-allocation-enforcement.fixture.md`

---

## Performance

- **Scope matching:** O(P) where P = # of patterns (typically < 50)
- **File write validation:** < 1ms per file (cached patterns)
- **Per-task overhead:** < 5ms (negligible)

No significant performance impact for typical tasks.

---

## Related Contracts

- `.specs/shared/local-allocation-contract.md` — Task-level allocation
- `.specs/shared/global-allocation-contract.md` — Change-level allocation
- `tools/allocation-check.sh` — Enforcement utilities

---

**Last Updated:** June 29, 2026
**Version:** 1.0.0 (Wave 5)
**Status:** Design Phase
**Author:** OpenCode Harness V3

---

# Allocation Ledger

## Overview (from allocation-ledger-contract)

**Purpose:** Define schema and query semantics for allocation events recorded during Harness V3 execution.

**Where:** `.specs/changes/<change_id>/03-execution-ledger.md` (embedded YAML section)

**Owner:** `altitude-execution`, `altitude-validation`, all agents making file mutations

**Queries:** `tools/allocation-check.sh validate-scope <change_id>`

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

## Event Schema (Extended)

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
| `decided_by` | string | ✗ | Who made decision (agent or human) |
| `reason` | string | ✓ | Why event occurred |
| `error` | string | ✗ | Error details (if applicable) |
| `parent_event_id` | string | ✗ | Escalation parent (if escalated) |
| `linked_events` | array[string] | ✗ | Related events |

## Ledger Queries

**Query allocation events for a change:**
```bash
tools/allocation-check.sh validate-scope wave-5 | grep "allocation_events"
```

**Audit all scope expansions:**
```bash
tools/allocation-check.sh list-changes | xargs -I {} tools/allocation-check.sh validate-scope {} | grep "scope_expansion_requested"
```

---

# Todo Projection (from todo-allocation-contract)

## Purpose

Define how the harness projects durable state into `TodoWrite`.

This contract exists to prevent the todo list from becoming a second planner. The todo list is an operational projection of current state, not an independent source of truth.

## Source Of Truth (Todo)

The todo tree must be derived from:

- `.specs/memory/active-state.md`
- active change `state.md`
- active phase contract
- active task contract
- active `Task-Spec` leaf task when present

**Rule:** `TodoWrite` is never the source of truth.

## Todo Projection Model

The coordinator should project work as a hierarchy:

```text
Wave / Change
└── Phase
    └── Task
        └── Todo
```

This means:

- the system may show many tasks when the wave truly has many tasks
- the system may show many todos inside a task when nuance demands it
- visibility comes from hierarchy, not from hiding work arbitrarily

## Visibility Rule (Todo)

If the active wave has 20 tasks, the projection may show the 20 tasks.

The harness should not enforce a small artificial cap that hides real decomposition detail.

## Todo Requirements

Every operational todo must include:

- **task id** — Which task this belongs to
- **specialist name** (when relevant) — Who is helping
- **short action statement** — What needs to happen
- **explicit `verify:` clause** — How to validate completion
- **loop posture** (when executable) — Whether Ralph Loop applies

### Todo Example

```yaml
- task_id: T-006
  owner: altitude-execution
  specialist: null
  action: "Consolidate allocation contracts: 7 → 3"
  verify: "allocation-contract.md absorbs global + local; enforcement + ledger merged; no agent refs broken"
  loop_posture: mandatory
```

### With Specialist

```yaml
- task_id: T-042
  owner: altitude-execution
  specialist: architect.schema-designer
  action: "Design complex dimensional model"
  verify: "Schema meets normal form 3NF; DDL passes validation; row counts match source"
  loop_posture: mandatory
```

## Specialist Rule (Todo)

When a delegated specialist is involved, the todo **must** always cite the specialist name.

This prevents hidden delegation and ensures visibility into who is doing the work.

## Verify Rule (Todo)

Every operational todo must include a `verify:` signal.

No todo should be emitted as execution-ready without a visible verification path.

Acceptable verify clauses:
- Concrete command: `bash test/smoke.sh`
- Manual check: `Review output in STDOUT`
- File check: `✅ if BUILD_MANIFEST.md exists and contains entry X`

**Not acceptable:**
- "looks good"
- "feels right"
- "trust the implementation"

## Loop Rule (Todo)

Todos for executable work inherit loop posture from the active task.

| Task posture | Todo posture | Example |
| --- | --- | --- |
| `mandatory` | include `[loop:mandatory]` | `[loop:mandatory] Consolidate files and verify no refs broken` |
| `advisory` | include loop marker only when useful | `[loop:advisory] Code style cleanup` |
| `not_applicable` | omit loop marker | `Documentation update` |

The todo list does not run Ralph Loop by itself; it projects the operational steps that the coordinator must verify through `.specs/shared/execution-loop-contract.md`.

## Recompute Rule (Todo)

The coordinator must recompute the todo tree when any of the following changes:

- active phase
- active task
- task status (pending → in_progress → completed)
- validation verdict (pass → fail)
- blocker status (new blocker, blocker resolved)
- replan or decomposition change
- explicit human override

Incremental patching is allowed internally, but the model exposed to the user should reflect a full recompute of the current valid work tree.

## Task and Todo Relationship

- **tasks** remain the durable work contract (source of truth)
- **todos** are the operational breakdown for current execution and navigation
- **todos must not** widen scope beyond the task

Example:
```text
TASK (durable):
  - task_id: T-42
  - scope: agents/**, .specs/shared/**
  - verify: "Integration tests pass"
  - evidence: test output
  
TODO (operational projection):
  - action: "Review agents/ code structure"
    verify: "All 9 agents follow naming convention"
  - action: "Run integration tests"
    verify: "test/integration.sh exit 0"
  - action: "Review test output"
    verify: "Coverage > 85%"
  
✓ Todos do NOT expand task scope
✓ Todos break down task into steps
```

## Tactical Versus Strategic Use

| Path | Todo posture |
| --- | --- |
| Strategic coordinator (Altitude) | project or change wave → task → todo |
| Tactical data-engineer coordinator | tactical work queue → task → todo |

Both use the same hierarchy. Difference is what lives at the "wave" level (durable change vs. tactical queue).

## Anti-Patterns (Todo)

- todo list as a second planner (don't create todos without backing task)
- todo without `verify:` (unverifiable work)
- todo without specialist when a specialist is involved (hidden delegation)
- shallow todo list that hides real decomposition (artificial task count)
- todo list that survives a phase change without recompute (stale todos)
- todos that broaden task scope (violates allocation)

---

**Last Updated:** June 29, 2026  
**Version:** 1.1.0 (consolidated from allocation-enforcement, allocation-ledger, todo-allocation)  
**Status:** Phase 0 Consolidation Complete

