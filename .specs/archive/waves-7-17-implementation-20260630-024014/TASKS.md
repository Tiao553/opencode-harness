# Waves 7-17 Implementation — Task Index

**Format:** Task-Spec v2.1  
**Total Tasks:** 11 (1 per wave)  
**Total Budget:** ~694K tokens  
**Status:** All ready for execution  

---

## Task Summary

| ID | Wave | Title | Effort | Budget | Agent | Status | Depends | Blocks |
|----|------|-------|--------|--------|-------|--------|---------|--------|
| W7-RALPH-LOOP | 7 | Ralph Loop Verification | M | 90K | altitude-execution | ready | — | 8,9,10,11,14 |
| W8-KB-QUALITY | 8 | KB Quality & Indexing | M | 48K | altitude-structure | ready | 7 | — |
| W9-SECURITY | 9 | Security & Secrets Detection | M | 48K | altitude-execution | ready | 7 | — |
| W10-METRICS | 10 | Performance Metrics | M | 48K | altitude-report | ready | 7 | — |
| W11-STATE-MACHINE | 11 | State Machine FSM | M | 77K | altitude-plan | ready | 7 | 12,13,16 |
| W12-RECOVERY | 12 | Error Recovery & Rollback | M | 60K | altitude-execution | ready | 11 | 16 |
| W13-ORCHESTRATION | 13 | Multi-Wave Orchestration | M | 70K | altitude-coordinator | ready | 11 | 16 |
| W14-PROTOCOLS | 14 | Agent Communication | M | 48K | altitude-execution | ready | 7 | — |
| W15-META-VALIDATION | 15 | Junta Audit | M | 55K | altitude-validation | ready | 7–14 | 17 |
| W16-HARDENING | 16 | Chaos Testing | M | 65K | altitude-report | ready | 11,12,13 | 17 |
| W17-FINAL-VALIDATION | 17 | Final Gate & Docs | M | 72K | altitude-report | ready | 15,16 | — |

---

## Execution Order (Critical Path)

```
Phase 1 (Sequential):
  └─ W7 (foundation, 90K)

Phase 2 (Parallel after Phase 1):
  ├─ W8 (KB, 48K)
  ├─ W9 (Security, 48K)
  ├─ W10 (Metrics, 48K)
  └─ W14 (Protocols, 48K)
  Total Phase 2: 192K

Phase 3 (Sequential after Phase 2):
  └─ W11 (State Machine, 77K)

Phase 4 (Parallel after Phase 3):
  ├─ W12 (Recovery, 60K)
  └─ W13 (Orchestration, 70K)
  Total Phase 4: 130K

Phase 5 (Sequential after Phase 4):
  └─ W16 (Hardening, 65K)

Phase 6 (Sequential after Phase 5):
  └─ W15 (Meta-Validation, 55K)

Phase 7 (Sequential after Phase 6):
  └─ W17 (Final, 72K)

Total: 7 phases | 11 tasks | ~694K tokens | Critical path: 7→11→(12+13)→16→15→17
```

---

## Task Details

### Phase 1: Foundation

**[W7-RALPH-LOOP](./tasks/W7-RALPH-LOOP.md)** — Ralph Loop Verification (90K)

Deterministic execution tracing with verify_step wrapper. Foundation for all downstream waves.

**Delivers:**
- `.specs/shared/verification-contract.md` (trace schema, replay semantics)
- `tools/verify-step.sh` (wrapper + trace recording)
- `agents/altitude-execution.agent.md` (integration)
- Fixture: 2 scenarios (happy path, fork)

**Blocks:** W8, W9, W10, W11, W14 (all use traces)

---

### Phase 2: Parallel Layers (192K)

**[W8-KB-QUALITY](./tasks/W8-KB-QUALITY.md)** — KB Quality & Indexing (48K)

Index KB domains, track staleness, enable smart context loading.

**Depends on:** W7 (uses traces for metadata)

---

**[W9-SECURITY](./tasks/W9-SECURITY.md)** — Security & Secrets Detection (48K)

Pre-write security gate: gitleaks, PII detection, sensitive file blocking.

**Depends on:** W7 (logs to trace)

---

**[W10-METRICS](./tasks/W10-METRICS.md)** — Performance Metrics Collection (48K)

Measure execution time, token usage, latency from traces.

**Depends on:** W7 (metrics from Ralph Loop traces)

---

**[W14-PROTOCOLS](./tasks/W14-PROTOCOLS.md)** — Multi-Agent Communication (48K)

Agent-to-agent messaging protocol with routing and acknowledgments.

**Depends on:** W7 (message tracing)

---

### Phase 3: State Foundation

**[W11-STATE-MACHINE](./tasks/W11-STATE-MACHINE.md)** — State Machine FSM (77K)

Formalize phase FSM, enforce transitions, detect deadlocks.

**Depends on:** W7  
**Blocks:** W12, W13, W16 (all use FSM state)

---

### Phase 4: State Layers (130K)

**[W12-RECOVERY](./tasks/W12-RECOVERY.md)** — Error Recovery & Rollback (60K)

State snapshots, atomic rollback, safe failure modes.

**Depends on:** W11 (state snapshots)

---

**[W13-ORCHESTRATION](./tasks/W13-ORCHESTRATION.md)** — Multi-Wave Orchestration (70K)

NEW agent: altitude-coordinator. Wave DAG scheduling and batch execution.

**Depends on:** W11 (state-driven scheduling)

---

### Phase 5: Resilience

**[W16-HARDENING](./tasks/W16-HARDENING.md)** — Production Hardening & Chaos (65K)

Load testing, chaos injection, resilience validation.

**Depends on:** W11, W12, W13  
**Blocks:** W17 (ship gate)

---

### Phase 6: Validation

**[W15-META-VALIDATION](./tasks/W15-META-VALIDATION.md)** — Junta Audit (55K)

Meta-validate all validators (Waves 7–14) for quality and bias.

**Depends on:** W7–W14 (audits all validators)  
**Blocks:** W17 (ship gate)

---

### Phase 7: Ship Gate

**[W17-FINAL-VALIDATION](./tasks/W17-FINAL-VALIDATION.md)** — Final Validation & Docs (72K)

Final gate checks, documentation complete, SHIP readiness.

**Depends on:** W15, W16  
**Delivers:** Updated AGENTS.md, README.md, roadmap doc  

---

## PR Strategy (3 PRs)

### PR-7 (Waves 7-10)

**Title:** Wave 7-10: Ralph Loop, KB Quality, Security, Metrics

**Contains:**
- W7-RALPH-LOOP (90K)
- W8-KB-QUALITY (48K)
- W9-SECURITY (48K)
- W10-METRICS (48K)

**Total:** ~234K tokens | 4 contracts | 4 tools | 4 fixtures | 3 agent updates

**Merge gate:** All 4 tasks passing

---

### PR-8 (Waves 11-14)

**Title:** Wave 11-14: State Machine, Recovery, Orchestration, Protocols

**Contains:**
- W11-STATE-MACHINE (77K)
- W12-RECOVERY (60K)
- W13-ORCHESTRATION (70K)
- W14-PROTOCOLS (48K)

**Total:** ~255K tokens | 4 contracts | 4 tools | 4 fixtures | 1 NEW agent (altitude-coordinator) | 3 agent updates

**Merge gate:** Depends PR-7, all 4 tasks passing

---

### PR-9 (Waves 15-17)

**Title:** Wave 15-17: Meta-Validation, Hardening, Final Validation + Docs

**Contains:**
- W15-META-VALIDATION (55K)
- W16-HARDENING (65K)
- W17-FINAL-VALIDATION (72K)

**Total:** ~192K tokens | 3 contracts | 3 tools | 3 fixtures | 2 agent updates | AGENTS.md + README.md + roadmap doc

**Merge gate:** Depends PR-8, all 3 tasks passing, docs complete

---

## Global Allocation

**Owner:** Altitude Coordinator  
**Mode:** Strategic durable work (Harness V3 self-refactoring)

**Allowed Files:**
- `.specs/shared/` (11 new contracts)
- `tools/` (11 tools + 11 contracts = 22 files)
- `agents/` (9 agents total: 8 existing updates + 1 new altitude-coordinator)
- `test/fixtures/harness-v3/` (11 fixtures)
- `.specs/changes/waves-7-17-implementation/` (tasks, design, state)
- `AGENTS.md` (sections 21.7–21.17)
- `README.md` (Wave 7-17 section)
- `docs/HARNESS_V3_WAVES_7-17_ROADMAP.md` (new)

**Forbidden:**
- Waves 0-6 files (frozen)
- Source application code
- `.specs/archive/`
- External integrations

---

## Validation Gates

Each task must:
1. ✅ Contract file created and valid
2. ✅ Tool script working (all commands pass)
3. ✅ Agent integration complete
4. ✅ Fixtures pass (both scenarios)
5. ✅ No breaking changes to existing behavior
6. ✅ Rollback plan documented

**Pre-execution validation:**
```bash
# For each task W*:
bash scripts/validate-task-spec.sh .specs/changes/waves-7-17-implementation/tasks/W*.md

# Run all fixtures:
bash test/fixtures/harness-v3/wave-*.fixture.md
```

---

## Next Steps

1. ✅ **Design/Plan Phase complete** (11 formal Task-Specs created)
2. **Await user sign-off** → Ready to enter Execution Phase?
3. **Execute tasks in dependency order** (critical path: W7→W11→(W12+W13)→W16→W15→W17)
4. **Merge 3 PRs** respecting dependencies
5. **Validate & Ship** (Wave 17)

---

## Ready to Execute?

**Confirm these before Execution Phase:**

- [ ] Task-Specs are formal (v2.1 format, all have evals)
- [ ] Dependency graph is correct (W7 first, W15-W17 last)
- [ ] Token budget is realistic (~694K total)
- [ ] 3 PRs make sense (grouped by phase)
- [ ] Allocation is clear (no cross-wave file touches)
- [ ] Ready to start with W7-RALPH-LOOP task?

**Answer YES to proceed, or ask for refinements.**
