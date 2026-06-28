> **MCP Validated:** 2026-06-28
> **Domain Owner:** platform-team
> **Review Tier:** critical
> **Freshness Window:** 30 days
> **Primary Sources:** Microsoft Learn Fabric docs, release notes
> **Confidence:** 0.95

# Microsoft Fabric Quick Reference

> Fast lookup tables. For code examples, see linked files.

## Workload Selection

| Use Case | Workload | Why |
|----------|----------|-----|
| Raw ingestion + Spark | Lakehouse | Delta tables, PySpark, notebooks |
| Structured analytics + T-SQL | Warehouse | Full DML, RLS, AI Functions, COPY INTO from OneLake |
| Real-time streaming | Eventhouse | KQL, time-series, sub-second, endpoints for Lakehouse & Warehouse |
| ETL/ELT orchestration | Data Factory | Copy Activity, Dataflows Gen2, pipelines |
| Dashboards + reports | Power BI | DirectLake, semantic models, Copilot |
| ML + AI workflows | Data Science | MLflow, Copilot, AI Skills, SynapseML |
| Operational database | SQL Database | OLTP + mirroring into OneLake (GA Nov 2025) |
| Document analytics | Cosmos DB | Mirroring for analytical queries (GA Nov 2025) |

## Capacity SKUs

| SKU | CUs | Max Memory | Best For |
|-----|-----|------------|----------|
| F2 | 2 | 3 GB | Dev/test |
| F16 | 16 | 25 GB | Small team |
| F64 | 64 | 100 GB | Department |
| F128 | 128 | 200 GB | Enterprise |
| F256+ | 256+ | 400 GB+ | Large-scale |

## Common API Endpoints

| Operation | Method | Endpoint |
|-----------|--------|----------|
| List workspaces | GET | `/v1/workspaces` |
| Create lakehouse | POST | `/v1/workspaces/{id}/lakehouses` |
| Run pipeline | POST | `/v1/workspaces/{id}/items/{id}/jobs/instances?jobType=Pipeline` |
| Deploy stage | POST | `/v1/deploymentPipelines/{id}/deploy` |
| Git connect | POST | `/v1/workspaces/{id}/git/connect` |

## Decision Matrix

| Use Case | Choose |
|----------|--------|
| Petabyte-scale raw data | Lakehouse (Delta + Spark) |
| Complex joins + stored procs | Warehouse (T-SQL) |
| Sub-second event analytics | Eventhouse (KQL) |
| No-code data movement | Copy Activity (Data Factory) |
| Code-first transforms | Spark Notebooks |
| Row-level access control | Warehouse RLS + security policies |
| Automated deployments | Deployment Pipelines + Git integration |

## What's New (2025-2026)

| Feature | Status | Description |
|---------|--------|-------------|
| Copilot on paid Fabric capacities | GA (Apr 2025) | Copilot is enabled by default for paid Fabric capacities (F2+) and can also run with Power BI Premium capacities (P1+); Pro/PPU workspaces need Fabric Copilot capacity |
| `fabric-cicd` Python lib | GA (Feb 2026) | Official CI/CD tool for programmatic deployments |
| AI Functions in Warehouse | Preview | T-SQL functions for sentiment, classification, extraction |
| Eventhouse endpoint for Warehouse | GA | Read-oriented Eventhouse endpoint over Warehouse tables for KQL and Real-Time Intelligence analysis |
| OneLake SharePoint/OneDrive shortcuts | GA (Dec 2025) | Reference M365 files directly in analytics |
| Azure Blob Storage shortcut | GA (May 2025) | New shortcut type for Blob containers |
| SQL Database | GA (Nov 2025) | OLTP database with auto-mirroring to OneLake |
| Cosmos DB mirroring | GA (Nov 2025) | Mirror Cosmos DB data for analytical queries |
| Azure DevOps cross-tenant | GA (Nov 2025) | Git integration across Azure AD tenants |
| COPY INTO from OneLake | Preview (Jul 2025) | Direct ingestion from OneLake files in Warehouse |
| JSONL in OPENROWSET | Preview (Aug 2025) | JSON Lines support for Warehouse and Lakehouse SQL |

## Governance Snapshot

| Field | Value |
|-------|-------|
| Domain owner | `platform-team` |
| Review tier | `critical` |
| Freshness window | `30 days` |
| Last validated | `2026-06-28` |

## Critical Claim Snapshot

| Claim ID | Claim | Status |
|----------|-------|--------|
| FABRIC-CC-001 | Copilot capacity prerequisites | aligned |
| FABRIC-CC-002 | AI Functions in Warehouse preview | aligned |
| FABRIC-CC-003 | `fabric-cicd` GA posture | aligned |
| FABRIC-CC-004 | Eventhouse endpoint for Warehouse posture | aligned |
| FABRIC-CC-005 | `COPY INTO` from OneLake preview | aligned |

## Common Pitfalls

| Don't | Do |
|-------|-----|
| Use V-Order on streaming tables | Use V-Order on batch Delta tables |
| Skip Git integration for prod | Connect workspace to Azure DevOps/GitHub |
| Grant broad workspace roles | Use item-level permissions + RLS |
| Run heavy Spark on F2 | Scale to F16+ for production Spark |
| Ignore capacity throttling | Monitor CU usage via Capacity Metrics app |
| Mix bronze/silver/gold in one lakehouse | Separate lakehouses per medallion layer |
| Require F64 for Copilot | Copilot works on paid Fabric capacities (F2+) and supported Power BI Premium capacities (P1+); Pro/PPU workspaces need Fabric Copilot capacity |
| Build custom CI/CD scripts | Use official `fabric-cicd` Python library |

## Related Documentation

| Topic | Path |
|-------|------|
| Lakehouse Architecture | `02-data-engineering/concepts/lakehouse.md` |
| Warehouse Basics | `04-data-warehouse/concepts/warehouse-basics.md` |
| Medallion Pattern | `03-architecture-patterns/patterns/medallion-fabric.md` |
| Full Index | `index.md` |
