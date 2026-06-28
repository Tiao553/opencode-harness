> **MCP Validated:** 2026-06-28
> **Domain Owner:** platform-team
> **Review Tier:** critical
> **Freshness Window:** 30 days
> **Primary Sources:** Microsoft Learn Fabric docs, release notes
> **Confidence:** 0.95

# Microsoft Fabric Knowledge Base

> **Purpose**: Unified analytics platform -- Lakehouse, Warehouse, Data Factory, Real-Time Intelligence, Copilot, governance, CI/CD
> **Platform**: Microsoft Fabric (SaaS on OneLake)
> **Latest**: June 2026 -- Copilot enabled by default for paid Fabric capacities (F2+) and supported through Power BI Premium (P1+); Pro/PPU workspaces require Fabric Copilot capacity, fabric-cicd tool GA, Eventhouse endpoints for Warehouse, AI Functions in T-SQL

## Quick Navigation

### Sections

| Section | Concepts | Patterns |
|---------|----------|----------|
| [01-logging-monitoring](01-logging-monitoring/) | [kql-queries](01-logging-monitoring/concepts/kql-queries.md) | [workspace-monitoring](01-logging-monitoring/patterns/workspace-monitoring.md) |
| [02-data-engineering](02-data-engineering/) | [lakehouse](02-data-engineering/concepts/lakehouse.md) | [copy-activity](02-data-engineering/patterns/copy-activity.md) |
| [03-architecture-patterns](03-architecture-patterns/) | [workload-selection](03-architecture-patterns/concepts/workload-selection.md) | [medallion-fabric](03-architecture-patterns/patterns/medallion-fabric.md) |
| [04-data-warehouse](04-data-warehouse/) | [warehouse-basics](04-data-warehouse/concepts/warehouse-basics.md) | [t-sql-patterns](04-data-warehouse/patterns/t-sql-patterns.md) |
| [05-apis-sdks](05-apis-sdks/) | [rest-api](05-apis-sdks/concepts/rest-api.md) | [sdk-automation](05-apis-sdks/patterns/sdk-automation.md) |
| [06-governance-security](06-governance-security/) | [rls-security](06-governance-security/concepts/rls-security.md) | [data-masking](06-governance-security/patterns/data-masking.md) |
| [07-cicd-automation](07-cicd-automation/) | [git-integration](07-cicd-automation/concepts/git-integration.md) | [deployment-pipelines](07-cicd-automation/patterns/deployment-pipelines.md) |
| [08-ai-capabilities](08-ai-capabilities/) | [copilot-ml](08-ai-capabilities/concepts/copilot-ml.md) | [ai-skills](08-ai-capabilities/patterns/ai-skills.md) |

## Quick Reference

- [quick-reference.md](quick-reference.md) -- Fast lookup tables and decision matrices

## Governance Metadata

| Field | Value |
|-------|-------|
| Domain owner | `platform-team` |
| Review tier | `critical` |
| Freshness window | `30 days` |
| Last validated | `2026-06-28` |
| Primary sources | Microsoft Learn Fabric docs and release notes |

## Critical Claim Register

| Claim ID | Claim | Current posture | Status |
|----------|-------|-----------------|--------|
| FABRIC-CC-001 | Copilot capacity prerequisites | Paid Fabric capacities `F2+`, supported Power BI Premium `P1+`, Pro/PPU require Fabric Copilot capacity | aligned |
| FABRIC-CC-002 | AI Functions in Warehouse | preview | aligned |
| FABRIC-CC-003 | `fabric-cicd` official deployment library | GA | aligned |
| FABRIC-CC-004 | Eventhouse endpoint for Warehouse data | Read-oriented Eventhouse endpoint over Warehouse tables; Warehouse remains the T-SQL/DML owner | aligned |
| FABRIC-CC-005 | `COPY INTO` from OneLake in Warehouse | preview support exists | aligned |

## Key Concepts

| Concept | Description |
|---------|-------------|
| **OneLake** | Centralized logical data lake with shortcuts to S3, ADLS, GCS, SharePoint, OneDrive, Azure Blob |
| **Lakehouse** | Delta-based storage with SQL analytics endpoint and Eventhouse endpoint (2025) |
| **Warehouse** | Full T-SQL engine with AI Functions (preview), RLS, masking, COPY INTO from OneLake |
| **Data Factory** | Low-code ETL/ELT with Copy Activity, Dataflows Gen2, and pipelines |
| **Real-Time Intelligence** | Eventhouse (KQL), Eventstream, Data Activator for streaming analytics |
| **Copilot** | Azure OpenAI-powered assistant across all workloads, available for paid Fabric capacities (F2+) and Power BI Premium capacities (P1+); Pro/PPU workspaces need Fabric Copilot capacity and workspace assignment |
| **CI/CD** | Git integration (GitHub/Azure DevOps) + Deployment Pipelines + `fabric-cicd` Python library |
| **Capacity** | Compute model using CU (Capacity Units), F2 to F256+ SKUs |
| **Databases** | SQL database and Cosmos DB mirroring (GA Nov 2025) |

## Learning Path

| Level | Files |
|-------|-------|
| **Beginner** | `02-data-engineering/concepts/lakehouse.md`, `04-data-warehouse/concepts/warehouse-basics.md` |
| **Intermediate** | `03-architecture-patterns/patterns/medallion-fabric.md`, `02-data-engineering/patterns/copy-activity.md` |
| **Advanced** | `05-apis-sdks/patterns/sdk-automation.md`, `07-cicd-automation/patterns/deployment-pipelines.md` |

## Agent Usage

| Agent | Primary Files | Use Case |
|-------|---------------|----------|
| fabric-architect | `03-architecture-patterns/`, `index.md` | Workload selection and medallion design |
| fabric-ai-specialist | `08-ai-capabilities/` | Copilot, ML models, AI Skills |
| fabric-cicd-specialist | `07-cicd-automation/` | Git sync, deployment pipelines |
| fabric-logging-specialist | `01-logging-monitoring/` | KQL queries, workspace monitoring |
| fabric-pipeline-developer | `02-data-engineering/`, `04-data-warehouse/` | Lakehouse, Copy Activity, T-SQL |
| fabric-security-specialist | `06-governance-security/` | RLS, data masking, access control |
