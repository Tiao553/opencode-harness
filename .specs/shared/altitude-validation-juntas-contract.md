# Altitude Validation Juntas Contract

## Purpose

Define Harness V3 validation architecture using the proven junta pattern.

This contract specifies:
- How 4 juntas validate across dimensions
- Deterministic scoring formula
- Eligibility gates for Ship/Remediate/Block
- Council role and constraints

---

## Architecture Overview

```
Phase 0: EVIDENCE PACK FREEZE
  └─ Create immutable snapshot of PRD, ADR, TEST-SPEC, task-specs, ledger
     (See: validation-evidence-pack-contract.md)

Phase 1: PARALLEL JUNTAS (background tasks)
  ├─ Junta de Requisitos
  │  └─ Validates PRD alignment with tasks + execution
  │     Output: 01_REQUIREMENTS_REPORT.json
  │
  └─ Junta de Arquitetura
     └─ Validates ADR decisions against implementation
        Output: 02_ARCHITECTURE_REPORT.json

Phase 2: SEQUENTIAL JUNTAS (after parallel complete)
  ├─ Junta de Testes
  │  └─ Validates TEST-SPEC coverage + execution evidence
  │     Output: 03_TESTS_REPORT.json
  │
  └─ Junta de Tarefas
     └─ Validates task-spec decomposition + ordering
        Output: 04_TASKS_REPORT.json

Phase 3: DETERMINISTIC SCORING (in-agent arithmetic)
  └─ score = reqs×0.30 + arch×0.25 + tests×0.20 + tasks×0.15 + delivery×0.10
     Output: 05_SCORING.json

Phase 4: COUNCIL NARRATIVE (after scoring)
  └─ Context-aware diagnosis + remediation strategy
     (Narrative only — MUST NOT change scores)
     Output: 06_COUNCIL_VERDICT.json

Phase 5: ARTIFACT RENDERING
  ├─ validation-report.md (always)
  └─ implementation-plan.md (if score < 90 or issues found)
```

---

## Junta Specifications

### Junta 1: Requirements Validation

**Purpose**: Validate PRD requirements are traceable to tasks and execution.

**Input**:
- PRD (or Intent summary if no PRD)
- All task-spec files
- Execution ledger with evidence

**Dimensions**:
| Dimension | Range | Measures |
|-----------|-------|----------|
| `requirements_coverage` | 0-100 | % of PRD requirements traceable to task-spec + execution |
| `acceptance_criteria_match` | 0-100 | % of acceptance criteria validated in execution |
| `requirement_traceability` | 0-100 | Quality of PRD → task-spec → execution links |

**Findings**:
- For each requirement: COVERED | PARTIAL | MISSING
- For each finding: severity (LOW/MEDIUM/HIGH/CRITICAL)

**Scoring**:
```
avg_score = (requirements_coverage + acceptance_criteria_match + requirement_traceability) / 3
```

**Status Rules**:
- PASSED: avg_score >= 90 AND 0 CRITICAL
- WARNING: any score 70-89 OR any HIGH (but 0 CRITICAL)
- FAILED: any score < 70 OR any CRITICAL

**Output**:
```json
{
  "junta": "requirements",
  "timestamp": "ISO8601",
  "requirements_coverage": 85,
  "acceptance_criteria_match": 90,
  "requirement_traceability": 80,
  "avg_score": 85,
  "findings": [
    {
      "requirement": "PRD section reference",
      "status": "COVERED|PARTIAL|MISSING",
      "reason": "explanation",
      "severity": "LOW|MEDIUM|HIGH|CRITICAL"
    }
  ],
  "status": "PASSED|WARNING|FAILED"
}
```

### Junta 2: Architecture Validation

**Purpose**: Validate ADR decisions hold up in implementation.

**Input**:
- ADR (if present)
- All task-spec files
- List of changed files
- Execution ledger

**Dimensions**:
| Dimension | Range | Measures |
|-----------|-------|----------|
| `architecture_fidelity` | 0-100 | Implementation matches ADR decisions |
| `design_pattern_consistency` | 0-100 | Patterns used match DESIGN intent |
| `allocation_respect` | 0-100 | Changes respect file allocation boundaries |

**Findings**:
- Decisions that changed from ADR
- Pattern inconsistencies
- File allocation violations

**Scoring**:
```
avg_score = (architecture_fidelity + design_pattern_consistency + allocation_respect) / 3
```

**Status Rules**:
- PASSED: avg_score >= 90 AND 0 CRITICAL
- WARNING: any score 70-89 OR any HIGH (but 0 CRITICAL)
- FAILED: any score < 70 OR any CRITICAL

**Output**: 02_ARCHITECTURE_REPORT.json (similar schema)

### Junta 3: Test Coverage Validation

**Purpose**: Validate TEST-SPEC coverage is executed.

**Input**:
- TEST-SPEC
- Execution evidence
- Test results
- Changed files

**Dimensions**:
| Dimension | Range | Measures |
|-----------|-------|----------|
| `test_case_coverage` | 0-100 | % of TEST-SPEC test cases with execution evidence |
| `assertion_quality` | 0-100 | Assertions are specific, not vague |
| `regression_coverage` | 0-100 | Regression scenarios from TEST-SPEC covered |

**Findings**:
- Missing test cases
- Weak assertions
- Uncovered regression scenarios

**Scoring**:
```
avg_score = (test_case_coverage + assertion_quality + regression_coverage) / 3
```

**Output**: 03_TESTS_REPORT.json

### Junta 4: Task Decomposition Validation

**Purpose**: Validate task-spec quality and execution order.

**Input**:
- All task-spec files
- Execution ledger
- Changed files
- Task relationships

**Dimensions**:
| Dimension | Range | Measures |
|-----------|-------|----------|
| `task_completeness` | 0-100 | Each task has clear goal, acceptance, verification |
| `scope_adherence` | 0-100 | Tasks respected allowed/forbidden files |
| `task_relationships` | 0-100 | Dependencies between tasks are correct |
| `execution_order_validity` | 0-100 | Execution followed a valid DAG (no cycles) |

**Findings**:
- Incomplete tasks
- Scope violations
- Missing dependencies
- Invalid task ordering

**Scoring**:
```
avg_score = (task_completeness + scope_adherence + task_relationships + execution_order_validity) / 4
```

**Output**: 04_TASKS_REPORT.json

---

## Deterministic Scoring

### Scoring Formula

```
score = (
  req_report.avg_score × 0.30 +
  arch_report.avg_score × 0.25 +
  test_report.avg_score × 0.20 +
  task_report.avg_score × 0.15 +
  delivery_readiness × 0.10
)

Where:
  delivery_readiness = 100 if (no missing files AND no MISSING requirements)
                     = 50 if (some PARTIAL or gaps exist)
                     = 0 if (major files missing OR core reqs MISSING)
```

### Critical Count

```
critical_count = SUM of all findings where severity == "CRITICAL"
                 (across all 4 junta reports)
```

### Overall Status

```
status = "PASSED" if score >= 90 AND critical_count == 0
       = "WARNING" if 70 <= score < 90 AND critical_count == 0
       = "FAILED" otherwise (score < 70 OR critical_count > 0)
```

### Output

```json
{
  "overall_score": 87.5,
  "status": "WARNING",
  "critical_count": 0,
  "dimension_scores": {
    "requirements": 85,
    "architecture": 80,
    "tests": 88,
    "tasks": 90,
    "delivery": 100
  },
  "weights": {
    "requirements": 0.30,
    "architecture": 0.25,
    "tests": 0.20,
    "tasks": 0.15,
    "delivery": 0.10
  },
  "calculation": "85×0.30 + 80×0.25 + 88×0.20 + 90×0.15 + 100×0.10 = 87.5"
}
```

---

## Ship Eligibility Matrix

| Score | CRITICAL | Status | Artifacts | Can Ship? |
|-------|----------|--------|-----------|-----------|
| ≥ 90  | 0        | PASSED | validation_report.md | ✅ Yes |
| 70-89 | 0        | WARNING | validation_report.md + implementation-plan.md | ❌ Remediate first |
| < 70  | Any      | FAILED | validation_report.md + implementation-plan.md | ❌ Remediate first |
| Any   | > 0      | FAILED | validation_report.md + implementation-plan.md | ❌ Fix CRITICAL first |

---

## Council Specification

### Purpose

Synthesize findings into diagnosis and remediation strategy.

### Role

- **The Judge**: Overall quality assessment
- **Root Cause Analyst**: Diagnose WHY failures happened
- **Remediation Planner**: Suggest specific tasks to fix

### Input

- All 4 junta reports (JSON)
- Scoring summary (JSON)
- Original artifacts (PRD, ADR, TEST-SPEC, task-specs)

### CRITICAL CONSTRAINT

**Council MUST NOT**:
- ❌ Change or recalculate scores
- ❌ Modify eligibility flags
- ❌ Override status (PASSED/WARNING/FAILED)
- ❌ Change critical_count

**Council CAN**:
- ✅ Explain scores in narrative
- ✅ Diagnose root causes
- ✅ Suggest remediation tasks
- ✅ Recommend execution sequence

### Output

```json
{
  "junta": "council",
  "timestamp": "ISO8601",
  "executive_summary": "2-3 paragraphs of overall assessment",
  "root_cause_analysis": {
    "requirements": [
      {
        "issue": "description of what failed",
        "root_cause": "why it failed (not just what)",
        "affected_tasks": ["task-id-1", "task-id-2"],
        "dependencies": "relationship to other failures"
      }
    ],
    "architecture": [...],
    "tests": [...],
    "tasks": [...]
  },
  "remediation_strategy": {
    "tasks_to_create": [
      {
        "task_name": "Fix X",
        "scope": "list of files to change",
        "acceptance": "criteria for fix",
        "blocked_by": [],
        "blocks": [],
        "priority": 1
      }
    ],
    "execution_sequence": "DAG or priority order",
    "estimated_effort": "hours or days"
  },
  "production_readiness": "Ready|Requires remediation|Not ready",
  "recommendations": "specific next steps"
}
```

---

## Validation Report Artifact

### Purpose

Document validation result and findings.

### Generated Always (regardless of score)

```markdown
---
artifact_type: validation_report
change_id: <id>
phase: Validation
generated_at: ISO8601
generated_by: altitude-validation
generation_number: N
junta_run_id: validation-run-YYYYMMDD-NNN
---

# Validation Report

## Validation Metadata
- Run ID: validation-run-YYYYMMDD-NNN
- Timestamp: ISO8601
- Change: <id>
- Generation: N (Nth time this change validated)

## Validation Result
- **Score**: XX/100
- **Status**: PASSED | WARNING | FAILED
- **Critical Issues**: 0
- **Can Ship**: YES | NO

## Dimension Scores
| Dimension | Score | Status |
|-----------|-------|--------|
| Requirements | 85 | ⚠️ |
| Architecture | 80 | ⚠️ |
| Tests | 88 | ✅ |
| Tasks | 90 | ✅ |
| Delivery | 100 | ✅ |

## Findings by Severity
[List of all findings grouped by CRITICAL/HIGH/MEDIUM/LOW]

## Council Assessment
[Executive summary + root cause analysis]

## Recommendations
[Next steps based on status]
```

---

## Implementation Plan Artifact

### Purpose

Document remediation strategy when validation doesn't pass.

### Generated When

Score < 90 OR any issues found

### Content

```markdown
---
artifact_type: implementation_plan
change_id: <id>
phase: Validation
generated_at: ISO8601
generated_by: altitude-validation
generation_number: N
triggered_by_validation_run: validation-run-YYYYMMDD-NNN
---

# Implementation Plan

## Trigger
- Validation run: validation-run-YYYYMMDD-NNN
- Score: XX/100
- Status: WARNING | FAILED
- Reason: [what triggered plan creation]

## Root Cause Analysis
[From council verdict — detailed diagnosis]

## Remediation Tasks
[Specific task-spec outlines to fix issues]

## Task Sequencing
[Execution order + dependencies]

## Production Readiness Path
[Steps to get from current state to PASSED]
```

---

## Junta Launch Protocol

### Altitude Validation Agent Responsibilities

1. **Freeze evidence pack** (from validation-evidence-pack-contract.md)
2. **Launch parallel juntas** (requirements + architecture)
   - Pass identical evidence pack
   - Wait for both to complete
3. **Launch sequential juntas** (tests, then tasks)
   - After parallel complete
4. **Compute deterministic scoring** (in-agent)
   - No LLM call in scoring phase
5. **Launch council** (after scoring)
   - Pass all 4 reports + scoring
   - Enforce MUST NOT constraints
6. **Render artifacts** (from templates)
   - validation-report.md (always)
   - implementation-plan.md (if needed)

---

## Source Authority

- **Pattern**: Grounded in workflow:validate junta architecture
- **Contracts**: Extends phase-engine-contract.md + allocation-contract.md
- **Taxonomy**: Uses artifact-taxonomy-and-tracking-contract.md
- **Evidence**: Uses validation-evidence-pack-contract.md

---

## Exit Criteria

This contract is complete when:

- ✅ All 4 juntas defined with clear rubrics
- ✅ Deterministic scoring formula is implemented in-agent
- ✅ Ship eligibility matrix is explicit
- ✅ Council role is advisory (narrative only)
- ✅ validation-report.md and implementation-plan.md schemas defined
- ✅ Junta launch protocol is step-by-step
- ✅ No contradictions with existing contracts
