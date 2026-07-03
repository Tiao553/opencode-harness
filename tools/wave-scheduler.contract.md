# Wave Scheduler Contract

**Version:** 1.0
**Tool:** `wave-scheduler.sh`
**Purpose:** Multi-wave scheduling, DAG computation, and batch orchestration
**Updated:** 2026-06-30

---

## 1. Overview

`wave-scheduler.sh` computes deterministic execution order for waves 7-17 based on the wave dependency DAG.

**Key features:**
- Topological sort (deterministic, stable)
- Parallel batch identification
- Wave status tracking
- DAG visualization (Graphviz)
- Integration with `.specs` state

---

## 2. Command Reference

### 2.1 schedule — Compute execution order

**Syntax:**
```bash
wave-scheduler.sh schedule [<waves-file>]
```

**Description:** Compute topological execution order for all waves.

**Arguments:**
- `<waves-file>` (optional) — Path to wave configuration YAML (default: `.specs/changes/waves-7-17-implementation/wave-structure.yaml`)

**Output:** Ordered list of waves in execution sequence

**Exit codes:**
- `0` — Success
- `1` — Circular dependency detected

**Example:**
```bash
$ wave-scheduler.sh schedule
# Wave Execution Schedule (Topological Order)
# Generated: 2026-06-30T15:23:45Z

batch_01: W7
batch_02: W8 W9 W10 W14
batch_03: W11
batch_04: W12 W13
batch_05: W16
batch_06: W15
batch_07: W17

# Full execution order:
 1. W7
 2. W8
 3. W9
 4. W10
 5. W11
 6. W12
 7. W13
 8. W14
 9. W15
10. W16
11. W17
```

**Guarantees:**
- Same input DAG → same output order (no randomness)
- Respects all dependencies (no wave runs before its dependencies)
- Identifies parallelizable batches

---

### 2.2 status — Show wave status

**Syntax:**
```bash
wave-scheduler.sh status [--wave <N>]
```

**Description:** Display status of one or all waves.

**Arguments:**
- `--wave <N>` (optional) — Show only wave N (e.g., `W7`, `W13`). If omitted, show all.

**Output:** Table with wave ID, title, and current status

**Statuses:**
- `queued` — Waiting for dependencies or execution slot
- `running` — Currently executing
- `completed` — Successfully completed
- `failed` — Execution failed
- `blocked` — Unrecoverable failure

**Example:**
```bash
$ wave-scheduler.sh status
# Wave Status Report
# Generated: 2026-06-30T15:23:45Z

W7   Ralph Loop              completed
W8   KB Quality              queued
W9   Security                queued
W10  Metrics                 queued
W11  State Machine           queued
W12  Recovery                queued
W13  Orchestration           queued
W14  Protocols               queued
W15  Meta-Validation         queued
W16  Hardening               queued
W17  Final Validation        queued

$ wave-scheduler.sh status --wave W7
# Wave Status Report
# Generated: 2026-06-30T15:23:45Z

W7   Ralph Loop              completed
```

**Status file locations:** `.specs/changes/waves-7-17-implementation/queue/status/W<N>.status`

---

### 2.3 execute — Execute one wave

**Syntax:**
```bash
wave-scheduler.sh execute --wave <N>
```

**Description:** Execute wave N (mark as running, then completed).

**Arguments:**
- `--wave <N>` (required) — Wave to execute (e.g., `W7`, `W13`)

**Behavior:**
1. Check that all dependencies are completed
2. Mark wave as `running`
3. Execute wave task (or signal to executor)
4. Mark as `completed` (if successful) or `failed` (if error)
5. Update status file

**Exit codes:**
- `0` — Wave executed successfully
- `1` — Dependency not met OR wave execution failed

**Example:**
```bash
$ wave-scheduler.sh execute --wave W7
Executing W7...
Status file: .specs/changes/waves-7-17-implementation/queue/status/W7.status
✅ W7 marked as completed

$ wave-scheduler.sh execute --wave W8
ERROR: Dependency W7 not completed (status: queued)
```

**Prerequisites:**
- All dependencies must be in `completed` status
- Status file must exist (created by `schedule` or `status` command)

---

### 2.4 graph — Visualize DAG

**Syntax:**
```bash
wave-scheduler.sh graph
```

**Description:** Output Graphviz (DOT) format representation of wave dependency DAG.

**Output:** DOT format code for directed graph

**Example:**
```bash
$ wave-scheduler.sh graph
# Wave Dependency DAG

digraph WaveDAG {
  rankdir=LR;
  node [shape=box, style=filled, fillcolor=lightblue];

  "W7" [label="W7\n(Ralph Loop)"];
  "W8" [label="W8\n(KB Quality)"];
  ...

  "W7" -> "W8";
  "W7" -> "W9";
  ...
}
```

**Rendering:**
```bash
wave-scheduler.sh graph > wave-dag.dot
dot -Tsvg wave-dag.dot -o wave-dag.svg
```

**Formats supported:** SVG, PNG, PDF (via Graphviz)

---

## 3. Wave Dependency Model

**Waves:** W7 through W17 (11 waves)

**Dependency graph:**

```
W7 (no deps)
├── → W8
├── → W9
├── → W10
├── → W14
└── → W11
      ├── → W12
      ├── → W13
      └── → W16 (also depends on W12, W13)

All W7-W14 → W15
W15, W16 → W17
```

**Critical path:** W7 → W11 → W12 → W16 → W15 → W17

**Parallelizable batches:**
- W8, W9, W10, W14 (all depend only on W7, can run together after W7)
- W12, W13 (both depend only on W11, can run together after W11)

---

## 4. Status File Format

Status files are YAML, stored at `.specs/changes/waves-7-17-implementation/queue/status/W<N>.status`.

**Schema:**
```yaml
wave: W<N>                                    # Wave ID
status: queued | running | completed | failed | blocked
started_at: ISO8601 | null                    # When execution started
completed_at: ISO8601 | null                  # When execution finished
error_message: string | null                  # Error reason (if failed)
evidence_path: string | null                  # Path to evidence artifact
ledger_entry: string | null                   # Link to execution ledger
```

**Example:**
```yaml
wave: W7
status: completed
started_at: 2026-06-30T15:00:00Z
completed_at: 2026-06-30T15:24:00Z
error_message: null
evidence_path: .specs/changes/waves-7-17-implementation/evidence/W7-evidence.md
ledger_entry: .specs/changes/waves-7-17-implementation/03-execution-ledger.md#W7
```

---

## 5. Integration with Orchestration Contract

**Scheduling model:** Defined in `.specs/shared/orchestration-contract.md`

**This tool implements:**
- Topological sort (deterministic scheduling)
- Batch identification (parallelizable waves)
- Status tracking (wave lifecycle)

**This tool does NOT:**
- Execute tasks (that's the responsibility of wave executor / altitude-coordinator)
- Manage recovery (that's recovery-manager.sh)
- Validate state machine (that's state-validator.sh)

---

## 6. Exit Codes

| Code | Meaning | Example |
|------|---------|---------|
| 0    | Success | Wave scheduled or status retrieved |
| 1    | Error   | Circular dependency or wave not found |

---

## 7. Error Handling

**Circular dependency:** Detected by topological sort, returns error message and exits with code 1

**Wave not found:** Returned if wave ID is invalid (e.g., `W20`)

**Dependency not met:** If trying to execute wave before dependencies are completed, returns error and exits with code 1

**Missing status file:** Treated as `queued` status

---

## 8. Examples

### Example 1: Full scheduling workflow

```bash
# Compute execution order
$ wave-scheduler.sh schedule
# Output: Topological order of all waves

# Check status
$ wave-scheduler.sh status
# Output: Status of all waves

# Execute first wave
$ wave-scheduler.sh execute --wave W7

# Check status again
$ wave-scheduler.sh status --wave W7
# Output: W7 is now completed

# Execute parallel batch
$ wave-scheduler.sh execute --wave W8 &
$ wave-scheduler.sh execute --wave W9 &
$ wave-scheduler.sh execute --wave W10 &
wait
```

### Example 2: Dependency validation

```bash
# Try to execute W12 before W11 is done
$ wave-scheduler.sh status --wave W12
# Output: W12 status is queued

$ wave-scheduler.sh execute --wave W12
# Output: ERROR: Dependency W11 not completed (status: queued)

# Execute W11 first
$ wave-scheduler.sh execute --wave W11

# Now W12 can execute
$ wave-scheduler.sh execute --wave W12
# Output: ✅ W12 marked as completed
```

### Example 3: DAG visualization

```bash
# Generate Graphviz representation
$ wave-scheduler.sh graph > wave-dag.dot

# Render as SVG
$ dot -Tsvg wave-dag.dot -o wave-dag.svg

# View
$ open wave-dag.svg  # or: xdg-open wave-dag.svg
```

---

## 9. Performance

- **schedule:** O(N + E) where N = number of waves (11), E = edges (~15)
- **status:** O(N) — reads N status files
- **execute:** O(N) — checks N dependencies
- **graph:** O(N + E) — outputs all nodes and edges

**Typical runtime:** < 100ms for all commands

---

## 10. Determinism Guarantee

**Claim:** `wave-scheduler.sh schedule` is deterministic.

**Proof:** Topological sort with stable tie-breaking (wave ID order):
```
For all waves with same dependency depth:
  Sort by wave ID (W7 < W8 < ... < W17)
  Add to queue in order
```

**Verification:**
```bash
$ wave-scheduler.sh schedule > order1.txt
$ wave-scheduler.sh schedule > order2.txt
$ diff order1.txt order2.txt
# No output = identical order (deterministic)
```

---

## References

- `.specs/shared/orchestration-contract.md` — Orchestration model
- `.specs/shared/recovery-contract.md` — Error recovery
- `agents/altitude-coordinator.agent.md` — Orchestration agent
- Wave 13 task (W13-ORCHESTRATION.md) — Task specification
