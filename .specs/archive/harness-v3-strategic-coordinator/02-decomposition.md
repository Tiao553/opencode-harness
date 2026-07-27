# Harness V3 Strategic Coordinator Introduction - Decomposition

## Task SC-001 - Introduce Altitude Coordinator

status: ready

### Allowed Files

- `agents/altitude.agent.md`
- `agents/altitude-intent.agent.md`
- `agents/altitude-structure.agent.md`
- `agents/altitude-plan.agent.md`
- `agents/altitude-execution.agent.md`
- `agents/altitude-validation.agent.md`
- `agents/altitude-report.agent.md`
- `agents/altitude-memory.agent.md`
- `opencode.json`
- `.specs/changes/harness-v3-strategic-coordinator/*`
- `.specs/memory/active-state.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`

### Verification

- `opencode.json` parses as JSON.
- exactly one `altitude` primary entry exists in config.
- phase-specific altitude agents are configured as subagents and hidden.
- all phase-agent files exist.

