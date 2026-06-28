# Todo Allocation Contract

## Purpose

Define how the harness projects durable state into `TodoWrite`.

This contract exists to prevent the todo list from becoming a second planner. The todo list is an operational projection of current state, not an independent source of truth.

## Source Of Truth

The todo tree must be derived from:

- `.specs/memory/active-state.md`
- active change `state.md`
- active phase contract
- active task contract
- active `Task-Spec` leaf task when present

`TodoWrite` is never the source of truth.

## Projection Model

The coordinator should project work as a hierarchy:

```text
Wave
└── Task
    └── Todo
```

This means:

- the system may show many tasks when the wave truly has many tasks
- the system may show many todos inside a task when nuance demands it
- visibility comes from hierarchy, not from hiding work arbitrarily

## Visibility Rule

If the active wave has 20 tasks, the projection may show the 20 tasks.

The harness should not enforce a small artificial cap that hides real decomposition detail.

## Todo Requirements

Every operational todo must include:

- task id
- specialist name when relevant
- short action statement
- explicit `verify:` clause
- loop posture when the todo is executable

### Example

```text
[T-006B1][platform.fabric-architect][loop:mandatory] Validate official Copilot capacity claim
-> verify: one source-backed rule is selected and documented
```

## Specialist Rule

When a delegated specialist is involved, the todo must always cite the specialist.

## Verify Rule

Every operational todo must include a `verify:` signal.

No todo should be emitted as execution-ready without a visible verification path.

## Loop Rule

Todos for executable work inherit loop posture from the active task.

| Task posture | Todo posture |
| --- | --- |
| `mandatory` | include `[loop:mandatory]` or equivalent visible marker |
| `advisory` | include loop marker only when useful |
| `not_applicable` | omit loop marker |

The todo list does not run Ralph Loop by itself; it projects the operational steps that the coordinator must verify through `.specs/shared/execution-loop-contract.md`.

## Recompute Rule

The coordinator must recompute the todo tree when any of the following changes:

- active phase
- active task
- task status
- validation verdict
- blocker status
- replan or decomposition change
- explicit human override

Incremental patching is allowed internally, but the model exposed to the user should reflect a full recompute of the current valid work tree.

## Task and Todo Relationship

- tasks remain the durable work contract
- todos are the operational breakdown for current execution and navigation
- todos must not widen scope beyond the task

## Tactical Versus Strategic Use

| Path | Todo posture |
| --- | --- |
| Strategic coordinator | project or change wave -> task -> todo |
| Tactical data-engineer coordinator | tactical work queue -> task -> todo |

## Anti-Patterns

- todo list as a second planner
- todo without `verify:`
- todo without specialist when a specialist is involved
- shallow todo list that hides real decomposition
- todo list that survives a phase change without recompute
