# Waves 7-17 Implementation — Structure Phase

**Change ID:** waves-7-17-implementation  
**Phase:** Structure (Phase 1)  
**Date:** 2026-06-29  
**Status:** Mapping Repository Surface

---

## 1. File Impact Map

### New Shared Contracts (11 files, ~5,000 lines)

```
.specs/shared/
├── verification-contract.md              (Wave 7 — Ralph Loop verification)
├── kb-quality-contract.md                (Wave 8 — KB quality & indexing)
├── security-contract.md                  (Wave 9 — Security & secrets)
├── metrics-contract.md                   (Wave 10 — Performance metrics)
├── state-machine-contract.md             (Wave 11 — State machine formalization)
├── recovery-contract.md                  (Wave 12 — Error recovery & rollback)
├── orchestration-contract.md             (Wave 13 — Wave orchestration)
├── protocol-contract.md                  (Wave 14 — Multi-agent communication)
├── meta-validation-contract.md           (Wave 15 — Cross-validation junta)
├── hardening-contract.md                 (Wave 16 — Production hardening)
└── final-validation-contract.md          (Wave 17 — Final validation & docs)
```

### New Tools (11 scripts + 11 contracts, ~6,500 lines)

```
tools/
├── verify-step.sh                        (Wave 7)
├── verify-step.contract.md               (Wave 7)
├── kb-indexer.sh                         (Wave 8)
├── kb-indexer.contract.md                (Wave 8)
├── security-scan.sh                      (Wave 9)
├── security-scan.contract.md             (Wave 9)
├── metrics-collector.sh                  (Wave 10)
├── metrics-collector.contract.md         (Wave 10)
├── state-validator.sh                    (Wave 11)
├── state-validator.contract.md           (Wave 11)
├── recovery-manager.sh                   (Wave 12)
├── recovery-manager.contract.md          (Wave 12)
├── wave-scheduler.sh                     (Wave 13)
├── wave-scheduler.contract.md            (Wave 13)
├── agent-messenger.sh                    (Wave 14)
├── agent-messenger.contract.md           (Wave 14)
├── junta-auditor.sh                      (Wave 15)
├── junta-auditor.contract.md             (Wave 15)
├── chaos-tester.sh                       (Wave 16)
├── chaos-tester.contract.md              (Wave 16)
├── acceptance-checker.sh                 (Wave 17)
└── acceptance-checker.contract.md        (Wave 17)
```

### Modified Agents (8 agents touched, ~1,500 lines added)

```
agents/
├── altitude-execution.agent.md           (Waves 7, 9, 12 — trace, security, recovery)
├── altitude-validation.agent.md          (Waves 11, 15 — state validation, junta audit)
├── altitude-plan.agent.md                (Wave 13 — orchestration support)
├── altitude-report.agent.md              (Waves 10, 16 — metrics, hardening sections)
├── altitude-structure.agent.md           (Wave 8 — KB audit)
├── altitude-coordinator.agent.md         (Wave 13 NEW — wave orchestration)
├── data-engineer.agent.md                (Wave 14 — messaging support)
└── altitude-memory.agent.md              (Wave 17 — final memory update)
```

### Golden Fixtures (11 files, ~2,500 lines)

```
test/fixtures/harness-v3/
├── wave-7-ralph-loop.fixture.md          (4 scenarios: happy path, retry, fork, replay)
├── wave-8-kb-quality.fixture.md          (4 scenarios: index, stale, refresh, audit)
├── wave-9-security.fixture.md            (5 scenarios: safe, secret, PII, blocked, override)
├── wave-10-metrics.fixture.md            (4 scenarios: timing, tokens, latency, report)
├── wave-11-state-machine.fixture.md      (6 scenarios: valid, invalid, deadlock, recovery)
├── wave-12-recovery.fixture.md           (5 scenarios: snapshot, fail, rollback, validate)
├── wave-13-orchestration.fixture.md      (5 scenarios: schedule, queue, execute, batch)
├── wave-14-protocols.fixture.md          (4 scenarios: message, route, acknowledge, error)
├── wave-15-meta-validation.fixture.md    (4 scenarios: audit, bias, score, remediate)
├── wave-16-hardening.fixture.md          (6 scenarios: load, stress, chaos, recover, report)
└── wave-17-final-validation.fixture.md   (3 scenarios: gate, accept, ship)
```

### Design Documents (11 files, ~5,500 lines)

```
.specs/changes/waves-7-17-implementation/
├── DESIGN.md                             (Master design document)
├── wave-7/design.md                      (Ralph Loop Verification)
├── wave-8/design.md                      (KB Quality & Indexing)
├── wave-9/design.md                      (Security & Secrets)
├── wave-10/design.md                     (Performance Metrics)
├── wave-11/design.md                     (State Machine)
├── wave-12/design.md                     (Error Recovery)
├── wave-13/design.md                     (Wave Orchestration)
├── wave-14/design.md                     (Multi-Agent Comm)
├── wave-15/design.md                     (Meta-Validation)
├── wave-16/design.md                     (Hardening)
└── wave-17/design.md                     (Final Validation)
```

### Documentation Updates (3 files, ~800 lines)

```
Root level:
├── README.md                             (Update Waves 7-17 sections, roadmap)
├── AGENTS.md                             (Add sections 21.7-21.17 for wave tools)
└── docs/HARNESS_V3_WAVES_7-17_ROADMAP.md (NEW — comprehensive roadmap)
```

---

## 2. Dependency Graph

### Linear Dependencies (Refined)

```
Wave 7 (Ralph Loop Verification) — FOUNDATION
  ├─→ Wave 8 (KB Quality) — uses traces
  ├─→ Wave 9 (Security) — logs to trace
  ├─→ Wave 10 (Metrics) — measures from traces
  ├─→ Wave 11 (State Machine) — validates state transitions via traces
  ├─→ Wave 14 (Protocols) — message tracing
  └─→ Everything traces back to Wave 7

Wave 12 (Recovery) ← depends on Wave 11 (state snapshots)
Wave 13 (Orchestration) ← depends on Wave 11 (state-driven scheduling)
Wave 16 (Hardening) ← depends on Waves 11, 12, 13 (chaos tests state + recovery + orchestration)
Wave 15 (Meta-Validation) ← depends on all prior (audits all validators)
Wave 17 (Final Validation) ← depends on all 16 waves
```

### Dependency Matrix (Corrected)

| Wave | Depends On | Why |
|------|-----------|-----|
| 7 | None | Foundation: Ralph Loop tracing |
| 8 | 7 | KB indexing uses Ralph Loop traces for freshness metadata |
| 9 | 7 | Security scan events log to Ralph Loop trace |
| 10 | 7 | Metrics collector measures performance from Ralph Loop traces |
| 11 | 7 | State machine validator uses decision traces from Wave 7 |
| 12 | 11 | Recovery manager snapshots state from Wave 11 FSM |
| 13 | 11 | Wave orchestrator schedules based on state transitions (Wave 11) |
| 14 | 7 | Protocol messenger logs messages to Ralph Loop trace |
| 15 | 7, 8, 9, 10, 11, 12, 13, 14 | Meta-junta audits all validators from Wave 7 onward |
| 16 | 11, 12, 13 | Chaos tester exercises state transitions, recovery paths, orchestration |
| 17 | 7-16 | Final validation runs complete system test |

### Execution Order (Corrected - Respecting Dependencies)

**Phase 1 (Sequential):** Wave 7 ONLY (blocker for all others)

**Phase 2 (Parallel after Wave 7):** Waves 8, 9, 10, 14 (parallel, all depend on 7)

**Phase 3 (Sequential after Phase 2):** Wave 11 (depends on 7, 9, 10 complete)

**Phase 4 (Parallel after Wave 11):** Waves 12, 13 (depend on 11)

**Phase 5 (Sequential after Phase 4):** Wave 16 (depends on 11, 12, 13)

**Phase 6 (Sequential after Phase 5):** Wave 15 (audits all), then Wave 17 (final)

**Critical Path:** 7 → 11 → (12,13) → 16 → 15 → 17

**Parallelizable:** (8,9,10,14) after 7; (12,13) after 11


---

## 3. File Scope & Boundaries

### Global Allocation

**Can create/modify:**
- `.specs/shared/` (11 new contract files)
- `tools/` (22 new files: 11 scripts + 11 contracts)
- `agents/` (8 existing agents modified)
- `test/fixtures/harness-v3/` (11 new fixture files)
- `.specs/changes/waves-7-17-implementation/` (11 design files)
- `docs/` (1 new file)
- `README.md` (update)
- `AGENTS.md` (update)

**Cannot touch:**
- Source application code
- User data files
- External integrations
- Waves 0-6 files (locked)
- `.specs/archive/` (legacy only)

**Wave 17 controls:**
- Final README/AGENTS/docs updates
- No files beyond scope

---

## 4. Repo Surface Impact Summary

| Category | Count | Lines | Impact |
|----------|-------|-------|--------|
| **New Contracts** | 11 | 5,000 | High (core) |
| **New Tools** | 22 | 6,500 | High (operational) |
| **Agent Updates** | 8 | 1,500 | Medium (coordination) |
| **Fixtures** | 11 | 2,500 | Medium (validation) |
| **Design Docs** | 12 | 5,500 | High (planning) |
| **Doc Updates** | 3 | 800 | Low (reference) |
| **TOTAL** | **67** | **~21,800** | **Major refactor** |

---

## 5. Constraints & Risks

### Constraints

| Type | Details |
|------|---------|
| **Time** | No deadline; quality > speed |
| **Context** | Token budget limits context loading per wave |
| **Testing** | All 11 waves need golden fixtures |
| **Dependencies** | Wave 15 + 17 must run after others complete |
| **Merge** | 1 PR per wave (11 PRs total) |
| **Validation** | Each wave must pass junta validation before merge |

### Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Waves 7-11 create deadlock in state machine | Medium | High | Wave 11 design validates state graph |
| Wave 15 meta-validation fails on existing juntas | Low | High | Run existing junta test cases first |
| Wave 13 orchestration breaks multi-wave scheduling | Medium | Medium | Design Wave 13 carefully, test with Wave 7+8 |
| Tool contracts conflict with existing Wave 4-6 patterns | Low | Medium | Review tool contract template consistency |
| Documentation becomes stale (Wave 17 rush) | High | Medium | Update docs continuously per wave, not just Wave 17 |

---

## 6. Affected Systems

### Directly Touched

- **Altitude Coordinator** — Primary system
- **Execution Engine** — Ralph Loop, recovery, traces
- **Validation System** — Juntas, meta-validation
- **Agent Communication** — Protocols, messaging
- **State Management** — State machine, recovery
- **KB Governance** — Quality indexing

### Indirectly Affected

- **Data Engineer Coordinator** — May use new protocols
- **Specialists** — May use metrics, security scanning
- **Users** — Better traceability, security, performance

---

## 7. Pre-Execution Checklist

**Before starting Execution Phase:**

- [ ] All 11 dependency relationships validated
- [ ] Each wave has clear allowed/forbidden files
- [ ] Design/Plan phase identifies task granularity
- [ ] Allocation per task is explicit
- [ ] Tool contracts follow existing pattern (Wave 4-6)
- [ ] Agent updates preserve backward compatibility
- [ ] Fixture scenarios cover all paths
- [ ] README/AGENTS/docs update plan defined

---

## 8. Unknowns to Clarify

| Unknown | Impact | Decision Needed |
|---------|--------|-----------------|
| Can Wave 7 verify-step reuse existing `verify_step` tool? | Medium | Design phase to decide (wrap vs. new) |
| Should Wave 13 orchestrator be new agent or coordinate existing? | High | Design phase (new altitude-coordinator vs. altitude-plan extension) |
| Wave 15: Which existing juntas should meta-validation audit? | Medium | Design phase (all 4 or subset?) |
| Tool naming convention: `-` or `_`? | Low | Follow existing (Wave 4-6 use `-`) |

---

## 9. Summary

**What will change:**
- 11 new shared contracts (core enforcement)
- 22 new tools + contracts (operational)
- 8 agents updated (coordination + integration)
- 11 fixtures (validation)
- 12 design docs (planning)
- 3 doc updates (reference)

**What will NOT change:**
- Waves 0-6 (locked)
- Source app code
- External integrations
- Core Altitude phases

**Next Phase:** Design/Plan
- Decompose 11 waves into executable tasks
- Define task allocation
- Create task pack
- Ready for Execution

---

## 10. Sign-Off Gate

**Structure Phase Ready for Design/Plan Phase?**

Questions for user before proceeding:

1. ✅ Dependency graph correct?
2. ✅ File scope boundaries clear?
3. ✅ Risks identified and acceptable?
4. ✅ Ready to move to Design/Plan?
