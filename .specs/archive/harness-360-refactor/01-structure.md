# Harness 360 Refactor - Structure

## Affected Modules

- `AGENTS.md`
- `README.md`
- `docs/`
- `.specs/shared/`
- `.specs/templates/`
- `config/routing.json`
- `opencode.json`
- `plugins/`
- `agents/`
- `skills/`
- `kb/`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`

## Likely Files

### Control plane and policy

- `AGENTS.md`
- `README.md`
- `docs/ALTITUDE_SPECS_HARNESS.md`
- `.specs/shared/altitude-contract.md`
- `.specs/shared/mcp-governance.md`
- `.specs/shared/definition-of-done.md`

### Routing and intake

- `config/routing.json`
- `agents/graph-router.agent.md`
- `agents/dev.agent-router.agent.md`
- `agents/dev.codebase-explorer.agent.md`
- new interview/grill skill surfaces

### Execution enforcement

- `opencode.json`
- `plugins/permission-hardening.ts`
- `plugins/specs-state.ts`
- `plugins/context-budget.ts`
- `plugins/rtk-native.ts`

### Workflow compatibility

- `skills/workflow-commands/SKILL.md`
- `skills/workflow-commands/commands/*.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`

### KB and domain repair

- `skills/knowledge/*`
- `agents/architect.kb-architect.agent.md`
- `kb/microsoft-fabric/**`
- `agents/platform.fabric-*.agent.md`

## Impacted Contracts

- `.specs/shared/change-request-contract.md`
- `.specs/shared/task-contract.md`
- `.specs/shared/mcp-governance.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- plugin-based permission shaping in `plugins/permission-hardening.ts`

## Dependencies

- strict config compatibility with `https://opencode.ai/config.json`
- live plugin load order from `opencode.json`
- current routing behavior in `config/routing.json`
- current KB posture and agent prompts

## Technical Constraints

- this harness uses both shareable versioned docs and private ignored operational state
- `plugins/specs-state.ts` cannot yet hard-stop edits dynamically
- `knowledge_context/` is referenced but absent, so replacement must be staged carefully
- agent permissions are partly defined in files and then reshaped at runtime by plugins

## Structural Risks

- split-brain between `Altitude + .specs` and `workflow:* + sdd/features`
- prompt-enforced behavior that exceeds runtime enforcement
- broken or stale surfaces such as `knowledge_context/`
- conflicting KB claims in critical domains
- disabled/stale agents continuing to inflate maintenance and routing complexity

## Known Gaps

- no authoritative decomposition engine doc yet
- no central MCP matrix existed before this change
- no KB governance standard doc existed before this change
