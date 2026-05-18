---
name: update-kb
description: Update an existing KB domain with MCP-validated changes
---

# Update Knowledge Base Command

> Atualiza um KB existente preservando estrutura, links e conteúdo local válido.

## Usage

```bash
/knowledge:update-kb <DOMAIN>
/knowledge:update-kb <DOMAIN> --topic <TOPIC>
/knowledge:update-kb <DOMAIN> --source <library-or-doc-id>
/knowledge:update-kb <DOMAIN> --since YYYY-MM-DD
```

**Examples**: `/knowledge:update-kb dbt --topic "Fusion engine"`, `/knowledge:update-kb gcp --since 2026-01-01`

## What Happens

1. **Lê estado atual** — carrega `index.md`, `quick-reference.md`, arquivos relacionados ao tópico e entrada no registry.
2. **Detecta lacunas** — identifica placeholders, links quebrados, arquivos fora do limite e datas MCP antigas.
3. **Consulta MCPs** — prioriza `context7`/`ref`; usa `exa`/`tavily` para mudanças recentes, release notes e exemplos.
4. **Aplica atualização incremental** — edita somente arquivos necessários.
5. **Atualiza metadados** — renova `MCP Validated`, confidence e registry do domínio.
6. **Valida** — executa o mesmo score de saúde do `kb-architect`.

## Regras de Atualização

- Não reescreva um KB inteiro quando uma atualização por tópico resolver.
- Preserve exemplos e decisões locais, salvo se MCP provar obsolescência.
- Ao remover conteúdo obsoleto, registre substituição ou razão no relatório final.
- Se um comando/API mudou de versão, registre versão anterior e versão atual quando útil.
- Se a atualização revelar grande reestruturação, proponha plano antes de editar múltiplos domínios.

## Quality Gates

- KB domain deve existir antes de atualizar; caso contrário, redirecione para `/knowledge:create-kb`.
- Pelo menos 2 fontes MCP consultadas quando o conteúdo afetar APIs, comandos ou sintaxe versionada.
- Conteúdo local preservado salvo obsolescência comprovada por MCP.
- Todo arquivo tocado deve conter `> **MCP Validated:** YYYY-MM-DD` atualizado.

## Output

```text
KB Domain Updated: ~/.config/opencode/kb/{domain}/
Changed Files: ...
Stale Items Fixed: ...
MCP Sources: ...
Validation Score: NN/100
Residual Risks: ...
```

## Next Step

`/knowledge:refresh-stale-kbs` — para auditar todos os domínios e detectar KBs desatualizados.

## See Also

- **Agent**: `~/.config/opencode/agents/architect.kb-architect.agent.md`
- **Templates**: `~/.config/opencode/kb/_templates/`
- **Registry**: `~/.config/opencode/kb/_index.yaml`
