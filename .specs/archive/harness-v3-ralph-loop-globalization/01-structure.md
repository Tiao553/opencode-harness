# Structure

## Surfaces

| Surface | Role |
| --- | --- |
| `.specs/shared/execution-loop-contract.md` | core Ralph Loop contract |
| `.specs/shared/task-contract.md` | executable task preconditions |
| `.specs/shared/todo-allocation-contract.md` | operational todo projection |
| `docs/HARNESS_V3_COORDINATOR_CONTRACT.md` | coordinator lifecycle and loop policy |
| `tools/verify_step.ts` | optional runtime verifier when exposed |
| `tools/faithfulness_gate.ts` | optional runtime preflight gate when exposed |
| `config/grounding.md` | contract index |

## Risk

If the loop contract is too broad, it creates ceremony for simple answer-only work. If too weak, later runtime enforcement and Task-Spec integration will lack a stable execution protocol.

## Design Direction

Use three postures:

- `mandatory` for executable or critical artifact work
- `advisory` for discovery and planning
- `not_applicable` for answer-only or read-only trivial work
