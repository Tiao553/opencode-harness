# Harness V3 Safety Foundation - Structure

## Repo Surfaces

| Surface | Role |
| --- | --- |
| `docs/HARNESS_V3_*.md` | shareable architecture and migration contracts |
| `.specs/shared/*.md` | operational policy contracts used by coordinators |
| `.specs/templates/*.md` | artifact templates for planning, decisions, validation, and shipping |
| `test/fixtures/harness-v3/*.md` | golden behavior snapshots |
| `.specs/changes/harness-v3-safety-foundation/` | operational ledger for this safety-foundation slice |

## Architecture Boundary

```text
Roadmap
  -> safety contracts
  -> artifact templates
  -> golden fixtures
  -> later runtime mutation
```

This change stops before runtime mutation.

## Risks

| Risk | Mitigation |
| --- | --- |
| Fixtures too weak to protect behavior | include route, mode, artifacts, allocation, context, todos, validation, state, and forbidden behavior in every fixture |
| Docs drift from active state | record this work in `.specs/changes/harness-v3-safety-foundation/` |
| Runtime mutation starts too early | state explicitly that runtime mutation remains blocked until fixtures are reviewed and extended |

