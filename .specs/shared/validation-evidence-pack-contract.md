# Artifact Validation Evidence Pack Contract

## Purpose

Define what constitutes a "frozen evidence pack" that validation juntas receive.

This ensures all juntas see identical input and can produce independent, consistent assessments without data drift during validation runs.

---

## Evidence Pack Definition

An evidence pack is an **immutable snapshot** of all artifacts needed for validation.

### Phase 3 Artifacts (Design/Plan)

When present, these are included as-is:
- **PRD** (if created): Complete product requirements document
- **ADR** (if created): Architectural decision record(s)
- **TEST-SPEC** (if created): Test specification with test cases

### Phase 3 Artifacts (Execution Planning)

All task-spec files:
- `task-*.spec.md` or `task-*.spec.yaml` files
- Each task-spec must include:
  - Task goal
  - Allowed files (explicit list)
  - Forbidden files (explicit list)
  - Acceptance criteria
  - Parent change reference

### Phase 4 Artifacts (Execution)

- **Execution ledger** (`.specs/changes/<id>/04-execution-ledger.md` or similar):
  - Which tasks were executed
  - Changed files (complete diff)
  - Evidence of completion (test output, manual checks, etc.)
  - Known issues or gaps

### Phase 5 Input (Validation Prep)

- **List of all artifacts above** (snapshot manifest)
- **Execution evidence**: tests run, manual checks, validation steps performed
- **All changed files** (file tree snapshot showing what was modified)
- **Validation run ID**: Unique identifier for this run (e.g., `validation-run-20260628-001`)

---

## Evidence Pack Freeze Process

### Step 1: Verify Artifact Readiness

Before freezing, **coordinator MUST verify** each artifact is complete:

```
Freeze Checklist:

PRD (if present):
  [ ] No placeholder text remaining
  [ ] All acceptance criteria are measurable
  [ ] User personas are clear
  [ ] Acceptance criteria map to test cases
  [ ] No TODOs or FIXMEs

ADR (if present):
  [ ] Decision is clearly stated
  [ ] At least 2 alternatives documented
  [ ] Trade-offs explained
  [ ] Chosen alternative has rationale
  [ ] No TODOs or FIXMEs

TEST-SPEC (if present):
  [ ] All test cases have expected outcomes
  [ ] Edge cases documented
  [ ] Regression scenarios listed
  [ ] Test data/fixtures specified
  [ ] No placeholders

task-spec files:
  [ ] All tasks have complete fields (goal, files, criteria)
  [ ] Task IDs are unique within change
  [ ] Parent change reference is correct
  [ ] Accepted execution prerequisites are listed

Execution Ledger:
  [ ] Execution sequence matches task-spec order
  [ ] All executed tasks have completion evidence
  [ ] Failed tasks have root cause notes
  [ ] Changed files list is complete
  [ ] Test results documented
```

If any artifact fails readiness check: **DO NOT FREEZE**. Return to prior phase to complete.

### Step 2: Create Evidence Pack Manifest

File: `.specs/changes/<id>/_validate/manifest.md`

```markdown
---
artifact_type: evidence_pack_manifest
change_id: wave-3-design
validation_run_id: validation-run-20260628-002
frozen_at: 2026-06-28T15:00:00Z
frozen_by: altitude-validation
---

# Evidence Pack Manifest

**Validation Run**: validation-run-20260628-002  
**Frozen**: 2026-06-28T15:00:00Z  
**Change**: wave-3-design  

## Contents

### Design Artifacts
- ✅ PRD (prd.md) — 150 lines, status: ready
- ✅ ADR (adr.md) — 80 lines, status: ready
- ✅ TEST-SPEC (test-spec.md) — 120 lines, status: ready

### Planning Artifacts
- ✅ task-spec-001.md (Junta Architecture) — 45 lines
- ✅ task-spec-002.md (Prompt Creation) — 50 lines
- ✅ task-spec-003.md (Agent Update) — 40 lines

### Execution Artifacts
- ✅ 04-execution-ledger.md — 200 lines, 3 tasks completed
- ✅ Changed files: 12 files modified, 45 files created

### Validation Run
- Run ID: validation-run-20260628-002
- Juntas: requirements, architecture, tests, tasks, council

## Immutability Hash

```
manifest_hash: sha256:xyz789...
all_artifacts_hash: sha256:abc123...
```

This pack is **FROZEN** and immutable.
All juntas will receive identical copies.
```

### Step 3: Freeze and Record

Once frozen:
1. Update `artifact-generation-registry.yaml`:
   ```yaml
   evidence_pack:
     generation_number: 2
     generated_at: 2026-06-28T15:00:00Z
     frozen_at: 2026-06-28T15:00:00Z
     validation_run_id: validation-run-20260628-002
     manifest_hash: sha256:xyz789...
   ```

2. Create immutable backup of all artifacts in `_validate/evidence-backup/`

3. Proceed to junta launches

---

## Evidence Pack Immutability Rule

**CRITICAL**: Once frozen, the evidence pack CANNOT be modified during validation.

### Allowed During Validation
- ❌ Modify any artifact (PRD, ADR, TEST-SPEC, task-spec, ledger)
- ❌ Add new artifacts
- ❌ Rename files
- ❌ Change test results

### If Artifacts Need Fixing
1. **STOP** current validation run
2. Go back to prior phase (Design/Plan or Execution)
3. Fix the artifact(s)
4. **CREATE A NEW VALIDATION RUN** with a new frozen evidence pack
5. Increment `generation_number` and `validation_run_id`

### Example

```
validation-run-20260628-001: FAILED (score 78)
  ├─ evidence pack frozen
  ├─ junta run in progress
  └─ (no changes allowed here)

User: "Let me fix the PRD"
  ├─ go back to Design phase
  ├─ update PRD
  ├─ update artifact-generation-registry
  └─ create NEW validation run

validation-run-20260628-002: PASSED (score 92)
  ├─ NEW evidence pack frozen
  ├─ NEW junta run with updated PRD
  └─ (independent from run #1)
```

---

## Junta Input Specification

Each junta receives an identical copy of:

1. **Evidence Pack Manifest** (plain text, for reference)
2. **Artifact files** (markdown or YAML, exact copies)
3. **Execution evidence** (plain text, exact copy)
4. **File tree snapshot** (list of all changed files)

### Example Junta Input

```
Requirements Junta receives:
  ├─ evidence_pack_manifest.md (frozen, checksum verified)
  ├─ prd.md (frozen, checksum: abc123)
  ├─ all task-spec files (frozen, checksums verified)
  ├─ 04-execution-ledger.md (frozen, checksum: xyz789)
  └─ file_tree.txt (snapshot of all changed files)

Architecture Junta receives:
  ├─ evidence_pack_manifest.md (SAME frozen copy)
  ├─ adr.md (SAME frozen copy)
  ├─ all task-spec files (SAME frozen copy)
  ├─ file_tree.txt (SAME frozen snapshot)
  └─ 04-execution-ledger.md (SAME frozen copy)

(And so on for all juntas)
```

---

## Validation Run Lifecycle

### Pre-Freeze

```
Artifacts created/updated
  ↓
Coordinator checks readiness (each artifact against checklist)
  ↓
All pass? → proceed to freeze
          → NO? return to prior phase
```

### Freeze

```
Create evidence pack manifest
  ↓
Compute checksums of all artifacts
  ↓
Record in artifact-generation-registry.yaml
  ↓
Create immutable backup
  ↓
evidence pack is FROZEN
```

### Validation (Immutable)

```
Launch junta 1 (receives frozen pack)
  ├─ cannot modify artifacts
  └─ reads only
  
Launch junta 2 (receives SAME frozen pack)
  ├─ cannot modify artifacts
  └─ reads only
  
(All juntas see identical data)
```

### Post-Validation

```
If score >= 90 and 0 CRITICAL:
  → Move to Ship phase
  
If score < 90 or CRITICAL found:
  → Go back to Design/Plan or Execution
  → Fix artifacts
  → CREATE NEW validation run (new frozen pack)
  → Re-validate
```

---

## Artifact Readiness Criteria

### PRD Readiness

```
"Ready" = all sections complete, no placeholders, testable

For PRD to be ready:
- Every acceptance criterion is specific (not vague)
- Every criterion links to at least one test case
- User personas are named, not generic
- Success metrics are quantified where possible
- Constraints are explicit
- Non-goals are listed (prevent scope creep)
- Review: "Could a QA engineer write tests from this?" → YES
```

### ADR Readiness

```
"Ready" = decision is locked, alternatives documented

For ADR to be ready:
- Decision statement is one sentence
- At least 2 alternatives are listed
- Each alternative has trade-off analysis
- Chosen alternative has clear justification
- Rollback/reversal plan is documented
- Review: "Is this architecture locked?" → YES
```

### TEST-SPEC Readiness

```
"Ready" = test cases are specific, outcomes expected

For TEST-SPEC to be ready:
- Every test case has: setup, action, expected outcome
- Edge cases are included (not just happy path)
- Test data is specified (not vague)
- Regression scenarios are listed
- Fixtures are referenced or data provided
- Review: "Could a tester execute this without asking questions?" → YES
```

### task-spec Readiness

```
"Ready" = task can be executed independently

For task-spec to be ready:
- Goal is one sentence, clear
- Allowed files are explicit (not "fix stuff")
- Forbidden files are explicit (safety boundary)
- Acceptance criteria are measurable
- Predecessor tasks (blocked by) are listed
- Successor tasks (blocks) are listed
- Estimate is in hours or days
- Review: "Could someone execute this task without design questions?" → YES
```

### Execution Ledger Readiness

```
"Ready" = execution is complete, evidence collected

For execution ledger to be ready:
- All planned tasks are marked: completed or failed
- Completed tasks have evidence (test results, PR link, etc.)
- Failed tasks have root cause notes
- Changed files list is complete (git diff)
- Test results are present
- Manual checks are documented with dates
- Review: "Is this ready to validate?" → YES
```

---

## Freeze Gates

### Mandatory Checks Before Freeze

```
Evidence Pack Freeze Gate:

1. Artifact Count Check
   [ ] Expected number of artifacts present
   [ ] No duplicate artifact slugs

2. Artifact Completeness
   [ ] All artifacts pass readiness criteria (above)
   [ ] No placeholders or TODOs
   [ ] All cross-references valid

3. Checksum Verification
   [ ] Compute SHA256 for all artifacts
   [ ] Store checksums in manifest
   [ ] Verify readable (no corruption)

4. Manifest Creation
   [ ] manifest.md created
   [ ] All artifacts listed
   [ ] Frozen timestamp recorded

5. Registry Update
   [ ] artifact-generation-registry.yaml updated
   [ ] generation_number incremented
   [ ] validation_run_id unique

6. Immutability Enforcement
   [ ] Manifest is read-only (chmod 444)
   [ ] Backup created in _validate/evidence-backup/
   [ ] Backup is read-only
```

If any check fails: **DO NOT PROCEED**. Fix and re-check.

---

## Source Authority

- Grounded in validation best practices
- Prevents data drift during junta runs
- Ensures all juntas see identical input
- Enables audit trail (checksums + timestamps)
- Supports re-validation (new frozen pack)

---

## Exit Criteria

This contract is complete when:

- ✅ Evidence pack definition is precise
- ✅ Freeze process is step-by-step
- ✅ Immutability rule is enforced
- ✅ Junta input specification is identical for all
- ✅ Artifact readiness criteria are testable
- ✅ Freeze gates are mandatory
- ✅ Lifecycle is clear (pre, freeze, validate, post)
