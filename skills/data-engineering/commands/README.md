# Data Engineering Commands

> **8 slash commands** for data pipeline development, from schema design to production migration

## Command Catalog

| Command | Purpose | Primary Agent |
|---------|---------|---------------|
| `/data:pipeline` | DAG/data:pipeline scaffolding | pipeline-architect |
| `/data:schema` | Interactive schema design | schema-designer |
| `/data:data-quality` | Quality rules generation | data-quality-analyst |
| `/data:lakehouse` | Table format + catalog guidance | lakehouse-architect |
| `/data:sql-review` | SQL-specific code review | code-reviewer + sql-optimizer |
| `/data:ai-pipeline` | RAG/embedding scaffolding | ai-data-engineer |
| `/data:data-contract` | Contract authoring (ODCS) | data-contracts-engineer |
| `/data:migrate` | Legacy ETL migration | dbt-specialist + spark-engineer |

## Quick Start

```bash
# Design a star schema
/data:schema "Star schema for e-commerce analytics"

# Generate quality checks for a dbt model
/data:data-quality models/staging/stg_orders.sql

# Scaffold an Airflow pipeline
/data:pipeline "Daily orders ETL from Postgres to Snowflake"

# Review SQL for anti-patterns
/data:sql-review models/marts/

# Create a data contract
/data:data-contract "Contract between orders team and analytics"

# Migrate stored procedures to dbt
/data:migrate legacy/etl_orders_proc.sql
```

## How Commands Work

Each command delegates to a specialized agent that:

1. Reads KB patterns from relevant domains (zero tokens for cached patterns)
2. Analyzes your input (SQL files, descriptions, requirements)
3. Generates production-ready code with confidence scoring
4. Escalates to other agents when the task crosses specializations
