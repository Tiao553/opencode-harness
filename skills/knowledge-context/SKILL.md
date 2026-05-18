---
name: knowledge-context
description: Reusable project context guidance for the native commands
  /context:create-context, /context:update-context, and /context:check-context. Load this skill when
  managing knowledge context files under ~/.config/opencode/knowledge_context/.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 1.0.0
  category: commands
  migrated-from: ~/.config/opencode/skills/knowledge-context/
---

# Knowledge Context Commands

> Used by the native commands: `/context:create-context`, `/context:update-context`, `/context:check-context`

## Mandatory Global Rules

These rules apply to all commands in this skill. If there is a conflict with migrated legacy blocks, this section wins.

### Grounding and Agent

1. Consult `~/.config/opencode/config/grounding.md` only when policy, security, or SDD gates are needed.
2. Read `~/.config/opencode/config/routing.json`; if no specific route matches, execute directly without delegating to a specialist agent.
3. Load only the necessary context files from `~/.config/opencode/knowledge_context/{slug}/`; never load all projects at once.
4. Include route diagnostics only when useful for planning, debugging, validation, or auditability.

### Canonical Paths

| Type | Correct path |
|---|---|
| Registry | `~/.config/opencode/knowledge_context/_registry.yaml` |
| Templates | `~/.config/opencode/knowledge_context/_templates/` |
| Root context | `~/.config/opencode/knowledge_context/{slug}/KNOWLEDGE_CONTEXT.md` |
| Architecture | `~/.config/opencode/knowledge_context/{slug}/architecture.md` |
| Rules | `~/.config/opencode/knowledge_context/{slug}/rules.md` |
| Roadmap | `~/.config/opencode/knowledge_context/{slug}/roadmap.md` |
| Glossary | `~/.config/opencode/knowledge_context/{slug}/domain-glossary.md` |
| Integrations | `~/.config/opencode/knowledge_context/{slug}/integrations.md` |

### Minimum Knowledge Context Structure

```text
~/.config/opencode/knowledge_context/{slug}/
├── KNOWLEDGE_CONTEXT.md     ← required
├── architecture.md          ← recommended
├── rules.md                 ← recommended
├── roadmap.md               ← optional
├── domain-glossary.md       ← optional
└── integrations.md          ← optional
```

Create files from `~/.config/opencode/knowledge_context/_templates/`:

| Output | Template |
|---|---|
| `KNOWLEDGE_CONTEXT.md` | `_templates/KNOWLEDGE_CONTEXT.md` |
| `architecture.md` | `_templates/architecture.md` |
| `rules.md` | `_templates/rules.md` |
| `roadmap.md` | `_templates/roadmap.md` |
| `domain-glossary.md` | `_templates/domain-glossary.md` |
| `integrations.md` | `_templates/integrations.md` |
| registry entry | `_registry.yaml` field `projects[]` |

If `~/.config/opencode/knowledge_context/_registry.yaml` does not exist, create it with a base structure before registering the first project. If it exists, update only the entry for the impacted project.

## Available Commands

| Command | Description | File |
|---|---|---|
| `/context:create-context` | Create a complete knowledge context for a project | `commands/create-context.md` |
| `/context:update-context` | Update context files for an existing project | `commands/update-context.md` |
| `/context:check-context` | Audit the active knowledge context and report gaps | `commands/check-context.md` |

### Escalation

- If `/context:create-context` reveals a conflict with an existing slug, ask before overwriting.
- If `/context:update-context` reveals a large architectural change, propose a plan before editing multiple files.
- If `/context:check-context` detects `active_project` pointing to a non-existent slug, fix the registry before continuing.

## See Also

- **Registry**: `~/.config/opencode/knowledge_context/_registry.yaml`
- **Templates**: `~/.config/opencode/knowledge_context/_templates/`
- **Design**: `~/.config/opencode/sdd/features/knowledge-context/DESIGN_KNOWLEDGE_CONTEXT.md`
