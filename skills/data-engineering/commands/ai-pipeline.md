---
name: ai-pipeline
description: RAG/embedding pipeline scaffolding — delegates to ai-data-engineer agent
---

# AI Pipeline Command

> Scaffold RAG pipelines, embedding workflows, feature stores, and text-to-SQL

## Usage

```bash
/data:ai-pipeline <description-or-file>
```

## Examples

```bash
/data:ai-pipeline "RAG pipeline for internal docs with pgvector"
/data:ai-pipeline "Embedding pipeline from S3 PDFs to Pinecone"
/data:ai-pipeline "Feature store setup with Feast for ML models"
/data:ai-pipeline "Text-to-SQL agent for analytics queries"
```

---

## What This Command Does

1. Invokes the **ai-data-engineer** agent
2. Analyzes your AI/ML data requirements
3. Loads KB patterns from `ai-data-engineering` and `streaming` domains
4. Generates:
   - RAG pipeline architecture and code
   - Embedding pipeline with chunking strategies
   - Vector database setup and indexing
   - Feature store definitions
   - Text-to-SQL prompt templates

## Agent Delegation

| Agent | Role |
|-------|------|
| `ai-data-engineer` | Primary — RAG, embeddings, vector DBs, features |
| `streaming-engineer` | Escalation — real-time embedding pipelines |
| `data-quality-analyst` | Escalation — embedding quality metrics |

## KB Domains Used

- `ai-data-engineering` — RAG pipelines, vector databases, feature stores, LLMOps
- `streaming` — real-time embedding ingestion
- `data-quality` — embedding quality, drift detection

## Quality Gates

| Gate | Critério | Ação se falhar |
|---|---|---|
| Input check | Descrição do pipeline AI contém tipo (RAG, embeddings, feature store) e fonte de dados | Pare e solicite detalhes |
| Agent check | `ai-data-engineer` agent carregado e KB `ai-data-engineering` disponível | Pare e reporte |
| Architecture check | Pipeline gerado inclui componentes obrigatórios (ingestão, processamento, serving) | Reporte lacunas |
| Output check | Artefatos gerados (código, config, documentação) estão completos e sem placeholders | Reporte erro |

## Output

The agent generates pipeline code, configuration, and architecture documentation for your AI data workflow.
