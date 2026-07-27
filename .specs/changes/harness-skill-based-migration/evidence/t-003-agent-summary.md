# T-003 Agent Capability Summary

- Custom agents represented: 75.
- Custom primary agents: altitude-maestro, data-engineer.
- Agents effectively able to call Task: 75, inherited from global permission.
- Agents effectively able to write TODO: 75, inherited from global permission.
- Six dev-agent conversion targets: dev.codebase-explorer, dev.faithfulness-guard, dev.judge-agent, dev.prompt-crafter, dev.security-guardian, dev.shell-script-specialist.
- Inline-only agents: data-engineer.

## Findings

- `data-engineer` remains an inline custom primary while its file is deleted from the worktree.
- `altitude-maestro` is the remaining file-backed custom primary.
- The current global permission allows Task and TODOWRITE, so absent per-agent denial is not an effective restriction.
- No current agent uses a declared `todowrite` permission; effective access is inherited from global configuration.
