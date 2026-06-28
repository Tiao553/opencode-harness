---
description: Capture and validate requirements in one pass (Phase 1)
agent: workflow.define-agent
subtask: true
---

# /workflow:define Command

Execute the global `/workflow:define` command.

Before acting, read these files:
- `~/.config/opencode/skills/workflow-commands/SKILL.md`
- `~/.config/opencode/skills/workflow-define/SKILL.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.
