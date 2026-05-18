---
name: data-engineering
description: Reusable data-engineering guidance for the native commands
  /data:ai-pipeline, /data:data-contract, /data:data-quality, /data:lakehouse, /data:migrate, /data:pipeline,
  /data:schema, and /data:sql-review. Load this skill when routing specialist data work.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 1.1.0
  category: commands
  migrated-from: ~/.config/opencode/skills/data-engineering/
---

# Data-Engineering Commands

> Used by the native commands: `/data:ai-pipeline`, `/data:data-contract`, `/data:data-quality`, `/data:lakehouse`, `/data:migrate`, `/data:pipeline`, `/data:schema`, `/data:sql-review`

## Regras Globais Obrigatórias

Estas regras valem para todos os comandos desta skill.

### Grounding e Roteamento

1. Leia o arquivo do comando solicitado em `commands/`.
2. Leia `~/.config/opencode/config/routing.json` e selecione o agente pelo comando solicitado.
3. Leia o arquivo do agente selecionado (ver tabela de comandos abaixo).
4. Carregue KB quick-reference do domínio indicado na tabela de routing (lazy loading).
5. Consulte `~/.config/opencode/config/grounding.md` somente quando houver politica, seguranca, shell, ferramentas, commits ou gates SDD.
6. Inclua diagnosticos de rota somente quando forem uteis para planejamento, depuracao, validacao ou auditoria.

### Delegação de Agentes

Cada comando delega a um agente primário. Se o escopo exigir, o agente primário pode escalar para agentes complementares:

- **Agente primário**: executa o core da tarefa
- **Agente de escalação**: ativado para edge cases, cross-domain, ou validação complementar
- Cada agente delegado deve ler seu agent file e carregar KB quick-reference se declarado

### Caminhos Canônicos

| Tipo | Caminho correto |
|---|---|
| Agentes data-engineering | `~/.config/opencode/agents/data-engineering.{name}.agent.md` |
| Agentes architect | `~/.config/opencode/agents/architect.{name}.agent.md` |
| Agentes test | `~/.config/opencode/agents/test.{name}.agent.md` |
| KB domains | `~/.config/opencode/kb/{domain}/quick-reference.md` |
| Templates | `~/.config/opencode/sdd/templates/*.md` |
| Instruções globais | `~/.config/opencode/AGENTS.md` |

### Regras de Caminho

- Nunca use caminhos `.claude/**` ou `.agents/**`.
- KB loading é lazy: carregue apenas quick-reference.md do domínio relevante.
- Se um domínio KB não existir, registre e continue sem ele.

### Constraints

- Não inicie fases SDD a partir desta skill.
- Não use sintaxe `#skill:` ou `skill:`.
- Output de comandos que geram código deve ir para `{output_path}/` quando em contexto de build.

## Comandos Disponíveis

| Comando | Descrição | Arquivo | Agente Primário | KB Domains |
|---|---|---|---|---|
| `/data:ai-pipeline` | RAG, embeddings, vector DBs, feature stores | `commands/ai-pipeline.md` | `ai-data-engineer` | `ai-data-engineering`, `streaming` |
| `/data:data-contract` | Contratos de dados (ODCS), SLAs, governance | `commands/data-contract.md` | `data-contracts-engineer` | `data-quality`, `data-modeling` |
| `/data:data-quality` | Regras de qualidade, expectations, test suites | `commands/data-quality.md` | `data-quality-analyst` | `data-quality`, `dbt`, `data-modeling` |
| `/data:lakehouse` | Table formats, catalogs, medallion architecture | `commands/lakehouse.md` | `lakehouse-architect` | `lakehouse`, `cloud-platforms`, `spark` |
| `/data:migrate` | Migrações de ETL legado para stacks modernos | `commands/migrate.md` | `dbt-specialist` / `spark-engineer` | `dbt`, `spark`, `airflow`, `sql-patterns` |
| `/data:pipeline` | Orquestração de pipelines (Airflow, dbt, etc.) | `commands/pipeline.md` | `pipeline-architect` | `airflow`, `dbt`, `data-quality` |
| `/data:schema` | Design de schema, modelagem dimensional | `commands/schema.md` | `schema-designer` | `data-modeling`, `sql-patterns`, `data-quality` |
| `/data:sql-review` | Review de SQL, performance, anti-patterns | `commands/sql-review.md` | `code-reviewer` | `sql-patterns`, `data-quality`, `dbt` |

### Escalação Cross-Command

Quando um comando detectar necessidade de outro domínio:

- Pipeline + qualidade → delegue checks para `/data:data-quality`
- Schema + contratos → delegue governance para `/data:data-contract`
- Migration + lakehouse → delegue table format para `/data:lakehouse`

O agente deve informar a escalação e continuar ou pedir confirmação, dependendo do impacto.
