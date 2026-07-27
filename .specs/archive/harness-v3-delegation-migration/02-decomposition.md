# Decomposition

## Task DM-001

Harden delegation as task-level specialist allocation.

Allowed files:

- `.specs/shared/specialist-allocation-contract.md`
- `.specs/shared/local-allocation-contract.md`
- `.specs/shared/task-contract.md`
- `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
- `agents/altitude.agent.md`
- `.specs/changes/harness-v3-delegation-migration/**`
- `.specs/memory/active-state.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`

Forbidden scope:

- subagent rewrites
- command deletion
- runtime plugin changes

Verification:

- delegation marker validator
- fixture validator
- grounding link validator
