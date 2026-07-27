# Evidence

evidence_id: E-001
change: harness-v3-safety-foundation
created: 2026-06-28
command: inventory checks + fixture validator
status: captured
captured_by: openai/gpt-5.4

## Summary

Captured the Harness V3 safety-foundation outputs and validated the first golden fixture set.

## Commands

```bash
rtk proxy find docs -maxdepth 1 -name 'HARNESS_V3_*.md' -printf '%f\n' | sort
rtk proxy find .specs/shared -maxdepth 1 \( -name '*allocation*' -o -name 'phase-engine-contract.md' -o -name 'state-conflict-resolution-policy.md' \) -printf '%f\n' | sort
rtk proxy find .specs/templates -maxdepth 1 \( -name 'prd-template.md' -o -name 'adr-template.md' -o -name 'test-spec-template.md' -o -name 'validation-report-template.md' -o -name 'ship-summary-template.md' \) -printf '%f\n' | sort
rtk proxy find .specs/shared -maxdepth 1 -type f -printf '%f\n' | sort
rtk proxy bash test/fixtures/harness-v3/validate-fixtures.sh
```

## Output

```text
Harness V3 fixture contract OK: 18 fixtures with ids, route/mode, verify clauses, and forbidden behavior
```

## Interpretation

The roadmap's first safety foundation is materially present. The migration now has explicit docs, contracts, templates, and reviewable fixture expectations before runtime behavior is changed. The fixture validator checks the expected fixture count, filename/id alignment, required sections, non-empty route/mode sections, at least one `verify:` clause, and at least one forbidden-behavior bullet per fixture.

The shared policy inventory now includes the roadmap-required runtime, context-loading, state-resolution, execution-loop, documentation-mode, production-code-mode, compatibility, allocation, and specialist-allocation contracts.

## Limitation

The validator does not yet validate route enum values, state transitions, or allocation inheritance. Later waves should add semantic validation for those fields.
