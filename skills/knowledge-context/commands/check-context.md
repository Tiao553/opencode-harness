---
name: check-context
description: Audit the knowledge context of a project — reports completeness, gaps, and health score
---

# Check Context Command

> Audit the knowledge context for a project. Reports which files exist, which fields are filled, and produces a health score with actionable gaps.

## Usage

```bash
/context:check-context
/context:check-context <slug>
/context:check-context --all
```

**Examples**:
```bash
/context:check-context
/context:check-context data-platform
/context:check-context --all
```

---

## What Happens

1. **Resolve target**
   - No argument: use `active_project` from `_registry.yaml`
   - With `<slug>`: audit that specific project
   - With `--all`: audit all registered projects

2. **Registry check**
   - Does `_registry.yaml` exist?
   - Does `active_project` point to a valid slug?
   - Does the project have an entry in the registry?

3. **File check** — for each project file:

   | File | Required | Check |
   |---|---|---|
   | `KNOWLEDGE_CONTEXT.md` | ✅ Yes | `deployment_context` filled? `business_context` filled? `Last Updated` recent? |
   | `architecture.md` | Recommended | Stack defined? Component map present? |
   | `rules.md` | Recommended | Conventions listed? Anti-patterns defined? |
   | `roadmap.md` | Optional | Current phase defined? Milestones listed? |
   | `domain-glossary.md` | Optional | Core entities defined? |
   | `integrations.md` | Optional | External APIs documented? |

4. **Health score** — deterministic calculation (0–100):

   | Item | Weight |
   |---|---|
   | `KNOWLEDGE_CONTEXT.md` exists and complete | 30 |
   | `architecture.md` exists and filled | 25 |
   | `rules.md` exists and filled | 20 |
   | `roadmap.md` exists | 10 |
   | `domain-glossary.md` exists | 8 |
   | `integrations.md` exists | 7 |

5. **Gap report** — list fields with `{placeholder}` or empty as concrete action items

6. **Cascade warning** — if `active_project` changed recently, alert about in-progress features

---

## Quality Gates

Before reporting:

- If `_registry.yaml` does not exist: report as critical gap, suggest `/context:create-context`.
- If `active_project` has no corresponding directory: report as critical gap.
- Never infer data — report only what literally exists.

---

## Output

```text
╔══════════════════════════════════════════════════╗
║  Knowledge Context Audit: {slug}                ║
║  Active: {"yes" | "no"}                         ║
╚══════════════════════════════════════════════════╝

Registry
  ✅ _registry.yaml exists
  ✅ active_project: {slug}

Files
  ✅ KNOWLEDGE_CONTEXT.md    — complete
  ✅ architecture.md         — complete
  ⚠️  rules.md               — exists but anti-patterns section empty
  ⬜ roadmap.md              — missing
  ⬜ domain-glossary.md      — missing
  ⬜ integrations.md         — missing

Fields Gap (KNOWLEDGE_CONTEXT.md)
  ⚠️  deployment_context.entry_points — still placeholder
  ✅ deployment_context.stack         — filled
  ✅ business_context                 — filled

Health Score: 72/100  🟡 MEDIUM

Action Items
  1. Fill deployment_context.entry_points in KNOWLEDGE_CONTEXT.md
  2. Complete rules.md anti-patterns section
  3. Create roadmap.md — run: /context:update-context {slug} --file roadmap.md

Next /workflow:brainstorm will inject: stack, entry_points, business_context automatically.
```

---

## Next Steps

- Gaps found → `/context:update-context {slug} --file <filename>`
- Project does not exist → `/context:create-context {slug}`

## See Also

- **Registry**: `~/.config/opencode/knowledge_context/_registry.yaml`
- **Create command**: `~/.config/opencode/skills/knowledge-context/commands/create-context.md`
- **Update command**: `~/.config/opencode/skills/knowledge-context/commands/update-context.md`
- **Design**: `~/.config/opencode/sdd/features/knowledge-context/DESIGN_KNOWLEDGE_CONTEXT.md`
