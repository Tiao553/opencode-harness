# Ship Note

## Shipped Boundary

Wave 3 shipped as a contract-only migration wave.

## Evidence

- `.specs/changes/harness-v3-unified-phase-contract/evidence/E-001-unified-phase-contract.md`
- `.specs/changes/harness-v3-unified-phase-contract/04-validation.md`

## Rollback

If this wave causes confusion, revert the edits to:

- `docs/HARNESS_V3_PHASE_ENGINE_SPEC.md`
- `.specs/shared/phase-engine-contract.md`
- `.specs/shared/compatibility-policy.md`

No runtime behavior or command files were changed.

## Next Recommended Wave

Audit the already-created artifact templates and allocation contracts, then move to Ask-User/Todo or Ralph Loop globalization depending on which gap remains larger after inspection.
