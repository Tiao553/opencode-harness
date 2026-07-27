# Ship Note

## Shipped Boundary

Wave 7 shipped as a contract and coordinator-guidance wave.

## Evidence

- `.specs/changes/harness-v3-delegation-migration/evidence/E-001-delegation-allocation.md`
- `.specs/changes/harness-v3-delegation-migration/04-validation.md`

## Rollback

Revert:

- `.specs/shared/specialist-allocation-contract.md`
- `.specs/shared/local-allocation-contract.md`
- `.specs/shared/task-contract.md`
- `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
- `agents/altitude.agent.md`

No subagent or command implementation was changed.

## Next Recommended Wave

Documentation Mode and Production Code Mode are already partially represented by shared contracts; audit and harden them next before runtime RTK/Headroom integration.
