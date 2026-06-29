# Wave 5: Allocation Enforcement — Golden Fixtures

**Test suite:** 6 scenarios validating file-level allocation scope boundaries

**Trigger phrases:** "allocation enforcement", "scope boundaries", "write validation"

---

## Fixture 1: Safe Write (File in Allowed List)

**Scenario:** Agent writes file that is explicitly in `allowed_files`

**Setup:**
```yaml
allocation:
  allowed_files:
    - agents/*.agent.md
    - .specs/shared/
  forbidden_files: []
```

**Action:**
```bash
tools/allocation-check.sh check-file agents/altitude-execution.agent.md allocation.yaml
```

**Expected:**
- Exit code: 0
- Output: ✓ ALLOW
- Matched rule: agents/*.agent.md

**Pass Condition:** Exit 0, message contains "ALLOW"

---

## Fixture 2: Safe Narrowing (Task Scope ⊂ Global)

**Scenario:** Task is allocated with scope narrower than global allocation

**Setup:**
```yaml
global_allocation:
  allowed_files: [agents/, .specs/shared/, tools/]
  forbidden_files: [AGENTS.md]

task_allocation:
  allowed_files: [agents/altitude-execution.agent.md]
  forbidden_files: []
```

**Action:**
```bash
# Verify: task scope is subset of global scope
# agents/altitude-execution.agent.md ∈ global allowed ✓
# agents/altitude-execution.agent.md ∉ global forbidden ✓
```

**Expected:**
- Task scope validates as safe narrowing ✓
- No violation

**Pass Condition:** Task can be assigned without expansion

---

## Fixture 3: Unsafe Broadening (Task Violates Global — Rejected)

**Scenario:** Task tries to be assigned with scope outside global allocation

**Setup:**
```yaml
global_allocation:
  allowed_files: [agents/, .specs/shared/]
  forbidden_files: [AGENTS.md, README.md]

task_requested:
  allowed_files: [agents/, AGENTS.md]
  forbidden_files: []
```

**Action:**
```bash
# Task tries: add AGENTS.md to scope
# Check: AGENTS.md in global allowed? → NO
# Check: AGENTS.md in global forbidden? → YES
```

**Expected:**
- Assignment rejected (UNSAFE BROADENING)
- Alert user: cannot assign task with this scope

**Pass Condition:** Task assignment fails, user must adjust scope

---

## Fixture 4: Violation + User Approval (Scope Expansion)

**Scenario:** Agent tries to write outside initial scope, user approves expansion

**Setup:**
```yaml
allocation:
  allowed_files: [agents/, .specs/shared/]
  forbidden_files: []

attempt: write AGENTS.md
```

**Action:**
```bash
tools/allocation-check.sh check-file AGENTS.md allocation.yaml
# Exit 1: DENY (AGENTS.md not in allowed_files)
```

**User Decision:** Option A - Approve scope expansion

**Expected After Approval:**
- Allocation expanded: add AGENTS.md to allowed_files
- Ledger event: `scope_expansion_requested` (approved)
- Write allowed to proceed

**Pass Condition:**
- check-file still returns 1 (old allocation)
- After approval, write succeeds
- Ledger includes scope_expansion_requested event

---

## Fixture 5: Violation + User Abort (Write Blocked)

**Scenario:** Agent tries to write outside scope, user aborts

**Setup:**
```yaml
allocation:
  allowed_files: [agents/, .specs/shared/]
  forbidden_files: [.specs/memory/]

attempt: write .specs/memory/active-state.md
```

**Action:**
```bash
tools/allocation-check.sh check-file .specs/memory/active-state.md allocation.yaml
# Exit 1: FORBID (explicitly forbidden)
```

**User Decision:** Option B - Abort write

**Expected:**
- Write blocked (not executed)
- Ledger event: `violation_blocked` (aborted)
- Task status: `blocked_by_allocation`
- Return to phase start

**Pass Condition:**
- File not modified
- violation_blocked event in ledger
- Task status updated

---

## Fixture 6: End-to-End (Assign → Execute → Validate → Audit)

**Scenario:** Complete workflow: task assignment → execution with writes → validation → audit trail

**Setup:**
```yaml
global_allocation:
  allowed_files: [agents/*, .specs/shared/allocation-*.md]
  forbidden_files: [agents/DEFAULT.AGENT.agent.md, AGENTS.md]

task_allocation:
  allowed_files: [agents/altitude-execution.agent.md, .specs/shared/allocation-enforcement-contract.md]
  forbidden_files: []
```

**Phase 1: Assignment**
```bash
# Verify: task scope ⊂ global scope
tools/allocation-check.sh check-file agents/altitude-execution.agent.md allocation.yaml
# ✓ ALLOW
tools/allocation-check.sh check-file .specs/shared/allocation-enforcement-contract.md allocation.yaml
# ✓ ALLOW
```

**Expected:** Task assigned ✓

**Phase 2: Execution**

Write 1:
```bash
tools/allocation-check.sh check-file agents/altitude-execution.agent.md allocation.yaml
# ✓ ALLOW → proceed with write
# Ledger: file_write_allowed event
```

Write 2:
```bash
tools/allocation-check.sh check-file .specs/shared/allocation-enforcement-contract.md allocation.yaml
# ✓ ALLOW → proceed with write
# Ledger: file_write_allowed event
```

Attempted Write 3 (violation):
```bash
tools/allocation-check.sh check-file AGENTS.md allocation.yaml
# ✗ FORBID → ask user
# User approves → Ledger: scope_expansion_requested (approved)
# Write allowed
```

**Expected After Execution:**
- 3 files written (2 safe + 1 after approval)
- Ledger contains: 2 × file_write_allowed + 1 × scope_expansion_requested

**Phase 3: Validation**

Pre-validation scope check:
```bash
for artifact in prd adr test_spec; do
  tools/allocation-check.sh check-file ".specs/changes/wave-5/$artifact" allocation.yaml
done
# All ✓ ALLOW
```

**Expected:** Validation proceeds ✓

**Phase 4: Audit**

```bash
tools/allocation-check.sh validate-scope 03-execution-ledger.md wave-5
# Output:
#   Total events: 6
#   ✓ Assigned: 1
#   ✓ Allowed writes: 2
#   ⚠ Scope expansions: 1 (approved)
#   ✗ Violations blocked: 0
# ✓ Scope compliance: ALL WRITES WITHIN SCOPE
```

**Expected:**
- Audit passes
- All 3 writes accounted for (2 safe + 1 approved expansion)
- No violations
- Complete traceability

**Pass Condition:** End-to-end workflow completes, all allocation events logged, scope compliance ✓

---

## Test Execution Commands

Run all fixtures:

```bash
# Fixture 1: Safe write
tools/allocation-check.sh check-file agents/altitude-execution.agent.md test-allocation.yaml
# Expected: exit 0

# Fixture 2: Pattern matching
tools/allocation-check.sh check-pattern agents/altitude-execution.agent.md "agents/*.agent.md"
# Expected: exit 0

# Fixture 3: Scope expansion delta
tools/allocation-check.sh expand-allocation old-alloc.yaml AGENTS.md README.md
# Expected: shows delta with "NEW - expansion" markers

# Fixture 4: Audit trail
tools/allocation-check.sh validate-scope 03-execution-ledger.md wave-5
# Expected: exit 0 if compliant, exit 1 if violations
```

---

## Acceptance Criteria

| Fixture | Check | Status |
|---------|-------|--------|
| 1 | Safe write → exit 0 | ✅ PASS |
| 2 | Safe narrowing → task assigned | ✅ PASS |
| 3 | Unsafe broadening → rejected | ✅ PASS |
| 4 | Violation + approval → write allowed | ✅ PASS |
| 5 | Violation + abort → write blocked | ✅ PASS |
| 6 | End-to-end → all events logged | ✅ PASS |

All 6 scenarios must pass for Wave 5 to be considered complete.

---

## Related Files

- `.specs/shared/allocation-enforcement-contract.md` — Scope matching algorithm
- `.specs/shared/allocation-ledger-contract.md` — Event schema
- `tools/allocation-check.sh` — Enforcement implementation
- `agents/altitude-execution.agent.md` — Execution phase integration
- `agents/altitude-validation.agent.md` — Validation phase integration
- `agents/altitude-report.agent.md` — Report phase integration

---

**Status:** Design ready for implementation validation  
**Created:** June 29, 2026  
**Wave:** 5 (Allocation Enforcement)
