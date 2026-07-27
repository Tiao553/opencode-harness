# BRAINSTORM — Observability Hub (Fabric Implementation)

**Date:** 2026-04-17
**Facilitator:** Claude Code
**Status:** Ready for `/define`

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-17 | brainstorm-agent | Initial BRAINSTORM |
| 1.1 | 2026-05-18 | iterate-agent | Removed Phase 1 Local / DuckDB strategy. Fabric é a plataforma única desde o início. Referências explícitas ao contrato_canonico.md e arquitetura_de_dados.md como documentos canônicos. |

---

## Executive Summary

Implementar o Observability Hub PRD (waves 1-4) diretamente no **Microsoft Fabric Lakehouse + DirectLake**, focando em telemetria operacional para ODI, ETLTOOLS e Power BI com **3 janelas diárias de execução** (18h, 22h, 17h). O MVP cobre a Wave 2 (Integration MVP): E3 (ODI), E4 (ETLTOOLS), E5 (Power BI).

**Plataforma única: Microsoft Fabric** — sem fase local intermediária, sem DuckDB, sem Parquet local.

---

## Documentos Canônicos

| Documento | Papel |
|---|---|
| [`docs/discovery/contrato_canonico.md`](../docs/discovery/contrato_canonico.md) | Schema canônico das entidades Gold (`fct_execution_event`, `fct_error_event`) com todos os campos, tipos, regras e decisões D1–D20 |
| [`docs/discovery/arquitetura_de_dados.md`](../docs/discovery/arquitetura_de_dados.md) | Arquitetura Medallion no Fabric: Bronze → Silver → Gold, tabelas `stg_*`, `nrm_*`, `fct_*`, orquestração, janelas de coleta, deduplicação |

Qualquer conflito entre exemplos neste BRAINSTORM e esses dois documentos: **os documentos de discovery vencem**.

---

## Problem Statement

Operações hoje carecem de uma **visão unificada e em tempo real** das execuções críticas de carga em três sistemas:
- **ODI**: Tabelas de controle existem, alguma normalização iniciada
- **ETLTOOLS**: Feedback já estruturado em tabelas (parsing resolvido) + Elastic para NOT_STARTED
- **Power BI**: Polling via API Admin REST

**Impacto:** Resposta a incidentes lenta, análise de causa raiz fragmentada, sem alertas consistentes roteáveis.

---

## Discovery Findings

### Timing & Frequência
- **3 janelas diárias fixas**: 18h (ODI), 22h (ETLTOOLS + Elastic + Power BI), 17h (materialização Gold)
- Lag máximo entre coletas: ~4 horas
- Alinhado ao target de SLA operacional (detecção ≤15 min entre runs é aceitável)

### Estado Atual
| Fonte | Status | Prontidão |
|--------|--------|-----------|
| ODI | Parcialmente feito | ~60% (tabelas de controle mapeadas) |
| ETLTOOLS | Parcialmente feito | ~70% (tabelas feedback estruturadas, sem parsing) |
| ETLTOOLS Elastic | Mapeado funcionalmente | Elastic ainda não encontrado concretamente no código |
| Power BI | TBD | Requer validação de app registration (tenant_id, client_id, client_secret) |

### Plataforma
- **Plataforma alvo única**: Microsoft Fabric Lakehouse + OneLake + Delta Lake
- **Orquestração**: Fabric Data Factory Pipelines + Fabric Notebooks agendados
- **Modelo de consumo**: Power BI Direct Lake — sem overhead de sync

### Abordagem: Medallion no Fabric
```
Bronze (stg_*) → Silver (nrm_*) → Gold (fct_*) → Consumo
```

Conforme definido em `arquitetura_de_dados.md`:
1. **Bronze**: Dados brutos das fontes sem transformação — Delta Tables no Lakehouse
2. **Silver**: Normalização, validação, deduplicação, padronização de status por origem
3. **Gold**: Contrato canônico consumível (`fct_execution_event`, `fct_error_event`, dimensões)
4. **Consumo**: Power BI Direct Lake sobre tabelas Gold

---

## Design Decisions

### Arquitetura: Fabric Lakehouse Medallion
**Rationale:** OneLake como single source of truth. Direct Lake lê o Gold diretamente — sem importação, sem latência de sync.

| Tabela | Propósito | Consumidor |
|-------|---------|----------|
| `fct_execution_event` | Evento de execução normalizado (por lote/sessão/refresh) | Painel, runbooks, post-mortem |
| `fct_error_event` | Detalhe técnico de erro com `error_type`, `server_name`, `correction_url` | Engenharia, alertas, diagnóstico |
| `fct_alert_event` | Roteamento de alertas e dedup | Engine de alertas (E7 futuro) |
| `fct_execution_snapshot` | Visão desnormalizada para DirectLake | Power BI + painel operacional |

### Contrato Canônico como contrato vivo
O `contrato_canonico.md` é o único schema de referência. Todos os campos de `fct_execution_event` e `fct_error_event` no DESIGN devem corresponder exatamente a ele (campos, tipos, obrigatoriedade, regras de derivação, decisões D1–D20).

### Orquestração
- **Fabric Data Factory Pipelines / Notebooks**: 3 janelas sequenciais (18h → 22h → 17h), cada uma:
  1. Extração (tabelas ODI Oracle, ETLTOOLS Oracle, Elastic Python, Power BI API)
  2. Staging (Bronze Delta Tables, dedup detection)
  3. Normalização (Silver Delta Tables, padronização por origem)
  4. Materialização Gold (via MERGE/UPSERT nas tabelas Gold)

---

## Open Questions Resolvidas

| Pergunta | Resolução |
|----------|-----------|
| Plataforma única ou em fases? | **Fabric desde o início** — sem fase local DuckDB |
| Schema canônico ou derivado? | **contrato_canonico.md v1.4 é o único schema de referência** |
| Arquitetura de processamento? | **arquitetura_de_dados.md v1.2 — Medallion no Fabric** |
| Tabelas normalizadas por fonte? | **Sim**: cada fonte tem `stg_*` e `nrm_*` independentes |
| Power BI coleta? | **E5**: API Admin REST polling a cada janela — credentials via Key Vault |

---

## O que NÃO estamos construindo (Wave 2 MVP)

- E1 (Catálogo) — postergado para Wave 1
- E2 (Discovery Técnico) — contratos definidos aqui, runflow no Design
- E6 (Dashboard Central) — painel Power BI via DirectLake disponível quando ready
- E7 (Alertas Inteligentes) — schema em andamento, execução postergada
- E8 (Métricas de Confiabilidade) — fundação MTTD/MTTR pronta via campos temporais do contrato

---

## Próximos Passos

1. **`/define`** — Formalizar requisitos:
   - Contrato de campos: exatamente os do `contrato_canonico.md`
   - Escopo do API Power BI e autenticação
   - Regras de qualidade (dedup, validação, completeness)
   - Lógica de refresh Gold (merge/upsert)

2. **`/design`** — Arquitetura técnica Fabric:
   - DAG dos pipelines Fabric Data Factory
   - Estrutura de Lakehouse + schemas Delta
   - Endpoints SQL Fabric para queries downstream
   - Blueprint do modelo semântico DirectLake

3. **`/build`** — Implementação:
   - E4 (ETLTOOLS): Collectors Oracle + Elastic
   - E3 (ODI): Collector Oracle
   - E5 (Power BI): Collector API REST
   - Pipelines Fabric + snapshot Gold + scheduler

---

## Assumptions & Risks

| Risco | Mitigação |
|------|-----------|
| **Power BI API** pode não expor todos os sinais para root cause | Design E5 para expor o disponível; lineage avançado postergado |
| **Elastic** não encontrado concretamente ainda | Cenário funcional já documentado; ponto de validação com DBA/Ops antes de E4 |
| **Duplicate events** entre janelas se carga atravessa horários | Dedup por `(source_system, run_id/lote_id, start_ts)` — ver arquitetura_de_dados.md seção 7 |
| **DirectLake** requer capacidade Premium no Fabric | Confirmar licença; fallback para import mode se necessário |
| **Credenciais Oracle (ODI, ETLTOOLS)** e **Azure AD (PBI)** precisam de Key Vault | Fabric Workspace Connections com credenciais seguras antes do build |
## Status: ✅ Shipped
