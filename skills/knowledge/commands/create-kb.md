---
name: create-kb
description: Create a complete KB domain from scratch with MCP validation
---

# Create Knowledge Base Command

> Create a complete KB section from scratch with MCP validation.

## Usage

```bash
/knowledge:create-kb <DOMAIN>
/knowledge:create-kb <DOMAIN> --source <library-or-doc-id>
/knowledge:create-kb <DOMAIN> --topics "<topic-1>, <topic-2>"
```

**Examples**: `/knowledge:create-kb redis`, `/knowledge:create-kb pandas`, `/knowledge:create-kb authentication`

## What Happens

1. **Valida pré-requisitos** — verifica `~/.config/opencode/kb/_templates/` e cria `~/.config/opencode/kb/_index.yaml` se necessário
2. **Resolve fontes MCP** — usa `context7`/`ref` para docs oficiais e `exa`/`tavily` para sinais recentes quando útil
3. **Planeja escopo** — define conceitos, patterns e specs mínimos para o domínio
4. **Cria estrutura** — gera diretórios e arquivos a partir dos templates
5. **Atualiza registry** — adiciona ou atualiza entrada em `~/.config/opencode/kb/_index.yaml`
6. **Valida saída** — checa links, limites de linhas, datas MCP e score

## Quality Gates

Antes de escrever:

- O domínio deve estar normalizado em `kebab-case`.
- O domínio não pode sobrescrever KB existente sem confirmação explícita.
- As fontes MCP devem atingir confiança mínima de `0.80`.
- Os templates obrigatórios devem existir.

## Output

```text
KB Domain Created: ~/.config/opencode/kb/{domain}/
Files: index.md, quick-reference.md, concepts/*, patterns/*, specs/*
Registry: ~/.config/opencode/kb/_index.yaml
MCP Sources: context7/ref/exa/tavily
Validation Score: NN/100
```

## Next Step

`/knowledge:update-kb <domain>` — para atualizar o domínio recém-criado com conteúdo adicional.

## See Also

- **Agent**: `~/.config/opencode/agents/architect.kb-architect.agent.md`
- **Templates**: `~/.config/opencode/kb/_templates/`
- **Registry**: `~/.config/opencode/kb/_index.yaml`
- **Example KB**: `~/.config/opencode/kb/{domain}/`
