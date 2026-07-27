# Intent — Harness V3 Waves 18-23 Refinement

**Date:** 2026-06-30  
**Author:** Altitude Coordinator  
**Confidence:** 0.92  

---

## 📋 Problem Statement

The Harness V3 self-refactoring (Waves 7-17) completed successfully with **92/100 validation score**. However, post-execution analysis identified governance gaps that will repeat in Waves 18-23 unless corrected:

### Problems Discovered

1. **Coordinator Duplication**: Two separate agents (`altitude.agent.md` + `altitude-coordinator.agent.md`) exist with overlapping responsibilities. Single maestro needed.

2. **Lessons Learned Not Applied**: File `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md` documents 6 critical learnings but is not loaded/enforced by any agent:
   - **Lesson 1:** Design phase incomplete (missing PRD, ADR, TEST-SPEC — only DESIGN.md created)
   - **Lesson 2:** Task-Spec compliance only 85% (should be 100%)
   - **Lesson 3:** Ask-user over-used (12 calls vs 5 necessary, 140% over)
   - **Lesson 4-6:** Allocation + security + recovery patterns exist but documentation poor

3. **Gates Not Enforced**: Phase gates defined in contracts but not validated in code:
   - Design 4-doc gate: Not enforced → allowed incomplete design phase
   - Ask-user policy: Not validated → unnecessary asks

4. **Lost-in-the-Middle**: Critical decisions buried in agent files:
   - `altitude-execution.agent.md`: 10 critical Wave decisions scattered in 739 lines
   - Decision readers lose context after line 40

### Impact on Waves 18-23

- **High Risk:** Same governance gaps will repeat (incomplete design phase, task-spec issues, ask-user over-use)
- **Medium Risk:** Decision clarity poor, maintainability low
- **Low Risk:** Execution quality good (Waves 7-17 proof)

---

## 🎯 Goal

**Unify coordinators + enforce gates + apply lessons learned** so that Waves 18-23 execution is both **CORRECT** (follows contracts) and **CLEAR** (decisions visible, steps traced).

**Success Criteria:**
1. ✅ Single unified `altitude-maestro.agent.md` (consolidates request classification + orchestration)
2. ✅ Design 4-doc gate enforced (blocks decomposition until PRD+ADR+TEST-SPEC+DESIGN exist)
3. ✅ Lessons learned file applied (6 learnings integrated into agent behavior)
4. ✅ Decision clarity improved (critical gates visible in first 200 lines of agents)

---

## 👥 Stakeholders

- **Altitude Coordinator** (Harness orchestrator)
- **Phase Agents** (intent, structure, plan, execution, validation, report, memory)
- **Waves 18-23 Execution** (depends on corrected design phase)
- **Future Waves** (W24+) should benefit from governance fixes

---

## 🚫 Non-Goals

- Rewrite all agents (only Altitude family + restructuring)
- Replace validation system (only gate enforcement added)
- Complete rewrite of tools (only validation integrated)

---

## ⚠️ Constraints

1. **Backward Compatibility**: Waves 7-17 already shipped. Must not break archived changes.
2. **Phase Integrity**: Must respect phase model (Intent → Structure → Design → Execution → Validate → Ship)
3. **No Speculative Features**: Only implement fixes documented in WAVES-7-17-LESSONS-LEARNED.md
4. **Gate Enforcement**: Gates must be STRONG (block execution) not just advisory

---

## 📊 Scope

### IN SCOPE (This Change)

- Create unified `altitude-maestro.agent.md` (~600 lines)
- Implement Design 4-doc gate in `altitude-plan.agent.md`
- Restructure `altitude-execution.agent.md` for decision clarity
- Create this Design/Plan phase with 4 full artifacts (PRD+ADR+TEST-SPEC+DESIGN)
- Apply 6 lessons from WAVES-7-17-LESSONS-LEARNED.md

### OUT OF SCOPE (Future Changes)

- Refactor non-Altitude agents
- Rewrite tools (only integrate validation)
- Waves 18-23 actual implementation (this is just the design)
- KB or documentation updates (only use existing)

---

## 📈 Success Metrics

| Metric | Target | Current | Gap |
|--------|--------|---------|-----|
| Design 4-doc enforcement | YES | NO | Implement |
| Ask-user policy validation | YES | NO | Implement |
| Lessons learned loaded | YES | NO | Implement |
| Decision clarity (agents >200 lines) | Top 50 lines | Scattered | Restructure |
| Phase gate count | 6+ gates | 3-4 | Implement 2-3 more |

---

## 🔗 Related Documents

- `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md` (source of corrections)
- `.specs/shared/phase-engine-contract.md` (design phase requirements)
- `.specs/shared/ask-user-policy.md` (ask-user rules)
- `agents/altitude.agent.md` (to be unified)
- `agents/altitude-coordinator.agent.md` (to be unified)

---

## ✅ Next Phase: Design/Plan

Will create:
1. **PRD.md** — Detailed requirements
2. **ADR.md** — Architectural decisions
3. **TEST-SPEC.md** — Validation strategy
4. **DESIGN.md** — Technical implementation plan

Then move to Structure → Execution → Validation → Shipping.

---
