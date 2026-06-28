# Harness V3 State Resolution Contract

## Purpose

Make phase and task resolution deterministic. State resolution must prevent stale artifacts, machine files, or memory notes from silently overriding the current user instruction.

## Authority Order

```text
1. explicit user instruction in current turn
2. active task contract
3. active local allocation
4. active wave allocation
5. active phase allocation
6. active change request contract
7. durable artifacts in .specs/changes/...
8. machine-readable state files
9. memory notes
10. inferred repository context
```

## State Inputs

| Input | Example | Use |
| --- | --- | --- |
| current user request | "implement", "plan only", "commit" | top-level authority |
| active state | `.specs/memory/active-state.md` | resume point |
| change state | `.specs/changes/{change}/state.md` | phase and status |
| task contract | `.specs/changes/{change}/tasks/T-*.md` | execution boundary |
| validation ledger | `04-validation.md` | acceptance evidence |
| memory | `.specs/memory/*` | durable operational context |

## Conflict Handling

If state sources disagree, do not proceed into execution.

Required output:

```text
State conflict detected.

Current evidence:
- user instruction:
- active task:
- local allocation:
- change state:
- machine state:
- memory:

Recommended repair:
A. trust current user instruction
B. trust active task contract
C. trust change state
D. create a repair task

Required confirmation:
Choose A/B/C/D.
```

## Conflict Examples

| Conflict | Required behavior |
| --- | --- |
| task says `ready`, validation says failed | block execution and repair task/validation |
| state says Execution, no active task exists | block and route to planning or report |
| user asks commit, staged files include unrelated changes | stage intended files only or ask |
| memory says old path, repo has new path | verify repo truth and update memory only when asked |

## State Repair Rules

- Repair the narrowest source possible.
- Never edit history to hide a prior mistake.
- Evidence files are append-only unless correcting a typo or malformed artifact.
- If a user instruction intentionally overrides state, record the override in the ledger.

## Completion Criteria

State resolution passes when:

- active change is known or intentionally absent
- phase is known
- next action is known
- no unresolved conflict blocks the next action
- evidence requirements are known for executable work

