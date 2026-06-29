# Context Budget Contract — Wave 6

**Purpose:** Enforce context/token budgets before heavy work; prevent unsafe context loading; track Headroom usage.

**Effective:** Wave 6+  
**Compatibility:** Advisory mode (Wave 6); Mandatory (Wave 7+)

---

## 1. Context Budget Model

### 1.1 Budget Hierarchy

Every change, wave, and task has a three-tier budget:

```yaml
# Global budget (per-change, initialized)
context_budget:
  coordinator: "altitude"
  change_id: "wave-6"
  total_tokens: 200000
  reserved_output_tokens: 50000    # For agent response + artifacts
  available_for_work: 150000        # Available for context loading
  usage_tracking:
    kb_loaded: 12000
    skills_loaded: 18000
    artifacts_loaded: 8000
    allocation_loaded: 2000
    agents_loaded: 15000
    total_used: 55000
    remaining: 95000
    
# Task-level budget (per task/allocation)
task_budget:
  parent_change: "wave-6"
  task_id: "design-contracts"
  allocated_tokens: 50000
  overhead_tokens: 10000           # Agent reasoning
  available_for_context: 40000
  safe_context_budget: 35000
  unsafe_context_threshold: 5000
  
# Headroom thresholds
headroom:
  minimum_percent: 15              # 15% of available_for_work
  minimum_absolute: 30000          # OR absolute 30K minimum
  escalation_level: "ask-user"     # warn | ask | block
```

### 1.2 Token Accounting

**Token Classes:**

| Class | Ownership | Purpose | Count Method |
| --- | --- | --- | --- |
| Output Reserved | Agent response | Response text + artifacts | ~25% total |
| KB/Index | Context load | KB domains loaded | Lines × 3.5 tokens/line |
| Skills | Context load | Skill files loaded | Lines × 3.5 tokens/line |
| Artifacts | Context load | PRD, ADR, TEST-SPEC | Lines × 3.5 tokens/line |
| Agents | Context load | Agent descriptors | Lines × 3.5 tokens/line |
| Allocation | Context load | Local/global allocation | Lines × 3.5 tokens/line |
| Reasoning | Task execution | Agent thinking, tool calls | Variable (estimated) |
| Buffer | Safety margin | Headroom reserve | Calculated |

**Estimation Formula:**

```
estimated_tokens = line_count × 3.5 + overhead
example: 500 lines KB = 1,750 tokens + 250 overhead = 2,000 tokens
```

### 1.3 Budget States

```yaml
budget_state:
  status: "OK" | "WARN" | "BLOCK"
  
  OK:
    - remaining >= (headroom_minimum_absolute OR total × headroom_minimum_percent)
    - safe context loading allowed
    - unsafe patterns allowed with approval
    
  WARN:
    - remaining < headroom_minimum AND > safety_margin
    - warn user before loading heavy context
    - block unsafe patterns without approval
    - escalation: ask-user (reduce scope OR approve unsafe)
    
  BLOCK:
    - remaining <= safety_margin
    - block ALL context loading
    - block ALL work
    - escalation: ask-user (cancel OR extend budget)
```

---

## 2. Budget Enforcement Points

### 2.1 Execution Phase Flow

```
Altitude-Execution receives task
  ↓
1. Load task allocation + budget
  ↓
2. Calculate available tokens
   available = total - reserved_output - used_so_far
  ↓
3. Check against Headroom thresholds
   if available >= headroom_min: status = OK
   if available < headroom_min AND > safety: status = WARN
   if available <= safety: status = BLOCK
  ↓
4. Decision gate
   OK → proceed to context loading
   WARN → ask-user before loading heavy context
   BLOCK → ask-user (cancel OR extend budget)
  ↓
5. Load context (respect budget during load)
   each load: check budget BEFORE adding to context
  ↓
6. Record ledger event (budget_context_load)
  ↓
7. Execute task (within budget)
```

### 2.2 Budget Check API

**Called by: altitude-execution, altitude-validation, altitude-report**

```bash
# Check current budget status
headroom-validator.sh check-budget <task.yaml>

# Returns:
# OK: remaining=95000, headroom=30000, status=OK
# WARN: remaining=25000, headroom=30000, status=WARN, action=ask-user
# BLOCK: remaining=8000, headroom=30000, status=BLOCK, action=blocked

# Estimate context before loading
headroom-validator.sh estimate-context <context_items.txt>
# context_items.txt: file paths (one per line)
# Returns: estimated_tokens=42500, includes_unsafe=false

# Validate safe patterns before load
headroom-validator.sh validate-safe <context_list.yaml>
# Returns: patterns_ok=true OR unsafe_pattern: "load all KB domains"
```

---

## 3. Safe vs. Unsafe Context Patterns

### 3.1 Safe Patterns (Default Allowed)

| Pattern | Example | Est. Tokens | Allowed |
| --- | --- | --- | --- |
| Single KB domain index | `.specs/memory/kb-index.md` | 2,000 | ✅ Always |
| Single skill | `skills/data-engineering/SKILL.md` | 8,000 | ✅ Always |
| Active allocation | `.specs/changes/wave-6/allocation.yaml` | 2,000 | ✅ Always |
| Task contract | `.specs/shared/task-contract.md` | 5,000 | ✅ Always |
| Phase artifact (current) | `.specs/changes/wave-6/DESIGN.md` | 12,000 | ✅ Always |
| Artifact checksum | `artifact-generation-registry.yaml` | 1,000 | ✅ Always |
| Validation report (current) | `.specs/changes/wave-6/validation.md` | 8,000 | ✅ Always |

**Cost:** ~40,000 tokens typical (all safe patterns combined)

### 3.2 Unsafe Patterns (Requires Approval OR Blocked)

| Pattern | Risk | Example | Est. Tokens |
| --- | --- | --- | --- |
| Load ALL KB domains | 🔴 Critical | Load entire `skills/` + `memory/` | 80,000+ |
| Load all agents | 🔴 Critical | Load all 15 agents at once | 50,000+ |
| Load entire `.specs/` | 🔴 Critical | Recursive load all changes | 150,000+ |
| Git history load | 🔴 Critical | `git log` + diffs for all commits | 200,000+ |
| Full codebase context | 🔴 Critical | Load entire `src/` directory | 500,000+ |
| Archive all changes | 🟠 High | Load `.specs/archive/` + current | 100,000+ |
| Load all validation runs | 🟠 High | Load entire validation ledger | 60,000+ |
| Speculative future skills | 🟠 High | Load skills for Wave 8-17 | 80,000+ |

**Decision Logic:**
```
Pattern detected: UNSAFE
available_tokens = 25,000
pattern_cost = 60,000

25,000 < 60,000 → BLOCK (insufficient budget)

IF user approves UNSAFE:
  -> Mark in ledger as approved_unsafe_context
  -> Reduce available budget
  -> Proceed if available > 0
  
IF user cancels:
  -> Cancel task
  -> Suggest compress OR extend budget
```

---

## 4. Budget Ledger Schema

### 4.1 Ledger Events

**Location:** `.specs/changes/<change_id>/03-budget-ledger.md`

```yaml
budget_ledger:
  change_id: "wave-6"
  initialized: 2026-06-29T10:00:00Z
  total_tokens: 200000
  reserved_output: 50000
  available_for_work: 150000
  
  events:
    - id: "budget_initialized"
      timestamp: 2026-06-29T10:00:00Z
      available_before: 150000
      available_after: 150000
      action: "initialize"
      
    - id: "context_load_kb"
      timestamp: 2026-06-29T10:15:00Z
      context_type: "kb_domain_index"
      context_path: ".specs/memory/kb-index.md"
      estimated_tokens: 2000
      pattern: "safe"
      available_before: 150000
      available_after: 148000
      status: "OK"
      action: "allowed"
      
    - id: "context_load_skill"
      timestamp: 2026-06-29T10:30:00Z
      context_type: "skill"
      context_path: "skills/data-engineering/SKILL.md"
      estimated_tokens: 8000
      pattern: "safe"
      available_before: 148000
      available_after: 140000
      status: "OK"
      action: "allowed"
      
    - id: "budget_warning"
      timestamp: 2026-06-29T14:00:00Z
      available_tokens: 25000
      headroom_minimum: 30000
      gap: -5000
      status: "WARN"
      action: "ask_user"
      escalation_options:
        - "approve_unsafe_pattern"
        - "compress_context"
        - "cancel_task"
      
    - id: "budget_escalation_approved"
      timestamp: 2026-06-29T14:05:00Z
      user_choice: "compress_context"
      action: "compress_kb_index"
      tokens_freed: 8000
      available_after: 33000
      status: "OK"
```

### 4.2 Ledger Queries

**Query: Current Budget Status**
```bash
grep -A 5 "available_after:" 03-budget-ledger.md | tail -1
# Output: available_after: 33000
```

**Query: Unsafe Patterns Approved**
```bash
grep "approved_unsafe_context" 03-budget-ledger.md | wc -l
# Output: 2 (two unsafe patterns approved)
```

**Query: Budget History**
```bash
grep "timestamp:" 03-budget-ledger.md | sort
# Timeline of all budget events
```

---

## 5. Configuration & Modes

### 5.1 Enforcement Modes

```yaml
# Mode 1: Advisory (Wave 6 default)
headroom_config:
  mode: "advisory"
  behavior:
    - warn on WARN status
    - block on BLOCK status (can override)
    - log all budget events
    - no task cancellation
    - no context compression
    
# Mode 2: Strict (Wave 7+ default)
headroom_config:
  mode: "strict"
  behavior:
    - block on WARN status (ask-user to extend budget)
    - block on BLOCK status (must cancel or extend)
    - enforce unsafe pattern blocking
    - mandatory context compression when possible
    - automatic task cancellation on overflow
    
# Mode 3: Unlimited (Testing/Special)
headroom_config:
  mode: "unlimited"
  behavior:
    - ignore all budget checks
    - log events only
    - never ask-user
    - for experimental work only
```

### 5.2 Per-Task Override

```yaml
task_contract:
  task_id: "explore-large-codebase"
  budget_override:
    mode: "strict"           # Override change mode
    total_tokens: 400000     # Extend budget just for this task
    unsafe_patterns_allowed:
      - "load_entire_specs"  # Whitelist specific patterns
```

---

## 6. Backward Compatibility

### 6.1 Pre-Wave 6 Behavior

Tasks without explicit budget:
- Assume unlimited budget (backward compatible)
- Log warning: "Budget not configured for task X"
- Proceed with advisory warnings only
- No blocking

### 6.2 Migration Path

```
Wave 6: Advisory mode (default), warn only
Wave 7: Strict mode (default), enforce blocking
Wave 8+: Legacy advisory mode removed
```

---

## 7. Integration with Other Contracts

### 7.1 Allocation Enforcement (Wave 5)

**Relationship:** Independent but complementary

| Aspect | Allocation (Wave 5) | Budget (Wave 6) |
| --- | --- | --- |
| Enforces | File scope | Token consumption |
| Prevents | Scope creep | Context overflow |
| Escalates | Ask-user (approve/abort) | Ask-user (approve/compress/cancel) |
| Ledger | allocation-events | budget-events |

Both can block independently:
```
if (scope_violation AND budget_exceeded):
  -> ask-user for both constraints
```

### 7.2 Artifact Versioning (Wave 4)

**Usage:** Artifact checksum + timeline queries are safe context loads

```yaml
context_load_artifact_checksum:
  artifact: "prd.md"
  checksum_size: 100 bytes
  timeline_query_tokens: 500
  total_tokens: 600
  pattern: "safe"  # Always safe to load metadata
```

---

## 8. Validation & Evidence

### 8.1 Golden Fixtures

Each fixture scenario includes:
- Input budget state
- Context load request
- Expected budget state
- Expected action (allowed/warned/blocked)
- Expected ledger event
- User interaction (if ask-user)

### 8.2 Acceptance Evidence

```bash
# Verify budget state
headroom-validator.sh check-budget wave-6-task.yaml
# Expected: status=OK, remaining=95000

# Verify safe pattern allowed
headroom-validator.sh validate-safe safe-contexts.yaml
# Expected: patterns_ok=true

# Verify unsafe pattern blocked
headroom-validator.sh validate-safe unsafe-contexts.yaml
# Expected: unsafe_pattern="load_all_kb_domains"

# Verify ledger recorded
grep "budget_initialized" .specs/changes/wave-6/03-budget-ledger.md
# Expected: one entry found
```

---

## 9. Rollback

### 9.1 Emergency Rollback

If context budget enforcement causes issues:

```bash
# Disable Wave 6 budget checks
export HEADROOM_MODE=unlimited

# Or update config
echo 'mode: advisory' > .specs/shared/headroom-validation.yaml
```

### 9.2 Recovery

1. Identify which task hit budget limit
2. Review 03-budget-ledger.md for events
3. Compress context (remove unnecessary KB/skills)
4. Extend budget for that task or wave
5. Resume execution

---

## 10. References

- Section 25: Context Loading Policy (existing)
- Section 31: RTK and Headroom (existing)
- Wave 5: Allocation Enforcement (allocation-enforcement-contract.md)
- Wave 4: Artifact Versioning (artifact-registry-maintenance.md)
