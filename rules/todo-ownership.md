# TODO Ownership Rule

**Trigger:** Any attempt to create, update, or close an entry in the managed TODO ledger.
**Load scope:** Lazy — loaded when a TODO write operation is initiated.
**Governing ADR:** ADR-0002.

---

## Core rule

**Only the parent session may write to the managed TODO ledger.**

---

## Required behavior

| Actor | Permitted TODO action |
|---|---|
| Parent session | Create, update, and close any ledger entry |
| Leaf subagent | None — `todowrite: deny` at the profile level (enforced in W6) |
| Manual `@agent` invocation | None — out-of-band from managed state |

## Mandatory fields for every ledger entry

```markdown
| Task ID | Status | Evidence file | Actor | Timestamp |
| T-{N}   | done   | evidence/...  | parent | {ISO-8601} |
```

A ledger entry without `actor: parent` and an `evidence:` path is incomplete and must not be written.

## Sequential execution rule

- One task is `in_progress` at a time in the managed ledger.
- To open a second task, the first must be `done` or explicitly `blocked` with a reason.
- Parallel tasks require pre-declared independent file scope approved before Execution begins.

## Stop conditions

- STOP if a leaf session attempts to write a TODO entry. Create a defect report and escalate to the parent.
- STOP if a TODO close has no associated evidence file path.
- STOP if two tasks are both `in_progress` simultaneously without an approved parallel-execution declaration.

---

*Governing: ADR-0002, `.specs/shared/allocation-contract.md`.*
