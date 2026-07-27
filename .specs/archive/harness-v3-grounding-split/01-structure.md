# Harness V3 Grounding Split - Structure

## Source Surfaces

| Surface | Role |
| --- | --- |
| `config/grounding.md` | thin index after this wave |
| `.specs/shared/runtime-policy.md` | runtime enforcement posture |
| `.specs/shared/context-loading-policy.md` | context loading |
| `.specs/shared/state-resolution-contract.md` | state precedence |
| `.specs/shared/phase-engine-contract.md` | phase semantics |
| `.specs/shared/execution-loop-contract.md` | Ralph Loop |
| `.specs/shared/documentation-mode-policy.md` | dense docs mode |
| `.specs/shared/production-code-mode-policy.md` | simple-first code mode |
| `.specs/shared/compatibility-policy.md` | legacy compatibility |
| `.specs/shared/ask-user-policy.md` | structured clarification |
| `.specs/shared/todo-allocation-contract.md` | todo projection |
| `.specs/shared/specialist-allocation-contract.md` | specialist allocation |
| `.specs/shared/state-conflict-resolution-policy.md` | conflict gate |

## Boundary

This wave changes documentation/policy routing only. It does not make plugins enforce new rules.

## Risk

The main risk is losing a legacy rule while replacing prose with references. The mitigation is to map every existing grounding concern to a shared contract owner.

