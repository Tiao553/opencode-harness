---
name: data-quality
description: Data quality rules generation — delegates to data-quality-analyst agent
---

# Data Quality Command

> Generate quality rules, expectations, and test suites for your data

## Usage

```bash
/data:data-quality <model-or-description>
```

## Examples

```bash
/data:data-quality models/staging/stg_orders.sql
/data:data-quality "Quality checks for customer dimension table"
/data:data-quality models/marts/
```

---

## What This Command Does

1. Invokes the **data-quality-analyst** agent
2. Reads model SQL or description to understand schema and business rules
3. Loads KB patterns from `data-quality` and `dbt` domains
4. Generates:
   - Great Expectations suite with expectations
   - dbt schema YAML with tests
   - Custom data quality SQL assertions
   - Freshness and completeness checks

## Agent Delegation

| Agent | Role |
|-------|------|
| `data-quality-analyst` | Primary — GE suites, quality rules, observability |
| `dbt-specialist` | Escalation — when tests need dbt YAML format |
| `data-contracts-engineer` | Escalation — when SLAs need formal contracts |

## KB Domains Used

- `data-quality` — Great Expectations, Soda, observability patterns
- `dbt` — dbt tests, schema YAML, custom generic tests
- `data-modeling` — constraint patterns, referential integrity

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Input check | Descrição contém dataset/tabela alvo e tipo de validação desejada | Pare e solicite detalhes |
| Agent check | `data-quality-analyst` agent carregado e KB `data-quality` disponível | Pare e reporte |
| Coverage check | Testes gerados cobrem dimensões essenciais (completude, unicidade, validade) | Alerte sobre dimensões não cobertas |
| Output check | Definições de teste geradas no formato correto (GE, dbt ou SQL) com severidade | Reporte erro |

## Output

The agent generates test definitions in your preferred format (GE, dbt, SQL) with severity classification.
