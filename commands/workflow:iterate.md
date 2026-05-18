---
description: Update any phase document when requirements or design change (Cross-Phase)
agent: workflow.iterate-agent
subtask: true
---

Execute the global `/workflow:iterate` command.

Before acting, read these files:
- `~/.config/opencode/skills/workflow-commands/SKILL.md`
- `~/.config/opencode/skills/workflow-commands/commands/iterate.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.
