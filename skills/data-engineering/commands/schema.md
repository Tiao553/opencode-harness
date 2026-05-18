---
name: schema
description: Interactive schema design — delegates to schema-designer agent
---

# Schema Command

> Design data models interactively (star schema, Data Vault, SCD, normalization)

## Usage

```bash
/data:schema <description-or-file>
```

## Examples

```bash
/data:schema "Star schema for e-commerce analytics"
/data:schema "SCD Type 2 for customer dimension"
/data:schema "Data Vault for multi-source integration"
/data:schema requirements/data-model-spec.md
```

---

## What This Command Does

1. Invokes the **schema-designer** agent
2. Analyzes your modeling requirements
3. Loads KB patterns from `data-modeling` and `sql-patterns` domains
4. Generates:
   - Entity-relationship diagrams (ASCII)
   - DDL statements for target platform
   - Grain definition and cardinality analysis
   - SCD strategy recommendations

## Agent Delegation

| Agent | Role |
|-------|------|
| `schema-designer` | Primary — dimensional modeling, SCD, Data Vault |
| `dbt-specialist` | Escalation — when models need dbt implementation |
| `sql-optimizer` | Escalation — when index strategy is needed |

## KB Domains Used

- `data-modeling` — dimensional modeling, SCD types, normalization, schema evolution
- `sql-patterns` — DDL patterns, index strategies
- `data-quality` — constraint enforcement

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Input check | Descrição contém entidade/domínio, tipo de modelagem e plataforma alvo | Pare e solicite detalhes |
| Agent check | `schema-designer` agent carregado e KB `data-modeling` disponível | Pare e reporte |
| Schema check | DDL gerado segue padrão de normalização/desnormalização solicitado com constraints | Alerte sobre constraints ausentes |
| Output check | DDL, documentação e recomendações gerados corretamente sem placeholders | Reporte erro |

## Output

The agent generates DDL, model documentation, and implementation recommendations for your target platform.
