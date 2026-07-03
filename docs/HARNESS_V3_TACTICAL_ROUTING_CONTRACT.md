# Harness V3 Tactical Routing Contract

## Purpose

Define how the visible `data-engineer` coordinator routes bounded tactical data-engineering work without requiring explicit `/data:*` commands.

## Routing Principle

The user describes the work naturally. The coordinator selects the route.

```text
User request
  -> data-engineer
  -> classify domain and artifact
  -> choose internal route
  -> optionally allocate specialist
  -> verify with data-specific evidence
  -> escalate to Altitude only when work becomes durable/strategic
```

## Route Map

| Internal route | User signals | Legacy command equivalent | Preferred specialist |
| --- | --- | --- | --- |
| `ai-pipeline` | RAG, embeddings, vector DB, feature store, LLMOps data plumbing | `/data:ai-pipeline` | `data-engineering.ai-data-engineer` |
| `data-contract` | ODCS, SLA, producer/consumer contract, schema contract | `/data:data-contract` | data-contract specialist when available |
| `data-quality` | freshness, anomaly, nulls, duplicate checks, Great Expectations, dbt tests | `/data:data-quality` | data-quality specialist when available |
| `lakehouse` / `fabric` | Fabric, Lakehouse, Warehouse, Eventhouse, OneLake, medallion | `/data:lakehouse` | lakehouse/Fabric specialist when available |
| `migrate` | migration plan, dbt conversion, Spark/dbt transition, warehouse move | `/data:migrate` | `data-engineering.dbt-specialist` with escalation when needed |
| `pipeline` | DAG, Airflow, Dataform, orchestration, dependencies, retries | `/data:pipeline` | `data-engineering.airflow-specialist` or pipeline specialist |
| `schema` | DDL, dimensional model, star schema, keys, grain | `/data:schema` | schema/data-modeling specialist when available |
| `sql-review` | query review, performance, dialect, explain plan, correctness | `/data:sql-review` | `data-engineering.sql-optimizer` |
| `spark` / `streaming` | PySpark, Structured Streaming, partitions, shuffle, state | no single legacy command | Spark/streaming specialist when available |
| `observability` | lineage, pipeline metrics, alerts, SLOs, run health | no single legacy command | observability/data platform specialist when available |

## Tactical vs Strategic Gate

Use `data-engineer` when:

- the work is bounded
- the artifact is data-engineering-specific
- validation can be performed with a targeted check
- no full durable phase progression is required

Escalate to `altitude` when:

- the work needs PRD, ADR, TEST-SPEC, or multi-wave planning
- the change spans multiple systems or teams
- task boundaries are not yet clear
- production data risk requires a durable evidence trail beyond a tactical note

## Context Loading

Default order:

1. directly referenced files
2. schema/model/DAG/query files
3. project tests or quality checks
4. relevant `quick-reference.md`
5. specific KB concept/pattern only when needed
6. specialist agent only when allocation is explicit

Do not load full KB domains by default.

## Verification Matrix

| Route | Evidence |
| --- | --- |
| `sql-review` | explain plan, corrected query, row-count check, targeted SQL test |
| `dbt` / `migrate` | `dbt compile`, `dbt test`, model diff, migration validation |
| `schema` | DDL diff, grain/key review, contract compatibility |
| `data-quality` | failing/passing quality check, sample rows, anomaly slice |
| `data-contract` | contract schema, SLA fields, compatibility check |
| `pipeline` | DAG parse, unit test, dry run, dependency graph review |
| `lakehouse` / `fabric` | source-backed Microsoft/Fabric docs when current behavior may drift |
| `spark` / `streaming` | local test, partition/shuffle/state analysis, sample job check |
| `ai-pipeline` | retrieval/embedding validation, cost/latency note, no secrets in code |

## Compatibility Rule

Existing `/data:*` commands are compatibility labels. Do not delete them until a preservation fixture proves the same behavior through the `data-engineer` coordinator.
