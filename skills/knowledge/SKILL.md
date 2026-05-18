---
name: knowledge
description: Reusable knowledge-base guidance for the native commands
  /knowledge:create-kb, /knowledge:update-kb, and /knowledge:refresh-stale-kbs. Load this skill when creating,
  updating, or auditing KB domains.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 1.0.0
  category: commands
  migrated-from: ~/.config/opencode/skills/knowledge/
---

# Knowledge Commands

> Used by the native commands: `/knowledge:create-kb`, `/knowledge:update-kb`, `/knowledge:refresh-stale-kbs`

## Regras Globais Obrigatórias

Estas regras valem para todos os comandos desta skill. Se houver conflito com blocos legados migrados, esta seção vence.

### Grounding e Agente

1. Leia o arquivo do comando solicitado em `commands/`.
2. Leia `~/.config/opencode/config/routing.json`; se nenhuma rota específica casar, use `~/.config/opencode/agents/architect.kb-architect.agent.md`.
3. Leia `~/.config/opencode/agents/architect.kb-architect.agent.md` antes de criar, atualizar ou auditar KBs.
4. Carregue somente os arquivos necessários do domínio em `~/.config/opencode/kb/{domain}/`; nunca carregue o diretório inteiro.
5. Consulte `~/.config/opencode/config/grounding.md` somente quando houver politica, seguranca, shell, ferramentas, commits ou gates SDD.
6. Inclua diagnosticos de rota somente quando forem uteis para planejamento, depuracao, validacao ou auditoria.

### Caminhos Canônicos

| Tipo | Caminho correto |
|---|---|
| Domínios KB | `~/.config/opencode/kb/{domain}/` |
| Templates KB | `~/.config/opencode/kb/_templates/*.template` |
| Registry KB | `~/.config/opencode/kb/_index.yaml` |
| Agente KB | `~/.config/opencode/agents/architect.kb-architect.agent.md` |
| Quick reference | `~/.config/opencode/kb/{domain}/quick-reference.md` |
| Índice do domínio | `~/.config/opencode/kb/{domain}/index.md` |
| Conceitos | `~/.config/opencode/kb/{domain}/concepts/*.md` |
| Patterns | `~/.config/opencode/kb/{domain}/patterns/*.md` |
| Specs | `~/.config/opencode/kb/{domain}/specs/*.yaml` |

### MCPs e Fontes

Use MCPs para validar conhecimento antes de gravar conteúdo técnico. Ordem recomendada:

| MCP | Uso principal | Obrigatoriedade |
|---|---|---|
| `context7` | Documentação oficial de bibliotecas, frameworks e APIs versionadas | Preferencial |
| `ref` | Referência técnica/API quando disponível | Preferencial |
| `exa` ou `tavily` | Pesquisa ampla, exemplos de produção e mudanças recentes | Complementar |
| MCP específico do domínio | Cloud, banco, plataforma ou vendor quando existir | Preferencial para domínio |

Regras de validação:

- Use pelo menos 2 fontes quando o conteúdo afetar comandos, APIs, limites, sintaxe ou comportamento versionado.
- Se só houver 1 fonte confiável, registre caveat de confiança no relatório final.
- Se fontes conflitarem, não invente resolução; registre conflito e peça decisão.
- Todo arquivo criado ou atualizado deve conter `> **MCP Validated:** YYYY-MM-DD`.
- Preserve conteúdo local relevante; atualizações devem ser incrementais e rastreáveis.

### Estrutura Mínima de um KB

```text
~/.config/opencode/kb/{domain}/
├── index.md
├── quick-reference.md
├── concepts/
├── patterns/
└── specs/
```

Crie arquivos a partir de `~/.config/opencode/kb/_templates/`:

| Saída | Template |
|---|---|
| `index.md` | `index.md.template` |
| `quick-reference.md` | `quick-reference.md.template` |
| `concepts/{name}.md` | `concept.md.template` |
| `patterns/{name}.md` | `pattern.md.template` |
| `specs/{name}.yaml` | `spec.yaml.template` |
| entrada do registry | `domain-manifest.yaml.template` |

Se `~/.config/opencode/kb/_index.yaml` não existir, crie com raiz `domains:` antes de registrar o primeiro domínio. Se existir, atualize apenas a entrada do domínio impactado.

## Comandos Disponíveis

| Comando | Descrição | Arquivo | Agente |
|---|---|---|---|
| `/knowledge:create-kb` | Criar KB domain completo com validação MCP | `commands/create-kb.md` | `kb-architect` |
| `/knowledge:update-kb` | Atualizar KB existente com mudanças validadas | `commands/update-kb.md` | `kb-architect` |
| `/knowledge:refresh-stale-kbs` | Identificar e atualizar KBs desatualizados | `commands/refresh-stale-kbs.md` | `kb-architect` |

### Escalação

- Se a criação de KB revelar dependência em domínio existente, proponha merge ou cross-reference antes de duplicar.
- Se a atualização revelar reestruturação grande, proponha plano antes de editar múltiplos domínios.
- Se o refresh detectar conflitos entre fontes MCP, registre conflito e peça decisão.

## See Also

- **Agent**: `~/.config/opencode/agents/architect.kb-architect.agent.md`
- **Example**: `~/.config/opencode/kb/{domain}/`
- **Templates**: `~/.config/opencode/kb/_templates/`
- **Registry**: `~/.config/opencode/kb/_index.yaml`

---
