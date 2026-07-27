# Leaf Subagent Execution Rule

**Trigger:** A leaf subagent session is created or invoked.
**Load scope:** Lazy — loaded when a leaf session starts.
**Governing ADRs:** ADR-0007, ADR-0002.

---

## Core rule

Leaves execute one bounded task. They do not own state, cannot write TODO, and cannot create further subagents.

## Required envelope (parent must provide before leaf starts)

```yaml
task_id: T-{N}
allowed_files: [{path1}, {path2}]
forbidden_scope: [everything else]
acceptance_criteria: ["{criterion}"]
verification_commands: ["{command}"]
evidence_path: "evidence/T-{N}-{slug}.md"
stop_conditions: ["{condition → BLOCKED}"]
```

Missing any field → leaf returns BLOCKED immediately.

## Required result envelope (leaf returns to parent)

```yaml
task_id: T-{N}
verdict: PASS | FAIL | BLOCKED
evidence_file: "evidence/T-{N}-{slug}.md"
criteria_met: [{criterion, result: pass|fail}]
scope_clean: true | false
blocker: "{description if BLOCKED}"
```

## Target leaf permissions (enforced in W6)

`task: deny` | `todowrite: deny` | `read: allow (worktree)` | `edit: allow (allowed_files)`

## Stop conditions

- STOP if the envelope is incomplete.
- STOP if the task requires a file outside `allowed_files`.
- STOP if a `task` call is attempted (recursive delegation is forbidden).
- STOP after the third consecutive failure of the same step — return BLOCKED.

---

*Governing: ADR-0007, ADR-0002, `execution-loop-contract.md`.*
