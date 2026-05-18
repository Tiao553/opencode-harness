---
name: migrate
description: Legacy ETL migration — delegates to dbt-specialist and spark-engineer agents
---

# Migrate Command

> Migrate legacy ETL (stored procedures, SSIS, Informatica) to modern stack

## Usage

```bash
/data:migrate <description-or-file>
```

## Examples

```bash
/data:migrate "Convert stored procedures to dbt models"
/data:migrate legacy/etl_orders_proc.sql
/data:migrate "Migrate Informatica workflows to Airflow + dbt"
/data:migrate "Move SSIS packages to Spark + Iceberg"
```

---

## What This Command Does

1. Analyzes legacy ETL code or description
2. Invokes the appropriate agent based on target stack
3. Loads KB patterns from `dbt`, `spark`, and `airflow` domains
4. Generates:
   - Equivalent modern code (dbt models, PySpark jobs, Airflow DAGs)
   - Migration mapping (source → target)
   - Data validation queries to compare old vs new output
   - Rollback strategy documentation

## Agent Delegation

| Agent | Role |
|-------|------|
| `dbt-specialist` | Primary — stored proc → dbt model conversion |
| `spark-engineer` | Primary — heavy ETL → PySpark conversion |
| `pipeline-architect` | Escalation — orchestration migration |
| `sql-optimizer` | Escalation — query optimization during migration |

## KB Domains Used

- `dbt` — model patterns, incremental strategies, macros
- `spark` — PySpark patterns, DataFrame transformations
- `airflow` — DAG patterns, operator selection
- `sql-patterns` — cross-dialect SQL translation

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Input check | Descrição contém tecnologia de origem, destino e escopo da migração | Pare e solicite detalhes |
| Agent check | Agent primário (dbt-specialist ou spark-engineer) carregado com KB correspondente | Pare e reporte |
| Parity check | Queries de validação geradas para comparar dados antes/depois da migração | Alerte sobre ausência de validação |
| Output check | Código migrado, checklist e queries de validação gerados corretamente | Reporte erro |

## Output

The agent generates modern code equivalents, a migration checklist, and validation queries to ensure data parity.
