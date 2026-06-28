# Harness V3 Legacy Preservation Matrix

## Purpose

Record which legacy surfaces are retained, absorbed, deprecated, or removed, and what behavior must be preserved before removal.

## Matrix

| Legacy surface | Current role | V3 disposition | Preserve before removal |
| --- | --- | --- | --- |
| `workflow:*` commands | lifecycle command surface | compatibility wrappers | command intent maps to Altitude phases |
| phase-specific workflow agents | phase behavior prompts | absorb into coordinator/contracts | phase semantics and validation gates |
| `config/grounding.md` monolith | mixed policy source | thin index | referenced policies split into shared contracts |
| `commands/context:*` | old context lifecycle commands | remove or absorb | memory/context behavior under `.specs/memory` |
| legacy skills for broad workflow | duplicate process docs | archive/remove after replacements | useful process rules captured in contracts |
| `sdd/architecture/WORKFLOW_CONTRACTS.yaml` | workflow source of truth | legacy/reference | preserved rules mapped into phase engine |
| `plugins/specs-state.ts` | intended state enforcement | enforce or demote | state blocking behavior or explicit advisory status |
| `plugins/rtk-native.ts` | token-saving runtime | enforce or remove | measurable RTK availability |
| `plugins/headroom-guard.ts` | context budget runtime | enforce or remove | measurable budget behavior |

## Preservation Rule

Do not delete a legacy surface until:

1. its useful behavior is named
2. the new owner is named
3. a golden fixture proves replacement behavior
4. rollback instructions exist

## Removal Classes

| Class | Meaning |
| --- | --- |
| retained | remains primary and documented |
| compatibility | remains but routes through V3 |
| absorbed | behavior moves to coordinator/contract/skill |
| advisory | no longer enforcement-critical |
| removed | deleted after fixtures pass |

## Risk Controls

- Soft-deprecate before hard removal.
- Keep command removal late in the migration.
- Treat runtime plugins as high-risk until fixture-backed.
- Never remove a user-facing entrypoint and a behavior owner in the same unvalidated step.

