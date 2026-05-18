---
name: create-skills
description: Meta-skill for scaffolding new AgentSpec skills. Creates skill
  directory structure with SKILL.md, commands/, references/, templates/, and
  scripts/.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 0.1.0
  category: meta
  status: scaffold
---

# Create Skills (Meta-Skill)

> Invoke: `/create-skills /create-skill <skill-name>`

## Purpose

Meta-skill para criar novas skills no AgentSpec. Gera a estrutura de diretórios padronizada e arquivos iniciais seguindo as convenções do repositório.

## Regras Globais

1. Consulte `~/.config/opencode/config/grounding.md` somente quando politicas, seguranca ou gates SDD forem necessarios.
2. Toda nova skill deve seguir a estrutura canônica abaixo.
3. SKILL.md gerado deve conter: frontmatter, global rules, routing table.
4. Nunca crie skills com conteúdo duplicado entre SKILL.md e commands/.

## Estrutura Canônica

```text
~/.config/opencode/skills/{skill-name}/
├── SKILL.md              ← Metadata, global rules, routing table
├── commands/             ← Um arquivo .md por comando
├── references/           ← Material de apoio reutilizável
├── templates/            ← Artefatos prontos para uso
└── scripts/              ← Automação e tooling
```

## Quality Gates

| Gate | Critério |
|---|---|
| Naming | `skill-name` em kebab-case |
| Structure | Todos os diretórios criados |
| SKILL.md | Frontmatter + global rules + routing table presentes |
| No duplication | Zero duplicação entre SKILL.md e commands/ |

## Status

> **SCAFFOLD** — Esta skill define a estrutura mínima. Expanda conforme necessidade.
