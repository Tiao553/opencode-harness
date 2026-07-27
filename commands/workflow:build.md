---
description: Execute implementation with on-the-fly task generation (Phase 3)
agent: workflow.build-agent
subtask: true
---

# /workflow:build Command

> **AgentSpec Isolation (ADR-0004):** This command routes to the AgentSpec workflow. It must NOT write to `.specs/changes/` or invoke Altitude phase agents. Artifacts go to `sdd/features/{feature-name}/`.


Execute the global `/workflow:build` command.

Before acting, read these files:
- `~/.config/opencode/skills/workflow-commands/SKILL.md`
- `~/.config/opencode/skills/workflow-commands/commands/build.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.

## Build Output Gate (mandatory — ADR-0004, WORKFLOW_CONTRACTS.yaml)

Before reading DESIGN or creating any file, ask the user where to write output:

```
Use the question tool IMMEDIATELY. Do NOT read output_path from DESIGN.
Do NOT suggest ./projects/ or any default. Ask first, then proceed.
```
