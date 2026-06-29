# Wave 6: Context Budget & Headroom Validation — Golden Fixtures

**Purpose:** Test context budget enforcement across 6 scenarios.

**Total Scenarios:** 6  
**Framework:** Acceptance criteria for each scenario

---

## Scenario 1: Safe Context Load (OK Status)

**Goal:** Load context within budget, proceed normally

**Setup:**
- Task allocated: 50K tokens
- Available: 95K tokens
- Headroom minimum: 30K tokens
- Mode: advisory

**Action:**
```bash
# Check budget
headroom-validator.sh check-budget scenario-1/task.yaml

# Load context (all safe patterns)
headroom-validator.sh estimate-context scenario-1/context-items.txt
# Expected: 25K tokens, includes_unsafe=false

# Validate patterns
headroom-validator.sh validate-safe scenario-1/context.yaml
# Expected: patterns_ok=true
```

**Expected Result:**
- ✅ Status: OK
- ✅ Action: proceed
- ✅ No user escalation
- ✅ Budget ledger records: budget_check (OK)

**Acceptance Criteria:**
1. Budget check returns exit 0
2. Context estimation shows safe patterns only
3. Pattern validation returns patterns_ok=true
4. Remaining budget ≥ 65K
5. No ask-user triggered

---

## Scenario 2: Safe Load with Warning (WARN Status)

**Goal:** Load context approaching limit, warn user, allow continuation

**Setup:**
- Task allocated: 50K tokens
- Available: 25K tokens (approaching headroom of 30K)
- Mode: advisory

**Action:**
```bash
# Check budget
headroom-validator.sh check-budget scenario-2/task.yaml
# Expected: status=WARN, action=warn_user
```

**Expected Result:**
- ⚠️ Status: WARN
- ⚠️ Action: warn_user
- ⚠️ Message: "Budget warning: approaching limit"
- ✅ Exit code: 1
- Ledger records: budget_warning event

**Acceptance Criteria:**
1. Budget check returns exit 1 (WARN)
2. Output includes warning message
3. Remaining tokens < headroom_minimum
4. But remaining > safety_margin (5K)
5. In advisory mode: still can proceed

---

## Scenario 3: Unsafe Pattern Detected (BLOCK Status)

**Goal:** Detect unsafe context pattern, block without user approval

**Setup:**
- Task allocated: 50K tokens
- Available: 95K tokens (plenty of budget)
- Context requested: `.specs/` directory (recursive, 150K+ tokens)
- Mode: strict

**Action:**
```bash
# Validate patterns
headroom-validator.sh validate-safe scenario-3/context.yaml
# Expected: patterns_ok=false, unsafe_patterns=["..."]

# Check budget
headroom-validator.sh check-budget scenario-3/task.yaml
# Expected: status=OK, but pattern validation failed

# Try to estimate (should detect unsafe)
headroom-validator.sh estimate-context scenario-3/context-items.txt
# Expected: includes_unsafe=true
```

**Expected Result:**
- ❌ Status: UNSAFE_PATTERN
- ❌ Action: blocked
- ❌ Unsafe patterns detected: [".specs/"]
- ❌ Exit code: 2
- Ledger records: pattern_validation_failed event

**Acceptance Criteria:**
1. Pattern validation returns patterns_ok=false
2. Unsafe patterns explicitly listed
3. Even with available budget, pattern blocked
4. User must approve before proceeding
5. In strict mode: blocked without asking

---

## Scenario 4: Budget Exceeded (BLOCK Status)

**Goal:** Budget insufficient, cannot load context, blocked

**Setup:**
- Task allocated: 50K tokens
- Available: 8K tokens (below safety_margin of 5K)
- Mode: strict

**Action:**
```bash
# Check budget
headroom-validator.sh check-budget scenario-4/task.yaml
# Expected: status=BLOCK, action=blocked
```

**Expected Result:**
- 🔴 Status: BLOCK
- 🔴 Action: blocked
- 🔴 Cannot proceed without budget extension
- 🔴 Exit code: 2
- Ledger records: budget_exceeded event

**Acceptance Criteria:**
1. Budget check returns exit 2 (BLOCK)
2. Available tokens ≤ safety_margin
3. Message: "Budget exceeded: cannot proceed"
4. User must choose: extend OR cancel
5. No context loaded

---

## Scenario 5: User Approval for Unsafe Pattern (Escalation)

**Goal:** User approves unsafe pattern, escapes to unsafe context, task proceeds

**Setup:**
- Task allocated: 50K tokens
- Available: 95K tokens
- Context requested: unsafe pattern (e.g., load multiple skills)
- User decision: APPROVE_UNSAFE

**Action:**
```bash
# Detect unsafe pattern
headroom-validator.sh validate-safe scenario-5/context.yaml
# Expected: patterns_ok=false

# [Simulated] User approves via ask-user tool
# User choice: "approve_unsafe_pattern"

# Record approval
headroom-validator.sh ledger-add scenario-5/approval-event.yaml wave-6

# Check budget after approval
headroom-validator.sh check-budget scenario-5/task-after-approval.yaml
# Expected: status=OK, action=proceed (with warning in log)
```

**Expected Result:**
- ✅ Status: APPROVED_UNSAFE
- ✅ Action: proceed_with_warning
- ✅ Unsafe context loaded (with user approval)
- ✅ Ledger records: escalation_to_user, user_decision=approved_unsafe
- ✅ Context timestamp marked

**Acceptance Criteria:**
1. Ask-user shows 3 options (approve/compress/cancel)
2. User selects "approve_unsafe"
3. Ledger records user approval
4. Remaining budget recalculated
5. Task proceeds
6. Warning logged for future validation

---

## Scenario 6: End-to-End Workflow

**Goal:** Full cycle: init → load → warn → compress → validate → report

**Setup:**
- Change wave-6 created
- Task assigned with 50K budget
- Available: 100K tokens
- Multiple context items requested (approaching limit)

**Workflow:**

```bash
# Step 1: Initialize budget
cat wave-6/task.yaml
# total_tokens=150000, available_for_work=100000

# Step 2: Check initial budget (OK)
headroom-validator.sh check-budget wave-6/task.yaml
# Status: OK, Action: proceed

# Step 3: Load KB domain (safe, 2K)
headroom-validator.sh estimate-context wave-6/context-1.txt
# Total: 2000, includes_unsafe=false

# Step 4: Load skill files (safe, 8K)
headroom-validator.sh estimate-context wave-6/context-2.txt
# Total: 8000, includes_unsafe=false

# Step 5: Load allocation (safe, 2K)
headroom-validator.sh estimate-context wave-6/context-3.txt
# Total: 2000, includes_unsafe=false

# Step 6: Load phase artifacts (15K)
headroom-validator.sh estimate-context wave-6/context-4.txt
# Total: 15000, includes_unsafe=false

# Total so far: 27K used, 73K remaining
# Still above headroom (30K)

# Step 7: Try to load optional skill (8K more)
headroom-validator.sh estimate-context wave-6/context-5.txt
# Total: 8000, includes_unsafe=false
# After: 35K used, 65K remaining
# Still OK (above 30K headroom)

# Step 8: Try to load archive (80K) — unsafe pattern
headroom-validator.sh validate-safe wave-6/context-6.yaml
# patterns_ok=false, unsafe_patterns=[".specs/archive/"]

# [Simulated] User decides to compress instead
# Remove optional skill (free 8K)
# Reduced to: 27K used, 73K remaining

# Step 9: Record all events
headroom-validator.sh ledger-add wave-6/event-budget-init.yaml wave-6
headroom-validator.sh ledger-add wave-6/event-context-load-1.yaml wave-6
headroom-validator.sh ledger-add wave-6/event-context-load-2.yaml wave-6
# ... (more events)

# Step 10: Generate budget report
headroom-validator.sh report wave-6
# Shows: total 10 events, no violations, safe patterns used, archive skipped
```

**Expected Outputs:**

```yaml
# Final ledger state
budget_events:
  - budget_initialized: 100000 available
  - context_load_1: KB index (2K), remaining 98K
  - context_load_2: Skill (8K), remaining 90K
  - context_load_3: Allocation (2K), remaining 88K
  - context_load_4: Phase artifacts (15K), remaining 73K
  - context_load_5: Optional skill (8K), remaining 65K
  - unsafe_pattern_detected: Archive pattern
  - compression_decision: Remove skill (free 8K), remaining 73K
  - final_state: 27K used, 73K available, headroom OK

# Final report
- Total events: 8
- Budget exceeded: No
- Unsafe patterns: 1 detected (not approved)
- Compression applied: Yes (freed 8K)
- Final status: Safe
```

**Acceptance Criteria:**
1. All budget checks pass
2. Safe patterns loaded successfully
3. Unsafe pattern detected and blocked
4. User compression decision honored
5. All events recorded in ledger
6. Final report accurate
7. No violations or errors

---

## Fixture Validation Checklist

Each fixture must include:

- [ ] Input configuration (task.yaml, context lists)
- [ ] Expected behavior description
- [ ] Step-by-step commands
- [ ] Expected outputs (YAML)
- [ ] Exit codes verified
- [ ] Ledger events checked
- [ ] Acceptance criteria met
- [ ] Tool contract validated

---

## Running All Fixtures

```bash
#!/bin/bash
# Run all 6 Wave 6 fixtures

echo "Wave 6: Context Budget & Headroom Validation Fixtures"
echo "======================================================"

for scenario in 1 2 3 4 5 6; do
  echo ""
  echo "Running Scenario $scenario..."
  bash test/fixtures/harness-v3/wave-6/scenario-$scenario.sh
  
  if [ $? -eq 0 ]; then
    echo "✓ Scenario $scenario PASSED"
  else
    echo "✗ Scenario $scenario FAILED"
    exit 1
  fi
done

echo ""
echo "✓ All Wave 6 fixtures passed"
exit 0
```

---

## Fixture Files

Each scenario has supporting files:

```
test/fixtures/harness-v3/wave-6/
├── scenario-1/
│   ├── task.yaml
│   ├── context-items.txt
│   └── context.yaml
├── scenario-2/
│   └── ...
├── scenario-3/
│   └── ...
├── scenario-4/
│   └── ...
├── scenario-5/
│   ├── context.yaml
│   ├── approval-event.yaml
│   └── task-after-approval.yaml
├── scenario-6/
│   ├── task.yaml
│   ├── context-1.txt through context-6.yaml
│   ├── event-*.yaml (ledger events)
│   └── expected-report.md
└── run-all-fixtures.sh
```

---

## Summary

| Scenario | Purpose | Expected Status | User Action |
| --- | --- | --- | --- |
| 1 | Normal safe load | OK | None |
| 2 | Load near limit | WARN | Optional: continue |
| 3 | Unsafe pattern | BLOCK | Require approval |
| 4 | Budget exceeded | BLOCK | Extend or cancel |
| 5 | User approval | OK (unsafe) | Approve unsafe |
| 6 | Full workflow | OK (with compression) | Decide to compress |

**All 6 fixtures validate Wave 6 implementation end-to-end.**
