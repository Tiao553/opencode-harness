# EXECUTAR TODAS

## Purpose

Execute a controlled sequence of changes.

## Queue Topology

```text
[Change Queue]
  -> [Select Active Change]
  -> [Select One Ready Task]
  -> [Execute]
  -> [Validate]
  -> [Advance or Stop on Blocker]
```

## Execution Policy

- Do not execute all changes in one shot.
- Execute one change at a time.
- Execute one task at a time.
- Validate before moving to the next change.
- Stop on blocker.
- Update memory only after durable learning or validated change.

## Queue

| Order | Change | Status | Current task | Required agent | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | 001-example | ready_for_execution | 001 | altitude-execution | |

## Wave Notes

| Wave | Goal | Entry Criteria | Exit Criteria |
| --- | --- | --- | --- |
| Wave 1 | {Goal} | {Entry} | {Exit} |

## Gates

- [ ] Active change selected
- [ ] Active task selected
- [ ] Allowed files defined
- [ ] Verification command defined
- [ ] Evidence path defined
- [ ] Rollback note defined

## Stop Conditions

- Any blocker that invalidates the active task contract
- Any scope expansion outside allowed files
- Any failed validation that requires planning refinement
