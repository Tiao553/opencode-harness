# Task

task_id: T-001
title: Freeze target operating model
status: validated
change: harness-360-refactor
owner_agent: altitude-execution

## Objective

Create the first versioned operating-model document and bootstrap the harness refactor ledger so later refactors have a fixed target.

## Context

The harness needed a stable design freeze before editing routing, plugins, and KB surfaces.

## Source References

- `AGENTS.md`
- `docs/ALTITUDE_SPECS_HARNESS.md`
- `.specs/shared/altitude-contract.md`
- `.specs/shared/change-request-contract.md`
- `.specs/shared/task-contract.md`
- `skills/workflow-commands/SKILL.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`

## Allowed Files

- `docs/HARNESS_TARGET_OPERATING_MODEL.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `.specs/changes/harness-360-refactor/00-intent.md`
- `.specs/changes/harness-360-refactor/01-structure.md`
- `.specs/changes/harness-360-refactor/02-decomposition.md`
- `.specs/changes/harness-360-refactor/03-execution-ledger.md`
- `.specs/changes/harness-360-refactor/04-validation.md`
- `.specs/changes/harness-360-refactor/state.md`
- `.specs/memory/active-state.md`

## Forbidden Scope

- `config/routing.json`
- `opencode.json`
- `plugins/*.ts`
- `agents/*.agent.md`
- `skills/**`

## Dependencies

- none

## Implementation Steps

1. Create the live change ledger.
2. Write the master plan mirror.
3. Write the target operating model design freeze.
4. Update ledger state and validation notes.

## Acceptance Criteria

- a live change ledger exists under `.specs/changes/harness-360-refactor/`
- the master plan exists and records locked decisions and active tasks
- the operating model exists and freezes coordinator, state, intake, decomposition, and execution boundaries

## Verification Commands

- manual cross-check against the listed source references

## Evidence Required

- `docs/HARNESS_TARGET_OPERATING_MODEL.md`
- `.specs/changes/harness-360-refactor/03-execution-ledger.md`
- `.specs/changes/harness-360-refactor/04-validation.md`

## Rollback

Delete the newly created design docs and reset the change ledger if the model is found to be directionally wrong.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Verification completed or justified
- [x] Evidence saved
- [x] Execution ledger updated
- [x] Ready for validation
