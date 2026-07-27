# PRD — Harness V3 Waves 18-23 Refinement

**Document ID:** waves-18-23-prd  
**Date:** 2026-06-30  
**Owner:** Altitude Coordinator  
**Status:** Draft → Review → Approved  

---

## Executive Summary

Harness V3 Waves 7-17 shipped with 92/100 validation score, but governance gaps discovered in lessons-learned file must be fixed BEFORE Waves 18-23 to prevent repetition. This PRD defines **corrective requirements** for:

1. **Unified Coordination** — Single maestro agent instead of two
2. **Design 4-Doc Gate** — Blocks incomplete design phases (PRD+ADR+TEST-SPEC+DESIGN required)
3. **Applied Lessons** — 6 corrections from W7-17 integrated into code
4. **Clear Decisions** — Critical gates moved to top of agents

---

## 📋 Requirements

### Requirement 1: Unify Coordinators

**Description:** Replace duplicate `altitude.agent.md` and `altitude-coordinator.agent.md` with single unified `altitude-maestro.agent.md`

**Rationale:**
- Two agents with overlapping responsibility cause confusion
- Request classification (altitude.agent) + orchestration (altitude-coordinator) should be unified
- Lessons-learned file recommends consolidation for clarity

**Acceptance Criteria:**
- [ ] `altitude-maestro.agent.md` exists (~600 lines)
- [ ] Performs request classification (new/resume/tactical/visual/readme/multi-wave)
- [ ] Performs multi-wave orchestration (W13+ scheduling)
- [ ] Routes to appropriate phase agents (intent/structure/plan/execution/validation/report/memory)
- [ ] Single entry point for all Altitude work
- [ ] `altitude.agent.md` marked DEPRECATED
- [ ] `altitude-coordinator.agent.md` marked DEPRECATED

**Priority:** HIGH  
**Complexity:** MEDIUM  

---

### Requirement 2: Design 4-Doc Gate Enforcement

**Description:** Enforce gate that blocks Design → Execution transition unless PRD, ADR, TEST-SPEC, and DESIGN all exist

**Rationale:**
- **Lesson 1 from W7-17:** Design phase only created DESIGN.md (missing PRD, ADR, TEST-SPEC)
- Incomplete design phase caused governance gaps (requirements not formal, trade-offs not documented, validation strategy not explicit)
- Gate should be STRONG (blocks, not warns)

**Acceptance Criteria:**
- [ ] Gate implemented in `altitude-plan.agent.md` (pre-decomposition check)
- [ ] Validates: PRD.md exists AND ADR.md exists AND TEST-SPEC.md exists AND DESIGN.md exists
- [ ] If any missing: blocks decomposition, asks user to create via template
- [ ] If all exist: allows phase transition to Execution
- [ ] Gate is testable (fixture passes/fails deterministically)
- [ ] Blocks Waves 18-23 from repeating W7-17 mistake

**Priority:** CRITICAL  
**Complexity:** LOW  

---

### Requirement 3: Lessons Learned Applied

**Description:** File `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md` (461 lines) documents 6 lessons; all must be integrated into agent behavior/code/gates

**Rationale:**
- Lessons file was created but never loaded/enforced
- 6 specific corrections documented but not applied
- Waves 18-23 will repeat same errors if lessons not enforced

**Specific Lessons to Apply:**

**Lesson 1 (CRITICAL):** Design Phase Completeness
- **From:** W7-17 created DESIGN.md only (missing 3 docs)
- **Apply:** Requirement 2 (4-doc gate)
- **Status:** Will be implemented

**Lesson 2 (HIGH):** Task-Spec v2.1 Compliance
- **From:** W7-17 achieved ~85% (should be 100%)
- **Apply:** Mandate skill:task-spec for ALL task creation in altitude-plan
- **Status:** Will be validated

**Lesson 3 (HIGH):** Ask-User Policy Enforcement
- **From:** W7-17 had 12 ask-user calls (target: 5, 140% over-use)
- **Apply:** Pre-ask-user checklist in altitude-maestro
- **Status:** Will be validated

**Lesson 4 (MEDIUM):** Allocation Enforcement
- **From:** W7-17 implemented Wave 5 correctly
- **Apply:** Verify altitude-execution pre-write checks working
- **Status:** Will be verified

**Lesson 5 (MEDIUM):** Security Pre-Write
- **From:** W7-17 implemented Wave 9 correctly
- **Apply:** Verify altitude-execution pre-write checks working
- **Status:** Will be verified

**Lesson 6 (MEDIUM):** Lost-in-the-Middle Prevention
- **From:** altitude-execution has 10 critical decisions in 739 lines
- **Apply:** Restructure: move decision map to top 50 lines
- **Status:** Will be implemented

**Acceptance Criteria:**
- [ ] All 6 lessons referenced in code comments
- [ ] Lesson 1: implemented as Requirement 2
- [ ] Lesson 2: task-spec mandate enforced in altitude-plan
- [ ] Lesson 3: ask-user policy checklist in altitude-maestro
- [ ] Lessons 4-5: pre-write checks verified working
- [ ] Lesson 6: decision map moved to agent tops
- [ ] Lessons file loaded by altitude-memory in recovery protocol

**Priority:** CRITICAL  
**Complexity:** MEDIUM  

---

### Requirement 4: Decision Clarity

**Description:** Critical decisions must be visible in first 50-200 lines of agents, not scattered throughout

**Rationale:**
- **Lesson 6 from W7-17:** Decisions buried in middle cause lost-in-the-middle confusion
- `altitude-execution.agent.md` has 10 critical Wave decisions in 739 lines starting at line 45
- Readers lose context, maintainers miss decisions, auditors can't trace reasoning

**Acceptance Criteria:**
- [ ] `altitude-maestro.agent.md` has GATES section in lines 1-200
- [ ] Each gate listed with line reference, trigger, rule, action
- [ ] `altitude-execution.agent.md` has decision map at top
- [ ] Critical gates (Allocation, Security, Validation) visible before line 100
- [ ] No agent >300 lines without decision index
- [ ] Fixture: "decision placement validation" passes

**Priority:** HIGH  
**Complexity:** MEDIUM  

---

## 🎯 Success Definition

When Waves 18-23 execution begins:
- ✅ Altitude coordinator is single, unified agent
- ✅ Design 4-doc gate blocks incomplete designs
- ✅ All 6 lessons from W7-17 enforced in code
- ✅ Critical decisions visible to readers
- ✅ No governance gaps from W7-17 repeated

**Measurement:** Waves 18-23 design phase MUST create all 4 docs (PRD+ADR+TEST-SPEC+DESIGN) before moving to Execution.

---

## 📊 Non-Functional Requirements

| Requirement | Target | Metric |
|-------------|--------|--------|
| Agent file size | altitude-maestro: ~600 lines | LOC count |
| Gate enforcement latency | <100ms | Response time |
| Decision visibility | >95% of gates in top 200 lines | Line position audit |
| Phase gate pass rate | 100% (no escape hatches) | Fixture results |
| Backward compatibility | Waves 7-17 archive untouched | No failures on archived changes |

---

## 📋 Deliverables

### Phase: Design/Plan (This Document)
1. ✅ PRD.md (this file)
2. ⏳ ADR.md (architectural decisions)
3. ⏳ TEST-SPEC.md (validation strategy + fixtures)
4. ⏳ DESIGN.md (technical implementation plan)

### Phase: Execution (Next)
- New/updated agent files
- Gate implementations
- Lesson integration code
- Fixtures (passing)

### Phase: Validation (Then)
- Evidence of requirements met
- Fixture audit results
- Acceptance criteria verification

### Phase: Shipping (Final)
- DESIGN.md + PRD + ADR + TEST-SPEC archived
- Lessons-learned updated with this change
- altitude.agent.md + altitude-coordinator.agent.md moved to archive
- altitude-maestro.agent.md deployed

---

## 🔄 Dependencies

- `.specs/shared/phase-engine-contract.md` (defines 4-doc design phase)
- `.specs/shared/ask-user-policy.md` (defines ask-user rules)
- `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md` (source of corrections)
- `agents/altitude.agent.md` (to be unified)
- `agents/altitude-coordinator.agent.md` (to be unified)
- `agents/altitude-plan.agent.md` (will have 4-doc gate added)

---

## ✅ Approval Gate

Before moving to Execution phase, PRD must be:
- [ ] Reviewed by user
- [ ] All 4 requirements understood
- [ ] Success definition accepted
- [ ] ADR + TEST-SPEC + DESIGN created and approved

---
