# Altitude File Reading Heuristic — Wave 24

**Version:** 1.0  
**Date:** 2026-07-03  
**Status:** Active  
**Scope:** All 9 altitude + data-engineer agents  
**Mode:** AGGRESSIVE (plugin-driven with automatic hooks)  

---

## Purpose

Define a **step-by-step disciplined approach** to file reading for all altitude agents, ensuring:
- ✅ Minimal context loading (no preloads)
- ✅ Automatic RTK compression when needed
- ✅ Headroom budget enforcement
- ✅ Complete TODOWRITE audit trail
- ✅ Explicit QUESTION() only when decision-required

---

## Core Rules

### Rule 1: Load Minimum Context

**Before any file read:**

```
1. What is the current task?
2. What files are REQUIRED for this task?
3. Which files are OPTIONAL/NICE-TO-HAVE?
4. How much headroom budget remains?
```

**Default:** Load only REQUIRED files. Load OPTIONAL only if blocked.

---

### Rule 2: Automatic RTK + Headroom

**How plugin intercepts:**

```
altitude_read('file.md')
  → Check Headroom budget
  → If budget_low: apply RTK compression
  → Log to TODOWRITE: "FILE_READ | file.md | size_KB | compressed: true/false"
  → Return: { content, bytes_used, compressed }
```

**Example flow:**

```
✅ PRD.md (216 lines, ~10KB)
   Headroom: 150KB remaining
   → Read normal, no compression
   → TODOWRITE: "PRD.md read (10KB, normal)"

⚠️ 5 design docs (total ~80KB)
   Headroom: 15KB remaining
   → Apply RTK lossy compression
   → TODOWRITE: "Design docs read (80KB → 15KB compressed)"

❌ Full archive (500KB)
   Headroom: 2KB remaining
   → BLOCK read, raise QUESTION
   → "Insufficient headroom. Load specific files or increase budget?"
```

---

### Rule 3: TODOWRITE Logging (Evidence Track)

**Every file read logged with:**

| Field | Example | Required |
|-------|---------|----------|
| Operation | FILE_READ | YES |
| Agent | altitude-maestro | YES |
| File | PRD.md | YES |
| Size (bytes) | 2048 | YES |
| Compressed | true/false | YES |
| Decision Required | true/false | YES |
| Timestamp | 2026-07-03T15:30:00Z | YES |

**TODOWRITE format:**

```yaml
- content: "BLOCO N | T-YY | FILE_READ: PRD.md (2KB, normal) | Agent: altitude-maestro"
  status: completed
  priority: high
```

---

### Rule 4: QUESTION() Only When block_decision_required

**When to raise QUESTION():**

```
❌ NOT: "Shall I read file X?"  (use heuristic instead)
❌ NOT: "Which compression level?" (use auto-detection)

✅ YES: "Headroom exhausted. Read critical files only or increase budget?"
✅ YES: "File scope ambiguous (N files match pattern). Which ones?"
✅ YES: "Allocation violation: file outside allowed scope. Override?"
```

**Decision gate checklist:**

```
Is decision blocking execution?
  NO → Use heuristic, proceed automatically
  YES → Raise QUESTION with multi-scenario

Can heuristic choose safe default?
  YES → Use default, log in TODOWRITE
  NO → Raise QUESTION, wait for user input
```

---

### Rule 5: Recovery Protocol Standard

**Every altitude agent must include:**

```markdown
## Recovery Protocol

### File Reading Discipline

1. Load `.specs/shared/altitude-file-reading-heuristic.md`
2. Check Headroom budget: `altitude_check_headroom()`
3. List REQUIRED files for this phase/task
4. Call altitude_read() for each file (plugin handles RTK + logging)
5. If block_decision_required: raise_question() with GRILL ME pattern
6. Proceed with loaded context

### TODOWRITE Logging

All file operations tracked:
- FILE_READ operations logged with size + compression status
- QUESTION operations logged with user response
- Phase context cached in memory

### Error Handling

- Headroom budget exceeded → QUESTION (user increases or reads fewer files)
- RTK compression failed → Fall back to truncation
- File not found → Escalate to validation gate
```

---

## Usage Examples

### Example 1: Normal load in altitude-plan (design phase)

```
Task: Load design context for task decomposition
Budget: 200KB remaining
Required files: PRD.md, ADR.md, TEST-SPEC.md, DESIGN.md

→ altitude_read('PRD.md')        # 10KB, logged
→ altitude_read('ADR.md')        # 8KB, logged
→ altitude_read('TEST-SPEC.md')  # 15KB, logged
→ altitude_read('DESIGN.md')     # 25KB, logged
→ Total: 58KB loaded, budget OK

TODOWRITE entries:
- "FILE_READ: PRD.md (10KB, normal)"
- "FILE_READ: ADR.md (8KB, normal)"
- "FILE_READ: TEST-SPEC.md (15KB, normal)"
- "FILE_READ: DESIGN.md (25KB, normal)"
```

### Example 2: Low budget in altitude-execution (execution phase)

```
Task: Load state + active task context
Budget: 5KB remaining
Required: state.md (3KB), active-task.yaml (2KB)
Optional: lessons.md (10KB), memory-index.md (5KB)

→ altitude_read('state.md')         # 3KB, no compression
→ altitude_read('active-task.yaml') # 2KB, no compression
→ Budget exhausted (5KB used)

Optional files not loaded (budget constraint)
Lessons available at memory load time

TODOWRITE entries:
- "FILE_READ: state.md (3KB, normal)"
- "FILE_READ: active-task.yaml (2KB, normal)"
- "BUDGET_STATUS: 0KB remaining (lessons deferred)"
```

### Example 3: Budget exhausted + RTK compression

```
Task: Load validation evidence (large change)
Budget: 20KB remaining
Files needed: evidence-*.md (15 files, ~150KB)

→ Detect budget insufficient
→ Apply RTK compression to all files
→ RTK reduces 150KB → 18KB (lossy, key info preserved)
→ Load compressed content

TODOWRITE entries:
- "FILE_READ_BATCH: evidence (150KB → 18KB RTK compressed) | compression_ratio: 88%"
- "HEADROOM_ACTION: RTK compression applied (budget pressure)"
```

### Example 4: File scope ambiguity

```
Task: Load relevant KB articles
Glob pattern: kb/**/*.md (matches 500 files)
Budget: 30KB available
Question: "Which KB domains relevant to this task?"

→ Cannot decide automatically
→ Raise QUESTION with user: "KB matching pattern. Select domains?"

User response: "Only data-engineering + spark"
→ Filter: kb/data-engineering/**/*.md + kb/spark/**/*.md (8 files)
→ Load filtered set (25KB)

TODOWRITE entries:
- "QUESTION: KB pattern matched 500 files. User selected data-engineering + spark (8 files)"
- "FILE_READ_BATCH: KB (data-engineering + spark, 25KB, normal)"
```

---

## Decision Tree

```
File read requested
  │
  ├─ Is file path in allowed_files?
  │   NO  → Raise QUESTION (scope violation)
  │   YES → Continue
  │
  ├─ Is file required for current task?
  │   NO  → Ask: skip, defer, or load anyway?
  │   YES → Continue
  │
  ├─ Check Headroom: budget_remaining >= file_size?
  │   YES → Load normal, log
  │   NO  → Apply RTK compression
  │       │
  │       ├─ Compression successful?
  │       │   YES → Load compressed, log compression_ratio
  │       │   NO  → Raise QUESTION (insufficient space)
  │       │
  │       └─ User decision:
  │           A) Increase budget
  │           B) Load only critical files
  │           C) Defer to next phase
  │
  └─ Load file, return { content, bytes_used, compressed }
```

---

## Integration with Plugins

### altitude-filestore.ts

**Intercepts:**
- `altitude_read(file)`
- `altitude_glob(pattern)`
- `altitude_grep(pattern, file)`

**Applies:**
1. Headroom budget check
2. RTK compression if needed
3. TODOWRITE logging
4. File operation tracking

**Returns:**
```typescript
{
  content: string,
  bytes_used: number,
  compressed: boolean,
  logged: boolean,
  timestamp: ISO8601,
}
```

### rtk-native.ts

**Rewrites commands:**
```
read 'large-file' → rtk read 'large-file'
grep 'pattern'    → rtk grep 'pattern'
```

**Policy:** Only safe rewrites, no destructive commands

### headroom-guard.ts

**Validates budget:**
- Global budget: 100KB per change
- Per-phase budget: 30-50KB based on phase
- Escalation: WARN → ASK → BLOCK

---

## Verification

### How to verify file-reading discipline is active:

```bash
# 1. Check plugin registered
grep "altitude-filestore" opencode.json

# 2. Check heuristic loaded in agent Recovery Protocol
grep -A 10 "Recovery Protocol" agents/altitude-maestro.agent.md | grep "file-reading"

# 3. Verify TODOWRITE entries created
grep "FILE_READ\|QUESTION" .specs/changes/<change-id>/... 

# 4. Validate RTK applied
grep "compressed: true" evidence-*.md
```

---

## Known Gaps (for W25+)

1. **Performance:** No latency metrics for file operations (add in W25)
2. **Compression quality:** RTK lossy compression heuristics tunable (expert mode in W25)
3. **User feedback:** No UX testing on QUESTION scenarios (collect in W25)
4. **Archive handling:** Large archived changes may still exceed headroom (strategy for W25)

---

## References

- **Plugin Contract:** `.specs/shared/altitude-filestore-plugin-contract.md`
- **Workflow Contract:** `.specs/shared/altitude-file-reading-workflow-contract.md`
- **Headroom Policy:** `.specs/shared/headroom-validation-contract.md`
- **RTK Policy:** `.specs/shared/rtk-native-policy.md` (if exists)
- **AGENTS.md Section 21.18:** File Reading integration details

---

**Status:** ✅ ACTIVE (Wave 24, BLOCO 1)
