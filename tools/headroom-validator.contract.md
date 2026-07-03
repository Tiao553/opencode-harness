# Headroom Validator Tool Contract

**Tool:** `tools/headroom-validator.sh`
**Wave:** 6
**Purpose:** Validate context budgets, estimate token usage, enforce safe context patterns

---

## 1. Command Reference

### 1.1 check-budget

**Purpose:** Check current budget status for a task

**Syntax:**
```bash
headroom-validator.sh check-budget <task.yaml>
```

**Input:** YAML file with task budget configuration
```yaml
task_id: "design-contracts"
allocated_tokens: 50000
available_tokens: 95000
mode: "advisory"  # or "strict" or "unlimited"
```

**Output:** YAML with budget status
```yaml
budget_check_result:
  status: "OK" | "WARN" | "BLOCK"
  action: "proceed" | "warn_user" | "blocked"
  available_tokens: 95000
  headroom_minimum: 30000
  safety_margin: 5000
  mode: "advisory"
```

**Exit Codes:**
- `0` = OK (safe to proceed)
- `1` = WARN (warning, still safe)
- `2` = BLOCK (cannot proceed)
- `3` = ERROR (validation error)

**Example:**
```bash
$ headroom-validator.sh check-budget wave-6-task.yaml
ℹ Budget Check Result
ℹ Available: 95000 tokens
ℹ Headroom min: 30000 tokens
ℹ Safety margin: 5000 tokens
ℹ Status: OK
ℹ Action: proceed
budget_check_result:
  status: OK
  action: proceed
  available_tokens: 95000
  headroom_minimum: 30000
  safety_margin: 5000
  mode: advisory
```

---

### 1.2 estimate-context

**Purpose:** Estimate token usage for a list of context items

**Syntax:**
```bash
headroom-validator.sh estimate-context <context_list.txt>
```

**Input:** Text file with one path per line
```
.specs/memory/kb-index.md
skills/data-engineering/SKILL.md
.specs/shared/context-budget-contract.md
.specs/changes/wave-6/allocation.yaml
```

**Output:** YAML with token estimates
```yaml
context_estimation_result:
  total_estimated_tokens: 25000
  includes_unsafe: false
  context_items: 4
```

**Estimation Formula:**
```
per_file_tokens = (lines × 3.5) + 250 overhead
example: 500 lines = (500 × 3.5) + 250 = 2,000 tokens
```

**Example:**
```bash
$ headroom-validator.sh estimate-context context-items.txt
ℹ Estimating context tokens...
ℹ   .specs/memory/kb-index.md: 2000 tokens (safe/kb_index)
ℹ   skills/data-engineering/SKILL.md: 8000 tokens (safe/skill)
ℹ Total estimated: 25000 tokens (unsafe: false)
```

---

### 1.3 validate-safe

**Purpose:** Validate that context patterns are safe (non-unsafe)

**Syntax:**
```bash
headroom-validator.sh validate-safe <context_list.yaml>
```

**Input:** YAML or text file with context items
```yaml
context_items:
  - .specs/memory/kb-index.md
  - skills/data-engineering/SKILL.md
  - .specs/changes/wave-6/allocation.yaml
```

**Output:** YAML with pattern validation result
```yaml
pattern_validation_result:
  patterns_ok: true | false
  unsafe_patterns: []  # or list of unsafe items
```

**Exit Codes:**
- `0` = All patterns safe
- `2` = Unsafe patterns detected
- `3` = ERROR

**Example:**
```bash
# Safe patterns
$ headroom-validator.sh validate-safe safe-contexts.yaml
✓ All patterns are safe
pattern_validation_result:
  patterns_ok: true
  unsafe_patterns: []

# Unsafe patterns
$ headroom-validator.sh validate-safe unsafe-contexts.yaml
⚠ Unsafe pattern: .specs/
✗ Found 1 unsafe pattern(s)
pattern_validation_result:
  patterns_ok: false
  unsafe_patterns:
    - ".specs/"
```

---

### 1.4 ledger-add

**Purpose:** Record a budget event in the budget ledger

**Syntax:**
```bash
headroom-validator.sh ledger-add <event.yaml> [change_id]
```

**Input:** YAML file with event details
```yaml
event_type: "budget_check"
timestamp: "2026-06-29T10:15:00Z"
available_tokens: 95000
status: "OK"
action: "proceed"
```

**Output:** Confirmation message

**Ledger Location:**
```
.specs/changes/<change_id>/03-budget-ledger.md
```

**Example:**
```bash
$ headroom-validator.sh ledger-add budget-event.yaml wave-6
ℹ Creating budget ledger: .specs/changes/wave-6/03-budget-ledger.md
✓ Budget event recorded
```

---

### 1.5 report

**Purpose:** Generate a budget report for a change

**Syntax:**
```bash
headroom-validator.sh report <change_id>
```

**Output:** Text report with budget summary

**Example:**
```bash
$ headroom-validator.sh report wave-6
ℹ Budget Report: wave-6
ℹ
ℹ Total budget events: 5
ℹ
ℹ Recent events:
# Event: 2026-06-29T10:15:00Z
event_type: budget_check
available_tokens: 95000
status: OK
```

---

## 2. Safe Pattern Library

### 2.1 Safe Patterns (Always Allowed)

| Pattern | Type | Est. Tokens | Decision |
| --- | --- | --- | --- |
| `.specs/memory/kb-index.md` | KB index | 2K | ✅ Auto-allow |
| `skills/*/SKILL.md` | Single skill | 5K-8K | ✅ Auto-allow |
| `.specs/shared/*-contract.md` | Contract | 8K-12K | ✅ Auto-allow |
| `.specs/changes/X/allocation.yaml` | Allocation | 2K | ✅ Auto-allow |
| `.specs/changes/X/DESIGN.md` | Phase artifact | 5K-15K | ✅ Auto-allow |
| `artifact-generation-registry.yaml` | Registry | 1K | ✅ Auto-allow |

**Combined safe patterns cost:** ~40K tokens typical

### 2.2 Unsafe Patterns (Requires Approval)

| Pattern | Risk | Est. Tokens | Decision |
| --- | --- | --- | --- |
| `.specs/` (recursively) | 🔴 Critical | 150K+ | ❌ Block unless approved |
| `skills/` (all) | 🔴 Critical | 80K+ | ❌ Block unless approved |
| `agents/` (all) | 🔴 Critical | 50K+ | ❌ Block unless approved |
| `.git/` (history) | 🔴 Critical | 200K+ | ❌ Block unless approved |
| `.specs/archive/` | 🟠 High | 80K+ | ❌ Block unless approved |

---

## 3. Budget Modes

### 3.1 Advisory Mode (Default)

**Behavior:**
- ✅ OK status: Proceed without confirmation
- ⚠️ WARN status: Warn user, still allow proceed
- 🔴 BLOCK status: Warn user strongly

**Use Case:** Development, initial implementation, Wave 6

**Command:**
```bash
task_config.yaml:
  mode: "advisory"
```

### 3.2 Strict Mode

**Behavior:**
- ✅ OK status: Proceed without confirmation
- ⚠️ WARN status: Ask user (extend budget OR compress context OR cancel)
- 🔴 BLOCK status: Blocked, cannot proceed

**Use Case:** Production, Wave 7+, high-risk tasks

**Command:**
```bash
task_config.yaml:
  mode: "strict"
```

### 3.3 Unlimited Mode

**Behavior:**
- ✅ OK status: Always proceed
- ⚠️ WARN status: Always proceed (with warning)
- 🔴 BLOCK status: Always proceed (with warning)

**Use Case:** Testing, experimental, exploration

**Command:**
```bash
task_config.yaml:
  mode: "unlimited"

# OR environment variable
export HEADROOM_MODE=unlimited
```

---

## 4. Integration Examples

### 4.1 Altitude-Execution Integration

```bash
#!/bin/bash
# Pseudo-code for altitude-execution

task_yaml="$TASK_PATH/task.yaml"
context_list="$TASK_PATH/context-items.txt"

# Step 1: Check budget
budget_result=$(headroom-validator.sh check-budget "$task_yaml")
budget_status=$(echo "$budget_result" | grep "status:" | awk '{print $2}')

if [[ "$budget_status" == "BLOCK" ]]; then
  echo "ERROR: Budget exceeded, cannot proceed"
  exit 2
fi

# Step 2: Estimate context
context_result=$(headroom-validator.sh estimate-context "$context_list")
estimated_tokens=$(echo "$context_result" | grep "total_estimated_tokens:" | awk '{print $2}')

# Step 3: Validate patterns
pattern_result=$(headroom-validator.sh validate-safe "$context_list")
patterns_ok=$(echo "$pattern_result" | grep "patterns_ok:" | awk '{print $2}')

if [[ "$patterns_ok" == "false" ]]; then
  echo "ERROR: Unsafe patterns detected"
  exit 1
fi

# Step 4: Record event
headroom-validator.sh ledger-add budget-check-event.yaml wave-6

# Step 5: Proceed with task
echo "Proceeding with task, using ~$estimated_tokens tokens"
```

### 4.2 Altitude-Validation Integration

```bash
#!/bin/bash
# Pseudo-code for altitude-validation

change_id="$1"

# Check budget compliance
echo "## Budget Compliance"
echo ""

# Run budget report
headroom-validator.sh report "$change_id" >> validation-report.md

# Validate no budget violations
if grep -q "BLOCK" .specs/changes/$change_id/03-budget-ledger.md; then
  echo "⚠️ WARNING: Budget exceeded during execution"
  exit 1
fi

echo "✓ Budget compliance validated"
```

---

## 5. Error Handling

### 5.1 Error Codes

| Code | Meaning | Typical Cause | Recovery |
| --- | --- | --- | --- |
| 0 | Success | OK status | Continue |
| 1 | Warning | WARN status | Proceed with caution |
| 2 | Blocked | BLOCK status | Extend budget or cancel |
| 3 | Error | Invalid input | Check file paths |

### 5.2 Common Errors

**Error:** "Task file not found: wave-6-task.yaml"
```
Solution: Verify file path and existence
$ ls -la .specs/changes/wave-6/task.yaml
```

**Error:** "Context list not found: context-items.txt"
```
Solution: Create context items file
$ echo ".specs/memory/kb-index.md" > context-items.txt
```

**Error:** "Ledger not found"
```
Solution: Create ledger first or check change_id
$ mkdir -p .specs/changes/wave-6/
$ headroom-validator.sh ledger-add event.yaml wave-6
```

---

## 6. Output Formats

### 6.1 Console Output

```
ℹ (info)   - Blue informational messages
✓ (ok)     - Green success indicators
⚠ (warn)   - Yellow warnings
✗ (error)  - Red error messages
```

### 6.2 YAML Output

All results are output as YAML for machine parsing:
```yaml
result_type:
  field1: value1
  field2: value2
```

### 6.3 JSON Output (Future)

JSON output support can be added in Wave 7+ via `--format json` flag

---

## 7. Usage Checklist

- [ ] Check budget before loading context
- [ ] Estimate context tokens before decision
- [ ] Validate patterns are safe
- [ ] Record budget events in ledger
- [ ] Generate report for validation
- [ ] Review budget compliance in validation phase
- [ ] Update README with Wave 6 changes

---

## 8. Testing Commands

```bash
# Test successful budget check
./tools/headroom-validator.sh check-budget .specs/changes/wave-6/task.yaml

# Test context estimation
./tools/headroom-validator.sh estimate-context context-list.txt

# Test safe pattern validation
./tools/headroom-validator.sh validate-safe safe-contexts.yaml

# Test unsafe pattern detection
./tools/headroom-validator.sh validate-safe unsafe-contexts.yaml

# Test ledger recording
./tools/headroom-validator.sh ledger-add event.yaml wave-6

# Test budget report
./tools/headroom-validator.sh report wave-6

# Test help
./tools/headroom-validator.sh help
```

---

## 9. References

- Context Budget Contract: `.specs/shared/context-budget-contract.md`
- Headroom Validation Contract: `.specs/shared/headroom-validation-contract.md`
- Wave 6 Design: `.specs/changes/wave-6-context-budget/DESIGN.md`
- AGENTS.md Section 31: RTK and Headroom
