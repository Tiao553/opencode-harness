# Wave 3B — Runtime Trifold Enforcement

**Status:** DESIGN  
**Scope:** Validation gates + Ask-User + TodoWrite enforcement  
**Effort:** ~2,500 lines, 8-10 files  
**Timeline:** 2 weeks  
**Blockers:** None  

---

## Problem Statement

Wave 3 delivered validation orchestration (4-junta pattern), but **enforcement was not implemented**.

Additionally, ask-user and todowrite were defined as global OpenCode primitives (Wave 0), but **no enforcement layer exists** to ensure:

1. Validators actually **block execution** when validation fails
2. Validators actually **block ship** when status ≠ PASSED
3. All interactive decisions use **ask-user** tool
4. All multi-step work is **tracked via todowrite**

This means:
- Validation junta output is advisory only (no gate)
- Interactive flow is scattered/inconsistent across agents
- Multi-step work state is invisible to users
- Platform lacks "runtime enforcement" posture

---

## Solution

**Wave 3B = Runtime Trifold Enforcement**

### Component 1: Validation Gate Enforcement
**What:** Make validation scores block execution and ship  
**How:** altitude-execution checks validation_status; altitude-report checks validation_status  
**Files:** 
- `.specs/shared/validation-gate-enforcement.md` (contract)
- `agents/altitude-execution.agent.md` (update)
- `agents/altitude-report.agent.md` (update)

### Component 2: Ask-User Enforcement
**What:** Ensure all interactive decisions route through ask-user tool  
**How:** Create patterns, audit agents/skills, add ask-user orchestrator  
**Files:**
- `.specs/shared/ask-user-enforcement-patterns.md` (when/how to use)
- `agents/altitude-interactive-enforcement.agent.md` (NEW — orchestrate asks)
- `skills/workflow-commands/references/ask-user-patterns.md` (usage guide)
- Audit + fix: agents/ (80+ files), skills/ (10+ files)

### Component 3: TodoWrite Enforcement
**What:** Ensure all multi-step work is tracked in todos  
**How:** Create patterns, audit agents/skills, enforce via altitude-plan  
**Files:**
- `.specs/shared/todowrite-enforcement-patterns.md` (when/how to use)
- `agents/altitude-plan.agent.md` (update — project todos)
- `skills/workflow-commands/references/todowrite-patterns.md` (usage guide)
- Audit + fix: agents/ (80+ files), skills/ (10+ files)

### Unified Contract
- `.specs/shared/runtime-enforcement-contract.md` (all 3 components + integration rules)

---

## Acceptance Criteria

### Validation Gates
- [ ] Execution cannot start if validation_status ≠ READY
- [ ] Execution cannot advance if validation_status ≠ PASSED
- [ ] Ship cannot happen if validation_status ≠ PASSED
- [ ] Fixture: blocked execution with validation < 90 score
- [ ] Fixture: blocked ship with validation status ≠ PASSED
- [ ] Fixture: recovery path (fix validation → retry execution)

### Ask-User Enforcement
- [ ] Audit complete (all agents + skills)
- [ ] Ask-user patterns documented (5+ scenarios)
- [ ] Altitude agents use ask-user for phase transitions
- [ ] Tactical data-engineer uses ask-user for routing
- [ ] Sample fixture: phase transition asks correctly

### TodoWrite Enforcement
- [ ] Audit complete (all agents + skills)
- [ ] TodoWrite patterns documented (5+ scenarios)
- [ ] Altitude-plan projects todos before execution
- [ ] Altitude-execution uses todowrite to track progress
- [ ] Sample fixture: multi-step execution with todo tracking

### Integration
- [ ] Validation gates + ask-user work together (ask user when blocked)
- [ ] Ask-user prompts can include todo suggestions
- [ ] TodoWrite can show validation status per todo
- [ ] End-to-end fixture: execution blocked → ask user → update todos → recover

---

## Architecture

```
User Request
  ↓
Altitude Coordinator (routes to phase)
  ↓
Phase Agent (e.g., altitude-execution)
  ├─ [NEW] Check validation_status
  │   ├─ If BLOCKED: ask-user "fix or escalate?"
  │   └─ If PASSED: proceed
  │
  ├─ [NEW] ProjectTodos (altitude-plan)
  │   └─ Create todos for current phase/task
  │
  ├─ Execute work
  │   └─ [NEW] Track via todowrite as steps complete
  │
  └─ [NEW] Check validation_status again
      ├─ If BLOCKED: ask-user "what's next?"
      └─ If PASSED: advance phase

Report Agent (altitude-report)
  └─ [NEW] Block ship if validation_status ≠ PASSED
      ├─ Show junta scores
      ├─ ask-user "remediate or escalate?"
      └─ If remediate: replan and loop back
```

---

## File Changes Summary

| File | Change | Lines | Purpose |
|------|--------|-------|---------|
| `.specs/shared/runtime-enforcement-contract.md` | CREATE | 400 | Master contract (all 3 components) |
| `.specs/shared/validation-gate-enforcement.md` | CREATE | 250 | Validation gate rules |
| `.specs/shared/ask-user-enforcement-patterns.md` | CREATE | 300 | Ask-user when/how |
| `.specs/shared/todowrite-enforcement-patterns.md` | CREATE | 300 | TodoWrite when/how |
| `agents/altitude-execution.agent.md` | UPDATE | +200 | Add validation check + todo tracking |
| `agents/altitude-report.agent.md` | UPDATE | +200 | Add validation ship gate |
| `agents/altitude-interactive-enforcement.agent.md` | CREATE | 400 | Orchestrate ask-user flows |
| `skills/workflow-commands/references/ask-user-patterns.md` | CREATE | 250 | Usage guide |
| `skills/workflow-commands/references/todowrite-patterns.md` | CREATE | 250 | Usage guide |
| `test/fixtures/harness-v3/validation-enforcement.fixture.md` | CREATE | 500 | 5+ validation block scenarios |
| `test/fixtures/harness-v3/ask-user-enforcement.fixture.md` | CREATE | 400 | 5+ ask-user scenarios |
| `test/fixtures/harness-v3/todowrite-enforcement.fixture.md` | CREATE | 400 | 5+ todowrite scenarios |
| Agent audit + fixes | UPDATE | ~500 | Fix 80+ agents (small changes each) |
| Skill audit + fixes | UPDATE | ~300 | Fix 10+ skills (small changes each) |
| **TOTAL** | | ~4,600 | ~10 files, 2-week effort |

---

## Validation Junta Scoring Rules (from Wave 3)

Score range: 0–100

```
validation_score = (
  requirements_score × 0.30 +
  architecture_score × 0.25 +
  tests_score × 0.20 +
  tasks_score × 0.15 +
  council_score × 0.10
)
```

Enforcement thresholds:

| Score | Status | Execution | Ship |
|-------|--------|-----------|------|
| 90–100 | PASSED | ✅ Continue | ✅ Allow |
| 75–89 | READY | ✅ Can start | ❌ Block (ask remediate) |
| 50–74 | CAUTION | ❌ Block (ask fix) | ❌ Block |
| < 50 | BLOCKED | ❌ Block | ❌ Block |

---

## Phase Gates with Enforcement

### Intent → Structure
- No validation required
- User confirmation: "scope clear?"

### Structure → Plan
- No validation required
- User confirmation: "surface mapped?"

### Plan → Execution
- **[NEW] Validation score ≥ 75 required**
- If blocked: ask-user "fix requirements/architecture first?"
- If passed: project todos + start execution

### Execution → Validation
- Allowed automatically
- Validation runs (junta)

### Validation → Ship
- **[NEW] Validation score ≥ 90 required**
- **[NEW] Validation status must be PASSED**
- If blocked: ask-user "fix and re-validate or document gap?"
- If passed: project ship todos + execute ship

### Ship → Archive
- Automatic
- Update memory

---

## Tactical Data Engineer Path

Ask-user enforcement at routing:

```
User asks for tactical SQL work
  ↓
Data Engineer Coordinator
  ├─ [NEW] ask-user: "Quick fix or durable change?"
  │   A. Quick fix (single query)
  │   B. Durable change (needs .specs)
  │
  └─ Based on answer:
      ├─ A → Execute immediately, skip validation
      └─ B → Route to Altitude (Intent phase)
```

TodoWrite for tactical multi-step:

```
Data Engineer executes multi-step SQL fix
  ├─ [NEW] Project todos for steps
  ├─ Step 1: optimize query
  │   └─ [NEW] Mark todo completed
  ├─ Step 2: test performance
  │   └─ [NEW] Mark todo completed
  └─ Step 3: migrate to production
      └─ [NEW] Mark todo completed
```

---

## Rollback Path

If validation gates cause too much friction:

1. **Option A:** Lower thresholds (75 → 60 for execution start)
2. **Option B:** Add "Force Execute" override (with documentation)
3. **Option C:** Add "Tactical Skip" path (bypass validation for simple tasks)

Initial rollout uses Option A (75 minimum for execution, 90 minimum for ship).

---

## Golden Fixtures

Need 5+ fixtures for each component:

### Validation Enforcement (5 fixtures)
1. Execution blocked (score 45)
2. Execution allowed (score 80)
3. Ship blocked (score 80)
4. Ship allowed (score 95)
5. Recovery: fix validation → re-execute → success

### Ask-User Enforcement (5 fixtures)
1. Phase transition asks correctly
2. Blocked execution offers fix/escalate choice
3. Blocked ship offers remediate/doc choice
4. Tactical routing asks quick/durable choice
5. Multi-step work navigation asks next-step choice

### TodoWrite Enforcement (5 fixtures)
1. Multi-step execution projects todos
2. Completed step marks todo done
3. Blocked step shows todo pending
4. Phase change recomputes todos
5. Recovery path updates todos

---

## Success Definition

**Wave 3B is complete when:**

- [ ] Validation gates actually block execution/ship (verified by fixtures)
- [ ] Ask-user is documented and enforced across coordinators
- [ ] TodoWrite is documented and enforced across multi-step work
- [ ] 15+ golden fixtures pass (5 validation + 5 ask-user + 5 todowrite)
- [ ] Agents audit complete (80+ agents reviewed)
- [ ] Skills audit complete (10+ skills reviewed)
- [ ] End-to-end flow works: blocked → ask → todo → fix → success
- [ ] Documentation complete (contracts + guides)
- [ ] Single commit, merged to main

---

## Estimated Timeline

| Phase | Effort | Days |
|-------|--------|------|
| Design + audit (this doc) | 2h | 0.25 |
| Create 4 shared contracts | 6h | 0.75 |
| Update 3 agents (execution, report, interactive) | 8h | 1 |
| Agent audit + fixes (80+) | 6h | 0.75 |
| Skill audit + fixes (10+) | 4h | 0.5 |
| Create 3 usage guides | 4h | 0.5 |
| Create 15 golden fixtures | 12h | 1.5 |
| Test end-to-end | 6h | 0.75 |
| Documentation review | 2h | 0.25 |
| **TOTAL** | **50h** | **6-7 days** |

---

## Next Step

1. **Confirm design** ← you are here
2. Start audit (agents + skills)
3. Create shared contracts
4. Update agents
5. Create fixtures
6. Test end-to-end
7. Commit Wave 3B
