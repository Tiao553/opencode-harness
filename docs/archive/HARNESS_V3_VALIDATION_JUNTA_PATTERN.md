# Harness V3 Validation Junta Pattern

> **Purpose:** Deterministic, multi-junta feature-level validation using frozen evidence packs and council narrative guidance
> **Scope:** Altitude Validation agent orchestration for Validate phase
> **Wave:** 3 (Unified Artifact Validation via Juntas)

---

## Overview

The **Junta Pattern** is a validation approach that:

1. **Freezes evidence** — makes an immutable snapshot of all artifacts before validation starts
2. **Launches 4 specialized juntas in parallel/sequential order** — each examines one dimension (requirements, architecture, tests, tasks)
3. **Computes deterministic scores** — pure arithmetic, no LLM in scoring
4. **Runs council narrative** — diagnoses root causes and suggests remediation (WITHOUT modifying scores)
5. **Renders final artifacts** — produces VALIDATION_REPORT, REMEDIATION_PLAN, or SHIP_READINESS

This pattern ensures:
- ✅ **Reproducibility** — frozen pack ensures all juntas see identical input
- ✅ **Transparency** — each junta's findings and scores are saved as JSON
- ✅ **Determinism** — scoring is arithmetic, not ML-based or subjective
- ✅ **Separation of concerns** — juntas examine different dimensions; council doesn't override scores

---

## When to Use

Use the junta pattern when:
- A feature has completed Execution phase (all tasks done, evidence collected)
- You need a quality gate before production Ship
- You want to know if the feature meets requirements, architecture, tests, and task standards

Trigger: `altitude-validation` agent with validation request.

---

## The 5 Phases

### Phase 0: Evidence Freeze

**What happens:**
1. Reads PRD, ADR, TEST-SPEC, all task-specs, execution ledger
2. Creates immutable snapshot (evidence pack) with timestamp and checksums
3. All 4 juntas receive IDENTICAL copies

**Why:** Prevents data drift during validation (e.g., someone modifies a task-spec while testing is underway).

**Artifacts:**
- `.specs/changes/{change-id}/validation/_FROZEN_AT.json` — timestamp, hashes

---

### Phase 1: Parallel Juntas (Requirements + Architecture)

**What happens:**
- **Requirements Junta** reads PRD + task-specs + execution ledger
  - Asks: "Are requirements traced to tasks and validated?"
  - Scores: coverage, acceptance-criteria match, traceability
  - Output: `01_REQUIREMENTS_REPORT.json`

- **Architecture Junta** reads ADR + task-specs + execution ledger
  - Asks: "Does implementation follow ADR decisions?"
  - Scores: fidelity, design-pattern consistency, allocation respect
  - Output: `02_ARCHITECTURE_REPORT.json`

**Why parallel:** Both are independent; no need to wait.

**Artifacts:**
```json
{
  "junta": "requirements",
  "avg_score": 85,
  "findings": [
    { "status": "COVERED", "severity": "LOW" },
    { "status": "PARTIAL", "severity": "MEDIUM" }
  ]
}
```

---

### Phase 2: Sequential Juntas (Tests → Tasks)

**What happens:**
- **Tests Junta** reads TEST-SPEC + execution ledger (+ parallel junta outputs for context)
  - Asks: "Are all test cases executed with strong assertions?"
  - Scores: test-case coverage, assertion quality, regression coverage
  - Output: `03_TESTS_REPORT.json`

- **Tasks Junta** reads task-specs + execution ledger (+ all prior junta outputs)
  - Asks: "Are tasks complete, properly scoped, and sequenced?"
  - Scores: completeness, scope adherence, relationships, execution order
  - Output: `04_TASKS_REPORT.json`

**Why sequential:** Tasks junta can use findings from earlier juntas to assess impact.

---

### Phase 3: Deterministic Scoring

**What happens:**

All scores are computed IN-AGENT via pure arithmetic:

```
requirements_score = (coverage + criteria_match + traceability) / 3
architecture_score = (fidelity + patterns + allocation) / 3
tests_score = (coverage + assertion_quality + regression) / 3
tasks_score = (completeness + scope + relationships + ordering) / 4

overall_score = requirements_score × 0.30
              + architecture_score × 0.25
              + tests_score × 0.20
              + tasks_score × 0.15
              + (council context) × 0.10

critical_count = count of CRITICAL findings across all juntas

readiness_status:
  PASSED   if score >= 90 AND critical_count == 0
  WARNING  if 70 <= score < 90 AND critical_count == 0
  FAILED   if score < 70 OR critical_count > 0

ship_eligible = (score >= 90 AND critical_count == 0)
```

**Why arithmetic?**
- Reproducible (same input → same score every time)
- Auditable (easy to verify the math)
- No LLM hallucination risk

**Artifacts:**
- `.specs/changes/{change-id}/validation/05_SCORING.json` — score, weights, status, eligibility flags

---

### Phase 4: Council Narrative

**What happens:**

Council reads all 4 junta reports + scoring JSON and provides:

1. **Root cause analysis** — "Why did this fail?" (not just "what failed")
2. **Remediation strategy** — "Here are the tasks to fix it"
3. **Execution sequence** — "Do A+B in parallel, then C, then validate again"
4. **Production readiness verdict** — "Ready for Ship / Needs remediation / Blocked"

**CRITICAL CONSTRAINT:** Council MUST NOT:
- ❌ Modify scores
- ❌ Override status (PASSED/WARNING/FAILED)
- ❌ Declare something "PASSED" if score says it's not eligible

**What council CAN do:**
- ✅ Explain scores in business context
- ✅ Diagnose root causes (e.g., "test gap because task scope didn't include edge case")
- ✅ Suggest specific remediation tasks (e.g., "add TEST-SPEC case for X, run task Y again")
- ✅ Recommend validation retry after fixes

**Artifacts:**
- `.specs/changes/{change-id}/validation/06_COUNCIL_VERDICT.json` — diagnosis + remediation + verdict

---

### Phase 5: Rendering

**What happens:**

Generate final markdown reports:

| Artifact | When | Purpose |
|----------|------|---------|
| `VALIDATION_REPORT_{CHANGE}.md` | Always | Executive summary, findings, scores |
| `REMEDIATION_PLAN_{CHANGE}.md` | If score < 90 or critical_count > 0 | Council-provided remediation tasks |
| `SHIP_READINESS_{CHANGE}.md` | If ship_eligible | Approval-ready summary |

---

## Junta Dimensions Explained

### Requirements Junta (30% weight)

**Questions:**
1. Are all PRD requirements traced to task-specs?
2. Are all acceptance criteria executed and validated?
3. Is traceability bidirectional (PRD ↔ task-spec ↔ execution)?

**Scoring:**
- **Coverage (0-100):** % of PRD requirements found in task-specs with execution evidence
- **Criteria match (0-100):** % of acceptance criteria with concrete validation
- **Traceability (0-100):** Quality of the link chain (requirement → task → evidence)

**Pass:** coverage >= 90 AND criteria >= 90 AND traceability >= 90

---

### Architecture Junta (25% weight)

**Questions:**
1. Does implementation follow ADR decisions?
2. Are design patterns consistently applied?
3. Do tasks respect file allocation boundaries?

**Scoring:**
- **Fidelity (0-100):** Implementation matches ADR decisions
- **Pattern consistency (0-100):** Patterns used everywhere needed, no inconsistencies
- **Allocation respect (0-100):** Tasks stayed within allowed files, didn't violate forbidden scope

**Pass:** fidelity >= 90 AND patterns >= 90 AND allocation >= 90

---

### Tests Junta (20% weight)

**Questions:**
1. Is every TEST-SPEC test case executed?
2. Are assertions strong (not vague)?
3. Are regression scenarios tested?

**Scoring:**
- **Coverage (0-100):** % of test cases with execution evidence
- **Assertion quality (0-100):** Strength of assertions (specific, correct, edge cases)
- **Regression coverage (0-100):** % of regression scenarios passing

**Pass:** coverage >= 90 AND quality >= 85 AND regression >= 90

---

### Tasks Junta (15% weight)

**Questions:**
1. Is every task-spec complete (goal, acceptance, scope, verification)?
2. Did tasks stay within their allowed files?
3. Are dependencies documented and sequencing valid (no cycles)?
4. Is execution order logically sound?

**Scoring:**
- **Completeness (0-100):** % of tasks with all required fields
- **Scope adherence (0-100):** % of executed tasks that respected file boundaries
- **Relationships (0-100):** Dependencies documented correctly
- **Ordering (0-100):** Execution follows valid DAG (no cycles, proper dependencies)

**Pass:** completeness >= 90 AND scope >= 100 AND relationships >= 90 AND ordering >= 100

---

## Severity Levels

All junta findings are classified by severity:

| Severity | Impact | Action |
|----------|--------|--------|
| **CRITICAL** | Blocks production | Must be fixed before ship |
| **HIGH** | Significant gap | Should be fixed before ship |
| **MEDIUM** | Minor issue | Nice-to-have fix |
| **LOW** | Style/polish | Optional |

> **Any CRITICAL finding blocks ship, even if overall score >= 90.**

---

## Eligibility Matrix

| Score | CRITICAL | Status | Ship? | Artifact |
|-------|----------|--------|-------|----------|
| ≥ 90 | 0 | PASSED | ✅ Yes | SHIP_READINESS |
| 70-89 | 0 | WARNING | ❌ No | REMEDIATION_PLAN |
| < 70 | Any | FAILED | ❌ No | REMEDIATION_PLAN |
| Any | > 0 | FAILED | ❌ No | REMEDIATION_PLAN |

---

## Practical Example

### Scenario: Validating a "User Auth" Feature

**Phase 0 — Freeze:**
```
Artifacts read:
✓ PRD_USER_AUTH.md (5 requirements)
✓ ADR_AUTH_PATTERNS.md (JWT + OIDC decision)
✓ TEST_SPEC_AUTH.md (12 test cases)
✓ 6 task-specs (setup, implementation, integration, testing, docs, review)
✓ execution-ledger.md (6 tasks executed, all passed)

Evidence pack frozen at: 2026-06-29T10:15:00Z
```

**Phase 1 — Parallel:**
```
Requirements Junta:
- All 5 PRD requirements mapped to task-specs ✓
- All acceptance criteria validated ✓
- Score: 95 (PASSED)

Architecture Junta:
- JWT pattern used in 4/4 places ✓
- OIDC boundary respected ✓
- Score: 92 (PASSED)
```

**Phase 2 — Sequential:**
```
Tests Junta:
- 12/12 test cases executed ✓
- Assertions strong (cover happy path + edge cases) ✓
- Regression scenarios for token expiry ✓
- Score: 88 (WARNING — 1 assertion could be stronger)

Tasks Junta:
- All 6 tasks complete ✓
- Scope respected (no unauthorized file changes) ✓
- Dependencies correct ✓
- Execution order valid ✓
- Score: 94 (PASSED)
```

**Phase 3 — Scoring:**
```
requirements: 95 × 0.30 = 28.5
architecture: 92 × 0.25 = 23.0
tests: 88 × 0.20 = 17.6
tasks: 94 × 0.15 = 14.1
council: 10 × 0.10 = 1.0

OVERALL: 84.2 (PASSED if no CRITICAL, but WARNING level)
CRITICAL count: 0
Status: WARNING (score < 90 but no critical issues)
Ship eligible: ❌ No, needs score >= 90
```

**Phase 4 — Council:**
```
Root cause of 84.2 score:
- Tests assertion slightly weak on edge case (why?)
  → Execution was time-pressured; edge case not fully specified in TEST-SPEC

Remediation:
1. Enhance TEST-SPEC assertion for token-refresh edge case
2. Re-run test case in existing task-spec-05
3. Re-validate

Expected outcome: tests score → 92, overall → 86.5 (still WARNING)
Then probably need quick acceptance-criteria tweak.

Verdict: "Requires remediation: enhance test assertion and re-validate"
```

**Phase 5 — Rendering:**
```
Artifacts generated:
- VALIDATION_REPORT_USER_AUTH.md (executive summary, findings, scores)
- REMEDIATION_PLAN_USER_AUTH.md (council-provided tasks: fix test assertion)

Not generated:
- SHIP_READINESS_USER_AUTH.md (score < 90, not eligible)
```

---

## Recovery from Failed Validation

If score < 90 or CRITICAL findings exist:

1. **Read REMEDIATION_PLAN_{CHANGE}.md** — council suggests specific fixes
2. **Create remediation tasks** in task-specs or update existing ones
3. **Execute** → run the suggested tasks
4. **Update execution ledger** — add new evidence
5. **Re-validate** → run junta orchestration again (Phase 0-5)

The second validation run uses a NEW frozen evidence pack (timestamps differ).

---

## Files and Contracts

| Resource | Purpose |
|----------|---------|
| `.specs/shared/altitude-validation-juntas-contract.md` | Junta specs and scoring formula |
| `.specs/shared/artifact-taxonomy-and-tracking-contract.md` | Artifact types and generation registry |
| `.specs/shared/validation-evidence-pack-contract.md` | Freeze process and immutability rules |
| `agents/altitude-validation.agent.md` | Orchestration orchestrator (Phase 0-5) |
| `skills/workflow-commands/references/harness-*-junta.md` | Individual junta prompts (requirements/architecture/tests/tasks/council) |

---

## Key Principles

1. **Evidence is frozen** — All juntas see identical input. If artifacts change, create a NEW validation run.
2. **Scores are deterministic** — Same input always produces same output. No randomness.
3. **Council diagnoses, doesn't override** — Council suggests fixes, doesn't rewrite scores.
4. **Severity matters** — One CRITICAL finding blocks ship, even if overall score is 95.
5. **Traceability is king** — Requirements → tasks → execution → validation → ship readiness.

---

## Troubleshooting

### Junta returns invalid JSON

**Problem:** Junta output can't be parsed.

**Recovery:**
1. Orchestrator retries once with explicit instruction
2. If still invalid, mark that dimension as 0
3. Add CRITICAL finding: "Junta validation failed"
4. Continue to council and remediation plan

### Score is lower than expected

**Problem:** Requirements junta says only 70% coverage, but you think all requirements are there.

**Root cause diagnosis:**
- Requirement is in PRD but not in any task-spec
- Requirement is in task-spec but no execution evidence collected
- Execution evidence exists but junta couldn't find it (vague naming)

**Fix:** Create a task to map the missing requirement explicitly.

### Council says "MUST NOT change score" but I disagree

**Correct response:**
Council's constraint is intentional. If score should be different, remediate the underlying dimension (requirements/architecture/tests/tasks) and re-validate.

Example:
- Junta says tests score = 75 (bad)
- Council says score MUST NOT change
- You should: fix the test gap, re-run tests, re-validate (tests score should go up)

---

## Next Steps

After validation completes:

**If PASSED (score >= 90, critical_count == 0):**
→ Ship gate is cleared. Create SHIP_READINESS artifact. Proceed to shipping.

**If WARNING (70 <= score < 90, critical_count == 0):**
→ Read REMEDIATION_PLAN. Execute suggested tasks. Re-validate.

**If FAILED (score < 70 OR critical_count > 0):**
→ Read REMEDIATION_PLAN. Major gap identified. Execute tasks. Re-validate.

---

## Related Documentation

- `AGENTS.md` — Harness V3 operating model and coordinators
- `HARNESS_V3_PHASE_ENGINE_SPEC.md` — Phase model and transitions
- `HARNESS_V3_TASK_SPEC_INTEGRATION.md` — Task decomposition
- `HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md` — Artifact types
