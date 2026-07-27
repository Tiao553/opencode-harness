# Structure

## Surfaces

| Surface | Role |
| --- | --- |
| `.specs/shared/specialist-allocation-contract.md` | delegation rules |
| `.specs/shared/local-allocation-contract.md` | task-level ownership |
| `.specs/shared/task-contract.md` | executable task fields |
| `docs/HARNESS_V3_COORDINATOR_CONTRACT.md` | coordinator allocation behavior |
| `agents/altitude.agent.md` | visible coordinator guidance |

## Risk

Over-delegation can create hidden task ownership and unreviewed specialist output. Under-delegation can skip useful domain review. The contract must make delegation explicit and bounded.
