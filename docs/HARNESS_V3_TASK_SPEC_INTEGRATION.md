# Harness V3 Task-Spec Integration

## Purpose

Define how Harness V3 uses `skills/task-spec/` as the official leaf-task engine without letting Task-Spec become a second change-level control plane.

## Authority Boundary

| Layer | Owns | Does Not Own |
| --- | --- | --- |
| `.specs/changes/...` | change state, phase, global allocation, task pack, evidence ledger | per-executor portable eval format |
| `.specs/shared/*` | contracts for phase, task, allocation, loop, validation | concrete leaf-task execution file format |
| `skills/task-spec/` | atomic S/M leaf task format, runnable evals, safe-to-delegate gate | change lifecycle, phase movement, wave ownership |

Correct flow:

```text
.specs change contract
  -> phase engine
  -> global allocation
  -> task pack
  -> local allocation
  -> Task-Spec leaf task
  -> Ralph Loop execution
  -> validation evidence
  -> .specs state update
```

Invalid flow:

```text
Task-Spec task
  -> silently changes phase
  -> broadens allocation
  -> bypasses .specs validation
```

## Generation Preconditions

A Task-Spec leaf task may be generated only when the coordinator knows:

- parent change id or tactical request id
- source phase or tactical mode
- objective
- allowed files
- forbidden scope
- required context
- verification path
- evidence required
- rollback path
- parent allocation
- local task allocation
- loop posture

If any field is unknown, return to Design/Plan or ask the user before generating the leaf task.

## Mapping

| Harness V3 field | Task-Spec field |
| --- | --- |
| `change_id` | `parent_change_id` |
| `phase` | `source_phase` |
| `wave` | `execution_wave` |
| `objective` | `goal` body section |
| `allowed files` | `touches_paths` and `allowed_files` |
| `forbidden scope` | `forbidden_files` and `Do-Not-Touch` |
| `global_allocation` | `parent_allocation` |
| `local_allocation` | `task_allocation` |
| `PRD` | `requirements_source` |
| `ADR` | `decision_source` |
| `TEST-SPEC` | `validation_source` |
| `verification_commands` | `verify_steps` and Success Criteria evals |
| `evidence_required` | `evidence_required` |
| `rollback` | `rollback_plan` and Rollback Plan section |
| `loop_posture` | `loop_posture` |

## Effort Gate

Task-Spec is valid for S/M leaf tasks.

| Effort | Routing |
| --- | --- |
| S | Task-Spec leaf task |
| M | Task-Spec leaf task when bounded and eval-friendly |
| L | split through Harness V3 Design/Plan before Task-Spec |
| XL | remain at `.specs`/SDD level until decomposed |

## Validation Gate

Before delegation:

1. Task contract is complete.
2. Task-Spec structural validation passes when scripts are available.
3. `safe-to-delegate.sh --stamp` passes before unattended execution.
4. Ralph Loop posture is `mandatory` for executable leaf tasks.
5. `.specs` state is updated only after validation evidence exists.

When Task-Spec scripts are unavailable, record that automation was unavailable and perform the Harness V3 task-contract structural review manually.

## State Rule

Task-Spec status is leaf-task status. It does not replace active change state.

The coordinator must update `.specs/changes/{change}/state.md` and `.specs/memory/active-state.md` when a leaf task changes the durable change status.

## Rollback

If Task-Spec integration fails:

- keep `.specs` task model as authority
- retain `skills/task-spec/` as standalone skill
- stop generating bridge fields until contract is repaired
