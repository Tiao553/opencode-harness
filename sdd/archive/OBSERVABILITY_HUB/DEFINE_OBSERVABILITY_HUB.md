# DEFINE: Observability Hub (Wave 2 — Integration MVP)

> **Plataforma única: Microsoft Fabric Lakehouse + OneLake + Delta Lake + DirectLake.**
> Sem fase local intermediária. O contrato canônico de dados é `docs/discovery/contrato_canonico.md` v1.4. A arquitetura de dados é `docs/discovery/arquitetura_de_dados.md` v1.2.

---

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | Observability Hub (Wave 2: E3, E4, E5) |
| **Date** | 2026-04-17 |
| **Author** | Sebastião Neto |
| **Status** | ✅ Complete (Built) |
| **Clarity Score** | 13/15 ✓ |

---

## Documentos Canônicos

| Documento | Papel | Versão |
|---|---|---|
| [`docs/discovery/contrato_canonico.md`](../docs/discovery/contrato_canonico.md) | Schema obrigatório de `fct_execution_event` e `fct_error_event` — campos, tipos, regras, decisões D1–D20 | v1.4 |
| [`docs/discovery/arquitetura_de_dados.md`](../docs/discovery/arquitetura_de_dados.md) | Arquitetura Medallion no Fabric: Bronze/Silver/Gold, tabelas `stg_*`/`nrm_*`/`fct_*`, orquestração, janelas, deduplicação | v1.2 |

> **Regra**: qualquer divergência entre este DEFINE e os documentos de discovery acima → os documentos de discovery vencem.

---

## Problem Statement

Operações hoje carecem de uma **visão unificada e em tempo real** das execuções críticas de carga em três sistemas (ODI, ETLTOOLS, Power BI). Cada fonte fala sua própria linguagem:
- ODI: Status de tabela de controle, contexto limitado
- ETLTOOLS: Feedback estruturado via Oracle + NOT_STARTED via Elastic
- Power BI: Polling da API REST Admin

**Impacto:** Resposta a incidentes lenta (fontes fragmentadas), análise de causa raiz inconsistente, alertas não roteáveis. Ops não consegue responder "o que falhou agora?" em menos de 15 minutos.

---

## Target Users

| Usuário | Papel | Pain Point |
|------|------|------------|
| **Operações / On-call** | Resposta a incidentes | Não consegue ver as três fontes em um lugar; pula entre ODI, logs, histórico de refresh PBI |
| **Engenharia / Plataforma** | Análise de causa raiz | Contexto fragmentado; deve correlacionar erros manualmente entre sistemas |
| **Liderança / Gestão** | Monitoramento de saúde | Sem visão consistente de violações de SLA, jobs com falha ou tendências |
| **Owners de carga** | Monitoramento proativo | Não sabem que seus jobs falharam até alguém reclamar; sem alertas self-service |

---

## Goals

| Prioridade | Objetivo |
|----------|------|
| **MUST** | Capturar eventos de execução de ODI, ETLTOOLS e Power BI nas 3 janelas diárias (18h, 22h, 17h) no Fabric Lakehouse |
| **MUST** | Normalizar eventos ao contrato canônico (`fct_execution_event` + `fct_error_event`) no Fabric Gold layer |
| **MUST** | Habilitar drill-down do dashboard ao detalhe técnico (execução → erro → log) |
| **MUST** | Suportar modelo semântico DirectLake no Power BI para dashboard operacional em tempo real |
| **MUST** | Capturar eventos `NOT_STARTED` do Elastic (ETLTOOLS) com `server_name` e `error_type = NOT_STARTED` |
| **SHOULD** | Implementar lógica de deduplicação cross-window por chave composta conforme `arquitetura_de_dados.md` seção 7 |
| **SHOULD** | Registrar auditoria de ingestão em `stg_ingestion_audit` (linhas lidas, escritas, duplicados descartados, status) |
| **COULD** | Classificar `error_type` Power BI em `CREDENTIAL` / `GATEWAY` / `CAPACITY` / `UNKNOWN` |

---

## Success Criteria

- [ ] **Completeness**: 100% dos eventos ODI, ETLTOOLS, Power BI capturados em cada janela (verificar via row counts em `fct_completeness_report`)
- [ ] **Latência**: Eventos visíveis no Gold ≤ 30 min após a janela (medido via `collected_at` vs `detected_at`)
- [ ] **Correlação**: Possível rastrear execução → erro → causa raiz em < 2 minutos (testar com runbooks)
- [ ] **Dedup**: Zero eventos duplicados no lookback de 3 janelas (medido via colisões na chave de dedup)
- [ ] **Qualidade**: Campos obrigatórios do contrato canônico com NULL rate < 2%
- [ ] **DirectLake Ready**: Schema Gold compatível com modelo semântico Power BI Direct Lake (schema exato do `contrato_canonico.md`)
- [ ] **MTTD/MTTR automáticos**: `time_to_detect_ms` e `time_in_error_ms` calculados sem entrada manual (critério de aceite 3 do programa)

---

## Acceptance Tests

| ID | Cenário | Given | When | Then |
|----|----------|-------|------|------|
| AT-001 | Job ODI conclui normalmente | Job ODI com `SESS_STATUS = 'D'` | Janela 18h roda | Evento em `fct_execution_event` com `execution_status = SUCCESS` em ≤ 30 min |
| AT-002 | Job ETLTOOLS falha | Lote com erro em `INTERFACE.ERRO` | Janela 22h roda | Erro em `fct_error_event` com `error_type = EXECUTION`, vinculado ao `execution_event_id` pai |
| AT-003 | Tabela ETLTOOLS não inicia (Elastic) | Log Elastic com `'tabela não iniciada com erro'` | Janela 22h roda | Registro em `fct_error_event` com `error_type = NOT_STARTED`, `server_name` preenchido, `execution_event_id = null` |
| AT-004 | Dataset Power BI falha por credencial | `serviceExceptionJson.errorCode` indica credencial | Janela 22h roda | Evento em `fct_error_event` com `error_type = CREDENTIAL`, `correction_url` apontando para o dataset |
| AT-005 | Evento atravessa duas janelas | Job inicia 21:50, termina 22:15 | Janelas 22h e 17h rodam | Nenhum duplicado; chave de dedup colide, `occurrence_count` incrementado |
| AT-006 | Drill-down do dashboard | Operador clica em "FAILED" no dashboard | Navega ao detalhe do erro | `fct_execution_event` → `fct_error_event` → `correction_url` em < 2 seg |
| AT-007 | MTTD calculado automaticamente | Job ODI falha às 02:00, detectado às 02:10 | Pipeline roda | `time_to_detect_ms = 600000` em `fct_execution_event` sem entrada manual |

---

## Out of Scope

Explicitamente NÃO incluído no Wave 2 MVP:

- **E1 (Catálogo)**: Enriquecimento (SLA, owner, criticidade) — postergado para Wave 1, adicionado via join futuro
- **E2 (Discovery Técnico)**: Detalhes de runflow — cobertos no Brainstorm, detalhe no Design
- **E6 (Dashboard Central)**: Implementação UI/UX — blueprint do modelo semântico Power BI apenas
- **E7 (Alertas Inteligentes)**: Roteamento de alertas, lógica de dedup — schema em andamento, execução postergada
- **E8 (Métricas de Confiabilidade)**: Agregações MTTD/MTTR — fundação pronta (campos temporais do contrato), queries postergadas
- **Features avançadas**: Classificação ML de erros, self-healing, lineage tracing, multi-tenant

---

## Constraints

| Tipo | Constraint | Impacto |
|------|------------|--------|
| **Plataforma** | Microsoft Fabric Lakehouse — OneLake + Delta Lake desde o build inicial | Sem fase local; todos os artefatos em Fabric |
| **Orquestração** | Fabric Data Factory Pipelines + Fabric Notebooks agendados | 3 janelas diárias (18h ODI, 22h ETLTOOLS+PBI, 17h materialização Gold) |
| **Contrato de schema** | `contrato_canonico.md` v1.4 é o único schema de referência para Gold | Campos de `fct_execution_event` e `fct_error_event` devem corresponder exatamente |
| **Consumo** | Power BI Direct Lake sobre tabelas Gold do Lakehouse | Schema Gold deve ser compatível com DirectLake sem import mode |
| **Timing** | 3 janelas fixas diárias | Processamento batch; lag máximo de ~4h é aceitável |
| **Credenciais** | Oracle (ODI, ETLTOOLS), Azure AD (Power BI) — gerenciadas via Fabric Workspace Connections / Key Vault | Nenhuma credencial em código |
| **Enriquecimento** | Sem catálogo/SLA no Wave 2 | Schema Gold deve suportar `LEFT JOIN` para `dim_catalog_load` futuro |

---

## Technical Context

| Aspecto | Valor | Notas |
|--------|-------|-------|
| **Plataforma de deploy** | Microsoft Fabric Lakehouse (Delta tables) | Bronze/Silver/Gold em único workspace |
| **Motor de processamento** | Fabric Notebooks PySpark/Python + Data Factory | PySpark para transformações Silver→Gold; Python para collectors |
| **Armazenamento** | OneLake + Delta Lake | Delta Tables como padrão em todas as camadas |
| **Consumo analítico** | Power BI Direct Lake | Lê diretamente as tabelas Delta Gold |
| **Arquitetura de referência** | Medallion (Bronze → Silver → Gold) | Definida em `arquitetura_de_dados.md` v1.2 |
| **Contrato de dados** | `contrato_canonico.md` v1.4 | Define schema exato das entidades Gold |

---

## Data Contract

### Source Inventory

| Fonte | Tipo | Volume | Freshness | Owner |
|--------|------|--------|-----------|-------|
| **ODI Control Tables** (Oracle) | Relacional | ~1000 execuções/dia | Atual (polls a cada janela) | ODI team |
| **ETLTOOLS Oracle** (`INTERFACE.ETL_*` + `INTERFACE.ERRO`) | Relacional | ~500 erros/dia | Atual (feedback escrito ao final do job) | ETLTOOLS team |
| **ETLTOOLS Elastic** (Python log extraction) | Logs | Variável | Tempo real (log = detecção imediata) | ETLTOOLS team |
| **Power BI API** (`datasets/{id}/refreshes`) | REST API | ~100 refreshes/dia | Atual (polling a cada janela) | Platform team |

---

### Schema Contract — Gold Layer

O schema das tabelas Gold é definido pelo `contrato_canonico.md` v1.4. Os campos abaixo são uma transcrição dos campos canônicos para referência no DEFINE. Em caso de divergência, o `contrato_canonico.md` vence.

#### `fct_execution_event`

| Campo | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `execution_event_id` | string (UUID) | **YES** | ID único do evento — gerado pelo pipeline |
| `catalog_load_sk` | int (FK) | **YES** | Vínculo com `dim_catalog_load` (alerta se ausente, não bloqueia) |
| `sla_policy_sk` | int (FK) | NO | Via join com `dim_catalog_load`. Null se catálogo ausente |
| `owner_sk` | int (FK) | NO | Via join com `dim_catalog_load`. Null = alerta não roteável |
| `dataset_sk` | int (FK) | NO | Somente Power BI |
| `system_name` | string | **YES** | Enum: `ODI` \| `ETLTOOLS` \| `POWER_BI` |
| `source_table` | string | **YES** | ODI: cenário/plano. ETLTOOLS: tabela controle. PBI: modelo semântico |
| `process_id` | string | **YES** | ID do processo/job na fonte |
| `run_id` | string | **YES** | ODI: `SESS_NO`. ETLTOOLS: `lote_id`. PBI: `id` do refresh |
| `execution_status` | string | **YES** | Enum: `SUCCESS` \| `FAILED` \| `RUNNING` |
| `start_time` | datetime (UTC) | **YES** | Nunca nulo |
| `end_time` | datetime (UTC) | NO | Null se `RUNNING` |
| `duration_ms` | int | NO | `(end_time − start_time)` |
| `detected_at` | datetime (UTC) | **YES** | Timestamp da coleta que identificou o problema |
| `resolved_at` | datetime (UTC) | NO | Null enquanto erro ativo |
| `time_to_detect_ms` | int | **YES** | `(detected_at − start_time)` — componente MTTD |
| `time_in_error_ms` | int | NO | `(resolved_at − detected_at)` — componente MTTR |
| `sla_breach_flag` | bool | **YES** | Default `false` se catálogo ausente |
| `sla_breach_ms` | int | NO | `(end_time − sla_deadline)` ms se violou |
| `severity` | string | **YES** | `P0` \| `P1` \| `P2` via `dim_catalog_load`. Null se não catalogado |
| `environment` | string | **YES** | `DEV` \| `EXEC` \| `PROD` — separação no pipeline, nunca no painel |
| `has_errors` | bool | **YES** | `true` se `msg_error` preenchido OU `execution_status = FAILED` |
| `msg_error` | string | NO | Truncar 2000 chars |
| `error_type` | string | NO | `EXECUTION` \| `CREDENTIAL` \| `GATEWAY` \| `CAPACITY` \| `UNKNOWN` |
| `correction_url` | string | **YES** | Link direto ao ponto de correção |
| `collected_at` | datetime (UTC) | **YES** | Timestamp da ingestão — auditoria de latência |

#### `fct_error_event`

| Campo | Tipo | Obrig. | Descrição |
|---|---|---|---|
| `error_event_id` | string (UUID) | **YES** | ID único do erro — gerado pelo pipeline |
| `execution_event_id` | string (FK) | **COND** | Obrigatório para ODI, ETLTOOLS SQL e PBI. **Null para NOT_STARTED Elastic** |
| `catalog_load_sk` | int (FK) | **YES** | Herdado do pai. NOT_STARTED: via join por `source_table` |
| `system_name` | string | **YES** | Enum: `ODI` \| `ETLTOOLS` \| `POWER_BI` |
| `source_table` | string | **YES** | Objeto de origem onde o erro ocorreu |
| `run_id` | string | **COND** | Herdado do pai. **Null para NOT_STARTED Elastic** |
| `process_id` | string | **YES** | Herdado do pai. NOT_STARTED: extraído do log |
| `server_name` | string | **COND** | **Exclusivo NOT_STARTED Elastic** — campo `servidor` do log |
| `error_code` | string | **YES** | NOT_STARTED: `'NOT_STARTED'`. Sem código: `'UNKNOWN'` |
| `msg_error` | string | **YES** | Nunca nulo |
| `error_type` | string | **YES** | `EXECUTION` \| `CREDENTIAL` \| `GATEWAY` \| `CAPACITY` \| `NOT_STARTED` \| `UNKNOWN` |
| `root_cause_hint` | string | NO | NOT_STARTED: inclui `server_name` na sugestão |
| `occurred_at` | datetime (UTC) | **YES** | Elastic: `@timestamp` |
| `detected_at` | datetime (UTC) | **YES** | Elastic: igual a `occurred_at` |
| `resolved_at` | datetime (UTC) | NO | Null enquanto ativo |
| `time_to_detect_ms` | int | **YES** | Elastic NOT_STARTED: `0` |
| `time_in_error_ms` | int | NO | Null enquanto ativo |
| `open_flag` | bool | **YES** | `true` se `resolved_at = null`. Atualizado a cada ciclo |
| `correction_url` | string | **YES** | Link direto à correção |
| `severity` | string | **YES** | Herdado do pai. NOT_STARTED: via `dim_catalog_load` |

---

### Freshness SLAs

| Camada | Target | Medição |
|-------|--------|-------------|
| Bronze (stg_*) | ≤ 30 min após janela | `collected_at` vs horário da janela |
| Silver (nrm_*) | ≤ 45 min após Bronze | Completion de notebook de normalização |
| Gold (fct_*) | ≤ 60 min após janela | `collected_at` do evento vs `detected_at` |

### Completeness Metrics

- **ODI**: 100% das sessões com `SESS_STATUS ∈ {D, E, R}` capturadas
- **ETLTOOLS Oracle**: 100% dos lotes com `STATUS ∈ {S, E}` capturados + detalhes de erro via `INTERFACE.ERRO`
- **ETLTOOLS Elastic**: 100% dos logs com padrão `'tabela não iniciada com erro'` capturados
- **Power BI**: 100% dos datasets no config list com histórico de refresh consultado
- **Gold**: Zero `execution_event_id` faltando entre janelas (validar via `fct_completeness_report`)

---

## Assumptions

| ID | Assumption | Se Errado | Validado? |
|----|------------|------------------|------------|
| A-001 | Tabelas de controle ODI estão atualizadas a cada janela | Precisaria ajustar frequência de polling | [x] Sim (confirmado ops) |
| A-002 | ETLTOOLS: tabelas `ETL_*` no schema `INTERFACE` com `STATUS S/E` e `INTERFACE.ERRO` com `LOTE_ID` | Precisaria de mapeamento adicional | [ ] TBD — service name `BDBI` pendente validação DBA |
| A-003 | Elastic existe e expõe logs com `'tabela não iniciada com erro'`, `@timestamp`, `source_table`, `servidor` | Precisaria de source alternativa para NOT_STARTED | [ ] TBD — Elastic não encontrado concretamente ainda |
| A-004 | Power BI API expõe `status`, `startTime`, `endTime`, `serviceExceptionJson` | Fallback para workbook audits | [ ] TBD — credentials (tenant_id, client_id, client_secret) pendentes |
| A-005 | Fabric Direct Lake disponível (capacidade Premium) | Fallback para import mode | [ ] TBD — confirmar licença |
| A-006 | Chave de dedup por `(system_name, run_id, start_time)` é única entre execuções | Precisaria de chave composta adicional | [x] Sim — sem execuções sobrepostas esperadas |

---

## Open Questions

| Pergunta | Status | Owner | Due |
|----------|--------|-------|-----|
| Service name `BDBI` ETLTOOLS Oracle — validar com DBA | **TBD** | DBA | Antes de E4 |
| Elastic: confirmar endpoint, índice e permissões | **TBD** | Ops/Infra | Antes de E4 |
| Power BI: validar app registration (tenant_id, client_id, client_secret) | **TBD** | Platform team | Antes de E5 |
| Capacidade Fabric Premium / Direct Lake disponível? | **TBD** | Liderança | Design phase |
| Fabric Data Factory: 3 pipelines sequenciais completam em < 60 min? | **TBD** | Platform team | Design phase |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-17 | define-agent | Initial DEFINE from BRAINSTORM |
| 1.1 | 2026-04-17 | iterate-agent | Build strategy: combinar design + build localmente (DuckDB/Parquet) |
| 1.2 | 2026-04-18 | iterate-agent | Clarificou Phase 1 Local vs Phase 2 Fabric |
| 1.3 | 2026-05-18 | iterate-agent | **Breaking change**: Removida estratégia Phase 1 Local / DuckDB. Plataforma única = Microsoft Fabric desde o início. Schema Gold alinhado exatamente ao `contrato_canonico.md` v1.4. Arquitetura alinhada a `arquitetura_de_dados.md` v1.2. Adicionados AT-003 (Elastic NOT_STARTED), AT-007 (MTTD automático). |

---

## Next Step

**Ready for:** `/workflow:validate` — validar a implementação construída e as evidências operacionais

**Abordagem:** Fabric Data Factory Pipelines + Notebooks PySpark/Python. Bronze/Silver/Gold no Lakehouse OneLake/Delta Lake. Schema Gold exatamente conforme `contrato_canonico.md` v1.4.
## Status: ✅ Shipped
