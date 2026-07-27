# E-001 - Template and Allocation Hardening

## Scope

Wave 3B hardened official Harness V3 artifact templates and allocation contracts.

## Files Changed

- `.specs/templates/prd-template.md`
- `.specs/templates/adr-template.md`
- `.specs/templates/test-spec-template.md`
- `.specs/templates/validation-report-template.md`
- `.specs/templates/ship-summary-template.md`
- `.specs/shared/allocation-contract.md`
- `.specs/shared/global-allocation-contract.md`
- `.specs/shared/local-allocation-contract.md`
- `docs/HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md`

## Evidence

Template/allocation validator:

```text
template-allocation-contract-ok
```

Fixture validator:

```text
Harness V3 fixture contract OK: 18 fixtures with ids, route/mode, verify clauses, and forbidden behavior
```

Grounding validator:

```text
grounding-links-ok
```

Marker check:

```text
source_authority, Task-Spec Mapping, Broadening Rule, and Allocation Connection markers exist.
```

## Result

The official templates now carry source authority, allocation, related artifact links, evidence, validation, residual-risk, and rollback fields. Allocation contracts now define precedence, Task-Spec inheritance, broadening rules, executable-local-allocation requirements, and invalid states.
