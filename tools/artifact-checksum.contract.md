# Custom Tool Contract: `artifact-checksum.sh`

## Overview

**Purpose:** Compute, verify, compare, and validate artifact checksums across the Harness V3 lifecycle.

**Location:** `~/.config/opencode/tools/artifact-checksum.sh`

**Status:** Custom tool (part of Wave 4: Artifact Versioning & Generation Registry)

**Ownership:** Wave 4 implementation; used by `altitude-execution`, `altitude-validation`, `altitude-report`

---

## Tool Behavior

### Commands

#### `compute <artifact>`
**Purpose:** Compute SHA256 checksum of a single artifact.

**Input:**
- File path (required): artifact to hash
- Supports `.md` and `.json` formats

**Output:**
- Format: `sha256:<64-char-hex-hash>`
- Exit code: 0 if successful, 1 if file not found

**Example:**
```bash
tools/artifact-checksum.sh compute .specs/changes/wave-4/prd.md
# Output: sha256:abc123def456...
```

---

#### `verify <artifact>`
**Purpose:** Verify artifact checksum against header-embedded checksum.

**Input:**
- File path (required): artifact with embedded `checksum` field

**Logic:**
1. Extract `checksum` from YAML frontmatter (Markdown) or JSON header
2. Compute current SHA256
3. Compare: `header_checksum == current_checksum`

**Output:**
- ✓ Checksum valid: exit 0
- ⚠ No checksum in header: exit 1
- ✗ Checksum mismatch: exit 1 (artifact was modified outside registry)

**Example:**
```bash
tools/artifact-checksum.sh verify .specs/changes/wave-4/prd.md
# Output:
# ✓ Checksum valid
#   Checksum: sha256:abc123...
```

---

#### `compare <artifact1> <artifact2>`
**Purpose:** Compare checksums of two artifacts; detect if identical.

**Input:**
- File paths (required, 2): artifacts to compare

**Output:**
- ✓ Checksums match: both identical, exit 0
- ✗ Checksums differ: artifacts different, exit 1

**Example:**
```bash
tools/artifact-checksum.sh compare prd-v1.md prd-v2.md
# Output:
# Comparing checksums:
#   File 1: prd-v1.md
#   Hash 1: sha256:abc123...
#   File 2: prd-v2.md
#   Hash 2: sha256:def456...
# ✗ Checksums differ (artifacts are different)
```

---

#### `list-all <change_id>`
**Purpose:** List all artifact checksums in a change's registry.

**Input:**
- Change ID (required): resolves to `.specs/changes/<change_id>/artifact-generation-registry.yaml`

**Output:**
- Table: artifact slug, generation count, latest checksum
- Uses yq for YAML parsing

**Example:**
```bash
tools/artifact-checksum.sh list-all wave-4-artifact-versioning
# Output:
# Artifact checksums in change: wave-4-artifact-versioning
# artifact: prd
# generations: 2
# latest_checksum: sha256:abc123...
# ---
# artifact: adr
# generations: 1
# latest_checksum: sha256:def456...
```

---

#### `detect-changes <registry> <artifact_slug>`
**Purpose:** Show generation history for an artifact; detect if it was regenerated.

**Input:**
- Registry path (required): YAML file
- Artifact slug (required): e.g., `prd`, `adr`, `validation_report`

**Output:**
- Timeline: generation → checksum → prior_checksum → timestamp
- Annotations: ↓ CHANGED between successive generations
- Summary: count of generations

**Example:**
```bash
tools/artifact-checksum.sh detect-changes artifact-generation-registry.yaml prd
# Output:
# Change history for prd:
# generation: 1
# checksum: sha256:abc123...
# prior: null
# timestamp: 2026-06-29T01:00:00Z
#   ↓ CHANGED
# generation: 2
# checksum: sha256:def456...
# prior: sha256:abc123...
# timestamp: 2026-06-29T02:30:00Z
#
# Summary: prd was regenerated 2 times
```

---

#### `validate-chain <registry> <artifact_slug>`
**Purpose:** Validate integrity of `prior_generation_checksum` chain for an artifact.

**Input:**
- Registry path (required): YAML file
- Artifact slug (required): e.g., `prd`

**Logic:**
- For each generation N > 1:
  - Extract `prior_generation_checksum`
  - Verify it matches generation N-1's checksum
  - Report ✓ if valid, ✗ if broken

**Output:**
- Line per generation: status + prior link validity
- Final: ✓ Chain validation: PASSED or ✗ Chain validation: FAILED
- Exit code: 0 if all valid, 1 if any broken

**Example:**
```bash
tools/artifact-checksum.sh validate-chain artifact-generation-registry.yaml prd
# Output:
# Validating checksum chain for prd...
# ✓ Gen 1: first generation (no prior link)
# ✓ Gen 2: prior link valid
# ✓ Gen 3: prior link valid
#
# ✓ Chain validation: PASSED
```

---

## Integration

### Used by

- **`altitude-execution.agent.md`**: Compute SHA256 + update registry on artifact writes
- **`altitude-validation.agent.md`**: Verify checksums before junta analysis
- **`altitude-report.agent.md`**: Query registry for artifact evolution

### Called from

```bash
# Execution phase (after writing artifact)
tools/artifact-checksum.sh compute .specs/changes/<change_id>/<file>

# Validation phase (verify before analysis)
tools/artifact-checksum.sh verify .specs/changes/<change_id>/prd.md

# Report phase (query integrity)
tools/artifact-checksum.sh validate-chain artifact-generation-registry.yaml prd
```

### Registry Dependency

All commands (except `compute`, `verify`, `compare`) require:
```
.specs/changes/<change_id>/artifact-generation-registry.yaml
```

Created by `altitude-execution` on first artifact write; updated on every write.

---

## Error Handling

| Condition | Exit Code | Message | Action |
|-----------|-----------|---------|--------|
| File not found | 1 | ✗ File not found: | Check path |
| No checksum in header | 1 | ⚠ No checksum found in header | Add checksum to artifact |
| Checksum mismatch | 1 | ✗ Checksum mismatch! | Investigate modification |
| Registry not found | 1 | ✗ Registry not found: | Create registry or check change_id |
| Invalid artifact_slug | 1 | (no entry in registry) | Verify artifact was tracked |
| Broken chain link | 1 | ✗ Gen N: prior link broken! | Investigate registry corruption |

---

## Validation Rules

### Checksum Format
- Must be: `sha256:<64-character-hex-string>`
- Invalid formats rejected

### Prior Checksum Chain
- Gen 1: `prior_generation_checksum = null`
- Gen N>1: `prior_generation_checksum = Gen(N-1).checksum`
- Must form unbroken chain or chain validation fails

### File Immutability
- Once checksummed and stored in registry, artifacts are immutable
- Any modification breaks verification
- Tools detect and report immutability violations

---

## Examples

### Compute + Store
```bash
# Phase: Execution
HASH=$(tools/artifact-checksum.sh compute .specs/changes/wave-4/prd.md)
# Register in registry: $HASH
```

### Verify Before Junta
```bash
# Phase: Validation
if tools/artifact-checksum.sh verify .specs/changes/wave-4/prd.md; then
    echo "Artifact clean, safe to analyze"
else
    echo "Artifact modified, abort junta"
    exit 1
fi
```

### Detect Changes Across Validation Runs
```bash
# Phase: Report
tools/artifact-checksum.sh detect-changes .specs/changes/wave-4/artifact-generation-registry.yaml prd
# Shows all regenerations of PRD artifact
```

### Full Integrity Check
```bash
# Phase: Ship (pre-archive)
tools/artifact-checksum.sh validate-chain .specs/changes/wave-4/artifact-generation-registry.yaml prd
if [ $? -ne 0 ]; then
    echo "Registry corrupted, do not ship"
    exit 1
fi
```

---

## Scope

### Allowed Files
- `.specs/changes/*/` (all artifacts in changes)
- `.specs/changes/*/artifact-generation-registry.yaml`
- Any `.md` or `.json` file

### Forbidden Files
- Source code (tools/, agents/, skills/)
- Configuration (opencode.json, .specs/shared/)
- This contract file itself

### Authority
- Read-only by default
- Modifies registry only via `altitude-execution`
- Never modifies artifact content

---

## Testing

Golden fixtures cover:
- **Fixture 1**: Compute hash for new PRD
- **Fixture 2**: Detect changes (Gen 1 → Gen 2)
- **Fixture 3**: Verify checksum match
- **Fixture 4**: Validate chain integrity
- **Fixture 5**: End-to-end (compute → register → verify → timeline)

See: `test/fixtures/harness-v3/wave-4-artifact-versioning.fixture.md`

---

## Dependencies

- **External**: `sha256sum`, `yq`, `jq`
- **Internal**: Harness V3 registry schema (`.specs/shared/artifact-registry-maintenance.md`)
- **Contracts**: `artifact-checksum-contract.md`, `artifact-timeline-queries.md`

---

**Last Updated:** June 29, 2026
**Version:** 1.0.0 (Wave 4)
**Status:** Production Ready
