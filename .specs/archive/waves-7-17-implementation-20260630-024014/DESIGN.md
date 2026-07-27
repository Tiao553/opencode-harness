# Waves 7-17 Implementation — Design/Plan Phase (Revised)

**Change ID:** waves-7-17-implementation  
**Phase:** Design/Plan (Phase 2)  
**Date:** 2026-06-29  
**Status:** Task Decomposition & Allocation (Revised)

---

## 1. Task Pack Strategy

### Subdivision: 3 tasks per wave (contract → tool → integration)

Each wave splits into:
1. **T-X.1: Contract + Design** (~15-20 lines contract, specification)
2. **T-X.2: Tool Implementation** (script + testing)
3. **T-X.3: Agent Integration + Fixtures** (agent updates + smoke tests)

**Total:** 11 waves × 3 tasks = **33 tasks**

---

### Token Allocation (Dynamic)

| Wave | Complexity | T.1 Contract | T.2 Tool | T.3 Integration | Total |
|------|-----------|----------|---------|-----------------|-------|
| 7 | High (foundation) | 10K | 50K | 30K | **90K** |
| 8 | Medium | 8K | 25K | 15K | **48K** |
| 9 | Medium | 8K | 25K | 15K | **48K** |
| 10 | Medium | 8K | 25K | 15K | **48K** |
| 11 | High (state machine) | 12K | 40K | 25K | **77K** |
| 12 | Medium | 10K | 30K | 20K | **60K** |
| 13 | Medium-High | 10K | 35K | 25K | **70K** |
| 14 | Medium | 8K | 25K | 15K | **48K** |
| 15 | Medium (audit) | 10K | 30K | 15K | **55K** |
| 16 | Medium-High (stress) | 10K | 35K | 20K | **65K** |
| 17 | High (final) | 12K | 40K | 20K | **72K** |
| **TOTAL** | — | **114K** | **365K** | **215K** | **694K** |

---

## 2. Detailed Task Decomposition

### Block 1: Waves 7-10 (Foundation)

#### Task T7.1: Ralph Loop Verification — Contract & Design

**Objective:** Specify deterministic tracing API and decision trace schema

**Dependencies:** None

**Deliverables:**
- `.specs/shared/verification-contract.md` (trace schema, replay semantics, decision graph)
- `.specs/changes/waves-7-17-implementation/wave-7/DESIGN.md` (technical design)

**Allowed Files:**
- `.specs/shared/verification-contract.md`
- `.specs/changes/waves-7-17-implementation/wave-7/`

**Forbidden:**
- Source code, tools, agents (yet)

**Acceptance Criteria:**
✅ Trace schema defined (decision_id, path, inputs, outputs, timestamp)  
✅ Replay semantics documented (deterministic replay, decision fork capture)  
✅ API surface clear (verify_step signature, inputs/outputs)  
✅ Examples provided (happy path, fork, retry)

**Verification:**
```bash
# Contract exists and is valid YAML
grep -q "schema:" .specs/shared/verification-contract.md
grep -q "replay_semantics:" .specs/shared/verification-contract.md

# Design document exists
ls -la .specs/changes/waves-7-17-implementation/wave-7/DESIGN.md
```

**Token Budget:** 10K  
**Evidence:** Contract file, design doc

---

#### Task T7.2: Ralph Loop Verification — Tool Implementation

**Objective:** Implement verify_step wrapper and trace recording

**Dependencies:** T7.1 complete

**Deliverables:**
- `tools/verify-step.sh` (wrapper, trace recording, replay)
- `tools/verify-step.contract.md` (command reference: `verify_step start|check|replay|ledger`)

**Allowed Files:**
- `tools/verify-step.sh`
- `tools/verify-step.contract.md`

**Acceptance Criteria:**
✅ `verify_step start --session-id <id> --step "<step>"` creates trace entry  
✅ `verify_step check --session-id <id> --verdict PASS|FAIL|BLOCKED` records result  
✅ `verify_step replay --session-id <id>` plays back trace deterministically  
✅ `verify_step ledger --session-id <id>` dumps trace as YAML  
✅ No errors on repeated calls  
✅ Trace is machine-parseable

**Verification:**
```bash
# Tool exists and is executable
test -x tools/verify-step.sh

# Commands work
tools/verify-step.sh start --session-id test1 --step "setup database"
tools/verify-step.sh check --session-id test1 --verdict PASS
tools/verify-step.sh ledger --session-id test1 | grep -q "decision_id"

# No syntax errors
bash -n tools/verify-step.sh
```

**Token Budget:** 50K  
**Evidence:** Tool script, command trace log

---

#### Task T7.3: Ralph Loop Verification — Agent Integration & Fixtures

**Objective:** Update altitude-execution to use verify_step; smoke test

**Dependencies:** T7.1, T7.2 complete

**Deliverables:**
- Update `agents/altitude-execution.agent.md` (+40 lines: trace recording at decision points)
- `test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md` (2 scenarios: happy path, fork)

**Allowed Files:**
- `agents/altitude-execution.agent.md` (add section on trace recording)
- `test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md`

**Acceptance Criteria:**
✅ altitude-execution calls verify_step at decision gates  
✅ Trace recorded to `.specs/changes/waves-7-17-implementation/03-execution-ledger.md`  
✅ Fixture scenario 1 (happy path) traces correctly  
✅ Fixture scenario 2 (decision fork) splits trace  
✅ No breaking changes to existing altitude-execution behavior

**Verification:**
```bash
# Agent updated
grep -q "verify_step" agents/altitude-execution.agent.md

# Fixture exists
ls -la test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md

# Fixture runs
bash test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md
grep -c "decision_id" test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md
```

**Token Budget:** 30K  
**Evidence:** Agent diff, fixture output

---

#### Task T8.1: KB Quality & Indexing — Contract & Design

**Objective:** Specify KB domain taxonomy and freshness tracking

**Dependencies:** T7.1 complete (uses Ralph Loop traces for metadata)

**Deliverables:**
- `.specs/shared/kb-quality-contract.md` (domain taxonomy, freshness schema, stale detection)
- `.specs/changes/waves-7-17-implementation/wave-8/DESIGN.md`

**Allowed Files:**
- `.specs/shared/kb-quality-contract.md`
- `.specs/changes/waves-7-17-implementation/wave-8/`

**Acceptance Criteria:**
✅ Domain taxonomy defined  
✅ Freshness schema (age, last-update, decay function)  
✅ Stale detection rules (>30 days = stale)  
✅ Refresh patterns documented

**Verification:**
```bash
grep -q "domain_taxonomy:" .specs/shared/kb-quality-contract.md
grep -q "freshness_schema:" .specs/shared/kb-quality-contract.md
```

**Token Budget:** 8K

---

#### Task T8.2: KB Quality & Indexing — Tool Implementation

**Objective:** Implement kb-indexer script

**Dependencies:** T7.2, T8.1 complete

**Deliverables:**
- `tools/kb-indexer.sh` (scan, index, freshness check)
- `tools/kb-indexer.contract.md`

**Allowed Files:**
- `tools/kb-indexer.sh`
- `tools/kb-indexer.contract.md`

**Commands:**
- `kb-indexer.sh index <kb-dir>` → builds index
- `kb-indexer.sh freshness --domain <domain>` → age check
- `kb-indexer.sh list` → all domains + freshness

**Verification:**
```bash
tools/kb-indexer.sh index kb/
tools/kb-indexer.sh freshness --domain ai-data-engineer
tools/kb-indexer.sh list | grep -q "domain_id"
```

**Token Budget:** 25K

---

#### Task T8.3: KB Quality & Indexing — Agent Integration & Fixtures

**Objective:** Update altitude-structure to validate KB; smoke test

**Dependencies:** T8.1, T8.2 complete

**Deliverables:**
- Update `agents/altitude-structure.agent.md` (+20 lines: KB audit on structure phase)
- `test/fixtures/harness-v3/wave-8-kb-quality-smoke.fixture.md` (2 scenarios: fresh, stale)

**Acceptance Criteria:**
✅ altitude-structure calls kb-indexer.sh during structure phase  
✅ Stale KB domains logged as warnings  
✅ Fixture scenario 1 (fresh KB) passes  
✅ Fixture scenario 2 (stale KB) triggers warning

**Verification:**
```bash
grep -q "kb-indexer" agents/altitude-structure.agent.md
bash test/fixtures/harness-v3/wave-8-kb-quality-smoke.fixture.md
```

**Token Budget:** 15K

---

#### Task T9.1 & T9.2: Security & Secrets Detection (Contract + Tool)

**Objective:** Security scanning contract and gitleaks/PII tool

**Dependencies:** T7.1 complete

**Deliverables:**
- `.specs/shared/security-contract.md` (scan rules, sensitivity levels)
- `tools/security-scan.sh` (gitleaks, PII regex patterns)
- `tools/security-scan.contract.md`

**Commands:**
- `security-scan.sh scan <files>` → detect secrets
- `security-scan.sh pii <files>` → detect PII patterns
- `security-scan.sh report` → summary

**Acceptance Criteria:**
✅ Detects common secrets (AWS keys, tokens)  
✅ Detects PII (SSN, phone, email patterns)  
✅ Blocks sensitive files from being written  
✅ Returns non-zero exit on findings

**Verification:**
```bash
tools/security-scan.sh scan agents/
test $? -eq 0  # No secrets found
```

**Token Budget:** 8K (contract) + 25K (tool) = 33K

---

#### Task T9.3: Security & Secrets Detection — Integration & Fixtures

**Objective:** Update altitude-execution security gate; smoke test

**Dependencies:** T9.1, T9.2 complete

**Deliverables:**
- Update `agents/altitude-execution.agent.md` (+15 lines: security gate before write)
- `test/fixtures/harness-v3/wave-9-security-smoke.fixture.md` (2 scenarios: safe, blocked)

**Acceptance Criteria:**
✅ altitude-execution runs security-scan before writing files  
✅ Fixture scenario 1 (safe file) passes  
✅ Fixture scenario 2 (file with secret) blocked

**Verification:**
```bash
bash test/fixtures/harness-v3/wave-9-security-smoke.fixture.md
```

**Token Budget:** 15K

---

#### Task T10.1 & T10.2: Performance Metrics (Contract + Tool)

**Objective:** Metrics collection contract and metrics-collector tool

**Dependencies:** T7.1 complete

**Deliverables:**
- `.specs/shared/metrics-contract.md` (measurement schema)
- `tools/metrics-collector.sh` (timing, token, latency)
- `tools/metrics-collector.contract.md`

**Commands:**
- `metrics-collector.sh collect --session-id <id>` → gather metrics
- `metrics-collector.sh report <session-id>` → human report

**Acceptance Criteria:**
✅ Measures execution time (wall-clock, per-phase)  
✅ Estimates token usage  
✅ Captures decision latency  
✅ Generates summaries

**Verification:**
```bash
tools/metrics-collector.sh report wave-7 | grep -q "execution_time_ms"
```

**Token Budget:** 8K + 25K = 33K

---

#### Task T10.3: Performance Metrics — Integration & Fixtures

**Objective:** Update altitude-report to show metrics; smoke test

**Dependencies:** T10.1, T10.2 complete

**Deliverables:**
- Update `agents/altitude-report.agent.md` (+15 lines: metrics section in reports)
- `test/fixtures/harness-v3/wave-10-metrics-smoke.fixture.md` (2 scenarios: collect, report)

**Acceptance Criteria:**
✅ altitude-report includes metrics section  
✅ Fixture scenario 1 (collect metrics) works  
✅ Fixture scenario 2 (generate report) works

**Verification:**
```bash
bash test/fixtures/harness-v3/wave-10-metrics-smoke.fixture.md
```

**Token Budget:** 15K

---

### Block 2: Waves 11-14 (State Machine + Orchestration)

#### Task T11.1: State Machine Formalization — Contract & Design

**Objective:** FSM definition, transitions, deadlock detection

**Dependencies:** T7.1 complete

**Deliverables:**
- `.specs/shared/state-machine-contract.md` (FSM graph, allowed transitions, invariants)
- `.specs/changes/waves-7-17-implementation/wave-11/DESIGN.md`

**Acceptance Criteria:**
✅ FSM states defined (Intent, Structure, Design, Execution, Validate, Ship)  
✅ Transitions documented (each state → next valid states)  
✅ Invariants specified (no backward jumps, no self-loops)  
✅ Deadlock conditions identified

**Verification:**
```bash
grep -q "states:" .specs/shared/state-machine-contract.md
grep -q "transitions:" .specs/shared/state-machine-contract.md
```

**Token Budget:** 12K

---

#### Task T11.2: State Machine Formalization — Tool Implementation

**Objective:** state-validator.sh for FSM validation

**Dependencies:** T11.1 complete

**Deliverables:**
- `tools/state-validator.sh` (validate transitions, detect deadlocks)
- `tools/state-validator.contract.md`

**Commands:**
- `state-validator.sh validate <current> <next>` → OK or blocked
- `state-validator.sh deadlock-check --trace <file>` → deadlock analysis

**Acceptance Criteria:**
✅ Validates all transitions  
✅ Blocks invalid moves  
✅ Detects potential deadlocks  
✅ Returns actionable error messages

**Verification:**
```bash
tools/state-validator.sh validate Intent Structure
echo $? # Should be 0 (valid)

tools/state-validator.sh validate Ship Intent
echo $? # Should be non-zero (invalid)
```

**Token Budget:** 40K

---

#### Task T11.3: State Machine Formalization — Integration & Fixtures

**Objective:** Update altitude-plan; smoke test FSM

**Dependencies:** T11.1, T11.2 complete

**Deliverables:**
- Update `agents/altitude-plan.agent.md` (+25 lines: state transition gates)
- `test/fixtures/harness-v3/wave-11-state-machine-smoke.fixture.md` (3 scenarios: valid, invalid, deadlock)

**Acceptance Criteria:**
✅ altitude-plan enforces state transitions  
✅ Fixture scenario 1 (valid sequence) passes  
✅ Fixture scenario 2 (invalid move) blocked  
✅ Fixture scenario 3 (deadlock detection) works

**Verification:**
```bash
bash test/fixtures/harness-v3/wave-11-state-machine-smoke.fixture.md
```

**Token Budget:** 25K

---

#### Task T12.1 & T12.2: Error Recovery — Contract + Tool

**Objective:** Recovery strategies, state snapshots, rollback API

**Dependencies:** T11.1 complete

**Deliverables:**
- `.specs/shared/recovery-contract.md` (snapshot schema, rollback strategies)
- `tools/recovery-manager.sh` (snapshot, rollback, validate)
- `tools/recovery-manager.contract.md`

**Commands:**
- `recovery-manager.sh snapshot --state <json>` → save checkpoint
- `recovery-manager.sh rollback --to <snapshot-id>` → restore

**Acceptance Criteria:**
✅ Snapshots are atomic  
✅ Rollback restores state exactly  
✅ No data loss on recovery  
✅ Snapshot IDs are verifiable

**Verification:**
```bash
SNAP=$(tools/recovery-manager.sh snapshot --state '{"phase":"Design"}')
tools/recovery-manager.sh rollback --to $SNAP
```

**Token Budget:** 10K + 30K = 40K

---

#### Task T12.3: Error Recovery — Integration & Fixtures

**Objective:** Update altitude-execution recovery; smoke test

**Dependencies:** T12.1, T12.2 complete

**Deliverables:**
- Update `agents/altitude-execution.agent.md` (+20 lines: rollback on failure)
- `test/fixtures/harness-v3/wave-12-recovery-smoke.fixture.md` (2 scenarios: snapshot, rollback)

**Acceptance Criteria:**
✅ altitude-execution creates snapshot before risky operations  
✅ Fixture scenario 1 (snapshot) works  
✅ Fixture scenario 2 (rollback) restores state

**Verification:**
```bash
bash test/fixtures/harness-v3/wave-12-recovery-smoke.fixture.md
```

**Token Budget:** 20K

---

#### Task T13.1 & T13.2: Wave Orchestration — Contract + Tool

**Objective:** Wave DAG, scheduling, multi-wave execution

**Dependencies:** T11.1, T11.2 complete

**Deliverables:**
- `.specs/shared/orchestration-contract.md` (wave DAG, scheduling semantics)
- `tools/wave-scheduler.sh` (schedule, execute batches)
- `tools/wave-scheduler.contract.md`

**Commands:**
- `wave-scheduler.sh schedule <waves-file>` → compute execution order
- `wave-scheduler.sh execute --wave <N>` → run single wave

**Acceptance Criteria:**
✅ DAG computed correctly  
✅ Dependencies respected  
✅ Scheduling is deterministic  
✅ Execution order optimal

**Verification:**
```bash
tools/wave-scheduler.sh schedule .specs/changes/waves-7-17-implementation/wave-structure.yaml
```

**Token Budget:** 10K + 35K = 45K

---

#### Task T13.3: Wave Orchestration — Integration & Fixtures

**Objective:** NEW agent altitude-coordinator; smoke test

**Dependencies:** T13.1, T13.2 complete

**Deliverables:**
- NEW: `agents/altitude-coordinator.agent.md` (multi-wave orchestration)
- `test/fixtures/harness-v3/wave-13-orchestration-smoke.fixture.md` (2 scenarios: schedule, execute)

**Acceptance Criteria:**
✅ altitude-coordinator created  
✅ Schedules waves correctly  
✅ Fixture scenario 1 (schedule) works  
✅ Fixture scenario 2 (execute batch) works

**Verification:**
```bash
ls -la agents/altitude-coordinator.agent.md
bash test/fixtures/harness-v3/wave-13-orchestration-smoke.fixture.md
```

**Token Budget:** 25K

---

#### Task T14.1 & T14.2: Multi-Agent Communication — Contract + Tool

**Objective:** Agent message protocol, routing, acknowledgments

**Dependencies:** T7.1 complete

**Deliverables:**
- `.specs/shared/protocol-contract.md` (message formats, routing rules)
- `tools/agent-messenger.sh` (queue, deliver, acknowledge)
- `tools/agent-messenger.contract.md`

**Commands:**
- `agent-messenger.sh send --to <agent> --msg <json>` → enqueue
- `agent-messenger.sh ack --msg-id <id>` → acknowledge receipt

**Acceptance Criteria:**
✅ Messages routed correctly  
✅ Acknowledgments working  
✅ Queue persists across restarts  
✅ No message loss

**Verification:**
```bash
tools/agent-messenger.sh send --to altitude-execution --msg '{"cmd":"status"}'
tools/agent-messenger.sh list-queue | grep -q "altitude-execution"
```

**Token Budget:** 8K + 25K = 33K

---

#### Task T14.3: Multi-Agent Communication — Integration & Fixtures

**Objective:** Update agents to use protocol; smoke test

**Dependencies:** T14.1, T14.2 complete

**Deliverables:**
- Update `agents/altitude-*.agent.md` (+5 lines each × 4 agents)
- `test/fixtures/harness-v3/wave-14-protocols-smoke.fixture.md` (2 scenarios: message, ack)

**Acceptance Criteria:**
✅ Agents use agent-messenger protocol  
✅ Fixture scenario 1 (send message) works  
✅ Fixture scenario 2 (acknowledge) works

**Verification:**
```bash
bash test/fixtures/harness-v3/wave-14-protocols-smoke.fixture.md
```

**Token Budget:** 15K

---

### Block 3: Waves 15-17 (Meta-Validation + Hardening + Final)

#### Task T15.1 & T15.2: Cross-Validation Junta Audit — Contract + Tool

**Objective:** Meta-validate validators, detect biases in scoring

**Dependencies:** T7-T14 complete

**Deliverables:**
- `.specs/shared/meta-validation-contract.md` (junta audit rules)
- `tools/junta-auditor.sh` (audit scoring, detect biases)
- `tools/junta-auditor.contract.md`

**Commands:**
- `junta-auditor.sh audit --junta <junta-name>` → audit one junta
- `junta-auditor.sh audit-all` → audit all juntas
- `junta-auditor.sh bias-report` → summarize biases

**Acceptance Criteria:**
✅ Audits junta scoring logic  
✅ Detects scoring biases (systematic over/under-scoring)  
✅ Generates audit trail  
✅ Reports recommendations

**Verification:**
```bash
tools/junta-auditor.sh audit requirements
tools/junta-auditor.sh bias-report | grep -q "bias_score"
```

**Token Budget:** 10K + 30K = 40K

---

#### Task T15.3: Cross-Validation Junta Audit — Integration & Fixtures

**Objective:** Update altitude-validation; smoke test junta audit

**Dependencies:** T15.1, T15.2 complete

**Deliverables:**
- Update `agents/altitude-validation.agent.md` (+20 lines: junta meta-audit)
- `test/fixtures/harness-v3/wave-15-meta-validation-smoke.fixture.md` (2 scenarios: audit, bias)

**Acceptance Criteria:**
✅ altitude-validation calls junta-auditor before scoring  
✅ Fixture scenario 1 (audit junta) works  
✅ Fixture scenario 2 (detect bias) works

**Verification:**
```bash
bash test/fixtures/harness-v3/wave-15-meta-validation-smoke.fixture.md
```

**Token Budget:** 15K

---

#### Task T16.1 & T16.2: Production Hardening — Contract + Tool

**Objective:** Chaos testing, load testing, resilience patterns

**Dependencies:** T11-T14 complete

**Deliverables:**
- `.specs/shared/hardening-contract.md` (chaos patterns, load profiles)
- `tools/chaos-tester.sh` (inject failures, validate recovery)
- `tools/chaos-tester.contract.md`

**Commands:**
- `chaos-tester.sh load --threads <N>` → load test
- `chaos-tester.sh chaos --pattern <pattern>` → inject chaos
- `chaos-tester.sh report` → resilience summary

**Acceptance Criteria:**
✅ Handles concurrent requests  
✅ Recovers from injected failures  
✅ Performance degrades gracefully  
✅ No data corruption under stress

**Verification:**
```bash
tools/chaos-tester.sh load --threads 5
tools/chaos-tester.sh chaos --pattern state-flip
```

**Token Budget:** 10K + 35K = 45K

---

#### Task T16.3: Production Hardening — Integration & Fixtures

**Objective:** Update altitude-report; smoke test hardening

**Dependencies:** T16.1, T16.2 complete

**Deliverables:**
- Update `agents/altitude-report.agent.md` (+15 lines: hardening section)
- `test/fixtures/harness-v3/wave-16-hardening-smoke.fixture.md` (2 scenarios: load, chaos)

**Acceptance Criteria:**
✅ altitude-report includes hardening metrics  
✅ Fixture scenario 1 (load test) passes  
✅ Fixture scenario 2 (chaos test) passes

**Verification:**
```bash
bash test/fixtures/harness-v3/wave-16-hardening-smoke.fixture.md
```

**Token Budget:** 20K

---

#### Task T17.1 & T17.2: Final Validation — Contract + Tool

**Objective:** Final acceptance gate, completion checklist

**Dependencies:** T7-T16 complete

**Deliverables:**
- `.specs/shared/final-validation-contract.md` (acceptance schema)
- `tools/acceptance-checker.sh` (final gate checks)
- `tools/acceptance-checker.contract.md`

**Commands:**
- `acceptance-checker.sh final-gate` → run all checks
- `acceptance-checker.sh checklist` → print checklist
- `acceptance-checker.sh ready-to-ship` → binary pass/fail

**Acceptance Criteria:**
✅ All 16 prior waves passing  
✅ All 33 tasks completed  
✅ All fixtures passing  
✅ No TODOs in code  
✅ Documentation complete

**Verification:**
```bash
tools/acceptance-checker.sh final-gate
tools/acceptance-checker.sh ready-to-ship
echo $? # Should be 0
```

**Token Budget:** 12K + 40K = 52K

---

#### Task T17.3: Final Validation — Integration & Documentation

**Objective:** Update AGENTS.md, README, docs; ship gate

**Dependencies:** T17.1, T17.2 complete

**Deliverables:**
- Update `AGENTS.md` (sections 21.7-21.17 for new tools)
- Update `README.md` (Wave 7-17 summary, roadmap)
- Create `docs/HARNESS_V3_WAVES_7-17_ROADMAP.md`
- Update `.specs/changes/waves-7-17-implementation/state.md` (completion)
- `test/fixtures/harness-v3/wave-17-final-validation-smoke.fixture.md` (2 scenarios: gate, ship)

**Acceptance Criteria:**
✅ AGENTS.md updated with all tool references  
✅ README.md updated with Wave 7-17  
✅ Roadmap doc created  
✅ Fixture scenario 1 (gate passes) works  
✅ Fixture scenario 2 (ready to ship) works  
✅ No broken links in docs

**Verification:**
```bash
grep -q "21.7\|21.8\|21.9\|21.10" AGENTS.md
bash test/fixtures/harness-v3/wave-17-final-validation-smoke.fixture.md
```

**Token Budget:** 20K

---

## 3. PR Strategy (3 PRs by Block)

### PR-7 (Waves 7-10): Foundation Layer

**Title:** Wave 7-10: Ralph Loop Verification, KB Quality, Security, Metrics

**Contains:**
- Tasks T7.1-T7.3, T8.1-T8.3, T9.1-T9.3, T10.1-T10.3
- 12 new files (4 contracts, 4 tools, 4 fixtures)
- Agent updates: altitude-execution (+60 lines), altitude-structure (+20 lines), altitude-report (+15 lines)

**Merge Criteria:**
- All 12 tasks passing
- All 4 fixtures passing
- No breaking changes

---

### PR-8 (Waves 11-14): State + Orchestration Layer

**Title:** Wave 11-14: State Machine, Recovery, Orchestration, Protocols

**Contains:**
- Tasks T11.1-T11.3, T12.1-T12.3, T13.1-T13.3, T14.1-T14.3
- 12 new files (4 contracts, 4 tools, 4 fixtures)
- Agent updates: altitude-plan, altitude-execution, NEW altitude-coordinator
- NEW agent: altitude-coordinator.agent.md

**Merge Criteria:**
- Depends on PR-7 merged
- All 12 tasks passing
- All 4 fixtures passing

---

### PR-9 (Waves 15-17): Validation + Finalization Layer

**Title:** Wave 15-17: Meta-Validation, Hardening, Final Validation

**Contains:**
- Tasks T15.1-T15.3, T16.1-T16.3, T17.1-T17.3
- 9 new files (3 contracts, 3 tools, 3 fixtures)
- Agent updates: altitude-validation, altitude-report, altitude-memory
- Documentation updates: AGENTS.md, README.md, new roadmap doc

**Merge Criteria:**
- Depends on PR-8 merged
- All 9 tasks passing
- All 3 fixtures passing
- Documentation complete
- Ready to ship

---

## 4. Execution Order (Respecting Task Dependencies)

**Sequential (Critical Path):**
1. **T7.1** → T7.2 → T7.3 (Ralph Loop foundation)
2. **Parallel after T7.3:**
   - T8.1 → T8.2 → T8.3 (KB indexing)
   - T9.1 → T9.2 → T9.3 (Security)
   - T10.1 → T10.2 → T10.3 (Metrics)
   - T14.1 → T14.2 → T14.3 (Protocols)
3. **After Wave 10 complete:** T11.1 → T11.2 → T11.3 (State Machine)
4. **Parallel after T11.3:**
   - T12.1 → T12.2 → T12.3 (Recovery)
   - T13.1 → T13.2 → T13.3 (Orchestration)
5. **After Waves 11-13 complete:** T16.1 → T16.2 → T16.3 (Hardening)
6. **After all waves:** T15.1 → T15.2 → T15.3 (Meta-Validation audit)
7. **Finally:** T17.1 → T17.2 → T17.3 (Ship gate + docs)

---

## 5. Global & Local Allocation

### Global Allocation

**Owner:** Altitude Coordinator  
**Scope:** All 33 tasks across 11 waves

**Allowed Files:**
- `.specs/shared/` (11 contracts)
- `tools/` (11 shell scripts + 11 contracts = 22 files)
- `agents/` (8 existing agents + 1 new coordinator = 9 agents, updates only)
- `test/fixtures/harness-v3/` (11 fixture files)
- `.specs/changes/waves-7-17-implementation/` (design docs, state.md, ledger.md)
- `README.md` (update Wave 7-17 section)
- `AGENTS.md` (add sections 21.7-21.17)
- `docs/HARNESS_V3_WAVES_7-17_ROADMAP.md` (new)

**Forbidden:**
- Source application code
- Waves 0-6 files
- `.specs/archive/`
- External integrations

### Local Allocation Template (Per Task)

```yaml
task_id: T<wave>.<subtask>
wave: <N>
subtask: <contract|tool|integration>
token_budget: <X>K
allocated_owner: altitude-execution agent
allowed_files:
  - .specs/shared/
  - tools/
  - agents/
  - test/fixtures/harness-v3/
  - .specs/changes/waves-7-17-implementation/
forbidden_files: (as per global)
parent_change: waves-7-17-implementation
parent_phase: execution
```

---

## 6. Sign-Off Gate

**Design/Plan Phase Complete?**

Confirm:

- [ ] **33 tasks** defined (11 waves × 3 tasks/wave)?
- [ ] **Task decomposition** clear (contract → tool → integration)?
- [ ] **Token allocation** realistic (~694K total)?
- [ ] **PR strategy** sensible (3 PRs by block)?
- [ ] **Dependencies** respected (T7 first, T15-T17 last)?
- [ ] **Smoke test strategy** lightweight (2-3 scenarios/task)?
- [ ] **Acceptance criteria** testable (bash commands)?
- [ ] **Ready for Execution Phase** (T7.1 first)?

**Answer YES to proceed to Execution Phase or ask clarifications.**
