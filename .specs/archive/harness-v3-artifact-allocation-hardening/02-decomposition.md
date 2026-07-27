# Decomposition

## Task AAH-001

Harden the official V3 artifact templates and allocation contracts.

Allowed files:

- `.specs/templates/prd-template.md`
- `.specs/templates/adr-template.md`
- `.specs/templates/test-spec-template.md`
- `.specs/templates/validation-report-template.md`
- `.specs/templates/ship-summary-template.md`
- `.specs/shared/allocation-contract.md`
- `.specs/shared/global-allocation-contract.md`
- `.specs/shared/local-allocation-contract.md`
- `docs/HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md`
- `.specs/changes/harness-v3-artifact-allocation-hardening/**`
- `.specs/memory/active-state.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`

Forbidden scope:

- runtime plugins
- command deletion
- coordinator config
- old SDD template overhaul

Verification:

- template section validator
- fixture validator
- grounding link validator
