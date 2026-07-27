# DESIGN: Observability Hub (Wave 2 — Integration MVP)

> **Plataforma única: Microsoft Fabric Lakehouse + OneLake + Delta Lake + DirectLake.**
> Sem fase local. Schema Gold definido pelo `contrato_canonico.md` v1.4. Arquitetura Medallion definida pelo `arquitetura_de_dados.md` v1.2.

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-18 | design-agent | Initial DESIGN (DuckDB/Parquet local Phase 1) |
| 2.0 | 2026-05-18 | iterate-agent | **Rewrite completo**: Removida toda infraestrutura local (DuckDB, APScheduler, Parquet export, HTML dashboard). Redesenhado para Microsoft Fabric como plataforma única. Schema Gold alinhado exatamente ao `contrato_canonico.md` v1.4. Manifesto de arquivos atualizado para estrutura Fabric Notebooks + Pipelines. |
| 2.1 | 2026-05-18 | iterate-agent | Revisão estrutural: detalhamento explícito dos agentes por fase e por artefato, matriz de delegação, especificações não-funcionais e critérios de prontidão para build/validate. |
| 2.2 | 2026-05-18 | iterate-agent | Adicionado gate de **Fabric Runtime Readiness** (topologia DEV/TEST/PROD, política de capacidade/SKU, guard de serving Gold, operação de semantic model, segurança/governança/operações) e expansão de critérios Ready for Build/Validate; manifesto ampliado com artefatos de governança, operação, CI/CD, semantic model e configuração de ambientes. |

---

## Documentos Canônicos

| Documento | Papel |
|---|---|
| [`docs/discovery/contrato_canonico.md`](../docs/discovery/contrato_canonico.md) | Schema Gold obrigatório: `fct_execution_event`, `fct_error_event`, campos, tipos, regras, decisões D1–D20 |
| [`docs/discovery/arquitetura_de_dados.md`](../docs/discovery/arquitetura_de_dados.md) | Arquitetura Medallion no Fabric: Bronze/Silver/Gold, tabelas `stg_*`/`nrm_*`/`fct_*`, orquestração, janelas, dedup, flows por fonte |

---

## Architecture Overview

### System Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              DATA SOURCES                                     │
│   ODI Oracle (SNP_SESSION, SNP_STEP_REPORT)                                  │
│   ETLTOOLS Oracle (INTERFACE.ETL_*, INTERFACE.ERRO)                          │
│   ETLTOOLS Elastic (logs: 'tabela não iniciada com erro')                    │
│   Power BI REST API (datasets/{id}/refreshes)                                │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│               FABRIC INGESTION / ORCHESTRATION                                │
│   Data Factory Pipelines │ Fabric Notebooks (Python/PySpark)                 │
│   Fabric Workspace Connections │ Key Vault / Secrets                         │
│   stg_ingestion_audit (Delta Table)                                          │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                   BRONZE — Fabric Lakehouse / OneLake / Delta Tables          │
│   stg_odi_exec_raw          stg_odi_error_raw                                │
│   stg_etltools_lote_raw     stg_etltools_erro_raw                            │
│   stg_elastic_not_started_raw                                                │
│   stg_powerbi_raw           stg_ingestion_audit                              │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │  normalização + validação + dedup
                                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                   SILVER — Fabric Lakehouse / Delta Tables                    │
│   nrm_odi_execution         nrm_odi_error                                    │
│   nrm_etltools_execution    nrm_etltools_error                               │
│   nrm_elastic_not_started                                                    │
│   nrm_powerbi_refresh       nrm_powerbi_error                               │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │  joins com dimensões + enriquecimento
                                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│             GOLD — Contrato Canônico / Fabric Warehouse ou Lakehouse          │
│   fct_execution_event       fct_error_event        fct_alert_event           │
│   fct_execution_snapshot    fct_dedup_registry     fct_completeness_report   │
│   dim_catalog_load          dim_sla_policy         dim_owner                 │
│   dim_dataset               dim_source_system      dim_status                │
│   dim_error_catalog         dim_environment        dim_date / dim_time       │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                           CONSUMPTION                                         │
│   Power BI Direct Lake │ Semantic Model │ Dashboards │ Alertas               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Overview

## Agent Architecture & Delegation Plan

### 0. Agentes de Workflow (orquestração de fase)

| Fase | Agente | Responsabilidade neste projeto | Artefato principal |
|---|---|---|---|
| `/workflow:design` | `workflow.design-agent` | Manter arquitetura técnica, manifesto e decisões de design coerentes com DEFINE + contrato canônico | `DESIGN_OBSERVABILITY_HUB.md` |
| `/workflow:iterate` | `workflow.iterate-agent` | Aplicar mudanças no DESIGN com versionamento e análise de impacto/cascade | Atualizações em `DESIGN_OBSERVABILITY_HUB.md` |
| `/workflow:build` | `workflow.build-agent` | Executar manifesto no ambiente alvo informado pelo usuário, gerar evidências por arquivo | Código + `BUILD_REPORT_OBSERVABILITY_HUB.md` |
| `/workflow:validate` | `workflow.validate-agent` | Validar aderência a DEFINE/DESIGN e prontidão operacional com scoring determinístico | `VALIDATION_REPORT_OBSERVABILITY_HUB.md` + runbook/roadmap |
| `/workflow:ship` | `workflow.ship-agent` | Arquivar artefatos aprovados e consolidar lições aprendidas | `SHIPPED_{DATE}.md` |

### 1. Agentes especialistas (delegação recomendada no Build)

| Domínio | Agente primário | Quando delegar | Entregáveis esperados |
|---|---|---|---|
| Pipelines Fabric Data Factory | `platform.fabric-pipeline-developer` | Criação e hardening de pipelines 17–20 | Pipelines com retry, timeout, dependências e logging |
| Arquitetura Fabric/OneLake | `platform.fabric-architect` | Decisões de workspace, lakehouse, separação de ambientes | Padrão de organização por camada e governança |
| Segurança/Governança Fabric | `platform.fabric-security-specialist` | Segredos, permissões, RLS/CLS e compliance de acesso | Matriz de acesso e controles de segredo sem credencial em código |
| Logging/Observabilidade Fabric | `platform.fabric-logging-specialist` | Métricas operacionais, auditoria e troubleshooting | Estratégia de logs + consultas KQL/monitoramento operacional |
| SQL e modelagem analítica | `data-engineering.sql-optimizer` | DDL/DML Gold e otimização de materializações | Queries revisadas para performance e legibilidade |
| Qualidade de dados | `test.data-quality-analyst` | Regras de qualidade Silver/Gold e checks de completude | Suite de validações + evidências no build/validate |

### 2. Matriz Agente → Manifesto

| Bloco do manifesto | Itens | Agente dono | Agentes de apoio |
|---|---:|---|---|
| Notebooks Bronze (1–4) | 4 | `workflow.build-agent` | `platform.fabric-architect`, `platform.fabric-security-specialist` |
| Notebooks Silver (5–7) | 3 | `workflow.build-agent` | `data-engineering.sql-optimizer`, `test.data-quality-analyst` |
| Notebooks Gold (8–12) | 5 | `workflow.build-agent` | `data-engineering.sql-optimizer`, `platform.fabric-logging-specialist` |
| Setup/Schema (13–16) | 4 | `workflow.build-agent` | `platform.fabric-architect` |
| Pipelines FDF (17–20) | 4 | `platform.fabric-pipeline-developer` | `workflow.build-agent`, `platform.fabric-logging-specialist` |
| Utilitários (21–23) | 3 | `workflow.build-agent` | `test.data-quality-analyst` |
| Config (24–26) | 3 | `workflow.build-agent` | `platform.fabric-security-specialist` |
| Runbooks/Docs (27–30) | 4 | `workflow.build-agent` | `platform.fabric-logging-specialist` |

### 3. Regra de execução

1. O `workflow.build-agent` permanece responsável pelo resultado final e pela escrita do `BUILD_REPORT`.
2. Delegações são por bloco independente do manifesto; dependências cruzadas continuam serializadas.
3. Cada delegado deve devolver evidência verificável (comando, output e status) para anexar ao build report.
4. Nenhuma decisão de schema Gold pode divergir do `contrato_canonico.md` sem nova iteração formal.

---

### 1. Orquestração — Fabric Data Factory Pipelines

| Pipeline | Janela UTC | Fontes | Saída Bronze |
|---|---|---|---|
| `pipeline_collect_odi` | 18:00 | ODI Oracle | `stg_odi_exec_raw`, `stg_odi_error_raw` |
| `pipeline_collect_etltools` | 22:00 | ETLTOOLS Oracle + Elastic | `stg_etltools_lote_raw`, `stg_etltools_erro_raw`, `stg_elastic_not_started_raw` |
| `pipeline_collect_powerbi` | 22:00 | Power BI API | `stg_powerbi_raw` |
| `pipeline_materialize_gold` | 17:00 | Silver Tables | Todas as tabelas Gold + `fct_completeness_report` |

Cada pipeline deve registrar em `stg_ingestion_audit`:
- `source_name`, `pipeline_run_id` (Fabric), `window_start`, `window_end`
- `rows_read`, `rows_written`, `rows_dedup_skipped`
- `execution_status` (`SUCCESS` / `FAILED`), `error_message`

### 2. Schema — Camadas Medallion

#### Bronze — Delta Tables (7 tabelas)

| Tabela | Fonte | Propósito |
|---|---|---|
| `stg_odi_exec_raw` | ODI `SNP_SESSION` | Dados brutos de execução ODI |
| `stg_odi_error_raw` | ODI `SNP_STEP_REPORT` | Dados brutos de erro ODI por passo |
| `stg_etltools_lote_raw` | `INTERFACE.ETL_*` | Dados brutos por lote ETLTOOLS |
| `stg_etltools_erro_raw` | `INTERFACE.ERRO` | Dados brutos de erro por linha ETLTOOLS |
| `stg_elastic_not_started_raw` | Elastic logs | Logs de NOT_STARTED com `server_name` |
| `stg_powerbi_raw` | PBI API | Dados brutos de refresh Power BI |
| `stg_ingestion_audit` | Fabric pipeline | Auditoria de todas as coletas |

Campos obrigatórios em todas as tabelas Bronze:
- `fabric_pipeline_run_id` — ID da execução Fabric (rastreabilidade)
- `collected_at` — timestamp da ingestão
- `ingestion_date` — data lógica (partição)

Campos brutos preservados sem transformação (exatamente como chegam da fonte).

#### Silver — Delta Tables normalizadas (7 tabelas)

| Tabela | Bronze Origem | Propósito |
|---|---|---|
| `nrm_odi_execution` | `stg_odi_exec_raw` | Execuções ODI normalizadas (status canônico, dedup, UTC) |
| `nrm_odi_error` | `stg_odi_error_raw` | Erros ODI normalizados (por passo) |
| `nrm_etltools_execution` | `stg_etltools_lote_raw` + `stg_etltools_erro_raw` | Execuções ETLTOOLS agregadas por lote |
| `nrm_etltools_error` | `stg_etltools_erro_raw` | Erros ETLTOOLS por linha |
| `nrm_elastic_not_started` | `stg_elastic_not_started_raw` | NOT_STARTED normalizados com `server_name` |
| `nrm_powerbi_refresh` | `stg_powerbi_raw` | Refreshes PBI normalizados |
| `nrm_powerbi_error` | `stg_powerbi_raw` | Erros PBI classificados por tipo |

#### Gold — Delta Tables / Warehouse (contrato canônico)

| Tabela | Tipo | Propósito |
|---|---|---|
| `fct_execution_event` | Fato — contrato canônico | Eventos de execução normalizados por fonte. Schema = `contrato_canonico.md` seção 3 |
| `fct_error_event` | Fato — contrato canônico | Detalhes de erro com `error_type`, `server_name`, `open_flag`. Schema = `contrato_canonico.md` seção 4 |
| `fct_alert_event` | Fato | Alertas roteáveis (E7 futuro) |
| `fct_execution_snapshot` | Visão desnormalizada | DirectLake target — todos os dims pré-joined |
| `fct_dedup_registry` | Registro | Rastreamento de dedup cross-window |
| `fct_completeness_report` | Métrica | Completeness diária por fonte e janela |
| `dim_catalog_load` | Dimensão | Catálogo mestre de processos (Wave 1 / E1) |
| `dim_sla_policy` | Dimensão | Políticas de SLA por processo |
| `dim_owner` | Dimensão | Owners técnicos e de negócio |
| `dim_dataset` | Dimensão | Datasets Power BI |
| `dim_source_system` | Dimensão | Sistemas de origem (ODI, ETLTOOLS, POWER_BI) |
| `dim_status` | Dimensão | Códigos de status normalizados |
| `dim_error_catalog` | Dimensão | Tipos de erro e padrões de causa raiz |
| `dim_environment` | Dimensão | Ambientes (DEV, EXEC, PROD) |
| `dim_date` | Calendário | Dimensão de data |
| `dim_time` | Calendário | Fatias de tempo intraday |

---

### 3. Schema Gold — fct_execution_event

Schema exato conforme `contrato_canonico.md` v1.4, seção 3. **Este schema é o contrato vivo — não alterar sem peer review e bump de versão no contrato.**

```sql
CREATE TABLE fct_execution_event (
    execution_event_id    STRING NOT NULL,          -- UUID v4, gerado pelo pipeline
    catalog_load_sk       INT,                      -- FK dim_catalog_load (alerta se null)
    sla_policy_sk         INT,                      -- FK dim_sla_policy (null se sem catálogo)
    owner_sk              INT,                      -- FK dim_owner (null = alerta não roteável)
    dataset_sk            INT,                      -- FK dim_dataset (somente PBI)
    system_name           STRING NOT NULL,          -- ODI | ETLTOOLS | POWER_BI
    source_table          STRING NOT NULL,          -- cenário/tabela/modelo semântico
    process_id            STRING NOT NULL,          -- ID do job/processo na fonte
    run_id                STRING NOT NULL,          -- ODI: SESS_NO | ETLTOOLS: lote_id | PBI: refresh_id
    execution_status      STRING NOT NULL,          -- SUCCESS | FAILED | RUNNING
    start_time            TIMESTAMP NOT NULL,       -- UTC, nunca nulo
    end_time              TIMESTAMP,                -- null se RUNNING
    duration_ms           BIGINT,                   -- (end_time - start_time) ms
    detected_at           TIMESTAMP NOT NULL,       -- collected_at do ciclo que identificou falha
    resolved_at           TIMESTAMP,                -- null enquanto ativo
    time_to_detect_ms     BIGINT NOT NULL,          -- (detected_at - start_time) ms — MTTD
    time_in_error_ms      BIGINT,                   -- (resolved_at - detected_at) ms — MTTR, null ativo
    sla_breach_flag       BOOLEAN NOT NULL,         -- default false se sem catálogo
    sla_breach_ms         BIGINT,                   -- (end_time - sla_deadline) ms se violou
    severity              STRING,                   -- P0 | P1 | P2 via dim_catalog_load, null se não catalogado
    environment           STRING NOT NULL,          -- DEV | EXEC | PROD
    has_errors            BOOLEAN NOT NULL,         -- true se msg_error preenchido OU status=FAILED
    msg_error             STRING,                   -- truncar 2000 chars
    error_type            STRING,                   -- EXECUTION | CREDENTIAL | GATEWAY | CAPACITY | UNKNOWN
    correction_url        STRING NOT NULL,          -- link direto ao ponto de correção
    collected_at          TIMESTAMP NOT NULL        -- timestamp da ingestão
)
USING DELTA
PARTITIONED BY (ingestion_date DATE);
```

### 4. Schema Gold — fct_error_event

Schema exato conforme `contrato_canonico.md` v1.4, seção 4.

```sql
CREATE TABLE fct_error_event (
    error_event_id        STRING NOT NULL,          -- UUID v4, gerado pelo pipeline
    execution_event_id    STRING,                   -- FK fct_execution_event — NULL para NOT_STARTED Elastic
    catalog_load_sk       INT NOT NULL,             -- FK dim_catalog_load (herdado ou via source_table)
    system_name           STRING NOT NULL,          -- ODI | ETLTOOLS | POWER_BI
    source_table          STRING NOT NULL,          -- objeto de origem onde o erro ocorreu
    run_id                STRING,                   -- null para NOT_STARTED Elastic
    process_id            STRING NOT NULL,          -- herdado do pai ou extraído do log
    server_name           STRING,                   -- EXCLUSIVO NOT_STARTED Elastic (campo 'servidor')
    error_code            STRING NOT NULL,          -- NOT_STARTED: 'NOT_STARTED'. Sem código: 'UNKNOWN'
    msg_error             STRING NOT NULL,          -- nunca nulo
    error_type            STRING NOT NULL,          -- EXECUTION | CREDENTIAL | GATEWAY | CAPACITY | NOT_STARTED | UNKNOWN
    root_cause_hint       STRING,                   -- NOT_STARTED: inclui server_name
    occurred_at           TIMESTAMP NOT NULL,       -- Elastic: @timestamp
    detected_at           TIMESTAMP NOT NULL,       -- Elastic: = occurred_at
    resolved_at           TIMESTAMP,                -- null enquanto ativo
    time_to_detect_ms     BIGINT NOT NULL,          -- Elastic NOT_STARTED: 0
    time_in_error_ms      BIGINT,                   -- null enquanto ativo
    open_flag             BOOLEAN NOT NULL,         -- true se resolved_at = null, atualizado a cada ciclo
    correction_url        STRING NOT NULL,          -- link direto à correção
    severity              STRING NOT NULL           -- herdado do pai ou via dim_catalog_load
)
USING DELTA
PARTITIONED BY (ingestion_date DATE);
```

---

### 5. Deduplicação Cross-Window

Conforme `arquitetura_de_dados.md` seção 7.

**Chave composta por fonte:**

| Fonte | Chave de dedup |
|---|---|
| ODI | `MD5('ODI' \|\| SESS_NO \|\| SESS_BEG)` |
| ETLTOOLS Oracle | `MD5('ETLTOOLS' \|\| source_table \|\| lote_id)` |
| ETLTOOLS Elastic | `source_table + server_name + occurred_at` (sem hash — sem run_id) |
| Power BI | `MD5('POWER_BI' \|\| dataset_id \|\| refresh_id \|\| start_ts)` |

**Algoritmo:**
1. Gerar `dedup_id` para cada evento entrante
2. Verificar em `fct_dedup_registry`
3. Se existe com mesma janela → skip (duplicata)
4. Se existe com janela diferente → incrementar `occurrence_count` (cross-window confirmado)
5. Se novo → inserir no registry + prosseguir para tabelas fato

---

### 6. Normalização de Status por Fonte

| Status Bruto | Fonte | Status Canônico |
|---|---|---|
| `D` | ODI | `SUCCESS` |
| `E` | ODI | `FAILED` |
| `R` | ODI | `RUNNING` |
| `W` | ODI | `PENDING` |
| Sem erro no lote | ETLTOOLS Oracle | `SUCCESS` |
| Com erro no lote | ETLTOOLS Oracle | `FAILED` |
| Log encontrado | ETLTOOLS Elastic | `NOT_STARTED` (somente em `fct_error_event`) |
| `Completed` | Power BI | `SUCCESS` |
| `Failed` | Power BI | `FAILED` |
| `Unknown` | Power BI | `RUNNING` |

> **Regra D16 do contrato:** `NOT_STARTED` é exclusivo do Elastic — nunca derivado da tabela de controle Oracle.

---

## Key Design Decisions

### Decision 1: Fabric como plataforma única desde o início

| Atributo | Valor |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-05-18 |

**Contexto:** Decisão anterior previa fase local (DuckDB/APScheduler) antes de Fabric. Isso criava risco de re-trabalho e divergência de schemas.

**Escolha:** Fabric Lakehouse como plataforma única desde o build inicial.
- Bronze/Silver/Gold: Delta Tables no OneLake
- Orquestração: Fabric Data Factory Pipelines + Notebooks agendados
- Consumo: Power BI Direct Lake sobre tabelas Gold

**Rationale:**
- Elimina fase de migração e risco de divergência
- OneLake é single source of truth desde o primeiro dia
- Direct Lake lê Delta diretamente — sem latência de import
- Credenciais gerenciadas via Fabric Workspace Connections (mais seguro que .env local)

**Alternativas rejeitadas:**
1. DuckDB local → Fabric: Re-trabalho garantido; schemas podem divergir
2. Azure Data Factory externo: Overhead desnecessário quando Fabric tem pipelines nativos

---

### Decision 2: contrato_canonico.md como único schema de referência para Gold

| Atributo | Valor |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-05-18 |

**Contexto:** Versões anteriores do DESIGN tinham schemas parcialmente derivados do contrato canônico, com divergências em campos e tipos.

**Escolha:** `contrato_canonico.md` v1.4 é a única fonte de verdade para `fct_execution_event` e `fct_error_event`. Qualquer alteração nesses schemas exige:
1. Atualização do `contrato_canonico.md`
2. Peer review
3. Bump de versão
4. Cascade para DEFINE e DESIGN via `/workflow:iterate`

**Rationale:**
- Garante que painel, alertas, métricas e engenharia falam a mesma língua
- Decisões D1–D20 do contrato cobrem todos os casos edge (NOT_STARTED, campos derivados, etc.)
- Sem contrato único, cada engenheiro interpreta diferente

---

### Decision 3: Medallion Architecture no Fabric

| Atributo | Valor |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-04-18 (confirmado 2026-05-18) |

**Escolha:** Bronze → Silver → Gold conforme `arquitetura_de_dados.md` v1.2.
- **Bronze**: Preserva dado bruto exatamente como chega da fonte
- **Silver**: Normaliza, valida, padroniza status, aplica dedup por origem
- **Gold**: Expõe contrato canônico consumível por DirectLake, alertas e métricas

**Regra operacional:** Bronze não transforma. Silver não expõe para consumo externo. Gold é o contrato.

---

### Decision 4: Elastic NOT_STARTED como origem exclusiva de server_name

| Atributo | Valor |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-05-18 |

**Contexto:** Processos que não iniciaram no ETLTOOLS não têm `lote_id`, não têm execução pai, e chegam via Elastic com campo `servidor`.

**Escolha:** Conforme decisões D16–D20 do `contrato_canonico.md`:
- `NOT_STARTED` é derivado exclusivamente do Elastic
- `execution_event_id = null` (sem pai)
- `run_id = null` (sem lote)
- `server_name` = campo `servidor` do log (obrigatório para NOT_STARTED, null para todas as demais origens)
- `time_to_detect_ms = 0` (log = detecção imediata)
- Chave de dedup: `source_table + server_name + occurred_at`

---

### Decision 5: Campos de janela temporal obrigatórios (MTTD/MTTR automáticos)

| Atributo | Valor |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-05-18 |

**Contexto:** Critério de aceite 3 do programa exige MTTD e MTTR calculados sem entrada manual.

**Escolha:** Conforme decisão D10 do `contrato_canonico.md`, os seguintes campos são obrigatórios em todos os eventos:
- `detected_at`, `resolved_at`, `time_to_detect_ms`, `time_in_error_ms`, `open_flag`, `sla_breach_ms`

**Fórmulas:**
- `time_to_detect_ms = (detected_at − start_time)` ms → componente MTTD
- `time_in_error_ms = (resolved_at − detected_at)` ms → componente MTTR
- `open_flag = (resolved_at IS NULL)` — atualizado pelo pipeline a cada ciclo

---

### Decision 6: correction_url obrigatório em ambas as entidades

| Atributo | Valor |
|---|---|
| **Status** | Accepted |
| **Date** | 2026-05-18 |

**Contexto:** Critério operacional — operador chega ao ponto de correção em 2 cliques.

**Escolha:** Conforme decisão D15 do `contrato_canonico.md`, `correction_url` é obrigatório em `fct_execution_event` e `fct_error_event`. Montado pelo pipeline por fonte:

| Fonte | URL de correção |
|---|---|
| ODI | `{base_url}/odi/job/{source_table}/{run_id}` |
| ETLTOOLS Oracle | referência à `source_table` + `lote_id` na `tabela_erro` |
| ETLTOOLS Elastic | `server_name` + `source_table` |
| Power BI | `{pbi_base_url}/groups/{workspace_id}/datasets/{dataset_id}` |

---

## File Manifest

> Todos os arquivos são criados no Fabric Workspace. Notebooks são artefatos `.ipynb` no Lakehouse. Pipelines são configurados no Fabric Data Factory.

| # | Arquivo | Tipo | Ação | Propósito |
|---|---|---|---|---|
| **NOTEBOOKS — Bronze (Collectors)** | | | | |
| 1 | `notebooks/bronze/collect_odi.ipynb` | Fabric Notebook | Create | Extrai ODI Oracle → `stg_odi_exec_raw` + `stg_odi_error_raw` |
| 2 | `notebooks/bronze/collect_etltools.ipynb` | Fabric Notebook | Create | Extrai ETLTOOLS Oracle → `stg_etltools_lote_raw` + `stg_etltools_erro_raw` |
| 3 | `notebooks/bronze/collect_elastic.ipynb` | Fabric Notebook | Create | Extrai Elastic NOT_STARTED → `stg_elastic_not_started_raw` |
| 4 | `notebooks/bronze/collect_powerbi.ipynb` | Fabric Notebook | Create | Polling API PBI → `stg_powerbi_raw` |
| **NOTEBOOKS — Silver (Normalization)** | | | | |
| 5 | `notebooks/silver/normalize_odi.ipynb` | Fabric Notebook | Create | Bronze ODI → `nrm_odi_execution` + `nrm_odi_error` |
| 6 | `notebooks/silver/normalize_etltools.ipynb` | Fabric Notebook | Create | Bronze ETLTOOLS → `nrm_etltools_execution` + `nrm_etltools_error` + `nrm_elastic_not_started` |
| 7 | `notebooks/silver/normalize_powerbi.ipynb` | Fabric Notebook | Create | Bronze PBI → `nrm_powerbi_refresh` + `nrm_powerbi_error` |
| **NOTEBOOKS — Gold (Materialization)** | | | | |
| 8 | `notebooks/gold/materialize_execution_event.ipynb` | Fabric Notebook | Create | Silver → `fct_execution_event` (MERGE/UPSERT por `run_id` + `system_name`) |
| 9 | `notebooks/gold/materialize_error_event.ipynb` | Fabric Notebook | Create | Silver → `fct_error_event` (incluindo NOT_STARTED Elastic) |
| 10 | `notebooks/gold/materialize_snapshot.ipynb` | Fabric Notebook | Create | Gold fcts + dims → `fct_execution_snapshot` (desnormalizado DirectLake) |
| 11 | `notebooks/gold/materialize_completeness.ipynb` | Fabric Notebook | Create | `fct_completeness_report` diário por fonte + janela |
| 12 | `notebooks/gold/update_open_flags.ipynb` | Fabric Notebook | Create | Atualiza `open_flag` e `resolved_at` em `fct_error_event` a cada ciclo |
| **NOTEBOOKS — Schema / Setup** | | | | |
| 13 | `notebooks/setup/create_schema_bronze.ipynb` | Fabric Notebook | Create | DDL Delta Tables Bronze (7 tabelas) |
| 14 | `notebooks/setup/create_schema_silver.ipynb` | Fabric Notebook | Create | DDL Delta Tables Silver (7 tabelas) |
| 15 | `notebooks/setup/create_schema_gold.ipynb` | Fabric Notebook | Create | DDL Delta Tables Gold (fcts + dims conforme contrato canônico) |
| 16 | `notebooks/setup/seed_dimensions.ipynb` | Fabric Notebook | Create | Popular dimensões de referência (source_system, status, error_catalog, environment) |
| **PIPELINES — Fabric Data Factory** | | | | |
| 17 | `pipelines/pipeline_collect_odi.json` | FDF Pipeline | Create | Orquestra notebooks 1 + 5 (18h UTC); Gold centralizado em `pipeline_materialize_gold` |
| 18 | `pipelines/pipeline_collect_etltools.json` | FDF Pipeline | Create | Orquestra notebooks 2+3 + 6 (22h UTC); Gold centralizado em `pipeline_materialize_gold` |
| 19 | `pipelines/pipeline_collect_powerbi.json` | FDF Pipeline | Create | Orquestra notebooks 4 + 7 (22h UTC); Gold centralizado em `pipeline_materialize_gold` |
| 20 | `pipelines/pipeline_materialize_gold.json` | FDF Pipeline | Create | Orquestra notebooks 8+9+12+10+11 (17h UTC) |
| **UTILITÁRIOS** | | | | |
| 21 | `notebooks/utils/dedup.ipynb` | Fabric Notebook | Create | Funções de dedup cross-window (chave por fonte, `fct_dedup_registry`) |
| 22 | `notebooks/utils/audit_logger.ipynb` | Fabric Notebook | Create | Funções de log em `stg_ingestion_audit` |
| 23 | `notebooks/utils/correction_url_builder.ipynb` | Fabric Notebook | Create | Funções de montagem de `correction_url` por fonte |
| **CONFIG** | | | | |
| 24 | `config/sources.json` | JSON | Create | Configuração de fontes: hosts Oracle, workspaces PBI, índice Elastic |
| 25 | `config/collection_windows.json` | JSON | Create | Janelas de coleta por fonte (18h, 22h, 17h) |
| 26 | `config/expected_counts.json` | JSON | Create | Contagens esperadas por fonte para `fct_completeness_report` |
| **DOCUMENTAÇÃO** | | | | |
| 27 | `docs/runbooks/odi_failure.md` | Markdown | Create | Runbook para falha ODI — usar `correction_url` do evento |
| 28 | `docs/runbooks/etltools_not_started.md` | Markdown | Create | Runbook NOT_STARTED Elastic — `server_name` + `source_table` |
| 29 | `docs/runbooks/powerbi_credential.md` | Markdown | Create | Runbook falha credencial PBI |
| 30 | `docs/architecture/fabric_setup.md` | Markdown | Create | Setup do Workspace Fabric, conexões, Key Vault |
| **ARQUITETURA / GOVERNANÇA FABRIC** | | | | |
| 31 | `docs/architecture/fabric_environment_topology.md` | Markdown | Create | Topologia DEV/TEST/PROD (`OBSERVABILITY-HUB-DEV/test/prod`) e estratégia de promoção via Deployment Pipeline |
| 32 | `docs/architecture/gold_serving_decision.md` | Markdown | Create | Guard de decisão de serving Gold (Lakehouse vs Warehouse), critérios, exceções e change control via `/workflow:iterate` |
| 33 | `docs/architecture/capacity_sku_plan.md` | Markdown | Create | Política de capacidade/SKU por ambiente, orçamento, limites e escalonamento |
| 34 | `docs/architecture/onelake_organization.md` | Markdown | Create | Organização OneLake por domínio/camada/ambiente e convenções de naming/paths |
| **SEGURANÇA / COMPLIANCE** | | | | |
| 35 | `docs/security/rbac_matrix.md` | Markdown | Create | Matriz RBAC por persona (Admin, Data Engineer, BI Engineer, Operator, Viewer) e permissões mínimas |
| 36 | `docs/security/secrets_rotation_policy.md` | Markdown | Create | Política de segredos (Key Vault/Connections), rotação, owner, periodicidade e evidências |
| **OPERAÇÕES / SRE** | | | | |
| 37 | `docs/operations/slo_sla_operacional.md` | Markdown | Create | SLO/SLA operacionais do hub (latência, disponibilidade, RTO/RPO, MTTR) |
| 38 | `docs/operations/alerting_matrix.md` | Markdown | Create | Matriz de alertas por severidade, serviço, owner/on-call e ação esperada |
| 39 | `docs/runbooks/disaster_recovery_bcp.md` | Markdown | Create | Runbook de DR/BCP com cenários de falha, failover e procedimentos de recuperação |
| **MONITORAMENTO KQL** | | | | |
| 40 | `monitoring/kql/pipeline_failures.kql` | KQL | Create | Query de falhas de pipeline/FDF com correlação por run id |
| 41 | `monitoring/kql/capacity_throttling.kql` | KQL | Create | Query de throttling/capacity pressure e impacto em SLAs |
| 42 | `monitoring/kql/semantic_model_refresh_failures.kql` | KQL | Create | Query de falhas e duração de refresh do semantic model |
| **SEMANTIC MODEL (TMDL)** | | | | |
| 43 | `semantic-model/observability_hub/model.tmdl` | TMDL | Create | Estrutura do semantic model, tabelas e relacionamentos canônicos de consumo |
| 44 | `semantic-model/observability_hub/measures/base_measures.tmdl` | TMDL | Create | Medidas base (MTTD, MTTR, SLA breach rate, success/error rates) e convenções de naming |
| 45 | `semantic-model/observability_hub/roles/rls_roles.tmdl` | TMDL | Create | Definições de RLS por ambiente, owner e domínio operacional |
| 46 | `semantic-model/observability_hub/deployment/bindings.json` | JSON | Create | Bindings por ambiente (workspace/lakehouse/warehouse/dataset) para promotion segura |
| **CI/CD FABRIC** | | | | |
| 47 | `cicd/fabric/deployment_pipeline.yml` | YAML | Create | Pipeline de promoção DEV→TEST→PROD com gates e aprovações |
| 48 | `cicd/fabric/artifact_manifest.json` | JSON | Create | Inventário versionado de artefatos Fabric promovíveis |
| 49 | `.github/workflows/fabric-ci.yml` | YAML | Create | CI para lint/validate de notebooks, TMDL, KQL e configs Fabric |
| **CONFIG FABRIC POR AMBIENTE** | | | | |
| 50 | `config/fabric/connections.dev.json` | JSON | Create | Mapeamento de conexões/identidades para DEV |
| 51 | `config/fabric/connections.homolog.json` | JSON | Create | Mapeamento de conexões/identidades para TEST |
| 52 | `config/fabric/connections.prod.json` | JSON | Create | Mapeamento de conexões/identidades para PROD |
| 53 | `config/fabric/retry_policy.json` | JSON | Create | Política padrão de retry/backoff/timeouts para pipelines e notebooks |

---

## Code Patterns

### Pattern 1: Collector Template (Fabric Notebook Python)

```python
# notebooks/bronze/collect_odi.ipynb
from pyspark.sql import SparkSession
from datetime import datetime, timezone
import uuid

spark = SparkSession.builder.getOrCreate()

def collect_odi_executions(connection, collected_at: datetime) -> list[dict]:
    """
    Extrai sessões ODI das tabelas de controle.
    Campos brutos preservados — sem transformação.
    """
    query = """
        SELECT
            SESS_NO           AS session_id,
            SCEN_NAME         AS scenario_name,
            SESS_STATUS       AS status_raw,
            SESS_BEG          AS start_ts,
            SESS_END          AS end_ts,
            ERROR_MESSAGE     AS error_message_raw,
            NB_ERR            AS nb_err,
            AGENT_NAME        AS agent_name,
            CONTEXT_CODE      AS context_code,
            SB_NO             AS sb_no
        FROM SNP_SESSION
        WHERE SESS_BEG >= :window_start
    """
    rows = connection.execute(query, window_start=window_start)
    
    pipeline_run_id = mssparkutils.env.getJobId()
    
    return [
        {**dict(row),
         "fabric_pipeline_run_id": pipeline_run_id,
         "collected_at": collected_at.isoformat(),
         "ingestion_date": collected_at.date().isoformat()}
        for row in rows
    ]

def write_bronze(records: list[dict], table_name: str):
    """Escreve em Delta Table Bronze via append."""
    df = spark.createDataFrame(records)
    df.write.format("delta").mode("append").saveAsTable(table_name)
```

### Pattern 2: Silver Normalization (PySpark)

```python
# notebooks/silver/normalize_odi.ipynb
from pyspark.sql import functions as F

STATUS_MAP_ODI = {"D": "SUCCESS", "E": "FAILED", "R": "RUNNING", "W": "PENDING"}
status_map_expr = F.create_map([F.lit(k), F.lit(v) for kv in STATUS_MAP_ODI.items() for k, v in [kv]])

def normalize_odi_executions():
    bronze = spark.table("stg_odi_exec_raw")
    
    silver = bronze.withColumn(
        "execution_status",
        status_map_expr[F.col("status_raw")]
    ).withColumn(
        "run_id", F.col("session_id")
    ).withColumn(
        "source_table", F.col("scenario_name")
    ).withColumn(
        "dedup_id",
        F.md5(F.concat_ws("|", F.lit("ODI"), F.col("session_id"), F.col("start_ts")))
    ).withColumn(
        "start_time", F.to_utc_timestamp(F.col("start_ts"), "America/Sao_Paulo")
    ).withColumn(
        "end_time",
        F.when(F.col("status_raw") == "R", F.lit(None))
         .otherwise(F.to_utc_timestamp(F.col("end_ts"), "America/Sao_Paulo"))
    )
    
    silver.write.format("delta").mode("overwrite").option("overwriteSchema", "true").saveAsTable("nrm_odi_execution")
```

### Pattern 3: Gold Materialization (MERGE)

```python
# notebooks/gold/materialize_execution_event.ipynb
from delta.tables import DeltaTable
import uuid
from datetime import datetime, timezone

def materialize_execution_event(source_df):
    """
    MERGE Silver → fct_execution_event.
    Chave de merge: system_name + run_id
    Atualiza resolved_at, time_in_error_ms, sla_breach_flag se necessário.
    """
    enriched = source_df.withColumn(
        "execution_event_id", F.udf(lambda: str(uuid.uuid4()))()
    ).withColumn(
        "collected_at", F.lit(datetime.now(timezone.utc).isoformat())
    ).withColumn(
        "has_errors",
        F.when(F.col("execution_status") == "FAILED", F.lit(True))
         .when(F.col("msg_error").isNotNull(), F.lit(True))
         .otherwise(F.lit(False))
    ).withColumn(
        "time_to_detect_ms",
        (F.unix_timestamp("detected_at") - F.unix_timestamp("start_time")) * 1000
    ).withColumn(
        "sla_breach_flag", F.lit(False)  # atualizado via join dim_sla_policy quando E1 disponível
    )
    
    if DeltaTable.isDeltaTable(spark, "Tables/fct_execution_event"):
        delta_table = DeltaTable.forName(spark, "fct_execution_event")
        delta_table.alias("target").merge(
            enriched.alias("source"),
            "target.system_name = source.system_name AND target.run_id = source.run_id"
        ).whenMatchedUpdate(set={
            "execution_status": "source.execution_status",
            "end_time": "source.end_time",
            "duration_ms": "source.duration_ms",
            "resolved_at": "source.resolved_at",
            "time_in_error_ms": "source.time_in_error_ms",
            "has_errors": "source.has_errors"
        }).whenNotMatchedInsertAll().execute()
    else:
        enriched.write.format("delta").saveAsTable("fct_execution_event")
```

### Pattern 4: NOT_STARTED Elastic → fct_error_event

```python
# notebooks/gold/materialize_error_event.ipynb (trecho Elastic)

def materialize_not_started(elastic_df):
    """
    NOT_STARTED do Elastic vai diretamente para fct_error_event.
    Sem execution_event_id pai. Sem run_id.
    """
    not_started = elastic_df.select(
        F.udf(lambda: str(uuid.uuid4()))().alias("error_event_id"),
        F.lit(None).cast("string").alias("execution_event_id"),   # D18: sem pai
        F.col("source_table"),
        F.col("server_name_raw").alias("server_name"),             # D19: exclusivo Elastic
        F.lit(None).cast("string").alias("run_id"),                # D17: sem lote_id
        F.col("process_id_raw").alias("process_id"),
        F.lit("ETLTOOLS").alias("system_name"),
        F.lit("NOT_STARTED").alias("error_code"),
        F.col("msg_error_raw").alias("msg_error"),
        F.lit("NOT_STARTED").alias("error_type"),
        F.to_utc_timestamp(F.col("occurred_at"), "UTC").alias("occurred_at"),
        F.to_utc_timestamp(F.col("occurred_at"), "UTC").alias("detected_at"),  # D20: = occurred_at
        F.lit(0).alias("time_to_detect_ms"),                       # D20: 0 para Elastic
        F.lit(None).cast("bigint").alias("time_in_error_ms"),
        F.lit(None).cast("timestamp").alias("resolved_at"),
        F.lit(True).alias("open_flag"),
        F.concat(
            F.lit(BASE_URL + "/etltools/not-started/"),
            F.col("source_table"), F.lit("/"), F.col("server_name_raw")
        ).alias("correction_url")
    )
    
    not_started.write.format("delta").mode("append").saveAsTable("fct_error_event")
```

---

## Validação de Qualidade (Silver Layer)

Em cada notebook Silver, antes do MERGE para Gold:

```python
VALIDATION_RULES = {
    "nrm_odi_execution": {
        "not_null": ["session_id", "execution_status", "start_time", "source_table", "run_id"],
        "valid_values": {"execution_status": ["SUCCESS", "FAILED", "RUNNING", "PENDING"]},
        "no_future_ts": ["start_time"],
        "no_negative_duration": ["duration_ms"]
    }
}

def validate_silver(df, table_name: str, audit_conn) -> tuple[DataFrame, int]:
    """Valida DataFrame Silver. Retorna (df_valido, qtd_warns)."""
    rules = VALIDATION_RULES.get(table_name, {})
    warns = 0
    
    for col in rules.get("not_null", []):
        nulls = df.filter(F.col(col).isNull()).count()
        if nulls > 0:
            log_audit(audit_conn, table_name, "WARN", f"{nulls} NULLs em {col}")
            warns += nulls
    
    return df, warns
```

---

## Especificações Não Funcionais (obrigatórias)

| Categoria | Requisito | Como validar |
|---|---|---|
| Performance | Materialização Gold concluída em até 60 min após janela | Tempo de execução dos pipelines 17–20 + timestamps de auditoria |
| Idempotência | Reprocessar mesma janela não gera duplicata de negócio | Colisão de `dedup_id` + incremento correto em `fct_dedup_registry` |
| Confiabilidade | Falha em uma fonte não bloqueia ingestão das demais | Execuções com isolamento por pipeline e status independente no audit |
| Segurança | Zero segredo em notebook/config versionado | Scan de artefatos + uso exclusivo de Workspace Connections/Key Vault |
| Auditabilidade | 100% das execuções com trilha em `stg_ingestion_audit` | Cobertura por `pipeline_run_id`, rows_read/written, status e erro |
| Operação | Tempo de triagem < 2 min via `correction_url` | Teste de drill-down AT-006 com runbook |

## Fabric Runtime Readiness (Gate para Build em ambiente real)

### 1) Topologia de ambientes e promoção

- Workspaces obrigatórios: `OBSERVABILITY-HUB-DEV`, `OBSERVABILITY-HUB-HOMOLOG`, `OBSERVABILITY-HUB-PROD`.
- Promoção obrigatória via Fabric Deployment Pipeline (sem deploy direto em PROD).
- Fluxo padrão: DEV (build técnico) → TEST (validação integrada/operacional) → PROD (go-live com aprovação).
- Artefatos promovidos: notebooks, pipelines, semantic model (TMDL), KQL, configurações de conexão e políticas operacionais.

### 2) Capacity/SKU policy + Direct Lake prerequisites + fallback

- Definir plano de capacidade/SKU por ambiente com budget, autoscale permitido e limites de throttling aceitáveis.
- Pré-requisitos Direct Lake mínimos:
  - Tabelas Gold em formato Delta consistente e com governança de refresh;
  - Semantic model com bindings corretos para o ambiente;
  - Capacidade com memória/concurrency compatível com janela de consumo.
- Estratégia de fallback (quando Direct Lake degradar):
  1. priorizar mitigação de capacidade (scale-up/scale-out conforme política);
  2. fallback controlado para modo Import/Hybrid no semantic model, com registro de incidente;
  3. retorno para Direct Lake após estabilização e validação de desempenho.

### 3) Gold serving decision guard (Lakehouse vs Warehouse)

- Decisão de serving Gold deve ser explícita e registrada em `docs/architecture/gold_serving_decision.md`.
- Guardrails de decisão:
  - Lakehouse quando Direct Lake end-to-end e governança Delta atenderem requisitos;
  - Warehouse quando houver necessidade de padrões SQL serving/governança que excedam o modelo Lakehouse.
- Mudança de serving target é considerada **modificação arquitetural controlada** e exige `/workflow:iterate` com atualização de DESIGN + critérios de validação.

### 4) Semantic model operational details

- Semantic model tratado como artefato versionado (TMDL): `semantic-model/observability_hub/*`.
- Obrigatório incluir:
  - medidas base (MTTD, MTTR, SLA breach, taxa de falha/sucesso);
  - roles de RLS por persona/domínio;
  - política de incremental refresh por tabela de maior volume;
  - deployment bindings por ambiente (DEV/TEST/PROD).
- Toda mudança de medida crítica, RLS ou binding entra no pipeline CI/CD e só promove com gate verde.

### 5) Security / Governance / Operations requirements

- RBAC por persona com princípio de menor privilégio (Admin, Data Engineer, BI Engineer, Operator, Viewer).
- Política de segredos: nenhum segredo em notebook/config versionado; rotação periódica e trilha de auditoria.
- Operações e observabilidade:
  - monitoring operacional com KQL para falhas de pipeline, throttling e refresh semântico;
  - matriz de alertas com severidade, owner, SLA de resposta e runbook associado;
  - SLO/SLA operacionais formalizados e validados em `/workflow:validate`.
- Continuidade:
  - runbook de DR/BCP com RTO/RPO declarados e testes periódicos de restauração/failover.

## Critérios de Prontidão para Build/Validate

### Ready for Build

- Manifesto completo (itens 1–30) com agente dono por bloco
- DDL Gold conferido contra `contrato_canonico.md` v1.4
- Definição explícita de estratégia de dedup por fonte
- Estratégia de segredos definida (Workspace Connections / Key Vault)
- Topologia DEV/TEST/PROD definida e documentada (`OBSERVABILITY-HUB-DEV/test/prod`)
- Deployment Pipeline definido com gates de promoção e aprovações
- Decisão de serving Gold (Lakehouse vs Warehouse) registrada e aprovada
- Plano de capacidade/SKU aprovado com pré-requisitos Direct Lake documentados
- Semantic model versionado em TMDL com medidas base + RLS + bindings por ambiente
- CI configurada para validar notebooks, TMDL, KQL e configs de ambiente
- `config/fabric/connections.{dev,test,prod}.json` e `retry_policy.json` versionados

### Ready for Validate

- Evidências de execução dos pipelines 17–20
- Evidências de qualidade (null-rate, dedup, completeness)
- Evidências dos acceptance tests críticos: AT-003, AT-005, AT-006, AT-007
- Runbooks operacionais disponíveis para ODI, ETLTOOLS NOT_STARTED e Power BI credencial
- Evidências de promoção DEV→TEST via Deployment Pipeline
- Evidências de saúde de capacidade (sem throttling crítico recorrente) ou plano de mitigação aceito
- Evidências de refresh do semantic model (sucesso, duração, falhas tratadas)
- Validação de RLS por persona com testes de acesso
- Alerting matrix ativa com KQL operacional e roteamento para on-call
- SLO/SLA operacionais medidos e dentro do limiar acordado
- DR/BCP validado (ao menos teste tabletop + evidência de execução de runbook)

---

## Diagrama de Fluxo de Dados — NOT_STARTED

```
Elastic Log
  @timestamp, source_table, servidor, message
        │
        ▼
stg_elastic_not_started_raw  (Bronze Delta)
  occurred_at, source_table, server_name_raw, msg_error_raw, fabric_pipeline_run_id
        │
        ▼
nrm_elastic_not_started  (Silver Delta)
  source_table, server_name, error_code='NOT_STARTED', time_to_detect_ms=0
        │
        ▼
fct_error_event  (Gold Delta — contrato canônico)
  execution_event_id=null, run_id=null, server_name=servidor
  error_type='NOT_STARTED', open_flag=true, correction_url com server_name
```

---

## Matriz de Decisões do Contrato Canônico Aplicadas

| Decisão | Impacto no DESIGN |
|---|---|
| D1 — `execution_event_id` gerado pelo pipeline | `uuid4()` no notebook de materialização Gold, nunca da fonte |
| D2 — Separação DEV/EXEC no pipeline | Campo `environment` derivado na Silver a partir do schema/tabela de origem ODI |
| D3 — Evento sem catálogo persiste com alerta | `catalog_load_sk` pode ser null; `stg_ingestion_audit` registra alerta |
| D5 — `duration_ms` ETLTOOLS é APROXIMAÇÃO | Documentado no notebook Silver com comentário explícito |
| D6 — ETLTOOLS: agregação por lote + detalhe por linha | Dois notebooks Silver: `normalize_etltools` (lote→execution) + (linha→error) |
| D10 — Campos temporais obrigatórios | `detected_at`, `time_to_detect_ms`, `open_flag` são NOT NULL no DDL |
| D14 — `error_type` classificado antes de persistir | Classificação no notebook Silver antes do MERGE Gold |
| D15 — `correction_url` obrigatório | `correction_url_builder.ipynb` chamado em todos os notebooks Gold |
| D16 — `NOT_STARTED` exclusivo do Elastic | Notebooks de normalização Oracle nunca geram `NOT_STARTED` |
| D19 — `server_name` exclusivo Elastic | Campo presente no DDL de `fct_error_event`, null para todas as demais origens |
## Status: ✅ Shipped
