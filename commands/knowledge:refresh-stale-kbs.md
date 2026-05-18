---
description: Identify stale KB domains and route each stale domain through /knowledge:update-kb
agent: architect.kb-architect
subtask: true
---

# /knowledge:refresh-stale-kbs Command

Execute the global `/knowledge:refresh-stale-kbs` command.

Before acting, read these files:
- `~/.config/opencode/skills/knowledge/SKILL.md`
- `~/.config/opencode/skills/knowledge/commands/refresh-stale-kbs.md`

Treat those files as the canonical workflow for this command.
User arguments: `$ARGUMENTS`

If the command references supporting artifacts, load them lazily from `~/.config/opencode/`.
