# ADR — Harness V3 Waves 18-23 Refinement

**Document ID:** waves-18-23-adr  
**Date:** 2026-06-30  
**Owner:** Altitude Coordinator  
**Status:** Draft → Review → Approved  

---

## Executive Summary

This ADR documents **2 major architectural decisions** for Waves 18-23:

1. **Unify coordinators into single agent** (not keep two)
2. **Restructure agents for decision clarity** (not leave buried)

Each decision includes rationale, trade-offs, and consequences.

---

## Decision 1: Unified Coordinator (altitude-maestro.agent.md)

### Problem

Two Altitude agents exist with overlapping responsibilities:
- `altitude.agent.md` (248 lines): classifies requests, routes to phases
- `altitude-coordinator.agent.md` (475 lines): orchestrates multi-wave execution

This duplication causes:
- Confusion about which agent to call
- Duplicated logic (Recovery Protocol, Ask-User patterns)
- Unclear ownership of orchestration vs. classification

### Decision

**Create single unified `altitude-maestro.agent.md` (~600 lines) that:**
1. Performs request classification (new/resume/tactical/visual/readme/multi-wave)
2. Performs phase routing (to altitude-intent/structure/plan/execution/validation/report/memory)
3. Performs multi-wave orchestration (compute DAG, schedule waves, monitor status)
4. Implements all 6 phase gates (state resolution, classification, validation, design-4-doc, orchestration, execution-ready)

**Deprecate but archive:**
- `altitude.agent.md` (mark DEPRECATED, link to maestro)
- `altitude-coordinator.agent.md` (mark DEPRECATED, link to maestro)

### Rationale

**Why unify?**
- **Separation of concerns failed**: Two agents doing overlapping work violates DRY principle
- **Lessons-learned lesson**: "Two coordinators create confusion; one maestro is clearer"
- **Gate routing unified**: Both orchestration and classification use same gates, easier to implement in one place
- **User experience**: Single entry point is simpler than choosing between two agents

**Why not keep two?**
- Code duplication: Recovery protocol, Ask-user patterns, Stop conditions repeated in both
- Maintenance burden: Bug fix in one agent might be missed in other
- Testing complexity: Fixtures must cover both paths
- Scalability: W24+ waves harder to add if orchestration is separate

### Alternatives Considered

**Option A (Rejected): Keep separate, add broker**
- Create `altitude-router.agent.md` that chooses between altitude.agent and altitude-coordinator
- **Con:** Adds third agent, more complex, still duplicated logic

**Option B (Rejected): Keep altitude-coordinator, remove altitude.agent**
- Make altitude-coordinator the primary, route to phase agents
- **Con:** altitude-coordinator is newer (W13), more experimental; altitude.agent is baseline

**Option C (Chosen): Create unified altitude-maestro.agent.md**
- Merge best of both agents into new, clean agent
- Preserve baseline (keep old agents as DEPRECATED reference)
- **Pro:** Fresh start, combines known-good patterns, clearer intent

### Consequences

**Positive:**
- ✅ Single entry point for all Altitude work
- ✅ Reduced code duplication (~490 lines saved)
- ✅ Easier to implement gates uniformly
- ✅ Clearer governance model

**Negative:**
- ❌ New agent to maintain instead of two
- ❌ W7-17 archived code might reference old agents (mitigated by keeping as DEPRECATED)
- ❌ Migration burden: any code calling altitude.agent directly needs to call maestro instead

**Mitigations:**
- Keep altitude.agent.md as reference (marked DEPRECATED)
- Create migration guide in docs/
- Run fixtures to ensure backward compatibility with archived changes

### Status
**Approved** (by this design document)

---

## Decision 2: Restructure Agents for Decision Clarity (Decision Map)

### Problem

Critical decisions are scattered throughout agent files, causing "lost-in-the-middle" effect:

- `altitude-execution.agent.md` (739 lines): 10 critical Wave decisions starting at line 45
- Reader: "OK, execution agent... oh wait, Wave 4 artifact versioning? I need to know this?"
- Reader: "Where's the security gate? Line 207? Buried!"
- Maintainer: "Did I miss any critical decision?"

**Consequence:** Decisions get missed, maintenance is hard, code is hard to audit.

### Decision

**Restructure all agents >200 lines with DECISION MAP at top:**

```
Structure:
  Lines 1-40: Mission + Recovery Protocol
  Lines 41-200: *** DECISION MAP (ALL critical gates with line refs) ***
  Lines 201-N: Detailed implementation (by wave or section)
```

**Apply to:**
- `altitude-maestro.agent.md` (new): Decision map lines 50-200 (Gates 1-6)
- `altitude-execution.agent.md` (restructure): Decision map lines 40-100, then details
- `altitude-plan.agent.md` (add): Decision map for design phase gates

### Rationale

**Why decision map matters:**
- **Visibility:** Readers know what critical decisions exist before reading 700 lines
- **Auditability:** Inspectors can quickly scan all decisions
- **Maintenance:** Developers know where to find/add gates
- **Lessons-learned:** Prevents "lost-in-the-middle" from W7-17

**Pattern from successful codebases:**
- Linux kernel: README at top, architecture docs, then code
- Python: docstrings explain intent before code
- Kubernetes: CRD has "status" and "spec" sections clearly separated

### Alternatives Considered

**Option A (Rejected): No restructuring, leave buried**
- Keep decisions scattered
- **Con:** Repeats W7-17 problem

**Option B (Rejected): Separate decision file**
- Create `altitude-execution-DECISIONS.md` file
- **Con:** Separate file gets outdated, not reviewed with code

**Option C (Chosen): Decision map at top of agent**
- Inline decisions with line references, details below
- **Pro:** Single source of truth, visible when agent loaded, easy to audit

### Consequences

**Positive:**
- ✅ Critical decisions visible in first ~200 lines
- ✅ Readers confident they haven't missed anything
- ✅ Audit trail clear
- ✅ Easier to find/add new gates

**Negative:**
- ❌ Agent files slightly longer (but more navigable)
- ❌ Decision map must be maintained when gates change
- ❌ Readers must scroll less but understand decisions are detailed below

**Mitigations:**
- Add table-of-contents to decision map with line numbers
- Document decision map as required pattern for agents >200 lines
- Create linter to validate decision maps exist and line numbers are accurate

### Status
**Approved** (by this design document)

---

## Cross-Cutting Decisions

### Decision: Apply All 6 Lessons from W7-17

**Lesson 1 (Design 4-doc):** Implemented in altitude-plan.agent.md (design gate)  
**Lesson 2 (Task-spec):** Mandate skill:task-spec in altitude-plan (altitude-plan design docs)  
**Lesson 3 (Ask-user policy):** User maintains freedom to ask when context needed (no enforcement gate)  
**Lesson 4 (Allocation):** Verify Wave 5 pre-write checks working (test execution)  
**Lesson 5 (Security):** Verify Wave 9 pre-write checks working (test execution)  
**Lesson 6 (Lost-in-middle):** Decision map implementation (Decision 2)  

**Rationale:** Lessons learned file explicitly recommends these fixes. BEFORE Waves 18-23 execution, all 6 must be in place.

---

## Summary Table

| Decision | Type | Impact | Status |
|----------|------|--------|--------|
| Unify coordinators | Architecture | HIGH (single agent) | ✅ Approved |
| Decision map | UX | MEDIUM (clarity) | ✅ Approved |
| Apply 6 lessons | Ops | HIGH (prevent errors) | ✅ Approved |

---

## Next Steps (Implementation)

1. ✅ PRD.md (this design phase — requirements defined)
2. ⏳ TEST-SPEC.md (validation strategy + fixtures)
3. ⏳ DESIGN.md (technical implementation details)
4. ⏳ Execution (implement altitude-maestro, add gates, restructure agents)
5. ⏳ Validation (run fixtures, verify gates work)
6. ⏳ Shipping (merge PRs, archive, update memory)

---

## References

- `.specs/shared/phase-engine-contract.md` (design phase definition)
- `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md` (source of decisions)
- `agents/altitude.agent.md` (to be unified)
- `agents/altitude-coordinator.agent.md` (to be unified)

---
