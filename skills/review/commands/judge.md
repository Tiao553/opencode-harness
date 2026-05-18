---
name: judge
description: Second-opinion quality assessment using external judge runtime with OpenRouter
---

# /review:judge Command

> Obter uma segunda opinião independente sobre output de alta-criticidade ou ambiguidade.

## Usage

```bash
/review:judge <file> [--context "..."] [--model <openrouter-model>]
/review:judge --ledger
```

## Prerequisites

- `OPENROUTER_API_KEY` configurada no ambiente
- Judge runtime disponível (ver `docs/getting-started/judge-setup.md`)
- Arquivo alvo deve existir

## Process

1. Leia `~/.config/opencode/agents/dev.judge-agent.agent.md`
2. Leia o arquivo alvo especificado
3. Se `--context` fornecido, use como contexto adicional para o julgamento
4. Se `--model` fornecido, use o modelo especificado; caso contrário, use o default do agent
5. Verifique se o judge runtime externo está configurado e `OPENROUTER_API_KEY` disponível
6. Se runtime ou key ausentes, pare e reporte o prerequisito faltante — não invente veredicto
7. Execute o judge runtime externo
8. Registre entrada no ledger

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Runtime check | Judge runtime instalado e acessível | Pare e reporte setup necessário |
| API key check | `OPENROUTER_API_KEY` disponível | Pare e reporte key faltante |
| File exists | Arquivo alvo existe e é legível | Pare e reporte arquivo não encontrado |
| Verdict quality | Veredicto retornado com score e justificativa | Reporte erro do runtime |

## Output

- Veredicto do judge com score e justificativa
- Entrada no ledger: `~/.config/opencode/storage/judge-ledger.jsonl`
- Se `--ledger` flag: lista entradas do ledger existente

## Ledger Format

Cada entrada no ledger contém:
- Timestamp
- Arquivo julgado
- Modelo usado
- Score
- Veredicto resumido
- Contexto fornecido

## Next Step

- Se o veredicto indicar problemas: `/workflow:iterate` para corrigir
- Se o veredicto aprovar: prossiga com `/workflow:ship`

## See Also

- `~/.config/opencode/agents/dev.judge-agent.agent.md` — Agent file
- `~/.config/opencode/storage/judge-ledger.jsonl` — Ledger storage
- `docs/getting-started/judge-setup.md` — Setup guide
