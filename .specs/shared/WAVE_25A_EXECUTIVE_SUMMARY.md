# Wave 25A: Allocation Consolidation — Executive Summary

**Status:** Comprehensive Audit Complete  
**Date:** 2026-07-03  
**Document:** 1,591 lines (Full audit in `WAVE_25A_ALLOCATION_CONSOLIDATION_AUDIT.md`)  

---

## KEY FINDINGS

### 1. CONTRACT REDUNDANCY: 40% Overlap Detected

**Current State:**
- 3 allocation contracts (1,189 lines) with significant overlap
- allocation-contract.md (243 lines) — definitions & hierarchy
- allocation-enforcement-and-ledger-contract.md (846 lines) — enforcement + ledger + todo projection merged
- specialist-allocation-contract.md (100 lines) — specialist rules
- allocation-check.sh tool contract (301 lines)

**Redundancy Analysis:**
- Specialist allocation covered 3x (C1: 30 lines, C2: 10 lines, C3: 100 lines)
- Scope narrowing/broadening: explained twice (C1: 25 lines, C2: 80 lines)
- Required fields scattered and inconsistent
- Todo projection rules (100 lines) in wrong contract

**Recommendation:** OPTION B — Keep 3 base contracts + split enforcement/ledger/todo into focused files
- Current 3 → 6 contracts, but each ≤ 400 lines (maintainable)
- Clearer separation of concerns
- Easier to version independently

---

### 2. TOOLING GAP: allocation-check.sh Has 60% Coverage

**Current Implementation:**
- 4 commands working: check-file, check-pattern, expand-allocation, validate-scope
- Performance: O(P + F) pattern matching, < 1ms typical
- Limitations: no batch operations, no violation filtering, no performance benchmarks, no agent integration

**Required Enhancements (T-21 to T-27):**
- `validate-file` — Pre-write checks
- `query-violations` — Violation filtering + export
- `ledger-stats` — Compliance reporting
- `allocation-snapshot.sh` — Versioning (new tool)
- `allocation-diff.sh` — Scope comparison (new tool)
- Performance testing suite

**Estimated Effort:** 23 hours, 5 new/enhanced commands

---

### 3. EDGE CASES: 18 Identified, 6 Critical

**CRITICAL (Must block execution if unhandled):**
1. **E-01: Circular specialist delegation** (A→B→C→A) — Blocker
2. **E-02: Scope violation approved then violated again** — Data integrity
3. **E-03: File matches both allowed AND forbidden** — Pattern confusion
4. **E-04: Specialist without grounding bundle** — Safety
5. **E-05: Specialist output violates scope** — Trust
6. **E-06: Scope narrowing breaks dependent tasks** — Dependency

**HIGH Risk (12 more):** Nested delegation, concurrent conflicts, cross-user approval, pattern ambiguity, ledger corruption, etc.

**Testing Strategy:** Golden fixtures for each, edge case matrix (table in Section 4.3)

---

### 4. TESTING SCOPE: 11 Hours of Integration + 8 Hours of Load Tests

**Integration Tests (4 scenario sets, 16 test cases, 11 hours):**
- SET 1: Safe allocation path (4 tests, 2.5h)
- SET 2: Scope expansion path (4 tests, 3h)
- SET 3: Specialist delegation (4 tests, 3h)
- SET 4: Ledger & audit (4 tests, 2.5h)

**Load Tests (4 test suites, 8 hours, 1000+ concurrent tasks):**
- Test 1: 1000+ task allocation (2h) — < 2ms per task
- Test 2: 10K files pattern matching (2h) — < 10µs per file
- Test 3: 1000-event ledger queries (1.5h) — < 500ms audit
- Test 4: Concurrent conflict handling (2.5h) — 100% detection

**Golden Fixtures:** 8 fixtures (340 lines total, 3 safe + 3 violation + 2 load)

---

### 5. AGENTS.md GAPS: 6 Areas, 120 Lines Required

| Gap | Current | Required | Effort |
|-----|---------|----------|--------|
| Allocation execution checklist | None | 15 lines | 1h |
| Specialist allocation matrix | Generic | 25 lines with matrix | 1h |
| Scope narrowing/broadening guide | Generic | 40 lines with flow | 2h |
| allocation-check.sh tool reference | None | 20 lines | 1h |
| Ledger query examples | None | 20 lines | 1h |
| **TOTAL** | - | **120 lines** | **6h** |

---

## CRITICAL PATH ANALYSIS

### 4-Phase Execution Plan

| Phase | Tasks | Duration | Gate |
|-------|-------|----------|------|
| **Phase 1: Analysis** | T-01–T-10 | 27h serial / 8h parallel | T-10 (user decides strategy) |
| **Phase 2: Design** | T-11–T-20 | 34h serial / 14h parallel | T-20 (approve contracts) |
| **Phase 3: Tooling** | T-21–T-30 | 23h serial / 10h parallel | T-30 (approve tools) |
| **Phase 4: Testing** | T-31–T-35 | 16h serial / 7h parallel | T-35 (final ship) |

**Total:** 100 work hours + 5 user decision gates ≈ 2 weeks (8h/day)

**Critical Path:** T-01 → Analysis → T-11 → Design → T-21 → Tooling → T-31 → Testing → Ship
- No circular dependencies
- Parallelization possible within phases
- Clear user decision gates (T-10, T-20, T-30, T-35)

---

## RESOURCE NEEDS

### Effort Allocation

- **Altitude (Strategic):** 82h (primary owner, architecture + contracts + tooling)
- **Data Engineer (Tactical):** 14h (optional, performance testing)
- **Security (Optional):** 4h (optional, scope expansion reviews)
- **User (Decision Gates):** 5h total across 4 gates

### Required Infrastructure

- ✅ Existing: bash, yq, git, ripgrep — all installed
- ⚠️ Optional: Load test framework (may use bash loops)
- ⚠️ Optional: Benchmark tool (may use bash time command)

---

## UNRESOLVED QUESTIONS (User Input Required)

**Q1: Consolidation Strategy** — Choose one (affects Phase 2 by 30-50%):
- **Option A:** Merge all into 1 contract (1,289 lines) — simpler but monolithic
- **Option B:** Keep 3 base contracts + split enforcement/ledger/todo (6 total) — **RECOMMENDED**
- **Option C:** Hybrid approach with core + supplements

**Q2: Merge Ledger or Split?**
- Keep in enforcement-ledger-contract or extract to allocation-ledger-contract?
- **Recommendation:** Extract for cleaner separation

**Q3: Todo Projection Location?**
- Currently in allocation-enforcement-contract
- **Recommendation:** Keep there but link to execution-loop-contract

**Q4: Tool Scope?**
- Batch file checking vs CLI-only?
- Agent integration required?
- **Recommendation:** Batch operations + agent integration helpers

**Q5: Load Test Target?**
- 1000 tasks (conservative) vs 10,000 (aggressive)?
- **Recommendation:** Start with 1000, scale if needed

---

## DELIVERABLES (Wave 25A)

### Contracts
1. allocation-contract.md V2 (250 lines, merged + clarified)
2. allocation-enforcement-contract.md (350 lines, split from 846)
3. allocation-ledger-contract.md (NEW, 200 lines)
4. specialist-allocation-contract.md V2 (150 lines, refined + linked)
5. todo-allocation-contract.md (NEW, 150 lines)
6. allocation-check.contract.md V2 (400 lines, expanded)

### Tooling
1. allocation-check.sh enhancements (validate-file, query-violations, ledger-stats)
2. allocation-snapshot.sh (NEW)
3. allocation-diff.sh (NEW)
4. Tool documentation + integration
5. Performance benchmark suite

### Testing
1. 16 integration test scenarios (11 hours)
2. 4 load test suites (8 hours, 1000+ tasks)
3. 18 edge case fixtures (50-100 lines each)
4. Golden fixture set (340 lines)
5. Full validation report

### Documentation
1. AGENTS.md updates (120 lines)
2. Migration path document (3h)
3. Backward compatibility guide
4. CLI reference + examples

---

## SUCCESS CRITERIA

| Criterion | Metric | Target | Status |
|-----------|--------|--------|--------|
| All 3 contracts consolidated | Option chosen at T-10 | ✓ | Pending user decision |
| No redundancy > 20% | Overlap audit | ✓ | Identified 40% → target is fix |
| Tool performance baseline | < 2ms per task | ✓ | Benchmark in T-24 |
| Edge cases covered | 18/18 tested | ✓ | Fixtures in T-16, T-17 |
| Integration tests pass | 16/16 scenarios | ✓ | Executed in T-31 |
| Load tests pass | 1000+ tasks | ✓ | Executed in T-32 |
| Zero violations | Production compliance | ✓ | Audited in T-33 |
| AGENTS.md complete | 120 lines added | ✓ | Added in T-02, T-08 |

---

## NEXT IMMEDIATE STEPS

### For User (Review & Decide)

1. **Read SECTION 1-2 of full audit** — Task dependency & contract analysis
2. **Review 3 consolidation options** — Choose A/B/C (recommended: B)
3. **Review 5 unresolved questions** — Provide input
4. **Approve Phase 1 start** — Confirm T-01 can begin

### For Altitude (Phase 1 Execution)

1. Execute T-01 (Contract Consolidation Analysis, 4h)
2. Execute T-02/T-03/T-06/T-08 in parallel (4h)
3. Execute T-07 (Testing Strategy, 4h)
4. Execute T-09 (Decision Document, 3h)
5. **Gate T-10:** User decision on consolidation strategy

---

## QUICK REFERENCE: DECISION MATRIX

```
QUESTION                      RECOMMENDATION          IMPACT
──────────────────────────────────────────────────────────────────
Consolidation strategy        Option B (split 6)      Phase 2 effort
Merge ledger or split?        Extract separately      Contract clarity
Todo location?                Keep in enforcement     Linked to execution
Tool scope (batch/CLI)?       Both + agent helpers   Automation level
Load test target (1k/10k)?    1000 initially          Timeline flexibility
```

---

## RISK ASSESSMENT

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| User indecision at T-10 | Medium | HIGH | QUESTION method forces choice |
| Performance regression | Low | MEDIUM | Baseline captured in T-05, T-24 |
| Edge case discovery | Medium | MEDIUM | Comprehensive test matrix (18 cases) |
| Tool integration issues | Low | LOW | Agent integration test in T-25 |
| Contract merge conflicts | Low | MEDIUM | Clear boundaries in Option B |

---

## ROI & VALUE

### What Wave 25A Delivers

1. **Clarity:** From 40% redundancy → clear hierarchy of 6 focused contracts
2. **Enforcement:** Active scope boundary validation at execution time
3. **Auditability:** Full ledger of allocation decisions + violations
4. **Scalability:** Tested with 1000+ concurrent tasks
5. **Safety:** 18 edge cases covered with fixtures + tests
6. **Documentation:** AGENTS.md + guides for implementers

### Effort Justification

- 100 hours of work = ~2.5 weeks of effort
- Prevents future scope violations, security issues, multi-task conflicts
- Foundation for Wave 26+ (nested allocations, cross-wave scoping, security hardening)
- Estimated ROI: 5-10x via bug prevention + security

---

**Full Audit Location:** `/home/ubuntu/.config/opencode/.specs/shared/WAVE_25A_ALLOCATION_CONSOLIDATION_AUDIT.md` (1,591 lines)

**Ready to proceed?** → Confirm user decisions for Q1-Q5, then execute T-01
