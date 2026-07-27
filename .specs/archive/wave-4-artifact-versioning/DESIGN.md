# Wave 4 — Artifact Versioning & Generation Registry

**Status:** DESIGN  
**Scope:** Generation tracking, immutable checksums, timeline queries  
**Effort:** ~2,000 lines, 8 files  
**Timeline:** 1 week  
**Blockers:** None (Wave 3B must be merged first)  

---

## Problem Statement

Harness V3 creates many artifacts (PRD, ADR, test-spec, validation reports, execution ledger, ship summary, etc.), but has **no way to track their generation history**.

This means:
- Cannot answer "How many times was the PRD regenerated?"
- Cannot ask "What changed between validation run #1 and #2?"
- Cannot trace "Timeline of changes to architecture decisions"
- Cannot detect "Which artifacts were created during which phase?"
- Cannot implement "Rollback to a prior artifact state"
- Validation junta scores are not linked to which artifacts were analyzed

**Additionally:** The artifact-taxonomy-and-tracking-contract.md exists (Wave 0), but:
- No generation registry is created/maintained
- No agents populate the registry
- Checksum validation is not implemented
- Timeline query tools don't exist

---

## Solution

**Wave 4 = Artifact Versioning & Generation Registry**

### Component 1: Generation Registry Creation & Maintenance
**What:** Create artifact-generation-registry.yaml per change; populate on every artifact generation  
**How:** altitude-execution and altitude-validation maintain registry  
**Files:**
- `.specs/shared/artifact-registry-maintenance.md` (contract for registry updates)
- `agents/altitude-execution.agent.md` (UPDATE — create/maintain registry)
- `agents/altitude-validation.agent.md` (UPDATE — record validation runs)

### Component 2: Checksum & Immutability Tracking
**What:** Hash every artifact version; detect changes; track rollback history  
**How:** Generate SHA256 on write; record prior_generation_checksum  
**Files:**
- `.specs/shared/artifact-checksum-contract.md` (hashing rules + detection)
- New utility script: `tools/artifact-checksum.sh` (compute/verify hashes)

### Component 3: Timeline Query Capability
**What:** Enable queries like "show all artifacts changed between X and Y" or "timeline of PRD versions"  
**How:** artifact-generation-registry.yaml is queryable via yq/jq  
**Files:**
- `.specs/shared/artifact-timeline-queries.md` (query patterns + examples)
- `tools/artifact-timeline.sh` (convenient query wrapper)

### Component 4: Validation Run Linking
**What:** Link each junta validation run to the artifacts it analyzed  
**How:** Store junta_run_id + artifact checksums in validation entry  
**Files:**
- Update `.specs/shared/validation-evidence-pack-contract.md`
- `agents/altitude-validation.agent.md` (UPDATE — record which artifacts were scored)

---

## Acceptance Criteria

### Generation Registry
- [ ] artifact-generation-registry.yaml is created on first artifact write per change
- [ ] Registry tracks all artifact types (prd, adr, task-spec, validation_report, etc.)
- [ ] Registry is updated on every artifact write (increment generation_number)
- [ ] Registry includes prior_generation_checksum for change detection
- [ ] Fixture: create PRD, modify it, verify generation_count = 2

### Checksums & Immutability
- [ ] SHA256 computed on every artifact save
- [ ] Checksum stored in registry entry
- [ ] Artifact header includes its own checksum (self-referential)
- [ ] Detect accidental modification (checksum mismatch)
- [ ] Fixture: modify artifact, verify checksum changes

### Timeline Queries
- [ ] Query: "show all generations of artifact_slug=prd"
- [ ] Query: "timeline of scores for validation_report"
- [ ] Query: "all artifacts changed between dates X and Y"
- [ ] Query: "which artifacts analyzed in junta_run_id=validation-run-001"
- [ ] Fixture: multi-run scenario with timeline queries

### Validation Run Linking
- [ ] Validation report records which artifacts were analyzed
- [ ] Validation report stores checksums of artifacts at time of analysis
- [ ] Registry links validation_run_id → artifact versions → scores
- [ ] Fixture: validation run, modify PRD, re-run validation, compare

### Integration
- [ ] altitude-plan creates initial registry on decomposition
- [ ] altitude-execution updates registry on every output write
- [ ] altitude-validation updates registry with junta scores + artifact checksums
- [ ] altitude-report reads registry for timeline queries
- [ ] End-to-end: intent → structure → plan → execute → validate → query history

---

## Architecture

```
User Request
  ↓
Altitude Phase Agent
  ├─ [NEW] Check if artifact-generation-registry.yaml exists
  │   └─ If not, create with metadata
  │
  ├─ Execute work (generate/modify artifacts)
  │   ├─ For each output file:
  │   │   ├─ [NEW] Compute SHA256 checksum
  │   │   ├─ [NEW] Add artifact header (YAML frontmatter)
  │   │   ├─ [NEW] Update registry entry
  │   │   │   ├─ Increment generation_number
  │   │   │   ├─ Record prior_generation_checksum
  │   │   │   ├─ Store file_path + checksum + timestamp
  │   │   │   └─ Store agent name (generated_by)
  │   │   └─ Write file
  │   │
  │   └─ [NEW] Update registry last_updated_at
  │
  └─ Artifact is versioned + immutable (by design)

Altitude Validation
  ├─ [NEW] Record validation run ID
  ├─ Run junta (requirements, architecture, tests, tasks, council)
  ├─ [NEW] For validation artifacts created:
  │   └─ Update registry with junta_run_id + score + artifact checksums
  └─ Validation report links to artifacts it analyzed

Timeline Query (e.g., altitude-report)
  └─ Read artifact-generation-registry.yaml
      ├─ Query: all generations of X artifact
      ├─ Query: timeline of validation scores
      ├─ Query: artifacts changed between dates
      └─ Display version history + checksums
```

---

## File Changes Summary

| File | Change | Lines | Purpose |
|------|--------|-------|---------|
| `.specs/shared/artifact-registry-maintenance.md` | CREATE | 250 | Registry creation/update rules |
| `.specs/shared/artifact-checksum-contract.md` | CREATE | 200 | SHA256 hashing + verification |
| `.specs/shared/artifact-timeline-queries.md` | CREATE | 300 | Query patterns + examples |
| `agents/altitude-execution.agent.md` | UPDATE | +150 | Create registry, update on writes |
| `agents/altitude-validation.agent.md` | UPDATE | +150 | Record junta runs + link artifacts |
| `agents/altitude-report.agent.md` | UPDATE | +100 | Query registry for timeline views |
| `tools/artifact-checksum.sh` | CREATE | 100 | Compute/verify SHA256 hashes |
| `tools/artifact-timeline.sh` | CREATE | 150 | Convenient query wrapper |
| `test/fixtures/harness-v3/artifact-versioning.fixture.md` | CREATE | 500 | 5 scenarios: create/modify/query |
| `.specs/changes/wave-4-artifact-versioning/artifact-generation-registry.yaml` | CREATE | 100 | Example registry for this wave |
| **TOTAL** | | ~2,000 | ~8 files, 1-week effort |

---

## Validation Evidence Pack Updates

The validation evidence pack (from Wave 3) will include registry snapshots:

```
.specs/changes/<change-id>/_validate/
├── manifest.md                       # (existing)
├── 01_REQUIREMENTS_REPORT.json       # (existing)
├── 02_ARCHITECTURE_REPORT.json       # (existing)
├── 03_TESTS_REPORT.json              # (existing)
├── 04_TASKS_REPORT.json              # (existing)
├── 05_SCORING.json                   # (existing)
├── 06_COUNCIL_VERDICT.json           # (existing)
├── [NEW] artifact-generation-registry-snapshot.yaml  # Registry at validation time
├── [NEW] artifact-checksums.json     # Checksums of all artifacts analyzed
└── validation-report.md              # (existing)
```

This enables: "What artifacts did this validation run analyze and what were their checksums?"

---

## Artifact Header Format

Every artifact will include YAML frontmatter (machine-readable metadata):

### Markdown Artifacts (PRD, ADR, test-spec, etc.)

```markdown
---
artifact_type: prd
artifact_slug: prd
change_id: wave-4-artifact-versioning
phase: Design
generated_at: 2026-06-29T15:30:00Z
generated_by: altitude-plan
generation_number: 1
total_generations: 1
checksum: sha256:abc123def456ghi789
size_lines: 125
---

# Product Requirements Document

...content...
```

### JSON Artifacts (validation reports, junta output)

```json
{
  "artifact_type": "validation_report",
  "artifact_slug": "validation-report",
  "change_id": "wave-4-artifact-versioning",
  "phase": "Validation",
  "generated_at": "2026-06-29T16:00:00Z",
  "generated_by": "altitude-validation",
  "generation_number": 1,
  "junta_run_id": "validation-run-20260629-001",
  "score": 88,
  "status": "READY",
  "checksum": "sha256:xyz789abc123def456",
  "data": {
    "score_breakdown": {...}
  }
}
```

---

## Generation Registry Schema

**File:** `.specs/changes/<change-id>/artifact-generation-registry.yaml`

```yaml
change_id: wave-4-artifact-versioning
created_at: 2026-06-29T14:00:00Z
last_updated_at: 2026-06-29T16:00:00Z
total_artifacts_tracked: 8

artifact_generations:
  prd:
    artifact_type: prd
    artifact_slug: prd
    max_instances: 1
    generation_count: 2
    generations:
      - generation_number: 1
        generated_at: 2026-06-29T14:00:00Z
        generated_by: altitude-plan
        file_path: .specs/changes/wave-4-artifact-versioning/prd.md
        checksum: sha256:abc123
        size_lines: 100
        status: draft
        
      - generation_number: 2
        generated_at: 2026-06-29T15:30:00Z
        generated_by: altitude-execution
        file_path: .specs/changes/wave-4-artifact-versioning/prd.md
        checksum: sha256:def456
        size_lines: 125
        status: ready
        prior_generation_checksum: sha256:abc123
        
  validation_report:
    artifact_type: validation_report
    artifact_slug: validation-report
    max_instances: unbounded
    generation_count: 2
    generations:
      - generation_number: 1
        junta_run_id: validation-run-20260629-001
        generated_at: 2026-06-29T15:45:00Z
        generated_by: altitude-validation
        file_path: .specs/changes/wave-4-artifact-versioning/_validate/validation-report-001.md
        score: 78
        status: FAILED
        artifacts_analyzed:
          - artifact_slug: prd
            checksum: sha256:abc123
          - artifact_slug: adr
            checksum: sha256:ghi789
            
      - generation_number: 2
        junta_run_id: validation-run-20260629-002
        generated_at: 2026-06-29T16:00:00Z
        generated_by: altitude-validation
        file_path: .specs/changes/wave-4-artifact-versioning/_validate/validation-report-002.md
        score: 92
        status: PASSED
        artifacts_analyzed:
          - artifact_slug: prd
            checksum: sha256:def456
          - artifact_slug: adr
            checksum: sha256:jkl012
```

---

## Timeline Query Examples

All queries read `.specs/changes/<change-id>/artifact-generation-registry.yaml`:

### Query 1: Show all PRD versions

```bash
yq '.artifact_generations.prd.generations[] | {generation_number, generated_at, checksum, status}' \
  .specs/changes/wave-4-artifact-versioning/artifact-generation-registry.yaml
```

**Output:**
```
generation_number: 1
generated_at: 2026-06-29T14:00:00Z
checksum: sha256:abc123
status: draft
---
generation_number: 2
generated_at: 2026-06-29T15:30:00Z
checksum: sha256:def456
status: ready
```

### Query 2: Timeline of validation scores

```bash
yq '.artifact_generations.validation_report.generations[] | {generation_number, junta_run_id, score, status, generated_at}' \
  .specs/changes/wave-4-artifact-versioning/artifact-generation-registry.yaml
```

### Query 3: Which artifacts were analyzed in validation run #2?

```bash
yq '.artifact_generations.validation_report.generations[1].artifacts_analyzed[]' \
  .specs/changes/wave-4-artifact-versioning/artifact-generation-registry.yaml
```

### Query 4: Did PRD change between validation run #1 and #2?

```bash
# Extract checksum from run #1
checksum_1=$(yq '.artifact_generations.validation_report.generations[0].artifacts_analyzed[] | select(.artifact_slug == "prd") | .checksum' \
  .specs/changes/wave-4-artifact-versioning/artifact-generation-registry.yaml)

# Extract checksum from run #2
checksum_2=$(yq '.artifact_generations.validation_report.generations[1].artifacts_analyzed[] | select(.artifact_slug == "prd") | .checksum' \
  .specs/changes/wave-4-artifact-versioning/artifact-generation-registry.yaml)

if [ "$checksum_1" == "$checksum_2" ]; then
  echo "PRD unchanged between runs"
else
  echo "PRD changed: $checksum_1 → $checksum_2"
fi
```

---

## Golden Fixtures (5 Scenarios)

### Fixture 1: Create PRD, verify generation #1 in registry

**Input:** altitude-plan generates PRD
**Expected:** 
- artifact-generation-registry.yaml created
- prd.artifact_generations[0].generation_number = 1
- prd checksum recorded

### Fixture 2: Modify PRD, verify generation #2

**Input:** altitude-execution modifies PRD
**Expected:**
- prd.generation_count incremented to 2
- prd.generations[1].prior_generation_checksum = prior checksum
- New checksum recorded

### Fixture 3: Run validation, record junta link

**Input:** altitude-validation runs, creates validation_report
**Expected:**
- validation_report.generation_number = 1
- validation_report.junta_run_id recorded
- validation_report.artifacts_analyzed includes prd checksum

### Fixture 4: Timeline query — "did PRD change?"

**Input:** Query registry for PRD checksums between validation runs
**Expected:** Script correctly compares checksums, identifies change

### Fixture 5: End-to-end — intent → execute → validate → query

**Input:** Full wave lifecycle
**Expected:**
- Registry created at plan
- Registry updated at each phase
- Query shows complete timeline
- Checksums match across artifacts + registry

---

## Implementation Order

1. **Create shared contracts** (registry + checksum + timeline)
   - artifact-registry-maintenance.md
   - artifact-checksum-contract.md
   - artifact-timeline-queries.md

2. **Create utility scripts**
   - tools/artifact-checksum.sh
   - tools/artifact-timeline.sh

3. **Update phase agents** (in this order)
   - altitude-execution (create registry + update on writes)
   - altitude-validation (record junta runs)
   - altitude-report (query registry)

4. **Create golden fixtures** (5 scenarios)

5. **Test end-to-end**

6. **Commit Wave 4**

---

## Success Definition

**Wave 4 is complete when:**

- [ ] artifact-generation-registry.yaml is created + maintained correctly
- [ ] All artifacts include self-referential checksums
- [ ] Timeline queries work (5+ query types)
- [ ] Validation runs are linked to artifact versions
- [ ] 5 golden fixtures pass
- [ ] End-to-end test: create → modify → validate → query succeeds
- [ ] Documentation complete (3 new shared contracts)
- [ ] Single commit to main

---

## Estimated Timeline

| Phase | Effort | Days |
|-------|--------|------|
| Design review (this doc) | 1h | 0.125 |
| Create 3 shared contracts | 4h | 0.5 |
| Create 2 utility scripts | 3h | 0.375 |
| Update 3 agents | 6h | 0.75 |
| Create 5 golden fixtures | 6h | 0.75 |
| Test end-to-end | 4h | 0.5 |
| Documentation review | 2h | 0.25 |
| **TOTAL** | **26h** | **3-4 days** |

---

## Next Step

1. **Confirm design** ← you are here
2. Create shared contracts
3. Create utility scripts
4. Update agents
5. Create fixtures
6. Test end-to-end
7. Commit Wave 4
