# Structure

## Surfaces

| Surface | Role |
| --- | --- |
| `docs/HARNESS_V3_PHASE_ENGINE_SPEC.md` | shareable phase model and workflow absorption explanation |
| `.specs/shared/phase-engine-contract.md` | operational contract loaded by grounding |
| `.specs/shared/compatibility-policy.md` | legacy command compatibility classification |
| `sdd/architecture/WORKFLOW_CONTRACTS.yaml` | legacy workflow semantics source, migration reference only |
| `config/grounding.md` | thin index over shared contracts |
| `test/fixtures/harness-v3/` | preservation fixtures |

## Risk

Primary risk is losing workflow lifecycle behavior while claiming V3 owns the phase model. This wave is contract-only, so runtime risk is low, but semantic regression risk is medium.

## Validation Strategy

- Confirm shared contract references exist.
- Confirm V3 fixture contract still passes.
- Confirm coordinator config still exposes only `altitude` and `data-engineer` as visible primary coordinators.
- Confirm phase contract names workflow compatibility explicitly.
