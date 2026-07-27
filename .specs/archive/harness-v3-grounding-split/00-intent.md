# Harness V3 Grounding Split - Intent

## Problem

`config/grounding.md` still mixes runtime policy, context loading, permissions, skill priority, SDD compatibility, language policy, execution loop, token budget, compression behavior, and miscellaneous rules. Harness V3 requires grounding to become a thin index so each concern has one owning contract under `.specs/shared`.

## Objective

Split grounding into a lightweight routing/index surface that points to shared policy contracts.

## Scope

- Replace monolithic policy detail in `config/grounding.md` with references to `.specs/shared/*`.
- Preserve the important behavior by pointing to the new owners.
- Do not mutate runtime plugins or command behavior in this wave.

## Non-Goals

- Rewire OpenCode runtime.
- Remove workflow commands.
- Implement semantic fixture runner.
- Change agent prompts.

## Success Criteria

- `config/grounding.md` is a thin index.
- Each major concern points to an owning `.specs/shared` file.
- Legacy workflow references are marked compatibility or migration-only.
- Docs mode and code mode are separated.
- Ask-User, todo projection, and specialist allocation are explicit references.

