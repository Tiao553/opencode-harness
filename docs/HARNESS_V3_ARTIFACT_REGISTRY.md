# Harness V3 Artifact Registry

## Purpose

Define artifact ownership, role, lifecycle, and source-of-truth boundaries for Harness V3.

## Registry

| Artifact | Location | Owner | Role |
| --- | --- | --- | --- |
| active state | `.specs/memory/active-state.md` | coordinator | current durable resume point |
| change state | `.specs/changes/{change}/state.md` | coordinator | phase/status for one change |
| intent | `.specs/changes/{change}/00-intent.md` | Altitude | problem and scope |
| structure | `.specs/changes/{change}/01-structure.md` | Altitude | repo and risk map |
| decomposition | `.specs/changes/{change}/02-decomposition.md` | Altitude plan | task order and dependencies |
| execution ledger | `.specs/changes/{change}/03-execution-ledger.md` | executor | append-only execution log |
| validation ledger | `.specs/changes/{change}/04-validation.md` | validator | validation record |
| executive report | `.specs/changes/{change}/05-executive-report.md` | reporter | stakeholder summary |
| ship note | `.specs/changes/{change}/06-ship-note.md` | reporter | shipped boundary and residual risk |
| task contract | `.specs/changes/{change}/tasks/T-*.md` | planner | executable leaf task |
| evidence | `.specs/changes/{change}/evidence/E-*.md` | executor/validator | proof of work |
| PRD | `.specs/changes/{change}/prd.md` or task-local | product/plan | requirements and acceptance |
| ADR | `.specs/changes/{change}/decisions/ADR-*.md` | architect | technical decision |
| TEST-SPEC | `.specs/changes/{change}/test-spec.md` or task-local | validator | validation matrix |
| docs mirror | `docs/*.md` | reporter/maintainer | shareable durable explanation |
| shared policy contract | `.specs/shared/*.md` | coordinator | operational policy source |

## Source-of-Truth Boundaries

- `.specs/changes` owns operational state.
- `docs` mirrors or explains architecture; it does not override active state.
- KB files own domain guidance only after freshness and contradiction checks pass.
- Memory helps resume; it does not outrank current user instruction or active task contracts.

## Artifact Quality Bar

Durable artifacts should include:

- purpose
- source references
- architecture-as-text when system behavior matters
- decisions and trade-offs
- validation requirements
- residual risks
- next action

## Drift Rules

When artifacts conflict:

1. use the state resolution contract
2. prefer current task/change state for execution
3. update mirrors after operational artifacts are correct
4. record material repairs in the ledger
