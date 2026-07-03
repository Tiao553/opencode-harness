# Phase Engine Contract

## Purpose

Define the operational phase authority for Harness V3 durable work.

This contract is loaded by coordinators and compatibility wrappers. Legacy workflow files may provide behavior to preserve, but they do not define current phase state.

## Phase Order

```text
Intent -> Structure -> Design/Plan -> Execution -> Validate -> Ship
```

## Authority

| Item | Authority |
| --- | --- |
| phase order | this contract |
| phase gate validity | this contract |
| active state precedence | `.specs/shared/state-resolution-contract.md` |
| conflict behavior | `.specs/shared/state-conflict-resolution-policy.md` |
| old workflow command behavior | `.specs/shared/compatibility-policy.md` |
| old SDD YAML | migration reference only |

## Gates

- Intent requires accepted problem and scope.
- Structure requires repo/module/risk map.
- Design/Plan requires artifact and task strategy.
- Execution requires ready task or approved batch.
- Validate requires evidence.
- Ship requires accepted residual risk and rollback note.

## Required Phase Evidence

| Phase | Minimum evidence |
| --- | --- |
| Intent | problem, goal, scope, non-goals, constraints |
| Structure | affected surfaces, dependencies, risks, source references |
| Design/Plan | requirements or decisions, task pack, allowed files, forbidden scope, validation commands |
| Execution | ledger entry, changed files, verification attempt |
| Validate | commands/checks run, acceptance verdict, failures or residual risks |
| Ship | summary, evidence links, rollback note, next recommendation |

## Invalid States

- execution without ready task
- validation without evidence
- ship with unresolved failed acceptance
- phase movement that contradicts current user instruction

## Workflow Compatibility Mapping

| `workflow:*` concept | V3 mapping |
| --- | --- |
| brainstorm | Intent exploration |
| define | PRD or Intent requirements |
| design | Structure plus Design/Plan artifacts |
| build | Execution of approved task or approved task batch |
| validate | Validate phase |
| ship | Ship phase |
| iterate | gated repair to the owning phase |

Compatibility wrappers must:

- resolve current V3 state before acting
- avoid creating execution scope without a ready task
- preserve useful legacy artifacts only as evidence or migration references
- update `.specs/changes/...` state for durable work
- defer to current user instruction when it conflicts with legacy command defaults

## Artifact Families

Use these artifact families instead of treating old SDD files as the only source of truth:

- PRD for requirements and acceptance criteria
- ADR for architectural choices
- TEST-SPEC for validation and regression cases
- execution ledger for task execution
- validation report for evidence and verdict
- ship summary for closure and residual risk

## Stop Conditions

Stop and ask or create a repair task when:

- active state contradicts the task contract
- a legacy command attempts to skip a human gate
- a task lacks allowed files, forbidden scope, validation commands, or evidence requirements
- validation fails and no accepted residual-risk path exists
- workflow compatibility would mutate files outside the approved scope
