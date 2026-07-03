# Custom Tool Contract: `artifact-timeline.sh`

## Overview

**Purpose:** Query artifact generation history, validation runs, and timeline progression across the Harness V3 lifecycle.

**Location:** `~/.config/opencode/tools/artifact-timeline.sh`

**Status:** Custom tool (part of Wave 4: Artifact Versioning & Generation Registry)

**Ownership:** Wave 4 implementation; used by `altitude-validation`, `altitude-report`

---

## Tool Behavior

### Commands

#### `timeline <change_id> <artifact_slug>`
**Purpose:** Show all versions of a specific artifact across its generation history.

**Input:**
- Change ID (required): resolves to `.specs/changes/<change_id>/artifact-generation-registry.yaml`
- Artifact slug (required): `prd`, `adr`, `test_spec`, `validation_report`, etc.

**Output:**
- Numbered timeline: Gen N → timestamp → status → shortened checksum
- Color-coded: BLUE header

**Example:**
```bash
tools/artifact-timeline.sh timeline wave-4-artifact-versioning prd
# Output:
# Timeline for prd:
# 1. Gen 1: 2026-06-29T01:00:00Z [generated] abc123de...
# 2. Gen 2: 2026-06-29T02:30:00Z [generated] def456ab...
# 3. Gen 3: 2026-06-29T04:15:00Z [generated] ghi789cd...
```

---

#### `validation-runs <change_id>`
**Purpose:** Show all validation runs recorded in the registry with junta scores and status.

**Input:**
- Change ID (required): resolves to registry

**Output:**
- Numbered list per run:
  - ID: junta_run_id
  - Score: junta score (0-100)
  - Status: `passed`, `failed`, `review`
  - Timestamp: when validation occurred

**Example:**
```bash
tools/artifact-timeline.sh validation-runs wave-4-artifact-versioning
# Output:
# Validation runs in wave-4-artifact-versioning:
# Run 1:
#   ID:        validation-run-20260629-001
#   Score:     87/100
#   Status:    passed
#   Timestamp: 2026-06-29T01:45:00Z
# Run 2:
#   ID:        validation-run-20260629-002
#   Score:     95/100
#   Status:    passed
#   Timestamp: 2026-06-29T03:00:00Z
```

---

#### `changed <change_id> <run_1> <run_2>`
**Purpose:** Compare artifacts analyzed in two validation runs; show what changed.

**Input:**
- Change ID (required)
- Run 1 ID (required): junta_run_id (e.g., `validation-run-20260629-001`)
- Run 2 ID (required): junta_run_id (e.g., `validation-run-20260629-002`)

**Logic:**
1. Get artifacts_analyzed in Run 1
2. For each artifact, compare checksum in Run 1 vs Run 2
3. Mark ✓ unchanged or ✗ changed (with hash diff)

**Output:**
- Per artifact: status + checksum comparison
- Summary: count of changed artifacts

**Example:**
```bash
tools/artifact-timeline.sh changed wave-4 run-001 run-002
# Output:
# Artifacts changed between validation runs:
#   From: run-001
#   To:   run-002
#
#   ✓ prd: unchanged
#   ✗ adr: changed
#     abc123de... → def456ab...
#   ✓ test_spec: unchanged
#   ✓ validation_report: unchanged
#
# Summary: Some artifacts changed between runs
```

---

#### `freshness <change_id>`
**Purpose:** Show which artifacts are fresh (updated < 24hrs) vs stale (updated > 24hrs).

**Input:**
- Change ID (required)

**Output:**
- Per artifact: freshness status + last update timestamp
- Color-coded: ✓ GREEN (fresh), ⚠ YELLOW (stale)

**Example:**
```bash
tools/artifact-timeline.sh freshness wave-4-artifact-versioning
# Output:
# Artifact freshness in wave-4-artifact-versioning:
#   ✓ prd: fresh (last: 2026-06-29T04:15:00Z)
#   ✓ adr: fresh (last: 2026-06-29T03:30:00Z)
#   ⚠ test_spec: stale (last: 2026-06-28T20:00:00Z)
#   ✓ validation_report: fresh (last: 2026-06-29T04:30:00Z)
```

---

#### `artifacts-at <change_id> <run_id>`
**Purpose:** Show all artifacts that were analyzed in a specific validation run.

**Input:**
- Change ID (required)
- Run ID (required): junta_run_id

**Output:**
- Numbered list: artifact_slug + shortened checksum
- Shows exact snapshot of what junta analyzed

**Example:**
```bash
tools/artifact-timeline.sh artifacts-at wave-4 validation-run-20260629-001
# Output:
# Artifacts analyzed in validation run: validation-run-20260629-001
#   1. prd: abc123de...
#   2. adr: def456ab...
#   3. test_spec: ghi789cd...
#   4. validation_report: jkl012ef...
```

---

#### `integrity <change_id>`
**Purpose:** Validate entire registry; check all `prior_generation_checksum` chains.

**Input:**
- Change ID (required)

**Logic:**
- Iterate all artifacts and all generations
- For Gen N > 1: verify `prior_generation_checksum` == Gen(N-1).checksum
- Report ✓ or ✗ per chain

**Output:**
- Per artifact, per generation: chain validity
- Final: ✓ Integrity check: PASSED or ✗ Integrity check: FAILED
- Exit code: 0 if all valid, 1 if any broken

**Example:**
```bash
tools/artifact-timeline.sh integrity wave-4-artifact-versioning
# Output:
# Registry integrity check for wave-4-artifact-versioning:
# ✓ prd gen 1: chain valid
# ✓ prd gen 2: chain valid
# ✓ adr gen 1: chain valid
# ✓ test_spec gen 1: chain valid
# ✓ validation_report gen 1: chain valid
#
# ✓ Integrity check: PASSED
```

---

#### `report <change_id>`
**Purpose:** Full registry summary; all artifacts, generation counts, recent validation runs.

**Input:**
- Change ID (required)

**Output:**
- Metadata: total artifacts, created_at, last_updated_at
- Artifacts: list with type + generation count
- Recent validations: last 3 runs + scores + status

**Example:**
```bash
tools/artifact-timeline.sh report wave-4-artifact-versioning
# Output:
# === Full Registry Report: wave-4-artifact-versioning ===
#
# Metadata:
#   Total artifacts: 4
#   Created:        2026-06-29T01:00:00Z
#   Last updated:   2026-06-29T04:30:00Z
#
# Artifacts:
#   1. prd (prd): 3 generations
#   2. adr (adr): 1 generations
#   3. test_spec (test_spec): 1 generations
#   4. validation_report (validation_report): 2 generations
#
# Recent validations:
#   1. validation-run-20260629-001: 87/100 [passed]
#   2. validation-run-20260629-002: 95/100 [passed]
```

---

## Integration

### Used by

- **`altitude-validation.agent.md`**: Query validation runs + artifacts analyzed
- **`altitude-report.agent.md`**: Generate timeline views + score progression

### Called from

```bash
# Validation phase (record run + analyzed artifacts)
tools/artifact-timeline.sh validation-runs <change_id>
tools/artifact-timeline.sh artifacts-at <change_id> <run_id>

# Report phase (show progression)
tools/artifact-timeline.sh changed <change_id> <run_1> <run_2>
tools/artifact-timeline.sh timeline <change_id> <artifact_slug>

# Ship phase (pre-archive validation)
tools/artifact-timeline.sh integrity <change_id>
tools/artifact-timeline.sh report <change_id>
```

### Registry Dependency

All commands require:
```
.specs/changes/<change_id>/artifact-generation-registry.yaml
```

Maintained by `altitude-execution` (writes) and `altitude-validation` (records runs).

---

## Error Handling

| Condition | Exit Code | Message | Action |
|-----------|-----------|---------|--------|
| Change ID not provided | 1 | Error: change_id required | Provide valid change_id |
| Registry not found | 1 | ✗ Registry not found: | Create registry or check change_id |
| Invalid run_id | 1 | ✗ Validation run not found: | Verify run was recorded |
| Invalid artifact_slug | 0 | (empty timeline) | Artifact not tracked |
| Broken chain link | 1 | ✗ Integrity check: FAILED | Investigate registry corruption |

---

## Query Examples

### Show Progression of PRD Across Generations
```bash
tools/artifact-timeline.sh timeline wave-4 prd
# Understand how PRD evolved through phases
```

### Compare Validation Runs for Change Detection
```bash
tools/artifact-timeline.sh changed wave-4 run-001 run-002
# Detect what artifacts were regenerated between validations
```

### Full Audit Trail
```bash
tools/artifact-timeline.sh report wave-4
tools/artifact-timeline.sh integrity wave-4
# Comprehensive health check before shipping
```

### Freshness Check (Before Ship)
```bash
tools/artifact-timeline.sh freshness wave-4
# Ensure all artifacts current before archival
```

### Snapshot of Specific Validation Run
```bash
tools/artifact-timeline.sh artifacts-at wave-4 run-001
# See exactly what the junta analyzed in this run
```

---

## Scope

### Allowed Files
- `.specs/changes/*/artifact-generation-registry.yaml` (read)
- All queries read-only from registry

### Forbidden Files
- Source code (tools/, agents/, skills/)
- Configuration (opencode.json, .specs/shared/)
- Artifact content files (never modifies artifacts)

### Authority
- Query-only; no writes
- Cannot modify registry directly (only `altitude-execution` writes)
- Cannot modify artifacts

---

## Output Format

### Colors
- **BLUE** (`\033[0;34m`): Section headers
- **GREEN** (`\033[0;32m`): ✓ status, unchanged items
- **YELLOW** (`\033[1;33m`): ⚠ warnings, stale items
- **RED** (`\033[0;31m`): ✗ errors, failures

### Sorting
- Timelines: chronological (oldest first)
- Validation runs: by timestamp
- Artifacts: alphabetical

### Abbreviations
- Checksums: shortened to 12 chars + `...`
- Full checksums: available from registry via yq directly

---

## Testing

Golden fixtures cover:
- **Fixture 2**: timeline (Gen 1 → Gen 2)
- **Fixture 3**: artifacts-at (snapshot in validation run)
- **Fixture 4**: changed (change detection between runs)
- **Fixture 5**: integrity (pre-ship validation)
- **Fixture 5**: report (full registry summary)

See: `test/fixtures/harness-v3/wave-4-artifact-versioning.fixture.md`

---

## Dependencies

- **External**: `yq`, `jq`, `date` (for freshness calculation)
- **Internal**: Harness V3 registry schema (`.specs/shared/artifact-registry-maintenance.md`)
- **Contracts**: `artifact-timeline-queries.md`, `artifact-checksum-contract.md`

---

## Performance

- **timeline**: O(G) where G = generations of artifact
- **validation-runs**: O(R) where R = validation runs
- **changed**: O(A·L) where A = artifacts, L = lookups (linear, could be optimized with indices)
- **integrity**: O(A·G) where A = artifacts, G = generations (pre-ship only, acceptable)
- **report**: O(A + R) summary query

For large registries (>1000 artifacts, >100 runs), consider:
- Running integrity only before ship (not every run)
- Using yq filters directly for custom queries

---

**Last Updated:** June 29, 2026
**Version:** 1.0.0 (Wave 4)
**Status:** Production Ready
