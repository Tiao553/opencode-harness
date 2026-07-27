# DESIGN: DAG Factory Medallion

> Technical design for the current Composer medallion orchestration: **3 active DAGs only** — one Bronze DAG, one Silver DAG, and one lightweight monitoring/orchestrator DAG.

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | DAG_FACTORY_MEDALLION |
| **Date** | 2026-05-19 |
| **Updated** | 2026-05-20 |
| **Author** | design-agent + implementation updates |
| **DEFINE** | [DEFINE_DAG_FACTORY_MEDALLION.md](./DEFINE_DAG_FACTORY_MEDALLION.md) |
| **Status** | Implemented |

---

## Architecture Overview

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                          COMPOSER MEDALLION ORCHESTRATION                   │
├──────────────────────────────────────────────────────────────────────────────┤
│ dags/.airflowignore                                                         │
│   └─ prevents Airflow from parsing internal packages/configs as DAG files    │
│                                                                              │
│ Active DAG #1: bronze_medallion                                              │
│   File: dags/bronze_medallion_dag.py                                         │
│   Schedule: 0 6 * * *                                                        │
│   Builds: one TaskGroup per pipeline config                                  │
│   Concurrency: heavy Cloud Run tasks limited by pool_bronze (4 slots)        │
│                                                                              │
│      bronze_fonograma              ─┐                                       │
│      bronze_grupo                   │ parallel, dependency-aware             │
│      bronze_titular                 │ via depends_on                         │
│      ...                            ┘                                       │
│               │                                                              │
│               ▼                                                              │
│      record_bronze_complete                                                │
│        outlets=[Dataset("dataset://medallion/bronze/complete")]             │
│                                                                              │
│                         Dataset event                                        │
│                              │                                               │
│                              ▼                                               │
│ Active DAG #2: silver_medallion                                              │
│   File: dags/silver_medallion_dag.py                                         │
│   Schedule: [Dataset("dataset://medallion/bronze/complete")]                │
│   Builds: one TaskGroup per pipeline config                                  │
│   Concurrency: heavy Dataform invocation tasks limited by pool_silver        │
│                                                                              │
│      silver_fonograma              ─┐                                       │
│      silver_grupo                   │ parallel, dependency-aware             │
│      silver_titular                 │ via depends_on                         │
│      ...                            ┘                                       │
│               │                                                              │
│               ▼                                                              │
│      record_silver_complete                                                │
│                                                                              │
│ Active DAG #3: medallion_orchestrator_monitor                                │
│   File: dags/orchestrator_monitoring_dag.py                                  │
│   Schedule: 0 8 * * *                                                        │
│   Purpose: lightweight inventory/health reporting only                       │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Current Components

| Component | Purpose | Notes |
|-----------|---------|-------|
| `dags/bronze_medallion_dag.py` | Active Bronze DAG entrypoint | Registers exactly one DAG: `bronze_medallion` |
| `dags/silver_medallion_dag.py` | Active Silver DAG entrypoint | Registers exactly one DAG: `silver_medallion` |
| `dags/orchestrator_monitoring_dag.py` | Monitoring/orchestrator inventory DAG | Registers `medallion_orchestrator_monitor`; does not trigger workloads |
| `dags/.airflowignore` | Composer parse optimization | Prevents internal modules/configs from being parsed as DAG files |
| `config_loader.py` | YAML discovery/parser | Loads `*_pipeline.yaml`; `schedule` is no longer required/used |
| `validation.py` | Config/dependency validation | Validates layer rules, duplicate IDs, unknown dependencies and cycles |
| `models.py` | Typed config models | `PipelineConfig` no longer owns per-pipeline DAG IDs |
| `bronze_factory.py` | Builds one Bronze DAG with N TaskGroups | Applies `depends_on`, publishes completion Dataset |
| `silver_factory.py` | Builds one Silver DAG with N TaskGroups | Triggered by Bronze Dataset; applies `depends_on` |
| `dataflow_launcher.py` | Builds Bronze Cloud Run task | Uses `LazyProviderOperator` to defer Google provider import until execution |
| `dataform_launcher.py` | Builds Silver Dataform task chain | Uses lazy provider imports for Composer parse performance |
| `lazy_provider_operator.py` | Lightweight provider proxy | Avoids Composer DAG parse timeout from heavy Google provider imports |
| Compatibility stubs | `bronze_factory_dags.py`, `silver_factory_dags.py`, `medallion_factory_dags.py`, `pipeline_factory.py` | Kept as non-registering stubs to avoid Composer stale-file import failures |

---

## Key Decisions

### Decision 1: Exactly 3 active DAGs

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted / Implemented |
| **Date** | 2026-05-20 |

**Choice:** Replace per-pipeline/per-layer DAG generation with three active DAGs:

1. `bronze_medallion`
2. `silver_medallion`
3. `medallion_orchestrator_monitor`

**Rationale:** Composer UI and scheduler perform better with a small number of DAGs. Pipeline granularity is preserved inside each layer DAG through TaskGroups.

**Consequences:**
- YAML `schedule` is ignored and removed from pipeline configs.
- The Bronze DAG owns the actual cron schedule: `0 6 * * *`.
- Silver waits for Bronze completion via Dataset scheduling, not sensors.

---

### Decision 2: Use Airflow Datasets for Bronze → Silver orchestration

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted / Implemented |
| **Dataset URI** | `dataset://medallion/bronze/complete` |

**Choice:** Bronze publishes one completion Dataset from `record_bronze_complete`; Silver subscribes to that Dataset.

**Rationale:** Dataset scheduling is native to Airflow 2.4+ and avoids `ExternalTaskSensor` or `TriggerDagRunOperator` coupling.

---

### Decision 3: Run tables in parallel, limited to 4 heavy tasks

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted / Implemented |
| **Bronze pool** | `pool_bronze`, expected 4 slots |
| **Silver pool** | `pool_silver`, expected 4 slots |

**Choice:** TaskGroups are created for all configured tables. They run in parallel unless `depends_on` creates an explicit edge. Heavy tasks are pool-limited:

- Bronze: `launch_dataflow_via_cloud_run_job`
- Silver: `*_create_workflow_invocation`

**Composer setup required:**

```bash
airflow pools set pool_bronze 4 "Bronze Cloud Run concurrency"
airflow pools set pool_silver 4 "Silver Dataform concurrency"
```

---

### Decision 4: Config `depends_on` controls TaskGroup chaining

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted / Implemented |

**Choice:** `dependencies.depends_on` expresses table-level dependency order inside both Bronze and Silver layer DAGs.

Example:

```yaml
pipeline_id: titularidade
dependencies:
  depends_on:
    - titular
```

Produces:

```text
bronze_titular >> bronze_titularidade
silver_titular >> silver_titularidade
```

Today no pipeline YAML defines dependencies, so all groups are parallel subject to pool limits.

---

### Decision 5: Defer Google provider imports until task execution

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted / Implemented |

**Context:** Composer timed out while parsing DAGs/internal modules after 120s due to heavy imports and package scanning.

**Choice:** Use `LazyProviderOperator` for Cloud Run and Dataform provider operators.

**Rationale:** Airflow parses DAGs frequently from GCS. Provider imports should not happen at parse time when they can be deferred to task execution.

**Related control:** `.airflowignore` prevents internal modules from being parsed as standalone DAG files.

---

### Decision 6: Bronze uses Cloud Run Job, not GKE/Dataflow provider launch

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted / Implemented |
| **Cloud Run Job** | `ingestao` |

**Choice:** Bronze executes the reusable Cloud Run Job `ingestao` synchronously through Airflow's Cloud Run provider operator, with env overrides:

- `ENVIRONMENT`
- `DATASET_NAME`
- `TABLE_NAME`
- `PROCESSING_MODE`

**Rationale:** GKE is not available; the ingestion container already dispatches Dataflow internally.

---

## Config Contract

Each pipeline config now represents one table/pipeline TaskGroup inside the two layer DAGs.

### Required fields

```yaml
pipeline_id: grupo

bronze:
  environment: dev
  dataset_name: arrecadacao
  table_name: grupo
  processing_mode: full

silver:
  included_tags: ["grupo", "silver"]
```

### Optional fields

```yaml
owner: data-engineering
labels: {}
runtime:
  project_id: prj-ecad-dl-dev
  region: us-east1
  gcp_conn_id: google_cloud_default
  retries: 2
  retry_delay_minutes: 5
  execution_timeout_minutes: 180
silver:
  repository_id: gcp-dl-dataform-system
  git_commitish: main
  invocation_timeout_minutes: 120
dependencies:
  bronze_to_silver: true
  depends_on: []
```

### Removed field

| Field | Status | Reason |
|-------|--------|--------|
| `schedule` | Removed from YAML configs | Scheduling is centralized in `BRONZE_SCHEDULE`; Silver is Dataset-triggered |

---

## File Manifest (Current)

| File | Status | Purpose |
|------|--------|---------|
| `dags/.airflowignore` | Active | Prevent parse timeout by ignoring internal modules/configs |
| `dags/bronze_medallion_dag.py` | Active | Single Bronze DAG entrypoint |
| `dags/silver_medallion_dag.py` | Active | Single Silver DAG entrypoint |
| `dags/orchestrator_monitoring_dag.py` | Active | Monitoring/orchestrator inventory DAG |
| `dags/bronze_factory_dags.py` | Compatibility stub | Registers no DAG |
| `dags/silver_factory_dags.py` | Compatibility stub | Registers no DAG |
| `dags/medallion_factory_dags.py` | Compatibility stub | Registers no DAG |
| `dags/medallion_factory/factories/pipeline_factory.py` | Compatibility stub | Avoids stale Composer import failures |
| `dags/medallion_factory/factories/bronze_factory.py` | Active | Build Bronze layer DAG with TaskGroups |
| `dags/medallion_factory/factories/silver_factory.py` | Active | Build Silver layer DAG with TaskGroups |
| `dags/medallion_factory/operators/lazy_provider_operator.py` | Active | Lazy provider execution wrapper |
| `dags/medallion_factory/operators/dataflow_launcher.py` | Active | Cloud Run Job task factory |
| `dags/medallion_factory/operators/dataform_launcher.py` | Active | Dataform task-chain factory |
| `dags/medallion_factory/config_loader.py` | Active | YAML loader |
| `dags/medallion_factory/validation.py` | Active | Config validation |
| `dags/medallion_factory/settings.py` | Active | Constants, schedules, pools, dataset URI |
| `dags/config/medallion/*_pipeline.yaml` | Active | Per-table config inventory |
| `dags/config/medallion/pipeline_template.yaml` | Active | Onboarding template |
| `tests/unit/*` + `tests/integration/*` | Active | Unit/integration validation |

---

## Verification

Current local validation after implementation:

```text
python3 -m pytest tests/ -q
198 passed

airflow dags list-import-errors
No data found
```

Expected active DAGs:

```text
bronze_medallion
silver_medallion
medallion_orchestrator_monitor
```

---

## Risks and Controls

| Risk | Control |
|------|---------|
| Composer parses internal modules and times out | `.airflowignore` ignores `medallion_factory/` and `config/` |
| Google provider imports exceed parse timeout | `LazyProviderOperator` defers provider imports to execution |
| Too many concurrent Cloud Run/Dataform executions | Pools `pool_bronze` and `pool_silver` with 4 slots |
| Future table dependency cycles | `validate_pipeline_configs` detects duplicate, unknown and cyclic dependencies |
| Stale files still present in Composer bucket | Compatibility stubs register no DAG and avoid import errors |

---

## Next Step

Deploy updated `dags/` contents to Composer, including `.airflowignore`, then create/update pools:

```bash
airflow pools set pool_bronze 4 "Bronze Cloud Run concurrency"
airflow pools set pool_silver 4 "Silver Dataform concurrency"
```
