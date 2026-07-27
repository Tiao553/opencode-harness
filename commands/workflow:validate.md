---
description: Multi-agent quality gate via Copilot-native juntas (Phase 3.5)
agent: workflow.validate-agent
subtask: true
---

# /workflow:validate Command

> **AgentSpec Isolation (ADR-0004):** This command routes to the AgentSpec workflow. It must NOT write to `.specs/changes/` or invoke Altitude phase agents. Artifacts go to `sdd/features/{feature-name}/`.


Execute the global `/workflow:validate` command.

Before acting, read these files:
- `~/.config/opencode/skills/workflow-commands/SKILL.md`
- `~/.config/opencode/skills/workflow-commands/commands/validate.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.
