# Harness V3 Phase Engine Spec

## Purpose

Define phase semantics, human gates, artifact outputs, and movement rules for durable Harness V3 work.

This document is the shareable phase authority. The operational contract loaded by agents is
`.specs/shared/phase-engine-contract.md`.

Legacy `workflow:*` commands and `sdd/architecture/WORKFLOW_CONTRACTS.yaml` remain migration references.
They do not own Harness V3 phase state.

## Phase Model

```text
Intent
  -> Structure
  -> Design/Plan
  -> Execution
  -> Validate
  -> Ship
```

## Phase Responsibilities

| Phase | Purpose | Required evidence |
| --- | --- | --- |
| Intent | define problem, goals, constraints, non-goals | intent artifact or accepted summary |
| Structure | map repo/modules/contracts/risks | structure artifact |
| Design/Plan | define requirements, architecture, task packs, validation | PRD/ADR/TEST-SPEC/task pack as needed |
| Execution | execute one approved task or task batch | ledger entry and changed files |
| Validate | verify acceptance, tests, evidence | validation report |
| Ship | summarize delivered boundary and risks | ship note |

## Legacy Workflow Absorption

Harness V3 preserves the useful behavior of the old workflow lifecycle without allowing that lifecycle to become a second phase authority.

| Legacy workflow phase | Harness V3 owner | Preserved behavior | Not preserved as authority |
| --- | --- | --- | --- |
| Brainstorm | Intent | exploration, assumptions, approaches, scope shaping | independent phase state |
| Define | Intent / Design-Plan | requirements, users, goals, acceptance criteria, assumptions | standalone command-owned requirements authority |
| Design | Structure / Design-Plan | architecture, decisions, file manifest, test strategy | build permission by design file alone |
| Build | Execution | implementation from an approved task, evidence, verification loop | on-the-fly task invention during execution |
| Validate | Validate | acceptance checks, evidence, score/risk report, runbook/roadmap decision | score-only ship authority |
| Ship | Ship | archive, lessons, final state, residual risk | unilateral closure without Harness V3 state update |
| Iterate | Intent / Design-Plan / Execution repair | controlled change propagation | implicit downstream mutation without gate |

Compatibility rule:

```text
workflow command invoked
  -> classify as compatibility wrapper
  -> resolve Harness V3 state
  -> load phase-engine-contract
  -> preserve useful workflow behavior
  -> update `.specs/changes/...` state when durable work is involved
```

## Human Gates

| Transition | Gate |
| --- | --- |
| Intent -> Structure | user confirms problem and scope |
| Structure -> Design/Plan | user confirms architecture surface and constraints |
| Design/Plan -> Execution | user selects task or batch |
| Execution -> Validate | automatic after execution unless blocked |
| Validate -> Ship | allowed after acceptance passes or gaps are explicit |
| Ship -> next wave | user confirms continuation or new change opens |

## Artifact Selection

Use PRD when behavior, workflow, requirements, stakeholders, or acceptance criteria matter.

Use ADR when architecture, alternatives, trade-offs, or future maintainability matter.

Use TEST-SPEC when correctness depends on explicit validation, regression cases, fixtures, data integrity, permissions, migration behavior, or evidence.

## Artifact Mapping

Harness V3 artifact families intentionally replace the old workflow-only artifact set.

| Legacy artifact | V3 artifact family | Rule |
| --- | --- | --- |
| `BRAINSTORM_*` | Intent summary or PRD notes | optional; use when ambiguity needs exploration |
| `DEFINE_*` | PRD | use when requirements, users, goals, or acceptance criteria matter |
| `DESIGN_*` | ADR + TEST-SPEC + task pack | split architecture decisions from validation and execution |
| `BUILD_REPORT_*` | execution ledger | record exact task execution and changed files |
| `VALIDATION_REPORT_*` | validation report | preserve evidence and verdict |
| `RUNBOOK_*` | ship note or operations section | use only when operations guidance is needed |
| `ROADMAP_*` | next-wave plan | use when validation creates follow-up work |
| `SHIPPED_*` | ship summary | close the change with evidence, residual risk, and next recommendation |

## Phase Movement Rules

- A coordinator may recommend phase movement.
- A coordinator must not silently advance human-gated phase transitions.
- Machine state must be updated when phase movement is accepted.
- Validation can move to Ship only when acceptance criteria are passed or residual risks are recorded.
- Execution must not begin without a ready task or user-approved task batch.
- Execution must not create broad new scope to compensate for missing design.
- Validation must cite commands, artifacts, or manual checks that actually ran.
- Ship must update the active state and recommend the next valid wave or stop point.

## Invalid Phase States

| Invalid state | Repair |
| --- | --- |
| Execution without ready task | return to Design/Plan |
| Validate without evidence | create evidence or mark blocked |
| Ship with failed acceptance | block or record accepted risk explicitly |
| active task outside active change | repair active state |

## Compatibility With Workflow Commands

`workflow:*` commands may still trigger phase behavior, but they do not own the phase model. They must route through this contract or be treated as legacy compatibility behavior.

## Exit Criteria For This Contract

The phase engine is acceptable only when:

- one phase contract exists and is loaded through `config/grounding.md`
- old workflow phase semantics are mapped to V3 phases
- human gates are explicit
- invalid phase states are named
- artifact families cover PRD, ADR, TEST-SPEC, validation report, and ship summary
- workflow runtime is a migration reference, not the authority
- fixtures preserve expected behavior before command or runtime removal
