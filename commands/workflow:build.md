---
description: Execute implementation with on-the-fly task generation (Phase 3)
agent: workflow.build-agent
subtask: true
---

Execute the global `/workflow:build` command.

Before acting, read these files:
- `~/.config/opencode/skills/workflow-commands/SKILL.md`
- `~/.config/opencode/skills/workflow-commands/commands/build.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.
