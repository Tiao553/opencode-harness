# Verification & Decision Tracing Contract

**Version:** 1.0
**Status:** Authoritative
**Date:** 2026-06-29

---

## Contract Specification

```yaml
trace_schema:
  decision_id: string
  session_id: string
  verdict: enum[PASS, FAIL, BLOCKED]
  timestamp_start: ISO-8601
  timestamp_end: ISO-8601
  deterministic_checksum: SHA-256
  fork_markers: array[fork_entry]

replay_semantics:
  - idempotent: true
  - path_preserving: true
  - state_validating: true
  - checksum_verifying: true

ledger_storage:
  primary: ".specs/changes/<change-id>/03-execution-ledger.md"
  per_session: ".specs/changes/<change-id>/traces/<session-id>.yaml"
  archive: ".specs/changes/<change-id>/traces/archive/<date>-<session-id>.yaml"
```

---

## Purpose

This contract defines deterministic execution tracing (Ralph Loop) for the Harness V3 execution engine.

It specifies:
- **trace_schema:** Structure of decision traces
- **trace_identity:** How sessions and decisions are identified
- **replay_semantics:** Deterministic replay requirements
- **ledger_storage:** How traces are persisted
- **api_surface:** Command interface for verify_step tool

---

## 1. Trace Schema

### Core Trace Entry

Each traced decision produces one entry in the session ledger:

```yaml
decision_entry:
  decision_id: "dec-<session-id>-<seq-num>"      # Unique identifier
  session_id: "sess-<timestamp>-<user>-<hash>"   # Session identifier
  step_number: <integer>                          # Sequence in this session
  step_description: "<human-readable>"            # What was being decided
  timestamp_start: "<ISO-8601>"                   # When decision started
  timestamp_end: "<ISO-8601>"                     # When decision ended
  path_taken: "<string>"                          # Which path was chosen (A/B/C)
  verdict: "PASS" | "FAIL" | "BLOCKED"            # Decision outcome
  inputs:                                         # What was decided about
    context_key_1: "<value>"
    context_key_2: "<value>"
  outputs:                                        # What changed
    result_key_1: "<value>"
    result_key_2: "<value>"
  fork_markers:                                   # If multiple paths existed
    - fork_id: "fork-<session-id>-<seq>"
      branch_name: "<path A | path B>"
      path_taken: true | false
  deterministic_checksum: "<SHA-256>"             # For replay validation
  metadata:
    agent: "<agent-name>"                         # Which agent made decision
    phase: "<phase-name>"                         # Which phase (Intent/Structure/Design/Execution/Validate/Ship)
    change_id: "<change-id>"                      # Associated change
    task_id: "<task-id>"                          # Associated task
    tags:
      - "<tag1>"                                  # User-defined tags
      - "<tag2>"
```

### Full Session Ledger

```yaml
trace_session:
  metadata:
    session_id: "sess-<timestamp>-<user>-<hash>"
    created_at: "<ISO-8601>"
    closed_at: "<ISO-8601>" | null
    created_by: "<agent-name>"
    status: "active" | "closed" | "replayed"
    total_steps: <integer>
    total_forks: <integer>

  decisions:
    - decision_entry: {...}
    - decision_entry: {...}

  execution_path:
    "step_1_description" -> "step_2_description" -> "step_3_description"

  fork_graph:
    forks:
      - fork_id: "fork-<session>-1"
        at_step: 1
        branches:
          - name: "path_a"
            taken: true
            ledger_segment: "decisions[0:3]"
          - name: "path_b"
            taken: false
            ledger_segment: "decisions[0:3]"

  integrity:
    ledger_checksum: "<SHA-256 of full ledger>"
    prior_session_checksum: "<SHA-256 of previous session>"
    validation_status: "valid" | "corrupt"
```

---

## 2. Trace Identity

### Session ID Generation

Session IDs must be deterministic by purpose, not random:

```
sess-<timestamp>-<source>-<purpose-hash>

  timestamp      = ISO-8601 second precision (e.g., 2026-06-29T14:30:45Z)
  source         = calling agent (e.g., altitude-execution, altitude-validation)
  purpose-hash   = SHA256(session_purpose)[0:8]
                   (e.g., "phase-transition-from-intent-to-structure" -> "a3f4b8e1")
```

**Example:**
```
sess-2026-06-29T14:30:45Z-altitude-execution-a3f4b8e1
```

### Decision ID Generation

Decision IDs must be unique within session:

```
dec-<session-id>-<seq>

  session-id  = from session
  seq         = monotonic counter within session (001, 002, ...)
```

**Example:**
```
dec-sess-2026-06-29T14:30:45Z-altitude-execution-a3f4b8e1-001
```

### Deterministic Checksum

For each decision, compute:

```
deterministic_checksum = SHA-256(
  decision_id +
  step_description +
  verdict +
  inputs_yaml_sorted +
  outputs_yaml_sorted +
  timestamp_start
)
```

This ensures replay detection of state changes.

---

## 3. Replay Semantics

### Deterministic Replay Contract

Replay must satisfy:

1. **Idempotent:** Replaying the same trace produces identical outputs (no side effects)
2. **Path-preserving:** Each replay follows the exact same decision path (no branching)
3. **State-validating:** Replay validates that prior state matches expected state
4. **Checksum-verifying:** Each replayed decision's checksum must match the original

### Replay Algorithm

```
replay(session_id):
  1. Load trace ledger for session_id
  2. Validate ledger integrity:
     - Check ledger_checksum == computed checksum
     - Verify prior_session_checksum chain (if exists)
  3. Validate determinism markers:
     - For each decision:
       a. Assert verdict matches traced verdict (PASS/FAIL/BLOCKED)
       b. Assert inputs match traced inputs
       c. Assert path matches traced path (no forks taken differently)
       d. Assert deterministic_checksum matches
  4. Execute decisions in sequence:
     - Skip actual side effects (read-only mode)
     - Record observed outputs for validation
  5. Compare observed vs. expected:
     - If mismatch: return REPLAY_DIVERGENCE error
     - If match: return REPLAY_OK
```

### Replay Failure Cases

| Case | Behavior |
| ---- | -------- |
| Ledger checksum mismatch | REPLAY_CORRUPT — trace was modified |
| Decision checksum mismatch | REPLAY_DIVERGENCE — decision diverged |
| Input state mismatch | REPLAY_STALE — input state changed |
| Fork taken differently | REPLAY_PATH_CHANGED — different branch chosen |
| Missing prior session | REPLAY_INCOMPLETE — cannot validate chain |

---

## 4. Fork Markers & Decision Branches

### Fork Marker Schema

When a decision point has multiple valid paths:

```yaml
fork_marker:
  fork_id: "fork-<session>-<seq>"
  at_step: <step_number>
  branches:
    - name: "path_a"
      description: "Option A — trade-off 1"
      taken: true | false
      ledger_segment: "decisions[start:end]"
      outputs:
        key: value
    - name: "path_b"
      description: "Option B — trade-off 2"
      taken: true | false
      ledger_segment: "decisions[start:end]"
      outputs:
        key: value
```

### Example: Phase Transition Fork

```yaml
decisions:
  - decision_id: "dec-...-001"
    step_description: "phase-transition-intent-to-structure"
    verdict: "PASS"
    fork_markers:
      - fork_id: "fork-...-001"
        branches:
          - name: "fast_path"
            description: "Proceed directly to Structure phase"
            taken: true
          - name: "loop_back"
            description: "Return to Intent for clarification"
            taken: false
```

---

## 5. Ledger Storage

### Location

Traces are stored in:

```
.specs/changes/<change-id>/03-execution-ledger.md
```

With optional per-session trace files:

```
.specs/changes/<change-id>/traces/<session-id>.yaml
```

### File Format

Primary ledger is Markdown with embedded YAML code blocks:

```markdown
# Execution Ledger

## Session: sess-2026-06-29T14:30:45Z-altitude-execution-a3f4b8e1

Status: closed
Total decisions: 3
Total forks: 1

### Decision 1: Load requirements

**Timestamp:** 2026-06-29T14:30:45Z → 2026-06-29T14:30:47Z
**Verdict:** PASS

\`\`\`yaml
decision_id: dec-sess-...-001
verdict: PASS
inputs:
  file: PRD.md
outputs:
  status: loaded
deterministic_checksum: abc123...
\`\`\`

### Fork: Phase transition

\`\`\`yaml
fork_id: fork-sess-...-001
at_step: 2
branches:
  - name: "proceed_to_structure"
    taken: true
  - name: "loop_back"
    taken: false
\`\`\`
```

### Rotation Policy

When ledger exceeds 1000 lines:

1. Move closed sessions to `.specs/changes/<change-id>/traces/archive/<date>-<session-id>.yaml`
2. Keep only active + recent (last 7 days) sessions in main ledger
3. Update ledger index: `.specs/changes/<change-id>/traces/index.yaml`

---

## 6. API Surface

### Command Interface

The `verify_step` tool implements 4 primary commands:

#### Command 1: start

```bash
verify_step start --session-id <id> --step "<step-description>" [--tags "<tag1>,<tag2>"]
```

**Purpose:** Begin tracing a decision step
**Exit Code:** 0 = success, 1 = error
**Output:** decision_id (stdout)

**Example:**
```bash
$ verify_step start --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc --step "Load PRD file"
dec-sess-2026-06-29T14:30:45Z-altitude-execution-abc-001
```

#### Command 2: check

```bash
verify_step check --session-id <id> --verdict PASS|FAIL|BLOCKED [--fork-decision "<path>"]
```

**Purpose:** Record decision outcome
**Exit Code:** 0 = success, 1 = error
**Output:** (none or summary)

**Example:**
```bash
$ verify_step check --session-id sess-... --verdict PASS
```

#### Command 3: replay

```bash
verify_step replay --session-id <id> [--verbose]
```

**Purpose:** Deterministically replay and validate a session
**Exit Code:** 0 = replay OK, 1 = replay divergence, 2 = corrupt ledger
**Output:** Replay status (JSON or plain text)

**Example:**
```bash
$ verify_step replay --session-id sess-... --verbose
REPLAY_OK: All decisions replayed successfully
```

#### Command 4: ledger

```bash
verify_step ledger --session-id <id> [--format yaml|json|markdown]
```

**Purpose:** Dump session ledger
**Exit Code:** 0 = success, 1 = not found
**Output:** Ledger in requested format (stdout)

**Example:**
```bash
$ verify_step ledger --session-id sess-... --format yaml
session_id: sess-...
decisions:
  - decision_id: dec-...
    verdict: PASS
```

---

## 7. Examples

### Example 1: Happy Path (3 steps, no forks)

```yaml
trace_session:
  session_id: "sess-2026-06-29T14:30:45Z-altitude-execution-happy"
  status: "closed"
  total_steps: 3
  total_forks: 0

  decisions:
    - decision_id: "dec-sess-...-001"
      step_description: "Load PRD from .specs/changes/wave-4/PRD.md"
      verdict: "PASS"
      timestamp_start: "2026-06-29T14:30:45Z"
      timestamp_end: "2026-06-29T14:30:47Z"
      outputs:
        prd_lines: 127
        prd_status: "valid"

    - decision_id: "dec-sess-...-002"
      step_description: "Validate PRD structure"
      verdict: "PASS"
      timestamp_start: "2026-06-29T14:30:47Z"
      timestamp_end: "2026-06-29T14:30:49Z"
      outputs:
        validation_status: "passed"

    - decision_id: "dec-sess-...-003"
      step_description: "Create task pack"
      verdict: "PASS"
      timestamp_start: "2026-06-29T14:30:49Z"
      timestamp_end: "2026-06-29T14:30:52Z"
      outputs:
        tasks_created: 5
```

### Example 2: Fork Path (3 steps, 1 fork at step 2)

```yaml
trace_session:
  session_id: "sess-2026-06-29T14:30:45Z-altitude-execution-fork"
  status: "closed"
  total_steps: 3
  total_forks: 1

  decisions:
    - decision_id: "dec-sess-...-001"
      step_description: "Load requirements"
      verdict: "PASS"

    - decision_id: "dec-sess-...-002"
      step_description: "Check validation status"
      verdict: "PASS"
      fork_markers:
        - fork_id: "fork-sess-...-001"
          at_step: 2
          branches:
            - name: "proceed_to_design"
              description: "Validation passed, proceed"
              taken: true
            - name: "loop_back_to_intent"
              description: "Validation failed, retry"
              taken: false

    - decision_id: "dec-sess-...-003"
      step_description: "Create design document"
      verdict: "PASS"
```

---

## 8. Integration Points

### Where verify_step is Called

1. **Phase transitions** (Intent → Structure → Design → Execution → Validate → Ship)
2. **Critical decision gates** (allocation, budget, scope expansion)
3. **Fork points** (multiple options presented to user)
4. **Validation checkpoints** (before shipping)

### Calling Pattern

```bash
# At start of decision point
decision_id=$(verify_step start --session-id $SESSION_ID --step "My decision point")

# Do work, make decision
# ...

# Record outcome
verify_step check --session-id $SESSION_ID --verdict PASS
```

### Error Handling

If `verify_step` fails:
- Log error to ledger: `trace_error` event
- Continue execution (trace errors are warnings, not fatal)
- Document reason in evidence

---

## 9. Validation Rules

1. **Idempotency:** Running verify_step twice with same inputs must be safe (no duplicate entries)
2. **Atomicity:** Each verify_step command must be atomic (all-or-nothing write to ledger)
3. **Ordering:** Decisions must be recorded in chronological order
4. **Integrity:** Ledger checksums must validate the entire chain
5. **Determinism:** Checksums must match the exact sequence and values

---

## 10. Reference

**Related files:**
- `.specs/shared/local-allocation-contract.md` — How allocation integrates with verify_step
- `agents/altitude-execution.agent.md` — How altitude-execution calls verify_step
- `tools/verify-step.contract.md` — Command reference and examples
- `.specs/changes/waves-7-17-implementation/03-execution-ledger.md` — Live execution traces

---

**Contract Version:** 1.0
**Last Updated:** 2026-06-29
**Maintained By:** Harness V3 Execution Team
