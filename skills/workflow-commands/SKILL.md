---
name: workflow-commands
description: Reusable workflow guidance for the native commands /workflow:brainstorm,
  /workflow:define, /workflow:design, /workflow:build, /workflow:validate, /workflow:ship, /workflow:iterate, and /workflow:create-pr. Load
  this skill when executing an SDD phase or validating workflow policy.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 1.0.0
  category: commands
  legacy-source: claude workflow commands
---

# Workflow Commands

> Used by the native workflow commands: `/workflow:brainstorm`, `/workflow:define`, `/workflow:design`, `/workflow:build`, `/workflow:validate`, `/workflow:ship`, `/workflow:iterate`, `/workflow:create-pr`

## Regras Globais Obrigatórias

Estas regras são mandatórias para todos os comandos deste skill. Se houver conflito entre exemplos antigos, comentários legados ou documentação migrada e esta seção, esta seção vence.

### Grounding e Roteamento

1. Este skill deve ser carregado quando um comando nativo de workflow estiver em execução.
2. Consulte `~/.config/opencode/config/grounding.md` somente quando a fase envolver politica, seguranca, shell, ferramentas, commits ou gates SDD historicos nao cobertos por `WORKFLOW_CONTRACTS.yaml`.
3. Quando um comando nativo de workflow estiver ativo, ele tem prioridade sobre roteamento por intent.
4. Leia `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` antes de selecionar ou executar a fase.
5. Leia `~/.config/opencode/config/routing.json` e selecione o agente da fase pelo comando solicitado.
6. Leia o arquivo do agente selecionado em `~/.config/opencode/agents/workflow.*.agent.md`.
7. Carregue KB somente se a rota exigir. As rotas de workflow atuais não carregam KB.
9. Inclua diagnosticos de rota somente quando forem uteis para planejamento, depuracao, validacao ou auditoria.

### Contrato Canônico de Workflow

`WORKFLOW_CONTRACTS.yaml` é fonte canônica para fases, entradas obrigatórias, saídas obrigatórias, gates, caminhos, transições e bloqueios de qualidade.

Regras:

- Todo comando deste skill deve carregar `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` antes de executar a fase.
- Se houver conflito entre exemplos legados neste arquivo e `WORKFLOW_CONTRACTS.yaml`, o contrato vence.
- O agente da fase deve aplicar o contrato antes de escrever, validar, arquivar ou orientar o próximo passo.
- Nenhum gate pode ser relaxado pelo agente sem registrar explicitamente o bloqueio e pedir decisão do usuário.

### Inicialização Obrigatória via Comando Nativo

As fases SDD (`/workflow:brainstorm`, `/workflow:define`, `/workflow:design`, `/workflow:build`, `/workflow:validate`, `/workflow:ship`, `/workflow:iterate`, `/workflow:create-pr`) não podem ser iniciadas por roteamento genérico, prompt natural ou chamada direta ao agente de workflow. O usuário deve invocar:

```text
/workflow:<fase> ...
```

Se a intenção for clara mas o comando nativo estiver ausente, não execute a fase. Responda com o comando exato que o usuário deve rodar.

### Caminhos Canônicos

| Tipo | Caminho correto |
|---|---|
| Features em andamento | `~/.config/opencode/sdd/features/{feature-name}/` |
| Brainstorm | `~/.config/opencode/sdd/features/{feature-name}/BRAINSTORM_{FEATURE}.md` |
| Define | `~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md` |
| Design | `~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md` |
| Build report | `~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md` |
| Validation report | `~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md` |
| Runbook | `~/.config/opencode/sdd/features/{feature-name}/RUNBOOK_{FEATURE}.md` |
| Remediation roadmap | `~/.config/opencode/sdd/features/{feature-name}/ROADMAP_{FEATURE}.md` |
| Build output root | `{output_path}/` |
| Ship archive | `~/.config/opencode/sdd/archive/{feature-name}/SHIPPED_{DATE}.md` |
| Templates | `~/.config/opencode/sdd/templates/*.md` |
| Contratos | `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| Instruções globais | `~/.config/opencode/AGENTS.md` |
| Agentes de workflow | `~/.config/opencode/agents/workflow.*.agent.md` |
| Judge runtime | external runtime only; no bundled `scripts/archive` runner |
| Judge setup | `docs/getting-started/judge-setup.md` |

### Regras de Caminho

- Nunca use caminhos `.claude/**`.
- Nunca grave artefatos de feature diretamente em `~/.config/opencode/sdd/features/` exceto `.gitkeep`.
- Sempre normalize `{FEATURE}` em `UPPER_SNAKE_CASE` para nomes de arquivos.
- Sempre normalize `{feature-name}` em `kebab-case` para diretórios.
- Se o usuário fornecer apenas `DEFINE_FOO.md`, resolva para `~/.config/opencode/sdd/features/*/DEFINE_FOO.md`; se houver mais de uma correspondência, pare e peça desambiguação.
- Se o diretório `~/.config/opencode/sdd/features/{feature-name}/` não existir para uma nova fase, crie-o antes de escrever artefatos.
- Não crie `~/.config/opencode/sdd/reports/`; build reports pertencem ao diretório da feature.
- Durante `/workflow:build`, todo arquivo de implementação deve ser criado em `{output_path}/`, preservando o caminho relativo do manifesto.
- Não escreva arquivos de implementação na raiz do repositório; a raiz fica para documentação, instruções e controle do AgentSpec.

### Gates Rígidos por Fase

| Comando | Entrada obrigatória | Saída obrigatória | Agente |
|---|---|---|---|
| `/workflow:brainstorm` | Ideia, problema ou notas | `BRAINSTORM_{FEATURE}.md` | `~/.config/opencode/agents/workflow.brainstorm-agent.agent.md` |
| `/workflow:define` | Input direto ou `BRAINSTORM_{FEATURE}.md` | `DEFINE_{FEATURE}.md` | `~/.config/opencode/agents/workflow.define-agent.agent.md` |
| `/workflow:design` | `DEFINE_{FEATURE}.md` | `DESIGN_{FEATURE}.md` | `~/.config/opencode/agents/workflow.design-agent.agent.md` |
| `/workflow:build` | `DESIGN_{FEATURE}.md` | Código + `BUILD_REPORT_{FEATURE}.md` | `~/.config/opencode/agents/workflow.build-agent.agent.md` |
| `/workflow:validate` | `DEFINE`, `DESIGN`, `BUILD_REPORT`, código em `{output_path}/` | `VALIDATION_REPORT_{FEATURE}.md` + `RUNBOOK` ou `ROADMAP` | `~/.config/opencode/agents/workflow.validate-agent.agent.md` |
| `/workflow:ship` | `DEFINE`, `DESIGN`, `BUILD_REPORT`, `VALIDATION_REPORT` aprovado e `RUNBOOK` | `SHIPPED_{DATE}.md` | `~/.config/opencode/agents/workflow.ship-agent.agent.md` |
| `/workflow:iterate` | `BRAINSTORM`, `DEFINE` ou `DESIGN` existente | Mesmo arquivo atualizado, com revision history | `~/.config/opencode/agents/workflow.iterate-agent.agent.md` |

- `/workflow:design` não pode iniciar sem `DEFINE_{FEATURE}.md`.
- `/workflow:build` não pode iniciar sem `DESIGN_{FEATURE}.md` e manifesto de arquivos no design.
- `/workflow:validate` não pode iniciar se `BUILD_REPORT_{FEATURE}.md` não existir ou se o código não existir em `{output_path}/`.
- `/workflow:ship` não pode iniciar se `VALIDATION_REPORT_{FEATURE}.md` não existir, registrar CRITICAL issues ou score abaixo de 90.
- Se um gate falhar, pare a fase e diga exatamente qual arquivo ou condição falta.
- Não invente requisitos ausentes para passar gate; peça a menor clarificação necessária.

## Comandos Disponíveis

| Comando | Descrição | Arquivo | Agente |
|---|---|---|---|
| `/workflow:brainstorm` | Ideação e exploração inicial | `commands/brainstorm.md` | `brainstorm-agent` |
| `/workflow:define` | Definição de requisitos e escopo | `commands/define.md` | `define-agent` |
| `/workflow:design` | Design técnico e arquitetura | `commands/design.md` | `design-agent` |
| `/workflow:build` | Implementação e geração de código | `commands/build.md` | `build-agent` |
| `/workflow:validate` | Quality gate multi-agente (Phase 3.5) | `commands/validate.md` | `validate-agent` |
| `/workflow:ship` | Empacotamento e arquivamento | `commands/ship.md` | `ship-agent` |
| `/workflow:iterate` | Revisão e atualização cross-phase | `commands/iterate.md` | `iterate-agent` |
| `/workflow:create-pr` | Criação de Pull Request | `commands/create-pr.md` | N/A |

## Knowledge Context Commands

Skill complementar para gestão de contexto de projeto. Use os comandos nativos `/context:create-context`, `/context:update-context` e `/context:check-context`.

| Comando | Descrição | Skill |
|---|---|---|
| `/context:create-context` | Criar knowledge context completo para um projeto | `~/.config/opencode/skills/knowledge-context/commands/create-context.md` |
| `/context:update-context` | Atualizar arquivos de contexto de um projeto existente | `~/.config/opencode/skills/knowledge-context/commands/update-context.md` |
| `/context:check-context` | Auditar o knowledge context ativo e reportar gaps | `~/.config/opencode/skills/knowledge-context/commands/check-context.md` |

> O Knowledge Context é carregado automaticamente no **Passo 0 do `/workflow:brainstorm`** (Knowledge Checkpoint). Configure o projeto ativo com `/context:create-context <slug> --set-active` antes de iniciar o workflow.
>
> Skill completo: `~/.config/opencode/skills/knowledge-context/SKILL.md`

### Fluxo de Fases

```text
/workflow:brainstorm → /workflow:define → /workflow:design → /workflow:build → /workflow:validate → /workflow:ship
                                      ↑                    |
                                      └── /workflow:iterate ←───────┘
```

### Delegação

Durante `/workflow:build`, o agente pode delegar tarefas a especialistas via `@{agent-name}`:

- `@{container-specialist}` — Docker, Compose, infraestrutura
- `@{dbt-specialist}` — Modelos dbt, testes, docs
- `@{airflow-specialist}` — DAGs, operators, scheduling
- `@{python-developer}` — Scripts, testes, CLI tools

Cada especialista delegado deve:
1. Ler seu agent file em `~/.config/opencode/agents/{category}/{name}.agent.md`
2. Carregar KB quick-reference se declarado no agent
3. Cumprir quality gates do agente
4. Registrar evidência no `BUILD_REPORT_{FEATURE}.md`
5. Escrever arquivos em `{output_path}/`

### Validação (Phase 3.5)

`/workflow:validate` usa 4 juntas hierárquicas internas (sem dependências externas):

| Junta | Tipo | Personas | Output |
|-------|------|----------|--------|
| SpecCrew | Paralela | MGR, ARC, ENG, SWE | `01_SPEC_REPORT.json` |
| CodeCrew | Paralela | MGR, SWE, ENG, OPS | `02_CODE_REPORT.json` |
| DeliveryCrew | Sequencial | CMP, GAP | `03_DELIVERY_DELTA.json` |
| CouncilCrew | Sequencial | JDG, RPT, PRD | `04_COUNCIL_VERDICT.json` |

Scoring é **determinístico** (sem LLM): `score = alignment×0.30 + quality×0.25 + architecture×0.20 + devops×0.15 + delta×0.10`

Contrato canônico: `~/.config/opencode/sdd/architecture/VALIDATE_JUNTAS_CONTRACT.yaml`
Prompts das juntas: `~/.config/opencode/skills/workflow-commands/references/*.md`
Renderer: `~/.config/opencode/skills/workflow-commands/scripts/render.py`
