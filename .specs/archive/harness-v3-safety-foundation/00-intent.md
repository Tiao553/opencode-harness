# Harness V3 Safety Foundation - Intent

## Problem

The Harness V3 roadmap requires a safety foundation before runtime, command, coordinator, or plugin mutation. Without explicit contracts, artifact templates, allocation rules, legacy preservation mapping, and golden fixtures, later migration waves could look architecturally cleaner while silently deleting useful behavior.

## Objective

Create the first Harness V3 safety foundation:

- coordinator contract
- state resolution contract
- phase engine spec
- artifact registry
- artifact template catalog
- allocation contracts
- migration test plan
- legacy preservation matrix
- golden behavior fixtures
- lightweight fixture validator

## Constraints

- Do not mutate runtime behavior.
- Do not delete legacy commands.
- Do not rewire plugins.
- Do not mark runtime-critical features as enforced unless evidence proves enforcement.
- Keep this as documentation/contracts/fixtures only.

## Non-Goals

- Implement the full Harness V3 runtime.
- Remove command surfaces.
- Build the final fixture runner.
- Integrate RTK or Headroom into runtime enforcement.

## Success Criteria

- Safety foundation docs exist under `docs/`.
- Shared contracts exist under `.specs/shared/`.
- PRD/ADR/TEST-SPEC/validation/ship templates exist under `.specs/templates/`.
- Eighteen golden fixtures exist under `test/fixtures/harness-v3/`.
- The fixture validator proves required sections and fixture count.

