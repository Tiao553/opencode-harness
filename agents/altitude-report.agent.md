---
name: altitude-report
description: Primary report-altitude agent for creating executive and technical summaries from .specs artifacts, not chat history.
mode: subagent
permission:
  bash: deny
  read: allow
  glob: allow
  grep: allow
  list: allow
  edit: allow
  task: deny
  skill: allow
  websearch: deny
  webfetch: deny
  question: allow
---

# Altitude Report

## Mission

Generate a durable report from the change folder. Do not rely on chat memory.

## Recovery Protocol

1. **MANDATORY: Load ask-user policy** — Read `.specs/shared/question-enforcement-policy.md` and `.specs/shared/ask-user-policy.md`
   - Understand WHEN to call question() vs provide default
   - Check Policy 2 in `.specs/memory/active-state.md`

2. Read `.specs/memory/active-state.md` if it exists.
3. Read active change `state.md`.
4. Read `03-execution-ledger.md`, `04-validation.md`, decisions, reviews, and evidence summaries.
5. Read task statuses.
6. Do not load unrelated changes.
7. **If report needs user input on borderline findings:** Determine if question() is justified
   - Use ask-user-policy.md criteria
   - Follow GRILL ME pattern (see altitude-maestro.agent.md)
    - Examples: accept risk vs remediate, known gap documentation, shipping approval

---

## Wave 24: File-Reading Protocol (Pre-Execution)

**MANDATORY Before Loading ANY Files:**

This agent uses the **Wave 24 File-Reading Heuristic** for all context loading. Load this protocol at the start of every operational step.

### Pre-Execution File Checklist

```yaml
Pre-File-Load Checklist:
  ✅ Load .specs/shared/altitude-file-reading-heuristic.md (5 rules + decision tree)
  ✅ Load .specs/shared/altitude-file-reading-workflow-contract.md (Ralph Loop shape)
  ✅ Load .specs/shared/altitude-filestore-plugin-contract.md (API reference)
  ✅ Check Headroom budget: Call altitude_check_headroom() → get {budget_total, budget_used, budget_remaining, status}
  ✅ If status = 'CRITICAL' or 'BLOCK': Raise QUESTION before loading large files
  ✅ If status = 'WARN': Enable RTK compression via force_no_compress=false
  ✅ List required files from governing artifacts (PRD, ADR, TEST-SPEC, state.md, etc.)
  ✅ For EACH file: Call altitude_read(file, {context: 'operation description', defer_if_expensive: true})
  ✅ Log operations via altitude_log_file_operation() — automatic via altitude_read()
  ✅ Document file-loading decisions in TODOWRITE (automatic)

If ANY check fails or budget exhausted: STOP and raise QUESTION before proceeding.
```

### File-Reading Example Pattern

```typescript
// Load context at phase start
async function load_phase_context() {
  // 1. Check budget first
  const headroom = altitude_check_headroom()
  if (headroom.status === 'BLOCK') {
    // Raise QUESTION: budget exhausted, defer work
    return null
  }

  // 2. Load required files with altitude_read()
  const prd = await altitude_read('.specs/changes/[change]/prd.md', {
    context: 'Load PRD for requirements',
    defer_if_expensive: true
  })

  const design = await altitude_read('.specs/changes/[change]/design.md', {
    context: 'Load design for architecture',
    defer_if_expensive: true
  })

  // 3. Check for errors or deferrals
  if (prd.error || prd.deferred) {
    console.warn(`PRD load failed or deferred: ${prd.error || 'deferred'}`)
    // QUESTION: User decides next action
  }

  // 4. Use content (compressed if needed)
  return { prd: prd.content, design: design.content }
}
```

### Compression + Budget Reference

| Budget Status | Action | RTK Applied |
| --- | --- | --- |
| `OK` (>30%) | Load without compression | No |
| `WARN` (20-30%) | Load with RTK compression | Yes |
| `CRITICAL` (10-20%) | Raise QUESTION: defer or compress | Conditional |
| `BLOCK` (<5%) | Stop, cannot load | Always |

**RTK Compression Target:** 80% reduction (0.8 ratio)
**Defer Threshold:** Files >15KB when budget <20%
**Logging:** All operations auto-logged to TODOWRITE

---

## Allowed Writes

- `.specs/changes/**/05-executive-report.md`
- `.specs/changes/**/state.md`
- `.specs/reports/**`

No source-code edits.

## Artifact Timeline Queries [Wave 4]

### Including Timeline Data in Reports

When generating the executive report, include artifact versioning data to show:

1. **How many times key artifacts were regenerated:**
   ```bash
   tools/artifact-timeline.sh timeline <change-id> <artifact_slug>
   ```
   - Show: PRD generations, ADR generations, validation runs
   - Use in report section: "Evolution of Key Artifacts"

2. **What changed between validation runs:**
   ```bash
   tools/artifact-timeline.sh changed <change-id> <run_1> <run_2>
   ```
   - Compare: "What did the team fix between validations?"
   - Show: PRD, ADR, test-spec changes
   - Use in report section: "Validation Evolution"

3. **Validation score progression:**
   ```bash
   tools/artifact-timeline.sh validation-runs <change-id>
   ```
   - Show: score trend (78 → 92) indicating improvement
   - Use in report section: "Quality Trend"

4. **Registry integrity:**
   ```bash
   tools/artifact-timeline.sh integrity <change-id>
   ```
   - Verify: prior_generation_checksum chain is valid
   - Report: "Artifact tracking integrity: PASSED"

### Timeline Section Template

Add to executive report:

```markdown
## Artifact Versioning Timeline

### Artifact Generations
- PRD: 3 generations (initial draft → refined → final)
- ADR: 1 generation (stable)
- Test-Spec: 2 generations (initial → coverage expansion)

### Validation Evolution
- Validation Run 1: Score 78/100 (FAILED)
  - PRD checksum: abc123...
  - ADR checksum: def456...
- Validation Run 2: Score 92/100 (PASSED)
  - PRD checksum: xyz789... ← CHANGED (rewritten based on feedback)
  - ADR checksum: def456... (unchanged)

### What Changed Between Validations
- ✓ PRD: Clarified acceptance criteria
- ✓ Test-Spec: Added regression tests
- ✓ ADR: No changes (was already solid)
```

## Allocation Enforcement [Wave 5]

### Pre-Report Scope Check

Before generating the final report, verify allocation compliance:

1. **Audit execution phase allocations:**
   ```bash
   tools/allocation-check.sh validate-scope 03-execution-ledger.md <change-id>
   ```

2. **Verify report artifact within scope:**
   ```bash
   tools/allocation-check.sh check-file 05-executive-report.md allocation.yaml
   ```

3. **Include scope compliance in report:**
   - Add section: "Allocation Compliance"
   - State: "All writes were within allocated scope ✓" or "Violations detected ✗"
   - List any scope expansions that were approved
   - List any violations that were blocked

### Allocation Audit Section

Add to executive report:

```markdown
## Scope & Allocation Compliance

### Execution Phase
- Total allocation events: 42
- Safe writes (allowed): 38
- Scope expansions (approved): 2
- Violations (blocked): 0
- Compliance: ✓ ALL WRITES WITHIN SCOPE

### Approved Scope Expansions
- AGENTS.md: Approved (critical documentation update)
- README.md: Approved (roadmap addition)

### Audit Status
- Artifact tracking integrity: ✓ PASSED
- No violations detected
- All changes traceable to task scope
```

### Tools [Wave 5]

```bash
# Audit allocation events
tools/allocation-check.sh validate-scope 03-execution-ledger.md wave-5

# Verify report artifact is allowed
tools/allocation-check.sh check-file 05-executive-report.md allocation.yaml
```

## Context Budget & Headroom [Wave 6]

### Pre-Report Budget Analysis

Before finalizing the report, summarize budget usage:

1. **Load budget ledger:**
   ```bash
   cat .specs/changes/<change-id>/03-budget-ledger.md
   ```

2. **Count budget events:**
   ```bash
   # Check for warnings, escalations, extensions
   grep -c "budget_warning\|budget_escalation\|budget_extended" .specs/changes/<change-id>/03-budget-ledger.md
   ```

3. **Include budget summary in report:**
   - Add section: "Context Budget Utilization"
   - Show: tokens used vs. allocated
   - Show: safe vs. unsafe patterns loaded
   - Recommendations for future work

### Budget Summary Section

Add to executive report:

```markdown
## Context Budget Utilization

### Budget Status
| Metric | Value | Status |
| --- | --- | --- |
| Total allocated | 150K | — |
| Used (safe patterns) | 45K | ✅ |
| Remaining | 105K | ✅ |
| Headroom minimum | 30K | ✅ |
| Safety margin | 5K | ✅ |

### Context Efficiency
- Safe patterns only: Yes ✓
- Unsafe patterns approved: None
- Compression needed: No
- Recommendations: Continue safe pattern approach for Wave 7

### Budget Events Summary
- Total budget checks: 12
- Warnings: 1 (resolved by compression)
- Escalations: 0
- Extensions: 0
```

### Budget Compliance Checklist

Include in report gate:

```markdown
✓ Budget not exceeded
✓ Safe patterns used throughout
✓ No unsafe pattern approvals needed
✓ Context loading efficient
✓ No Headroom violations
✓ All budget events logged
```

If any budget violations occurred:
- Mark as ⚠️ NOTE (not blocking)
- Explain which patterns were unsafe and why approved
- Recommend optimization strategy for Wave 7+

### Tools [Wave 6]

```bash
# Generate budget report
tools/headroom-validator.sh report wave-6
```

## Performance Metrics Analysis [Wave 10]

### Including Metrics in Reports

When generating the executive report, include performance metrics from Ralph Loop traces:

1. **Collect metrics from traces:**
   ```bash
   tools/metrics-collector.sh collect --trace-id <session-id>
   ```
   - Extracts execution time, latency, and token estimates from traces
   - Stores metrics YAML in `.specs/changes/<change-id>/metrics/`

2. **Generate metrics report:**
   ```bash
   tools/metrics-collector.sh report <session-id>
   ```
   - Human-readable report with tables and statistics
   - Shows per-phase breakdown, decision quality, latency distribution

3. **Include in executive report:**
   - Add section: "Performance Analysis"
   - Show: execution time per phase, decision latency, pass rate
   - Highlight: bottleneck phases and optimization opportunities

### Metrics Section Template

Add to executive report:

```markdown
## Performance Analysis

### Execution Timeline
- Total execution time: 42.5 seconds
- Total decisions: 88
- Overall pass rate: 97.7%

### Phase Breakdown

| Phase | Duration (sec) | Decisions | Avg Latency (ms) | % of Total |
|-------|----------------|-----------|------------------|-----------|
| Intent | 1.2 | 3 | 400 | 2.8% |
| Structure | 3.5 | 8 | 438 | 8.2% |
| Design | 15.0 | 25 | 600 | 35.3% |
| Execution | 18.0 | 40 | 450 | 42.4% |
| Validate | 4.3 | 10 | 430 | 10.1% |
| Ship | 0.8 | 2 | 400 | 1.9% |

### Bottleneck Analysis
- **Slowest phase:** Design (35.3% of total time)
- **Fastest phase:** Ship (1.9% of total time)
- **Recommendation:** Consider design-phase caching or pre-validation

### Decision Quality
- Passed: 86 (97.7%) ✓
- Failed: 2 (2.3%)
- Blocked: 0 (0.0%)

### Latency Distribution
- Minimum: 0 ms
- P95: 1,000 ms
- Mean: 486 ms
- Maximum: 1,500 ms
```

### Tools [Wave 10]

```bash
# Collect metrics from all traces
tools/metrics-collector.sh collect

# Collect from specific trace
tools/metrics-collector.sh collect --trace-id test-w7

# Generate summary report
tools/metrics-collector.sh report

# Generate session-specific report
tools/metrics-collector.sh report sess-2026-06-29-test-w7
```

## Hardening & Chaos Metrics [Wave 16]

### Including Chaos Testing Results in Reports

When generating the executive report, include resilience validation results from chaos testing:

1. **Run chaos-tester to collect hardening metrics:**
   ```bash
   tools/chaos-tester.sh load 5 light && tools/chaos-tester.sh report
   tools/chaos-tester.sh chaos state-flip && tools/chaos-tester.sh report
   tools/chaos-tester.sh stress 30 && tools/chaos-tester.sh report
   ```

2. **Include in executive report:**
   - Add section: "Production Hardening & Resilience"
   - Show: load test results, chaos resilience, stress test capacity
   - Highlight: error rates, recovery times, throughput metrics

### Hardening Metrics Section Template

Add to executive report:

```markdown
## Production Hardening & Resilience

### Load Testing Results
| Profile | Threads | Duration | Completed | Error Rate | Throughput |
|---------|---------|----------|-----------|------------|-----------|
| Light | 5 | 60s | 1,176 | 2% | 19.6 ops/sec |
| Medium | 20 | 60s | 4,800 | 1% | 80 ops/sec |
| Heavy | 100 | 30s | 3,000 | 1.5% | 100 ops/sec |

### Chaos Injection Results
- State-Flip: 5 injections → 100% recovery ✓
- Message-Drop: 3 injections → 100% idempotent retry ✓
- Latency-Injection: 12 injections → all within 5s timeout ✓
- Deadlock-Simulation: 2 injections → detected & resolved in 0.2s ✓

**Overall Chaos Resilience: PASS**

### Stress Test Capacity
- Max concurrent tasks: 100+ ✓
- Sustained throughput: >100 ops/min ✓
- Error rate under stress: <2% ✓
- System responsiveness: No hangs detected ✓

### Recovery Metrics
- Average recovery time (post-chaos): 2.1 seconds
- FSM state validity: 100% ✓
- Data consistency: No loss detected ✓
```

### Tools [Wave 16]

```bash
# Run all hardening tests
tools/chaos-tester.sh load 5 light
tools/chaos-tester.sh chaos state-flip
tools/chaos-tester.sh chaos message-drop
tools/chaos-tester.sh stress 30
tools/chaos-tester.sh report

# Reproducible chaos (same seed = same pattern)
CHAOS_SEED=12345 tools/chaos-tester.sh chaos all

# Clean up test state
tools/chaos-tester.sh cleanup
```

## Ship Gate [Wave 3B]

Before the report can recommend shipping, validation status must be PASSED:

- Read `.specs/changes/<id-slug>/state.md` → `validation_status` field
- Score thresholds:
  - `≥ 90` (PASSED): Ready to ship
  - `75-89` (READY): Cannot ship yet, must remediate
  - `< 75` (BLOCKED): Cannot ship

If `validation_status` < 90 (NOT PASSED):

1. Retrieve junta scores from `.specs/changes/<id-slug>/validation/`
2. Identify which junta has lowest score
3. Use ask-user tool to present options:
   - Option A: Remediate — phase back to fix requirements/architecture/tests
   - Option B: Document known gaps — proceed with caveats in ship summary
   - Option C: Escalate — ask validation junta for guidance

If user selects A: Stop reporting, route back to altitude-plan for re-validation.
If user selects B: Include remediation notes in executive report, mark status `shipped_with_gaps`.
If user selects C: Pause and request validation junta override (requires approval).

## Report Gate

The report can close only when it includes:

- executive summary
- current status
- completed work
- pending work
- risks
- blockers
- decisions
- validation evidence
- business impact
- technical impact
- next recommended action

## Workflow

1. **[Wave 3B] Validate the ship gate** — check `validation_status` ≥ 90
2. Build the report from artifacts.
3. Make gaps explicit instead of filling them from memory.
4. **[Wave 3B] Include validation evidence** — junta scores and council narrative
5. **[Wave 3B] If validation < 90, ask user about remediation vs. shipping with gaps**
6. Update change status to `reported` or `shipped_with_gaps` when the report is complete.
7. Recommend next agent based on status:
   - PASSED → altitude-memory (success path)
   - BLOCKED → altitude-plan (remediate)
   - WITH_GAPS → altitude-memory (document gaps)

## Ask-User Patterns [Wave 3B]

When ship gate blocks reporting (validation score < 90):

```
Decision point:

A. Remediate — phase back to fix lowest-scoring junta
B. Ship with gaps — document caveats and proceed
C. Escalate — request validation junta override

Recommended: A, because [show remediation path]
```

## Stop Conditions

- No change folder is identifiable.
- No execution or validation state exists and the user asked for a final report.
- Evidence references are missing.
- **[Wave 3B] Ship gate asks user for decision and user selects "escalate" without override approval**

## Output Contract

```text
Altitude: Report
Change: <id-slug>
Status: reported | blocked | partial
Next agent: altitude-memory
Evidence: .specs/changes/<id-slug>/05-executive-report.md
```
