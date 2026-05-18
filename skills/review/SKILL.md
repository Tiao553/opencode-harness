---
name: review
description: Reusable review guidance for the native commands /review:review and
  /review:judge. Load this skill when reviewing code or requesting a second opinion.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 1.0.0
  category: commands
---

# Review Commands

Invoke as:

```text
/review:review <file-or-directory>
/review:judge <file> [--context "..."] [--model <openrouter-model>]
/review:judge --ledger
```

## Grounding

1. Consult `~/.config/opencode/config/grounding.md` only when policy, security, or SDD gates are needed.
2. Treat this skill as the primary routing source.
3. For `/review:review`, use `~/.config/opencode/agents/python.code-reviewer.agent.md`.
4. For `/review:judge`, use `~/.config/opencode/agents/dev.judge-agent.agent.md`.
5. Load only the KB files required by the selected agent or by the reviewed domain.

## /review:review

Use for code review, config review, migration review, and documentation review.

Execution:

1. Read the target file or directory.
2. Use the code-review stance: findings first, ordered by severity.
3. Cite concrete file paths and line numbers.
4. Include missing tests or residual risks.

## /review:judge

Use for a second opinion on high-risk or ambiguous output.

Execution:

1. Read `~/.config/opencode/agents/dev.judge-agent.agent.md`.
2. If the request targets a file, read the file before judging.
3. If an external judge runtime is configured and `OPENROUTER_API_KEY` is available, run that runtime.
4. If the runtime or key is missing, stop and report the missing prerequisite instead of inventing an external verdict.
5. Write ledger entries only to `~/.config/opencode/storage/judge-ledger.jsonl`.

## Comandos Disponíveis

| Comando | Descrição | Arquivo | Agente |
|---|---|---|---|
| `/review:review` | Code review com findings por severidade | `commands/review.md` | `code-reviewer` |
| `/review:judge` | Segunda opinião via judge runtime externo | `commands/judge.md` | `judge-agent` |

## Constraints

- Do not use `#skill:` or `skill:` syntax.
- Do not use `.claude/**` paths.
- Do not initiate SDD workflow phases from this skill.
