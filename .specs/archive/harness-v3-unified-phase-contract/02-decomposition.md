# Decomposition

## Task UPC-001

- Tighten the phase engine spec and shared phase contract.
- Add explicit workflow-to-V3 phase mapping.
- Add compatibility requirements for `/workflow:*` wrappers.
- Record evidence and validation.

Allowed files:

- `docs/HARNESS_V3_PHASE_ENGINE_SPEC.md`
- `.specs/shared/phase-engine-contract.md`
- `.specs/shared/compatibility-policy.md`
- `.specs/changes/harness-v3-unified-phase-contract/**`
- `.specs/memory/active-state.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`

Forbidden scope:

- command deletion
- workflow agent rewrites
- runtime plugin mutation
- unrelated legacy cleanup

Verification:

- `rtk proxy bash test/fixtures/harness-v3/validate-fixtures.sh`
- grounding shared-link check
- coordinator registration check
- contract grep for workflow compatibility mapping
