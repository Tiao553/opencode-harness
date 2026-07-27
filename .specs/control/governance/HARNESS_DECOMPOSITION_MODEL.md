# Harness Decomposition Model

## Purpose

Define the decomposition engine for the harness so that execution no longer depends on late build-time task invention.

This document freezes:

- the effort-based `SDD` vs `Task-Spec` selection rule
- the leaf-task size rule
- the decomposition escalation rule
- the expected planning outputs before execution can start

## Grounding

This model is grounded in:

- `.specs/shared/task-contract.md`
- `.specs/shared/definition-of-done.md`
- `.specs/shared/acceptance-criteria.md`
- `agents/altitude-plan.agent.md`
- `skills/workflow-commands/commands/build.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- `docs/HARNESS_TARGET_OPERATING_MODEL.md`

## Design Goals

- force decomposition before execution
- keep tasks small enough for smaller models and delegated agents
- stop build from becoming the real planner
- make verification and rollback mandatory at the leaf level
- create a predictable path for escalation when a task is still too large

## Selection Matrix

| Effort class | Shape | Primary decomposition artifact |
| --- | --- | --- |
| XS | single bounded adjustment | direct leaf task in `.specs/tasks/` |
| S | one small vertical slice, low coupling | `Task-Spec`-style leaf task inside an `Altitude` change |
| M | bounded multi-file slice, still local and reversible | `Task-Spec`-style leaf task or small task pack inside an `Altitude` change |
| L | multi-module or policy-heavy change | full `Altitude` decomposition with multiple leaf tasks |
| XL | cross-cutting or migration-scale change | staged `Altitude` decomposition with explicit phase boundaries |

## Rule of Use

- `Task-Spec` is the preferred leaf-task form for S and many M tasks.
- richer `Altitude` task packs are preferred for L and XL work.
- every durable effort still belongs to an `Altitude` change request.
- `Task-Spec` does not replace the change ledger; it refines the leaf execution unit.

## Leaf Task Rule

Every execution-ready leaf task must satisfy all of the following:

- one deliverable outcome
- maximum three non-ledger files touched
- explicit acceptance criteria
- explicit verification path
- explicit evidence requirement
- explicit rollback note
- clear forbidden scope

### What Does Not Count Toward the Three-File Rule

The following operational files do not count toward the three-file product limit:

- `state.md`
- `03-execution-ledger.md`
- `04-validation.md`
- task files under `tasks/`
- evidence files under `evidence/`

This exception exists so the harness can keep traceability without inflating the perceived size of the actual product change.

## Preferred Slice Shape

Prefer a small vertical slice over a horizontal batch.

### Good

- one policy document plus the small routing change needed to adopt it
- one broken context dependency replaced in one workflow path
- one KB contradiction fixed with one supporting agent-grounding adjustment

### Bad

- all routing cleanup in one task
- all knowledge-context removal in one task
- all Fabric KB repairs in one task

## Decomposition Flow

1. Confirm intent.
2. Map structure and risks.
3. Classify effort.
4. Decide `Task-Spec` leaf vs richer task pack.
5. Split until each ready task is small, reversible, and verifiable.
6. Only then mark a task `ready` for execution.

## Escalation Rule

If a task still violates any of these conditions:

- too many non-ledger files
- more than one true deliverable
- unclear rollback
- unclear verification
- hidden dependency chain

then execution must not proceed.

The harness must escalate back to planning refinement.

This escalation may:

- split the task further
- re-sequence dependencies
- reclassify the effort from S/M to L/XL
- introduce a preparatory documentation or policy task first

## Build Implication

`Build` must not be the place where the harness creates its real task model.

That means the future-state harness should treat these as anti-patterns:

- on-the-fly execution task generation from a file manifest
- hidden execution chunks not represented in `.specs/changes/.../tasks/`
- build-only plans that are more specific than the prior decomposition

## Planning Outputs

Before execution, planning should emit:

- change-level decomposition order
- leaf-task files with full contract fields
- dependencies between tasks
- verification strategy per task
- rollback strategy per task

## Examples

### Example A - Documentation/Policy Task

- deliverable: `docs/HARNESS_MCP_GOVERNANCE_MATRIX.md`
- non-ledger files touched: 2
- acceptable as S task

### Example B - Broken Context Surface Replacement

- likely touches `README.md`, `config/grounding.md`, one workflow command file
- acceptable only if split into multiple leaf tasks

### Example C - Fabric Golden-Domain Repair

- must split by contradiction cluster or workload area
- not acceptable as one monolithic task

## Success Criteria

This decomposition model is adopted when:

- ready tasks are smaller than the current build-time chunk model
- execution no longer depends on late task invention
- the three-file non-ledger rule is being used consistently
- planning refinement is used instead of letting oversized tasks leak into execution
