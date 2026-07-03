# Artifact Timeline Queries Contract

## Purpose

Define query patterns and examples for analyzing artifact history through the artifact-generation-registry.yaml.

---

## Registry Structure (Quick Reference)

```yaml
.specs/changes/<change-id>/artifact-generation-registry.yaml

├── change_id
├── created_at
├── last_updated_at
├── total_artifacts_tracked
└── artifact_generations
    ├── prd
    │   ├── artifact_type
    │   ├── artifact_slug
    │   ├── generation_count
    │   └── generations[]
    │       ├─ generation_number
    │       ├─ generated_at
    │       ├─ generated_by
    │       ├─ checksum
    │       ├─ status
    │       └─ prior_generation_checksum
    │
    ├── validation_report
    │   ├── generation_count
    │   └── generations[]
    │       ├─ generation_number
    │       ├─ junta_run_id
    │       ├─ score
    │       ├─ artifacts_analyzed[]
    │       │   └─ {artifact_slug, checksum}
```

---

## Query Categories

---

## Category 1: Single-Artifact Timeline

### Query 1.1: Show all versions of one artifact

```bash
# List all PRD generations
yq '.artifact_generations.prd.generations[] | {
  gen: .generation_number,
  timestamp: .generated_at,
  status: .status,
  checksum: .checksum
}' artifact-generation-registry.yaml
```

**Output:**
```
gen: 1
timestamp: 2026-06-29T14:00:00Z
status: draft
checksum: sha256:abc123
---
gen: 2
timestamp: 2026-06-29T15:30:00Z
status: ready
checksum: sha256:def456
---
gen: 3
timestamp: 2026-06-29T16:00:00Z
status: passed
checksum: sha256:ghi789
```

### Query 1.2: Show when artifact was last modified

```bash
# Last generation of ADR
yq '.artifact_generations.adr.generations[-1] | {
  generation_number,
  generated_at,
  generated_by,
  status
}' artifact-generation-registry.yaml
```

**Output:**
```
generation_number: 1
generated_at: 2026-06-29T14:15:00Z
generated_by: altitude-plan
status: draft
```

### Query 1.3: Count total modifications of one artifact

```bash
# How many times was PRD regenerated?
yq '.artifact_generations.prd.generation_count' artifact-generation-registry.yaml
```

**Output:**
```
3
```

### Query 1.4: Show artifact change chain (with checksums)

```bash
# Show PRD evolution: gen 1 → gen 2 → gen 3
yq '.artifact_generations.prd.generations[] | {
  gen: .generation_number,
  checksum: .checksum,
  prior: .prior_generation_checksum
}' artifact-generation-registry.yaml | \
sed 's/checksum:/checksum:/' | \
awk 'NR>1 {print prev " → " $0} {prev=$0}'
```

**Output:**
```
gen: 1
checksum: sha256:abc123
prior: null
 → gen: 2
checksum: sha256:def456
prior: sha256:abc123
 → gen: 3
checksum: sha256:ghi789
prior: sha256:def456
```

---

## Category 2: Validation Timeline

### Query 2.1: Show all validation runs with scores

```bash
# Timeline of validation runs
yq '.artifact_generations.validation_report.generations[] | {
  run: .junta_run_id,
  score: .score,
  status: .status,
  timestamp: .generated_at
}' artifact-generation-registry.yaml
```

**Output:**
```
run: validation-run-20260629-001
score: 78
status: FAILED
timestamp: 2026-06-29T15:45:00Z
---
run: validation-run-20260629-002
score: 92
status: PASSED
timestamp: 2026-06-29T16:00:00Z
```

### Query 2.2: Show score progression (did we improve?)

```bash
# Extract scores and show trend
yq -r '.artifact_generations.validation_report.generations[] | "\(.junta_run_id): \(.score)/100"' \
  artifact-generation-registry.yaml | \
awk -F': ' '{print $2 "%" " (" $1 ")"}'
```

**Output:**
```
78% (validation-run-20260629-001)
92% (validation-run-20260629-002)
```

### Query 2.3: Which artifacts were analyzed in each run?

```bash
# Show which artifacts + checksums were used in each validation
yq '.artifact_generations.validation_report.generations[] | {
  run: .junta_run_id,
  artifacts: .artifacts_analyzed
}' artifact-generation-registry.yaml
```

**Output:**
```
run: validation-run-20260629-001
artifacts:
  - artifact_slug: prd
    checksum: sha256:abc123
  - artifact_slug: adr
    checksum: sha256:def456
---
run: validation-run-20260629-002
artifacts:
  - artifact_slug: prd
    checksum: sha256:def456
  - artifact_slug: adr
    checksum: sha256:def456
```

---

## Category 3: Cross-Artifact Change Detection

### Query 3.1: Did PRD change between validation run 1 and 2?

```bash
#!/bin/bash
REGISTRY="artifact-generation-registry.yaml"
ARTIFACT="prd"

# Checksum from run 1
checksum_run1=$(yq ".artifact_generations.validation_report.generations[0].artifacts_analyzed[] | select(.artifact_slug == \"$ARTIFACT\") | .checksum" "$REGISTRY")

# Checksum from run 2
checksum_run2=$(yq ".artifact_generations.validation_report.generations[1].artifacts_analyzed[] | select(.artifact_slug == \"$ARTIFACT\") | .checksum" "$REGISTRY")

if [ "$checksum_run1" == "$checksum_run2" ]; then
    echo "✓ $ARTIFACT unchanged between runs"
else
    echo "✗ $ARTIFACT changed:"
    echo "  Run 1: $checksum_run1"
    echo "  Run 2: $checksum_run2"
fi
```

**Output:**
```
✗ prd changed:
  Run 1: sha256:abc123
  Run 2: sha256:def456
```

### Query 3.2: What artifacts changed between validations?

```bash
#!/bin/bash
REGISTRY="artifact-generation-registry.yaml"

# Get artifacts from run 1
run1_artifacts=$(yq '.artifact_generations.validation_report.generations[0].artifacts_analyzed' "$REGISTRY" | jq -r '.[].artifact_slug')

# Get artifacts from run 2
run2_artifacts=$(yq '.artifact_generations.validation_report.generations[1].artifacts_analyzed' "$REGISTRY" | jq -r '.[].artifact_slug')

echo "Artifacts that changed between validation runs:"

for artifact in $run1_artifacts; do
    checksum_run1=$(yq ".artifact_generations.validation_report.generations[0].artifacts_analyzed[] | select(.artifact_slug == \"$artifact\") | .checksum" "$REGISTRY")
    checksum_run2=$(yq ".artifact_generations.validation_report.generations[1].artifacts_analyzed[] | select(.artifact_slug == \"$artifact\") | .checksum" "$REGISTRY")

    if [ "$checksum_run1" != "$checksum_run2" ]; then
        echo "  ✗ $artifact: $checksum_run1 → $checksum_run2"
    else
        echo "  ✓ $artifact: unchanged"
    fi
done
```

**Output:**
```
Artifacts that changed between validation runs:
  ✓ prd: unchanged
  ✗ adr: sha256:def456 → sha256:jkl012
  ✓ test-spec: unchanged
```

### Query 3.3: Reproduce validation with specific artifact versions

```bash
# Show exactly which artifact versions the validation analyzed
junta_run_id="validation-run-20260629-002"

yq ".artifact_generations.validation_report.generations[] | select(.junta_run_id == \"$junta_run_id\") | {
  run: .junta_run_id,
  score: .score,
  artifacts_analyzed: .artifacts_analyzed
}" artifact-generation-registry.yaml
```

**Output:**
```
run: validation-run-20260629-002
score: 92
artifacts_analyzed:
  - artifact_slug: prd
    checksum: sha256:def456
  - artifact_slug: adr
    checksum: sha256:jkl012
```

**Use case:** "I want to rebuild the exact validation with these artifacts"

---

## Category 4: Timeline by Phase

### Query 4.1: Show when each phase modified artifacts

```bash
# All artifacts created/modified during PLAN phase
yq '.artifact_generations | to_entries[] | select(.value.generations[0].generated_by | startswith("altitude-plan")) | {
  artifact: .key,
  generations: .value.generation_count,
  first_created: .value.generations[0].generated_at
}' artifact-generation-registry.yaml
```

**Output:**
```
artifact: prd
generations: 1
first_created: 2026-06-29T14:00:00Z
---
artifact: adr
generations: 1
first_created: 2026-06-29T14:15:00Z
---
artifact: decomposition
generations: 1
first_created: 2026-06-29T14:30:00Z
```

### Query 4.2: What agents touched which artifacts?

```bash
# Show all agents + artifacts they modified
yq '.artifact_generations | to_entries[] | {
  artifact: .key,
  modified_by: (.value.generations[] | .generated_by) | unique
}' artifact-generation-registry.yaml
```

**Output:**
```
artifact: prd
modified_by:
  - altitude-plan
  - altitude-execution
---
artifact: validation_report
modified_by:
  - altitude-validation
```

---

## Category 5: Artifact Aging & Staleness

### Query 5.1: Which artifacts are old (not updated since X)?

```bash
# Artifacts not modified in last 24 hours
cutoff_date=$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)

yq ".artifact_generations | to_entries[] | select(.value.generations[-1].generated_at < \"$cutoff_date\") | {
  artifact: .key,
  last_updated: .value.generations[-1].generated_at,
  age_hours: (now - (\\(.value.generations[-1].generated_at | fromdateiso8601))) / 3600
}" artifact-generation-registry.yaml
```

**Output:**
```
artifact: prd
last_updated: 2026-06-28T14:00:00Z
age_hours: 48.5
```

### Query 5.2: Freshness report

```bash
# Show which artifacts are "fresh" vs "stale"
yq '.artifact_generations | to_entries[] | {
  artifact: .key,
  last_updated: .value.generations[-1].generated_at,
  freshness: if (now - (.value.generations[-1].generated_at | fromdateiso8601)) < 86400
             then "fresh" else "stale" end
}' artifact-generation-registry.yaml
```

**Output:**
```
artifact: prd
last_updated: 2026-06-29T16:00:00Z
freshness: fresh
---
artifact: adr
last_updated: 2026-06-29T14:15:00Z
freshness: stale
```

---

## Category 6: Debugging & Audit

### Query 6.1: Show complete registry for one artifact

```bash
# Full registry entry for PRD
yq '.artifact_generations.prd' artifact-generation-registry.yaml
```

### Query 6.2: Find artifacts modified by specific agent

```bash
# What did altitude-execution modify?
agent="altitude-execution"

yq ".artifact_generations | to_entries[] | select(.value.generations[] | .generated_by == \"$agent\") | .key" \
  artifact-generation-registry.yaml
```

**Output:**
```
prd
decomposition
```

### Query 6.3: Show all registry changes on specific date

```bash
date_filter="2026-06-29"

yq ".artifact_generations | to_entries[] | {
  artifact: .key,
  changes_on_date: [.value.generations[] | select(.generated_at | startswith(\"$date_filter\"))]
}" artifact-generation-registry.yaml
```

### Query 6.4: Validate registry integrity

```bash
#!/bin/bash
# Verify prior_generation_checksum chain

REGISTRY="artifact-generation-registry.yaml"

echo "Checking registry integrity..."

artifacts=$(yq '.artifact_generations | keys[]' "$REGISTRY")

for artifact in $artifacts; do
    gens=$(yq ".artifact_generations.$artifact.generations | length" "$REGISTRY")

    for ((i=0; i<gens; i++)); do
        gen_num=$(yq ".artifact_generations.$artifact.generations[$i].generation_number" "$REGISTRY")
        checksum=$(yq ".artifact_generations.$artifact.generations[$i].checksum" "$REGISTRY")
        prior=$(yq ".artifact_generations.$artifact.generations[$i].prior_generation_checksum" "$REGISTRY")

        if [ $gen_num -gt 1 ]; then
            prior_gen_checksum=$(yq ".artifact_generations.$artifact.generations[$((i-1))].checksum" "$REGISTRY")
            if [ "$prior" != "$prior_gen_checksum" ]; then
                echo "✗ INVALID: $artifact gen $gen_num prior_generation_checksum mismatch"
            fi
        fi
    done
done

echo "✓ Registry integrity check complete"
```

---

## Tools

All queries use standard Unix tools:
- `yq` — YAML query
- `jq` — JSON query
- `date` — timestamp manipulation
- `awk` — text processing

### Convenience Wrapper

```bash
# tools/artifact-timeline.sh

usage() {
    echo "artifact-timeline.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  timeline <artifact_slug>          Show all versions of artifact"
    echo "  validation-runs                   Show all validation runs + scores"
    echo "  changed <validation_run_1> <run_2>  Show what changed between runs"
    echo "  freshness                         Show which artifacts are fresh/stale"
    echo "  integrity                        Validate registry chain"
}

case "$1" in
    timeline) yq ".artifact_generations.$2.generations[]" artifact-generation-registry.yaml ;;
    validation-runs) yq '.artifact_generations.validation_report.generations[]' artifact-generation-registry.yaml ;;
    changed) # Compare two validation runs ;;
    freshness) # Show freshness report ;;
    integrity) # Validate chain ;;
    *) usage ;;
esac
```

---

## Success Criteria

- [ ] All 6 query categories work end-to-end
- [ ] Registry integrity checker detects broken chains
- [ ] Change detection between validations is accurate
- [ ] Tools scripts are available and documented
- [ ] Examples are tested against real Wave 4 registry
