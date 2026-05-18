---
name: update-context
description: Update context files for an existing project — full file or targeted section
---

# Update Context Command

> Update one or more context files for an existing project. Supports full file update or targeted section edit.

## Usage

```bash
/context:update-context <slug>
/context:update-context <slug> --file <filename>
/context:update-context <slug> --file architecture.md
/context:update-context <slug> --set-active
```

**Examples**:
```bash
/context:update-context my-api
/context:update-context data-platform --file architecture.md
/context:update-context mobile-app --file rules.md
/context:update-context my-api --set-active
```

---

## What Happens

1. **Load current state**
   - Read `_registry.yaml` and verify the slug exists
   - If `--file` specified: load only that file
   - If not specified: load `KNOWLEDGE_CONTEXT.md` + list existing files and ask which one to update

2. **Identify changes**
   - Show current content of the file(s)
   - Ask what needs to be updated (field, section, or full file)
   - Classify impact: Additive (new field) / Modifying (change existing) / Architectural (stack or structure change)

3. **Apply update**
   - Edit the specified fields/sections
   - Update the `Last Updated: YYYY-MM-DD` field in `KNOWLEDGE_CONTEXT.md`
   - If `--set-active`: update `active_project` in `_registry.yaml`

4. **Cascade check**
   - If `deployment_context` or stack changed: warn that in-progress features (BRAINSTORM/DEFINE/DESIGN) may need `/workflow:iterate`

5. **Report**
   - List modified fields
   - Indicate whether a cascade was detected

---

## Quality Gates

Before updating:

- Slug must exist in `_registry.yaml`.
- Architectural changes (stack, cloud, structure) must be confirmed before applying.
- `Last Updated` field must be updated on every edit to `KNOWLEDGE_CONTEXT.md`.

---

## Output

```text
Knowledge Context Updated: ~/.config/opencode/knowledge_context/{slug}/
Changes:
  ✅ {filename} — {changed fields}

Last Updated: YYYY-MM-DD

Cascade Warning (if applicable):
  ⚠️  deployment_context changed — review in-progress BRAINSTORM/DEFINE/DESIGN with /workflow:iterate
```

---

## Next Step

`/context:check-context {slug}` — to confirm the context is complete after the update.

## See Also

- **Registry**: `~/.config/opencode/knowledge_context/_registry.yaml`
- **Iterate command**: `~/.config/opencode/skills/workflow-commands/commands/iterate.md`
- **Design**: `~/.config/opencode/sdd/features/knowledge-context/DESIGN_KNOWLEDGE_CONTEXT.md`
