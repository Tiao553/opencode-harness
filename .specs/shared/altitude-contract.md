# Altitude Contract

The user operates high. The agent descends deliberately.

## Altitudes

| Altitude | Purpose | Agent | Primary output |
| --- | --- | --- | --- |
| Intent | Clarify the problem and success criteria | `altitude-intent` | `00-intent.md` |
| Structure | Map modules, contracts, constraints, and risks | `altitude-structure` | `01-structure.md` |
| Decomposition | Split work into small executable tasks | `altitude-plan` | `02-decomposition.md`, `tasks/` |
| Execution | Implement one approved task | `altitude-execution` | `03-execution-ledger.md`, `evidence/` |
| Validation | Check scope, tests, evidence, and criteria | `altitude-validation` | `04-validation.md` |
| Report | Summarize from artifacts, not chat | `altitude-report` | `05-executive-report.md` |
| Memory | Update durable project memory and archive | `altitude-memory` | `.specs/memory/**`, `06-ship-note.md` |

## Rules

- Complex work cannot skip Intent, Structure, and Decomposition.
- Execution requires an active change and one ready task.
- Validation requires evidence.
- Reports are generated from `.specs` artifacts, not conversation history.
- Memory updates require durable learning.
