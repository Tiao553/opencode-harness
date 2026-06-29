# Artifact Registry Maintenance Contract

## Purpose

Define when, how, and by whom artifact-generation-registry.yaml is created, updated, and queried across the Harness V3 lifecycle.

---

## Registry Lifecycle

### Creation (altitude-plan phase)

**When:** During decomposition, when the first artifact is generated  
**Who:** altitude-plan agent  
**What:** Create `.specs/changes/<change-id>/artifact-generation-registry.yaml`

**Schema:**
```yaml
change_id: "<change-id>"
created_at: "<ISO8601>"  # When registry created
last_updated_at: "<ISO8601>"  # When last updated
total_artifacts_tracked: 0
artifact_generations: {}
```

**Trigger:** Any artifact write (PRD, ADR, test-spec, etc.)

---

### Updates (all phases)

**When:** After any artifact is written or modified  
**Who:** Phase agent that generated the artifact  
**What:** Update registry entry for that artifact

**Steps:**
1. Read current registry (if exists)
2. Compute SHA256 checksum of artifact
3. Increment artifact.generation_count
4. Add new entry to artifact.generations[]
5. If modification: set prior_generation_checksum
6. Update registry.last_updated_at = now
7. Write registry

**Example update flow:**
```yaml
# Before: prd.generation_count = 1
# After writing modified PRD:

prd:
  generation_count: 2  # incremented
  generations:
    - generation_number: 1
      checksum: sha256:abc123
    - generation_number: 2  # [NEW]
      checksum: sha256:def456
      prior_generation_checksum: sha256:abc123  # links to previous
```

---

## Per-Phase Responsibilities

### Intent Phase (altitude-intent)
- No artifacts created; no registry update needed

### Structure Phase (altitude-structure)
- **Artifacts:** 01-structure.md
- **Action:** Create registry, add structure entry
- **When:** After writing 01-structure.md

### Design Phase (altitude-plan)
- **Artifacts:** PRD, ADR(s), test-spec, task-spec(s), 02-decomposition.md
- **Action:** Update registry entry for each artifact written
- **When:** After each artifact write

### Execution Phase (altitude-execution)
- **Artifacts:** 04-execution-ledger.md, any implementation artifacts
- **Action:** Update registry on each write
- **When:** After updating ledger

### Validation Phase (altitude-validation)
- **Artifacts:** validation-report.md, junta JSON outputs, evidence pack
- **Action:** Update registry with validation metadata + artifact checksums at analysis time
- **When:** After junta run completes

### Report Phase (altitude-report)
- **Artifacts:** 05-executive-report.md
- **Action:** Query registry for timeline data; update report entry
- **When:** After report generated

### Ship Phase (altitude-memory)
- **Artifacts:** 06-ship-note.md, archive metadata
- **Action:** Final registry update before archival
- **When:** After ship summary written

---

## Registry Entry Structure

Each artifact type gets one entry in artifact_generations:

```yaml
artifact_generations:
  <artifact_slug>:  # e.g., "prd", "adr-001", "validation_report"
    artifact_type: "<type>"  # e.g., "prd", "adr", "task-spec"
    artifact_slug: "<slug>"  # unique identifier within change
    max_instances: <count | "unbounded">
    generation_count: <N>
    last_generation_number: <N>
    generations:
      - generation_number: <seq>
        generated_at: "<ISO8601>"
        generated_by: "<agent-name>"
        file_path: "<path-to-artifact>"
        checksum: "<sha256:hash>"
        size_lines: <N>
        status: "<draft | ready | passed | failed>"
        notes: "<optional>"
        # For modifications:
        prior_generation_checksum: "<sha256:previous-hash>"
        # For validation artifacts:
        junta_run_id: "<validation-run-ID>"
        score: <N>
        artifacts_analyzed: [
          { artifact_slug, checksum },
          ...
        ]
```

---

## Agent Responsibilities

### altitude-execution

```python
# Pseudocode: artifact write with registry update

def write_artifact(file_path, content, artifact_type, artifact_slug):
    # 1. Write file
    write_file(file_path, content)
    
    # 2. Compute checksum
    checksum = sha256(content)
    
    # 3. Load or create registry
    registry = load_registry()  # Or create if not exists
    
    # 4. Update registry
    if artifact_slug not in registry['artifact_generations']:
        registry['artifact_generations'][artifact_slug] = {
            'artifact_type': artifact_type,
            'artifact_slug': artifact_slug,
            'generation_count': 0,
            'generations': []
        }
    
    entry = registry['artifact_generations'][artifact_slug]
    generation_number = len(entry['generations']) + 1
    
    # Get prior checksum if this is a modification
    prior_checksum = None
    if generation_number > 1:
        prior_checksum = entry['generations'][-1]['checksum']
    
    # Add new generation
    entry['generations'].append({
        'generation_number': generation_number,
        'generated_at': now_iso8601(),
        'generated_by': 'altitude-execution',
        'file_path': file_path,
        'checksum': checksum,
        'size_lines': len(content.split('\n')),
        'status': 'draft',
        'prior_generation_checksum': prior_checksum
    })
    
    entry['generation_count'] = generation_number
    registry['last_updated_at'] = now_iso8601()
    
    # 5. Save registry
    save_registry(registry)
```

### altitude-validation

```python
# Pseudocode: validation run with registry update

def run_junta_and_update_registry():
    # 1. Run validation (junta)
    junta_run_id = 'validation-run-' + timestamp()
    requirements_score, architecture_score, tests_score, tasks_score = run_junta()
    council_verdict = ask_council(scores)
    
    # 2. Collect checksums of artifacts analyzed
    artifacts_analyzed = [
        {'artifact_slug': 'prd', 'checksum': read_checksum('prd.md')},
        {'artifact_slug': 'adr', 'checksum': read_checksum('adr.md')},
        ...
    ]
    
    # 3. Create validation report
    report = create_validation_report(junta_run_id, scores, council_verdict, artifacts_analyzed)
    save_file(f"_validate/validation-report-{generation}.md", report)
    
    # 4. Update registry
    registry = load_registry()
    
    if 'validation_report' not in registry['artifact_generations']:
        registry['artifact_generations']['validation_report'] = {
            'artifact_type': 'validation_report',
            'artifact_slug': 'validation-report',
            'generation_count': 0,
            'generations': []
        }
    
    entry = registry['artifact_generations']['validation_report']
    generation_number = len(entry['generations']) + 1
    
    entry['generations'].append({
        'generation_number': generation_number,
        'junta_run_id': junta_run_id,
        'generated_at': now_iso8601(),
        'generated_by': 'altitude-validation',
        'file_path': f"_validate/validation-report-{generation}.md",
        'checksum': sha256(report),
        'score': council_verdict['score'],
        'status': council_verdict['status'],
        'artifacts_analyzed': artifacts_analyzed
    })
    
    entry['generation_count'] = generation_number
    registry['last_updated_at'] = now_iso8601()
    
    save_registry(registry)
    
    return report, council_verdict
```

### altitude-report

```python
# Pseudocode: query registry for timeline

def generate_timeline_view():
    registry = load_registry()
    
    # Timeline of PRD versions
    prd_generations = registry['artifact_generations']['prd']['generations']
    timeline = []
    for gen in prd_generations:
        timeline.append({
            'generation': gen['generation_number'],
            'timestamp': gen['generated_at'],
            'status': gen['status'],
            'checksum': gen['checksum']
        })
    
    # Timeline of validation scores
    validation_gens = registry['artifact_generations']['validation_report']['generations']
    validation_timeline = []
    for gen in validation_gens:
        validation_timeline.append({
            'run': gen['junta_run_id'],
            'score': gen['score'],
            'status': gen['status'],
            'timestamp': gen['generated_at'],
            'artifacts_analyzed': gen['artifacts_analyzed']
        })
    
    return {
        'artifact_timeline': timeline,
        'validation_timeline': validation_timeline
    }
```

---

## Checksum Integrity

**Requirement:** Each artifact must have exactly one checksum for each generation.

**Detection of modification:**
```bash
# If checksum of on-disk artifact != checksum in registry:
checksum_on_disk=$(sha256sum artifact.md)
checksum_in_registry=$(yq '.artifact_generations.<slug>.generations[-1].checksum' registry.yaml)

if [ "$checksum_on_disk" != "$checksum_in_registry" ]; then
    echo "WARNING: Artifact was modified outside of registry"
fi
```

**Rule:** Never modify an artifact directly without updating the registry. All writes go through the phase agents.

---

## Multi-Phase Artifact Lifecycle Example

```
Phase: PLAN
├─ altitude-plan writes PRD
│  └─ Registry entry created: prd.generation_number = 1, checksum = abc123
│
├─ altitude-plan writes ADR
│  └─ Registry entry created: adr.generation_number = 1, checksum = def456
│
└─ altitude-plan writes 02-decomposition.md
   └─ Registry entry created: decomposition.generation_number = 1, checksum = ghi789

Phase: EXECUTION
├─ altitude-execution updates PRD (acceptance criteria refined)
│  └─ Registry updated: prd.generation_number = 2, checksum = xyz789, prior_checksum = abc123
│
└─ altitude-execution writes 04-execution-ledger.md
   └─ Registry entry created: execution-ledger.generation_number = 1, checksum = jkl012

Phase: VALIDATION
├─ altitude-validation runs junta
│  └─ Junta analyzes: PRD (checksum xyz789), ADR (checksum def456), decomposition (checksum ghi789)
│
├─ altitude-validation creates validation_report
│  └─ Registry entry created: validation_report.generation_number = 1
│     ├─ junta_run_id = validation-run-001
│     ├─ score = 88
│     ├─ artifacts_analyzed = [{prd, xyz789}, {adr, def456}, ...]
│     └─ checksum = mno345
│
├─ User fixes PRD based on feedback
│  └─ altitude-execution updates PRD (correction)
│     └─ Registry updated: prd.generation_number = 3, checksum = pqr678, prior_checksum = xyz789
│
└─ altitude-validation re-runs junta
   └─ Registry entry created: validation_report.generation_number = 2
      ├─ junta_run_id = validation-run-002
      ├─ score = 94
      ├─ artifacts_analyzed = [{prd, pqr678}, {adr, def456}, ...]
      └─ prior_generation_checksum = mno345

Query: "Timeline of PRD versions"
└─ prd.generations = [
    {gen: 1, checksum: abc123},
    {gen: 2, checksum: xyz789, prior: abc123},
    {gen: 3, checksum: pqr678, prior: xyz789}
  ]

Query: "Did PRD change between validation run 1 and 2?"
└─ validation_report.generations[0].artifacts_analyzed[prd] = xyz789
   validation_report.generations[1].artifacts_analyzed[prd] = pqr678
   → YES, changed
```

---

## Error Handling

### Registry Missing

**Symptom:** phase agent tries to update non-existent registry  
**Action:** Create registry immediately with bootstrap metadata

### Checksum Mismatch

**Symptom:** on-disk artifact checksum != registry entry checksum  
**Action:** Log warning, offer options:
- A. Update registry to match on-disk (if intentional external edit)
- B. Restore from registry (if on-disk is corrupt)

### Generation Counter Inconsistency

**Symptom:** generation_count != len(generations[])  
**Action:** Repair: generation_count = len(generations[])

---

## Validation Gates

Before advancing to next phase:

- [ ] Registry exists
- [ ] All created/modified artifacts have registry entries
- [ ] All checksums are present and unique per generation
- [ ] Timestamps are monotonically increasing

---

## Success Criteria

- [ ] altitude-plan creates registry on first artifact write
- [ ] altitude-execution updates registry on every write
- [ ] altitude-validation records junta runs with artifact checksums
- [ ] altitude-report can query registry successfully
- [ ] Checksums detect modifications
- [ ] Multi-phase lifecycle preserves history
