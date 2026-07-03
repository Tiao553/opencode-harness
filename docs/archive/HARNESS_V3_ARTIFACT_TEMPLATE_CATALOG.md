# Harness V3 Artifact Template Catalog

## Purpose

Define official templates for V3 planning, decision, validation, and shipping artifacts.

## Template Inventory

| Template | Path | Required when |
| --- | --- | --- |
| PRD | `.specs/templates/prd-template.md` | requirements or user-visible behavior need alignment |
| ADR | `.specs/templates/adr-template.md` | architecture decision has meaningful alternatives |
| TEST-SPEC | `.specs/templates/test-spec-template.md` | validation must be explicit |
| validation report | `.specs/templates/validation-report-template.md` | change/task acceptance needs evidence |
| ship summary | `.specs/templates/ship-summary-template.md` | work is ready to close |

## Required Shared Fields

Every official V3 artifact template includes or should preserve:

| Field | Purpose |
| --- | --- |
| `source_authority` | names the request, artifact, code, or evidence the artifact is grounded in |
| `allocation` | links the artifact to global/local ownership boundaries |
| related artifact links | connects PRD, ADR, TEST-SPEC, validation, and ship artifacts |
| evidence fields | makes validation auditable |
| rollback or residual risk | prevents silent acceptance of unsafe closure |

If a field is not applicable, mark it `N/A` and state why. Do not delete traceability fields from durable artifacts.

## Template Selection

```text
behavior / product semantics -> PRD
technical trade-off          -> ADR
regression or correctness    -> TEST-SPEC
acceptance evidence          -> validation report
closure and residual risks   -> ship summary
```

## Quality Rules

- Templates are scaffolds, not excuses for shallow output.
- Delete irrelevant sections only when the task explicitly does not need them.
- Keep architecture-as-text for system changes.
- Keep acceptance criteria and validation separate.
- Record residual risks explicitly.
- Link requirements to tests when correctness matters.
- Link decisions to rollback when architecture changes.
- Link validation evidence to the exact commands, screenshots, fixtures, or manual checks used.
- Link ship summaries to validation reports and state/memory updates.

## Allocation Connection

Artifact generation must respect:

- `.specs/shared/allocation-contract.md`
- `.specs/shared/global-allocation-contract.md`
- `.specs/shared/local-allocation-contract.md`

Artifacts may narrow scope as they become more concrete. They must not broaden the active allocation without explicit user confirmation or a new accepted allocation.

## Future Validation

Each template should eventually have a fixture that proves:

- required sections exist
- placeholders are removed
- traceability is present
- evidence references are concrete
