# Orchestration Contract

**Version:** 1.0
**Wave:** W13 — Multi-Wave Orchestration
**Updated:** 2026-06-30
**Status:** FORMALIZED

---

## 1. Purpose

This contract formalizes multi-wave scheduling, dependency management, and batch execution for waves 7-17.

It defines:
- **Wave DAG model** — Waves as nodes, dependencies as edges
- **Scheduling rules** — Topological sort, critical path, parallel execution
- **Execution semantics** — Sequential vs. parallel batch execution
- **State tracking** — Wave lifecycle (queued, running, completed, failed)
- **FSM integration** — Orchestration respects state-machine-contract.md gates

---

## 2. Wave DAG Model

### 2.0 Wave DAG Structure (YAML Schema)

```yaml
wave_dag:
  version: "1.0"
  change_id: waves-7-17-implementation
  created_at: 2026-06-30T00:00:00Z

  nodes:
    - wave_id: W7
      title: Ralph Loop
      dependencies: []
      critical_path: true

    - wave_id: W8
      title: KB Quality
      dependencies: [W7]
      critical_path: false

    - wave_id: W11
      title: State Machine
      dependencies: [W7]
      critical_path: true

    # ... (full list of W7-W17)

  edges:
    - from: W7
      to: W8
      type: hard
      critical_path: false

    - from: W7
      to: W11
      type: hard
      critical_path: true

    # ... (all dependencies)

  scheduling:
    topological_order: [W7, W8, W9, W10, W11, W12, W13, W14, W15, W16, W17]
    parallel_batches:
      - batch_id: batch_1
        waves: [W7]
      - batch_id: batch_2
        waves: [W8, W9, W10, W11, W14]
      - batch_id: batch_3
        waves: [W12, W13]
      - batch_id: batch_4
        waves: [W16]
      - batch_id: batch_5
        waves: [W15]
      - batch_id: batch_6
        waves: [W17]

    critical_path: [W7, W11, W12, W16, W15, W17]
    total_duration_hours: 138
```

### 2.1 Nodes

A **wave** is an executable unit with:

```yaml
wave:
  id: W<N>                              # W7, W8, ..., W17
  title: string                         # Human-readable name
  effort: effort_level                  # M (medium), L (large), etc.
  status: wave_status                   # queued, running, completed, failed
  duration_estimate_tokens: number      # Token budget
  created_at: ISO8601                   # Creation timestamp
  started_at: ISO8601 | null            # When execution started
  completed_at: ISO8601 | null          # When execution finished
  dependencies: [W_id]                  # Upstream waves (list of W<N>)
  blocked_by: [W_id]                    # Waves blocking this one (computed)
  evidence_path: string                 # Evidence artifact path
  ledger_entry: string                  # Execution ledger reference
```

### 2.2 Edges

A **dependency edge** connects two waves:

```yaml
edge:
  from: W_id                            # Source wave (upstream)
  to: W_id                              # Target wave (downstream)
  type: hard | soft                     # hard = must complete; soft = advisory
  critical_path: boolean                # Is this on critical path?
  latency_hours: number                 # Expected hours between completion and start
```

### 2.3 Wave DAG for W7-W17

**Dependency graph:**

```
W7 (Ralph Loop, foundation)
├── → W8 (KB Quality)
├── → W9 (Security)
├── → W10 (Metrics)
├── → W14 (Protocols)
└── → W11 (State Machine)
      ├── → W12 (Recovery)
      ├── → W13 (Orchestration)
      └── → W16 (Hardening)
            ├── ← W12
            └── ← W13

All W7-W14 → W15 (Meta-Validation)
W15 + W16 → W17 (Final Validation)
```

**Formal dependency list:**

| Wave | Depends On | Blocked By |
|------|-----------|-----------|
| W7   | —         | —         |
| W8   | W7        | —         |
| W9   | W7        | —         |
| W10  | W7        | —         |
| W11  | W7        | —         |
| W12  | W11       | —         |
| W13  | W11       | —         |
| W14  | W7        | —         |
| W15  | W7,W8,W9,W10,W11,W12,W13,W14 | —         |
| W16  | W12,W13   | —         |
| W17  | W15,W16   | —         |

---

## 3. Scheduling Rules

### 3.1 Topological Sort (Deterministic)

**Rule:** Waves are scheduled using stable topological sort.

**Algorithm:**

```
Input: Wave DAG (dependency graph)
Output: Execution queue (ordered list of waves)

1. Start with all waves that have no dependencies (W7)
2. For each wave in topological order:
   a. Add to queue if all dependencies are met
   b. Never re-order if dependency is already satisfied
   c. Prioritize critical path when tied
3. Return ordered queue
```

**Determinism guarantee:** Same DAG → same order (no randomness, stable sort)

**Implementation:** See `wave-scheduler.sh schedule`

### 3.2 Critical Path

**Critical path:** Longest dependency chain (determines minimum project duration).

**For W7-W17:**

```
Critical Path: W7 (90K) → W11 (65K) → W12 (60K) → W16 (65K) → W15 (55K) → W17 (72K)
Total: ~407K tokens

Non-critical parallel paths:
  W7 → W8 (55K)
  W7 → W9 (65K)
  W7 → W10 (45K)
  W7 → W14 (70K)
  W12 → W13 (70K) [parallel to W12]
```

**Scheduling priority:** Critical path waves scheduled first to minimize project slack.

### 3.3 Batch Execution Modes

**Mode 1: Sequential (default)**
- Execute one wave at a time
- Wait for completion before starting next
- Simpler state tracking
- Slower total time

**Mode 2: Parallel (recommended)**
- Execute independent waves in parallel
- Respect dependencies (W8, W9, W10, W14 can run together after W7)
- W12 and W13 can run together after W11
- Requires coordinator to manage parallel processes
- Faster total time

**Rule:** Waves with no shared downstream dependencies and all upstream dependencies met can execute in parallel.

### 3.4 Deterministic Scheduling (No Randomness)

**Requirements:**
- Same DAG input → same execution order
- Tie-breaking rule: Wave ID ordering (W7 < W8 < ... < W17)
- No random delays
- No non-deterministic scheduling heuristics

**Verification:** `wave-scheduler.sh schedule <input>` called twice with same input must produce identical output.

---

## 4. Wave Status Lifecycle

Each wave has a **status** that progresses through this state machine:

```
queued
  ↓
running
  ├→ completed ✓
  └→ failed
      ↓
    (retry via recovery-manager)
      ├→ running (retry attempt)
      └→ blocked (unrecoverable failure)
```

**Status definitions:**

| Status    | Meaning | Transition | Who controls |
|-----------|---------|-----------|---------------|
| queued    | Waiting for dependencies or execution slot | → running | coordinator |
| running   | Actively executing | → completed or failed | task executor |
| completed | Successful execution, all evals pass | (final) | executor + validator |
| failed    | Execution or validation failed | → blocked or running (retry) | recovery-manager |
| blocked   | Unrecoverable failure, cannot retry | (final) | altitude-coordinator |

**State file location:** `.specs/changes/waves-7-17-implementation/queue/W<N>.status`

---

## 5. Integration with State Machine (FSM)

The orchestration layer works **in tandem** with the state machine (Wave 11).

### 5.1 State Machine Role

**state-machine-contract.md** defines:
- Phase gates (Intent → Structure → Design → Execution → Validate → Ship)
- Transition rules (who can move between phases)
- Deadlock detection (prevent circular dependencies)
- FSM enforcement (no hidden state changes)

### 5.2 Orchestration Role

**orchestration-contract.md** (this file) defines:
- Wave DAG (dependency graph between waves)
- Topological scheduling (execute waves in dependency order)
- Parallel-safe execution (manage concurrent waves)
- Wave state tracking (queued, running, completed, failed)

### 5.3 Integration Points

**Before scheduling:**
- FSM validates that the project is in "Execution" phase
- FSM confirms no state machine deadlocks
- Orchestration computes wave DAG

**During execution:**
- Orchestration respects wave dependencies
- Each wave update triggers FSM validation (via state-validator.sh from Wave 11)
- FSM detects if state machine enters deadlock (error in Wave 11 logic)

**After execution:**
- Orchestration tracks final wave status
- FSM validates transition to next phase
- Evidence collected for validation gate

### 5.4 FSM + Orchestration State Model

```yaml
system_state:
  phase: Execution                      # From state-machine
  wave_status:
    queued: [W7]                        # Orchestration tracking
    running: [W8, W9]                   # Orchestration tracking
    completed: [W7]                     # Orchestration tracking
  fsm_state: execution_phase            # From state-machine
  fsm_deadlock: false                   # From state-machine
  orchestration_dag_valid: true         # From orchestration
  critical_path_identified: true        # From orchestration
```

---

## 6. Scheduling State

The orchestration system maintains scheduling state:

```yaml
scheduling_state:
  change_id: waves-7-17-implementation
  created_at: ISO8601
  current_phase: scheduling | executing | completed

  wave_queue:
    - wave_id: W7
      status: queued
      position: 1
      dependencies_met: true
      estimated_start: ISO8601
      estimated_duration_hours: 24

    - wave_id: W8
      status: queued
      position: 2
      dependencies_met: false (waiting for W7)
      estimated_start: ISO8601 (after W7 completes)
      estimated_duration_hours: 14

  parallel_batches:
    - batch_id: batch_1
      waves: [W8, W9, W10, W14]
      start_after: W7
      duration_hours: 24
      batch_status: planned

  critical_path:
    waves: [W7, W11, W12, W16, W15, W17]
    total_duration_hours: 168
    slack_hours: 0

  execution_log:
    - timestamp: ISO8601
      wave_id: W7
      status_change: queued → running
      message: "Starting Wave 7: Ralph Loop"
```

---

## 7. Orchestration Contract vs. Task Contracts

**This contract** (orchestration-contract.md):
- Governs multi-wave scheduling and dependencies
- Applies to the entire W7-W17 lifecycle
- Used by altitude-coordinator agent
- Controls execution order and parallelization

**Task contracts** (TASKS.md and individual W<N> files):
- Govern individual wave implementation
- Define success criteria per wave
- Specify acceptance criteria and evals
- Controlled by individual task executors

**Relationship:**
```
orchestration-contract.md (master)
  ↓ (orchestrates)
  ├→ W7-RALPH-LOOP.md (task contract)
  ├→ W8-KB-QUALITY.md (task contract)
  ├→ ...
  └→ W17-FINAL-VALIDATION.md (task contract)
```

---

## 8. Constraints

### 8.1 Determinism

**MUST:** Same DAG → same execution order (no randomness)

**Implementation:** Topological sort with stable tie-breaking (wave ID order)

### 8.2 Parallel Safety

**MUST:** Support independent parallel execution of waves

**Rule:** Waves with no shared downstream dependencies can run in parallel

**Guarantee:** Orchestration correctly identifies parallelizable waves from DAG

### 8.3 State Tracking Correctness

**MUST:** Accurately track wave state (queued, running, completed, failed)

**Guarantee:** No wave can be marked completed without evidence of passing all evals

### 8.4 FSM Integration

**MUST:** Orchestration respects state-machine gates

**Guarantee:** No wave execution without FSM validation that project is in Execution phase

### 8.5 No Hardcoding

**MUST:** Wave dependencies read from wave-structure.yaml or .specs artifacts, not hardcoded in scheduler

---

## 9. Tools & Contracts

**Related contracts:**
- `.specs/shared/state-machine-contract.md` (FSM model)
- `.specs/shared/recovery-contract.md` (rollback on failure)
- `.specs/shared/protocol-contract.md` (agent messaging)

**Related tools:**
- `tools/wave-scheduler.sh` (compute order, execute waves)
- `tools/wave-scheduler.contract.md` (command reference)
- `tools/state-validator.sh` (Wave 11 FSM validation)
- `tools/recovery-manager.sh` (Wave 12 error handling)

---

## 10. Example: Scheduling W7-W17

**Input:** Wave dependency graph (from STRUCTURE.md)

**Process:**
```
1. Load DAG: W7 → {W8,W9,W10,W14,W11}; W11 → {W12,W13,W16}; etc.
2. Topological sort: [W7, W8, W9, W10, W11, W14, W12, W13, W16, W15, W17]
3. Group parallelizable: batch_1=[W8,W9,W10,W14]; batch_2=[W12,W13]
4. Output: Execution plan with batches and timing
```

**Output:**
```yaml
execution_plan:
  sequence:
    - phase: phase_1
      waves: [W7]
      parallel: false
      duration_hours: 24

    - phase: phase_2
      waves: [W8, W9, W10, W14]
      parallel: true
      duration_hours: 24

    - phase: phase_3
      waves: [W11]
      parallel: false
      duration_hours: 18

    - phase: phase_4
      waves: [W12, W13]
      parallel: true
      duration_hours: 20

    - phase: phase_5
      waves: [W16]
      parallel: false
      duration_hours: 18

    - phase: phase_6
      waves: [W15]
      parallel: false
      duration_hours: 14

    - phase: phase_7
      waves: [W17]
      parallel: false
      duration_hours: 20

  total_duration_hours: 138 (vs 407K tokens sequential)
  critical_path: [W7, W11, W12, W16, W15, W17]
```

---

## 11. Failure & Recovery

**If a wave fails:**

1. **Recovery manager (Wave 12)** is called
2. Recovery manager decides:
   - Retry with same code
   - Rollback + fix + retry
   - Skip wave (if not critical)
   - Block project (if unrecoverable)
3. State is updated
4. Orchestrator resumes from failure point

**Related:** `.specs/shared/recovery-contract.md`

---

## 12. Acceptance & Validation

**Acceptance criteria (for this contract):**

- [ ] Wave DAG model is formalized (section 2)
- [ ] Scheduling rules are deterministic (section 3)
- [ ] Status lifecycle is clear (section 4)
- [ ] FSM integration is defined (section 5)
- [ ] No hardcoded dependencies (section 8.5)
- [ ] Tools are integrated (section 9)
- [ ] Example walkthrough works (section 10)

**Validation by:** altitude-validator (Wave 15) + altitude-coordinator (Wave 13)

---

## References

- STRUCTURE.md — Wave dependency graph (source)
- state-machine-contract.md — FSM gates and deadlock detection
- recovery-contract.md — Error handling and rollback
- Wave 13 task (W13-ORCHESTRATION.md) — Implementation task
- altitude-coordinator.agent.md — Orchestration agent (owner)
