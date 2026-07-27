# Structure

## Surfaces

| Surface | Role |
| --- | --- |
| `skills/task-spec/SKILL.md` | leaf-task generation workflow |
| `skills/task-spec/templates/task-spec.md.tpl` | Task-Spec frontmatter and body template |
| `skills/task-spec/scripts/generate-task-spec.sh` | creates Task-Spec stubs |
| `docs/HARNESS_V3_TASK_SPEC_INTEGRATION.md` | bridge contract |
| `.specs/shared/task-contract.md` | Harness V3 executable task requirements |
| `.specs/shared/allocation-contract.md` | allocation inheritance |
| `.specs/shared/execution-loop-contract.md` | loop posture for executable tasks |
| `test/fixtures/harness-v3/fixture-10-task-spec-leaf-generation.md` | preservation fixture |

## Risk

Task-Spec can become a competing task control plane if it is allowed to own change state. This wave keeps Task-Spec as the leaf-task representation only.
