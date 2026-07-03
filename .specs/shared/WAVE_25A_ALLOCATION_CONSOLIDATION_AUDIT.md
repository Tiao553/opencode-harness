# Wave 25A: Allocation Consolidation — Comprehensive Audit

**Status:** Planning Phase  
**Date:** 2026-07-03  
**Scope:** Contract consolidation, tooling requirements, testing strategy, AGENTS.md updates  
**Effort Estimate:** 12-15 days (35 tasks), 8,000-10,000 lines  

---

## EXECUTIVE SUMMARY

Wave 25A consolidates the allocation system from fragmented design to a unified, tested, production-ready framework. Currently 3 allocation contracts (1,189 lines) + 1 tool contract (301 lines) exist with partial overlap, redundancy, and unclear merging strategy.

**Key Questions to Resolve:**
1. **Consolidation Strategy:** Merge into 1 contract or keep 3 with clear boundaries?
2. **Ledger Integration:** Is ledger part of enforcement contract or separate?
3. **Todo Projection:** Does this belong in allocation-enforcement or in execution-loop-contract?
4. **Tool Scope:** What commands must allocation-check.sh support by end of wave?
5. **Edge Cases:** Circular specialist delegation, nested allocations, concurrent conflicts?

---

# SECTION 1: TASK DEPENDENCY ANALYSIS

## 1.1 Task Map (T-01 through T-35)

### PHASE 1: ANALYSIS & DECISION (T-01 to T-10)

| Task | Title | Depends On | Duration | Assignee | Status |
|------|-------|-----------|----------|----------|--------|
| **T-01** | Contract Consolidation Analysis | None | 4h | Altitude | Pending |
| **T-02** | Tool Requirements Audit | T-01 | 3h | Altitude | Pending |
| **T-03** | Edge Case Inventory | T-01 | 3h | Altitude | Pending |
| **T-04** | Current Tool Assessment | T-02 | 2h | Altitude | Pending |
| **T-05** | Performance Baseline Capture | T-04 | 2h | Altitude | Pending |
| **T-06** | Specialist Allocation Review | T-01 | 2h | Altitude | Pending |
| **T-07** | Testing Strategy Design | T-03, T-04 | 4h | Altitude | Pending |
| **T-08** | AGENTS.md Gap Audit | T-01 | 2h | Altitude | Pending |
| **T-09** | Consolidation Decision Document | T-01..T-08 | 3h | Altitude | Pending |
| **T-10** | User Decision Checkpoint | T-09 | 1h | (user) | Pending |

**Critical Path (Phase 1):** T-01 → [T-02, T-03, T-06, T-08] → T-07 → T-09 → T-10  
**Duration:** 27h serial (or 8h parallel with T-02/T-03/T-06/T-08)

---

### PHASE 2: CONTRACT DESIGN (T-11 to T-20)

| Task | Title | Depends On | Duration | Assignee | Status |
|------|-------|-----------|----------|----------|--------|
| **T-11** | Allocation-Contract.md V2 (merged) | T-10 | 6h | Altitude | Pending |
| **T-12** | Enforcement-Ledger-Contract.md V2 | T-10, T-11 | 5h | Altitude | Pending |
| **T-13** | Specialist-Contract.md V2 (refined) | T-10, T-11 | 4h | Altitude | Pending |
| **T-14** | Migration Path Document | T-11, T-12, T-13 | 3h | Altitude | Pending |
| **T-15** | Tool Contract V2 (expanded) | T-02, T-12 | 4h | Altitude | Pending |
| **T-16** | Golden Fixture Set 1 (safe paths) | T-11, T-15 | 4h | Altitude | Pending |
| **T-17** | Golden Fixture Set 2 (violations) | T-12, T-15 | 4h | Altitude | Pending |
| **T-18** | Integration Test Spec | T-16, T-17 | 3h | Altitude | Pending |
| **T-19** | Load Test Spec (1000+ tasks) | T-05, T-18 | 3h | Altitude | Pending |
| **T-20** | Design Review & Approval Gate | T-11..T-19 | 2h | (user) | Pending |

**Critical Path (Phase 2):** T-10 → T-11 → T-12 → T-14 → [T-15, T-16, T-17] → T-18 → T-19 → T-20  
**Duration:** 34h serial (or 14h with parallelization)

---

### PHASE 3: TOOLING (T-21 to T-30)

| Task | Title | Depends On | Duration | Assignee | Status |
|------|-------|-----------|----------|----------|--------|
| **T-21** | allocation-check.sh: validate-scope enhancement | T-15 | 3h | Altitude | Pending |
| **T-22** | allocation-check.sh: query-violations command | T-15 | 3h | Altitude | Pending |
| **T-23** | allocation-check.sh: ledger-stats command | T-15 | 2h | Altitude | Pending |
| **T-24** | allocation-check.sh: performance tests | T-19 | 4h | Altitude | Pending |
| **T-25** | allocation-check.sh: integration with agents | T-21 | 2h | Altitude | Pending |
| **T-26** | allocation-snapshot.sh (new tool) | T-12 | 3h | Altitude | Pending |
| **T-27** | allocation-diff.sh (new tool) | T-12, T-26 | 2h | Altitude | Pending |
| **T-28** | Tool Documentation | T-21..T-27 | 2h | Altitude | Pending |
| **T-29** | Tool Integration Test | T-21..T-27 | 3h | Altitude | Pending |
| **T-30** | Tool Approval Gate | T-28, T-29 | 1h | (user) | Pending |

**Critical Path (Phase 3):** T-15 → [T-21, T-26] → T-22, T-23 → T-24 → T-29 → T-30  
**Duration:** 23h serial (or 10h with parallelization)

---

### PHASE 4: TESTING (T-31 to T-35)

| Task | Title | Depends On | Duration | Assignee | Status |
|------|-------|-----------|----------|----------|--------|
| **T-31** | Integration Test Execution | T-20, T-29 | 4h | Altitude | Pending |
| **T-32** | Load Test Execution (1000+ tasks) | T-20, T-24 | 5h | Altitude | Pending |
| **T-33** | Edge Case Test Execution | T-31, T-32 | 4h | Altitude | Pending |
| **T-34** | Validation Report | T-31, T-32, T-33 | 2h | Altitude | Pending |
| **T-35** | Ship & Deploy | T-34 | 1h | Altitude | Pending |

**Critical Path (Phase 4):** T-20 → T-29 → T-31 → T-33 → T-34 → T-35  
**Duration:** 16h serial (or 7h with some parallel)

---

## 1.2 Critical Path Summary

**Overall Critical Path:**
```
T-01 (4h)
  ↓
T-02, T-03, T-06, T-08 (4h parallel max)
  ↓
T-07 (4h)
  ↓
T-09 (3h) → T-10 (user decision, 1h)
  ↓
T-11 (6h) → T-12 (5h) → [T-14, T-15] (4h) → T-16, T-17 (4h) → T-18 (3h) → T-19 (3h) → T-20 (user decision, 2h)
  ↓
[T-21, T-26] (3h parallel) → T-22, T-23 (3h) → T-24 (4h) → T-29 (3h) → T-30 (user decision, 1h)
  ↓
T-31 (4h) → T-33 (4h) → T-34 (2h) → T-35 (1h)
```

**Total Duration:**
- **Serial (no parallelization):** ~100h = 13 days (8h/day)
- **With optimal parallelization:** ~50h = 6 days (8h/day) + 5 user decision gates
- **Recommended pace:** 2 weeks (1 phase per 3-4 days) with decision gates between phases

---

## 1.3 Unblocked vs Blocked Tasks

### Immediately Unblocked (Can start now)
- T-01 (Analysis) — Foundation
- T-02, T-03, T-06, T-08 (can run parallel with T-01 output)

### Blocked Tasks
- T-04+ depend on T-01 completion
- T-11+ depend on T-10 user decision
- T-21+ depend on T-20 user decision
- T-31+ depend on T-30 user decision

### User Decision Gates (Blockers)
1. **Gate T-10:** After Phase 1 analysis — user approves consolidation strategy
2. **Gate T-20:** After Phase 2 design — user approves contracts & fixtures
3. **Gate T-30:** After Phase 3 tooling — user approves tool commands & performance
4. **Gate T-35:** Approval to ship

---

## 1.4 Circular Dependency Check

✅ **No circular dependencies detected.**

All tasks have single-direction flow: Analysis → Design → Tooling → Testing → Ship

---

# SECTION 2: ALLOCATION CONTRACT ANALYSIS

## 2.1 Current State

### Contract 1: `allocation-contract.md` (243 lines)

**Scope:**
- Global allocation definition (change, wave, phase ownership)
- Local allocation definition (task, todo ownership)
- Specialist allocation definition
- Precedence rules
- Invalid states
- Delegation rules

**Key Concepts:**
- 3 allocation types: Global, Local, Specialist
- Narrowing is safe; broadening requires approval
- 8 required fields per allocation
- Precedence hierarchy: user → local → wave → phase → change → repo default → coordinator

**Strengths:**
- Clear hierarchy
- Safe narrowing / unsafe broadening rule is explicit
- Task-Spec mapping defined

**Gaps:**
- Does not define file-level matching (patterns, glob, negation)
- Does not define ledger events
- Does not define todo projection rules
- Does not mention specialist grounding bundle size/performance

---

### Contract 2: `allocation-enforcement-and-ledger-contract.md` (846 lines)

**Scope:**
- Scope model (glob patterns, exact paths, directory patterns, negation)
- Scope matching algorithm (rule order, matching function)
- Validation rules (safe writes, safe narrowing, unsafe broadening)
- Escalation flow (ask-user options: A/B/C)
- Ledger events (schema, event types: allocated/allowed/expansion/violation)
- Todo projection (source of truth, visibility, specialist rule, verify rule, loop rule)
- Backward compatibility

**Key Concepts:**
- Pattern matching with glob support
- Forbidden overrides allowed
- Default deny (if not in allowed, deny)
- 4 event types: allocation_assigned, file_write_allowed, scope_expansion_requested, violation_blocked
- Todo must include verify: clause
- Todo must cite specialist name if delegated

**Strengths:**
- Comprehensive pattern matching algorithm
- Clear escalation flow with user choices
- Ledger event schema fully defined
- Backward compatibility path

**Gaps:**
- Merges 3 concerns (enforcement, ledger, todo) into single 846-line doc
- Todo projection feels out of place (belongs in execution-loop or orchestration?)
- Performance baseline not specified (O(P) analysis present but no real numbers)
- Does not address nested specialist delegation

---

### Contract 3: `specialist-allocation-contract.md` (100 lines)

**Scope:**
- Required fields for specialist allocation
- Grounding bundle definition
- Evidence contract
- When to allocate
- Over-delegation rules
- Delegation lifecycle
- Stop conditions
- Anti-patterns

**Key Concepts:**
- Specialist provides bounded expertise, not hidden ownership
- Must have: reason, scope, evidence expectation, stop condition
- Grounding bundle required
- 8 over-delegation anti-patterns

**Strengths:**
- Focused, concise
- Clear lifecycle
- Anti-patterns explicit

**Gaps:**
- Does not define what "bounded" means quantitatively (lines of code? files? time?)
- Does not address nested specialist delegation (A delegates to B, B to C)
- No performance/context budget for specialists
- Does not reference allocation-contract or enforcement-contract for scope/boundaries

---

## 2.2 Redundancy Analysis

### High Redundancy (2+ contracts cover same ground)

| Topic | Contract 1 | Contract 2 | Contract 3 | Assessment |
|-------|-----------|-----------|-----------|-----------|
| Specialist definition | 30 lines | 10 lines | 100 lines | 3x coverage; unclear boundaries |
| Allocation hierarchy | 40 lines | 0 lines | 0 lines | Only in C1; C2/C3 reference it |
| Scope narrowing/broadening | 25 lines | 80 lines | 0 lines | C1 principle; C2 algorithm |
| Evidence requirements | 0 lines | 0 lines | 15 lines | Only in C3; should reference C2 ledger |
| Required fields | 30 lines | 0 lines | 10 lines | Scattered across C1/C3; overlap |
| Todo rules | 0 lines | 100 lines | 0 lines | Only in C2; may belong elsewhere |

### Moderate Redundancy (1 contract, but should reference others)

- **Scope matching algorithm** (C2 only) — C1 does not explain glob patterns
- **Ledger events** (C2 only) — C1/C3 do not mention how allocation decisions are recorded
- **Escalation flow** (C2 only) — C1/C3 do not explain ask-user for scope expansion

---

## 2.3 Complementarity Assessment

### What C1 Does That Others Don't
- Global allocation hierarchy (change → wave → phase)
- Precedence rules (user → local → wave → phase → change → repo)
- Invalid allocation states
- Task-Spec mapping

### What C2 Does That Others Don't
- Glob pattern syntax and matching algorithm
- Ledger event schema
- Escalation flow
- Todo projection rules

### What C3 Does That Others Don't
- Specialist evidence contract
- Grounding bundle concept
- Over-delegation rules
- When-to-allocate heuristics

---

## 2.4 Consolidation Options

### Option A: Merge into Single Contract (1,289 lines)

**Pros:**
- Single source of truth
- No cross-references needed
- Easier to search
- Clearer hierarchy

**Cons:**
- May become unwieldy (>1000 lines)
- Harder to find specific info
- Different audiences (architects vs implementers vs validators)
- Difficult to update without large rewrites

**Structure (if merged):**
```markdown
# Unified Allocation Contract

## Section 1: Allocation Hierarchy (from C1)
- Global allocation
- Local allocation
- Specialist allocation
- Precedence rules

## Section 2: Scope Model (from C2)
- Pattern types
- Matching algorithm

## Section 3: Enforcement (from C2)
- Validation rules
- Escalation flow

## Section 4: Specialist Details (from C3)
- Grounding bundle
- Evidence contract
- Lifecycle

## Section 5: Ledger (from C2)
- Event schema
- Event types

## Section 6: Todo Projection (from C2)
- Visibility rules
- Verify clause requirement
```

---

### Option B: Keep 3 Contracts, Clarify Boundaries

**Pros:**
- Each contract has focused purpose
- Easier to update individual pieces
- Clearer audience (architect/implementer separation)
- Easier to test one aspect independently

**Cons:**
- More cross-references needed
- Risk of divergence/inconsistency
- Harder to understand full picture

**Proposed Boundaries:**
```
allocation-contract.md
├── Global/Local/Specialist definition
├── Hierarchy & precedence
├── Invalid states
└── References → enforcement, specialist

allocation-enforcement-contract.md (NEW - split from current 846-line file)
├── Scope model & pattern matching
├── Validation rules
├── Escalation flow
└── References → allocation, specialist

allocation-ledger-contract.md (NEW - extract from current 846-line file)
├── Event schema
├── Event types
├── Ledger queries
└── References → enforcement

specialist-allocation-contract.md (unchanged)
├── Grounding bundle
├── Evidence contract
├── Lifecycle
└── References → allocation, enforcement

todo-allocation-contract.md (NEW - extract from current 846-line file)
├── Todo projection rules
├── Verify clause requirement
├── Loop posture
└── References → allocation, execution-loop
```

---

### Option C: Hybrid — Core Contract + Focused Supplements

**Structure:**
```
allocation-contract.md (consolidate C1 + essential C2/C3)
└── Global/Local/Specialist definition
└── Hierarchy & precedence
└── Scope narrowing/broadening (principle only)
└── References to specialized contracts

allocation-enforcement-contract.md (C2 enforcement only, 300 lines)
└── Scope model & pattern matching
└── Validation rules & escalation

specialist-allocation-contract.md (C3 unchanged)

allocation-ledger-contract.md (NEW)

todo-allocation-contract.md (NEW)
```

---

## 2.5 Recommendation

**→ OPTION B: Keep 3 Base Contracts + Split Enforcement/Ledger/Todo**

**Rationale:**
1. Allows Phase 0 consolidation approach (from 7→3 model)
2. Clearer separation of concerns
3. Each contract ≤ 400 lines (maintainable)
4. Easier to test and version independently
5. Aligns with shared contracts pattern (one file per domain)

**Consolidation Math:**
- Current: 3 contracts (1,189 lines)
- After split: 6 contracts (~1,400 lines, but better organized)
- Net: +200 lines, but significantly clearer

---

# SECTION 3: TOOLING REQUIREMENTS ANALYSIS

## 3.1 Current Tool Assessment

### allocation-check.sh (286 lines, YAML-based)

**Implemented Commands:**
1. `check-file <file> <allocation.yaml>` — Is file allowed? (✓ working)
2. `check-pattern <file> <pattern>` — Glob match? (✓ working)
3. `expand-allocation <old.yaml> <new_files>` — Scope delta? (✓ working)
4. `validate-scope <ledger.md> <change_id>` — Audit trail? (✓ working)

**Performance:**
- Pattern matching: O(P + F) where P = allowed patterns, F = forbidden patterns
- Typical: < 50 patterns → < 1ms per file
- Ledger query: O(E) where E = events (typically < 100)
- No significant overhead for typical tasks

**Limitations:**
- Read-only (does not modify files)
- Does not handle 1000+ tasks (needs benchmarking)
- Does not provide violation filtering/export
- Does not support batch operations
- Does not integrate with agents (just CLI tool)
- Pattern matching is bash glob (not full regex)

---

## 3.2 Required Commands (T-03 Edge Case Audit)

### Phase 1: Enforcement (Essential)

| Command | Purpose | Estimate | Priority |
|---------|---------|----------|----------|
| `validate-file` | Pre-write check against allocation | 2h | Must-have |
| `query-violations` | List all blocked writes | 2h | Must-have |
| `expand-scope` | Show scope expansion delta | 1h | Already exists |
| `audit-ledger` | Full ledger compliance report | 2h | Must-have |

### Phase 2: Queries (Important)

| Command | Purpose | Estimate | Priority |
|---------|---------|----------|----------|
| `list-allocations` | Show all active allocations in change | 1h | Should-have |
| `list-violations` | List all violations (with details) | 2h | Should-have |
| `compare-scope` | Diff between two allocations | 1.5h | Should-have |
| `export-ledger` | Export events as JSON/CSV | 1.5h | Should-have |

### Phase 3: Utilities (Nice-to-have)

| Command | Purpose | Estimate | Priority |
|---------|---------|----------|----------|
| `snapshot` | Save current state as baseline | 1h | Nice-to-have |
| `replay-violations` | Replay past violations from ledger | 1.5h | Nice-to-have |
| `performance-test` | Benchmark scope matching at scale | 1.5h | Nice-to-have |

---

## 3.3 Scope Matching Requirements

### Current Implementation
```bash
case "$file" in
    $pattern) return 0 ;;
    *) return 1 ;;
esac
```

**Limitations:**
- No nested glob support (e.g., `**/*.md`)
- No character class support (e.g., `[abc]`)
- No negation (handled externally)
- No regex mode (only bash glob)

### Required Enhancements

| Feature | Current | Required | Estimate |
|---------|---------|----------|----------|
| `*` (any except /) | ✓ | ✓ | Done |
| `**` (any including /) | ✗ | ✓ | 1h |
| `?` (single char) | ✗ | ✓ | 30m |
| `[abc]` (class) | ✗ | ✓ | 1h |
| Negation (!) | ✗ | ✓ (external) | Done |
| Regex mode | ✗ | ✗ (optional) | - |
| Performance > 1000 files | ? | ✓ | 1.5h (benchmark) |

---

## 3.4 Performance Requirements

### Load Test Target: 1000+ Concurrent Tasks

| Operation | Baseline | Target | Accept |
|-----------|----------|--------|--------|
| Scope matching per file | < 1ms | < 2ms | Per-file validation |
| Ledger query (1000 events) | ? | < 500ms | Audit-ledger command |
| Allocation assignment | ? | < 100ms | Typical task |
| Scope expansion check | < 50 patterns × < 1ms | < 50ms | Pre-write check |

**Benchmark Tasks (T-05, T-24):**
1. Match 1000 files against 50 patterns → expect < 1s
2. Query ledger with 1000 events → expect < 500ms
3. Concurrent writes with allocation checks → expect < 100ms per write

---

## 3.5 Tooling Gap Analysis

### Gaps in Current Implementation

| Gap | Impact | Estimate | Owner |
|-----|--------|----------|-------|
| No batch file checking | Can't pre-validate task files | 2h | T-21 |
| No violation filtering | Hard to debug scope violations | 2h | T-22 |
| No ledger statistics | Can't quickly assess compliance | 1h | T-23 |
| No performance baseline | Can't detect regressions | 2h | T-24 |
| No agent integration | Manual CLI only | 3h | T-25 |
| No snapshot/diff | Can't compare scope versions | 3h | T-26, T-27 |

---

# SECTION 4: EDGE CASES TO TEST

## 4.1 Edge Case Inventory (Ranked by Risk)

### CRITICAL (Must block execution if unhandled)

| Case # | Description | Risk | Test? | Estimate |
|--------|-------------|------|-------|----------|
| **E-01** | Circular specialist delegation (A→B→C→A) | HIGH | ✓ | 2h |
| **E-02** | Scope violation approved, then violated again in same task | HIGH | ✓ | 2h |
| **E-03** | File matches both allowed AND forbidden patterns | HIGH | ✓ | 1h |
| **E-04** | Specialist allocated without grounding bundle | HIGH | ✓ | 1h |
| **E-05** | Specialist output violates task scope | HIGH | ✓ | 2h |
| **E-06** | Scope narrowing that breaks dependent tasks | HIGH | ✓ | 2h |

### HIGH (Should handle gracefully)

| Case # | Description | Risk | Test? | Estimate |
|--------|-------------|------|-------|----------|
| **E-07** | 1000+ tasks with overlapping scopes | MEDIUM | ✓ | 3h |
| **E-08** | Nested specialist delegation (A→specialist.B→specialist.C) | MEDIUM | ✓ | 2h |
| **E-09** | Scope expansion approved by one user, violated by another | MEDIUM | ✓ | 2h |
| **E-10** | Task narrows global scope (safe), but violates another task's expectations | MEDIUM | ✓ | 1.5h |
| **E-11** | Glob pattern ambiguity (e.g., `agents/*.md` vs `agents/*.agent.md`) | MEDIUM | ✓ | 1.5h |
| **E-12** | Ledger corruption or missing events | MEDIUM | ✓ | 1.5h |

### MEDIUM (Edge cases, test if time permits)

| Case # | Description | Risk | Test? | Estimate |
|--------|-------------|------|-------|----------|
| **E-13** | Allocation file not found during check | LOW | ✓ | 0.5h |
| **E-14** | Specialist produces output without evidence | LOW | ✓ | 1h |
| **E-15** | Task assigned to specialist who later rejects it | LOW | ✓ | 1.5h |
| **E-16** | Rollback when specialist output violates scope | LOW | ✓ | 2h |
| **E-17** | Concurrent write attempts to same file | LOW | ✓ | 1.5h |
| **E-18** | Allocation scope with empty allowed_files (only forbidden) | LOW | ✓ | 0.5h |

---

## 4.2 Detailed Edge Case Scenarios

### E-01: Circular Specialist Delegation

**Scenario:**
```yaml
Task T-42:
  specialist: architect
  reason: "Design schema"

Architect output:
  "This needs data engineer input"
  specialist: data-engineer
  
Data engineer output:
  "This needs architect review"
  specialist: architect  # CYCLE!
```

**Expected Behavior:**
1. Detect cycle after 2nd delegation
2. Block execution
3. Ask user: "Cycle detected. Choose resolution:"
   - A. Break cycle: which specialist takes final decision?
   - B. Escalate to human review
   - C. Decompose into separate tasks

**Test Fixture:** `edge-case-circular-delegation.fixture.md`

---

### E-02: Scope Violation Approved Then Violated Again

**Scenario:**
```yaml
Task T-43:
  global_allowed: [agents/, .specs/shared/]
  global_forbidden: [AGENTS.md]
  
Step 1: Write agents/new.agent.md
  → Check: In allowed? YES
  → Write allowed ✓

Step 2: Write AGENTS.md
  → Check: In forbidden? YES
  → Ask user: Approve expansion?
  → User: APPROVE
  → Ledger: scope_expansion_requested (approved)
  → Write allowed ✓

Step 3: Write AGENTS.md again (different content)
  → Check: In forbidden? NO (now in allowed after expansion)
  → Write allowed ✓

Step 4: Validate uses old allocation (before expansion)
  → Check Step 3: Is AGENTS.md in original allowed? NO
  → Report: VIOLATION AFTER APPROVAL
  → ??? Correct behavior?
```

**Expected Behavior:**
1. Allocations are versioned; expansions tracked in ledger
2. Validation uses current state, not original state
3. Ledger shows approval → subsequent writes are within scope

**Test Fixture:** `edge-case-expansion-state-consistency.fixture.md`

---

### E-03: File Matches Both Allowed AND Forbidden

**Scenario:**
```yaml
allowed_files:
  - agents/**/*.md        # All agents
  
forbidden_files:
  - agents/DEFAULT.agent.md
  - agents/test-*.agent.md  # Test agents
  
Query: Is agents/test-custom.agent.md allowed?
  Match allowed: agents/**/*.md? YES
  Match forbidden: agents/test-*.agent.md? YES
  Decision: ???
```

**Current Rule:** "Forbidden overrides allowed"  
**Expected Behavior:** FORBID (forbidden wins)

**Test Fixture:** `edge-case-pattern-overlap.fixture.md`

---

### E-04: Specialist Without Grounding Bundle

**Scenario:**
```yaml
Task T-44:
  owner: altitude-execution
  specialist: dbt-expert  # Allocated
  reason: "Review dbt models"
  # MISSING: grounding_bundle, expected_output, stop_condition
```

**Expected Behavior:**
1. Stop execution
2. Error: "Specialist allocated without grounding bundle"
3. Ask user:
   - A. Provide grounding bundle and retry
   - B. Remove specialist from task
   - C. Redesign task without specialist

**Test Fixture:** `edge-case-missing-grounding.fixture.md`

---

### E-05: Specialist Output Violates Task Scope

**Scenario:**
```yaml
Task T-45:
  allowed: [.specs/shared/]
  specialist: architect
  
Architect output:
  "I created docs/architecture-refactor.md"
  files_created: [docs/architecture-refactor.md]  # NOT in allowed!
  
Validation:
  - Is docs/architecture-refactor.md in allowed? NO
  - Report: "Specialist output violates scope"
  - Action: Rollback specialist changes, ask user
```

**Expected Behavior:**
1. Detect violation immediately
2. Block specialist output acceptance
3. Ask user:
   - A. Approve scope expansion
   - B. Reject specialist output (replan)
   - C. Escalate to security

**Test Fixture:** `edge-case-specialist-scope-violation.fixture.md`

---

### E-06: Scope Narrowing Breaks Dependent Task

**Scenario:**
```yaml
Task T-46 (active):
  allowed: [agents/**, .specs/shared/**]

Task T-47 (queued):
  depends_on: T-46
  expected_files_from_T46: [agents/altitude-execution.agent.md]

During T-46:
  "Narrow scope to: agents/altitude-validation.agent.md only"
  
Task T-47 starts:
  - Expected file: agents/altitude-execution.agent.md
  - Actual files from T-46: [agents/altitude-validation.agent.md]
  - Mismatch! T-47 blocked
```

**Expected Behavior:**
1. T-46 allowed to narrow (safe narrowing)
2. T-47 detects dependency broken
3. Ask user:
   - A. Widen T-46 scope
   - B. Update T-47 expectations
   - C. Replan both tasks

**Test Fixture:** `edge-case-scope-narrowing-dependency.fixture.md`

---

## 4.3 Edge Case Testing Matrix

| Edge Case | Unit Test | Integration | Load Test | Fixture |
|-----------|-----------|-------------|-----------|---------|
| E-01 (circular) | ✓ | ✓ | - | Yes |
| E-02 (violation+approved) | ✓ | ✓ | ✓ | Yes |
| E-03 (overlap patterns) | ✓ | - | - | Yes |
| E-04 (missing grounding) | ✓ | ✓ | - | Yes |
| E-05 (specialist violation) | ✓ | ✓ | - | Yes |
| E-06 (narrowing breaks deps) | - | ✓ | ✓ | Yes |
| E-07 (1000+ tasks) | - | - | ✓ | Yes |
| E-08 (nested delegation) | ✓ | ✓ | - | Yes |
| E-09 (cross-user approval) | ✓ | ✓ | - | Yes |
| E-10 (scope narrowing side-effect) | - | ✓ | - | Yes |
| E-11 (glob ambiguity) | ✓ | - | - | Yes |
| E-12 (ledger corruption) | ✓ | ✓ | - | Yes |

---

# SECTION 5: INTEGRATION TEST SCOPE

## 5.1 Integration Test Scenarios

### Scenario SET 1: Safe Allocation Path

| Test | Description | Preconditions | Steps | Expected | Duration |
|------|-------------|---------------|-------|----------|----------|
| **I-01** | Global allocation created | None | 1. Create global allocation | ✓ Allocation exists | 0.5h |
| **I-02** | Local task allocated within scope | Global exists | 1. Create task 2. Assign files 3. Verify | ✓ Task is assigned | 0.5h |
| **I-03** | File write within scope | Local allocated | 1. Write file 2. Check 3. Verify ledger | ✓ Write allowed, event logged | 1h |
| **I-04** | Task scope narrows global scope | Global exists | 1. Create narrower task 2. Check 3. Verify | ✓ Safe narrowing, allowed | 0.5h |

**Total Duration:** 2.5h

---

### Scenario SET 2: Scope Expansion Path

| Test | Description | Preconditions | Steps | Expected | Duration |
|------|-------------|---------------|-------|----------|----------|
| **I-05** | File write outside scope | Local allocated, file forbidden | 1. Try write 2. Catch error 3. Ask user | ✗ Write blocked | 0.5h |
| **I-06** | Scope expansion approved | Write blocked (I-05) | 1. Approve expansion 2. Verify allocation updated 3. Retry write | ✓ Scope expanded, write allowed | 1h |
| **I-07** | Scope expansion recorded | Expansion approved (I-06) | 1. Query ledger 2. Verify event type 3. Verify decision | ✓ Event logged with approval | 0.5h |
| **I-08** | Scope expansion aborted | Setup like I-05 | 1. Reject expansion 2. Verify task blocked 3. Return to phase start | ✓ Write blocked, task reset | 1h |

**Total Duration:** 3h

---

### Scenario SET 3: Specialist Delegation Path

| Test | Description | Preconditions | Steps | Expected | Duration |
|------|-------------|---------------|-------|----------|----------|
| **I-09** | Specialist allocated with grounding | Task exists | 1. Allocate specialist 2. Provide grounding 3. Verify | ✓ Specialist allocated | 0.5h |
| **I-10** | Specialist output accepted | Specialist allocated (I-09) | 1. Specialist produces output 2. Verify within scope 3. Accept | ✓ Output accepted | 1h |
| **I-11** | Specialist output violates scope | Specialist allocated (I-09) | 1. Specialist produces out-of-scope 2. Detect violation 3. Reject | ✗ Output rejected | 1h |
| **I-12** | Specialist delegation recorded | Output accepted (I-10) | 1. Query ledger 2. Verify specialist events 3. Verify evidence | ✓ Events logged | 0.5h |

**Total Duration:** 3h

---

### Scenario SET 4: Ledger & Audit Path

| Test | Description | Preconditions | Steps | Expected | Duration |
|------|-------------|---------------|-------|----------|----------|
| **I-13** | Ledger consistency | Multiple allocations exist | 1. Run audit-ledger 2. Check event counts 3. Verify no gaps | ✓ Ledger consistent | 0.5h |
| **I-14** | Violation reporting | Violations occurred (I-05, I-11) | 1. Query violations 2. List details 3. Export CSV | ✓ Violations listed with details | 0.5h |
| **I-15** | Scope compliance check | Multiple allocations + writes | 1. Run compliance audit 2. Get summary 3. Verify verdict | ✓ PASS or FAIL with details | 0.5h |
| **I-16** | Ledger versioning | Multiple expansions occurred | 1. Query allocation versions 2. Show timeline 3. Diff versions | ✓ Versions tracked | 1h |

**Total Duration:** 2.5h

---

## 5.2 Integration Test Differences from Unit Tests

| Aspect | Unit Test | Integration Test |
|--------|-----------|------------------|
| **Scope** | Single function/command | Multi-step workflow |
| **Setup** | Mock allocation.yaml | Real allocation files |
| **Execution** | Bash function | CLI commands |
| **Verification** | exit code + stdout | File state + ledger events |
| **Fixtures** | Small examples (10s of lines) | Realistic scenarios (100s of lines) |
| **Duration** | Seconds | Minutes |
| **Dependencies** | Isolated | Full tool chain |

---

## 5.3 Golden Fixture Set 1 (Safe Paths)

**Fixtures to create:**

1. `safe-write-in-allowed.fixture.md` (50 lines)
   - Global: agents/, .specs/shared/
   - Local: agents/test.agent.md
   - Write: agents/test.agent.md
   - Expected: ✓ ALLOW

2. `safe-narrowing-global-to-local.fixture.md` (50 lines)
   - Global: agents/**, .specs/**
   - Local: agents/altitude-execution.agent.md
   - Query: Is local ⊂ global? ✓ YES
   - Expected: ✓ SAFE NARROWING

3. `safe-directory-pattern.fixture.md` (50 lines)
   - Global allowed: .specs/shared/
   - Query: .specs/shared/allocation-contract.md in allowed?
   - Expected: ✓ ALLOW (directory pattern matches)

**Total: 150 lines**

---

## 5.4 Golden Fixture Set 2 (Violations)

**Fixtures to create:**

1. `violation-file-not-in-allowed.fixture.md` (60 lines)
   - Global allowed: agents/, .specs/shared/
   - Query: AGENTS.md in allowed? ✗ NO (not in list)
   - Expected: ✗ DENY (default deny)

2. `violation-file-in-forbidden.fixture.md` (60 lines)
   - Global allowed: agents/
   - Global forbidden: agents/DEFAULT.agent.md
   - Query: agents/DEFAULT.agent.md allowed? ✗ NO (in forbidden)
   - Expected: ✗ FORBID (forbidden overrides)

3. `violation-scope-broadening.fixture.md` (70 lines)
   - Global allowed: agents/, .specs/shared/
   - Local tries: AGENTS.md (outside global)
   - Expected: ✗ REJECT TASK ALLOCATION

**Total: 190 lines**

---

# SECTION 6: LOAD TEST SCOPE

## 6.1 Load Test Targets

### Test 1: 1000+ Task Allocation Assignments

**Goal:** Validate performance with realistic scale

**Setup:**
```yaml
Global allocation:
  allowed_files: [agents/**, .specs/**, tools/**]
  forbidden_files: [config/secrets, .git/]
  
Create: 1000 tasks
  Each with local allocation:
    allowed: subset of global
    forbidden: subset of global
```

**Measurements:**
- Time to assign all 1000 tasks
- Memory usage
- CPU usage
- Allocation check latency per task

**Success Criteria:**
- < 2s to assign all 1000 tasks (< 2ms per task)
- Memory < 100MB
- No errors or timeouts

**Duration:** 2h (setup + execution + analysis)

---

### Test 2: Scope Matching Performance Baseline

**Goal:** Validate pattern matching at scale

**Setup:**
```yaml
Files: 10,000 files across nested directories
Patterns: 50 allow rules, 20 forbid rules
Query: Check each file against allocation
```

**Measurements:**
- Time to check all 10,000 files
- Latency histogram (min/max/p50/p99)
- Cache effectiveness (if caching added)

**Success Criteria:**
- < 100ms to check all 10,000 files (< 10µs per file)
- P99 latency < 50µs
- Consistent performance across patterns

**Duration:** 2h

---

### Test 3: Ledger Query Performance

**Goal:** Validate audit queries at scale

**Setup:**
```yaml
Create: 1000 allocation events in ledger
Include: 100 violations, 50 expansions, 850 allowed
Query: audit-ledger, query-violations, export CSV
```

**Measurements:**
- Time to query all events
- Time to filter violations
- Time to export CSV

**Success Criteria:**
- audit-ledger: < 500ms
- query-violations: < 200ms
- export CSV: < 1s

**Duration:** 1.5h

---

### Test 4: Concurrent Allocation Conflicts

**Goal:** Validate behavior under concurrency

**Setup:**
```yaml
Concurrent tasks: 100 parallel writes
Each trying to write to different files
Some files violate allocation
Measurement: How many conflicts, resolution time
```

**Measurements:**
- Number of conflicts detected
- Number of false positives/negatives
- Resolution time per conflict
- Memory under concurrent load

**Success Criteria:**
- 100% conflict detection (no false negatives)
- < 1% false positives
- Resolution < 100ms per conflict
- Memory < 200MB

**Duration:** 2h

---

## 6.2 Load Test Fixtures

### Fixture 1: 1000-Task Allocation

```yaml
filename: load-test-1000-tasks.fixture.md

global_allocation:
  allowed_files:
    - agents/**/*.md
    - .specs/**/*.md
    - tools/**/*.sh
  forbidden_files:
    - agents/DEFAULT.agent.md
    - config/secrets/**
    
tasks: 1000
  - task_id: T-1 to T-1000
    allowed: random subset of global
    owner: altitude-execution
```

**Size:** ~50 lines + generated 1000 task entries

---

### Fixture 2: 10K Files + Pattern Matching

```yaml
filename: load-test-10k-files.fixture.md

files:
  - agents/altitude-execution.agent.md
  - agents/altitude-validation.agent.md
  - ...
  - (10,000 total)
  
patterns: 50 allow + 20 forbid rules

queries: check each file
```

**Size:** ~10,000 lines (generated)

---

### Fixture 3: 1000-Event Ledger

```yaml
filename: load-test-1000-event-ledger.md

allocation_events:
  - event_id: allocation-event-1
    timestamp: 2026-07-01T...
    type: allocation_assigned
    ...
  - event_id: allocation-event-2
    timestamp: 2026-07-02T...
    type: file_write_allowed
    ...
  # ... 1000 total
```

**Size:** ~2,000 lines

---

# SECTION 7: AGENTS.md UPDATE REQUIREMENTS

## 7.1 Current AGENTS.md Allocation-Related Sections

**Section 3: Source of Truth Hierarchy**
- Line 71-86: Defines priority of allocation as level 3 and 4

**Section 4: Repository Reference Map**
- Line 97: References `.specs/shared/<domain>-contract.md` for allocation

**Section 5: Primary Coordinators**
- Line 112: Altitude owns "allocation, Task-Spec handoff, specialist allocation"
- Line 119: Data Engineer owns "local allocation, specialist selection"

**Section 8: Execution Rules**
- Line 172: Lists "allocation resolved" as requirement

**Section 12: Activation Gates**
- Line 252: "local allocation broadens global allocation" is a GATE

---

## 7.2 Allocation Gaps in AGENTS.md

| Gap | Location | Current | Required | Impact |
|-----|----------|---------|----------|--------|
| No allocation checklist | Section 5.1 | None | Pre-execution checklist | HIGH |
| No specialist matrix | Section 5.2 | Generic | Specialist assignment rules | MEDIUM |
| No scope narrowing rules | Section 8 | Generic "allocation resolved" | Explicit narrowing/broadening guide | MEDIUM |
| No tool reference | Section 4 | Lists tools dir | allocation-check.sh commands + usage | LOW |
| No escalation flow | Section 7 | Generic QUESTION | Scope expansion decision tree | MEDIUM |
| No ledger query examples | None | None | How to audit allocation events | LOW |

---

## 7.3 Proposed AGENTS.md Updates

### Update 1: Allocation Execution Checklist (Section 8.2, NEW)

**Location:** After Section 8 (Execution Rules)

```markdown
### 8.1 Allocation Execution Checklist

Before executing any task with allocation, verify:

- [ ] Global allocation exists or task is explicitly standalone
- [ ] Local allocation defined with allowed_files AND forbidden_files
- [ ] Verification path is concrete (not "looks good")
- [ ] Evidence can be recorded (not chat memory only)
- [ ] Any specialist support has: reason, scope, evidence, stop condition
- [ ] Any specialist has grounding bundle
- [ ] No circular specialist delegation
- [ ] Scope narrowing (if any) does not break dependent tasks

If any box is unchecked, STOP and fix before execution.
```

**Estimate:** 1h (T-02)

---

### Update 2: Specialist Assignment Matrix (Section 5.2, EXPAND)

**Location:** Expand current Section 5.2 (Data Engineer coordinator)

```markdown
### 5.2.1 Specialist Allocation Rules

When to allocate a specialist:
- [ ] Task crosses high-risk domain (security, architecture, data quality)
- [ ] Owner lacks domain-specific context
- [ ] Independent review materially reduces risk
- [ ] Specialist is mandated by policy

When NOT to allocate:
- [ ] Owner already has enough context & task is low-risk
- [ ] Delegation cost > direct execution
- [ ] Scope is unclear
- [ ] No evidence can be requested from specialist
- [ ] Specialist would become real task owner (over-delegation)

Specialist Matrix:

| Specialist | Domains | Allocation Type | Grounding Required |
|-----------|---------|------------------|-------------------|
| architect | architecture, design, refactor | Optional | Yes |
| security | auth, RLS, secrets, PII | Mandatory | Yes |
| dbt-expert | dbt models, SQL logic | Optional | Yes |
| data-engineer | data pipeline, quality | Optional | Yes |
| performance | optimization, scale | Optional | Yes |
| test-expert | test design, coverage | Optional | Yes |
```

**Estimate:** 1h (T-02)

---

### Update 3: Scope Narrowing/Broadening Guide (Section 8.3, NEW)

**Location:** After Execution Checklist

```markdown
### 8.2 Scope Narrowing vs Broadening

#### Safe: Narrowing Global to Local Scope

Example:
```yaml
Global allowed: [agents/**, .specs/**, tools/**]
Local allowed: [agents/altitude-execution.agent.md]

Check: Is local ⊂ global?
  agents/altitude-execution.agent.md ⊂ agents/** ? YES
Result: ✓ SAFE — no approval needed
```

#### Unsafe: Broadening Beyond Global Scope

Example:
```yaml
Global allowed: [agents/, .specs/shared/]
Global forbidden: [AGENTS.md]

Task tries: write AGENTS.md
Check: Is AGENTS.md in global allowed? NO
Check: Is AGENTS.md in global forbidden? YES

Result: ✗ UNSAFE BROADENING — ask user before proceeding
```

#### Escalation Flow (Scope Expansion)

When a write violates global scope:

1. Block write
2. Ask user (QUESTION method):
   - A. Approve scope expansion (update allocation)
   - B. Abort write (return to phase start)
   - C. Escalate to security specialist
3. Record decision in ledger: `scope_expansion_requested`
4. If approved: update allocation + allow write
5. If aborted: stop task + return to Design/Plan phase
```

**Estimate:** 2h (T-02, T-08)

---

### Update 4: Tool Reference (Section 4, EXPAND)

**Location:** Expand "Custom tool registry" row in Section 4

```markdown
### 4.1 Allocation Tooling

**Tool:** `tools/allocation-check.sh`  
**Purpose:** Enforce file-level allocation scope boundaries

**Commands:**
- `check-file <file> <allocation.yaml>` — Is file allowed?
- `validate-scope <ledger.md> <change_id>` — Audit allocation compliance
- `query-violations <ledger.md>` — List scope violations
- `expand-allocation <old.yaml> <new_files>` — Show scope delta

**Usage:**
```bash
# Pre-write check (used by agents)
if ! tools/allocation-check.sh check-file "$FILE" allocation.yaml; then
    question "Approve scope expansion?" # Harness will ask user
fi

# Post-execution audit
tools/allocation-check.sh validate-scope .specs/changes/wave-5/03-execution-ledger.md wave-5
```

**Reference:** `.specs/shared/allocation-enforcement-contract.md`
```

**Estimate:** 1h (T-02)

---

### Update 5: Ledger Query Examples (NEW SECTION)

**Location:** New section after "Validation Rules Summary" (post-Section 8)

```markdown
### 8.3 Allocation Ledger Queries

**Purpose:** Audit allocation events recorded during task execution

**Query Examples:**

```bash
# List all scope violations in a change
tools/allocation-check.sh query-violations .specs/changes/wave-5/03-execution-ledger.md

# Export allocation events as CSV
tools/allocation-check.sh validate-scope .specs/changes/wave-5/03-execution-ledger.md wave-5 --export-csv

# Verify no specialist was allocated without grounding
rg "specialist.*without.*grounding" .specs/changes/wave-5/03-execution-ledger.md

# Show scope expansion timeline
rg "scope_expansion_requested" .specs/changes/wave-5/03-execution-ledger.md | sort
```

**Reference:** `.specs/shared/allocation-ledger-contract.md`
```

**Estimate:** 1h (T-08)

---

## 7.4 AGENTS.md Update Effort

| Update | Lines | Effort | Priority | Owner |
|--------|-------|--------|----------|-------|
| Execution Checklist | 15 | 1h | HIGH | T-02 |
| Specialist Matrix | 25 | 1h | HIGH | T-02 |
| Scope Guide | 40 | 2h | HIGH | T-02, T-08 |
| Tool Reference | 20 | 1h | MEDIUM | T-02 |
| Ledger Queries | 20 | 1h | MEDIUM | T-08 |
| **TOTAL** | **120** | **6h** | - | Parallel |

---

# SECTION 8: CONSOLIDATED PLAN

## 8.1 Wave 25A Critical Path (Detailed)

```
PHASE 1: ANALYSIS (27h serial / 8h parallel)
├─ T-01: Contract Consolidation Analysis (4h)
│  └─ Output: Redundancy report, option analysis
├─ T-02/T-03/T-06/T-08 (parallel, 4h)
│  ├─ T-02: Tool Requirements Audit (3h)
│  │  └─ Output: Commands, performance targets
│  ├─ T-03: Edge Case Inventory (3h)
│  │  └─ Output: 18 edge cases ranked by risk
│  ├─ T-06: Specialist Review (2h)
│  │  └─ Output: Specialist matrix, grounding rules
│  └─ T-08: AGENTS.md Audit (2h)
│     └─ Output: 6 gap areas, 120 lines of updates
├─ T-07: Testing Strategy (4h)
│  └─ Inputs: T-03, T-04
│  └─ Output: Integration + load test plans
├─ T-09: Decision Document (3h)
│  └─ Inputs: T-01..T-08
│  └─ Output: Recommendation + trade-offs
└─ T-10: User Decision Gate ⏹️ (user approval needed)
   └─ Decision: Option A/B/C for consolidation strategy

PHASE 2: CONTRACT DESIGN (34h serial / 14h parallel)
├─ T-11: allocation-contract.md V2 (6h)
│  └─ Output: 250 lines, merged + clarified
├─ T-12: enforcement-ledger-contract.md V2 (5h)
│  └─ Inputs: T-11
│  └─ Output: 350 lines, split from current 846
├─ T-13: specialist-contract.md V2 (4h)
│  └─ Inputs: T-11, T-12
│  └─ Output: 150 lines, refined + linked
├─ T-14: Migration Path (3h)
│  └─ Inputs: T-11, T-12, T-13
│  └─ Output: Backward compatibility guide
├─ T-15: Tool Contract V2 (4h)
│  └─ Inputs: T-02, T-12
│  └─ Output: 400 lines, expanded commands
├─ T-16/T-17 (parallel, 4h)
│  ├─ T-16: Golden Fixture Set 1 (4h)
│  │  └─ Output: 150 lines, 3 safe path fixtures
│  └─ T-17: Golden Fixture Set 2 (4h)
│     └─ Output: 190 lines, 3 violation fixtures
├─ T-18: Integration Test Spec (3h)
│  └─ Inputs: T-16, T-17
│  └─ Output: 16 test scenarios, 11 hours
├─ T-19: Load Test Spec (3h)
│  └─ Inputs: T-05, T-18
│  └─ Output: 4 load tests, performance targets
└─ T-20: Review & Approval Gate ⏹️
   └─ Decision: Approve design artifacts

PHASE 3: TOOLING (23h serial / 10h parallel)
├─ T-21: allocation-check.sh: validate-scope (3h)
│  └─ Inputs: T-15
│  └─ Output: Enhanced validation command
├─ T-22: query-violations command (3h)
│  └─ Inputs: T-15
│  └─ Output: New filtering command
├─ T-23: ledger-stats command (2h)
│  └─ Inputs: T-15
│  └─ Output: New reporting command
├─ T-24: Performance tests (4h)
│  └─ Inputs: T-19
│  └─ Output: Benchmark suite, baseline numbers
├─ T-25: Agent integration (2h)
│  └─ Inputs: T-21
│  └─ Output: Agent helper functions
├─ T-26: allocation-snapshot.sh (3h)
│  └─ Inputs: T-12
│  └─ Output: Versioning tool
├─ T-27: allocation-diff.sh (2h)
│  └─ Inputs: T-12, T-26
│  └─ Output: Comparison tool
├─ T-28: Tool Documentation (2h)
│  └─ Inputs: T-21..T-27
│  └─ Output: CLI reference
├─ T-29: Tool Integration Test (3h)
│  └─ Inputs: T-21..T-27
│  └─ Output: Test suite, all commands verified
└─ T-30: Approval Gate ⏹️
   └─ Decision: Tool release ready

PHASE 4: VALIDATION (16h serial / 7h parallel)
├─ T-31: Integration Test Execution (4h)
│  └─ Inputs: T-20, T-29
│  └─ Output: 16 tests passed, evidence
├─ T-32: Load Test Execution (5h)
│  └─ Inputs: T-20, T-24
│  └─ Output: 1000+ tasks, performance verified
├─ T-33: Edge Case Execution (4h)
│  └─ Inputs: T-31, T-32
│  └─ Output: 18 edge cases tested
├─ T-34: Validation Report (2h)
│  └─ Inputs: T-31, T-32, T-33
│  └─ Output: Executive summary, evidence links
└─ T-35: Ship & Deploy (1h)
   └─ Inputs: T-34
   └─ Output: Contracts merged, tools released, AGENTS.md updated
```

---

## 8.2 Timeline & Resource Planning

### Execution Pace

**Conservative (2 weeks, 8h/day = 80h available):**
- Phase 1: Days 1-2 (27h serial reduced to 8h parallel ≈ 10h actual)
- Phase 2: Days 3-5 (34h → 14h actual ≈ 16h actual)
- Phase 3: Days 6-7 (23h → 10h actual ≈ 12h actual)
- Phase 4: Days 8-10 (16h → 7h actual ≈ 8h actual)
- **Contingency:** Days 11-14 (reserve for rework)

**Aggressive (1 week, 10h/day = 50h available):**
- Not recommended due to QUESTION gates + user decision time
- Would compress phases but increase risk of rework

### Resource Allocation

| Phase | Altitude | Data Engineer | Security | Other | Total |
|-------|----------|---------------|----------|-------|-------|
| Phase 1 (Analysis) | 20h | 5h | 2h | - | 27h |
| Phase 2 (Design) | 28h | 4h | 2h | User: 5h | 34h + gates |
| Phase 3 (Tooling) | 20h | 3h | - | - | 23h |
| Phase 4 (Testing) | 14h | 2h | - | - | 16h |
| **TOTAL** | **82h** | **14h** | **4h** | **5h** | **100h + gates** |

---

## 8.3 Unresolved Questions (For User Input)

| Question | Impact | Decision Needed |
|----------|--------|-----------------|
| **Q1: Consolidation strategy** | Affects Phase 2 effort by 30-50% | Choose Option A/B/C (T-10) |
| **Q2: Merge ledger or split?** | Affects contract organization | Option B recommended (split) |
| **Q3: Todo projection location** | Affects allocation vs execution-loop | Recommend: keep in enforcement |
| **Q4: Tool scope (batch vs CLI)** | Affects T-21-T-27 effort | Must decide scope by T-10 |
| **Q5: Load test target (1000 vs 10k)** | Affects T-24, T-32 effort | 1000 recommended initially |

---

# SECTION 9: EDGE CASE RISK RANKING

## 9.1 Risk Matrix

```
        ↑ IMPACT
        │
     HighImpact
        │
        │ E-01: Circular specialist (blocker)
        │ E-02: Approved then violated (data integrity)
        │ E-05: Specialist scope violation (trust)
        │
        │ E-03: Overlapping patterns (confusion)
        │ E-04: Missing grounding (safety)
        │ E-06: Narrowing breaks deps (dependency)
        │
        │ E-07: 1000+ tasks (scale)
        │ E-08: Nested delegation (complexity)
        │ E-09: Cross-user approval (multi-tenancy)
        │
     LowImpact
        │ E-10-E-18: Various...
        │
        └────────────────────────────────────────→
               LOW LIKELIHOOD       HIGH LIKELIHOOD
```

---

## 9.2 Test Priority (By Risk)

| Rank | Edge Case | Likelihood | Impact | Effort | Priority |
|------|-----------|-----------|--------|--------|----------|
| 1 | E-01 Circular delegation | Medium | CRITICAL | 2h | MUST-TEST |
| 2 | E-02 Approved then violated | Medium | CRITICAL | 2h | MUST-TEST |
| 3 | E-05 Specialist violates scope | Medium | HIGH | 2h | MUST-TEST |
| 4 | E-03 Pattern overlap | High | MEDIUM | 1h | MUST-TEST |
| 5 | E-04 Missing grounding | Medium | HIGH | 1h | MUST-TEST |
| 6 | E-06 Narrowing breaks deps | Low | MEDIUM | 2h | SHOULD-TEST |
| 7 | E-07 1000+ tasks | Low | MEDIUM | 3h | SHOULD-TEST |
| 8 | E-08 Nested delegation | Low | MEDIUM | 2h | SHOULD-TEST |
| 9-18 | Others | Low | LOW | 1-2h | NICE-TO-TEST |

---

# SECTION 10: RESOURCE NEEDS SUMMARY

## 10.1 Skills Required

| Skill | Tasks | Effort | Owner |
|-------|-------|--------|-------|
| Harness architecture | T-01, T-09, T-11 | 8h | Altitude required |
| Bash/shell scripting | T-21-T-27 | 15h | Altitude required |
| Contract design | T-12-T-15 | 16h | Altitude required |
| Test design | T-07, T-18, T-19 | 8h | Altitude required |
| YAML/data structures | T-12, T-26, T-27 | 8h | Altitude required |
| Performance testing | T-05, T-24, T-32 | 8h | Data Engineer optional |
| Security review | T-06, gates | 4h | Security optional |

---

## 10.2 Tools & Infrastructure

| Tool | Purpose | Status | Needed |
|------|---------|--------|--------|
| `yq` | YAML queries | ✅ Installed | ✓ |
| `bash` | Shell scripting | ✅ Installed | ✓ |
| `ripgrep (rg)` | Content search | ✅ Installed | ✓ |
| `git` | Version control | ✅ Installed | ✓ |
| Load testing framework | Performance tests | ⚠️ May need | ? |
| Benchmark tool | Baseline capture | ⚠️ May need | ? |

---

## 10.3 Decision Gates (User Input Required)

| Gate | When | What | Effort |
|------|------|------|--------|
| **T-10** | After Phase 1 | Approve consolidation strategy | 1h user decision |
| **T-20** | After Phase 2 | Approve contracts + fixtures | 1-2h user review |
| **T-30** | After Phase 3 | Approve tool commands + performance | 1h user decision |
| **T-35** | After Phase 4 | Approve ship | 30m user final check |

---

# SECTION 11: FINAL RECOMMENDATION

## 11.1 Wave 25A Consolidated Plan

**Scope:** Allocation system consolidation from fragmented to unified, tested framework

**Duration:** 2 weeks (80 work hours) + 5 hours user decision gates

**Phases:**
1. Analysis (Phase 1) — Define consolidation strategy
2. Design (Phase 2) — Create contracts + fixtures
3. Tooling (Phase 3) — Build allocation-check.sh enhancements + new tools
4. Validation (Phase 4) — Execute tests + finalize

**Critical Success Factors:**
1. User decision at T-10 (consolidation strategy)
2. Clear test fixtures (T-16, T-17, T-19)
3. Tool performance baseline (T-24)
4. Complete AGENTS.md updates (T-08, T-02)

**Deliverables:**
- ✅ 5-6 allocation contracts (merged + clearer)
- ✅ 5 new/enhanced tool commands
- ✅ 16 integration test scenarios
- ✅ 4 load test suites
- ✅ 18 edge case fixtures
- ✅ AGENTS.md updates (120 lines)
- ✅ Full documentation & evidence

---

## 11.2 Next Steps

1. **Review this audit** — User reads SECTION 1-10
2. **QUESTION: T-10 Decision** — User decides consolidation strategy (A/B/C)
3. **Allocate resources** — Assign Altitude, Data Engineer if needed
4. **Create change artifact** — `.specs/changes/wave-25a-allocation-consolidation/`
5. **Start Phase 1** — Execute T-01 through T-09
6. **Gate T-10** — User approves before Phase 2

---

