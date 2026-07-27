# DESIGN — Harness V3 Waves 18-23 Refinement

**Document ID:** waves-18-23-design  
**Date:** 2026-06-30  
**Owner:** Altitude Coordinator  
**Status:** Draft → Review → Approved  

---

## Technical Implementation Plan

This document specifies **exactly how** to implement each requirement from PRD + ADR.

---

## Task Allocation Map

| Bloco | Task | Assigned Agent | Complexity | Time | Phase |
|-------|------|---|---|---|---|
| 1 | T-01 | `altitude-execution` | MEDIUM | 45 min | Execution |
| **2** | **T-02** | **`altitude-plan`** | **MEDIUM** | **30-45 min** | **Execution** |
| **2** | **T-03** | **`altitude-execution`** | **MEDIUM** | **30 min** | **Execution** |
| **2** | **T-04** | **`altitude-memory`** | **LOW** | **5 min** | **Execution** |
| 3 | T-05 | `altitude-execution` | MEDIUM | 35 min | Execution |
| 4 | T-06 | `altitude-execution` | LOW | 10 min | Execution |
| 4 | T-07 | `altitude-validation` | MEDIUM | 30 min | Validation |

**Total Time:** ~3.5 hours (4 blocos)  
**Critical Path:** BLOCO 1 → BLOCO 2 → BLOCO 3 → BLOCO 4

---

## Implementation Plan

### Component 1: altitude-maestro.agent.md (NEW AGENT)

**File:** `agents/altitude-maestro.agent.md`  
**Size:** ~600 lines  
**Type:** PRIMARY agent (visible entry point)  
**Replaces:** altitude.agent.md + altitude-coordinator.agent.md (mark DEPRECATED)

#### Structure

```
Lines 1-30:   Headers + metadata
Lines 31-80:  Mission + Recovery Protocol
Lines 81-200: DECISION MAP (Gates 1-6)
             ├─ Gate 1: State Resolution [line X]
             ├─ Gate 2: Request Classification [line Y]
             ├─ Gate 3: Phase Validation [line Z]
             ├─ Gate 4: Design 4-Doc [line A]
             ├─ Gate 5: Multi-Wave Orchestration [line B]
             └─ Gate 6: Execution Readiness [line C]

Lines 201-300: Section 3: REQUEST-LEVEL ROUTING
              ├─ 3A: New durable work
              ├─ 3B: Resume existing change
              ├─ 3C: Tactical work
              ├─ 3D: Visual artifacts
              ├─ 3E: README work
              └─ 3F: Multi-wave orchestration

Lines 301-350: Section 4: PHASE-LEVEL ROUTING
              ├─ Intent phase → altitude-intent.agent.md
              ├─ Structure phase → altitude-structure.agent.md
              ├─ Design phase → altitude-plan.agent.md
              ├─ Execution phase → altitude-execution.agent.md
              ├─ Validation phase → altitude-validation.agent.md
              ├─ Reporting phase → altitude-report.agent.md
              └─ Memory phase → altitude-memory.agent.md

Lines 351-450: Section 5: ORCHESTRATION LOGIC (from altitude-coordinator)
              ├─ Load orchestration-contract.md
              ├─ Compute wave DAG
              ├─ Schedule waves (topological sort)
              ├─ Monitor execution
              └─ Handle failures

Lines 451-500: Section 6: ASK-USER PATTERNS
              ├─ State conflict pattern
              ├─ Classification ambiguity pattern
              ├─ Gate failure pattern
              └─ Approval request pattern

Lines 501-550: Section 7: STOP CONDITIONS + OUTPUT CONTRACT

Lines 551-600: References to .specs/shared/ contracts
```

#### Key Gates Implementation

**Gate 1: State Resolution**
```bash
# Load state
[ -f ".specs/memory/active-state.md" ] || { echo "MISSING"; exit 1; }
state=$(cat .specs/memory/active-state.md)

# If conflict: ask-user to repair
if [ conflict_detected ]; then
  ask_user("State conflict. Repair / Reset / Skip?")
fi
```

**Gate 2: Request Classification**
```bash
# Classify request type
case "$request" in
  "new"       ) route altitude-intent ;;
  "resume"    ) route altitude-$phase ;;
  "tactical"  ) route data-engineer ;;
  "visual"    ) recommend visual:* ;;
  "readme"    ) recommend core:readme-maker ;;
  "multi-wave") branch orchestration ;;
esac
```

**Gate 4: Design 4-Doc (implemented in altitude-plan, called from maestro)**
```bash
# Called: "altitude-maestro routes to altitude-plan"
# altitude-plan implements pre-decomposition gate:

validate_design_completeness() {
  local change_id=$1
  for doc in PRD.md ADR.md TEST-SPEC.md DESIGN.md; do
    if [ ! -f ".specs/changes/$change_id/$doc" ]; then
      echo "BLOCKED: Missing $doc"
      ask_user("Create $doc to proceed")
      return 1
    fi
  done
  return 0
}
```

---

### Component 2: altitude-plan.agent.md (MODIFIED)

**File:** `agents/altitude-plan.agent.md`  
**Changes:** Enhance with Design 4-Doc context loading + usage  
**Location:** Post-validation section + new "Context Loading for Decomposition" section  
**Current spec:** ~30 lines → **Refined spec:** ~60-80 lines (loads + uses context)

#### Refined Implementation Strategy

The current altitude-plan has **validation** of 4-docs (lines 47-67). T-02 should **enhance** it to also:

1. ✅ **Validate** 4-docs exist (already done)
2. ✅ **Load PRD context** → Extract requirements + success criteria
3. ✅ **Load ADR context** → Extract architectural decisions + constraints
4. ✅ **Load TEST-SPEC context** → Extract test strategy + acceptance criteria
5. ✅ **Use loaded context** during task decomposition (NEW)

#### Required Code Changes

**After line 67 (current 4-doc validation), add new section:**

```markdown
## Design Context Loading for Decomposition [NEW - ~60 lines]

**PURPOSE:** After validating 4-docs exist, load their context for use in task decomposition.

### Load PRD Context (Extract Requirements)

```bash
load_prd_context() {
  local prd_file=".specs/changes/$CHANGE_ID/PRD.md"
  
  # Extract and store:
  # - Requirements (Req 1-N)
  # - Stakeholders
  # - Success criteria
  # - Non-goals
  
  prd_requirements=$(grep "^## Requirement\|^### Req " "$prd_file")
  prd_success=$(grep "^## Success\|^### Success" "$prd_file")
  prd_nongols=$(grep "^## Non-Goals\|^### Non-" "$prd_file")
}
```

**Usage in decomposition:**
- Each task must map to ≥1 PRD requirement
- Success criteria must trace to PRD success criteria
- Non-goals must NOT appear in task scope

### Load ADR Context (Extract Architecture Decisions)

```bash
load_adr_context() {
  local adr_file=".specs/changes/$CHANGE_ID/ADR.md"
  
  # Extract and store:
  # - Decisions (ADR-1, ADR-2, ...)
  # - Trade-offs
  # - Constraints
  # - Rationale
  
  adr_decisions=$(grep "^## Decision\|^### ADR" "$adr_file")
  adr_constraints=$(grep "^## Constraint\|^### Constraint" "$adr_file")
}
```

**Usage in decomposition:**
- Each task must respect ADR decisions
- Constraints must be documented in task allowed_files / forbidden_scope
- Trade-offs must inform task priority

### Load TEST-SPEC Context (Extract Validation Strategy)

```bash
load_testspec_context() {
  local testspec_file=".specs/changes/$CHANGE_ID/TEST-SPEC.md"
  
  # Extract and store:
  # - Test scenarios
  # - Acceptance criteria per scenario
  # - Regression test matrix
  # - Known gaps
  
  testspec_scenarios=$(grep "^## Scenario\|^### Scenario" "$testspec_file")
  testspec_acceptance=$(grep "^## Acceptance\|^### Acceptance" "$testspec_file")
}
```

**Usage in decomposition:**
- Each task must map to ≥1 test scenario
- Acceptance criteria in tasks must align with TEST-SPEC
- Each task must define verification commands (from TEST-SPEC)

### Decomposition Using Context

```markdown
## Decomposition Workflow (Enhanced) [lines ~130-150]

1. Load and validate 4-doc gate
2. **Load PRD context** → requirements_list
3. **Load ADR context** → decisions_list, constraints_list
4. **Load TEST-SPEC context** → scenarios_list, acceptance_criteria_list
5. For each DESIGN.md task:
   - Map to PRD requirement (validate coverage)
   - Check against ADR constraints (validate architecture)
   - Map to TEST-SPEC scenario (validate testing)
   - Create task with:
     * objective (from DESIGN)
     * requirements (from PRD + mapping)
     * constraints (from ADR)
     * acceptance_criteria (from TEST-SPEC)
     * verification_commands (from TEST-SPEC)
6. Validate coverage:
   - ALL PRD requirements mapped to ≥1 task?
   - ALL ADR decisions respected?
   - ALL TEST-SPEC scenarios mapped to ≥1 task?
7. Create 02-decomposition.md with traceability matrix
```

### Traceability Matrix (New artifact requirement)

```markdown
## Decomposition Traceability Matrix [NEW - in 02-decomposition.md]

| Task | PRD Req | ADR Decision | TEST-SPEC Scenario | Acceptance Criteria |
|------|---------|------|---|---|
| T-01 | Req 1 | ADR-1 | Scenario 1 | AC-1, AC-2 |
| T-02 | Req 2, Req 3 | ADR-2 | Scenario 2 | AC-3 |
| T-03 | Req 4 | ADR-1, ADR-2 | Scenario 3, 4 | AC-4, AC-5 |

**Validation:**
- ✅ All PRD requirements covered
- ✅ All ADR constraints respected
- ✅ All TEST-SPEC scenarios assigned
- ✅ No requirements missed
```

---

#### Impact Summary

| Change | Before | After | Notes |
|--------|--------|-------|-------|
| Lines added to altitude-plan | ~30 | ~60-80 | Context loading + usage logic |
| New section in 02-decomposition.md | N/A | Traceability matrix | Artifact shows requirement coverage |
| Task verification | Basic | Enhanced | Tasks now map to PRD/ADR/TEST-SPEC |
| Coverage guarantee | Implicit | Explicit | Traceability matrix proves completeness |

---

#### Acceptance Criteria for T-02 (Refined)

```bash
✅ altitude-plan loads PRD context (requirements extraction works)
✅ altitude-plan loads ADR context (decisions/constraints extraction works)
✅ altitude-plan loads TEST-SPEC context (scenarios/acceptance extraction works)
✅ 02-decomposition.md generated with traceability matrix
✅ Each task in decomposition maps to PRD + ADR + TEST-SPEC
✅ Traceability matrix shows 100% PRD coverage
✅ Traceability matrix shows ADR constraint respect
✅ Traceability matrix shows TEST-SPEC scenario assignment
```

---

### Component 3: altitude-execution.agent.md (RESTRUCTURED)

**File:** `agents/altitude-execution.agent.md`  
**Changes:** Move decision map to top (~50 lines), reorganize Wave sections  
**Current:** 739 lines with decisions scattered  
**After:** 750 lines with clear decision map at top

#### Before (Current Structure)
```
Lines 1-44:   Mission + Recovery + Allowed Writes
Lines 45-100: Wave 4: Artifact Versioning [buried]
Lines 101-206: Wave 5: Allocation Enforcement [buried]
Lines 207-288: Wave 9: Security Gate [buried]
... (10 critical decisions scattered)
Lines 700-739: Output contract
```

#### After (New Structure)
```
Lines 1-44:   Mission + Recovery + Allowed Writes
Lines 45-150: *** DECISION MAP (ALL Waves with line refs) ***
  │ Wave 3B: Validation Gate [line X]
  │ Wave 4: Artifact Versioning [line Y]
  │ Wave 5: Allocation Enforcement [line Z]
  │ Wave 6: Context Budget [line A]
  │ Wave 7: Decision Tracing [line B]
  │ Wave 9: Security Gate [line C]
  │ Wave 12: Recovery [line D]
  │ Wave 14: Messaging [line E]
  └─ See detailed sections below

Lines 151-739: Detailed sections (same content, just moved)
  │ Wave 3B details (151-200)
  │ Wave 4 details (201-250)
  │ etc.
  └─ Output contract (730-739)
```

#### Implementation

Add after "Allowed Writes" section:

```markdown
## ⚡ CRITICAL DECISIONS MAP [NEW]

This agent implements 8 critical Wave specifications. ALL must be understood before execution:

| Wave | Decision | Line | Trigger | Action |
|------|----------|------|---------|--------|
| 3B | Validation Gate Pass? | 151 | Before execution | Check score ≥75 |
| 4 | Artifact versioning | 201 | On artifact write | Compute checksum + registry |
| 5 | Scope violation check | 251 | On file write | Verify allowed_files |
| 6 | Budget exceeded? | 301 | Pre-work | Check headroom |
| 7 | Decision traceable? | 351 | During execution | Record verify_step |
| 9 | Security violation? | 401 | Pre-write | Scan for secrets/PII |
| 12 | Recovery snapshot | 451 | Pre-risky-op | Create snapshot |
| 14 | Agent message publish | 501 | On gate passage | Publish via messenger |

**Navigation:** Click line number above to jump to detailed section.

---
```

---

### Component 4: altitude-memory.agent.md (MINOR CHANGE)

**File:** `agents/altitude-memory.agent.md`  
**Changes:** Update recovery protocol to load lessons learned  
**Location:** Line 29 (Recovery Protocol)

#### Current
```
1. Read `.specs/memory/active-state.md` if it exists.
```

#### Updated
```
1. **Load Lessons Learned** — Read `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md` to understand prior governance gaps.
2. Read `.specs/memory/active-state.md` if it exists.
```

---

### Component 5: Test Fixtures

**Directory:** `test/fixtures/harness-v3/`  
**Files:** 7 bash scripts (from TEST-SPEC.md)

#### Required Fixtures

```
maestro-routing.sh
  ├─ Test: Routes "new" to altitude-intent ✅
  ├─ Test: Routes "resume" to altitude-$phase ✅
  └─ Test: Routes "multi-wave" to orchestration ✅

design-4-doc-gate-pass.sh
  ├─ Test: All 4 docs exist → allows transition ✅

design-4-doc-gate-block.sh
  ├─ Test: ADR missing → blocks decomposition ✅

lessons-learned-loaded.sh
  ├─ Test: altitude-memory loads WAVES-7-17 file ✅

decision-map-visible.sh
  ├─ Test: Decisions visible in first 200 lines ✅

orchestration-dag.sh
  ├─ Test: Wave DAG computed correctly ✅

execution-ready-gate.sh
  ├─ Test: Task ready gate enforced ✅
```

#### Example Fixture: design-4-doc-gate-pass.sh

```bash
#!/bin/bash
set -e

change_dir=".specs/changes/waves-18-23-implementation"

# Create all 4 docs (simulating passed gate)
for doc in PRD.md ADR.md TEST-SPEC.md DESIGN.md; do
  if [ ! -f "$change_dir/$doc" ]; then
    echo "Creating $doc..."
    touch "$change_dir/$doc"
  fi
done

# Run gate validation
validate_design_completeness() {
  for doc in PRD.md ADR.md TEST-SPEC.md DESIGN.md; do
    [ -f "$change_dir/$doc" ] || return 1
  done
  return 0
}

if validate_design_completeness; then
  echo "✅ PASS: Design 4-doc gate allows phase transition"
  exit 0
else
  echo "❌ FAIL: Design 4-doc gate validation failed"
  exit 1
fi
```

---

## Task Decomposition (for Execution Phase)

These tasks will be created in 02-decomposition.md:

### Task T-01: Create altitude-maestro.agent.md

**Assigned Agent:** `altitude-execution` (or manual bootstrap)  
**Complexity:** MEDIUM  
**Time:** 45 min  
**Steps:**
1. Merge altitude.agent + altitude-coordinator content
2. Add Gates section (200 lines)
3. Add Request routing (3A-3F)
4. Add Phase routing (4)
5. Add Orchestration (5)
6. Add Output contract
7. Verify ~600 lines

---

### Task T-02: Enhance altitude-plan.agent.md (Design 4-Doc Gate + Context Loading)

**Assigned Agent:** `altitude-plan`  
**Complexity:** MEDIUM  
**Time:** 30-45 min  
**Scope Increase:** ~30 lines (gate) → ~60-80 lines (gate + context loading + usage)

**Steps:**
1. Add Design 4-Doc validation function (already exists, lines 47-67)
2. **[NEW]** Add "Design Context Loading" section (~60 lines):
   - load_prd_context() function
   - load_adr_context() function
   - load_testspec_context() function
3. **[NEW]** Update decomposition workflow to use loaded context:
   - Map each task to PRD requirement(s)
   - Map each task to ADR decision(s)
   - Map each task to TEST-SPEC scenario(s)
4. **[NEW]** Generate traceability matrix in 02-decomposition.md:
   - Task | PRD Req | ADR Decision | TEST-SPEC Scenario | Acceptance Criteria
   - Validate 100% PRD coverage
5. Update Workflow section (lines 69-81) with new steps
6. Test with fixtures:
   - design-4-doc-gate-pass.sh (validates gate + context loading)
   - altitude-plan-context-loading.sh (NEW: validates traceability matrix)

**Acceptance Criteria:**
- ✅ 4-doc gate validation works (blocks if missing)
- ✅ PRD context loaded (requirements extractable)
- ✅ ADR context loaded (decisions extractable)  
- ✅ TEST-SPEC context loaded (scenarios extractable)
- ✅ Decomposition uses loaded context (tasks map to artifacts)
- ✅ Traceability matrix generated in 02-decomposition.md
- ✅ 100% PRD requirement coverage validated
- ✅ Fixtures pass

**Impact Summary:**

| Item | Before | After | Change |
|------|--------|-------|--------|
| altitude-plan size | ~204 lines | ~270-290 lines | +60-80 lines |
| Complexity | LOW | MEDIUM | Gate + Context |
| Time estimate | 15 min | 30-45 min | +15-30 min |
| Test coverage | 2 scenarios | 3 scenarios | +1 (context loading) |

---

### Task T-03: Restructure altitude-execution.agent.md (Decision Map)

**Assigned Agent:** `altitude-execution`  
**Complexity:** MEDIUM  
**Time:** 30 min  
**Steps:**
1. Add Decision Map after "Allowed Writes"
2. Table with all 8 Waves + line refs
3. Move Wave sections (content unchanged, just relocate)
4. Verify line references correct
5. Test with fixture

### Task T-04: Update altitude-memory.agent.md (Lessons Loading)

**Assigned Agent:** `altitude-memory`  
**Complexity:** LOW  
**Time:** 5 min  
**Steps:**
1. Update recovery protocol line 29
2. Add lessons loading reference
3. Verify file loads correctly

### Task T-05: Create Test Fixtures (7 scripts)

**Assigned Agent:** `altitude-execution` (creates test scripts)  
**Complexity:** MEDIUM  
**Time:** 35 min  
**Steps:**
1. maestro-routing.sh
2. design-4-doc-gate-pass.sh
3. design-4-doc-gate-block.sh
4. lessons-learned-loaded.sh
5. decision-map-visible.sh
6. orchestration-dag.sh
7. execution-ready-gate.sh

### Task T-06: Deprecate Old Agents

**Assigned Agent:** `altitude-execution`  
**Complexity:** LOW  
**Time:** 10 min  
**Steps:**
1. altitude.agent.md: Add DEPRECATED header
2. altitude-coordinator.agent.md: Add DEPRECATED header
3. Link both to altitude-maestro.agent.md
4. Document migration path in docs/

### Task T-07: Validation Verification

**Assigned Agent:** `altitude-validation`  
**Complexity:** MEDIUM  
**Time:** 30 min  
**Steps:**
1. Run all 7 fixtures
2. Record results with timestamps
3. Verify altitude-maestro routes correctly
4. Verify gates block/allow as expected
5. Create evidence file

---

## File Changes Summary

| File | Type | Change | Lines |
|------|------|--------|-------|
| **altitude-maestro.agent.md** | NEW | Complete new agent | ~600 |
| altitude-plan.agent.md | EDIT | Add 4-doc gate + validation | +30 |
| altitude-execution.agent.md | EDIT | Add decision map to top | +100 |
| altitude-memory.agent.md | EDIT | Add lessons loading | +2 |
| altitude.agent.md | EDIT | Mark DEPRECATED | +5 |
| altitude-coordinator.agent.md | EDIT | Mark DEPRECATED | +5 |
| test/fixtures/harness-v3/* | NEW | 7 fixture scripts | ~280 |
| state.md | UPDATE | Record phase progress | — |

**Total new lines:** ~1,020  
**Total modified lines:** ~50  
**Total fixture lines:** ~280

---

## Migration Path

### For Users
1. Call `altitude-maestro` instead of `altitude.agent` (if direct call)
2. Otherwise: automatic routing from command/entry point

### For Developers
1. Update any internal references from `altitude.agent.md` to `altitude-maestro.agent.md`
2. Keep old agents in place for reference (marked DEPRECATED)
3. No breaking changes to phase agents (intent/structure/plan/execution/validation/report/memory)

### For Archived Changes (W7-17, etc.)
1. Still reference old agents (still available, marked DEPRECATED)
2. No action required for archived changes
3. New changes use altitude-maestro automatically

---

## Quality Assurance

### Pre-Execution Checks (MANDATORY)

**Before ANY bloco/task execution, verify:**

#### TODO + Agent Tracking
- [ ] **TODO Tracking initialized** — todowrite() called with entries for this bloco
- [ ] **Agent assignments visible** — Each TODO entry shows `Agent: agent-name`
- [ ] **Taxonomy correct** — Format: `BLOCO N (Phase: X) | T-YY | Description | Agent: name`
- [ ] **Gates defined** — Gate 7 (Pre-Viability), Gate 8 (Post-Validation), Gate 9 (Memory Closure) documented

#### Question() Usage Validation
- [ ] **Ask-user policy loaded** — Agent reads `.specs/shared/ask-user-policy.md` before ANY question() call
- [ ] **Question() justified?** — Only use if State conflict / Gate blocked / Ambiguity / Destructive / Scope expansion / Phase transition
- [ ] **No safe default?** — If safe default exists, use it instead of question()
- [ ] **GRILL ME pattern ready?** — If question() will be called, prepare multi-scenario comparison
- [ ] **Pre-Checklist in code** — Recovery Protocol in agents includes ask-user validation

#### Design Artifacts
- [ ] All 4 PRD requirements understood
- [ ] All 2 ADR decisions approved
- [ ] All 7 TEST-SPEC scenarios reviewed
- [ ] This DESIGN.md reviewed + approved

### Post-Execution Checks

- [ ] **TODO entries updated** — All completed tasks marked `completed` in todowrite
- [ ] **Evidence file created** — `evidence/BLOCO-N.md` generated
- [ ] **State updated** — `state.md` reflects bloco completion
- [ ] **Next bloco TODO ready** — If more blocos, todowrite() prepared for next
- [ ] **Question() calls logged** — Evidence file documents when question() was called + why
- [ ] All 7 tasks completed
- [ ] All 7 fixtures pass
- [ ] altitude-maestro works as documented
- [ ] Gates block/allow correctly
- [ ] No backward compatibility issues

### Evidence Required

- [ ] altitude-maestro.agent.md exists (~600 lines)
- [ ] Fixture results (timestamps, all 7 pass)
- [ ] state.md updated with gate passages
- [ ] Lessons application evidence
- [ ] **TODO tracking log** — `todowrite()` entries + status transitions
- [ ] **Agent allocation audit** — Verify each task executed by assigned agent
- [ ] **Question() audit** — Log all question() calls + user responses (e.g., "Gate 1 state conflict: user chose Option B")

---

## References

- PRD.md (Requirement definitions)
- ADR.md (Architectural decisions)
- TEST-SPEC.md (Validation fixtures)
- `.specs/shared/phase-engine-contract.md`
- `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md`

---

## Next Steps

1. ✅ PRD.md, ADR.md, TEST-SPEC.md, DESIGN.md (this document) — COMPLETE
2. ⏳ Execution: Implement 7 tasks above
3. ⏳ Validation: Run fixtures + verify gates
4. ⏳ Shipping: Archive + merge PRs

---
