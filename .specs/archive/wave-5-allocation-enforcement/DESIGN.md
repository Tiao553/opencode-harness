# Wave 5: Global/Task Allocation Enforcement

## Problem Statement

Currently in Harness V3, allocation contracts define `allowed_files` and `forbidden_files` boundaries, but **there is no runtime enforcement**. Coordinators and agents can mutate files outside their allocated scope without any validation or blocking.

**Risks:**
- Scope creep (agents modifying files outside their authority)
- Hidden dependencies (unclear which agent touched which files)
- Audit trail gaps (no record of attempted violations)
- Unintended side effects (changes to protected files like AGENTS.md, contracts)

**Example violation:**
```
Global allocation allows: agents/, .specs/shared/
Local allocation for task-1 allows: agents/altitude-execution.agent.md
Agent tries to write: AGENTS.md (forbidden)
Current behavior: ✗ Write succeeds (no enforcement)
Desired behavior: ✓ Write blocked + ask user for approval
```

---

## Solution: Allocation Enforcement Layer

**Goal:** Validate all file mutations against allocation contracts; detect scope creep; ask user for approval before expanding scope.

**Scope Model:**
- **Per-pattern:** `agents/*.agent.md`, `.specs/shared/`, `tools/`
- **Per-file:** Exact paths like `AGENTS.md`, `README.md`
- **Negation:** `!agents/DEFAULT.AGENT.agent.md` (exclude pattern)

**Validation Points:**
1. **Task Assignment** (pre-check): Verify task scope against global allocation
2. **Execution** (real-time): Validate every write before it happens
3. **Violations**: Block write + ask user to approve or abort

**Escalation:**
- If agent tries to write outside scope:
  1. Compute scope delta (what new files are requested)
  2. Show user: "Write requests access to X new files, currently allowed only Y"
  3. Ask: Approve expansion? / Abort write? / Escalate to specialist?
  4. If approved: Record in ledger + expand allocation
  5. If abort: Stop task, return to phase start
  6. If escalate: Route to security specialist or coordinator

---

## Deliverables

### 1. Shared Contracts (2 files, ~800 lines)

#### `allocation-enforcement-contract.md`
- Defines scope matching algorithm (per-pattern + per-file)
- Specifies validation rules (allowed vs. forbidden)
- Documents escalation paths
- Examples: safe, safe-narrowing, unsafe-broadening scenarios

#### `allocation-ledger-contract.md`
- Defines ledger entries for allocation events
- Records: allocation_assigned, file_write_allowed, scope_expansion_requested, violation_blocked
- Timestamps + evidence fields

### 2. Agent Updates (3 files, ~150 lines)

#### `altitude-execution.agent.md`
- Before write: validate file against local allocation
- If violates: block + ask user to approve scope expansion
- Log allocation event to ledger

#### `altitude-validation.agent.md`
- Pre-validation check: confirm all artifacts within scope
- Report: "validation run analyzed X files, all within scope"

#### `altitude-report.agent.md`
- Pre-report check: confirm report artifact within scope
- Include: scope compliance summary in report

### 3. Enforcement Logic (1 new file, ~200 lines)

#### `tools/allocation-check.sh`
- Commands:
  - `check-file <file> <allocation.yaml>` — Is file allowed?
  - `check-pattern <file> <pattern>` — Does file match pattern?
  - `expand-allocation <old> <new_files>` — Show delta
  - `validate-scope <ledger> <change_id>` — Full audit

### 4. Golden Fixtures (6 scenarios, ~400 lines)

**Fixture 1:** Safe write (file in allowed list)  
**Fixture 2:** Safe narrowing (task scope ⊂ global scope)  
**Fixture 3:** Unsafe broadening (task tries to write outside global)  
**Fixture 4:** Violation + user approval (expands allocation)  
**Fixture 5:** Violation + abort (user declines, rolls back)  
**Fixture 6:** End-to-end (assign → execute → validate → audit)

---

## Acceptance Criteria

### AC1: Scope Matching
- ✅ Per-pattern matching works (`agents/*.agent.md`, `tools/`, etc.)
- ✅ Per-file matching works (exact paths)
- ✅ Negation patterns work (`!DEFAULT.AGENT.agent.md`)
- ✅ Order respected (first match wins)

### AC2: Validation at Task Assignment
- ✅ Pre-check: task scope ⊂ global scope
- ✅ If violates: raise alert (but allow with user confirmation)
- ✅ Record in ledger: `allocation_assigned` event

### AC3: Validation During Execution
- ✅ Real-time file write checks
- ✅ If violates: block write + ask user
- ✅ Ask-user options: approve / abort / escalate
- ✅ If approved: record `scope_expansion_requested` event
- ✅ If abort: `violation_blocked` event + restore ledger

### AC4: Audit Trail
- ✅ All allocation events logged to ledger
- ✅ Ledger queryable: `allocation-check.sh validate-scope`
- ✅ Report includes scope compliance summary

### AC5: Backward Compatibility
- ✅ Tasks without allocation still work (no breaking changes)
- ✅ Old code paths unaffected
- ✅ Enforcement opt-in initially, mandatory later

---

## Phase Integration

### Intent Phase
- Identify scope implications: who should write what

### Structure Phase
- Define global allocation (allowed/forbidden files)
- Identify risky surfaces (protected files)

### Design/Plan Phase
- Create local allocations (per task)
- Verify no broadening of global scope
- Plan escalation strategy

### Execution Phase
- Enforce during writes
- Ask user for approval if scope creep detected
- Log all events to ledger

### Validate Phase
- Query: "Were all writes within scope?"
- Check: ledger integrity (all writes logged)
- Report: scope compliance ✓ or violations ✗

### Ship Phase
- Audit trail included in ship summary
- Archive allocation evidence

---

## Technical Design

### Scope Matching Algorithm

```
function matches_pattern(file, pattern):
  1. If pattern starts with '!': negate
  2. Convert pattern to regex:
     - '*.agent.md' → '.*\.agent\.md$'
     - 'tools/' → 'tools/.*'
     - 'AGENTS.md' → '^AGENTS\.md$'
  3. Match file against regex
  4. Return: true/false

function is_file_allowed(file, allocation):
  rules = allocation.allowed_files + allocation.forbidden_files
  for rule in rules (in order):
    if matches_pattern(file, rule):
      return !rule.startswith('!')
  return false
```

### Escalation Flow

```
Agent writes file X
  ↓
Is X in allowed_files?
  ↓ YES → Write allowed, log event, continue
  ↓ NO → Compute delta (X not in allowed_files)
    ↓
    Ask user:
      A. Approve scope expansion
      B. Abort write (return to phase start)
      C. Escalate to security specialist
    ↓
    If A: Update allocation, log event, write allowed
    If B: Log violation_blocked, stop task
    If C: Route to security specialist, pause task
```

### Ledger Entry Format

```yaml
allocation_events:
  - event_id: allocation-event-20260629-001
    timestamp: 2026-06-29T01:00:00Z
    type: allocation_assigned | file_write_allowed | scope_expansion_requested | violation_blocked
    change_id: wave-5-allocation-enforcement
    task_id: task-1
    file: agents/altitude-execution.agent.md
    scope_delta: null | ["AGENTS.md", "README.md"]
    decision: null | approved | aborted | escalated
    agent: altitude-execution
```

---

## Implementation Plan

### Step 1: Create Contracts (Days 1-2)
- allocation-enforcement-contract.md (scope model + validation rules)
- allocation-ledger-contract.md (event schema)

### Step 2: Implement Enforcement Logic (Days 2-3)
- tools/allocation-check.sh (scope matching + validation)
- Test with golden scenarios

### Step 3: Update Agents (Days 3-4)
- altitude-execution: add pre-write validation
- altitude-validation: add pre-validation check
- altitude-report: add pre-report check

### Step 4: Create Fixtures & Document (Days 4-5)
- 6 golden fixtures
- Update README.md (Wave 5 section)
- Update AGENTS.md

### Step 5: Integration & Testing (Day 5)
- End-to-end test: assign → execute → validate → audit
- Verify backward compatibility
- Review with user

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| **Breaking changes** | Enforcement opt-in initially; gradual rollout |
| **False positives** (legitimate writes blocked) | Clear error messages + ask-user options |
| **Performance overhead** | Allocation checks O(P) where P = pattern count (usually < 20) |
| **Scope drift over time** | Audit trail enables discovery of unapproved changes |

---

## Success Metrics

- ✅ All writes validated against allocation
- ✅ Zero untracked scope changes (audit trail 100% complete)
- ✅ Scope creep detected within 1 second
- ✅ User asked for approval before any scope expansion
- ✅ All golden fixtures pass
- ✅ Zero breaking changes to existing code

---

## Next Wave

**Wave 6: Context Budget & Headroom Validation**
- Implement token/context budget tracking
- Validate before loading context
- Enforce maximum context per task

---

**Status:** Ready for Design/Plan → Execution transition  
**Created:** June 29, 2026  
**Author:** OpenCode Harness V3  
**Phase:** Design/Plan (waiting for user approval to proceed to Execution)
