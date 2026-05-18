---
name: refresh-stale-kbs
description: Identify stale KB domains and route each stale domain through /knowledge:update-kb
---

# Refresh Stale Knowledge Bases Command

> Identifica KBs desatualizados e chama o fluxo de `/knowledge:update-kb` para cada domínio impactado.

## Usage

```bash
/knowledge:refresh-stale-kbs
/knowledge:refresh-stale-kbs --domain <DOMAIN>
/knowledge:refresh-stale-kbs --max-age-days 90
/knowledge:refresh-stale-kbs --dry-run
```

**Examples**: `/knowledge:refresh-stale-kbs --max-age-days 120`, `/knowledge:refresh-stale-kbs --domain lakeflow --dry-run`

## Staleness Signals

Um KB é candidato a atualização quando qualquer regra abaixo for verdadeira:

| Sinal | Critério padrão | Ação |
|---|---:|---|
| `MCP Validated` antigo | > 90 dias | chamar `/knowledge:update-kb <domain>` |
| Header sem data MCP | ausente | chamar `/knowledge:update-kb <domain>` |
| Placeholder de template | contém `{{...}}` | chamar `/knowledge:update-kb <domain>` |
| Links internos quebrados | qualquer link inválido | corrigir durante update |
| Registry divergente | arquivo existe mas não está no `_index.yaml`, ou inverso | atualizar registry |
| Fonte externa mudou | MCP/release notes indicam breaking changes | chamar `/knowledge:update-kb <domain> --topic <change>` |

## What Happens

1. **Audita estrutura** — lista domínios em `~/.config/opencode/kb/*/`.
2. **Calcula idade** — lê datas `MCP Validated` nos arquivos principais e relacionados.
3. **Checa saúde local** — procura placeholders, links quebrados, registry divergente e arquivos fora dos limites.
4. **Consulta sinais externos** — usa MCPs para detectar releases recentes ou mudanças relevantes.
5. **Prioriza fila** — ordena por risco: breaking changes, ausência de validação, idade, links.
6. **Executa update** — para cada domínio stale, chama o fluxo `/knowledge:update-kb`.
7. **Reporta resultado** — separa atualizados, ignorados, bloqueados e riscos residuais.

## Dry Run

Com `--dry-run`, não edite arquivos. Produza apenas:

```text
Stale KBs:
- {domain}: reason, recommended /knowledge:update-kb command

Fresh KBs:
- {domain}: latest MCP date

Blocked:
- {domain}: missing source/conflict/requires decision
```

## Quality Gates

- Auditoria deve cobrir 100% dos domínios em `~/.config/opencode/kb/` (exceto `_templates`).
- Domínios com breaking changes detectados têm prioridade máxima.
- Conflitos entre fontes MCP devem ser registrados sem resolução automática.
- `--dry-run` nunca deve modificar arquivos.

## Output

```text
Refresh Complete:
Updated: N domains
Skipped: N domains (fresh)
Blocked: N domains (requires decision)
Residual Risks: ...
```

## Next Step

`/knowledge:create-kb <domain>` — para criar domínios identificados como ausentes durante o audit.

## See Also

- **Agent**: `~/.config/opencode/agents/architect.kb-architect.agent.md`
- **Templates**: `~/.config/opencode/kb/_templates/`
- **Registry**: `~/.config/opencode/kb/_index.yaml`
- **Legacy alias**: `/knowledge:create-kb --audit` (alias para `--dry-run`)
