# Decomposition

## Task TSI-001

Create the Harness V3 Task-Spec bridge.

Allowed files:

- `docs/HARNESS_V3_TASK_SPEC_INTEGRATION.md`
- `skills/task-spec/templates/task-spec.md.tpl`
- `skills/task-spec/scripts/generate-task-spec.sh`
- `.specs/changes/harness-v3-task-spec-integration/**`
- `.specs/memory/active-state.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`

Forbidden scope:

- Task-Spec validator rewrite
- command deletion
- runtime plugin changes
- unrelated skill refactors

Verification:

- Task-Spec bridge marker validator
- fixture validator
- grounding link validator
