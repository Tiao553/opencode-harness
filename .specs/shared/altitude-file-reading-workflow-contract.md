# Altitude File Reading Workflow Contract — Wave 24

**Version:** 1.0  
**Date:** 2026-07-03  
**Binding:** All 9 altitude agents + data-engineer  
**Ralph Loop:** Mandatory for file reading operations  

---

## Contract Definition

This contract **binds file reading operations to Ralph Loop discipline** with explicit QUESTION + TODOWRITE tracking.

### Part 1: Ralph Loop Shape (File Reading)

```
1. RESTATE: What files are needed for current task?
2. IDENTIFY CONSTRAINTS: Budget? Scope? Time? Allocation?
3. PLAN: Which files load, in what order?
4. EXECUTE: Call altitude_read() for each (plugin handles RTK/Headroom)
5. VERIFY: All required files loaded? Budget OK?
6. EVALUATE: Context sufficient for task? Any gaps?
7. REPAIR: Load additional files if gaps exist
8. RECORD: Log all operations to TODOWRITE
9. UPDATE: Mark phase context cached, ready for decomposition
```

---

## Part 2: TODOWRITE Mandate

**Every file operation creates a TODOWRITE entry.**

### Entry Format

```yaml
content: "BLOCO N | T-YY | FILE_OP | Operation: [FILE_READ|FILE_SKIP|FILE_DEFER|FILE_FAILED] | File: [name] | Status: [normal|compressed|skipped] | Agent: [agent-name]"
status: completed
priority: high
```

### Examples

```yaml
# Normal read
- content: "BLOCO 1 | T-01 | FILE_READ | PRD.md (10KB, normal) | altitude-maestro"
  status: completed
  priority: high

# Compressed read (budget pressure)
- content: "BLOCO 1 | T-01 | FILE_READ | Design (80KB → 15KB RTK) | altitude-plan"
  status: completed
  priority: high

# Skipped (optional, not needed)
- content: "BLOCO 1 | T-01 | FILE_SKIP | lessons.md (deferred to memory phase) | altitude-execution"
  status: completed
  priority: medium

# Failed (error or scope violation)
- content: "BLOCO 1 | T-01 | FILE_FAILED | archive/*.md (outside allowed_files) | altitude-validation"
  status: completed
  priority: high
```

### Tracking Rules

1. ✅ **Obligation:** Every `altitude_read()` call → TODOWRITE entry
2. ✅ **Obligation:** Every `altitude_skip()` call → TODOWRITE entry
3. ✅ **Obligation:** Every RTK compression → TODOWRITE documents ratio
4. ✅ **Obligation:** Every Headroom violation → TODOWRITE documents action
5. ✅ **Permission:** Glob/grep operations → log only if ambiguous or block_decision
6. ✅ **Permission:** Cache hits → log summary, not individual hits

**Audit:** All TODOWRITE entries for file ops preserved in evidence file.

---

## Part 3: QUESTION Mandate

**QUESTION() raised ONLY when `block_decision_required`.**

### When to Raise QUESTION()

```
Headroom budget exhausted → QUESTION
  "Budget exhausted (5KB remaining). Options?"
  A) Increase budget [add context]
  B) Load critical files only [defer optional]
  C) Defer to next phase [resume later]

File glob matches multiple targets → QUESTION
  "Pattern matches 12 files. Which ones?"
  A) All [risk: high budget pressure]
  B) By domain (select KB domains)
  C) By metadata (select by size/age/relevance)

Allocation violation → QUESTION
  "Requested file outside allowed_files. Override?"
  A) Load (security risk, log)
  B) Skip (proceed without)
  C) Escalate (ask allocation owner)

RTK compression failed → QUESTION
  "Compression failed (already lossy). Options?"
  A) Truncate end of file
  B) Skip file, defer
  C) Abort task
```

### When NOT to Raise QUESTION()

```
✗ File read succeeds normally
✗ RTK compression succeeds
✗ Budget remaining sufficient
✗ File in allowed_files
✗ Decision has safe default
```

### QUESTION Format (GRILL ME Pattern)

```
Decision Point: [Title]

Current situation:
- [Evidence 1]
- [Evidence 2]
- [Constraint 1]

Options:
A) [Option A] — Trade-off: [positive] / [negative]
B) [Option B] — Trade-off: [positive] / [negative]
C) [Option C] — Trade-off: [positive] / [negative]

Recommended: [A|B|C], because [reasoning]

TODOWRITE log:
- Decision context logged
- User response logged
- Outcome logged
```

### Example QUESTION

```
Decision Point: Headroom budget exhausted

Current situation:
- Phase: altitude-execution
- Budget remaining: 2KB
- Files needed: 3 design docs (40KB estimated)
- Already loaded: PRD, ADR, TEST-SPEC (35KB)

Options:
A) Defer design docs to validation phase (3 hours later)
   ✅ Preserves budget for other tasks
   ❌ Blocks task decomposition now

B) Increase budget for this phase (risky)
   ✅ Complete context now
   ❌ May starve later phases

C) Load design docs compressed only (lossy)
   ✅ Get context now
   ❌ May miss important details

Recommended: A, because altitude-validation phase needs full context anyway; defer reduces risk.

TODOWRITE log:
- "QUESTION: Headroom exhausted (2KB remaining, 40KB needed). User chose: Defer to validation phase."
```

---

## Part 4: Pre-Execution Checklist (Before any phase)

**Every altitude agent Recovery Protocol must verify:**

```
File Reading Setup
─────────────────
□ Load `.specs/shared/altitude-file-reading-heuristic.md`
□ Load `.specs/shared/altitude-file-reading-workflow-contract.md`
□ Identify REQUIRED vs OPTIONAL files for phase
□ Check Headroom budget availability
□ Verify allowed_files allocation defined

Ralph Loop Preparation
──────────────────────
□ Step 1: RESTATE — What files needed?
□ Step 2: IDENTIFY — Budget, scope, time?
□ Step 3: PLAN — Load order, RTK strategy?
□ Ready for EXECUTE

TODOWRITE Tracking
──────────────────
□ TODOWRITE initialized for phase
□ FILE_READ entries will be created
□ QUESTION responses will be logged
□ Evidence file will document all ops

QUESTION Discipline
───────────────────
□ Ask-user-policy loaded (pre-call checklist)
□ GRILL ME pattern prepared if needed
□ Decision gate clear (block_decision_required?)
□ Only raise QUESTION if true blocker
```

---

## Part 5: Error Handling & Recovery

### Scenario 1: Headroom Exhausted

```
RALPH LOOP:
1. RESTATE: Load 5 design docs (50KB)
2. IDENTIFY: Budget 10KB, gap = 40KB
3. PLAN: Compress or defer
4. EXECUTE: Try RTK compression
5. VERIFY: Compressed to 8KB ✓
6. EVALUATE: Sufficient? Yes
7. REPAIR: None needed
8. RECORD: "Design docs (50KB → 8KB RTK)"
9. UPDATE: Cached, continue

TODOWRITE:
- "FILE_READ | Design docs (50KB → 8KB RTK compression) | Agent: altitude-plan"

If compression fails:
→ QUESTION: "Compression failed. Defer or truncate?"
→ Wait for user
→ Log response
→ Proceed based on choice
```

### Scenario 2: File Not Found

```
RALPH LOOP:
1-3. [same]
4. EXECUTE: altitude_read('missing.md') → ERROR
5. VERIFY: File not found
6. EVALUATE: Required? Yes → BLOCK
7. REPAIR: Check allocation, alternatives?
8. RECORD: "FILE_FAILED | missing.md (not found)"
9. UPDATE: Escalate to validation

TODOWRITE:
- "FILE_FAILED | missing.md (not found, required) | Escalated to altitude-validation"

QUESTION:
- "File missing.md not found. Alternatives?"
  A) Load similar file
  B) Proceed without
  C) Fail task
```

### Scenario 3: Allocation Violation

```
RALPH LOOP:
1-3. [same]
4. EXECUTE: altitude_read('forbidden/archive.md') → Allocation violation
5. VERIFY: File outside allowed_files
6. EVALUATE: Can proceed without? Yes → SKIP
7. REPAIR: None needed
8. RECORD: "FILE_SKIP | archive.md (outside allowed_files)"
9. UPDATE: Continue with allowed files

TODOWRITE:
- "FILE_SKIP | archive.md (outside allowed_files allocation) | Agent: altitude-execution"

If required:
→ QUESTION: "Override allocation? (security risk)"
→ Only proceed with explicit approval
→ Log override decision
```

---

## Part 6: Integration Points

### altitude-filestore.ts Plugin

**Calls:**
```typescript
altitude_read(file)
  → Check allocation (allowed_files)
  → Check Headroom budget
  → Apply RTK if needed
  → Log to TODOWRITE
  → Return { content, bytes_used, compressed }

altitude_glob(pattern)
  → Check if pattern is deterministic
  → If ambiguous: raise QUESTION
  → If deterministic: log summary

altitude_grep(pattern, file)
  → Log only if used for decision
  → Otherwise: silent operation
```

### Ralph Loop Integration

```
Phase Agent Recovery Protocol:

1. Load contracts (heuristic + workflow)
2. Pre-execution checklist
3. RESTATE task → identify required files
4. IDENTIFY constraints → check budget
5. PLAN load strategy → RTK needed?
6. Execute → call altitude_read() for each
7. Verify → all loaded? budget OK?
8. Evaluate → context sufficient?
9. Repair → additional files if gaps
10. Record → TODOWRITE entries created
11. Update → phase context cached
```

---

## Part 7: Compliance Verification

### How to audit file-reading discipline:

```bash
# 1. Verify Recovery Protocol includes pre-checklist
grep -A 20 "Recovery Protocol" agents/altitude-maestro.agent.md | grep -i "file-read"

# 2. Count TODOWRITE entries for phase
grep "FILE_READ\|FILE_SKIP" .specs/changes/<id>/... | wc -l

# 3. Verify QUESTION pattern followed (if raised)
grep "QUESTION" .specs/changes/<id>/... | grep -i "headroom\|budget\|allocation"

# 4. Validate RTK compression logged
grep "compressed: true\|RTK" .specs/changes/<id>/...

# 5. Check Headroom enforcement
grep "HEADROOM_ACTION\|BUDGET_STATUS" .specs/changes/<id>/...
```

---

## Part 8: Known Limitations

1. **Manual validation:** Audit trail is human-readable but not machine-enforced
2. **RTK tuning:** Compression algorithm not context-aware (basic lossy only)
3. **Recursive refs:** Does not detect circular file dependencies
4. **Performance:** No timeout for large file ops

---

## References

- **Heuristic:** `.specs/shared/altitude-file-reading-heuristic.md`
- **Plugin Contract:** `.specs/shared/altitude-filestore-plugin-contract.md`
- **Ralph Loop:** `.specs/shared/execution-loop-contract.md`
- **Ask-User Policy:** `.specs/shared/ask-user-policy.md`
- **AGENTS.md:** Section 21.18 (Wave 24 overview)

---

**Status:** ✅ ACTIVE (Wave 24, BLOCO 1)
**Binding:** All altitude agents must load this contract in Recovery Protocol
