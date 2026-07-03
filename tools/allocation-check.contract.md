# Custom Tool Contract: `allocation-check.sh`

## Overview

**Purpose:** Enforce file-level allocation scope boundaries; validate files against allocation contracts.

**Location:** `~/.config/opencode/tools/allocation-check.sh`

**Status:** Custom tool (part of Wave 5: Global/Task Allocation Enforcement)

**Ownership:** Wave 5 implementation; used by `altitude-execution`, `altitude-validation`, `altitude-report`

---

## Tool Behavior

### Commands

#### `check-file <file> <allocation.yaml>`
**Purpose:** Determine if a file write is allowed by the allocation.

**Input:**
- File path (required): path to check (e.g., `AGENTS.md`, `agents/altitude-execution.agent.md`)
- Allocation file (required): YAML with `allowed_files` and `forbidden_files` arrays

**Output:**
- ✓ ALLOW: File is allowed by allocation, exit 0
- ✗ FORBID: File matches forbidden rules, exit 1
- ✗ DENY: File not in allowed_files (default deny), exit 1

**Example:**
```bash
tools/allocation-check.sh check-file agents/altitude-execution.agent.md allocation.yaml
# Output:
# ✓ ALLOW
#   File: agents/altitude-execution.agent.md
#   Matched: agents/*.agent.md
#   Decision: ALLOWED
```

**Scope Matching:**
- Supports glob patterns: `agents/*.agent.md`, `tools/`, `*.md`
- Supports exact paths: `AGENTS.md`, `README.md`
- Supports directories: `.specs/shared/` (all files under)
- Forbidden overrides allowed (if both match, forbidden wins)

---

#### `check-pattern <file> <pattern>`
**Purpose:** Test if a file matches a single pattern.

**Input:**
- File path (required)
- Pattern (required): glob pattern to test

**Output:**
- ✓ MATCH: File matches pattern, exit 0
- ✗ NO MATCH: File does not match pattern, exit 1

**Example:**
```bash
tools/allocation-check.sh check-pattern agents/altitude-execution.agent.md "agents/*.agent.md"
# Output:
# ✓ MATCH
#   File: agents/altitude-execution.agent.md
#   Pattern: agents/*.agent.md
#   Decision: MATCHES
```

**Patterns Supported:**
- `*` = any characters (except `/`)
- `**` = any characters (including `/`)
- `?` = single character
- `[abc]` = character class
- `/` suffix = directory match

---

#### `expand-allocation <old.yaml> <new_files...>`
**Purpose:** Show what new files would be added to scope if allocation expanded.

**Input:**
- Old allocation file (required): current YAML
- New files (required, multiple): files to add

**Output:**
- Current allowed_files listed
- New files marked as: ✓ already allowed or + NEW (expansion)
- Scope delta count

**Example:**
```bash
tools/allocation-check.sh expand-allocation old-allocation.yaml AGENTS.md README.md
# Output:
# Scope Expansion Delta:
#
# Current allowed_files:
#   - agents/
#   - .specs/shared/
#
# Files to add:
#   + AGENTS.md (NEW - expansion)
#   ✓ README.md (already allowed)
#
# Scope delta: 2 files
```

---

#### `validate-scope <ledger.md> <change_id>`
**Purpose:** Audit allocation events in a change's execution ledger.

**Input:**
- Ledger file (required): `.specs/changes/<change_id>/03-execution-ledger.md`
- Change ID (required): for context/reporting

**Output:**
- Summary: counts of each event type
  - Assigned: tasks allocated
  - Allowed writes: successful writes within scope
  - Scope expansions: approved scope changes
  - Violations blocked: writes rejected
  - Warnings: writes without allocation
- Compliance check: ✓ ALL WITHIN SCOPE or ✗ VIOLATIONS DETECTED
- If violations: list blocked violations

**Example:**
```bash
tools/allocation-check.sh validate-scope 03-execution-ledger.md wave-5
# Output:
# === Allocation Audit: wave-5 ===
#
# Summary:
#   Total events: 42
#   ✓ Assigned: 5
#   ✓ Allowed writes: 38
#   ⚠ Scope expansions: 2 (approved)
#   ✗ Violations blocked: 0
#   ⚠ Warnings (no allocation): 0
#
# ✓ Scope compliance: ALL WRITES WITHIN SCOPE
```

---

## Integration

### Used by

- **`altitude-execution.agent.md`**: Check file before writing
- **`altitude-validation.agent.md`**: Validate all artifact files within scope
- **`altitude-report.agent.md`**: Verify report artifact within scope

### Called from

```bash
# Execution phase (pre-write check)
if ! tools/allocation-check.sh check-file "$file" allocation.yaml; then
    echo "Write outside scope, ask user for approval"
fi

# Validation phase (audit trail)
tools/allocation-check.sh validate-scope 03-execution-ledger.md wave-5

# Query phase (scope expansion delta)
tools/allocation-check.sh expand-allocation old-alloc.yaml new_file.md
```

### Allocation File Format

YAML file with `allowed_files` and `forbidden_files` arrays:

```yaml
allowed_files:
  - agents/*.agent.md
  - .specs/shared/
  - tools/

forbidden_files:
  - agents/DEFAULT.AGENT.agent.md
  - AGENTS.md
```

---

## Error Handling

| Condition | Exit Code | Message | Action |
|-----------|-----------|---------|--------|
| File not provided | 1 | Error: file required | Provide file path |
| Pattern not provided | 1 | Error: pattern required | Provide pattern |
| Allocation file not found | 1 | ✗ Allocation file not found | Check file path |
| Ledger file not found | 1 | ✗ Ledger file not found | Check file path |
| Invalid YAML | 1 | (yq error) | Validate YAML syntax |

---

## Examples

### Pre-Write Validation

```bash
# Agent before writing a file
FILE=agents/altitude-execution.agent.md
ALLOC=.specs/changes/wave-5/.allocation.yaml

if tools/allocation-check.sh check-file "$FILE" "$ALLOC"; then
    # Write allowed
    echo "content" > "$FILE"
else
    # Write blocked, ask user
    echo "Write outside scope, request approval"
fi
```

### Pattern Matching

```bash
# Test if a file matches a pattern
tools/allocation-check.sh check-pattern "agents/custom-agent.agent.md" "agents/*.agent.md"
# Exit 0: matches

tools/allocation-check.sh check-pattern "AGENTS.md" "agents/*.agent.md"
# Exit 1: does not match
```

### Scope Expansion

```bash
# Before approving scope expansion
tools/allocation-check.sh expand-allocation current-alloc.yaml AGENTS.md README.md
# Shows what new files would be added
```

### Post-Execution Audit

```bash
# After execution completes, audit allocation events
tools/allocation-check.sh validate-scope .specs/changes/wave-5/03-execution-ledger.md wave-5
# Shows: total writes, violations, expansions
# Returns: 0 if all compliant, 1 if violations
```

---

## Scope

### Allowed Files
- Allocation YAML files (`.allocation.yaml`)
- Execution ledgers (`03-execution-ledger.md`)
- Any file path (checked for access)

### Forbidden Files
- Source code (read-only for analysis)
- Configuration (cannot modify)
- This contract file itself

### Authority
- Read-only by default
- Never modifies allocation files
- Never modifies ledger (only queries)
- Used by agents to decide on write operations

---

## Testing

Golden fixtures cover:
- **Fixture 1**: Safe write (file in allowed)
- **Fixture 2**: Safe narrowing (task scope ⊂ global)
- **Fixture 3**: Unsafe broadening (rejected)
- **Fixture 4**: Violation + approval
- **Fixture 5**: Violation + abort
- **Fixture 6**: End-to-end audit

See: `test/fixtures/harness-v3/wave-5-allocation-enforcement.fixture.md`

---

## Dependencies

- **External**: `yq`, `bash` (POSIX pattern matching)
- **Internal**: Harness V3 allocation schema (`.specs/shared/allocation-enforcement-contract.md`)
- **Contracts**: `allocation-enforcement-contract.md`, `allocation-ledger-contract.md`

---

## Performance

- **check-file**: O(P + F) where P = allowed patterns, F = forbidden patterns (typically < 50 total)
- **check-pattern**: O(1) (bash glob match)
- **expand-allocation**: O(P·N) where N = new files (typically < 10)
- **validate-scope**: O(E) where E = ledger entries (typically < 100)

All operations complete in < 100ms. No significant performance impact.

---

**Last Updated:** June 29, 2026
**Version:** 1.0.0 (Wave 5)
**Status:** Production Ready
