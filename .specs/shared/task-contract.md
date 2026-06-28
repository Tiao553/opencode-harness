# Task Contract

Execution works one task at a time.

## Task Statuses

```text
pending
ready
in_progress
implemented
validation_failed
validated
blocked
skipped
cancelled
```

## Required Fields

Each task must include:

- objective
- context
- source references
- allowed files
- forbidden scope
- dependencies
- implementation steps
- acceptance criteria
- verification commands
- evidence required
- rollback
- completion checklist
- loop posture
- specialist allocation when relevant

## Execution Preconditions

Execution can begin only when:

- `change.status` is `ready_for_execution` or `in_execution`
- `task.status` is `ready`
- `allowed_files` is defined
- `forbidden_scope` is defined
- `acceptance_criteria` is defined
- `verification_commands` is defined
- `evidence_required` is defined
- `loop_posture` is `mandatory`, `advisory`, or `not_applicable`

## Loop Posture

Executable tasks must set:

```text
loop_posture: mandatory
```

Use `advisory` only for planning, discovery, or non-critical artifact drafting. Use `not_applicable` only for answer-only or trivial read-only work.

When `loop_posture` is `mandatory`, the task must identify:

- step boundaries
- verification command or manual check for each step
- evidence location or evidence summary
- repair limit or escalation condition

See `.specs/shared/execution-loop-contract.md`.

## Specialist Allocation

When specialist support is needed, the task must identify:

- specialist or skill name
- reason
- scope
- grounding bundle
- expected evidence
- verification responsibility
- stop condition

Specialist support must be allocated before execution begins. It must not be invented inside execution to compensate for an incomplete task contract.
