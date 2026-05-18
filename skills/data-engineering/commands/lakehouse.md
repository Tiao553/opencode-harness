---
name: lakehouse
description: Table format and catalog guidance — delegates to lakehouse-architect agent
---

# Lakehouse Command

> Get guidance on Iceberg, Delta Lake, catalogs, and open table formats

## Usage

```bash
/data:lakehouse <description-or-question>
```

## Examples

```bash
/data:lakehouse "Set up Iceberg tables with partition evolution"
/data:lakehouse "Migrate from Hive to Iceberg on AWS"
/data:lakehouse "Compare Delta Lake vs Iceberg for our use case"
/data:lakehouse "Configure Unity Catalog for multi-cloud"
```

---

## What This Command Does

1. Invokes the **lakehouse-architect** agent
2. Analyzes your table format or catalog requirements
3. Loads KB patterns from `lakehouse` and `cloud-platforms` domains
4. Generates:
   - Table DDL with partition strategies
   - Catalog configuration (Unity, Polaris, Nessie)
   - Migration scripts from legacy formats
   - Compaction and maintenance procedures

## Agent Delegation

| Agent | Role |
|-------|------|
| `lakehouse-architect` | Primary — Iceberg, Delta, catalog governance |
| `data-platform-engineer` | Escalation — when infra provisioning is needed |
| `spark-engineer` | Escalation — when Spark read/write optimization is needed |

## KB Domains Used

- `lakehouse` — Iceberg v3, Delta Lake, catalog wars, DuckLake
- `cloud-platforms` — platform-specific Iceberg/Delta patterns
- `spark` — Spark table format integration

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Input check | Descrição contém formato de tabela (Iceberg/Delta) e plataforma alvo | Pare e solicite detalhes |
| Agent check | `lakehouse-architect` agent carregado e KB `lakehouse` disponível | Pare e reporte |
| Architecture check | Definições incluem particionamento, catálogo e estratégia de compactação | Alerte sobre configurações ausentes |
| Output check | Artefatos gerados (DDL, configs, runbooks) estão completos e sem placeholders | Reporte erro |

## Output

The agent generates table definitions, catalog configs, and operational runbooks for your lakehouse setup.
