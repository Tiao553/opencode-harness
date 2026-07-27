# RLG-001 - Globalize Ralph Loop Contract

## Status

validated

## Objective

Make Ralph Loop posture explicit and required for executable work, with a manual fallback when `verify_step` is unavailable.

## Acceptance Criteria

- `execution-loop-contract.md` defines mandatory/advisory/not-applicable posture.
- `execution-loop-contract.md` maps work classes to loop requirements.
- `task-contract.md` requires loop posture and evidence for executable tasks.
- coordinator contract states when to call `verify_step` versus manual evidence.
- validation proves markers and standard V3 fixture checks pass.

## Steps

1. [x] Harden execution-loop contract -> verify: posture and gate mapping exist.
2. [x] Update task/todo/coordinator contracts -> verify: loop posture is referenced.
3. [x] Validate markers and fixtures -> verify: all checks pass.
4. [x] Record evidence and ship -> verify: active state and master plan point to this wave.
