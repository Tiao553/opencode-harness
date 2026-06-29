# Headroom Validation Contract — Wave 6

**Purpose:** Define validation logic, escalation flow, and enforcement behavior for context budgets.

**Effective:** Wave 6+  
**Compatibility:** Advisory mode (Wave 6); Mandatory (Wave 7+)  
**Related:** `context-budget-contract.md`

---

## 1. Headroom Validator — Responsibilities

The Headroom Validator is a specialized decision engine for context budget enforcement.

**Owned by:** `altitude-execution`, `altitude-validation`, `altitude-report`

**Responsibility:**
- Compute available tokens before work
- Validate context safety patterns
- Detect budget violations
- Escalate to ask-user when needed
- Record budget events in ledger

**NOT Responsible For:**
- Actual token counting (estimation only)
- Context compression algorithms
- KB/skill loading (delegated to context manager)
- Task execution (delegated to task engine)

---

## 2. Validation Logic

### 2.1 Budget Check Algorithm

**Input:**
- `task_budget`: allocated tokens for task
- `available_tokens`: tokens remaining in wave
- `headroom_config`: enforcement mode (advisory/strict/unlimited)

**Process:**

```pseudo
function check_budget(task_budget, available_tokens, headroom_config):
  
  # Calculate thresholds
  headroom_min = max(
    available_tokens * 0.15,  # 15% of available
    30000                      # OR absolute 30K min
  )
  safety_margin = 5000         # Absolute minimum
  
  # Determine status
  if available_tokens >= headroom_min:
    status = "OK"
  elif available_tokens > safety_margin:
    status = "WARN"
  else:
    status = "BLOCK"
  
  # Decide action based on mode
  if headroom_config.mode == "unlimited":
    return action: "proceed", status: status
  
  elif headroom_config.mode == "advisory":
    if status == "OK":
      return action: "proceed"
    elif status == "WARN":
      return action: "warn_user", escalation: "optional"
    else:  # BLOCK
      return action: "warn_user", escalation: "strongly_recommended"
  
  elif headroom_config.mode == "strict":
    if status == "OK":
      return action: "proceed"
    elif status == "WARN":
      return action: "ask_user", options: [
        "extend_budget",
        "compress_context",
        "cancel_task"
      ]
    else:  # BLOCK
      return action: "blocked", reason: "insufficient_budget"
      # User MUST choose extend_budget or cancel_task
```

**Output:**
```yaml
budget_check_result:
  status: "OK" | "WARN" | "BLOCK"
  action: "proceed" | "warn_user" | "ask_user" | "blocked"
  available_tokens: 95000
  headroom_minimum: 30000
  gap: 65000
  escalation_level: "none" | "optional" | "required"
  options: []  # If ask_user
```

### 2.2 Pattern Validation Algorithm

**Input:**
- `context_items`: list of files/skills/domains to load
- `available_tokens`: tokens remaining

**Process:**

```pseudo
function validate_context_patterns(context_items, available_tokens):
  
  unsafe_patterns = []
  total_estimated_tokens = 0
  
  for each item in context_items:
    classification = classify_pattern(item)
    estimated = estimate_tokens(item)
    
    total_estimated_tokens += estimated
    
    if classification == "unsafe":
      unsafe_patterns.append({
        item: item,
        reason: explain_unsafe(item),
        tokens: estimated
      })
  
  # Validation decision
  if unsafe_patterns.empty() AND total_estimated_tokens <= available_tokens:
    return result: "OK", pattern: "safe", estimated_tokens: total_estimated_tokens
  
  elif unsafe_patterns.empty() AND total_estimated_tokens > available_tokens:
    return result: "WARN", pattern: "safe_but_expensive", 
           estimated_tokens: total_estimated_tokens, 
           overflow: total_estimated_tokens - available_tokens
  
  elif unsafe_patterns.not_empty() AND available_tokens > safe_threshold:
    return result: "REQUIRES_APPROVAL", pattern: "unsafe",
           unsafe_items: unsafe_patterns,
           total_tokens: total_estimated_tokens,
           required_approval: "user"
  
  else:  # unsafe AND insufficient budget
    return result: "BLOCKED", pattern: "unsafe",
           reason: "insufficient_budget_for_unsafe_pattern",
           unsafe_items: unsafe_patterns
```

**Output:**
```yaml
pattern_validation_result:
  result: "OK" | "WARN" | "REQUIRES_APPROVAL" | "BLOCKED"
  pattern: "safe" | "safe_but_expensive" | "unsafe"
  unsafe_items:
    - item: ".specs/memory/"
      reason: "Load entire KB domain tree"
      tokens: 45000
  total_estimated_tokens: 50000
  available_tokens: 25000
```

---

## 3. Escalation Flow

### 3.1 Ask-User Escalation

**Trigger:** Budget status = WARN or BLOCK, Mode = strict

**Flow:**
```
Validator detects budget issue
  ↓
Determine severity:
  - WARN + strict mode → ask-user (optional approval)
  - BLOCK + strict mode → ask-user (required decision)
  ↓
Present options to user:
  Option A: Extend budget (if possible)
  Option B: Compress context (if possible)
  Option C: Cancel task (always available)
  ↓
User chooses:
  A → Extend budget, record ledger event, proceed
  B → Compress context, revalidate budget, proceed
  C → Cancel task, record ledger event, stop
  ↓
Record escalation event in ledger
```

### 3.2 Ask-User Format

**Example: Budget Warning (WARN status)**

```
Context Budget Warning

Current Status:
- Available tokens: 25,000
- Headroom minimum: 30,000
- Gap: -5,000 (need 5K more to be safe)

Options:
A. Extend budget (Wave 6 total from 150K → 160K) [Recommended]
B. Compress context (remove non-critical skills)
C. Cancel task and try later

Choice:
```

**Example: Budget Blocked (BLOCK status)**

```
Context Budget Exceeded

Current Status:
- Available tokens: 8,000
- Safety margin: 5,000
- Below minimum - cannot proceed safely

This task requires at least 15,000 tokens but only 8K available.

Options:
A. Extend wave budget (150K → 165K+)
B. Cancel task (mandatory if no budget extension available)

Choice:
```

---

## 4. Ledger Recording

### 4.1 When to Record

**Record EVERY:**
- Budget initialization
- Context load (before + after tokens)
- Budget status check (OK/WARN/BLOCK)
- Escalation (ask-user triggered)
- User approval/rejection
- Budget extension
- Context compression
- Task cancellation

**Pattern:**
```yaml
budget_event:
  id: "unique_event_id"
  timestamp: "2026-06-29T10:15:00Z"
  type: "budget_status_check" | "context_load" | "escalation" | "user_decision"
  available_before: 150000
  available_after: 148000
  action: "allowed" | "asked_user" | "blocked"
  details: {}  # Type-specific fields
```

### 4.2 Event Details by Type

**budget_initialized**
```yaml
event_type: "budget_initialized"
total_tokens: 200000
reserved_output: 50000
available_for_work: 150000
mode: "advisory"
```

**context_load_requested**
```yaml
event_type: "context_load_requested"
context_items: [".specs/memory/kb-index.md", "skills/data-engineering/SKILL.md"]
estimated_tokens: 10000
pattern_classification: "safe"
available_before: 150000
```

**budget_status_check**
```yaml
event_type: "budget_status_check"
available_tokens: 25000
headroom_minimum: 30000
status: "WARN"
action: "warn_user"
```

**escalation_to_user**
```yaml
event_type: "escalation_to_user"
reason: "budget_warning"
available_tokens: 25000
options:
  - extend_budget
  - compress_context
  - cancel_task
user_choice: "extend_budget"
extension_amount: 20000
available_after: 45000
```

---

## 5. Unsafe Pattern Library

### 5.1 Unsafe Patterns with Costs

**Critical (> 50K tokens each):**
- Load all agents (`agents/`) → 50K+
- Load all KB domains (`skills/` + `memory/`) → 80K+
- Load entire `.specs/` recursively → 150K+
- Load git history + diffs → 200K+

**High (20K-50K tokens each):**
- Load all archived changes (`.specs/archive/`) → 80K+
- Load entire validation ledger (all runs) → 60K+
- Load all change artifacts (multiple waves) → 40K+

**Medium (10K-20K tokens each):**
- Load all phase artifacts (Intent → Ship) → 15K+
- Load all contracts (`.specs/shared/`) → 12K+

**Low (< 10K tokens):**
- Load previous phase artifacts (current change only) → 8K
- Load allocation enforcement records → 5K

### 5.2 Safe Pattern Library

**Always Safe (< 5K tokens each):**
- KB domain index (one domain) → 2K
- Single skill file → 5K-8K
- Current phase artifact → 5K-12K
- Task contract → 5K
- Active allocation → 2K
- Artifact checksum registry → 1K

---

## 6. Context Compression

### 6.1 Compression Strategies

When WARN/BLOCK status and user chooses "compress_context":

**Strategy 1: Remove Optional KB Domains**
```
Original: Load KB + 3 skill files + all contracts → 40K
Compressed: Load KB index only + 1 critical skill → 10K
Tokens freed: 30K
```

**Strategy 2: Archive Deletion**
```
Original: Include .specs/archive/ in context load → 80K
Compressed: Exclude archive, load current only → 30K
Tokens freed: 50K
```

**Strategy 3: Phase Reduction**
```
Original: Load Intent + Structure + Design + Execution → 20K
Compressed: Load Design + Execution only → 12K
Tokens freed: 8K
```

**Strategy 4: Skill Removal**
```
Original: Load 5 skills proactively → 40K
Compressed: Load 1 required skill only → 8K
Tokens freed: 32K
```

---

## 7. Configuration Schema

### 7.1 Global Headroom Config

**File:** `.specs/shared/headroom-validation.yaml` (created per wave)

```yaml
wave: 6
mode: "advisory"  # advisory | strict | unlimited

# Thresholds
thresholds:
  headroom_minimum_percent: 15      # 15% of available
  headroom_minimum_absolute: 30000  # OR 30K absolute
  safety_margin: 5000               # Hard floor

# Escalation behavior
escalation:
  warn_on_status: "WARN"            # advisory: warn, strict: ask
  block_on_status: "BLOCK"          # Always block
  ask_user_on_unsafe: true          # Ask before loading unsafe patterns

# Per-mode behavior
modes:
  advisory:
    proceed_on_ok: true
    warn_on_warn: true
    warn_on_block: true
    
  strict:
    proceed_on_ok: true
    ask_on_warn: true
    block_on_block: true

# Whitelisted unsafe patterns (override defaults)
unsafe_pattern_overrides:
  ".specs/archive/wave-1/": "allowed"  # Only for legacy migration
```

### 7.2 Task-Level Override

**File:** `.specs/changes/<change_id>/<task_id>/local-allocation.yaml`

```yaml
budget_override:
  mode: "strict"                    # Override global mode
  total_tokens: 400000              # Override task budget
  extended_budget_reason: "large_codebase_analysis"
  
  unsafe_patterns_allowed:
    - ".specs/archive/"             # Whitelist specific patterns
    - "agents/"
  
  safe_patterns_only: false          # Allow unsafe (with approval)
```

---

## 8. Integration Points

### 8.1 With Altitude-Execution

```python
# Pseudo-code
class AltitudeExecution:
  def execute_task(task):
    # Step 1: Check budget
    budget_result = headroom_validator.check_budget(
      task.budget,
      available_tokens,
      headroom_config
    )
    
    # Step 2: Handle result
    if budget_result.action == "blocked":
      escalate_to_user(budget_result)
      return BLOCKED
    
    elif budget_result.action == "ask_user":
      user_choice = ask_user(budget_result.options)
      if user_choice == "proceed":
        record_ledger_event("user_approved_unsafe_budget")
      else:
        return CANCELLED
    
    # Step 3: Proceed with task
    execute_work(task)
    record_ledger_event("task_completed")
```

### 8.2 With Altitude-Validation

```python
# Pseudo-code
class AltitudeValidation:
  def validate_task():
    # Check budget compliance
    violations = []
    
    for event in budget_ledger:
      if event.type == "unsafe_pattern_approved":
        violations.append({
          event: event,
          review_needed: true
        })
    
    # Report in validation summary
    return validation_report + budget_compliance_section
```

---

## 9. Acceptance Criteria

✅ Budget checked before context load  
✅ Safe patterns allowed without approval  
✅ Unsafe patterns blocked or require approval  
✅ Ask-user escalation working (3 options)  
✅ Ledger events recorded  
✅ Compression strategies available  
✅ Advisory/Strict modes configurable  
✅ All 6 golden fixtures pass  
✅ Backward compatible (advisory default)  

---

## 10. References

- Context Budget Contract: `context-budget-contract.md`
- Section 25: Context Loading Policy
- Section 31: RTK and Headroom
- Wave 5: Allocation Enforcement (`allocation-enforcement-contract.md`)
- Wave 4: Artifact Versioning (`artifact-registry-maintenance.md`)
