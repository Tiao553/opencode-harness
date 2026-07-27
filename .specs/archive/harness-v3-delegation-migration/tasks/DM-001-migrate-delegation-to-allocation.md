# DM-001 - Migrate Delegation to Allocation

## Status

validated

## Objective

Make specialist delegation a pre-execution allocation field with grounding, evidence, verification, and over-delegation rules.

## Acceptance Criteria

- specialist allocation includes grounding bundle and evidence contract.
- local allocation and task contract reference specialist allocation before execution.
- coordinator guidance says specialists cannot become hidden owners.
- validation proves delegation markers and standard V3 gates pass.

## Steps

1. [x] Harden specialist allocation contract -> verify: grounding/evidence/over-delegation sections exist.
2. [x] Update local/task/coordinator guidance -> verify: specialist allocation is pre-execution.
3. [x] Validate markers and fixtures -> verify: all checks pass.
4. [x] Ship and update state -> verify: active state and master plan point to this wave.
