---
name: pipeline
description: DAG/data:pipeline scaffolding — delegates to pipeline-architect agent
---

# Pipeline Command

> Scaffold a data pipeline (Airflow, Dagster) with best-practice patterns

## Usage

```bash
/data:pipeline <description-or-file>
```

## Examples

```bash
/data:pipeline "Daily orders ETL from Postgres to Snowflake"
/data:pipeline "Kafka → staging → dbt → marts with hourly refresh"
/data:pipeline requirements/pipeline-spec.md
```

---

## What This Command Does

1. Invokes the **pipeline-architect** agent
2. Analyzes your description or requirements file
3. Loads KB patterns from `airflow` and `dbt` domains
4. Generates:
   - DAG structure (Airflow or Dagster)
   - Task definitions with dependencies
   - Error handling and retry configuration
   - Sensor/trigger patterns for scheduling

## Agent Delegation

| Agent | Role |
|-------|------|
| `pipeline-architect` | Primary — DAG design, task orchestration |
| `spark-engineer` | Escalation — when pipeline includes Spark jobs |
| `dbt-specialist` | Escalation — when pipeline includes dbt models |

## KB Domains Used

- `airflow` — DAG patterns, operators, sensors
- `dbt` — model execution, incremental strategies
- `data-quality` — quality gates between pipeline stages

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Input check | Descrição contém tipo de pipeline, fonte de dados e frequência/trigger | Pare e solicite detalhes |
| Agent check | `pipeline-architect` agent carregado e KB `airflow` disponível | Pare e reporte |
| DAG check | Pipeline gerado inclui dependências de tarefas, tratamento de erros e idempotência | Alerte sobre lacunas |
| Output check | Código do pipeline e resumo do DAG gerados corretamente | Reporte erro |

## Output

The agent generates pipeline code files and a summary of the DAG structure with task dependencies.
