# Harness V3 Strategic Coordinator Introduction - Structure

## Affected Surfaces

| Surface | Role |
| --- | --- |
| `agents/altitude.agent.md` | new visible coordinator |
| `agents/altitude-*.agent.md` | internal phase-specific helpers |
| `opencode.json` | visible/hidden agent registry |
| `docs/HARNESS_V3_COORDINATOR_CONTRACT.md` | source contract |
| `.specs/shared/*` | phase/state/allocation contracts |

## Architecture

```text
User
  -> altitude
  -> state resolver
  -> phase detection
  -> internal altitude-* subagent recommendation or task
  -> validation/report/ship
```

## Risk

Demoting phase agents can break direct user entrypoints if the runtime ignores `hidden` or `subagent` differently than expected. Rollback is restoring the old `opencode.json` primary entries and phase-agent frontmatter modes.

