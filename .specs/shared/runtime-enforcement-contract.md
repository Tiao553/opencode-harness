# Runtime Enforcement Contract [Wave 3B]

**Status:** ACTIVE
**Created:** 2026-06-29
**Scope:** Validation gates + Ask-User + TodoWrite integration
**Coordinators:** Altitude + Data Engineer
**Updated agents:** 8 coordinators + 2 phase agents

---

## Purpose

Define how validation gates, ask-user prompts, and todo tracking work together at runtime to enforce:

1. **Validation gates** block execution/ship when validation score < threshold
2. **Ask-user** provides structured decision paths when blocked or ambiguous
3. **TodoWrite** tracks multi-step work state and progress

---

## Component 1: Validation Gate Enforcement

### Validation Scores (from Wave 3)

```
validation_score = (
  requirements_score × 0.30 +
  architecture_score × 0.25 +
  tests_score × 0.20 +
  tasks_score × 0.15 +
  council_score × 0.10
)

Range: 0–100
```

### Validation Status Progression

| Status | Score | Execution | Ship | Description |
|--------|-------|-----------|------|-------------|
| PASSED | 90–100 | ✅ Go | ✅ Allow | Ready to ship |
| READY | 75–89 | ✅ Go | ❌ Block | Can execute, remediate before ship |
| CAUTION | 50–74 | ❌ Block | ❌ Block | Requires remediation |
| BLOCKED | < 50 | ❌ Block | ❌ Block | Unrecoverable, escalate |

### Enforcement Points

#### Point 1: Pre-Execution Gate (altitude-execution)

**When:** User requests execution
**Check:** `validation_status` from `.specs/changes/<id>/state.md`

```
If validation_score < 75:
  → Block execution
  → Route to ask-user (Option: remediate or escalate)
  → On remediate: phase back to altitude-plan
  → On escalate: route to altitude-validation
  → On accept-risk: document and proceed with WARNING

Else:
  → Continue to execution workflow
```

#### Point 2: Pre-Ship Gate (altitude-report)

**When:** User requests reporting/shipping
**Check:** `validation_status` from `.specs/changes/<id>/state.md`

```
If validation_score < 90:
  → Block ship
  → Route to ask-user (Option: remediate, ship-with-gaps, or escalate)
  → On remediate: phase back to altitude-plan
  → On ship-with-gaps: include in executive report, mark status "shipped_with_gaps"
  → On escalate: request validation junta override (requires approval)

Else:
  → Continue to report/ship workflow
```

### Recovery from Validation Block

When user chooses remediate (from execution or ship gate):

1. Identify lowest-scoring junta
2. Phase back to appropriate phase:
   - Requirements low → altitude-intent (re-clarify)
   - Architecture low → altitude-structure (re-map)
   - Tests low → altitude-plan (add tests)
   - Tasks low → altitude-plan (re-decompose)
3. Re-validate (junta runs again)
4. If score ≥ threshold: unblock and resume
5. If score still low: ask user again (recursive)

---

## Component 2: Ask-User Enforcement

### Policy (from Wave 0)

Use structured multiple-choice prompts whenever possible for:

- intent clarification under ambiguity
- phase transition confirmation
- scope boundary confirmation
- tradeoff selection between valid options
- escalation direction selection
- task selection for explicit execution
- rollback versus continue decision
- validation blocker remediation

### Implementation Rules

1. **Always lead with recommended option** (first option, labeled "Recommended")
2. **Keep options mutually exclusive** when possible
3. **Include short explanation** for each option
4. **Use one question at a time** for high-impact decisions
5. **Custom input allowed only** when choice space is genuinely open

### Ask-User Locations by Agent

#### Altitude Coordinator
- Phase transition confirmation
- State conflict resolution
- Task selection (when multiple ready tasks exist)
- Validation blocker remediation

#### Altitude-Execution
- Validation blocker (score < 75) → remediate/escalate/accept-risk
- Scope expansion detected → block or confirm
- Missing task fields → clarify or stop

#### Altitude-Report
- Ship gate (score < 90) → remediate/ship-with-gaps/escalate
- Validation blocker with override request

#### Altitude-Intent
- Problem statement ambiguity → clarify goal
- Scope/impact ambiguity → confirm breadth
- Constraint discovery → identify hard constraints

#### Altitude-Structure
- Structural approach alternatives → select
- Scope boundary ambiguity → include/exclude

#### Data-Engineer Coordinator
- Tactical vs. strategic ambiguity → clarify
- Environment/credentials unclear → confirm
- Destructive operation requested → gate

### Ask-User Prompt Template

```
Decision point: [what's being decided?]

A. [Option A] — [trade-off/reason]
B. [Option B] — [trade-off/reason]
C. [Option C] — [trade-off/reason]

Recommended: [A|B|C], because [specific reason from context]
```

### Escalation Pattern

When user selects "escalate" from ask-user:

1. Load junta scores/evidence
2. Create escalation summary:
   - What's being escalated
   - Why (which junta scored low / which decision is stuck)
   - What options were offered
   - User's request for review
3. Route to appropriate junta (validation) or specialist
4. Await approval/guidance
5. Resume from current point with resolution

---

## Component 3: TodoWrite Enforcement

### Policy (from Wave 0)

Project work state via TodoWrite:

```
Wave
└── Task
    └── Todo
        └── verify: [check]
```

Every operational todo must include:

- Task ID
- Specialist name (when relevant)
- Short action statement
- Explicit `verify:` clause
- Loop posture (mandatory/advisory)

### Recompute Rules

Recompute todo tree when:

- **IMMEDIATE:** Phase changes, task status changes, validation status changes, blocker appears
- **BATCH:** Per-todo completion (may batch multiple completions)

Do NOT recompute on every small field update.

### TodoWrite Locations by Agent

#### Altitude-Plan
- Project todos from task decomposition
- Todo tree: design → subtasks → implementation steps
- Each task gets 3–5 todos (planning, impl, verify)

#### Altitude-Execution
- Project execution-specific todos from task contract
- Track progress: mark completed as steps finish
- Update blocker status when step blocks

#### Altitude-Validation
- Project validation todos from 4-junta pattern
- Todo: requirements junta → verify check
- Todo: architecture junta → verify check
- Todo: tests junta → verify check
- Todo: tasks junta → verify check
- Todo: council review → verify check

#### Altitude-Report
- Project reporting todos
- Todo: gather artifacts → verify evidence located
- Todo: write executive summary → verify completed
- Todo: update state → verify state.md updated

#### Data-Engineer (Tactical)
- Project multi-step SQL/dbt/pipeline fixes
- Track: analyze → fix → test → deploy
- Mark each step as complete

### Integration with Validation Gates

When execution is blocked by validation:

1. Current todos show "BLOCKED" status
2. Ask-user presents remediation options
3. If user chooses remediate:
   - Phase back to appropriate phase
   - Phase agent re-projects todos for remediation
   - User sees new todo list for fix
4. After re-validation passes:
   - Todos recomputed
   - Execution resumes with new todo list

### Example Flow

```
[Altitude-Plan creates task]
├─ Project todos for task
│  ├─ [T-001] Step 1: understand requirements
│  ├─ [T-001] Step 2: design solution
│  ├─ [T-001] Step 3: implement
│  ├─ [T-001] Step 4: verify
│  └─ [T-001] Step 5: record evidence
│
[Altitude-Execution starts]
├─ Validation gate checks score
│  ├─ Score 45 (BLOCKED)
│  └─ ask-user: "Fix or escalate?"
│     └─ User picks "Fix"
│
[Back to Altitude-Plan with remediation]
├─ Project new todos for remediation
│  ├─ [T-001-FIX] Re-clarify requirements
│  ├─ [T-001-FIX] Re-design
│  └─ [T-001-FIX] Re-validate
│
[After re-validation passes]
├─ Altitude-Execution resumes
├─ New todo list loaded
└─ Complete remaining steps
```

---

## Integration Rules

### Rule 1: Validation + Ask-User

When validation blocks (score < threshold):
- Route to ask-user immediately
- Do NOT proceed silently
- Do NOT force user to manually check validation score

### Rule 2: Ask-User + TodoWrite

When ask-user presents decision:
- Show current todo state in decision context
- "Current step: [todo description]"
- Allow user to see what's blocked

When user chooses remediation option:
- TodoWrite projects new todos
- User sees updated todo list for new path

### Rule 3: Validation + TodoWrite

Validation todos (one per junta):
- `verify: [junta specific check]` e.g., "requirements junta passes"
- When validation blocks: show which todo (junta) is failing
- Include junta score in verify clause

### Rule 4: Phase Boundaries + TodoWrite

When phasing back for remediation:
- Previous phase todos are NOT deleted
- New todo list appended for remediation
- User can see full history of work

Example:
```
[Original execution todos] ← BLOCKED AT STEP 3
[Remediation todos] ← NEW, IN PROGRESS
[Re-execution todos] ← PENDING (will load after fix)
```

---

## Anti-Patterns to Avoid

### Validation
- ❌ Silent execution when score < 90
- ❌ Hard-coded thresholds that don't make sense
- ❌ No recovery path when blocked

### Ask-User
- ❌ Vague open-ended questions
- ❌ Burying recommended option
- ❌ Batching unrelated decisions
- ❌ Asking when the choice is already clear

### TodoWrite
- ❌ Todo without verify: clause
- ❌ Todo without specialist name (when specialist involved)
- ❌ Shallow todo list that hides real work
- ❌ Todos that survive phase change without recompute

---

## Testing & Evidence

### Validation Gate Test Cases

```
✅ Execution allowed (score 90+)
✅ Execution allowed but warned (score 75–89)
✅ Execution blocked (score < 75) → ask-user → remediate → unblocked
✅ Ship allowed (score ≥ 90)
✅ Ship blocked (score 75–89) → ask-user → ship-with-gaps or remediate
✅ Validation BLOCKED (score < 50) → escalate to validation junta
```

### Ask-User Test Cases

```
✅ Phase transition asks confirmed
✅ Task selection with multiple ready tasks
✅ Validation blocker → ask remediate/escalate
✅ Scope expansion → ask confirm
✅ State conflict → ask resolution
```

### TodoWrite Test Cases

```
✅ Execution projects todos from task
✅ Step completion marks todo done
✅ Phase change recomputes todos
✅ Validation blocker shows pending todo
✅ Remediation appends new todos
```

### End-to-End Test

```
1. User requests execution
2. Validation score 60 (BLOCKED)
3. ask-user: "Fix requirements?"
4. User picks "Yes"
5. Phase back to altitude-intent
6. Altitude-intent re-projects todos
7. User sees "Clarify problem statement" todo
8. User completes clarification
9. Re-validate (new score 85)
10. Unblock execution
11. New todos for execution projected
12. Altitude-execution resumes
13. Execution completes
14. Validation runs (final score 95)
15. Ship allowed
```

---

## Rollback & Escape Hatches

### If Validation Thresholds Are Too Strict

**Option 1:** Lower threshold (75 → 60 for execution)
**Option 2:** Add "Accept Risk" option (explicit override with documentation)
**Option 3:** Audit-mode-first (Wave 3B enforces gently, future wave enforces strictly)

### If Ask-User Becomes Too Chatty

**Option 1:** Reduce ask-user only to critical gates (validation, phase transition)
**Option 2:** Allow "silent mode" with documented assumptions
**Option 3:** Batch related questions into fewer prompts

### If TodoWrite Recompute Is Too Frequent

**Option 1:** Batch updates (recompute only on major phase boundaries)
**Option 2:** Lazy recompute (recompute on first user action after change)
**Option 3:** Selective recompute (only for affected steps, not whole tree)

---

## Success Criteria for Wave 3B

- [ ] All 8 coordinators + 2 phase agents have ask-user patterns
- [ ] Validation gates block execution/ship when score < threshold
- [ ] Validation block → ask-user → remediate path works end-to-end
- [ ] TodoWrite projects todos for all multi-step work
- [ ] TodoWrite recomputes on phase change
- [ ] Integration tests pass (15+ fixtures)
- [ ] Documentation complete (this contract + agent patterns)
- [ ] No silent failures (all blockers route to ask-user)

---

## References

- `.specs/shared/ask-user-policy.md` — Ask-user rules
- `.specs/shared/todo-allocation-contract.md` — TodoWrite projection rules
- `.specs/shared/altitude-validation-juntas-contract.md` — Junta orchestration (Wave 3)
- agents/altitude-execution.agent.md — Execution with validation gate
- agents/altitude-report.agent.md — Report with ship gate
- agents/altitude.agent.md — Coordinator with ask-user patterns
- agents/altitude-plan.agent.md — Task selection with ask-user
- agents/data-engineer.agent.md — Tactical routing with ask-user
