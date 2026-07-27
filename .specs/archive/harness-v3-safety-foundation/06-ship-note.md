# Harness V3 Safety Foundation - Ship Note

change: harness-v3-safety-foundation
status: shipped
date: 2026-06-28
owner: altitude-report

## Summary

Shipped the first Harness V3 safety foundation. This is a non-runtime change that creates the contracts, templates, and fixtures needed before later migration waves.

## What Shipped

- Harness V3 foundation docs under `docs/`
- shared contracts under `.specs/shared/`
- artifact templates under `.specs/templates/`
- golden fixtures under `test/fixtures/harness-v3/`
- fixture validator under `test/fixtures/harness-v3/validate-fixtures.sh`

## Validation Reference

```bash
test/fixtures/harness-v3/validate-fixtures.sh
```

Latest result:

```text
Harness V3 fixture contract OK: 18 fixtures with ids, route/mode, verify clauses, and forbidden behavior
```

## Risks Accepted

- Fixture validation checks structure and minimal semantics only.
- Route/state/allocation values are reviewable but not machine-validated yet.
- Runtime mutation remains blocked until later waves.

## Follow-Up Watch Items

- Add a machine-readable fixture runner.
- Materially review all fixture expectations.
- Start Grounding Split only after fixture review.
