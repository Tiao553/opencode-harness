# State Machine Contract — Harness V3 Phase FSM

**Version:** 1.0  
**Status:** Active (Wave 11)  
**Last Updated:** 2026-06-29  

---

## Overview

This contract defines the formal finite state machine (FSM) for Harness V3 phase transitions. It enforces:

- Valid state sequences (no backward jumps except Design ← Validate)
- No self-loops (state must change)
- Deadlock detection (circular wait scenarios)
- Idempotent validation (same input → same result)

---

## states:

```yaml
states:
  - Intent: "Problem definition and stakeholder alignment"
  - Structure: "Repository surface mapping and scope definition"
  - Design: "Technical requirements and task decomposition"
  - Execution: "Task implementation and code generation"
  - Validate: "Verification, evidence, and acceptance criteria"
  - Ship: "Archival, lessons, and state update"
```

Each state is terminal (no self-loops). Phase advancement must change state.

---

## transitions:

```yaml
transitions:
  Intent:
    forward_only: ["Structure"]
    allows_skip: []
    allows_backtrack: false
    invariant: "Single entry point for all changes"

  Structure:
    forward_only: ["Design"]
    allows_skip: []
    allows_backtrack: false
    invariant: "Must map scope before design"

  Design:
    forward_only: ["Execution", "Validate"]
    allows_skip: []
    allows_backtrack: false
    invariant: "Can fast-track to validation if needed early"

  Execution:
    forward_only: ["Validate"]
    allows_skip: []
    allows_backtrack: false
    invariant: "Code/artifact generation completes before validation"

  Validate:
    forward_only: ["Ship"]
    allows_skip: []
    allows_backtrack: ["Design"]
    invariant: "Single backward transition to Design for rework (validated only once)"

  Ship:
    forward_only: []
    allows_skip: []
    allows_backtrack: false
    invariant: "Terminal state; loops begin next change (Intent)"
```

---

## Valid State Paths

```
Path 1 (Happy Path):
  Intent → Structure → Design → Execution → Validate → Ship

Path 2 (Early Validation):
  Intent → Structure → Design → Validate → Ship

Path 3 (Rework Loop):
  Intent → Structure → Design → Execution → Validate → Design → Execution → Validate → Ship
  (Only backward edge: Validate → Design)

Path 4 (Design-Validate Rework):
  Intent → Structure → Design → Validate → Design → Execution → Validate → Ship
```

---

## Forbidden State Transitions

```yaml
forbidden:
  - "Ship → Intent"           # Must create new change, not loop
  - "Validate → Execution"    # Must rework through Design
  - "Validate → Intent"       # Must rework through Design
  - "Execution → Design"      # Must rework through Validate
  - "Execution → Execution"   # No self-loops
  - "Design → Design"         # No self-loops
  - "Structure → Intent"      # No backward jumps (except Validate → Design)
  - "Intent → Design"         # Must pass through Structure
  - "Intent → Execution"      # Must pass through Structure + Design
  - "Design → Ship"           # Must pass through Execution + Validate
```

---

## Transition Rules

### Rule 1: Forward-Only (Default)
Transitions are strictly forward except Validate → Design.

```
current_state ∈ {Intent, Structure, Execution}
  ⟹ next_state ∈ forward_only[current_state]
  ⟹ next_state > current_state (numerically ordered)
```

### Rule 2: Design Branches
From Design, can go to Execution (normal) or Validate (fast-track).

```
current_state = Design
  ⟹ next_state ∈ {Execution, Validate}
```

### Rule 3: Validate Rework Loop
Validate can branch to Ship (pass) or Design (rework).

```
current_state = Validate
  ⟹ next_state ∈ {Ship, Design}
  ⟹ if next_state = Design, record rework attempt
```

### Rule 4: No Self-Loops
State cannot transition to itself.

```
current_state ≠ next_state
  ⟹ always true for valid transitions
```

### Rule 5: Idempotency
Calling validate(A, B) multiple times with same arguments yields same result.

```
validate(A, B) at t1 = validate(A, B) at t2
  ⟹ always returns same PASS/FAIL
```

---

## State Ordering (Numeric)

For forward-only validation:

```
Intent (1) < Structure (2) < Design (3) < Execution (4) < Validate (5) < Ship (6)
```

Rework edge Validate → Design is allowed as special case (backward but documented).

---

## Deadlock Detection

### Deadlock Condition

Circular wait for phase advancement where state A requires event from B, B requires event from C, and C requires A:

```
State A: waiting for approval from State B
State B: waiting for approval from State C
State C: waiting for State A to provide something

Example (Change P1):
  Execution: waiting for Validate phase gate (event from user)
  Validate: waiting for test results (external event)
  Test: waiting for Execution to complete (impossible, Execution blocked)
  
  ⟹ Circular dependency detected → DEADLOCK
```

### Deadlock Detection Algorithm

```bash
For each state S in trace:
  1. Collect all "waiting_for" events
  2. Build dependency graph: S → {events/states}
  3. Run cycle detection (DFS)
  4. If cycle found ⟹ DEADLOCK
  5. Report cycle path and involved states
```

### Deadlock Prevention Rules

```yaml
deadlock_prevention:
  - "Execution must complete before Validate gate can open"
  - "Validate rework must go through Design, not loop to Execution"
  - "No state can wait on itself (caught by no-self-loop rule)"
  - "No two states can wait on each other (symmetric wait forbidden)"
```

---

## Invariants

```yaml
invariants:
  - "No state repeats in a single change's trace"
    (changes tracked by .specs/changes/<change_id>/state.md)
  
  - "Required phases never skipped (Intent, Structure, Design always traversed)"
    except: "Design can skip directly to Validate, bypassing Execution"
  
  - "Only backward transition: Validate → Design"
    (single allowed backtrack, used for rework)
  
  - "Transition logged to change state before execution"
    format: "phase: <old> → <new>, timestamp, reason"
  
  - "Deadlock must be detected and reported before blocking"
    tools: "state-validator deadlock-check"
  
  - "validation results cached for idempotent re-runs"
    (calling validate(A, B) twice = same result)
```

---

## Integration Points

### altitude-plan.agent.md

Before advancing phase:

```bash
state-validator validate <current_phase> <next_phase>
  if $? -eq 0
    phase_gate_passed=true
  else
    log "BLOCKED: Invalid transition $current → $next"
    exit 1
fi
```

### altitude-execution.agent.md

On task completion, propose next phase:

```bash
current_phase=$(grep "^phase:" .specs/changes/<id>/state.md | cut -d: -f2)
if state-validator deadlock-check --trace .specs/changes/<id>/trace.md
  proceed_to_next_phase
else
  report "Deadlock detected; escalate to altitude-plan"
  exit 1
fi
```

### .specs/changes/<change-id>/state.md

Track state transitions:

```yaml
phase_history:
  - timestamp: 2026-06-29T10:00Z
    from: Intent
    to: Structure
    validation: passed
  - timestamp: 2026-06-29T11:00Z
    from: Structure
    to: Design
    validation: passed
```

---

## Error Handling

```yaml
errors:
  INVALID_TRANSITION:
    code: 1
    message: "Transition from {current} to {next} not allowed"
    action: "Check forbidden_transitions list; propose valid next state"
  
  DEADLOCK_DETECTED:
    code: 2
    message: "Circular wait detected in phase progression"
    action: "Report cycle path; escalate to altitude-plan"
  
  MISSING_PHASE:
    code: 3
    message: "Phase not recognized (typo or undefined)"
    action: "Check state_machine_contract.md; list valid states"
  
  SELF_LOOP_ATTEMPT:
    code: 4
    message: "Cannot transition from {state} to {state}"
    action: "Choose a different target state"
```

---

## Testing Strategy

See: `test/fixtures/harness-v3/wave-11-state-machine-smoke.fixture.md`

Test scenarios:
1. Valid path (Intent → Structure → Design → Execution → Validate → Ship)
2. Invalid transition blocked (Ship → Intent)
3. Deadlock detection with circular wait
4. Rework loop (Validate → Design → Execution → Validate → Ship)
5. Fast-track (Design → Validate, skipping Execution)
6. Idempotent validation (same input, multiple calls)

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-06-29 | v1.0 Initial FSM formalization | Wave 11 |

