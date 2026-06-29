# Artifact Checksum & Immutability Contract

## Purpose

Define how checksums are computed, stored, verified, and used to detect unintended modifications to artifacts across the Harness V3 lifecycle.

---

## Checksum Specification

### Algorithm

**Standard:** SHA256 (256-bit cryptographic hash)

**Why SHA256:**
- Deterministic (same content = same hash)
- Fast to compute
- Collision-resistant (99.99% safe for accidental changes)
- Industry standard (Git, Docker, TLS, etc.)

### Computation

```bash
# For Markdown artifacts
checksum=$(sha256sum artifact.md | awk '{print $1}')

# For JSON artifacts
checksum=$(sha256sum artifact.json | awk '{print $1}')

# For YAML artifacts
checksum=$(sha256sum artifact.yaml | awk '{print $1}')

# Result format: sha256:abc123def456...
echo "sha256:$checksum"
```

**Important:** Checksum is computed on the **raw file content**, not including:
- The YAML frontmatter header (which includes the checksum itself)
- Trailing whitespace
- Line ending variations (normalize to LF)

---

## Storing Checksums

### In Artifact Header

Every artifact must include a self-referential checksum in its header:

**Markdown:**
```markdown
---
artifact_type: prd
checksum: sha256:abc123def456ghi789jkl012mno345pqr678stu901
---

# PRD Content
...
```

**JSON:**
```json
{
  "artifact_type": "prd",
  "checksum": "sha256:abc123def456ghi789jkl012mno345pqr678stu901",
  "data": {
    ...
  }
}
```

**YAML:**
```yaml
artifact_type: prd
checksum: sha256:abc123def456ghi789jkl012mno345pqr678stu901
data:
  ...
```

### In Registry

The artifact-generation-registry.yaml stores checksums for all versions:

```yaml
artifact_generations:
  prd:
    generations:
      - generation_number: 1
        checksum: sha256:abc123def456ghi789jkl012mno345pqr678stu901
      - generation_number: 2
        checksum: sha256:xyz789abc123def456ghi789jkl012mno345pqr678
        prior_generation_checksum: sha256:abc123def456ghi789jkl012mno345pqr678stu901
```

### In Validation Evidence Pack

When validation runs, record checksums of all artifacts analyzed:

```yaml
.specs/changes/<change-id>/_validate/artifact-checksums.yaml

validated_artifacts:
  - artifact_slug: prd
    generation_number: 2
    checksum: sha256:xyz789abc123def456ghi789jkl012mno345pqr678
    analyzed_at: 2026-06-29T15:45:00Z
    
  - artifact_slug: adr
    generation_number: 1
    checksum: sha256:def456ghi789jkl012mno345pqr678stu901vwx234
    analyzed_at: 2026-06-29T15:45:00Z
```

---

## Checksum Verification

### Detection of Unintended Modification

```bash
#!/bin/bash
# tools/artifact-checksum-verify.sh

ARTIFACT=$1

# Read checksum from artifact header
header_checksum=$(yq -r '.checksum' "$ARTIFACT" 2>/dev/null)

# Compute checksum of current file
current_checksum="sha256:$(sha256sum "$ARTIFACT" | awk '{print $1}')"

# Compare
if [ "$header_checksum" == "$current_checksum" ]; then
    echo "✓ Checksum valid"
    exit 0
else
    echo "✗ Checksum mismatch!"
    echo "  Expected: $header_checksum"
    echo "  Current:  $current_checksum"
    echo "  Action needed: artifact was modified outside of registry"
    exit 1
fi
```

### Detection of Change Between Versions

```bash
#!/bin/bash
# Check if artifact changed between two validation runs

REGISTRY=".specs/changes/<change-id>/artifact-generation-registry.yaml"
ARTIFACT_SLUG=$1

# Checksum from validation run #1
checksum_run1=$(yq '.artifact_generations.validation_report.generations[0].artifacts_analyzed[] | select(.artifact_slug == "'$ARTIFACT_SLUG'") | .checksum' "$REGISTRY")

# Checksum from validation run #2
checksum_run2=$(yq '.artifact_generations.validation_report.generations[1].artifacts_analyzed[] | select(.artifact_slug == "'$ARTIFACT_SLUG'") | .checksum' "$REGISTRY")

if [ "$checksum_run1" == "$checksum_run2" ]; then
    echo "No change detected"
    exit 0
else
    echo "Change detected:"
    echo "  Run 1: $checksum_run1"
    echo "  Run 2: $checksum_run2"
    exit 1
fi
```

---

## Immutability Guarantees

### What is Immutable

Once written and checksummed, an artifact **version** is immutable:

- The checksum is a permanent record of what the artifact was at that moment
- Prior versions are preserved in registry.prior_generation_checksum chain
- Validation evidence packs include checksums from time of analysis

**This enables:**
- "Rollback to prior checksum"
- "Reproduce validation with original artifacts"
- "Audit trail of what was analyzed when"

### What is NOT Immutable

New generations are allowed:

- Phase agents can write new versions of artifacts
- Registry increments generation_number for each write
- Prior checksums are preserved via prior_generation_checksum chain

**This enables:**
- Iterative refinement (PRD revised, re-validated, etc.)
- Bug fixes (typo in test-spec, fix it, re-run validation)
- Stakeholder feedback (ADR revised, new generation created)

### Timeline Integrity

The registry chain proves the sequence:

```
PRD Gen 1 (checksum: abc123)
   ↓ (prior_generation_checksum: abc123)
PRD Gen 2 (checksum: def456)
   ↓ (prior_generation_checksum: def456)
PRD Gen 3 (checksum: ghi789)
```

**Invariant:** Each prior_generation_checksum must match a previous generation's checksum.

---

## Rollback Path

If you need to revert to a prior artifact version:

```bash
#!/bin/bash
# tools/artifact-rollback.sh

CHANGE_ID=$1
ARTIFACT_SLUG=$2
TARGET_GENERATION=$3

REGISTRY=".specs/changes/$CHANGE_ID/artifact-generation-registry.yaml"
ARTIFACT_PATH=$(yq ".artifact_generations.$ARTIFACT_SLUG.generations[$TARGET_GENERATION - 1].file_path" "$REGISTRY")
TARGET_CHECKSUM=$(yq ".artifact_generations.$ARTIFACT_SLUG.generations[$TARGET_GENERATION - 1].checksum" "$REGISTRY")

echo "Rolling back $ARTIFACT_SLUG to generation $TARGET_GENERATION"
echo "  Target checksum: $TARGET_CHECKSUM"
echo "  Target file: $ARTIFACT_PATH"
echo ""
echo "To rollback:"
echo "  1. Manually restore artifact from version control"
echo "  2. Verify: tools/artifact-checksum-verify.sh $ARTIFACT_PATH"
echo "  3. Re-run validation"
```

---

## Checksum Audit Trail

### Before Artifact Write

```
1. Compute checksum of new content
2. Check: is this checksum already in registry?
   - If yes, warn: "This artifact is identical to a prior generation"
   - If no, proceed
```

### After Artifact Write

```
1. Verify: on-disk checksum == registry checksum
2. If mismatch: abort and warn "registry update failed"
3. If match: commit registry and artifact together
```

### During Validation

```
1. For each artifact analyzed:
   a. Read artifact from disk
   b. Compute checksum
   c. Store in validation evidence pack
   d. Compare to registry entry
2. If mismatch: warn "artifact was modified after analysis"
```

---

## Checksum Policies

### Policy 1: No Silent Modifications

**Rule:** Phase agents must never silently modify artifacts. All changes must go through write + registry flow.

**Enforcement:**
```python
# DO THIS:
def update_artifact(artifact_slug, new_content):
    write_artifact_with_registry_update(artifact_slug, new_content)

# DON'T DO THIS:
def update_artifact(artifact_slug, new_content):
    open(artifact_path, 'w').write(new_content)  # Registry not updated!
```

### Policy 2: Detect Externally Modified Artifacts

**Rule:** Before writing to registry, verify on-disk artifact matches expected checksum.

**Enforcement:**
```python
def write_artifact_with_registry_update(artifact_slug, new_content):
    file_path = get_file_path(artifact_slug)
    
    # If file already exists, verify prior checksum
    if file_exists(file_path):
        prior_on_disk_checksum = compute_checksum(read_file(file_path))
        prior_registry_checksum = get_prior_checksum_from_registry(artifact_slug)
        
        if prior_on_disk_checksum != prior_registry_checksum:
            raise Error("Artifact was modified outside of registry!")
    
    # Now safe to proceed
    write_file(file_path, new_content)
    update_registry(artifact_slug, compute_checksum(new_content))
```

### Policy 3: Preserve History

**Rule:** Never delete prior generations from registry. Always append.

**Enforcement:** Registry is append-only (for prior versions).

---

## Checksum Format

**Standard format:** `sha256:<64-character-hex-string>`

**Example:** `sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

**Regex:** `^sha256:[a-f0-9]{64}$`

---

## Tools

### Compute Checksum

```bash
tools/artifact-checksum.sh compute <artifact_path>
```

### Verify Checksum

```bash
tools/artifact-checksum.sh verify <artifact_path>
```

### Compare Checksums

```bash
tools/artifact-checksum.sh compare <artifact_1> <artifact_2>
```

### List All Checksums in Change

```bash
tools/artifact-checksum.sh list-all <change_id>
```

---

## Success Criteria

- [ ] All artifacts include self-referential checksums
- [ ] Registry stores all checksums per generation
- [ ] Validation evidence packs include checksums at analysis time
- [ ] Checksum verification tool detects modifications
- [ ] Rollback path preserves prior checksums
- [ ] No artifact can be modified without registry update
- [ ] Prior generation chain is never broken
