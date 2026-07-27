# Harness 360 Refactor - Decomposition

## Task Sequence

| Order | Task | Status | Dependencies |
| --- | --- | --- | --- |
| 1 | T-001 - bootstrap ledger and freeze target operating model | validated | none |
| 2 | T-002 - define central MCP governance matrix | validated | T-001 |
| 3 | T-003 - design decomposition engine and SDD vs Task-Spec matrix | validated | T-001 |
| 4 | T-004A - replace canonical `knowledge_context/` policy references with `.specs/memory` | validated | T-003 |
| 5 | T-004B - rewrite workflow brainstorm and legacy knowledge-context surfaces | pending | T-004A |
| 6 | T-005A - remove generic natural-language workflow-phase routes | validated | T-003 |
| 7 | T-005B - rewrite workflow build surfaces to stop late task invention | pending | T-005A,T-003 |
| 8 | T-006A - define the KB governance standard | validated | T-002 |
| 9 | T-006B - repair Fabric contradictions and golden-domain metadata | validated | T-006A |
| 10 | T-006B1 - repair Fabric Copilot capacity contradiction and align entry points | validated | T-006A |
| 11 | T-006B2 - add Fabric governance metadata and critical-claim register | validated | T-006B1 |
| 12 | T-006B3 - audit remaining Fabric high-impact claims for quick-reference parity | validated | T-006B2 |
| 13 | T-007A - define the Markdown authoring standard | validated | none |
| 14 | T-007B - upgrade `.specs` templates for density and architecture views | validated | T-007A |
| 15 | T-007C - upgrade `sdd` templates for denser architectural artifacts | validated | T-007A |
| 16 | T-007D - upgrade Markdown-producing skill guidance | validated | T-007A |
| 17 | T-009A - repair Fabric Eventhouse for Warehouse parity gap | ready | T-006B3 |

## Decomposition Rules

- one deliverable per leaf task
- maximum three non-ledger files touched per leaf task
- small vertical slice preferred over broad horizontal changes
- if a task cannot become small, reversible, and verifiable, escalate back to planning
- `Task-Spec` is for S/M effort leaves; broader changes remain richer `Altitude` tasks

## Validation Plan

- every completed task must update `03-execution-ledger.md`
- every completed task must leave evidence under `evidence/`
- every validated task must update `04-validation.md`
- no execution proceeds without full task contract coverage

## Rollback Approach

- documentation tasks roll back by removing the newly introduced doc and reverting ledger state
- policy and config tasks must name explicit rollback files in their task contracts

## Ready Queue

- `T-009A` is ready for execution.
- `T-005B` still needs planning refinement if the workflow-build rewrite remains too broad.
