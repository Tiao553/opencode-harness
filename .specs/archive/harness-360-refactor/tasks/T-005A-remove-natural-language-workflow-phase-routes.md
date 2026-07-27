# Task

task_id: T-005A
title: Remove generic workflow-phase natural-language routes
status: validated
change: harness-360-refactor
owner_agent: altitude-execution

## Objective

Remove the generic natural-language workflow-phase routes that currently bypass the command-first workflow policy.

## Context

The harness policy says workflow phases should start from native commands, but `config/routing.json` still contains generic routes such as `brainstorm`, `define`, `design`, `build`, `validate`, and `ship`.

## Source References

- `AGENTS.md`
- `skills/workflow-commands/SKILL.md`
- `config/routing.json`
- `docs/HARNESS_TARGET_OPERATING_MODEL.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `.specs/changes/harness-360-refactor/02-decomposition.md`

## Allowed Files

- `config/routing.json`
- `AGENTS.md`
- `skills/workflow-commands/SKILL.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `.specs/changes/harness-360-refactor/02-decomposition.md`
- `.specs/changes/harness-360-refactor/03-execution-ledger.md`
- `.specs/changes/harness-360-refactor/04-validation.md`
- `.specs/changes/harness-360-refactor/state.md`
- `.specs/changes/harness-360-refactor/tasks/T-005A-remove-natural-language-workflow-phase-routes.md`
- `.specs/memory/active-state.md`

## Forbidden Scope

- `skills/workflow-commands/commands/build.md`
- `agents/workflow.build-agent.agent.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- `opencode.json`

## Dependencies

- T-003

## Implementation Steps

1. Remove or narrow the generic workflow-phase routes from `config/routing.json`.
2. Align the policy wording in `AGENTS.md` and `skills/workflow-commands/SKILL.md`.
3. Update the ledger and validation notes.

## Acceptance Criteria

- generic workflow-phase routes no longer bypass command-first policy
- `AGENTS.md` and `skills/workflow-commands/SKILL.md` remain aligned with routing behavior
- explicit native commands still remain the supported workflow path

## Verification Commands

- inspect `config/routing.json` for removed or narrowed generic workflow-phase triggers
- confirm policy wording remains aligned in `AGENTS.md` and `skills/workflow-commands/SKILL.md`

## Evidence Required

- updated routing policy files
- updated execution ledger and validation notes

## Rollback

Restore the removed route entries if the narrowed routing unexpectedly breaks required compatibility.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Verification completed or justified
- [x] Evidence saved
- [x] Execution ledger updated
- [x] Ready for validation
