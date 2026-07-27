# Ship Note

## Shipped Boundary

Wave 5 shipped as a contract and policy wave.

## Evidence

- `.specs/changes/harness-v3-ralph-loop-globalization/evidence/E-001-ralph-loop-globalization.md`
- `.specs/changes/harness-v3-ralph-loop-globalization/04-validation.md`

## Rollback

Revert:

- `.specs/shared/execution-loop-contract.md`
- `.specs/shared/task-contract.md`
- `.specs/shared/todo-allocation-contract.md`
- `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`

No runtime plugin behavior was changed.

## Next Recommended Wave

Task-Spec integration is the next high-risk wave. It can now rely on artifact allocation and Ralph Loop contracts.
