# Artifact Taxonomy & Generation Tracking

## Purpose

Define all artifact types, their taxonomy, and how generations are tracked across the lifecycle of a change.

This enables queries like:
- "How many times was X artifact generated?"
- "When was the last validation run?"
- "Timeline of all changes to PRD"
- "All artifacts changed between dates X and Y"

---

## Artifact Taxonomy

### Intent Phase

| Artifact | Slug | Max instances | Tracked |
|----------|------|---------------|---------|
| Intent summary or intent doc | `00-intent` | 1 | Yes |

### Structure Phase

| Artifact | Slug | Max instances | Tracked |
|----------|------|---------------|---------|
| Structure analysis | `01-structure` | 1 | Yes |

### Design/Plan Phase

| Artifact | Slug | Max instances | Tracked |
|----------|------|---------------|---------|
| Product requirements doc | `prd` | 1 | Yes |
| Architectural decision record | `adr` | 1-N (one per decision) | Yes |
| Test specification | `test-spec` | 1 | Yes |
| Task specification files | `task-*.spec.md` | 1-N | Yes |
| Decomposition manifest | `02-decomposition` | 1 | Yes |

### Execution Phase

| Artifact | Slug | Max instances | Tracked |
|----------|------|---------------|---------|
| Execution ledger | `04-execution-ledger` | 1 | Yes |

### Validation Phase (NEW)

| Artifact | Slug | Max instances | Tracked |
|----------|------|---------------|---------|
| Evidence pack manifest | `_validate/manifest.md` | N (one per run) | Yes |
| Requirements report | `_validate/01_REQUIREMENTS_REPORT.json` | N | Yes |
| Architecture report | `_validate/02_ARCHITECTURE_REPORT.json` | N | Yes |
| Tests report | `_validate/03_TESTS_REPORT.json` | N | Yes |
| Tasks report | `_validate/04_TASKS_REPORT.json` | N | Yes |
| Scoring | `_validate/05_SCORING.json` | N | Yes |
| Council verdict | `_validate/06_COUNCIL_VERDICT.json` | N | Yes |
| Validation report | `validation-report.md` | N (one per run) | Yes |
| Implementation plan | `implementation-plan.md` | N (if needed) | Yes |

### Ship Phase

| Artifact | Slug | Max instances | Tracked |
|----------|------|---------------|---------|
| Ship summary | `ship-summary.md` | 1 | Yes |

---

## Generation Tracking Metadata

Every artifact includes header metadata:

### Required Fields (ALL Artifacts)

```yaml
generated_at: "ISO8601 timestamp"      # When created (UTC)
generated_by: "agent-name"             # Which agent/coordinator created it
change_id: "id-slug"                   # Parent change identifier
phase: "Intent|Structure|Design|Execution|Validation|Ship"
artifact_type: "prd|adr|task-spec|validation_report|..."
artifact_slug: "slug-from-taxonomy"    # For easy lookups
version: 1                             # Version within generation cycle
generation_number: 1                   # 1st/2nd/3rd time this artifact generated
prior_generations: []                  # Links to previous versions
```

### Validation Phase Additional Fields

For validation artifacts, add:

```yaml
junta_run_id: "validation-run-YYYYMMDD-NNN"  # Unique run identifier
juntas_run: ["requirements", "architecture", "tests", "tasks", "council"]
score: 85                                     # Overall score (0-100)
status: "PASSED|WARNING|FAILED"               # Overall status
```

---

## Generation Registry

### Purpose

Central registry for all artifact generations within a change.

### File Location

`.specs/changes/<change-id>/artifact-generation-registry.yaml`

### Schema

```yaml
change_id: "wave-3-design"
created_at: "2026-06-28T10:00:00Z"      # When registry created
last_updated_at: "2026-06-28T16:45:00Z" # When last updated
total_artifacts_tracked: 12
artifact_generations:

  # Single-instance artifact (PRD)
  prd:
    artifact_type: "prd"
    artifact_slug: "prd"
    max_instances: 1
    generation_count: 2
    last_generation_number: 2
    generations:

      - generation_number: 1
        generated_at: "2026-06-28T10:00:00Z"
        generated_by: "altitude-plan"
        file_path: ".specs/changes/wave-3-design/prd.md"
        checksum: "sha256:abc123def456"
        size_lines: 120
        status: "draft"
        notes: "Initial draft"

      - generation_number: 2
        generated_at: "2026-06-28T14:30:00Z"
        generated_by: "altitude-plan"
        file_path: ".specs/changes/wave-3-design/prd.md"
        checksum: "sha256:xyz789abc123"
        size_lines: 150
        status: "ready"
        notes: "Acceptance criteria refined"
        prior_version_checksum: "sha256:abc123def456"
        prior_generation_number: 1

  # Multi-instance artifact (validation reports)
  validation_report:
    artifact_type: "validation_report"
    artifact_slug: "validation-report"
    max_instances: "unbounded"
    generation_count: 2
    last_generation_number: 2
    generations:

      - generation_number: 1
        run_id: "validation-run-20260628-001"
        generated_at: "2026-06-28T14:00:00Z"
        generated_by: "altitude-validation"
        file_path: ".specs/changes/wave-3-design/_validate/validation-report-001.md"
        juntas_run: ["requirements", "architecture", "tests", "tasks", "council"]
        score: 78
        status: "failed"
        notes: "Initial validation"

      - generation_number: 2
        run_id: "validation-run-20260628-002"
        generated_at: "2026-06-28T15:00:00Z"
        generated_by: "altitude-validation"
        file_path: ".specs/changes/wave-3-design/_validate/validation-report-002.md"
        juntas_run: ["requirements", "architecture", "tests", "tasks", "council"]
        score: 92
        status: "passed"
        notes: "Passed after PRD refinement"

  implementation_plan:
    artifact_type: "implementation_plan"
    artifact_slug: "implementation-plan"
    max_instances: "unbounded"
    generation_count: 1
    generations:

      - generation_number: 1
        generated_at: "2026-06-28T16:45:00Z"
        generated_by: "altitude-validation"
        file_path: ".specs/changes/wave-3-design/_validate/implementation-plan-001.md"
        triggered_by_validation_run: "validation-run-20260628-001"
        triggered_by_score: 78
        notes: "Created after first validation failed"
```

---

## Header Formats

### Markdown Artifacts

```markdown
---
# ARTIFACT METADATA
artifact_type: prd
artifact_slug: prd
change_id: wave-3-design
phase: Design
generated_at: 2026-06-28T14:30:00Z
generated_by: altitude-plan
generation_number: 2
file_version: prd-v2
prior_generation:
  generation_number: 1
  generated_at: 2026-06-28T10:00:00Z
  checksum: sha256:abc123def456
  file_path: .specs/changes/wave-3-design/prd.md
---

# Product Requirements — Wave 3 Design

[rest of document]
```

### JSON Artifacts

```json
{
  "artifact_metadata": {
    "artifact_type": "requirements_report",
    "artifact_slug": "validation_report",
    "change_id": "wave-3-design",
    "phase": "Validation",
    "generated_at": "2026-06-28T15:00:00Z",
    "generated_by": "altitude-validation",
    "generation_number": 1,
    "junta_run_id": "validation-run-20260628-002",
    "score": 92,
    "status": "passed",
    "prior_generations": [
      {
        "generation_number": 1,
        "generated_at": "2026-06-28T14:00:00Z",
        "junta_run_id": "validation-run-20260628-001",
        "score": 78,
        "status": "failed"
      }
    ]
  },
  "content": {
    "summary": "...",
    "findings": [...]
  }
}
```

---

## Query Support

### How many times was X artifact generated?

```bash
# Count all validations for a change
grep "artifact_type: validation_report" .specs/changes/*/artifact-generation-registry.yaml | wc -l

# For specific change
yq '.artifact_generations.validation_report.generation_count' \
  .specs/changes/wave-3-design/artifact-generation-registry.yaml
```

### When was the last generation?

```bash
# Last validation
yq '.artifact_generations.validation_report.generations[-1].generated_at' \
  .specs/changes/wave-3-design/artifact-generation-registry.yaml

# All timestamps for a change
yq '.artifact_generations[] | .generations[].generated_at' \
  .specs/changes/wave-3-design/artifact-generation-registry.yaml | sort
```

### Timeline of all artifact changes

```bash
# All generations sorted by time
yq '.artifact_generations[] | .generations[] | {artifact: .artifact_type, time: .generated_at, status: .status}' \
  .specs/changes/wave-3-design/artifact-generation-registry.yaml | sort_by(.time)
```

### Artifacts between two dates

```bash
# All artifacts generated after 2026-06-28T14:00:00Z
yq '.artifact_generations[] | .generations[] | select(.generated_at > "2026-06-28T14:00:00Z")' \
  .specs/changes/wave-3-design/artifact-generation-registry.yaml
```

### Version history for one artifact

```bash
# All versions of PRD
yq '.artifact_generations.prd.generations[]' \
  .specs/changes/wave-3-design/artifact-generation-registry.yaml
```

---

## Registry Management

### Creation

Registry is created when a change is first created (Intent phase):

```bash
# .specs/changes/wave-3-design/artifact-generation-registry.yaml
change_id: "wave-3-design"
created_at: "2026-06-28T10:00:00Z"
last_updated_at: "2026-06-28T10:00:00Z"
artifact_generations: {}
```

### Updates

Registry is updated each time an artifact is generated:

```bash
# After PRD generation
yq -i '.artifact_generations.prd.generations += [{generation_number: 1, ...}]' \
  .specs/changes/wave-3-design/artifact-generation-registry.yaml

yq -i '.last_updated_at = "2026-06-28T10:05:00Z"' \
  .specs/changes/wave-3-design/artifact-generation-registry.yaml
```

### Validation

Before accepting a generation:
- [ ] artifact_type matches taxonomy
- [ ] generation_number is sequential
- [ ] generated_at is ISO8601 and later than prior
- [ ] generated_by is valid agent name
- [ ] checksum is present (for validation runs)
- [ ] status is PASSED/WARNING/FAILED (for validation runs)

---

## Source Authority

- Grounded in audit + traceability requirements
- Supports artifact lifecycle tracking
- Enables metrics: "X artifact generated N times"
- Enables timeline: "When did X change"
- Enables version comparison: "What changed between gen 1 and 2"

---

## Example: Full Timeline

```
Wave 3 Design — Complete Generation Timeline

10:00 ─ PRD v1 (draft, 120 lines, status: draft)
        └─ generated by: altitude-plan

10:15 ─ ADR v1 (architectural decisions)
        └─ generated by: altitude-plan

10:30 ─ task-spec-001 v1 (decomposed task)
        └─ generated by: altitude-plan

14:00 ─ VALIDATION RUN #1 (failed, score: 78)
        ├─ requirements_report v1 (coverage: 85)
        ├─ architecture_report v1 (fidelity: 80)
        ├─ tests_report v1 (coverage: 75)
        ├─ tasks_report v1 (completeness: 82)
        ├─ council_verdict v1 (remediate needed)
        ├─ validation_report v1 (status: FAILED)
        └─ implementation_plan v1 (created)

14:30 ─ PRD v2 (updated, 150 lines, status: ready)
        ├─ prior: v1 (120 lines)
        └─ notes: acceptance criteria refined

15:00 ─ VALIDATION RUN #2 (passed, score: 92)
        ├─ requirements_report v2 (coverage: 95)
        ├─ architecture_report v2 (fidelity: 90)
        ├─ tests_report v2 (coverage: 90)
        ├─ tasks_report v2 (completeness: 93)
        ├─ council_verdict v2 (all clear)
        └─ validation_report v2 (status: PASSED)

(No new implementation_plan needed — validation passed)
```

---

## Constraints

- **Immutability**: Once generated_at is set, it never changes
- **Sequential**: generation_number must always increase by 1
- **Checksums**: For validation runs, checksum must be present
- **Uniqueness**: Each (artifact_type, generation_number, change_id) tuple must be unique
- **Traceability**: prior_generation links must be resolvable

---

## Exit Criteria

This contract is complete when:

- ✅ Taxonomy covers all artifact types (Intent → Ship)
- ✅ Generation registry schema is queryable
- ✅ Header formats are consistent (markdown + JSON)
- ✅ Query examples are actionable
- ✅ Timeline examples show real scenarios
- ✅ Constraints are explicit
- ✅ Registry management is documented
