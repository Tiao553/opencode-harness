# Harness V3 Tactical Data Engineer Coordinator - Structure

## Affected Surfaces

| Surface | Role |
| --- | --- |
| `agents/data-engineer.agent.md` | visible tactical coordinator |
| `docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md` | model/source doc |
| `docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md` | tactical routing contract |
| `skills/data-engineering/SKILL.md` | compatibility skill |
| `skills/data-engineering/routing_skill.json` | legacy route map |
| `opencode.json` | visible coordinator registration |

## Architecture

```text
User tactical data request
  -> data-engineer
  -> classify domain and artifact
  -> select internal route/specialist
  -> verify with data-specific evidence
  -> escalate to Altitude only if work becomes durable/strategic
```

## Risk

The main risk is routing strategic work into a tactical path. The coordinator prompt must explicitly stop and recommend Altitude when the work is broad, multi-wave, or architecture-program scale.

