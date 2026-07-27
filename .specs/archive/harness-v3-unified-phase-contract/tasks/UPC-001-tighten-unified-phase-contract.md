# UPC-001 - Tighten Unified Phase Contract

## Status

validated

## Objective

Absorb useful legacy workflow semantics into the Harness V3 phase engine contract without deleting legacy command surfaces.

## Acceptance Criteria

- One unified phase contract owns phase order, gates, invalid states, artifact expectations, and workflow compatibility.
- `workflow:*` is described as a compatibility wrapper, not a phase authority.
- Legacy workflow outputs map to V3 artifact families.
- Validation gates prove fixtures, grounding links, and coordinator registration still pass.

## Steps

1. [x] Update phase docs and contracts -> verify: workflow compatibility mapping is present.
2. [x] Update compatibility policy -> verify: retained/compatibility/absorbed classes are explicit.
3. [x] Record evidence and validation -> verify: evidence file names checks and outputs.
4. [x] Update state and master plan -> verify: active state points to shipped wave and next recommended work.
