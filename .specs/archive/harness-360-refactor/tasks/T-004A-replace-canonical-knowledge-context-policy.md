# Task

task_id: T-004A
title: Replace canonical knowledge_context policy references
status: validated
change: harness-360-refactor
owner_agent: altitude-execution

## Objective

Replace the canonical policy-level references to the missing `knowledge_context/` surface with the `.specs/memory` model.

## Context

The harness target operating model now treats `.specs/memory` as the durable context surface, but some canonical files still point to `knowledge_context/` and `_registry.yaml`, which do not exist in this repo.

## Source References

- `docs/HARNESS_TARGET_OPERATING_MODEL.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `README.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `.specs/changes/harness-360-refactor/02-decomposition.md`
- `AGENTS.md`
- `config/grounding.md`

## Allowed Files

- `README.md`
- `AGENTS.md`
- `config/grounding.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `.specs/changes/harness-360-refactor/02-decomposition.md`
- `.specs/changes/harness-360-refactor/03-execution-ledger.md`
- `.specs/changes/harness-360-refactor/04-validation.md`
- `.specs/changes/harness-360-refactor/state.md`
- `.specs/changes/harness-360-refactor/tasks/T-004A-replace-canonical-knowledge-context-policy.md`
- `.specs/memory/active-state.md`

## Forbidden Scope

- `skills/workflow-commands/commands/brainstorm.md`
- `agents/workflow.brainstorm-agent.agent.md`
- `skills/knowledge-context/**`
- `config/routing.json`
- `opencode.json`

## Dependencies

- T-003

## Implementation Steps

1. Replace canonical references that treat `knowledge_context/` as an active dependency.
2. Point those surfaces to `.specs/memory` and active change memory instead.
3. Update the ledger and validation notes.

## Acceptance Criteria

- `README.md` no longer describes `knowledge_context/` as an active harness surface
- `AGENTS.md` no longer instructs the harness to rely on `knowledge_context/_registry.yaml`
- `config/grounding.md` no longer treats `knowledge_context/` as a required active context source

## Verification Commands

- confirm the targeted files no longer contain active dependency language for `knowledge_context/`
- confirm the replacement language points to `.specs/memory` consistently

## Evidence Required

- updated canonical policy files
- updated execution ledger and validation notes

## Rollback

Restore the prior references if the replacement language creates a larger migration mismatch than expected.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Verification completed or justified
- [x] Evidence saved
- [x] Execution ledger updated
- [x] Ready for validation
