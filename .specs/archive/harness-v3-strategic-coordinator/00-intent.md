# Harness V3 Strategic Coordinator Introduction - Intent

## Problem

The current runtime exposes seven phase-specific `altitude-*` agents as primary entrypoints. Harness V3 requires one visible strategic coordinator, `Altitude`, that owns durable strategic work and routes internally through phase contracts and phase-specific helper agents.

## Objective

Introduce one visible `altitude` coordinator while preserving the existing phase-specific altitude agents as internal subagents.

## Constraints

- Do not delete phase-specific agent files.
- Do not remove the ability to route to Intent, Structure, Plan, Execution, Validation, Report, or Memory behavior.
- Keep command removal out of scope.
- Keep Data Engineer coordinator for a later wave.

## Success Criteria

- `agents/altitude.agent.md` exists.
- `opencode.json` exposes `altitude` as primary.
- `altitude-*` phase agents are no longer primary user entrypoints.
- Phase detection and routing are described in the coordinator prompt.
- Config validates as JSON.

