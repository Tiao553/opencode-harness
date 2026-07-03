# Wave 25A: Allocation Consolidation — Execution Plan

**Status:** LOCKED FOR EXECUTION  
**Date:** 2026-07-03  
**Decision Checkpoint:** PASSED (All 5 decisions confirmed)  
**Ready to Execute:** YES

---

## DECISION LOCK

User confirmed all 5 critical decisions on 2026-07-03:

| Decision | Choice | Impact |
|----------|--------|--------|
| **Q1: Contract Consolidation** | Option B (6 contracts, ≤400 lines each) | Phase 2 scope: 6 target contracts, clearer boundaries |
| **Q2: Ledger Storage** | Extract to separate `allocation-ledger-contract.md` | Phase 2: New ledger contract, enforcement stays focused |
| **Q3: Todo Location** | Keep in enforcement + link to execution-loop | Phase 2: Cross-reference added, concerns linked but not coupled |
| **Q4: Tool Scope** | Batch operations + agent integration helpers | Phase 3: 5 new/enhanced commands, Python/Go agent helpers |
| **Q5: Load Test Target** | 1,000 tasks (conservative, start point) | Phase 4: Load tests run at 1k scale, scale up available later |

**All decisions are FINAL and drive Phase 1-4 execution.**

---

# PHASE 1: ANALYSIS & DECISION (T-01 to T-10)

## T-01: Contract Consolidation Analysis (4 hours)

**Owner:** Altitude (Strategic)  
**Depends:** None (unblocked)  
**Verification:** MANDATORY

### Deliverable

Single document (`WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md`) containing:

1. **Current State Inventory** (30 lines)
   - allocation-contract.md: 243 lines, what's covered
   - allocation-enforcement-and-ledger-contract.md: 846 lines, what's covered
   - specialist-allocation-contract.md: 100 lines, what's covered
   - tool-contract (allocation-check.sh): 301 lines, what's covered

2. **Redundancy Matrix** (20 lines)
   - Specialist allocation: defined 3x (C1: 30 lines, C2: 10 lines, C3: 100 lines) ← consolidate
   - Scope narrowing/broadening: 2x coverage (C1 principle, C2 algorithm) ← integrate
   - Required fields: scattered across C1/C3 ← consolidate
   - Todo rules: only in C2 ← move/link

3. **Option B Implementation Plan** (50 lines)
   - allocation-contract.md V2 (250 lines): Global/Local/Specialist + hierarchy
   - allocation-enforcement-contract.md (350 lines): Scope model + validation + escalation
   - allocation-ledger-contract.md (NEW, 200 lines): Event schema + queries
   - specialist-allocation-contract.md V2 (150 lines): Grounding bundle + evidence + lifecycle
   - todo-allocation-contract.md (NEW, 150 lines): Todo projection + verify + loop rules
   - allocation-check.contract.md V2 (400 lines): Tool specification (already exists, minor updates)

4. **File Structure Proposal** (20 lines)
   - Current: 3 files (1,189 lines) in `.specs/shared/`
   - Target: 6 files (1,400 lines) in `.specs/shared/` (organized as domain)
   - Consolidation math: +200 lines, but significantly clearer separation

5. **Risk Assessment** (20 lines)
   - Risk: Contract merge conflicts during edits → Mitigation: Clear ownership per file
   - Risk: Cross-reference breakage → Mitigation: Golden fixtures validate refs
   - Risk: Agent integration gaps → Mitigation: Integration tests in T-25

### Acceptance Criteria

- ✓ Document created and stored at `.specs/shared/WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md`
- ✓ Redundancy matrix shows all 3x/2x overlaps identified
- ✓ Option B plan includes exact line counts and structure
- ✓ Risk assessment lists 3+ risks with mitigations
- ✓ No unresolved questions (all settled by Q1-Q5 decisions)

### Verification

```bash
# Verify document exists
test -f .specs/shared/WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md && echo "✓ Document exists"

# Verify sections present
grep -q "Current State Inventory" WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md && echo "✓ Section 1"
grep -q "Redundancy Matrix" WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md && echo "✓ Section 2"
grep -q "Option B Implementation Plan" WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md && echo "✓ Section 3"
grep -q "File Structure Proposal" WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md && echo "✓ Section 4"
grep -q "Risk Assessment" WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md && echo "✓ Section 5"

# Verify line counts mentioned
grep "allocation-contract.md V2 (250 lines)" WAVE_25A_CONTRACT_CONSOLIDATION_ANALYSIS.md && echo "✓ Line counts specified"
```

### Evidence Required

- Document file
- Line counts documented
- Risk assessment captured

---

## T-02: Tool Requirements Audit (3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-01 (output drives scope)  
**Verification:** MANDATORY

### Deliverable

Document (`WAVE_25A_TOOL_REQUIREMENTS.md`) with:

1. **Current allocation-check.sh Assessment** (20 lines)
   - 4 working commands: check-file, check-pattern, expand-allocation, validate-scope
   - Performance: O(P + F), < 1ms typical
   - Coverage: 60% (enforcement OK, queries weak, integration missing)

2. **Required Commands (Decision Q4: Batch + Agent Integration)** (40 lines)
   - `validate-file`: Pre-write checks (MUST-HAVE, 2h)
   - `query-violations`: Violation filtering + export (MUST-HAVE, 2h)
   - `ledger-stats`: Compliance reporting (MUST-HAVE, 2h)
   - `allocation-snapshot`: Version baseline (SHOULD-HAVE, 1h)
   - `allocation-diff`: Scope comparison (SHOULD-HAVE, 1.5h)
   - Agent helpers: Python/Go SDK stubs (MUST-HAVE, 1h)

3. **Performance Targets** (15 lines)
   - Per-file pattern matching: < 10µs
   - Per-task allocation: < 2ms
   - Ledger query (1000 events): < 500ms
   - Batch operation (1000 tasks): < 2000ms

4. **Integration Points** (15 lines)
   - altitude-execution: calls validate-file before write
   - altitude-validation: calls ledger-stats for audit
   - Python agents: import allocation helpers
   - Load test framework: calls batch operations

5. **Effort Breakdown** (20 lines)
   - T-21: validate-scope enhancement (3h)
   - T-22: query-violations (3h)
   - T-23: ledger-stats (2h)
   - T-24: performance tests (4h)
   - T-25: agent integration (2h)
   - T-26: allocation-snapshot.sh (3h)
   - T-27: allocation-diff.sh (2h)
   - T-28: documentation (2h)
   - T-29: integration test (3h)
   - **Total Phase 3: 25h**

### Acceptance Criteria

- ✓ Document at `.specs/shared/WAVE_25A_TOOL_REQUIREMENTS.md`
- ✓ 5 commands specified with clear purpose/effort
- ✓ Performance targets measurable and testable
- ✓ Integration points mapped to 3+ agents
- ✓ Phase 3 effort total documented (25h)

### Verification

```bash
# Document exists and has required sections
test -f .specs/shared/WAVE_25A_TOOL_REQUIREMENTS.md || exit 1
grep -q "Required Commands" WAVE_25A_TOOL_REQUIREMENTS.md || exit 1
grep -q "validate-file" WAVE_25A_TOOL_REQUIREMENTS.md || exit 1
grep -q "agent helpers" WAVE_25A_TOOL_REQUIREMENTS.md || exit 1
echo "✓ All checks passed"
```

---

## T-03: Edge Case Inventory (3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-01 (allocation concepts)  
**Verification:** MANDATORY

### Deliverable

Document (`WAVE_25A_EDGE_CASES.md`) with:

1. **Critical Edge Cases (6, must-test)** (60 lines, 10 lines each)
   - E-01: Circular specialist delegation (A→B→C→A)
   - E-02: Scope violation approved, then violated again
   - E-03: File matches **both** allowed AND forbidden patterns
   - E-04: Specialist without grounding bundle
   - E-05: Specialist output violates scope
   - E-06: Scope narrowing breaks dependent tasks

2. **High-Risk Edge Cases (8)** (80 lines, 10 lines each)
   - E-07: Nested specialist delegation (depth > 3)
   - E-08: Concurrent writes to same file by different tasks
   - E-09: Scope expansion approved by user A, but violates user B's allocation
   - E-10: Pattern matching ambiguity (glob vs regex)
   - E-11: Ledger event reordering (out-of-order writes)
   - E-12: Todo without verify clause
   - E-13: Specialist invoked after task started (no grounding)
   - E-14: Task tries to narrow but parent is already narrow

3. **Medium-Risk Edge Cases (4)** (40 lines, 10 lines each)
   - E-15: Ledger corruption (missing events)
   - E-16: Rollback when specialist output violates scope
   - E-17: Cross-wave allocation conflicts
   - E-18: Empty allowed_files (default deny)

4. **Test Fixtures Required** (20 lines)
   - 6 critical fixtures (50-100 lines each) = 350 lines
   - 8 high-risk fixtures (30-50 lines each) = 300 lines
   - 4 medium-risk fixtures (20-30 lines each) = 100 lines
   - **Total fixtures: 750 lines, ~20 YAML files**

5. **Testing Strategy** (20 lines)
   - Unit tests: edge cases in isolation (T-31)
   - Integration tests: edge cases + ledger + agents (T-31-33)
   - Load tests: edge cases at 1000-task scale (T-32)
   - Regression tests: past violations don't recurr (T-34)

### Acceptance Criteria

- ✓ Document at `.specs/shared/WAVE_25A_EDGE_CASES.md`
- ✓ 18 edge cases classified (6 critical, 8 high, 4 medium)
- ✓ Each edge case has: description, impact, fixture outline, test scenario
- ✓ Fixture count and sizes estimated
- ✓ Testing strategy clear (unit/integration/load/regression)

### Verification

```bash
test -f .specs/shared/WAVE_25A_EDGE_CASES.md || exit 1
grep "E-01:" WAVE_25A_EDGE_CASES.md && echo "✓ Critical cases listed"
grep "E-07:" WAVE_25A_EDGE_CASES.md && echo "✓ High-risk cases listed"
grep "E-15:" WAVE_25A_EDGE_CASES.md && echo "✓ Medium-risk cases listed"
echo "✓ All checks passed"
```

---

## T-04: Current Tool Assessment (2 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-02 (requirements)  
**Verification:** MANDATORY

### Deliverable

Document (`WAVE_25A_TOOL_ASSESSMENT.md`) with:

1. **allocation-check.sh Current State** (40 lines)
   - 286 lines total
   - 4 commands implemented: check-file, check-pattern, expand-allocation, validate-scope
   - Bash + YAML-based
   - Performance profile documented

2. **Code Quality Assessment** (20 lines)
   - 4/5 error handling (mostly present)
   - 3/5 readability (YAML parsing complex)
   - 2/5 testability (no unit test harness)
   - Performance: unknown for 1000+ tasks

3. **Gap Analysis** (30 lines)
   - Missing: batch operations (each file checked individually)
   - Missing: violation filtering/export
   - Missing: performance benchmarks
   - Missing: agent integration (Python/Go helpers)
   - Missing: cross-file pattern matching optimization

4. **Reuse vs Rewrite Decision** (10 lines)
   - **Decision:** Extend existing tool (better than rewrite)
   - Rationale: 4 working commands, bash infrastructure OK, only need 5 new commands

5. **Migration Path** (10 lines)
   - No breaking changes planned
   - New commands added side-by-side
   - Old commands continue to work (backward compatibility)

### Acceptance Criteria

- ✓ Document at `.specs/shared/WAVE_25A_TOOL_ASSESSMENT.md`
- ✓ Current tool performance profiled (or explicitly noted as "needs T-05")
- ✓ All 5 gaps documented
- ✓ Reuse vs rewrite decision made (reuse confirmed)
- ✓ Backward compatibility confirmed

### Verification

```bash
# Verify tool exists and has working commands
test -f tools/allocation-check.sh || exit 1
bash tools/allocation-check.sh check-file --help >/dev/null 2>&1 && echo "✓ Tool functional"
grep -c "^.*validate-scope" tools/allocation-check.sh && echo "✓ Commands present"
```

---

## T-05: Performance Baseline Capture (2 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-04 (tool assessment)  
**Verification:** MANDATORY

### Deliverable

Document (`WAVE_25A_PERFORMANCE_BASELINE.md`) with:

1. **Baseline Metrics** (20 lines)
   - Single file check: measure time for check-file with 50-file allocation
   - Pattern matching: measure O(P + F) for various allocation sizes
   - Ledger query: measure query time for 100-event ledger
   - Scope expansion: measure expand-allocation algorithm time

2. **Test Fixtures** (20 lines)
   - Small allocation (10 files): baseline
   - Medium allocation (100 files): typical
   - Large allocation (500 files): stress
   - Huge allocation (1000 files): load test baseline

3. **Captured Metrics** (30 lines, format: metric | baseline | target)
   - Per-file pattern match | TBD | < 10µs
   - Per-task allocation check | TBD | < 2ms
   - Ledger query (100 events) | TBD | < 100ms
   - Scope expansion (50 files) | TBD | < 50ms
   - Batch operation (100 tasks) | TBD | < 200ms

4. **Performance Regression Alert** (10 lines)
   - If Phase 3 implementation exceeds baselines by >50%, escalate
   - If Phase 4 load tests fail performance targets, debug before ship

5. **Tooling** (5 lines)
   - Use bash time command for micro-benchmarks
   - CSV output for tracking over time
   - Regression check in T-24

### Acceptance Criteria

- ✓ Document at `.specs/shared/WAVE_25A_PERFORMANCE_BASELINE.md`
- ✓ At least 4 metrics measured and recorded
- ✓ Test fixtures created (4 sizes)
- ✓ Performance targets clear (table: metric | baseline | target)
- ✓ Regression alert criteria defined

### Verification

```bash
# Verify baseline document and test fixtures exist
test -f .specs/shared/WAVE_25A_PERFORMANCE_BASELINE.md || exit 1
# Verify metrics table present
grep "per-file pattern match" WAVE_25A_PERFORMANCE_BASELINE.md && echo "✓ Metrics captured"
echo "✓ All checks passed"
```

---

## T-06: Specialist Allocation Review (2 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-01 (context from contract analysis)  
**Verification:** MANDATORY

### Deliverable

Document (`WAVE_25A_SPECIALIST_ALLOCATION_REVIEW.md`) with:

1. **Current Specialist Definition** (30 lines)
   - What is "specialist" in allocation context?
   - Required fields: grounding bundle, reason, scope, evidence, stop condition
   - Lifecycle: allocation → grounding → delegation → output validation → evidence ledger

2. **Redundancy in Specialist Contracts** (20 lines)
   - allocation-contract.md: 30 lines on specialist
   - allocation-enforcement-contract.md: 10 lines on specialist
   - specialist-allocation-contract.md: 100 lines on specialist
   - Consolidation: merge definitions, keep specialist-contract focused on evidence & lifecycle

3. **New Specialist Concepts for Wave 25A** (30 lines)
   - Circular delegation prevention: detect A→B→C→A cycles
   - Grounding bundle size limits: max X lines, Y files
   - Evidence requirements: what must specialist output include
   - Specialist timeout: max time specialist can own a task

4. **Nested Specialist Delegation** (20 lines)
   - Current: Specialist allocated by Coordinator
   - New: Can specialist allocate sub-specialist?
   - Recommendation: Allow max depth 1 (A→B OK, A→B→C not allowed)
   - Enforcement: Track in ledger, reject depth > 1

5. **Integration with allocation-check.sh** (15 lines)
   - New command: `validate-specialist <allocation.yaml>`
   - Check: grounding bundle exists, non-circular, depth ≤ 1
   - Error messages: clear guidance if invalid

### Acceptance Criteria

- ✓ Document at `.specs/shared/WAVE_25A_SPECIALIST_ALLOCATION_REVIEW.md`
- ✓ Current definition documented (5+ required fields)
- ✓ Redundancy identified across 3 contracts
- ✓ New concepts proposed (circular prevention, grounding limits, evidence requirements)
- ✓ Nested delegation policy clear (max depth 1)

### Verification

```bash
test -f .specs/shared/WAVE_25A_SPECIALIST_ALLOCATION_REVIEW.md || exit 1
grep "Circular delegation prevention" WAVE_25A_SPECIALIST_ALLOCATION_REVIEW.md && echo "✓ Circular prevention documented"
grep "max depth 1" WAVE_25A_SPECIALIST_ALLOCATION_REVIEW.md && echo "✓ Nesting policy documented"
echo "✓ All checks passed"
```

---

## T-07: Testing Strategy Design (4 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-03 (edge cases), T-04 (tool assessment)  
**Verification:** MANDATORY

### Deliverable

Document (`WAVE_25A_TESTING_STRATEGY.md`) with:

1. **Integration Test Plan** (50 lines)
   - 4 scenario sets (16 total tests, 11 hours)
   - SET 1: Safe allocation path (4 tests)
     - T-INT-01: Safe narrowing (global → local)
     - T-INT-02: Safe write (file in allowed)
     - T-INT-03: File in forbidden (correctly rejected)
     - T-INT-04: Ledger events recorded
   - SET 2: Scope expansion (4 tests)
     - T-INT-05: Violation detected
     - T-INT-06: User approval granted
     - T-INT-07: Allocation expanded
     - T-INT-08: Write succeeds after expansion
   - SET 3: Specialist delegation (4 tests)
     - T-INT-09: Specialist allocated with grounding
     - T-INT-10: Specialist output validated
     - T-INT-11: Circular delegation rejected
     - T-INT-12: Ledger tracks specialist decision
   - SET 4: Ledger & audit (4 tests)
     - T-INT-13: 100 events query < 100ms
     - T-INT-14: Violation filtering works
     - T-INT-15: Ledger export JSON format
     - T-INT-16: Compliance report generated

2. **Load Test Plan** (40 lines, Decision Q5: 1000 tasks)
   - 4 load test suites (8 hours, 1000 concurrent)
   - Suite 1: 1000 task allocation assignments (< 2ms per task)
   - Suite 2: 10K files pattern matching (< 10µs per file)
   - Suite 3: 1000-event ledger queries (< 500ms audit)
   - Suite 4: 100 concurrent write conflicts (100% detection)

3. **Edge Case Test Matrix** (50 lines)
   - 18 edge cases mapped to test scenarios
   - E-01 → TEST-EDGE-01 (circular delegation)
   - E-02 → TEST-EDGE-02 (re-violation)
   - ... E-18 → TEST-EDGE-18 (empty allowed)

4. **Golden Fixtures** (30 lines)
   - 8 fixture files (~340 lines total)
   - 3 safe path fixtures (150 lines)
   - 3 violation fixtures (150 lines)
   - 2 load test fixtures (40 lines)

5. **Success Criteria** (20 lines)
   - Integration: 16/16 tests passing
   - Load: 1000+ tasks at < 2ms average
   - Edge cases: all 18 covered
   - Performance: all baselines met
   - Ledger: zero corruption

### Acceptance Criteria

- ✓ Document at `.specs/shared/WAVE_25A_TESTING_STRATEGY.md`
- ✓ 4 scenario sets with 16 total integration tests defined
- ✓ 4 load test suites with 1000-task target confirmed
- ✓ 18 edge cases mapped to test scenarios
- ✓ 8 golden fixtures outlined (lines estimated)
- ✓ Success criteria measurable (16/16, 1000 tasks, all baselines)

### Verification

```bash
test -f .specs/shared/WAVE_25A_TESTING_STRATEGY.md || exit 1
grep -c "T-INT-" WAVE_25A_TESTING_STRATEGY.md | grep -E "(16|17)" && echo "✓ 16 integration tests"
grep "1000" WAVE_25A_TESTING_STRATEGY.md && echo "✓ Load test target confirmed"
grep -c "E-" WAVE_25A_TESTING_STRATEGY.md | grep -E "(18|19|20)" && echo "✓ 18+ edge cases"
echo "✓ All checks passed"
```

---

## T-08: AGENTS.md Gap Audit (2 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-01 (allocation context)  
**Verification:** MANDATORY

### Deliverable

Document (`WAVE_25A_AGENTS_MD_GAPS.md`) with:

1. **Current AGENTS.md Coverage** (20 lines)
   - 286 lines total
   - Sections: operating model, coordinators, memory, state, activation gates, context loading, behavioral principles
   - Gap: No allocation section

2. **6 Missing Sections** (60 lines, 10 lines each)
   - **Gap 1:** No allocation execution checklist
     - Required: step-by-step checklist for agents to verify allocation before executing tasks
     - Target: 15 lines
   - **Gap 2:** No specialist allocation matrix
     - Required: when to allocate which specialist, required evidence
     - Target: 25 lines
   - **Gap 3:** No scope narrowing/broadening guide
     - Required: flowchart or decision tree for safe narrowing vs unsafe broadening
     - Target: 40 lines
   - **Gap 4:** No allocation-check.sh tool reference
     - Required: commands, examples, integration with agents
     - Target: 20 lines
   - **Gap 5:** No ledger query examples
     - Required: how to audit violations, export events, generate reports
     - Target: 20 lines
   - **Gap 6:** No escalation flow for scope expansion
     - Required: ask-user options (A/B/C), decision recording
     - Target: (merged into Gap 3)

3. **Proposed Updates** (30 lines)
   - Section: "# 15. Allocation Execution"
   - Subsections: execution checklist, specialist matrix, scope guide, tool reference, ledger queries, escalation

4. **Update Locations** (10 lines)
   - Line 270: Add new section after "Behavioral Principles" (line 286)
   - Link to shared contracts: allocation-contract.md, specialist-allocation-contract.md, allocation-check.contract.md
   - Cross-reference to this Wave 25A plan

5. **Effort Breakdown** (10 lines)
   - T-02: Draft checklist + matrix (1h)
   - T-08: Finalize all 6 sections (2h in T-08)
   - T-31 (optional): Update based on integration test discoveries (0.5h)

### Acceptance Criteria

- ✓ Document at `.specs/shared/WAVE_25A_AGENTS_MD_GAPS.md`
- ✓ 6 gaps identified with line count targets
- ✓ Proposed sections drafted (outline)
- ✓ Total effort: 120 lines, 6 hours
- ✓ Update locations and cross-references specified

### Verification

```bash
test -f .specs/shared/WAVE_25A_AGENTS_MD_GAPS.md || exit 1
grep -c "Gap [0-9]:" WAVE_25A_AGENTS_MD_GAPS.md && echo "✓ All 6 gaps documented"
grep "15 lines\|25 lines\|40 lines\|20 lines" WAVE_25A_AGENTS_MD_GAPS.md && echo "✓ Line targets specified"
echo "✓ All checks passed"
```

---

## T-09: Consolidation Decision Document (3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-01 through T-08 (all analysis complete)  
**Verification:** MANDATORY

### Deliverable

Single document (`WAVE_25A_CONSOLIDATION_DECISIONS.md`) synthesizing:

1. **Executive Summary** (10 lines)
   - Wave 25A consolidates allocation from 3→6 contracts (Option B)
   - All 5 decisions locked (Q1-Q5)
   - Ready for Phase 2 design & contract rewrite

2. **Decision Summary Table** (10 lines)
   - Q1 → Option B
   - Q2 → Extract ledger
   - Q3 → Keep + link
   - Q4 → Batch + agent helpers
   - Q5 → 1000 tasks

3. **Phase 2 Design Constraints** (20 lines)
   - allocation-contract.md: 250 lines (from 243)
   - allocation-enforcement-contract.md: 350 lines (split from 846)
   - allocation-ledger-contract.md: 200 lines (new)
   - specialist-allocation-contract.md: 150 lines (from 100, refined)
   - todo-allocation-contract.md: 150 lines (new, extracted)
   - allocation-check.contract.md: 400 lines (expanded tool spec)

4. **Critical Path for Phase 2** (15 lines)
   - T-11: allocation-contract.md V2 (6h)
   - T-12: allocation-enforcement-contract.md (5h)
   - Parallel: T-13 (specialist), T-15 (tool spec), T-16/T-17 (fixtures)
   - Gate: T-20 (user approval)

5. **Risk Mitigation** (15 lines)
   - Cross-reference validation: golden fixtures verify refs don't break
   - Performance regression: baselines captured, Phase 3 validates
   - Agent integration: integration tests in T-25
   - Contract divergence: clear ownership per file

6. **Next Immediate Actions** (10 lines)
   - Phase 1 sign-off (this document)
   - Phase 2 ready to start (all constraints known)
   - T-10 gate: User approval (if needed)
   - T-11: Begin contract rewrites

### Acceptance Criteria

- ✓ Document at `.specs/shared/WAVE_25A_CONSOLIDATION_DECISIONS.md`
- ✓ All 5 decisions restated with rationale
- ✓ Phase 2 constraints (file counts, line targets) locked
- ✓ Critical path clear (T-11 through T-20)
- ✓ Risk mitigations listed
- ✓ Next actions explicit

### Verification

```bash
test -f .specs/shared/WAVE_25A_CONSOLIDATION_DECISIONS.md || exit 1
grep "Option B" WAVE_25A_CONSOLIDATION_DECISIONS.md && echo "✓ Q1 decision confirmed"
grep "Extract ledger" WAVE_25A_CONSOLIDATION_DECISIONS.md && echo "✓ Q2 decision confirmed"
grep "T-11.*T-12.*T-13" WAVE_25A_CONSOLIDATION_DECISIONS.md && echo "✓ Phase 2 critical path clear"
echo "✓ All checks passed"
```

---

## T-10: User Decision Checkpoint (1 hour)

**Owner:** User (External)  
**Depends:** T-09 (decision document ready)  
**Verification:** USER CONFIRMATION

### Required Action

User reviews and approves Phase 1 output:

1. **Phase 1 Completion Checklist:**
   - ✓ All 9 Phase 1 documents completed (T-01 through T-09)
   - ✓ Contract consolidation strategy locked (Option B)
   - ✓ Tool requirements understood (5 commands, batch + agent integration)
   - ✓ Testing strategy approved (16 integration + 4 load test suites)
   - ✓ AGENTS.md gaps known (6 sections, 120 lines)

2. **Gate Criteria:**
   - Phase 1 documents ✓ (all 9 in place)
   - No blockers identified ✓
   - Confidence: 96% (only sequential BLOCO cleanup as prerequisite) ✓

3. **Decision:**
   - **APPROVED:** Proceed to Phase 2 (contract design & rewrite)
   - **BLOCKED:** Return to T-01 (reason required)

### Acceptance

User confirms (via chat or command) one of:
- "APPROVED — proceed to Phase 2"
- "NEEDS REVISION — [reason]"

### Verification

```bash
# This is a human gate; verification is implicit user approval
# No automated check required
echo "✓ Awaiting user decision (T-10 gate)"
```

---

# PHASE 2-4 OVERVIEW

(Detailed specs will be created after T-10 user approval)

## Phase 2: Contract Design (T-11 to T-20)

**Duration:** 34h serial / 14h parallel  
**Deliverable:** 6 rewritten contracts + 8 golden fixtures  
**Gate:** User approval at T-20

---

## Phase 3: Tooling (T-21 to T-30)

**Duration:** 23h serial / 10h parallel  
**Deliverable:** 5 new/enhanced tool commands + agent helpers  
**Gate:** User approval at T-30

---

## Phase 4: Testing & Ship (T-31 to T-35)

**Duration:** 16h serial / 7h parallel  
**Deliverable:** 16 integration tests + 4 load tests + validation report  
**Final Gate:** Ship ready

---

# MEMORY WRITE TRIGGERS

Memory writes occur at these points:

1. **T-10 User Approval:** Record decision lock in `.specs/memory/active-state.md`
2. **T-20 User Approval:** Record Phase 2 completion, wave transitions to Phase 3
3. **T-30 User Approval:** Record Phase 3 completion, tooling validated
4. **T-35 Ship:** Record Wave 25A completion, lessons learned

---

# NEXT IMMEDIATE ACTION

**You are here:** Phase 1 execution plan locked.

**Next Step:** Approve T-10 gate → I create Phase 2 detailed task specs

**Command:** `APPROVED` (or describe any needed revisions)

---

**Document Status:** READY FOR EXECUTION  
**Created:** 2026-07-03  
**User Decision Checkpoint:** AWAITING T-10 GATE APPROVAL
