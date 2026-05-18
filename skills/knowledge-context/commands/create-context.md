---
name: create-context
description: Create a complete knowledge context for a new project from templates
---

# Create Context Command

> Scaffold a full knowledge context for a project. Copies all templates, registers the project, and optionally sets it as active.

## Usage

```bash
/context:create-context <slug>
/context:create-context <slug> --name "<Project Name>"
/context:create-context <slug> --set-active
```

**Examples**:
```bash
/context:create-context my-api
/context:create-context data-platform --name "Data Platform v2" --set-active
/context:create-context mobile-app --name "Mobile App"
```

---

## What Happens

1. **Validate prerequisites**
   - Check that `~/.config/opencode/knowledge_context/_templates/` exists
   - If `_registry.yaml` does not exist, create it with base structure
   - Check if the slug already exists — if so, ask before overwriting

2. **Normalize slug**
   - Convert to `kebab-case`
   - e.g. `My Project` → `my-project`, `DATA_PLATFORM` → `data-platform`

3. **Scaffold directory**
   - Create `~/.config/opencode/knowledge_context/{slug}/`
   - Copy all files from `~/.config/opencode/knowledge_context/_templates/`
   - Replace `{Project Name}` and `{slug}` in the copied files

4. **Register project**
   - Add entry to `_registry.yaml` with `slug`, `name`, `created_at`, `context_files`
   - If `--set-active`: update `active_project: {slug}`

5. **Report**
   - List created files
   - Indicate the required fields to fill in `KNOWLEDGE_CONTEXT.md`

---

## Quality Gates

Before creating:

- Slug must be in `kebab-case`.
- Slug cannot overwrite an existing context without explicit user confirmation.
- Required templates must exist in `_templates/`.

---

## Output

```text
Knowledge Context Created: ~/.config/opencode/knowledge_context/{slug}/
Files:
  ✅ KNOWLEDGE_CONTEXT.md    ← fill in: deployment_context, business_context
  ✅ architecture.md         ← fill in: stack, components
  ✅ rules.md                ← fill in: conventions, guardrails
  ✅ roadmap.md              ← fill in: milestones, current phase
  ✅ domain-glossary.md      ← fill in: entities, terms
  ✅ integrations.md         ← fill in: external APIs, contracts

Registry: ~/.config/opencode/knowledge_context/_registry.yaml
Active Project: {slug} (if --set-active) | unchanged (if not)

Next: fill KNOWLEDGE_CONTEXT.md with deployment_context before running /workflow:brainstorm
```

---

## Next Step

`/context:check-context {slug}` — to audit what still needs to be filled in.

## See Also

- **Templates**: `~/.config/opencode/knowledge_context/_templates/`
- **Registry**: `~/.config/opencode/knowledge_context/_registry.yaml`
- **Design**: `~/.config/opencode/sdd/features/knowledge-context/DESIGN_KNOWLEDGE_CONTEXT.md`
