# verify_step Tool Contract & Command Reference

**Tool:** `tools/verify-step.sh`  
**Version:** 1.0  
**Status:** Authoritative  
**Date:** 2026-06-29  

---

## Overview

`verify_step` is the Harness V3 deterministic execution tracing tool.

It records decision traces, supports replay validation, captures fork paths, and enables audit trails for all execution decisions.

---

## Command: `verify_step start`

### Signature

```bash
verify_step start --session-id <id> --step "<description>" [--tags "<tag1>,<tag2>"]
```

### Purpose

Begin tracing a decision point. Creates a new trace entry and returns its decision ID.

### Parameters

| Parameter | Type | Required | Example |
| --- | --- | --- | --- |
| `--session-id` | string | ✅ | `sess-2026-06-29T14:30:45Z-altitude-execution-abc` |
| `--step` | string | ✅ | `"Load PRD from file"` |
| `--tags` | string | ⭕ | `"phase-transition,critical"` |

### Output

**Success:** Prints decision_id to stdout  
**Error:** Prints error message to stderr, exits with code 1

### Example

```bash
$ verify_step start \
    --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc \
    --step "Validate PRD structure"
dec-sess-2026-06-29T14:30:45Z-altitude-execution-abc-001
```

### Behavior

1. If session doesn't exist: creates new session file
2. If session exists: increments decision counter
3. Records start timestamp
4. Returns decision_id for this step
5. Stores temporary state in `/tmp/verify_step_$$`

### Error Cases

| Error | Cause | Resolution |
| --- | --- | --- |
| `ERROR: --session-id and --step are required` | Missing required parameters | Provide both --session-id and --step |
| `ERROR: Cannot create traces directory` | Permission denied | Check directory permissions |
| `ERROR: Session file is corrupt` | Trace file is invalid YAML | Delete trace file and restart |

---

## Command: `verify_step check`

### Signature

```bash
verify_step check --session-id <id> --verdict PASS|FAIL|BLOCKED [--fork-decision "<path>"]
```

### Purpose

Record the outcome of a decision step that was started with `verify_step start`.

### Parameters

| Parameter | Type | Required | Values |
| --- | --- | --- | --- |
| `--session-id` | string | ✅ | Session ID from previous `start` command |
| `--verdict` | enum | ✅ | `PASS` \| `FAIL` \| `BLOCKED` |
| `--fork-decision` | string | ⭕ | `"path_a"` or `"path_b"` if fork taken |

### Output

**Success:** Prints summary to stdout (optional), exits with code 0  
**Error:** Prints error message to stderr, exits with code 1

### Example

```bash
# Simple success
$ verify_step check \
    --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc \
    --verdict PASS

# With fork decision
$ verify_step check \
    --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc \
    --verdict PASS \
    --fork-decision "proceed_to_design"
```

### Behavior

1. Loads temporary state from `verify_step start` command
2. Records end timestamp
3. Computes deterministic checksum of the decision
4. Appends decision entry to session ledger
5. Updates total_steps counter
6. Saves session YAML to trace file
7. Cleans up temporary files

### Error Cases

| Error | Cause | Resolution |
| --- | --- | --- |
| `ERROR: --session-id and --verdict are required` | Missing parameters | Provide both parameters |
| `ERROR: --verdict must be PASS, FAIL, or BLOCKED` | Invalid verdict value | Use only valid verdict values |
| `ERROR: No active step for session (did you call start?)` | start was not called first | Call `verify_step start` before `check` |
| `ERROR: Session file corrupted` | Trace file is invalid | Delete and recreate session |

### Idempotency

**Not idempotent by design.** Each `check` call appends a new decision to the ledger.

To safely re-run, create a new session ID or load the same session and use `replay` to validate.

---

## Command: `verify_step ledger`

### Signature

```bash
verify_step ledger --session-id <id> [--format yaml|json|markdown]
```

### Purpose

Extract and display the complete execution trace for a session.

### Parameters

| Parameter | Type | Required | Default |
| --- | --- | --- | --- |
| `--session-id` | string | ✅ | — |
| `--format` | enum | ⭕ | `yaml` |

### Output

**Success:** Ledger in requested format to stdout, exits with code 0  
**Error:** Error message to stderr, exits with code 1

### Example

```bash
# YAML format
$ verify_step ledger \
    --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc \
    --format yaml

# Markdown format
$ verify_step ledger \
    --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc \
    --format markdown

# JSON format
$ verify_step ledger \
    --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc \
    --format json
```

### Output Examples

**YAML:**
```yaml
trace_session:
  session_id: sess-2026-06-29T14:30:45Z-altitude-execution-abc
  created_at: 2026-06-29T14:30:45Z
  status: active
  total_steps: 3
  decisions:
    - decision_id: dec-sess-...-001
      verdict: PASS
      timestamp_start: 2026-06-29T14:30:45Z
```

**Markdown:**
```markdown
# Execution Ledger

## Session: sess-2026-06-29T14:30:45Z-altitude-execution-abc

\`\`\`yaml
trace_session:
  ...
\`\`\`
```

### Formats

| Format | Description | Use Case |
| --- | --- | --- |
| `yaml` | YAML key-value structure | Machine parsing, storage |
| `json` | JSON object structure | API integration |
| `markdown` | Markdown code block | Documentation, human review |

### Error Cases

| Error | Cause | Resolution |
| --- | --- | --- |
| `ERROR: Session <id> not found` | No trace file exists | Verify session ID, check traces directory |
| `ERROR: Unknown format` | Invalid format value | Use yaml, json, or markdown |

---

## Command: `verify_step replay`

### Signature

```bash
verify_step replay --session-id <id> [--verbose]
```

### Purpose

Deterministically replay a trace to validate that decisions can be replayed without divergence.

### Parameters

| Parameter | Type | Required | Default |
| --- | --- | --- | --- |
| `--session-id` | string | ✅ | — |
| `--verbose` | flag | ⭕ | false |

### Output

**Success:**
```
REPLAY_OK: All decisions replayed successfully
```
Exit code: 0

**Divergence:**
```
REPLAY_DIVERGENCE: One or more decisions failed validation
```
Exit code: 1

**Error:**
```
ERROR: Session <id> not found
```
Exit code: 1

### Example

```bash
$ verify_step replay \
    --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc
REPLAY_OK: All decisions replayed successfully

# With verbose output
$ verify_step replay \
    --session-id sess-2026-06-29T14:30:45Z-altitude-execution-abc \
    --verbose
Replaying session: sess-...
Total decisions: 3
  ✓ dec-sess-...-001: PASS (checksum: a3f4b8e1...)
  ✓ dec-sess-...-002: PASS (checksum: c5d2e7f9...)
  ✓ dec-sess-...-003: PASS (checksum: 7b1a3e9c...)
REPLAY_OK: All decisions replayed successfully
```

### Behavior

1. Loads trace file for session
2. Extracts all decisions from ledger
3. For each decision:
   - Validates deterministic_checksum is present
   - Verifies checksum matches original computation
   - Checks verdict is valid (PASS/FAIL/BLOCKED)
4. If all checks pass: prints `REPLAY_OK`, exits 0
5. If any check fails: prints `REPLAY_DIVERGENCE`, exits 1

### Replay Validation Checks

| Check | Validating | On Failure |
| --- | --- | --- |
| Checksum present | Trace was complete | REPLAY_DIVERGENCE |
| Checksum matches | Decision was not modified | REPLAY_DIVERGENCE |
| Verdict valid | Decision outcome is reasonable | REPLAY_DIVERGENCE |
| Decision count | Session is complete | REPLAY_DIVERGENCE |

### Use Cases

1. **Audit trail validation:** Verify trace before shipping
2. **Incident investigation:** Check if decision path was followed
3. **Regression detection:** Validate trace hasn't been corrupted
4. **Fork path validation:** Ensure correct branch was taken

---

## Integration Examples

### Example 1: Happy Path (3-Step Trace)

```bash
#!/bin/bash

SESSION_ID="sess-$(date -u +%Y-%m-%dT%H:%M:%SZ)-altitude-execution-example"

# Step 1: Load requirements
verify_step start --session-id "$SESSION_ID" --step "Load requirements from PRD.md"
verify_step check --session-id "$SESSION_ID" --verdict PASS

# Step 2: Validate structure
verify_step start --session-id "$SESSION_ID" --step "Validate PRD structure"
verify_step check --session-id "$SESSION_ID" --verdict PASS

# Step 3: Create task pack
verify_step start --session-id "$SESSION_ID" --step "Create task pack from requirements"
verify_step check --session-id "$SESSION_ID" --verdict PASS

# View ledger
verify_step ledger --session-id "$SESSION_ID" --format yaml

# Validate replay
verify_step replay --session-id "$SESSION_ID" --verbose
```

### Example 2: Fork Path (Decision with Multiple Options)

```bash
#!/bin/bash

SESSION_ID="sess-$(date -u +%Y-%m-%dT%H:%M:%SZ)-altitude-execution-fork"

# Phase 1: Assess requirements
verify_step start --session-id "$SESSION_ID" --step "Assess PRD completeness"
verify_step check --session-id "$SESSION_ID" --verdict PASS

# Fork point: Validation check
verify_step start --session-id "$SESSION_ID" --step "Check validation status"
# User chose: "Proceed to Design" (path_a)
verify_step check --session-id "$SESSION_ID" --verdict PASS --fork-decision "path_a"

# Continue on chosen path
verify_step start --session-id "$SESSION_ID" --step "Create design document"
verify_step check --session-id "$SESSION_ID" --verdict PASS

# Dump and validate
verify_step ledger --session-id "$SESSION_ID" --format markdown
verify_step replay --session-id "$SESSION_ID"
```

### Example 3: Error Path (FAIL Verdict)

```bash
#!/bin/bash

SESSION_ID="sess-$(date -u +%Y-%m-%dT%H:%M:%SZ)-altitude-execution-error"

# Attempt task
verify_step start --session-id "$SESSION_ID" --step "Validate PRD against schema"
verify_step check --session-id "$SESSION_ID" --verdict FAIL

# Trace shows FAIL; altitude-execution can decide to retry or escalate
verify_step ledger --session-id "$SESSION_ID" | grep -q "FAIL"
if [ $? -eq 0 ]; then
    echo "PRD validation failed; escalating to Phase 1 clarification"
fi
```

---

## Error Handling & Safety

### Atomicity

Each `verify_step` command is atomic:
- All-or-nothing writes to trace file
- If write fails, previous state is preserved
- Safe to retry (check idempotency rules above)

### File Permissions

- Traces directory: created if missing, readable/writable by current user
- Trace files: created with default umask (typically 644)
- Temporary files: stored in `/tmp/verify_step_$$` (PID-scoped)

### Bash Compatibility

- Tested on Bash 3.2+ (macOS compatible)
- Uses only standard Bash builtins
- No dependency on external tools (grep, awk used minimally)

### Edge Cases

| Case | Behavior |
| --- | --- |
| Session doesn't exist | `start` creates it, other commands fail |
| Multiple `start` calls without `check` | Last `start` overwrites temp state |
| `check` without prior `start` | Error: "No active step" |
| Traces directory is full | Standard disk-full error from shell |
| Trace file is corrupted | Load/replay fails; manual repair needed |

---

## Reference

**Related Files:**
- `.specs/shared/verification-contract.md` — Complete trace schema specification
- `.specs/changes/waves-7-17-implementation/03-execution-ledger.md` — Live execution traces
- `agents/altitude-execution.agent.md` — How altitude-execution integrates verify_step
- `test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md` — Example usage

---

**Tool Version:** 1.0  
**Last Updated:** 2026-06-29  
**Maintained By:** Harness V3 Execution Team
