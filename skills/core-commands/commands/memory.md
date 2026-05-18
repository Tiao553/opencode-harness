---
name: memory
description: Save valuable insights from the current session to storage
---

# Memory Command

Save session insights to `~/.config/opencode/storage/` for future reference (directory is auto-created on first use).

## Usage

```bash
/core:memory                           # Save current session insights
/core:memory "specific note to save"   # Save with specific context
```

---

## What It Does

1. **Analyzes** current conversation for valuable insights
2. **Compresses** to high-signal format (decisions, patterns, gotchas)
3. **Saves** to `~/.config/opencode/storage/memory-{YYYY-MM-DD}.md`

---

## When to Use

Use `/core:memory` when you've discovered something worth remembering:

- ✅ Non-obvious decisions with rationale
- ✅ Patterns that worked well
- ✅ Gotchas discovered
- ✅ Architecture decisions
- ✅ Terminology clarifications

**Don't save:**

- ❌ Step-by-step implementation details (obvious from code)
- ❌ Temporary debugging info
- ❌ Every session (only valuable ones)

---

## Output Format

Creates: `~/.config/opencode/storage/memory-{YYYY-MM-DD}.md`

```markdown
# Memory: {date}

> {One-line summary of session}

## Decisions Made

| Decision | Rationale | Impact |
| -------- | --------- | ------ |
| {what} | {why} | {files affected} |

## Patterns Discovered

- {pattern}: {where applied}

## Gotchas

- {gotcha}: {how to avoid}

## Open Items

- [ ] {item for next session}

---
*Saved: {timestamp}*
```

---

## Process

When invoked:

```text
1. Scan conversation for:
   - Decisions (look for "decided", "chose", "will use")
   - Patterns (look for reusable solutions)
   - Gotchas (look for "gotcha", "watch out", "careful")
   - Open items (look for "TODO", "later", "next time")

2. Compress ruthlessly:
   - Max 5 decisions
   - Max 3 patterns
   - Max 3 gotchas
   - Max 3 open items

3. Write to storage:
   - Create ~/.config/opencode/storage/ if not exists
   - Append to existing file if same date
   - Use consistent format
```

---

## Example

```text
User: /core:memory "Completed authentication refactoring"

→ Scanning conversation...
→ Found: 2 decisions, 1 pattern, 1 gotcha

Saved to: ~/.config/opencode/storage/memory-2026-01-23.md

## Preview:
> Completed authentication refactoring with JWT + refresh tokens

| Decision | Rationale |
| -------- | --------- |
| Use JWT + refresh | Stateless, scales better |
| 15min access token | Balance security/UX |

Pattern: Token rotation on refresh

Gotcha: Must invalidate refresh tokens on password change
```

---

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Input check | Sessão contém pelo menos 1 insight identificável (decisão, padrão ou gotcha) | Alerte que não há conteúdo relevante para salvar |
| Compression check | Output comprimido respeita limites (máx 5 decisões, 3 padrões, 3 gotchas) | Reaplique compressão |
| Storage check | Arquivo `~/.config/opencode/storage/memory-{date}.md` criado/atualizado corretamente | Reporte erro |
| Output check | Formato do arquivo segue template padrão com todas as seções | Reporte erro |

## Best Practices

| Do | Don't |
| -- | ----- |
| Save only valuable insights | Save every session |
| Compress ruthlessly | Write long summaries |
| Reference file paths | Duplicate code comments |
| Store decisions + rationale | Store implementation details |
