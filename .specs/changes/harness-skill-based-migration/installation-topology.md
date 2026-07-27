# T-008 Installation Topology

## Metadata

- Source: T-002 configuration provenance and T-007 runtime baseline.
- Verification: `opencode debug paths` and filesystem discovery checks.
- Rollback: documentation-only.
- Limitation: no separate project-local installation exists to exercise override behavior; W11 T-159 owns fixture validation.

| Surface | Resolved location | Status |
|---|---|---|
| Repository and global config root | `~/.config/opencode` | Same physical directory |
| OpenCode executable | `~/.nvm/versions/node/v24.16.0/bin/opencode` | NVM-managed |
| Global agents, commands, skills, plugins | `~/.config/opencode/{agents,commands,skills,plugins}` | Active discovery locations |
| Project-local `.opencode/` | Absent | No override layer present |
| External skills | `~/.claude/skills`, `~/.agents/skills` | Not present on this host |
| Runtime state | `~/.local/state/opencode` | OpenCode-managed |

No target migration path may depend on `/home/ubuntu`; all runtime references use `~` or the discovered config root. A project-local `AGENTS.md` is additive to the global harness according to OpenCode instruction discovery; no project-local file exists in this repository.
