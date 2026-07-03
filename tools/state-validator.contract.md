# state-validator Tool Contract

**Version:** 1.0
**Status:** Active (Wave 11)
**Location:** `tools/state-validator.sh`

---

## Overview

`state-validator` is a Bash script that validates Harness V3 phase transitions and detects deadlocks in state machine traces.

**Usage:**
```bash
state-validator <command> [options]
```

**Return Codes:**
- `0` — Success (valid transition or no deadlock detected)
- `1` — Invalid transition or validation failed
- `2` — Deadlock detected in trace
- `3` — Unknown state (typo or undefined)
- `4` — Self-loop attempt (state → state)

---

## Commands

### 1. `validate <current-state> <next-state>`

Validates whether a state transition is allowed by the FSM.

**Usage:**
```bash
state-validator validate <current-state> <next-state>
```

**Arguments:**
- `current-state` — Current phase (Intent, Structure, Design, Execution, Validate, Ship)
- `next-state` — Proposed next phase

**Return Codes:**
- `0` — Transition is valid
- `1` — Transition is invalid (forbidden)
- `3` — Unknown state(s)
- `4` — Self-loop attempt

**Examples:**

```bash
# Valid transitions
$ state-validator validate Intent Structure
$ echo $?
0

$ state-validator validate Design Execution
$ echo $?
0

$ state-validator validate Validate Design
$ echo $?
0

# Invalid transitions
$ state-validator validate Ship Intent
[ERROR] Invalid transition: Ship → Intent
$ echo $?
1

$ state-validator validate Intent Execution
[ERROR] Invalid transition: Intent → Execution
$ echo $?
1

# Self-loop
$ state-validator validate Design Design
[ERROR] Self-loop not allowed: Design → Design
$ echo $?
4

# Unknown state
$ state-validator validate Intent Unknown
[ERROR] Unknown state: Unknown
$ echo $?
3
```

**Error Messages:**
```
[ERROR] Unknown state: <state>
[ERROR] Self-loop not allowed: <state> → <state>
[ERROR] Invalid transition: <current> → <next>
```

---

### 2. `deadlock-check [--trace <file>]`

Detects circular wait conditions in phase progression traces.

**Usage:**
```bash
state-validator deadlock-check [--trace <file>]
```

**Arguments:**
- `--trace <file>` — Trace file to analyze (optional)
  - If not provided, reads from stdin
  - If neither provided, returns success (no-op)

**Trace File Format:**
```
# Comments start with #
state <state_name> waiting_for <event_or_state>
state <state_name> waiting_for <event_or_state>
...
```

**Example Trace File:**
```
# Phase progression trace for change wave-11-trace
state Execution waiting_for validate_approval
state Validate waiting_for test_results
state TestRunner waiting_for Execution
```

**Return Codes:**
- `0` — No deadlock detected (or no trace provided)
- `2` — Deadlock detected (circular dependency)

**Examples:**

```bash
# No deadlock
$ echo "state Intent waiting_for user_approval" | \
  state-validator deadlock-check
[INFO] Deadlock check passed; no cycles detected
$ echo $?
0

# Deadlock detected
$ cat > /tmp/circular-trace.txt << 'EOF'
state Execution waiting_for Validate
state Validate waiting_for TestResults
state TestResults waiting_for Execution
EOF

$ state-validator deadlock-check --trace /tmp/circular-trace.txt
[ERROR] Deadlock detected in cycle: Execution → Validate → TestResults → Execution
$ echo $?
2

# Using stdin
$ cat /tmp/circular-trace.txt | state-validator deadlock-check
[ERROR] Deadlock detected in cycle: Execution → Validate → TestResults → Execution
$ echo $?
2
```

**Error Messages:**
```
[ERROR] Trace file not found: <path>
[ERROR] Deadlock detected in cycle: <state> → <state> → ... → <state>
```

---

### 3. `dump-graph`

Prints the complete state machine graph and transition rules.

**Usage:**
```bash
state-validator dump-graph
```

**Output:**
- State definitions (Intent, Structure, Design, Execution, Validate, Ship)
- Directed edges (allowed transitions)
- ASCII diagram showing FSM structure
- List of forbidden transitions
- Deadlock rules and invariants

**Return Code:**
- `0` — Always succeeds

**Example:**
```bash
$ state-validator dump-graph

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
```

---

## Integration Examples

### altitude-plan.agent.md

```bash
# Before advancing to next phase
if state-validator validate "$current_phase" "$next_phase"; then
  log "Phase transition $current_phase → $next_phase approved"
else
  log_error "Invalid phase transition"
  exit 1
fi
```

### Phase Gate in State Transition Code

```bash
validate_phase_gate() {
  local change_id="$1"
  local next_phase="$2"

  # Get current phase from state
  local current_phase=$(grep "^phase:" .specs/changes/"$change_id"/state.md | cut -d: -f2 | tr -d ' ')

  # Validate transition
  if ! state-validator validate "$current_phase" "$next_phase"; then
    echo "ERROR: Cannot transition from $current_phase to $next_phase" >&2
    return 1
  fi

  # Log transition
  echo "$(date -u +%Y-%m-%dT%H:%MZ) Transition $current_phase → $next_phase APPROVED" >> \
    .specs/changes/"$change_id"/state.md

  return 0
}
```

### Deadlock Detection in Trace

```bash
check_for_deadlocks() {
  local change_id="$1"
  local trace_file=".specs/changes/$change_id/trace.md"

  if [[ -f "$trace_file" ]]; then
    if ! state-validator deadlock-check --trace "$trace_file"; then
      echo "ERROR: Deadlock detected in $change_id" >&2
      return 2
    fi
  fi

  return 0
}
```

---

## Related Files

- **State Machine Definition:** `.specs/shared/state-machine-contract.md`
- **FSM Implementation:** `.specs/shared/state-machine-contract.md` (states, transitions, rules)
- **Integration Point:** `agents/altitude-plan.agent.md` (calls state-validator at phase gates)

---

## Testing

See: `test/fixtures/harness-v3/wave-11-state-machine-smoke.fixture.md`

**Test Coverage:**
1. Valid transitions return 0
2. Invalid transitions return 1
3. Self-loops return 4
4. Unknown states return 3
5. Deadlock detection returns 2
6. Idempotent validation (same input → same result)

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-06-29 | v1.0 Initial release | Wave 11 |
