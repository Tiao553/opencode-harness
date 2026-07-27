# Wave 6: Context Budget & Headroom Validation — Design

**Wave:** 6 of 17  
**Status:** Design Phase  
**Goal:** Enforce context budgets before heavy work; prevent unsafe context loading; track Headroom usage.

---

## 1. Problem Statement

### Current State
- Context loading decisions are advisory (section 25, AGENTS.md)
- No enforcement of token budgets
- No prevention of unsafe context loading
- Headroom calculations are reactive (post-load), not proactive

### Pain Points
- Large codebases can overwhelm context budget silently
- No early warning before exceeding limits
- Unsafe context patterns not prevented
- Difficult to predict context usage

### Success Criteria
✅ Context budget computed **before** heavy work  
✅ Budget changes loading strategy dynamically  
✅ Unsafe context can block execution when configured  
✅ Compression or omission is traceable  
✅ No surprises at runtime

---

## 2. Scope & Non-Scope

### In Scope
- Context budget initialization (per-task, per-wave, global)
- Safe vs. unsafe context patterns
- Headroom validator tool (`tools/headroom-validator.sh`)
- Pre-execution budget checks
- Budget overflow escalation (ask-user)
- Ledger tracking (budget events)
- Agent updates (execution, validation, report)
- Golden fixtures (6 scenarios)

### Out of Scope
- Actual token counting (Claude/OpenRouter specifics)
- Context compression algorithms
- KB/skill loading optimization (Wave 7+)
- Real-time token usage tracking
- Multi-model context differences

---

## 3. Design Decisions

### 3.1 Budget Model

**Global Budget** (per-change):
```yaml
context_budget:
  total_tokens: 200000        # Hard limit (Claude/OpenRouter)
  reserved_output: 50000      # Reserved for response + artifacts
  available_for_work: 150000  # Available for KB, skills, context
```

**Task Budget** (per task/allocation):
```yaml
task_budget:
  allocated_tokens: 50000
  overhead: 10000             # Agent reasoning, tool calls
  available_for_context: 40000
```

**Headroom** (safety margin):
```yaml
headroom:
  minimum_percent: 15         # Never go below 15% available
  safety_margin: 10000        # Minimum absolute tokens left
  escalation_level: "ask-user" # Ask before going below headroom
```

### 3.2 Budget Enforcement Points

**Phase:** Execution (altitude-execution)  
**Timing:** Pre-context-load → Pre-work-dispatch → Post-artifact-write

**Logic Flow:**
```
1. Load current allocation + task budget
2. Calculate available tokens (remaining = total - used)
3. Check against Headroom minimum
4. If available >= required:
   -> proceed (record in ledger)
5. If available < required AND available > headroom:
   -> warn (record in ledger)
6. If available <= headroom:
   -> ask-user (approve/compress/cancel)
   -> escalate if needed
```

### 3.3 Safe vs. Unsafe Context Patterns

**Safe Patterns:**
- Load only required KB domain index (2-5 KB)
- Load only required skill (1 skill per task)
- Load only active allocation + task contract
- Load recent phase artifacts only
- Load cached checksum + timeline queries

**Unsafe Patterns:**
- Load all KB domains at once
- Load all skills for future flexibility
- Load entire `.specs/` directory
- Load full git history
- Load all agents/plugins
- Load all archived changes

### 3.4 Budget Ledger Events

**Event Types:**
```yaml
budget_events:
  - type: budget_initialized
    wave: 6
    total_tokens: 200000
    timestamp: 2026-06-29T10:00:00Z
    
  - type: context_load_planned
    context_type: "KB domain"
    estimated_tokens: 5000
    available_before: 150000
    available_after: 145000
    
  - type: budget_warning
    available_tokens: 25000
    headroom_minimum: 30000
    action: "warn_user"
    
  - type: budget_escalation
    available_tokens: 12000
    headroom_minimum: 30000
    action: "ask_user"
    options: ["approve_unsafe", "compress_context", "cancel_work"]
    user_choice: "compress_context"
    
  - type: budget_overflow
    required_tokens: 45000
    available_tokens: 10000
    action: "blocked"
```

### 3.5 Artifact Output

**Budget Summary (in phase artifacts):**
```markdown
## Context Budget Summary

| Metric | Value |
| --- | --- |
| Total Budget | 200,000 |
| Reserved Output | 50,000 |
| Available for Work | 150,000 |
| Used So Far | 87,500 |
| Remaining | 62,500 |
| Headroom Min (15%) | 30,000 |
| Safety Status | ✅ Safe |

## Budget Events
- [10:00] Initialize budget (150K available)
- [10:15] Load KB (5K) → 145K remaining
- [10:45] Load skill (8K) → 137K remaining
- [11:30] Load allocation (2K) → 135K remaining
```

---

## 4. Implementation Plan

### 4.1 Shared Contracts (2 files, 800 lines)

**`context-budget-contract.md`** (450 lines)
- Budget model (global, task, headroom)
- Enforcement points + flow diagram
- Safe vs. unsafe patterns (with examples)
- API: `context-budget` struct
- Rollback behavior

**`headroom-validation-contract.md`** (350 lines)
- Validator logic (check-budget, estimate-context, validate-safe)
- Escalation flow (warn → ask → block)
- Ledger schema (budget events)
- Backward compatibility (advisory mode)
- Configuration (strict vs. advisory)

### 4.2 Custom Tool (2 files, 600 lines)

**`tools/headroom-validator.sh`** (400 lines)
- Commands:
  - `check-budget <task.yaml>` → Budget status (OK/WARN/BLOCK)
  - `estimate-context <context_items>` → Estimated tokens
  - `validate-safe <context_list>` → Safe pattern check
  - `ledger-add <event.yaml>` → Record budget event
  - `report <change_id>` → Budget summary

**`tools/headroom-validator.contract.md`** (200 lines)
- Command reference
- Return codes
- Usage examples per phase

### 4.3 Agent Updates (3 files, 200 lines)

**`altitude-execution`**
- Pre-work budget check (before KB load)
- Ask-user escalation (if warning/block)
- Ledger recording (all budget events)

**`altitude-validation`**
- Budget compliance check (validation phase)
- Context unsafe pattern detection
- Audit trail (budget overflow review)

**`altitude-report`**
- Budget summary section
- Context efficiency metrics
- Recommendations (compress/extend budget)

### 4.4 Golden Fixtures (6 scenarios, 500 lines)

1. **Safe Context Load** → Budget OK, proceed
2. **Safe with Warning** → Budget near limit, warn user
3. **Unsafe Pattern Detected** → Pattern blocked
4. **Budget Exceeded (Block)** → No available budget, blocked
5. **Approval Escalation** → User approves unsafe context
6. **End-to-End** → Full cycle: init → load → check → report

---

## 5. Integration Points

### Before Wave 6
- Wave 5 Allocation Enforcement (completed)
- Wave 4 Artifact Versioning (completed)
- Section 25: Context Loading Policy (existing)

### After Wave 6
- Wave 7: Ralph Loop Verification (uses budget events for tracing)
- Wave 8: KB Quality (respects budget constraints)
- Artifact checksum validation (context verification)

---

## 6. Risk Assessment

| Risk | Probability | Impact | Mitigation |
| --- | --- | --- | --- |
| Budget too conservative | Low | Low | Advisory mode available, configurable |
| Token counting mismatch | Medium | Medium | Round up estimates, test with real LLMs |
| False positive unsafe patterns | Low | Medium | Whitelist known safe patterns, allow override |
| Backward compatibility break | Low | High | Advisory mode by default, opt-in strict |

---

## 7. Acceptance Criteria

✅ Context budget computed before heavy work  
✅ Budget changes loading strategy  
✅ Unsafe context patterns blocked (with approval option)  
✅ All budget events ledger-recorded  
✅ All 6 golden fixtures pass  
✅ No breaking changes to existing agents  
✅ Budget summary in phase artifacts  
✅ Configuration (strict vs. advisory) working  

---

## 8. Files to Create/Modify

**Create:**
- `.specs/changes/wave-6-context-budget/DESIGN.md` (this file)
- `.specs/shared/context-budget-contract.md` (450 lines)
- `.specs/shared/headroom-validation-contract.md` (350 lines)
- `tools/headroom-validator.sh` (400 lines)
- `tools/headroom-validator.contract.md` (200 lines)
- `test/fixtures/harness-v3/wave-6-context-budget.fixture.md` (500 lines)

**Modify:**
- `agents/altitude-execution.agent.md` (+80 lines)
- `agents/altitude-validation.agent.md` (+50 lines)
- `agents/altitude-report.agent.md` (+70 lines)
- `AGENTS.md` (+40 lines for section 21.5 + 21.6)
- `README.md` (Wave 6 section)

**Total Wave 6:** ~2,700 lines

---

## 9. Next Steps

1. ✅ Design phase complete
2. Create shared contracts (context-budget + headroom-validation)
3. Implement headroom-validator.sh tool
4. Update agents (execution, validation, report)
5. Create golden fixtures (6 scenarios)
6. Update documentation (README + AGENTS.md)
7. Commit to branch `wave-6-context-budget`
8. Create PR #5 to main
