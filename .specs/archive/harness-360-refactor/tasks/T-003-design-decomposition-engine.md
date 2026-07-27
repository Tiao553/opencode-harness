# Task

task_id: T-003
title: Design decomposition engine and SDD vs Task-Spec matrix
status: validated
change: harness-360-refactor
owner_agent: altitude-execution

## Objective

Freeze the decomposition engine so execution no longer depends on late build-time chunk generation.

## Context

The harness currently wants smaller tasks but still relies on build-time task invention in the workflow path. This task defines the durable decomposition rules and the effort-based SDD vs Task-Spec matrix.

## Source References

- `.specs/shared/task-contract.md`
- `.specs/shared/definition-of-done.md`
- `.specs/shared/acceptance-criteria.md`
- `agents/altitude-plan.agent.md`
- `skills/workflow-commands/commands/build.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- `docs/HARNESS_TARGET_OPERATING_MODEL.md`

## Allowed Files

- `docs/HARNESS_DECOMPOSITION_MODEL.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `.specs/changes/harness-360-refactor/02-decomposition.md`
- `.specs/changes/harness-360-refactor/03-execution-ledger.md`
- `.specs/changes/harness-360-refactor/04-validation.md`
- `.specs/changes/harness-360-refactor/state.md`
- `.specs/changes/harness-360-refactor/tasks/T-003-design-decomposition-engine.md`

## Forbidden Scope

- `config/routing.json`
- `plugins/*.ts`
- `opencode.json`
- `kb/**`

## Dependencies

- T-001

## Implementation Steps

1. Define the effort-based selection matrix for `SDD` vs `Task-Spec`.
2. Define the leaf-task size rule and exceptions.
3. Define the decomposition failure escalation rule.
4. Update the master plan and ledger.

## Acceptance Criteria

- the decomposition engine doc exists
- the SDD vs Task-Spec selection matrix is explicit
- the three-file non-ledger rule is documented
- the escalation rule is explicit when decomposition fails

## Verification Commands

- manual cross-check against the listed source references

## Evidence Required

- `docs/HARNESS_DECOMPOSITION_MODEL.md`
- `.specs/changes/harness-360-refactor/03-execution-ledger.md`
- `.specs/changes/harness-360-refactor/04-validation.md`

## Rollback

Remove the decomposition model doc and restore the task state if the matrix or size rule is wrong.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Verification completed or justified
- [x] Evidence saved
- [x] Execution ledger updated
- [x] Ready for validation
