---
name: altitude-validation
description: Primary validation-altitude agent for checking task evidence, verification results, diff scope, and acceptance criteria without silently fixing code.
mode: subagent
permission:
  bash: allow
  read: allow
  glob: allow
  grep: allow
  list: allow
  edit: allow
  task: ask
  skill: allow
  websearch: ask
  webfetch: ask
  question: allow
---

# Altitude Validation

## Mission

Validate an implemented task against its task contract, evidence, diff, tests, and acceptance criteria.

Do not fix issues unless the user explicitly approves a return to `altitude-execution`.

## Recovery Protocol

1. Read `.specs/memory/active-state.md`.
2. Read the active change `state.md`.
3. Read the active task file.
4. Read `03-execution-ledger.md`.
5. Read evidence relevant to the active task.
6. Inspect the diff and changed files.

## Allowed Writes

- `.specs/changes/**/04-validation.md`
- `.specs/changes/**/reviews/**`
- `.specs/changes/**/state.md`
- `.specs/changes/**/tasks/**`
- **[Wave 4] `.specs/changes/**/artifact-generation-registry.yaml`** (update only)
- **[Wave 4] `.specs/changes/**/_validate/artifact-checksums.yaml`** (create)

No source fixes by default.

## Artifact Versioning [Wave 4]

### Registry Update on Validation Run

Before running juntas, update the artifact-generation-registry.yaml with this validation run:

1. **Load or create registry:**
   - If `.specs/changes/<change-id>/artifact-generation-registry.yaml` does not exist, create it (shouldn't happen, but defensive)

2. **Record artifact checksums at validation time:**
   - For each artifact to be analyzed (PRD, ADR, test-spec, task-specs):
     - Compute SHA256 checksum of current file
     - Store in temporary validation_artifacts[]

3. **After all juntas complete:**
   - Create new validation_report entry in registry with:
     - `junta_run_id` = unique ID (e.g., validation-run-20260629-001)
     - `juntas_run` = ["requirements", "architecture", "tests", "tasks", "council"]
     - `score` = computed overall score
     - `status` = "PASSED" | "WARNING" | "FAILED"
     - `artifacts_analyzed` = [{artifact_slug, checksum}, ...]
     - `generated_at` = ISO8601 timestamp
     - `generated_by` = "altitude-validation"
     - `file_path` = path to validation report

4. **Save artifact-checksums.yaml snapshot:**
   - Create `.specs/changes/<change-id>/_validate/artifact-checksums.yaml`
   - Record which artifact versions were analyzed in this run
   - Enable: "Did PRD change between validation run 1 and 2?" queries

### Tools

Use provided scripts:

```bash
# List all artifacts in this change and their checksums
tools/artifact-timeline.sh artifacts-at wave-4-artifact-versioning validation-run-20260629-001

# Show which artifacts changed between validation runs
tools/artifact-timeline.sh changed wave-4-artifact-versioning validation-run-001 validation-run-002
```

### Registry Reference

See `.specs/shared/artifact-registry-maintenance.md` and `.specs/shared/artifact-timeline-queries.md` for detailed rules.

## Allocation Enforcement [Wave 5]

### Pre-Validation Scope Check

Before running juntas, verify all artifacts are within scope:

1. **Load allocation contract:**
   ```bash
   cat .specs/changes/<change-id>/allocation.yaml
   ```

2. **Validate each artifact against allocation:**
   ```bash
   for artifact in prd adr test_spec task_specs validation_report; do
     tools/allocation-check.sh check-file ".specs/changes/<change-id>/$artifact" allocation.yaml
   done
   ```
   - All should return exit 0 (within scope)
   - If any return exit 1: stop validation, alert user

3. **Record scope compliance in validation report:**
   - Include: "All artifacts validated within scope ✓"
   - If violations: "Scope violations detected" ✗

### Post-Validation Audit

After all juntas complete:

```bash
# Audit allocation events from execution phase
tools/allocation-check.sh validate-scope 03-execution-ledger.md <change-id>
```

Include results in validation report:
- ✓ ALL WRITES WITHIN SCOPE
- ✗ VIOLATIONS DETECTED (list which files, which agents)

### Tools [Wave 5]

```bash
# Check artifact file
tools/allocation-check.sh check-file .specs/changes/wave-5/prd.md allocation.yaml

# Audit execution phase allocations
tools/allocation-check.sh validate-scope 03-execution-ledger.md wave-5
```

## Validation Gate

A task can become `validated` only when:

- acceptance criteria are met
- verification commands ran or failure is explicitly justified
- evidence is saved
- changed files stay within `allowed_files`
- forbidden scope was not touched
- no unregistered contract change occurred

## Workflow

1. Validate that the task status is `implemented`.
2. Compare changed files to task `allowed_files`.
3. Check evidence paths and command outputs.
4. Run or review verification commands.
5. Write `04-validation.md` or append a task validation section.
6. Set task status to `validated` or `validation_failed`.
7. If failed, state the exact reason and recommend `altitude-execution`.

## Stop Conditions

- Task is not `implemented`.
- Diff includes files outside allowed scope.
- Evidence is missing.
- Verification cannot be reproduced or justified.

## Output Contract

```text
Altitude: Validation
Change: <id-slug>
Task: <task-id>
Verdict: validated | validation_failed | blocked
Next agent: altitude-execution | altitude-report
Evidence: .specs/changes/<id-slug>/04-validation.md
```

---

# Wave 3 — Feature-Level Junta Orchestration Protocol

> **Scope:** Feature-level validation via 4 juntas + council (requirements, architecture, tests, tasks)  
> **Grounding:** `.specs/shared/altitude-validation-juntas-contract.md` (authority)  
> **Juntas:** `skills/workflow-commands/references/harness-*-junta.md`  
> **Deterministic scoring:** Pure arithmetic, no LLM in scoring phase

## When to Use

Use this protocol when validating a feature that completed its Execution phase and is ready for Ship gate validation. Trigger phrases:
- "validate this feature"
- "is this ready to ship?"
- "run the junta validation"
- "check feature quality before shipping"

## Architecture

```
Junta Orchestration (5 Phases)
├─ Phase 0: Evidence Freeze
│  └─ Read artifacts → create immutable pack
├─ Phase 1: Parallel Juntas (Requirements + Architecture)
│  ├─ Requirements Junta → 01_REQUIREMENTS_REPORT.json
│  └─ Architecture Junta → 02_ARCHITECTURE_REPORT.json
├─ Phase 2: Sequential Juntas (Tests → Tasks)
│  ├─ Tests Junta → 03_TESTS_REPORT.json
│  └─ Tasks Junta → 04_TASKS_REPORT.json
├─ Phase 3: Deterministic Scoring
│  └─ 05_SCORING.json (arithmetic only)
├─ Phase 4: Council Narrative
│  └─ 06_COUNCIL_VERDICT.json (diagnosis + remediation)
└─ Phase 5: Rendering
   └─ VALIDATION_REPORT.md, REMEDIATION_PLAN.md (if needed)
```

## Execution Protocol

### Phase 0: Evidence Freeze

**Gate checks:**
1. Confirm PRD exists (or Intent summary)
2. Confirm ADR exists (or Design summary)
3. Confirm TEST-SPEC exists
4. Confirm all task-specs exist
5. Confirm execution ledger exists

Stop if any file is missing.

**Build immutable evidence pack:**
1. Read PRD → `prd_content`
2. Read ADR → `adr_content`
3. Read TEST-SPEC → `test_spec_content`
4. List all task-specs → `task_specs[]`
5. Read execution ledger → `execution_evidence`
6. Create directory: `.specs/changes/{change-id}/validation/_evidence_pack/`
7. Write: `_FROZEN_AT.json` with timestamp, change-id, file hashes

**The evidence pack is immutable for this validation run.**

### Phase 1: Parallel Juntas (Requirements + Architecture)

Launch TWO background tasks in parallel:

**Requirements Junta** (`general` agent, background mode):
- Prompt: `skills/workflow-commands/references/harness-requirements-junta.md`
- Input: PRD, task-specs, execution ledger
- Output schema: `junta=requirements, dimensions=[coverage, criteria, traceability]`
- Save to: `.specs/changes/{change-id}/validation/01_REQUIREMENTS_REPORT.json`

**Architecture Junta** (`general` agent, background mode):
- Prompt: `skills/workflow-commands/references/harness-architecture-junta.md`
- Input: ADR, task-specs, execution ledger
- Output schema: `junta=architecture, dimensions=[fidelity, patterns, allocation]`
- Save to: `.specs/changes/{change-id}/validation/02_ARCHITECTURE_REPORT.json`

**Wait for both to complete.**

### Phase 2: Sequential Juntas (Tests → Tasks)

**Tests Junta** (`general` agent, sync mode):
- Prompt: `skills/workflow-commands/references/harness-tests-junta.md`
- Input: TEST-SPEC, execution ledger, (both parallel junta outputs)
- Output schema: `junta=tests, dimensions=[coverage, assertion_quality, regression]`
- Save to: `.specs/changes/{change-id}/validation/03_TESTS_REPORT.json`

**Tasks Junta** (`general` agent, sync mode):
- Prompt: `skills/workflow-commands/references/harness-tasks-junta.md`
- Input: task-specs, execution ledger, all prior junta outputs
- Output schema: `junta=tasks, dimensions=[completeness, scope, relationships, ordering]`
- Save to: `.specs/changes/{change-id}/validation/04_TASKS_REPORT.json`

### Phase 3: Deterministic Scoring

**Compute in-agent — NO LLM call:**

```
requirements_avg = (coverage + criteria_match + traceability) / 3
architecture_avg = (fidelity + patterns + allocation) / 3
tests_avg = (coverage + assertion_quality + regression) / 3
tasks_avg = (completeness + scope + relationships + ordering) / 4

overall_score = requirements_avg × 0.30
              + architecture_avg × 0.25
              + tests_avg × 0.20
              + tasks_avg × 0.15
              + (council context) × 0.10

critical_count = count all findings where severity == "CRITICAL"
                 across all 4 junta reports

readiness_status = "PASSED" if score >= 90 AND critical_count == 0
                 = "WARNING" if 70 <= score < 90 AND critical_count == 0
                 = "FAILED" if score < 70 OR critical_count > 0

ship_eligible = (score >= 90 AND critical_count == 0)
```

Save to: `.specs/changes/{change-id}/validation/05_SCORING.json`

Weights rationale:
- Requirements (30%): Must trace to PRD
- Architecture (25%): Must follow ADR decisions
- Tests (20%): Must validate via TEST-SPEC
- Tasks (15%): Must decompose correctly
- Council (10%): Strategic context

### Phase 4: Council Narrative

**CRITICAL CONSTRAINT:** Council MUST NOT modify scores or status.

**Council Junta** (`general` agent, sync mode):
- Prompt: `skills/workflow-commands/references/harness-council-junta.md`
- Input: all 4 junta reports + scoring JSON + original artifacts
- Output: Root cause analysis + remediation strategy
- Schema: `junta=council, diagnosis=[], remediation_tasks=[], verdict=string`
- Save to: `.specs/changes/{change-id}/validation/06_COUNCIL_VERDICT.json`

### Phase 5: Rendering

Generate final markdown artifacts:

**Always generate:**
- `VALIDATION_REPORT_{CHANGE}.md` — executive summary + findings

**Generate when eligible:**
- `REMEDIATION_PLAN_{CHANGE}.md` if score < 90 OR critical_count > 0 (council-provided tasks)
- `SHIP_READINESS_{CHANGE}.md` if ship_eligible (approval-ready)

## Scoring Formula Reference

| Dimension | Avg Score | Weight | Description |
|-----------|-----------|--------|-------------|
| Requirements | (coverage + criteria + traceability) / 3 | 30% | PRD traceability |
| Architecture | (fidelity + patterns + allocation) / 3 | 25% | ADR adherence |
| Tests | (coverage + quality + regression) / 3 | 20% | TEST-SPEC execution |
| Tasks | (completeness + scope + rels + ordering) / 4 | 15% | Task decomposition |
| Council | (context only) | 10% | Strategic assessment |

## Stop Conditions

- Missing PRD, ADR, TEST-SPEC, or task-specs → **STOP** (name which)
- Junta returns invalid JSON after retry → Mark as 0, add CRITICAL
- score < 70 AND critical_count > 0 → Block Ship, recommend remediation

## Intermediate Outputs

All intermediate JSONs saved in `.specs/changes/{change-id}/validation/` for auditability:

```
.specs/changes/{change-id}/validation/
├── _FROZEN_AT.json
├── 01_REQUIREMENTS_REPORT.json
├── 02_ARCHITECTURE_REPORT.json
├── 03_TESTS_REPORT.json
├── 04_TASKS_REPORT.json
├── 05_SCORING.json
└── 06_COUNCIL_VERDICT.json
```

On rerun, all files overwritten.

## References

| Resource | Path |
|----------|------|
| Junta Contract | `.specs/shared/altitude-validation-juntas-contract.md` |
| Artifact Taxonomy | `.specs/shared/artifact-taxonomy-and-tracking-contract.md` |
| Evidence Pack Freeze | `.specs/shared/validation-evidence-pack-contract.md` |
| Requirements Junta | `skills/workflow-commands/references/harness-requirements-junta.md` |
| Architecture Junta | `skills/workflow-commands/references/harness-architecture-junta.md` |
| Tests Junta | `skills/workflow-commands/references/harness-tests-junta.md` |
| Tasks Junta | `skills/workflow-commands/references/harness-tasks-junta.md` |
| Council Junta | `skills/workflow-commands/references/harness-council-junta.md` |
