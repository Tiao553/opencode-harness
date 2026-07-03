# Wave 3B Fixtures: Runtime Trifold Enforcement

**Status:** ACTIVE
**Phase:** In-Progress
**Scope:** 5 key scenarios (validation + ask-user + todowrite)

---

## Scenario 1: Execution Blocked by Validation (Score 45)

**Setup:**
- Change: wave-3b-test-001
- Task: T-001 (ready for execution)
- Validation score: 45/100 (BLOCKED)
  - Requirements: 30/100
  - Architecture: 50/100
  - Tests: 40/100
  - Tasks: 55/100
  - Council: 40/100

**Flow:**

```
1. User: "Execute T-001"
   altitude-execution receives request

2. altitude-execution: Validation Gate Check
   Read .specs/changes/wave-3b-test-001/state.md
   → validation_status = BLOCKED (score 45)

3. altitude-execution: Block Execution
   Score < 75, cannot proceed

4. [Wave 3B] ask-user presented:

   Decision point: Validation BLOCKED (score: 45/100)

   Lowest scoring junta: Requirements (30/100)

   A. Remediate — phase back to fix requirements
   B. Accept risk — document and proceed anyway
   C. Escalate — request validation junta review

   Recommended: A

5. [Fixture validates] ask-user options are correct

6. User selects: A (Remediate)

7. altitude-execution: Route to Remediation
   Phase back to altitude-intent
   Reason: "Requirements score too low (30/100)"

8. altitude-intent receives remediation request
   - Load current intent from 00-intent.md
   - Show: "Problem statement needs clarification"
   - Project todos via todowrite:
     ├─ [T-001-FIX] Re-read original requirements
     ├─ [T-001-FIX] Clarify ambiguous aspects
     ├─ [T-001-FIX] Document clarifications
     └─ [T-001-FIX] Re-validate with requirements junta

9. User works through remediation todos
   Mark each step complete

10. Re-validation runs
    New requirements score: 85/100
    Total score: 78/100 (READY)

11. altitude-execution: Validation Gate Check
    Score ≥ 75, proceed

12. [Wave 3B] todowrite projects execution todos:
    ├─ [T-001] Read clarified requirements
    ├─ [T-001] Implement change
    ├─ [T-001] Run verification
    ├─ [T-001] Record evidence
    └─ [T-001] Mark complete

13. Execution proceeds and completes

14. Final validation runs
    Score: 92/100 (PASSED)

15. [Fixture validates] Entire remediation → recovery flow works
```

**Assertions:**
- ✅ Execution blocked when score < 75
- ✅ ask-user presented with 3 options
- ✅ Remediate option routes to correct phase
- ✅ TodoWrite projects remediation todos
- ✅ After fix, execution unblocked
- ✅ Final validation passes

---

## Scenario 2: Ship Blocked by Validation (Score 80)

**Setup:**
- Change: wave-3b-test-002
- Task: T-001 completed and verified
- Final validation score: 80/100 (READY, not PASSED)
  - Requirements: 85/100
  - Architecture: 80/100
  - Tests: 75/100
  - Tasks: 85/100
  - Council: 80/100

**Flow:**

```
1. User: "Report and ship T-001"
   altitude-report receives request

2. altitude-report: Ship Gate Check
   Read state.md → validation_status = READY (score 80)
   Score < 90, cannot ship

3. altitude-report: Block Ship
   Show junta scores to user

4. [Wave 3B] ask-user presented:

   Decision point: Validation is READY (score: 80/100)

   Can execute but cannot ship yet.

   A. Remediate — phase back to fix tests/architecture
   B. Ship with gaps — document caveats and proceed
   C. Escalate — request validation junta override

   Recommended: A

5. [Fixture validates] ask-user presented correctly

6. User selects: B (Ship with gaps)

7. altitude-report: Proceed with Documentation
   - Include validation score in executive report
   - Include junta narrative
   - Note: "Shipped with known gaps: Tests coverage below target"
   - Mark status: shipped_with_gaps

8. Executive report generated with:
   ├─ Executive summary
   ├─ Validation scores
   ├─ Known gaps
   ├─ Risk notes
   └─ Next recommendations

9. Change archived to .specs/archive/ with status shipped_with_gaps

10. [Fixture validates] Ship gate and reporting flow works
```

**Assertions:**
- ✅ Ship blocked when score < 90
- ✅ ask-user presented with 3 options
- ✅ Ship-with-gaps option includes documentation
- ✅ Executive report includes validation evidence
- ✅ Status correctly marked shipped_with_gaps

---

## Scenario 3: Task Selection with ask-user

**Setup:**
- Change: wave-3b-test-003
- Phase: Plan (ready for execution)
- 3 ready tasks exist:
  - T-001: Core feature (critical path)
  - T-002: Data quality check (blocking downstream)
  - T-003: Monitoring (nice-to-have)

**Flow:**

```
1. User: "Proceed to execution"
   altitude-plan receives request

2. altitude-plan: Task Selection Gate
   Multiple ready tasks found:
   - T-001 (ready)
   - T-002 (ready)
   - T-003 (ready)

3. [Wave 3B] ask-user presented:

   Decision point: Which task should execute next?

   A. T-001 — Build core functionality (Recommended) — on critical path
   B. T-002 — Fix data quality check — blocking downstream
   C. T-003 — Add monitoring — nice-to-have

4. [Fixture validates] ask-user options are correct

5. User selects: A (T-001)

6. altitude-plan: Proceed with T-001
   - Set T-001 status to selected
   - [Wave 3B] Project todos via todowrite:
     ├─ [T-001] Review design
     ├─ [T-001] Implement change
     ├─ [T-001] Verify tests pass
     ├─ [T-001] Record evidence
     └─ [T-001] Complete

7. altitude-plan recommends altitude-execution

8. [Fixture validates] Task selection works correctly
```

**Assertions:**
- ✅ ask-user presented when multiple tasks ready
- ✅ Correct task selected and marked
- ✅ TodoWrite projects execution todos
- ✅ Recommended option is first

---

## Scenario 4: Data Engineer Ask-User (Tactical Routing)

**Setup:**
- User asks for help with a SQL optimization

**Flow:**

```
1. User: "Help me optimize this Snowflake query"
   data-engineer receives request

2. data-engineer: Scope Disambiguation
   Request could be:
   - Quick SQL fix (tactical)
   - Architecture redesign (strategic)

3. [Wave 3B] ask-user presented:

   Decision point: Is this tactical or strategic work?

   A. Tactical fix — optimize specific query (quick)
   B. Durable change — query redesign/refactor (complex)

   Recommended: A, unless you mentioned "migration" or "multi-component"

4. [Fixture validates] ask-user presented correctly

5. User selects: A (Tactical)

6. data-engineer: Proceed with Tactical Path
   - Load SQL optimizer specialist
   - Analyze query
   - [Wave 3B] Project todos via todowrite:
     ├─ [SQL-001] Analyze current query plan
     ├─ [SQL-001] Identify bottleneck
     ├─ [SQL-001] Rewrite query
     ├─ [SQL-001] Benchmark improvement
     └─ [SQL-001] Deploy

7. User works through todos

8. [Fixture validates] Tactical SQL flow works
```

**Assertions:**
- ✅ ask-user presented for scope disambiguation
- ✅ Tactical path taken (not escalated to Altitude)
- ✅ TodoWrite projects tactical todos
- ✅ Specialist routed correctly

---

## Scenario 5: State Conflict Gate

**Setup:**
- Change: wave-3b-test-005
- Active state points to: altitude-execution
- User request: "Phase back to Intent"
- Conflict: User is asking to go backward, breaking state

**Flow:**

```
1. User: "I need to reclarify the requirements"
   altitude.coordinator receives request

2. altitude.coordinator: State Conflict Detection
   Current: execution phase
   Requested: intent phase
   Conflict: Backward phase not allowed without explicit conflict resolution

3. [Wave 3B] State Conflict ask-user presented:

   State conflict detected.

   Current evidence:
   - Active phase: Execution
   - Current request: Return to Intent
   - Conflict: Backward phase may lose execution work

   Recommended: A

   A. Trust current request — phase back to Intent (document loss)
   B. Trust artifact state — stay in Execution
   C. Reset to earlier phase — return to Structure

4. [Fixture validates] State conflict gate works

5. User selects: A (Phase back to Intent)

6. altitude.coordinator: Conflict Resolution
   - Document backward phase reason
   - Archive current execution work
   - Phase to altitude-intent
   - Update state.md

7. altitude-intent: Remediation workflow
   [Similar to Scenario 1]

8. [Fixture validates] State conflict and backward phase works
```

**Assertions:**
- ✅ State conflict detected
- ✅ ask-user presented for conflict resolution
- ✅ Backward phase allowed with documentation
- ✅ Previous work archived

---

## Validation Checklist

### For all 5 scenarios:

```
✅ ask-user called at correct decision point
✅ ask-user options are mutually exclusive
✅ Recommended option is labeled and first
✅ User selection is properly routed
✅ TodoWrite projects todos at appropriate points
✅ Todos include verify: clause
✅ Todos include task ID
✅ Phase transitions work correctly
✅ Evidence is recorded
✅ State is updated
```

### Scoring Validation

```
✅ Score < 75 blocks execution
✅ Score 75–89 allows execution but blocks ship
✅ Score ≥ 90 allows both execution and ship
✅ Junta scores aggregate correctly
```

### Ask-User Validation

```
✅ ask-user called via question() tool
✅ All options presented
✅ Recommended option marked
✅ User response routed correctly
✅ Multiple ask-user in sequence work correctly
```

### TodoWrite Validation

```
✅ todowrite called via todowrite() tool
✅ Todos projected before execution
✅ Each todo marked with [WAVE][TASK][ACTION]
✅ Each todo includes verify: clause
✅ Completed steps marked done
✅ Phase change recomputes todos
✅ Blocked step shows pending todo status
```

---

## Test Execution

### Manual Test (Option A)

1. Load each scenario
2. Follow flow manually
3. Check assertions
4. Document pass/fail

### Automated Test (Option B)

Use task-spec or test-generator to create runnable test suite:

```bash
pytest test/fixtures/harness-v3/validation-enforcement.test.py -v
pytest test/fixtures/harness-v3/ask-user-enforcement.test.py -v
pytest test/fixtures/harness-v3/todowrite-enforcement.test.py -v
```

### Integration Test (Option C)

Run full end-to-end:

1. Create change in .specs/changes/
2. Execute Scenario 1 (blocked → remediate → unblocked)
3. Verify state matches expected
4. Clean up

---

## Expected Test Results

```
✅ Scenario 1: Validation Blocker + ask-user + Remediation
   Status: PASS
   Time: ~2 min
   Coverage: Validation gate, ask-user, TodoWrite, phase back

✅ Scenario 2: Ship Gate + ask-user + Documentation
   Status: PASS
   Time: ~1 min
   Coverage: Ship gate, ask-user, shipped_with_gaps status

✅ Scenario 3: Task Selection + ask-user
   Status: PASS
   Time: ~1 min
   Coverage: Task selection, ask-user, TodoWrite

✅ Scenario 4: Data Engineer Tactical + ask-user
   Status: PASS
   Time: ~1 min
   Coverage: Tactical routing, ask-user, specialist delegation

✅ Scenario 5: State Conflict + ask-user
   Status: PASS
   Time: ~1 min
   Coverage: State conflict, ask-user, backward phase

TOTAL: 5/5 PASS, ~6 min
```

---

## Notes for Implementation

- Each scenario should be independently runnable
- State should be isolated (change IDs are unique)
- Ask-user responses should be mock-able or require interactive input
- TodoWrite calls should be recorded and verified
- All evidence should be committed (no cleanup of test artifacts)

---

## Rollback/Escape Hatches Tested

In future waves, test these variations:

- ❌ ask-user can be skipped (should fail)
- ❌ TodoWrite can be skipped (should fail)
- ✅ Validation thresholds can be adjusted (should still work)
- ✅ ask-user options can be expanded (should still work)
- ✅ TodoWrite recompute frequency can be tuned (should still work)
