# Ship Note

## Shipped Boundary

Wave 6 shipped the Task-Spec bridge contract and additive template metadata.

## Evidence

- `.specs/changes/harness-v3-task-spec-integration/evidence/E-001-task-spec-bridge.md`
- `.specs/changes/harness-v3-task-spec-integration/04-validation.md`

## Rollback

Revert:

- `docs/HARNESS_V3_TASK_SPEC_INTEGRATION.md`
- `skills/task-spec/templates/task-spec.md.tpl`
- `skills/task-spec/scripts/generate-task-spec.sh`

If reverted, keep `.specs` task model as authority and retain Task-Spec as a standalone skill.

## Next Recommended Wave

Delegation migration: move specialist allocation fully into allocation/task contracts and out of late execution decisions.
