# Altitude FileStore Plugin Contract — Wave 24

**Version:** 1.0  
**Type:** Plugin specification  
**Date:** 2026-07-03  
**Binding:** All altitude agents + data-engineer  
**Mode:** AGGRESSIVE (hook-based interception)  

---

## Executive Summary

**altitude-filestore.ts** is the central file reading system for all altitude agents. It:
- ✅ Wraps `read()` with RTK compression + Headroom budgeting
- ✅ Logs ALL file operations to TODOWRITE automatically
- ✅ Integrates with existing plugins (rtk-native, headroom-guard)
- ✅ Raises QUESTION() only when decisions are blocking
- ✅ Provides audit trail for validation phase

---

## Architecture

```
┌─────────────────────────────────────────────┐
│  Agent (altitude-maestro, plan, etc.)       │
│  altitude_read('PRD.md')                    │
└─────────────┬───────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│  altitude-filestore.ts Plugin               │
│ ┌──────────────────────────────────────────┐│
│ │ 1. Check allocation (allowed_files)     ││
│ │ 2. Check Headroom budget                ││
│ │ 3. Apply RTK compression if needed      ││
│ │ 4. Log to TODOWRITE                     ││
│ │ 5. Return { content, bytes, compressed }││
│ └──────────────────────────────────────────┘│
└─────────────┬───────────────────────────────┘
              │
      ┌───────┴────────┬──────────────┬──────────────┐
      ▼                ▼              ▼              ▼
┌──────────────┐ ┌──────────┐ ┌─────────────┐ ┌──────────────┐
│ MCP Filestore│ │ RTK-Native│ │ Headroom-   │ │  TODOWRITE   │
│              │ │ Compress  │ │ Guard       │ │  Logger      │
└──────────────┘ └──────────┘ └─────────────┘ └──────────────┘
```

---

## API Contract

### Function: `altitude_read(file: string, options?: ReadOptions)`

**Purpose:** Safe file reading with automatic discipline.

**Parameters:**
```typescript
file: string              // File path (relative or absolute)
options?: {
  force_no_compress?: boolean   // Disable RTK even if budget low
  defer_if_expensive?: boolean  // Skip file if would consume >50% budget
  tracking?: boolean            // Enable TODOWRITE logging (default: true)
  context?: string              // Context for TODOWRITE label (optional)
}
```

**Returns:**
```typescript
{
  content: string         // File content (original or RTK-compressed)
  bytes_used: number      // Actual bytes consumed (post-compression)
  bytes_original: number  // Original file size
  compressed: boolean     // Whether RTK was applied
  compression_ratio: number // Original/compressed ratio (if compressed)
  logged: boolean         // Whether TODOWRITE entry created
  timestamp: ISO8601      // Read timestamp
  error?: string          // Error message if read failed
}
```

**Errors:**
```
- AllocationViolation: File outside allowed_files
- HeadroomExhausted: Budget insufficient, compression failed
- FileNotFound: File does not exist
- ReadPermissionDenied: Cannot read file
```

**Example:**
```typescript
// Simple read
const prd = await altitude_read('PRD.md');
// Returns: { content, bytes_used: 10240, compressed: false, ... }

// With context label
const design = await altitude_read('DESIGN.md', {
  context: 'Load design for task decomposition'
});
// TODOWRITE: "FILE_READ | DESIGN.md | context: Load design... | 25KB"

// Conditional read (defer if expensive)
const archive = await altitude_read('archive.md', {
  defer_if_expensive: true
});
// Returns: { content: null, bytes_used: 0, deferred: true }
```

---

### Function: `altitude_glob(pattern: string, options?: GlobOptions)`

**Purpose:** File pattern matching with ambiguity detection.

**Parameters:**
```typescript
pattern: string         // Glob pattern (e.g., "docs/**/*.md")
options?: {
  limit?: number        // Max files to match (default: 100)
  raise_on_ambiguous?: boolean  // Raise QUESTION if >5 matches (default: true)
}
```

**Returns:**
```typescript
{
  matches: string[]      // Matched file paths
  count: number          // Number of matches
  ambiguous: boolean     // Whether >5 matches (heuristic)
  question_raised?: boolean  // Whether user was asked (if ambiguous)
}
```

**Behavior:**
```
1-5 matches → Return silently, log summary
6+ matches → Raise QUESTION "Pattern too broad, specify domains?"
```

---

### Function: `altitude_grep(pattern: string, file: string)`

**Purpose:** Search within file with lazy logging.

**Parameters:**
```typescript
pattern: string         // Regex pattern
file: string           // File to search in
```

**Returns:**
```typescript
{
  matches: string[]      // Matching lines
  count: number          // Number of matches
  logged: boolean        // Whether logged (true if decision-point)
}
```

**Logging:** Only logged if used for decision (e.g., "file contains section X?")

---

### Function: `altitude_check_headroom()`

**Purpose:** Validate budget status before heavy reads.

**Parameters:** None

**Returns:**
```typescript
{
  budget_total: number       // Global budget (100KB default)
  budget_used: number        // Bytes consumed so far
  budget_remaining: number   // Available budget
  compression_active: boolean // RTK compression mode on/off
  phase: string              // Current phase (cached)
  status: 'OK' | 'WARN' | 'CRITICAL'
}
```

**Status Levels:**
```
OK: > 30% remaining
WARN: 10-30% remaining (apply RTK for new reads)
CRITICAL: < 10% remaining (raise QUESTION for any new read)
```

---

### Function: `altitude_log_file_operation(op: FileOp)`

**Purpose:** Manual logging for edge cases.

**Parameters:**
```typescript
{
  operation: 'FILE_READ' | 'FILE_SKIP' | 'FILE_DEFER' | 'FILE_FAILED'
  file: string
  size_bytes?: number
  compressed?: boolean
  compression_ratio?: number
  reason?: string
  context?: string
}
```

**Example:**
```typescript
altitude_log_file_operation({
  operation: 'FILE_READ',
  file: 'PRD.md',
  size_bytes: 10240,
  compressed: false,
  context: 'design phase context loading'
});
// → TODOWRITE: "FILE_READ | PRD.md (10KB) | altitude-maestro"
```

---

## Integration Requirements

### 1. opencode.json Registration

**Hook registration:**
```json
{
  "plugins": {
    "altitude-filestore": {
      "module": "plugins/altitude-filestore.ts",
      "enabled": true,
      "hooks": {
        "pre-command": "intercept_read_operations",
        "post-read": "apply_rtk_and_log"
      },
      "config": {
        "budget_total_kb": 100,
        "compression_threshold_kb": 15,
        "compression_ratio_target": 0.8,
        "headroom_warn_percent": 20,
        "headroom_critical_percent": 10
      }
    }
  },
  "agents": {
    "altitude-maestro": { ... },
    "altitude-execution": { ... }
    // ... all agents get plugin hooks automatically
  }
}
```

### 2. Plugin Dependencies

**altitude-filestore.ts depends on:**
- `rtk-native.ts` — Compression rewrites
- `headroom-guard.ts` — Budget validation
- `MCP filestore` — Actual file I/O
- TODOWRITE API — Logging

### 3. Initialization

**On plugin load:**
```typescript
export default (async () => {
  return {
    config: async (cfg) => {
      // 1. Load budget config
      const budget = cfg.headroom?.budget_total_kb || 100;
      
      // 2. Register hooks
      cfg.hooks = {
        'altitude-read': altitude_read_wrapped,
        'altitude-glob': altitude_glob_wrapped,
        'altitude-grep': altitude_grep_wrapped,
      };
      
      // 3. Initialize Headroom tracker
      headroom_state = { budget_total: budget, budget_used: 0 };
      
      // 4. Verify dependencies
      if (!rtk_native_available) warn("RTK compression unavailable");
      if (!headroom_guard_available) warn("Headroom guard unavailable");
    }
  }
}) satisfies Plugin
```

---

## Behavior Specification

### Scenario 1: Normal Read (budget OK)

```
User: altitude_read('PRD.md')
│
├─ Plugin: Check allocation → ✓ allowed
├─ Plugin: Check Headroom → budget_remaining = 80KB, file = 10KB → ✓ OK
├─ Plugin: Load file via MCP → content loaded
├─ Plugin: No compression needed
├─ Plugin: Log to TODOWRITE → "FILE_READ | PRD.md (10KB, normal)"
└─ Return: { content, bytes_used: 10240, compressed: false }
```

### Scenario 2: Budget Low (RTK compression)

```
User: altitude_read('DESIGN.md')
│
├─ Plugin: Check allocation → ✓ allowed
├─ Plugin: Check Headroom → budget_remaining = 5KB, file = 30KB → ⚠️ WARN
├─ Plugin: Call RTK compression → 30KB → 5KB (lossy)
├─ Plugin: Load compressed content
├─ Plugin: Log to TODOWRITE → "FILE_READ | DESIGN.md (30KB → 5KB RTK)"
└─ Return: { content: compressed, bytes_used: 5120, compressed: true, ratio: 0.17 }
```

### Scenario 3: Budget Exhausted (QUESTION)

```
User: altitude_read('archive.md')
│
├─ Plugin: Check allocation → ✓ allowed
├─ Plugin: Check Headroom → budget_remaining = 0KB, file = 50KB → ❌ CRITICAL
├─ Plugin: Try RTK compression → fails (not enough space)
├─ Plugin: Raise QUESTION
│  "Headroom exhausted (0KB remaining). Options?"
│  A) Increase budget
│  B) Defer file to next phase
│  C) Truncate file (keep first N lines)
│
├─ User selects: B (defer)
├─ Plugin: Log to TODOWRITE → "FILE_DEFER | archive.md | user choice: defer to next phase"
└─ Return: { content: null, bytes_used: 0, deferred: true, question_raised: true }
```

### Scenario 4: Allocation Violation

```
User: altitude_read('forbidden/secret.md')
│
├─ Plugin: Check allocation → ✗ outside allowed_files
├─ Plugin: Check if required → No (optional)
├─ Plugin: Skip file silently
├─ Plugin: Log to TODOWRITE → "FILE_SKIP | secret.md (outside allowed_files)"
└─ Return: { content: null, bytes_used: 0, skipped: true }

If required: Raise QUESTION → "Override allocation? (security risk)"
```

### Scenario 5: Glob Ambiguity

```
User: altitude_glob('kb/**/*.md')
│
├─ Plugin: Match pattern → 500 files matched
├─ Plugin: Check ambiguity → matches > 5 → ⚠️ AMBIGUOUS
├─ Plugin: Raise QUESTION
│  "Pattern matched 500 KB files. Specify domains?"
│  A) All files (risk: budget exhaustion)
│  B) data-engineering domain only
│  C) spark domain only
│
├─ User selects: B (data-engineering)
├─ Plugin: Filter to kb/data-engineering/**/*.md → 15 matches
├─ Plugin: Log to TODOWRITE → "GLOB_FILTERED | kb pattern (500 → 15 matches by domain)"
└─ Return: { matches: [...], count: 15, filtered_by_user: true }
```

---

## Configuration

### Budget Policy

```yaml
# opencode.json
budget:
  total_kb: 100           # Global budget for entire change
  per_phase:
    intent: 20
    structure: 30
    plan: 40
    execution: 30
    validation: 40
    report: 30
    memory: 20

compression:
  enabled: true
  threshold_kb: 15        # Apply RTK if budget < 15KB
  target_ratio: 0.80      # Aim for 80% reduction
  algorithm: 'lossy'      # lossy | lossless

headroom:
  warn_percent: 20        # Warn when 20% remaining
  critical_percent: 10    # Ask when 10% remaining
  block_percent: 5        # Block new reads when 5% remaining
```

---

## Testing Requirements

### Test 1: Normal read

```bash
✓ altitude_read('PRD.md') → content loaded, logged, budget OK
```

### Test 2: Budget constraint → RTK compression

```bash
✓ Set budget = 5KB
✓ altitude_read('DESIGN.md' 30KB) → compressed to ~5KB
✓ TODOWRITE entry shows compression_ratio
```

### Test 3: Budget exhausted → QUESTION

```bash
✓ Set budget = 0KB
✓ altitude_read('FILE.md') → raises QUESTION
✓ User chooses defer
✓ File not loaded, TODOWRITE logged
```

### Test 4: Allocation violation

```bash
✓ Set allowed_files = ['docs/', 'agents/']
✓ altitude_read('forbidden/secret.md') → skipped
✓ TODOWRITE logs FILE_SKIP
```

### Test 5: Glob ambiguity → QUESTION

```bash
✓ altitude_glob('**/*.md' match 500) → raises QUESTION
✓ User specifies domain
✓ Filtered to N matches
✓ TODOWRITE logs filter decision
```

---

## Error Handling

### AllocationViolation

```typescript
throw new AllocationViolation(
  `File ${file} outside allowed_files`,
  { file, allowed_files, phase }
);
// → Escalate to altitude-validation
```

### HeadroomExhausted

```typescript
if (compression_failed) {
  const response = await question({
    header: "Budget exhausted",
    question: "...",
    options: [...]
  });
  // → Log response, proceed based on choice
}
```

### FileNotFound

```typescript
throw new FileNotFound(
  `${file} does not exist`,
  { file, phase, suggestions: [...] }
);
// → Log to TODOWRITE, escalate if required
```

---

## Known Limitations

1. **Circular deps:** Does not detect if file A references file B references A
2. **Performance:** No async timeout for slow reads
3. **Context awareness:** RTK compression not aware of task context (generic lossy)
4. **User experience:** QUESTION interface plain text (could improve in W25)

---

## References

- **Heuristic:** `.specs/shared/altitude-file-reading-heuristic.md`
- **Workflow:** `.specs/shared/altitude-file-reading-workflow-contract.md`
- **RTK:** `plugins/rtk-native.ts`
- **Headroom:** `plugins/headroom-guard.ts`
- **AGENTS.md:** Section 21.18

---

**Status:** ✅ SPEC COMPLETE (Wave 24, BLOCO 1)
