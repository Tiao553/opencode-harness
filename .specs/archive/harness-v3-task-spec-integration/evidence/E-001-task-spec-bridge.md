# E-001 - Task-Spec Bridge

## Scope

Wave 6 integrated Task-Spec as the Harness V3 leaf-task engine while preserving `.specs/changes/...` as the change-level control surface.

## Files Changed

- `docs/HARNESS_V3_TASK_SPEC_INTEGRATION.md`
- `skills/task-spec/templates/task-spec.md.tpl`
- `skills/task-spec/scripts/generate-task-spec.sh`
- `.specs/changes/harness-v3-task-spec-integration/**`

## Evidence

Task-Spec bridge marker validator:

```text
task-spec-bridge-ok
```

Fixture validator:

```text
Harness V3 fixture contract OK: 18 fixtures with ids, route/mode, verify clauses, and forbidden behavior
```

Grounding validator:

```text
grounding-links-ok
```

## Result

Harness V3 now has a documented `.specs -> Task-Spec -> execution -> validation -> state` bridge. The Task-Spec template carries additive `harness_v3` metadata for parent change, phase, allocation, artifact sources, verification, evidence, rollback, and loop posture.
