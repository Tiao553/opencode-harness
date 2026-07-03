# Wave 25A Audit — Quick Navigation & Reference

**Date Created:** 2026-07-03  
**Full Audit Completed:** YES (1,591 lines)  
**Status:** Ready for user review + decision gates

---

## DOCUMENT STRUCTURE

```
Wave 25A Allocation Consolidation Audit
├── EXECUTIVE SUMMARY (this file)
│   └── 5 key findings, critical path, deliverables
│
├── FULL AUDIT (1,591 lines in .specs/shared/)
│   ├── SECTION 1: TASK DEPENDENCY ANALYSIS (100+ lines)
│   │   ├── 1.1 Task Map (T-01 through T-35, 4 phases)
│   │   ├── 1.2 Critical Path Summary
│   │   ├── 1.3 Unblocked vs Blocked Tasks
│   │   └── 1.4 Circular Dependency Check ✓
│   │
│   ├── SECTION 2: ALLOCATION CONTRACT ANALYSIS (250+ lines)
│   │   ├── 2.1 Current State (C1/C2/C3 detailed review)
│   │   ├── 2.2 Redundancy Analysis (40% overlap identified)
│   │   ├── 2.3 Complementarity Assessment
│   │   ├── 2.4 Consolidation Options (A/B/C)
│   │   └── 2.5 Recommendation: OPTION B
│   │
│   ├── SECTION 3: TOOLING REQUIREMENTS ANALYSIS (150+ lines)
│   │   ├── 3.1 Current Tool Assessment (allocation-check.sh)
│   │   ├── 3.2 Required Commands (Phase 1/2/3 breakdown)
│   │   ├── 3.3 Scope Matching Requirements
│   │   ├── 3.4 Performance Requirements
│   │   └── 3.5 Tooling Gap Analysis
│   │
│   ├── SECTION 4: EDGE CASES TO TEST (400+ lines)
│   │   ├── 4.1 Edge Case Inventory (18 cases, risk-ranked)
│   │   ├── 4.2 Detailed Edge Case Scenarios (E-01 through E-18)
│   │   └── 4.3 Edge Case Testing Matrix
│   │
│   ├── SECTION 5: INTEGRATION TEST SCOPE (150+ lines)
│   │   ├── 5.1 Integration Test Scenarios (4 sets, 16 tests)
│   │   ├── 5.2 Test Differences from Unit Tests
│   │   ├── 5.3 Golden Fixture Set 1 (Safe Paths)
│   │   └── 5.4 Golden Fixture Set 2 (Violations)
│   │
│   ├── SECTION 6: LOAD TEST SCOPE (100+ lines)
│   │   ├── 6.1 Load Test Targets (4 suites)
│   │   └── 6.2 Load Test Fixtures
│   │
│   ├── SECTION 7: AGENTS.md UPDATE REQUIREMENTS (150+ lines)
│   │   ├── 7.1 Current AGENTS.md Allocation Sections
│   │   ├── 7.2 Allocation Gaps (6 areas)
│   │   ├── 7.3 Proposed Updates (5 updates, 120 lines)
│   │   └── 7.4 AGENTS.md Update Effort
│   │
│   ├── SECTION 8: CONSOLIDATED PLAN (200+ lines)
│   │   ├── 8.1 Wave 25A Critical Path (Detailed)
│   │   ├── 8.2 Timeline & Resource Planning
│   │   └── 8.3 Unresolved Questions
│   │
│   ├── SECTION 9: EDGE CASE RISK RANKING (50 lines)
│   │   ├── 9.1 Risk Matrix
│   │   └── 9.2 Test Priority (By Risk)
│   │
│   └── SECTION 10: RESOURCE NEEDS SUMMARY (50 lines)
│       ├── 10.1 Skills Required
│       ├── 10.2 Tools & Infrastructure
│       └── 10.3 Decision Gates
│
└── SECTION 11: FINAL RECOMMENDATION
    ├── Wave 25A Consolidated Plan
    └── Next Steps
```

---

## FILE LOCATIONS

```
/home/ubuntu/.config/opencode/

.specs/shared/
├── WAVE_25A_EXECUTIVE_SUMMARY.md (this document, ~250 lines)
├── WAVE_25A_ALLOCATION_CONSOLIDATION_AUDIT.md (full audit, 1,591 lines)
├── allocation-contract.md (current, 243 lines)
├── allocation-enforcement-and-ledger-contract.md (current, 846 lines)
└── specialist-allocation-contract.md (current, 100 lines)

tools/
├── allocation-check.sh (current, 286 lines)
└── allocation-check.contract.md (current, 301 lines)

AGENTS.md (primary coordinator interface, needs 120-line update)
```

---

## QUICK DECISION CHECKLIST

### For User (Before Phase 1)

- [ ] Review Executive Summary (this document) — 5 min read
- [ ] Read SECTION 1 (Task Dependency) — 10 min
- [ ] Read SECTION 2 (Consolidation Options) — 15 min
- [ ] Make decision on Q1-Q5 (below) — 30 min
- [ ] Approve Phase 1 start — 5 min

**Total Time: ~1 hour**

### User Decisions Required

| # | Question | Option A | Option B ✓ | Option C | Your Choice |
|---|----------|----------|-----------|----------|-------------|
| Q1 | Consolidation | Merge 1 | Keep 3+split | Hybrid | **?** |
| Q2 | Ledger location | Keep merged | Extract sep | TBD | **?** |
| Q3 | Todo projection | Keep enf | Link only | TBD | **?** |
| Q4 | Tool scope | CLI only | Batch+agent | Both | **?** |
| Q5 | Load test target | 1000 tasks | 10k tasks | Hybrid | **?** |

---

## CRITICAL PATH TIMELINE

```
Week 1:
┌─────────────────────────────────────────────────────────┐
│ PHASE 1: ANALYSIS (T-01 to T-10)                        │
│ ├─ T-01: Contract Analysis (4h)                        │
│ ├─ T-02/T-03/T-06/T-08: Parallel (4h)                  │
│ ├─ T-07: Testing Strategy (4h)                         │
│ ├─ T-09: Decision Doc (3h)                             │
│ └─ ⏹️ GATE T-10: User Decides Strategy                   │
│ Total: 8h parallel time ≈ 1-2 days effective           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ PHASE 2: DESIGN (T-11 to T-20)                         │
│ ├─ T-11/T-12/T-13: Contracts (15h serial → 8h eff)    │
│ ├─ T-14: Migration Path (3h)                           │
│ ├─ T-15/T-16/T-17: Fixtures (8h serial → 4h eff)      │
│ ├─ T-18/T-19: Specs (6h)                               │
│ └─ ⏹️ GATE T-20: Approve Contracts                       │
│ Total: 14h parallel time ≈ 2-3 days effective          │
└─────────────────────────────────────────────────────────┘

Week 2:
┌─────────────────────────────────────────────────────────┐
│ PHASE 3: TOOLING (T-21 to T-30)                        │
│ ├─ T-21/T-22/T-23: Commands (8h)                       │
│ ├─ T-24/T-25: Integration (6h)                         │
│ ├─ T-26/T-27: New Tools (5h)                           │
│ ├─ T-28/T-29: Docs & Tests (5h)                        │
│ └─ ⏹️ GATE T-30: Tool Release Ready                      │
│ Total: 10h parallel time ≈ 1-2 days effective          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ PHASE 4: VALIDATION (T-31 to T-35)                     │
│ ├─ T-31: Integration Tests (4h)                        │
│ ├─ T-32: Load Tests (5h)                               │
│ ├─ T-33: Edge Case Tests (4h)                          │
│ ├─ T-34: Validation Report (2h)                        │
│ └─ T-35: 🚀 SHIP                                         │
│ Total: 7h parallel time ≈ 1 day effective              │
└─────────────────────────────────────────────────────────┘

**Recommended Pace:** 2 weeks (1 phase per 3-4 days + decision gates)
**Aggressive Pace:** 1 week (not recommended due to user decisions)
**Conservative Pace:** 3 weeks (if rework needed)
```

---

## KEY METRICS AT A GLANCE

| Metric | Value | Notes |
|--------|-------|-------|
| **Total Work Hours** | 100 | Altitude: 82h, Data Engineer: 14h, Security: 4h |
| **User Decision Time** | 5h | Across 4 gates (T-10, T-20, T-30, T-35) |
| **Critical Path (serial)** | ~100h | No parallelization |
| **Critical Path (optimal)** | ~50h | With parallelization |
| **Recommended Duration** | 2 weeks | 8h/day, 1 phase per 3-4 days |
| **Contracts Delivered** | 6 | From 3 (each ≤400 lines) |
| **Tools Delivered** | 3 new/enhanced | allocation-check, snapshot, diff |
| **Integration Tests** | 16 scenarios | 11 hours, 4 scenario sets |
| **Load Tests** | 4 suites | 8 hours, 1000+ tasks |
| **Edge Cases** | 18 identified | 6 critical, 12 high |
| **AGENTS.md Updates** | 120 lines | 5 new sections |

---

## RISK RANKING (Top 5)

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|-----------|
| 1 | User indecision at T-10 | Medium | HIGH | QUESTION method forces choice |
| 2 | Contract merge conflicts | Low | MEDIUM | Clear boundaries in Option B |
| 3 | Performance regression | Low | MEDIUM | Baseline in T-05/T-24 |
| 4 | Tool integration issues | Low | LOW | Integration test in T-25 |
| 5 | Edge case discovery | Medium | MEDIUM | Comprehensive test matrix |

---

## SUCCESS DEFINITION (8 Criteria)

1. ✓ Contracts consolidated (Option chosen)
2. ✓ Redundancy reduced (40% → <20%)
3. ✓ Tools enhanced (5 new/enhanced commands)
4. ✓ Performance baseline (< 2ms per task)
5. ✓ Edge cases covered (18/18 tested)
6. ✓ Integration tests (16/16 passing)
7. ✓ Load tests (1000+ tasks passing)
8. ✓ AGENTS.md complete (120 lines added)

---

## EXAMPLE: PHASE 1 EXECUTION (Days 1-2)

**Day 1 (8 hours):**
- 8:00-12:00 (4h): T-01 Contract Consolidation Analysis
- 12:00-13:00 (1h): Lunch
- 13:00-17:00 (4h): T-02/T-03/T-06/T-08 (parallel kicks off)

**Day 2 (8 hours):**
- 8:00-12:00 (4h): T-07 Testing Strategy Design
- 12:00-13:00 (1h): Lunch
- 13:00-16:00 (3h): T-09 Consolidation Decision Document
- 16:00-17:00 (1h): T-10 Checkpoint: Wait for user decision

**Gate T-10 (User Review):**
- Read Phase 1 summary (30 min)
- Decide on Q1-Q5 (30 min)
- Approve → Phase 2 can start

---

## NEXT IMMEDIATE ACTIONS

### RIGHT NOW (5 minutes)

1. **Read this document** — Overview (5 min)

### THEN (30-60 minutes)

2. **Review SECTION 1-2 of full audit** — Understand scope & options
3. **Read SECTION 2.4 & 2.5** — Consolidation options + recommendation
4. **Review Table: "Unresolved Questions"** — Understand Q1-Q5

### THEN (30 minutes)

5. **Decide on Q1-Q5** — Make your choices (or discuss with team)
6. **Confirm: "Approve Phase 1 start?"** — Yes or No

### THEN (Phase 1 starts)

7. **T-01 begins** — Altitude contracts analysis (4h)
8. **Parallel T-02/T-03/T-06/T-08** — 4h group analysis
9. **T-07** — Testing strategy (4h)
10. **T-09** — Decision document (3h)
11. **Gate T-10** — User approves before Phase 2

---

## FURTHER READING

**For Deep Dive (30-60 min):**
- SECTION 1: Task dependency mapping
- SECTION 2: Contract analysis & recommendations
- SECTION 4: Edge case scenarios

**For Implementation (60-90 min):**
- SECTION 3: Tooling requirements
- SECTION 5: Integration test scope
- SECTION 6: Load test scope

**For Documentation (30 min):**
- SECTION 7: AGENTS.md updates
- SECTION 8: Consolidated plan
- SECTION 10: Resource needs

**For Decision-Making (15 min):**
- SECTION 11: Final recommendation
- Quick reference: "Unresolved Questions"

---

## QUESTIONS?

**General Questions:**
- See SECTION 11 (Final Recommendation)

**Technical Questions:**
- See relevant section (1-7)

**Task/Timeline Questions:**
- See SECTION 8 (Consolidated Plan)

**Resource Questions:**
- See SECTION 10 (Resource Needs)

---

**Status:** Audit Complete, Ready for User Input  
**Files:** 
- Executive Summary: `/home/ubuntu/.config/opencode/.specs/shared/WAVE_25A_EXECUTIVE_SUMMARY.md`
- Full Audit: `/home/ubuntu/.config/opencode/.specs/shared/WAVE_25A_ALLOCATION_CONSOLIDATION_AUDIT.md`

**Next Gate:** User decision on Q1-Q5 before T-01 execution

