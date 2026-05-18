---
name: core-commands
description: Reusable core guidance for the native commands /core:meeting, /core:memory,
  /core:readme-maker, /core:status, and /core:sync-context. Load this skill when running
  project utility commands.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 2.0.0
  category: commands
  migrated-from: ~/.config/opencode/skills/core-commands/commands/
---

# Core Commands

> Used by the native commands: `/core:meeting`, `/core:memory`, `/core:readme-maker`, `/core:status`, `/core:sync-context`

## Regras Globais Obrigatórias

Estas regras valem para todos os comandos desta skill.

### Grounding e Roteamento

1. Leia o arquivo do comando solicitado em `commands/`.
2. Leia `~/.config/opencode/config/routing.json` e selecione o agente pelo comando solicitado.
3. Leia o arquivo do agente selecionado em `~/.config/opencode/agents/`.
4. Consulte `~/.config/opencode/config/grounding.md` somente quando houver politica, seguranca, shell, ferramentas, commits ou gates SDD.
5. Inclua diagnosticos de rota somente quando forem uteis para planejamento, depuracao, validacao ou auditoria.

### Caminhos Canônicos

| Tipo | Caminho correto |
|---|---|
| Storage persistente | `~/.config/opencode/storage/` |
| Memória do projeto | `~/.config/opencode/storage/memory/` |
| Status do projeto | `_meta/STATUS.md` |
| Contexto do projeto | `_meta/CONTEXT.md` |
| Instruções globais | `~/.config/opencode/AGENTS.md` |
| Agentes | `~/.config/opencode/agents/{category}/{name}.agent.md` |
| KB domains | `~/.config/opencode/kb/{domain}/` |

### Regras de Caminho

- Nunca use caminhos `.claude/**`, `.agents/**` ou `GEMINI.md`.
- Storage local usa `~/.config/opencode/storage/`, não a raiz do repositório.
- Artefatos de documentação (README, docs/) seguem convenções do repositório.

### Constraints

- Não inicie fases SDD a partir desta skill.
- Não use sintaxe `#skill:` ou `skill:`.
- Se o comando exigir um agente que não existe, pare e reporte ao invés de inventar.

## Comandos Disponíveis

| Comando | Descrição | Arquivo | Agente |
|---|---|---|---|
| `/core:meeting` | Análise de transcrições de reunião | `commands/meeting.md` | `meeting-analyst` |
| `/core:memory` | Gestão de memória e contexto do projeto | `commands/memory.md` | `codebase-explorer` |
| `/core:readme-maker` | Geração e atualização de README | `commands/readme-maker.md` | `codebase-explorer` |
| `/core:status` | Status e saúde do projeto | `commands/status.md` | `codebase-explorer` |
| `/core:sync-context` | Sincronização de contexto entre sessões | `commands/sync-context.md` | `codebase-explorer` |

### Execução

Para cada comando, leia o arquivo correspondente em `commands/` e siga as instruções detalhadas contidas nele. O arquivo do comando é a fonte autoritativa de lógica, passos e formato de saída.
