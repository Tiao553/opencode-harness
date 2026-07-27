# TSI-001 - Create Task-Spec Bridge

## Status

validated

## Objective

Document and template the mapping from Harness V3 `.specs` task contracts into Task-Spec leaf tasks.

## Acceptance Criteria

- `docs/HARNESS_V3_TASK_SPEC_INTEGRATION.md` exists and defines the `.specs -> Task-Spec -> execution -> validation -> state` flow.
- Task-Spec template includes additive Harness V3 bridge fields.
- Generator writes safe default values for bridge fields.
- Fixture 10 remains valid under the Harness V3 fixture validator.

## Steps

1. [x] Add integration doc -> verify: mapping table exists.
2. [x] Add template/generator bridge fields -> verify: markers exist in generated template path.
3. [x] Validate fixture and markers -> verify: all checks pass.
4. [x] Record evidence and ship -> verify: active state and master plan point to this wave.
