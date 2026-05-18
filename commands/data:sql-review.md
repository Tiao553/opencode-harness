---
description: SQL-specific code review — delegates to sql-optimizer + code-reviewer agents
agent: data-engineering.sql-optimizer
subtask: true
---

# /data:sql-review Command

Execute the global `/data:sql-review` command.

Before acting, read these files:
- `~/.config/opencode/skills/data-engineering/SKILL.md`
- `~/.config/opencode/skills/data-engineering/commands/sql-review.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.
