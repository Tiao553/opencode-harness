---
name: data-contract
description: Data contract authoring (ODCS) — delegates to data-contracts-engineer agent
---

# Data Contract Command

> Author producer-consumer data contracts following the Open Data Contract Standard

## Usage

```bash
/data:data-contract <description-or-file>
```

## Examples

```bash
/data:data-contract "Contract between orders team and analytics"
/data:data-contract "SLA definition for customer dimension table"
/data:data-contract models/marts/mart_revenue.sql
/data:data-contract "Schema governance rules for the payments domain"
```

---

## What This Command Does

1. Invokes the **data-contracts-engineer** agent
2. Analyzes your contract requirements or existing model
3. Loads KB patterns from `data-quality` and `data-modeling` domains
4. Generates:
   - ODCS-compliant contract YAML
   - Schema definitions with column-level contracts
   - SLA specifications (freshness, completeness, accuracy)
   - Producer-consumer agreement documentation
   - Breaking change detection rules

## Agent Delegation

| Agent | Role |
|-------|------|
| `data-contracts-engineer` | Primary — ODCS, SLAs, schema governance |
| `data-quality-analyst` | Escalation — quality rule enforcement |
| `schema-designer` | Escalation — schema evolution planning |

## KB Domains Used

- `data-quality` — SLA patterns, quality metrics, observability
- `data-modeling` — schema evolution, compatibility rules

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Input check | Descrição contém dataset, owner e consumidores do contrato | Pare e solicite detalhes |
| Agent check | `data-contracts-engineer` agent carregado e KB `data-quality` disponível | Pare e reporte |
| Schema check | Contrato ODCS gerado é YAML válido com campos obrigatórios (schema, SLA, owner) | Reporte erro de validação |
| Output check | Artefatos gerados (YAML, SLA, docs) estão completos e sem placeholders | Reporte erro |

## Output

The agent generates ODCS contract YAML, SLA definitions, and governance documentation.
