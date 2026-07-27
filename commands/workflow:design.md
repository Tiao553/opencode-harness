---
description: Create architecture and technical specification (Phase 2)
agent: workflow.design-agent
subtask: true
---

# /workflow:design Command

> **AgentSpec Isolation (ADR-0004):** This command routes to the AgentSpec workflow. It must NOT write to `.specs/changes/` or invoke Altitude phase agents. Artifacts go to `sdd/features/{feature-name}/`.


Execute the global `/workflow:design` command.

Before acting, read these files:
- `~/.config/opencode/skills/workflow-commands/SKILL.md`
- `~/.config/opencode/skills/workflow-design/SKILL.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.
