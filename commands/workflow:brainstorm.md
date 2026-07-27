---
description: Explore ideas through collaborative dialogue before requirements
  capture (Phase 0)
agent: workflow.brainstorm-agent
subtask: true
---

# /workflow:brainstorm Command

> **AgentSpec Isolation (ADR-0004):** This command routes to the AgentSpec workflow. It must NOT write to `.specs/changes/` or invoke Altitude phase agents. Artifacts go to `sdd/features/{feature-name}/`.


Execute the global `/workflow:brainstorm` command.

Before acting, read these files:
- `~/.config/opencode/skills/workflow-commands/SKILL.md`
- `~/.config/opencode/skills/workflow-commands/commands/brainstorm.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.
