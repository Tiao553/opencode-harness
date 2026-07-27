# DESIGN: Observability Hub

> Technical design for implementing a Fabric-native observability hub that preserves dense source semantics while keeping the build narrow: notebooks, pipelines, Delta tables, audit outputs, and only minimal optional shared assets.

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | OBSERVABILITY_HUB |
| **Date** | 2026-06-10 |
| **Author** | iterate-agent |
| **DEFINE** | [DEFINE_OBSERVABILITY_HUB.md](./DEFINE_OBSERVABILITY_HUB.md) |
| **Status** | Ready for Build |

---

## Canonical Sources

| Source | Design role |
|--------|-------------|
| `docs/discovery/contrato_canonico.md` | Defines required Gold facts, mandatory fields, lifecycle fields, and source-specific derivation rules |
| `docs/discovery/arquitetura_de_dados.md` | Defines the Fabric medallion flow, source collection surfaces, and preferred mechanisms |
| `docs/architecture/onelake_organization.md` | Governs layer separation, naming, and table-placement discipline |
| `docs/architecture/gold_serving_decision.md` | Confirms Gold Lakehouse on Delta as the authoritative Gold store |
| `docs/architecture/fabric_setup.md` | Supplies setup and connection guidance without becoming a rollout blueprint |
| `docs/architecture/fabric_environment_topology.md` | Defines the fixed workspace topology that bootstrap prepares one workspace at a time |
| `Deploy_FUAM.ipynb` | Reference for notebook-scoped bootstrap with `%pip install ms-fabric-cli`, connection validation/creation, workspace discovery, and item organization |
| `docs/security/secrets_rotation_policy.md` | Constrains credential handling in notebooks and pipelines |
| `docs/security/rbac_matrix.md` | Constrains author, operator, and consumer boundaries |
| `docs/operations/slo_sla_operacional.md` | Supplies reference windows, latency targets, and completeness intent |
| `docs/operations/alerting_matrix.md` | Supplies reference alert semantics and minimum evidence expectations |
| `docs/runbooks/*.md` | Define recovery expectations and correction evidence requirements |
| User iteration request via `/workflow:iterate` on 2026-06-10 | Enforces simplicity-first scope boundaries for this phase |

---

## Architecture Overview

```text
Sources
  ├─ ODI control tables
  ├─ ETLTOOLS Oracle control/error tables
  ├─ Elastic logs for NOT_STARTED
  └─ Power BI refresh/status APIs

Fabric orchestration
  ├─ bootstrap setup notebook
  ├─ setup notebooks
  ├─ Bronze notebooks
  ├─ Silver notebooks
  ├─ Gold notebooks
  └─ 4 core Fabric Data Factory pipelines

Lakehouse layers
  ├─ Bronze: raw source evidence + ingestion audit
  ├─ Silver: normalized source-specific tables
  └─ Gold: canonical facts + operational status outputs

Operator flow
  ├─ open Fabric pipeline/notebook run history
  ├─ inspect stg_ingestion_audit
  ├─ inspect Gold facts/status outputs
  └─ follow correction_url / runbook path
```

This remains a single-path architecture: source evidence moves once through Bronze, once through Silver, and once into Gold. No alternate serving path, second authority store, local execution tier, or build-time orchestration framework is introduced in this phase.

**Sources:** `docs/discovery/arquitetura_de_dados.md` §2–§3; `docs/architecture/gold_serving_decision.md`; `docs/architecture/onelake_organization.md`.

---

## Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| Bootstrap notebook | Prepare workspace-scoped setup actions when provisioning is required | Fabric Notebook + `notebookutils` + session-scoped `ms-fabric-cli` |
| Bronze collectors | Extract raw source evidence and append audit metadata | Fabric Notebooks + source-specific Python / connectors |
| Silver normalizers | Convert raw source evidence into source-safe normalized tables | Fabric Notebooks + Spark SQL |
| Gold materializers | Build canonical facts and minimal operational outputs | Fabric Notebooks + Spark SQL |
| Fabric Data Factory pipelines | Orchestrate collection and Gold materialization windows | Fabric Data Factory |
| `stg_ingestion_audit` | Minimal operational ledger for auditable runs | Delta table in Bronze |
| Gold Lakehouse tables | Contract-safe operational consumption layer | Delta tables in Gold Lakehouse |

**Sources:** `docs/discovery/arquitetura_de_dados.md` §2–§5; `docs/architecture/fabric_setup.md`; `docs/architecture/onelake_organization.md`.

---

## Key Decisions

### Decision 1: Fabric-only, medallion-first implementation

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-10 |

**Context:** Previous iterations carried local-first or broader rollout assumptions that no longer match the current scope.

**Choice:** Keep the solution entirely on Microsoft Fabric with separate Bronze, Silver, and Gold layers.

**Rationale:** This preserves the canonical architecture and avoids rework between local and Fabric execution models.

**Alternatives Rejected:**
1. Local-first staging stack — rejected because it creates drift from Fabric runtime and Gold contract delivery.
2. Multi-platform orchestration — rejected because it broadens the runtime without serving this phase.

**Consequences:**
- The design remains operationally simple and source-grounded.
- All required build assets must map cleanly to the Fabric workspace model.

**Sources:** `docs/discovery/arquitetura_de_dados.md` §1–§3; `docs/architecture/onelake_organization.md`.

---

### Decision 2: Gold contract is authoritative and non-negotiable

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-10 |

**Context:** Source semantics vary widely across ODI, ETLTOOLS, Elastic, and Power BI.

**Choice:** `docs/discovery/contrato_canonico.md` remains the authoritative source for `fct_execution_event` and `fct_error_event`.

**Rationale:** A single contract prevents downstream ambiguity in triage, reporting, and validation.

**Alternatives Rejected:**
1. Per-source fact schemas — rejected because consumers would need custom logic per source.
2. Design-owned schema copies — rejected because they drift from the canonical contract.

**Consequences:**
- Build must materialize Gold directly against the canonical contract.
- Future schema change requires another `/workflow:iterate` pass.

**Sources:** `docs/discovery/contrato_canonico.md` §2–§6.

---

### Decision 3: Bronze notebooks stay intentionally thin

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-10 |

**Context:** The phase goal is dense documentation but narrow implementation surface.

**Choice:** Bronze notebooks only read parameters, extract rows, stamp metadata, persist raw rows, append audit rows, and exit.

**Rationale:** This keeps source collection readable in Fabric UI and avoids framework sprawl.

**Alternatives Rejected:**
1. Shared notebook framework — rejected because it hides source-specific control flow.
2. Business logic in Bronze — rejected because normalization belongs in Silver.

**Consequences:**
- Most transformation logic moves to Spark SQL in Silver and Gold.
- Collector notebooks remain easy to inspect and test.

**Sources:** user iteration request via `/workflow:iterate`, 2026-06-10; `docs/discovery/arquitetura_de_dados.md` §3–§5.

---

### Decision 4: Bootstrap may use notebook-contained Fabric CLI only for setup

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-10 |

**Context:** Workspace-aware provisioning needs connection and item operations, but the runtime must remain notebook/pipeline-first.

**Choice:** Add a bootstrap notebook that may install `ms-fabric-cli`, export transient session tokens, validate/create connections, resolve the current workspace, and organize environment-bound items.

**Rationale:** This captures the setup pattern from `Deploy_FUAM.ipynb` without expanding into a separate CLI operating model.

**Alternatives Rejected:**
1. Standalone shell/CLI setup workflow — rejected because it becomes a parallel operating model.
2. Manual-only workspace setup — rejected because it weakens repeatability for environment bootstrap.

**Consequences:**
- Bootstrap remains per-environment and notebook-scoped.
- Secrets must remain session-scoped and never persisted.

**Sources:** `Deploy_FUAM.ipynb`; `docs/architecture/fabric_setup.md`; `docs/security/secrets_rotation_policy.md`.

---

### Decision 5: Shared objects are optional and justified only by repetition

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-10 |

**Context:** The feature should avoid over-abstraction while still allowing limited reuse.

**Choice:** Fabric functions and variables may be created only when repeated logic or shared values clearly make the build simpler than inline implementation.

**Rationale:** This preserves simplicity while leaving room for justified extraction.

**Alternatives Rejected:**
1. Mandatory shared utility layer — rejected because it adds assets before reuse is proven.
2. No reuse ever — rejected because repeated correction-link or completeness logic may become noisier inline.

**Consequences:**
- Shared assets are marked optional in the file manifest.
- Build should default to inline logic until repetition is demonstrated.

**Sources:** user iteration request via `/workflow:iterate`, 2026-06-10; `docs/operations/slo_sla_operacional.md` §4–§8.

---

## File Manifest

| # | File | Action | Purpose | Agent | Dependencies |
|---|------|--------|---------|-------|--------------|
| 1 | `notebooks/setup/bootstrap_environment.ipynb` | Create | Install `ms-fabric-cli` when needed, resolve current workspace, validate/create connections, import/update workspace-bound items, and hand off to setup initialization | `@platform.fabric-security-specialist` | None |
| 2 | `notebooks/bronze/collect_odi.ipynb` | Keep/Simplify | ODI raw extraction only | `(general)` | 14 |
| 3 | `notebooks/bronze/collect_etltools.ipynb` | Keep/Simplify | ETLTOOLS Oracle raw extraction only | `(general)` | 14 |
| 4 | `notebooks/bronze/collect_elastic.ipynb` | Keep/Simplify | Elastic `NOT_STARTED` raw extraction only | `(general)` | 14 |
| 5 | `notebooks/bronze/collect_powerbi.ipynb` | Keep/Simplify | Power BI raw extraction only | `(general)` | 14 |
| 6 | `notebooks/silver/normalize_odi.ipynb` | Keep/Simplify | ODI normalization and dedup | `@data-engineering.sql-optimizer` | 2, 15 |
| 7 | `notebooks/silver/normalize_etltools.ipynb` | Keep/Simplify | ETLTOOLS SQL-path + Elastic-path normalization | `@data-engineering.sql-optimizer` | 3, 4, 15 |
| 8 | `notebooks/silver/normalize_powerbi.ipynb` | Keep/Simplify | Power BI normalization | `@data-engineering.sql-optimizer` | 5, 15 |
| 9 | `notebooks/gold/materialize_execution_event.ipynb` | Keep/Simplify | Build `fct_execution_event` | `@data-engineering.sql-optimizer` | 6, 7, 8, 16 |
| 10 | `notebooks/gold/materialize_error_event.ipynb` | Keep/Simplify | Build `fct_error_event` | `@data-engineering.sql-optimizer` | 6, 7, 8, 16 |
| 11 | `notebooks/gold/materialize_snapshot.ipynb` | Keep | Build `fct_execution_snapshot` | `@data-engineering.sql-optimizer` | 9, 10 |
| 12 | `notebooks/gold/materialize_completeness.ipynb` | Keep | Build `fct_completeness_report` | `@data-engineering.sql-optimizer` | 6, 7, 8, 16 |
| 13 | `notebooks/gold/update_open_flags.ipynb` | Keep | Maintain `open_flag` / `resolved_at` lifecycle | `@data-engineering.sql-optimizer` | 10 |
| 14 | `notebooks/setup/create_schema_bronze.ipynb` | Keep/Simplify | Create Bronze tables with Spark SQL | `@platform.fabric-architect` | 1 |
| 15 | `notebooks/setup/create_schema_silver.ipynb` | Keep/Simplify | Create Silver tables with Spark SQL | `@platform.fabric-architect` | 14 |
| 16 | `notebooks/setup/create_schema_gold.ipynb` | Keep/Simplify | Create Gold facts and only the minimal reference tables needed by current fact joins | `@platform.fabric-architect` | 15 |
| 17 | `notebooks/setup/seed_dimensions.ipynb` | Optional/Simplify | Seed only the minimal reference data required if it does not already exist | `@platform.fabric-security-specialist` | 16 |
| 18 | `pipelines/pipeline_collect_odi.json` | Keep/Simplify | Orchestrate ODI Bronze → Silver | `@platform.fabric-pipeline-developer` | 2, 6 |
| 19 | `pipelines/pipeline_collect_etltools.json` | Keep/Simplify | Orchestrate ETLTOOLS + Elastic Bronze → Silver | `@platform.fabric-pipeline-developer` | 3, 4, 7 |
| 20 | `pipelines/pipeline_collect_powerbi.json` | Keep/Simplify | Orchestrate Power BI Bronze → Silver | `@platform.fabric-pipeline-developer` | 5, 8 |
| 21 | `pipelines/pipeline_materialize_gold.json` | Keep/Simplify | Orchestrate Gold notebooks | `@platform.fabric-pipeline-developer` | 9, 10, 11, 12, 13 |
| 22 | `fabric/functions/build_correction_url` | Optional/Create-if-needed | Optional shared correction-url builder | `@platform.fabric-security-specialist` | 9, 10 |
| 23 | `fabric/functions/build_dedup_key` | Optional/Create-if-needed | Optional shared dedup-key builder | `@platform.fabric-security-specialist` | 6, 7, 8 |
| 24 | `fabric/variables/collection_windows` | Optional/Create-if-needed | Optional window references | `@platform.fabric-security-specialist` | 18, 19, 20, 21 |
| 25 | `fabric/variables/expected_counts` | Optional/Create-if-needed | Optional completeness expectations | `@platform.fabric-security-specialist` | 12 |

**Total Files:** 25

**Sources:** `docs/discovery/arquitetura_de_dados.md`; `docs/architecture/gold_serving_decision.md`; `docs/architecture/fabric_setup.md`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Agent Assignment Rationale

> Agents discovered from `~/.config/opencode/agents/` - Build phase invokes matched specialists.

| Agent | Files Assigned | Why This Agent |
|-------|----------------|----------------|
| `@platform.fabric-pipeline-developer` | 18, 19, 20, 21 | Fabric Data Factory pipeline authoring and runtime wiring |
| `@data-engineering.sql-optimizer` | 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 | SQL-heavy normalization, DDL, and Gold materialization |
| `@platform.fabric-security-specialist` | 1, 17, 22, 23, 24, 25 | Connection handling, secret discipline, and least-privilege setup |
| `@platform.fabric-architect` | 1, 14, 15, 16, 17 | Workspace/lakehouse structure and setup alignment |
| `@test.data-quality-analyst` | 6, 7, 8, 9, 10, 11, 12 | Data quality checks for normalization, facts, and completeness |
| `(general)` | 2, 3, 4, 5 | Straightforward source-specific collectors that do not need more specialization |

**Agent Discovery:**
- Scanned: `~/.config/opencode/agents/*.agent.md`
- Matched by: Fabric pipelines, Spark/SQL-heavy notebooks, security-sensitive setup, and validation-oriented data checks

**Sources:** `~/.config/opencode/config/routing.json`; `WORKFLOW_CONTRACTS.yaml` design/build delegation sections.

---

## Code Patterns

### Pattern 1: Bootstrap notebook skeleton

```python
%pip install ms-fabric-cli

import os
import sempy.fabric as fabric

token = notebookutils.credentials.getToken("pbi")
os.environ["FAB_TOKEN"] = token
os.environ["FAB_TOKEN_ONELAKE"] = token

workspace_id = fabric.get_notebook_workspace_id()

# validate or create approved connections
# import or update workspace-bound items
# trigger schema initialization notebooks
```

**Use when:** setup requires workspace-aware provisioning or refresh.

### Pattern 2: Bronze collector skeleton

```python
from datetime import datetime, timezone

run_id = notebookutils.runtime.context.get("currentRunId")
collected_at = datetime.now(timezone.utc)

# 1. read params
# 2. extract rows from source
# 3. create dataframe
# 4. add run_id / collected_at / ingestion_date
# 5. append to stg_* target
# 6. append one audit row
```

**Use when:** collecting one source surface into Bronze with minimal logic.

### Pattern 3: SQL-heavy DDL / materialization structure

```python
spark.sql("""
CREATE TABLE IF NOT EXISTS fct_execution_event (
    execution_event_id STRING NOT NULL,
    system_name STRING NOT NULL,
    source_table STRING NOT NULL,
    process_id STRING NOT NULL,
    run_id STRING NOT NULL,
    execution_status STRING NOT NULL,
    start_time TIMESTAMP NOT NULL,
    detected_at TIMESTAMP NOT NULL,
    time_to_detect_ms BIGINT NOT NULL,
    correction_url STRING NOT NULL,
    collected_at TIMESTAMP NOT NULL
)
USING DELTA
""")
```

```yaml
pipelines:
  collect_odi:
    notebooks:
      - notebooks/bronze/collect_odi.ipynb
      - notebooks/silver/normalize_odi.ipynb
  materialize_gold:
    notebooks:
      - notebooks/gold/materialize_execution_event.ipynb
      - notebooks/gold/materialize_error_event.ipynb
      - notebooks/gold/update_open_flags.ipynb
      - notebooks/gold/materialize_snapshot.ipynb
      - notebooks/gold/materialize_completeness.ipynb
```

**Use when:** defining schema creation and orchestration in a simple, explicit way.

**Sources:** `Deploy_FUAM.ipynb`; `docs/discovery/contrato_canonico.md`; `docs/discovery/arquitetura_de_dados.md`; `docs/architecture/fabric_setup.md`.

---

## Data Flow

```text
1. Source-specific notebooks extract raw ODI, ETLTOOLS, Elastic, and Power BI evidence
   │
   ▼
2. Bronze tables store raw rows plus Fabric runtime metadata and `stg_ingestion_audit`
   │
   ▼
3. Silver notebooks normalize statuses, timestamps, lineage, and dedup keys per source family
   │
   ▼
4. Gold notebooks materialize `fct_execution_event`, `fct_error_event`, snapshot, completeness, and lifecycle updates
   │
   ▼
5. Operators inspect Fabric UI history, audit tables, Gold facts, and `correction_url` outputs
```

**Sources:** `docs/discovery/arquitetura_de_dados.md` §2–§5; `docs/discovery/contrato_canonico.md` §2–§6; `docs/runbooks/*.md`.

---

## Integration Points

| External System | Integration Type | Authentication |
|-----------------|------------------|----------------|
| ODI Oracle | Relational query access | Approved Fabric connection / secret-backed access |
| ETLTOOLS Oracle | Relational query access | Approved Fabric connection / secret-backed access |
| Elastic logs | Search/query access | Approved Fabric connection / secret-backed access |
| Power BI APIs | REST API | Notebook-acquired token / approved workspace connection as applicable |

**Sources:** `docs/architecture/fabric_setup.md`; `docs/security/secrets_rotation_policy.md`; `Deploy_FUAM.ipynb`.

---

## Testing Strategy

| Test Type | Scope | Files | Tools | Coverage Goal |
|-----------|-------|-------|-------|---------------|
| Unit | Source-specific parsing, status mapping, and correction-url logic | Bronze/Silver/Gold notebook logic blocks or extracted helpers | Notebook tests / Spark SQL validation snippets | Key source rules |
| Integration | End-to-end source family flow Bronze → Silver → Gold | 2–13, 18–21 | Fabric notebook runs + pipeline runs + validation queries | All 4 source paths |
| E2E | Operational triage flow from pipeline failure to Gold record to correction target | 18–21 + Gold tables + runbook path | Fabric UI + query checks | Happy path + main failure paths |

**Testing focus:** preserve ETLTOOLS dual-path semantics, Gold contract fields, audit visibility, and bootstrap secret discipline.

**Sources:** `docs/discovery/contrato_canonico.md`; `docs/discovery/arquitetura_de_dados.md`; `docs/runbooks/*.md`; `docs/operations/slo_sla_operacional.md`.

---

## Error Handling

| Error Type | Handling Strategy | Retry? |
|------------|-------------------|--------|
| Source connectivity failure | Fail the notebook/pipeline step, preserve audit row with error detail, inspect via Fabric UI | Yes |
| Source payload or parsing drift | Preserve raw evidence where possible, fail normalization with explicit lineage to source row family | Limited |
| Contract materialization conflict | Stop Gold write/update, keep Silver evidence intact, investigate against canonical contract | No |
| Bootstrap connection/setup failure | Stop bootstrap before setup notebooks proceed; avoid partial silent provisioning | Yes |

**Sources:** `docs/architecture/fabric_setup.md`; `docs/discovery/contrato_canonico.md`; `docs/runbooks/*.md`.

---

## Configuration

| Config Key | Type | Default | Description |
|------------|------|---------|-------------|
| `collection_windows` | structured variable / config | none | Window definitions per source family, created only if shared values are justified |
| `expected_counts` | structured variable / config | none | Lightweight completeness expectations for `fct_completeness_report` |
| `workspace_connection_names` | structured config | environment-specific | Stable logical connection names used by collectors and bootstrap |
| `bootstrap_enabled` | bool | `true` when provisioning is needed | Controls whether the environment bootstrap notebook must run |

**Sources:** `docs/architecture/fabric_setup.md`; `docs/operations/slo_sla_operacional.md`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Security Considerations

- No secrets may be embedded in notebooks, JSON artifacts, or Markdown files.
- Bootstrap may export `FAB_TOKEN` and `FAB_TOKEN_ONELAKE` only as session-scoped values and must never persist them.
- Connections and runtime access must stay compatible with the least-privilege boundaries in `docs/security/rbac_matrix.md`.

**Sources:** `docs/security/secrets_rotation_policy.md`; `docs/security/rbac_matrix.md`; `Deploy_FUAM.ipynb`.

---

## Observability

| Aspect | Implementation |
|--------|----------------|
| Logging | Fabric notebook and pipeline run history plus explicit audit writes to `stg_ingestion_audit` |
| Metrics | Lightweight operational outputs through `fct_completeness_report` and Gold lifecycle fields |
| Tracing | Run correlation via `fabric_pipeline_run_id`, notebook run identifiers, and source lineage fields |

This phase intentionally stops at basic operability; advanced KQL packs and wider alert-routing remain deferred.

**Sources:** `docs/operations/slo_sla_operacional.md`; `docs/operations/alerting_matrix.md`; `docs/discovery/arquitetura_de_dados.md` §3.

---

## Pipeline Architecture

> This feature involves data pipelines and analytics-style materialization.

### DAG Diagram

```text
[ODI Oracle] ──extract──→ [Bronze ODI] ──normalize──→ [Silver ODI] ──materialize──→ [Gold facts]
[ETL Oracle] ──extract──→ [Bronze ETL] ──normalize──→ [Silver ETL] ───────────────↗
[Elastic] ─────extract──→ [Bronze Elastic] ─normalize──→ [Silver NOT_STARTED] ───↗
[Power BI API] ─extract→ [Bronze PBI] ───normalize──→ [Silver PBI] ───────────────↗
                                            ↓
                                     [stg_ingestion_audit]
```

### Partition Strategy

| Table | Partition Key | Granularity | Rationale |
|-------|---------------|-------------|-----------|
| `stg_*` raw tables | `ingestion_date` | Daily | Matches windowed collection and simplifies retention |
| `fct_execution_event` | `ingestion_date` | Daily | Supports operational time slicing and incremental checks |
| `fct_error_event` | `ingestion_date` | Daily | Supports lifecycle tracking and incident review |

### Incremental Strategy

| Model | Strategy | Key Column | Lookback |
|-------|----------|------------|----------|
| Bronze collectors | Append | `collected_at` / source window | Per run |
| Silver normalizers | Rebuild or bounded overwrite by logical window | source-specific run key + window | Current + recent window as needed |
| Gold facts | Merge/upsert by contract-safe business keys | source family key + logical run identity | Current + recent unresolved window |

### Schema Evolution Plan

| Change Type | Handling | Rollback |
|-------------|----------|----------|
| New Gold column from canonical contract | Add via schema update after DEFINE/DESIGN iteration | Revert design/build and remove column only through controlled follow-up |
| Source payload drift | Adjust Bronze persistence and Silver mapping explicitly | Restore prior mapping and quarantine new source fields |
| Optional shared object introduction | Create only after repeated use is proven | Inline logic back into notebooks and remove optional asset |

### Data Quality Gates

| Gate | Tool | Threshold | Action on Failure |
|------|------|-----------|-------------------|
| Mandatory Gold identifiers not null | Spark SQL validation / notebook checks | 0 nulls | Block Gold publish |
| ETLTOOLS `NOT_STARTED` lineage rule | Spark SQL validation / notebook checks | 100% compliant rows | Block Gold publish |
| Window completeness | Completeness notebook / validation query | Missing source window = 0 tolerated for planned runs | Alert and investigate before sign-off |

**Sources:** `docs/discovery/arquitetura_de_dados.md` §2–§5; `docs/discovery/contrato_canonico.md` §2–§6; `docs/operations/slo_sla_operacional.md`.

---

## Validation Contract

> This section is read by `/workflow:validate` at Phase 3.5.

### Spec Junta Targets (alignment + architecture)

| Requirement ID | Description | Expected Evidence in Code |
|----------------|-------------|---------------------------|
| FR-05 to FR-10 | Bronze raw staging and thin collectors | Bronze notebooks and `create_schema_bronze.ipynb` |
| FR-11 to FR-15 | Silver normalization, lineage, and dedup boundary | Silver normalization notebooks |
| FR-16 to FR-21 | Gold contract materialization and lifecycle fields | Gold materialization notebooks and Gold DDL |
| FR-22 to FR-29 | Bootstrap/setup and 4-pipeline orchestration model | `bootstrap_environment.ipynb`, setup notebooks, and 4 pipeline JSON files |
| FR-30 to FR-32 | Basic operational evidence for runbook-driven triage | `stg_ingestion_audit`, Gold outputs, and pipeline history evidence |

**Architecture decisions to verify:**

| Decision | Expected Pattern in Code |
|----------|--------------------------|
| Fabric-only, medallion-first implementation | No local execution tier or non-Fabric orchestration artifacts in the build output |
| Gold contract is authoritative | Gold DDL and materialization logic reflect canonical contract fields and rules |
| Bronze notebooks stay thin | Bronze notebooks show explicit extract → metadata → raw write → audit flow |
| Bootstrap uses notebook-contained CLI only for setup | Bootstrap notebook uses session-scoped token export and does not create a separate CLI operating path |
| Shared objects are optional | Optional functions/variables exist only if justified and referenced by repeated use |

---

### Code Junta Targets (quality + devops)

| Dimension | Expectation |
|-----------|-------------|
| Type hints / explicitness | Notebook logic and any extracted helpers remain explicit and readable |
| Error handling | External calls and setup steps fail visibly with audit or run-history evidence |
| Test coverage | Validation queries and notebook/pipeline runs cover all 4 source paths plus Gold rules |
| DevOps | No secrets in code; no CI/CD assets added as required scope for this phase |
| Security | Inputs and credentials stay at the approved connection / session-token boundary |

---

### Delivery Junta Targets (manifest completeness)

All files in the File Manifest above are expected to exist in the build output tree unless marked optional and explicitly deemed unnecessary during build.

| File | Delivery Status at Design Time |
|------|--------------------------------|
| `notebooks/setup/bootstrap_environment.ipynb` | Planned |
| `notebooks/bronze/collect_odi.ipynb` | Planned |
| `notebooks/bronze/collect_etltools.ipynb` | Planned |
| `notebooks/bronze/collect_elastic.ipynb` | Planned |
| `notebooks/bronze/collect_powerbi.ipynb` | Planned |
| `notebooks/silver/normalize_odi.ipynb` | Planned |
| `notebooks/silver/normalize_etltools.ipynb` | Planned |
| `notebooks/silver/normalize_powerbi.ipynb` | Planned |
| `notebooks/gold/materialize_execution_event.ipynb` | Planned |
| `notebooks/gold/materialize_error_event.ipynb` | Planned |
| `notebooks/gold/materialize_snapshot.ipynb` | Planned |
| `notebooks/gold/materialize_completeness.ipynb` | Planned |
| `notebooks/gold/update_open_flags.ipynb` | Planned |
| `notebooks/setup/create_schema_bronze.ipynb` | Planned |
| `notebooks/setup/create_schema_silver.ipynb` | Planned |
| `notebooks/setup/create_schema_gold.ipynb` | Planned |
| `notebooks/setup/seed_dimensions.ipynb` | Optional |
| `pipelines/pipeline_collect_odi.json` | Planned |
| `pipelines/pipeline_collect_etltools.json` | Planned |
| `pipelines/pipeline_collect_powerbi.json` | Planned |
| `pipelines/pipeline_materialize_gold.json` | Planned |
| `fabric/functions/build_correction_url` | Optional |
| `fabric/functions/build_dedup_key` | Optional |
| `fabric/variables/collection_windows` | Optional |
| `fabric/variables/expected_counts` | Optional |

**Acceptance criteria mapping**

| Acceptance Test | Delivered By |
|-----------------|--------------|
| AT-001 / AT-001A / AT-002 / AT-003 | Bootstrap + setup + Bronze notebooks |
| AT-004 / AT-005 / AT-006 / AT-007 | Silver and Gold notebooks |
| AT-008 / AT-009 / AT-010 | Pipelines, `stg_ingestion_audit`, and Gold query validation |

---

### Score Targets

| Junta | Minimum Score | Zero Tolerance |
|-------|---------------|----------------|
| Spec (alignment) | ≥ 90 | CRITICAL findings |
| Spec (architecture) | ≥ 90 | CRITICAL findings |
| Code (quality) | ≥ 90 | CRITICAL findings |
| Code (devops) | ≥ 70 | secrets in code |
| Delivery (delta) | ≥ 90 | Missing required manifest items |
| **Overall** | **≥ 90** | **0 CRITICAL** |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-18 | design-agent | Initial DESIGN (DuckDB/Parquet local Phase 1) |
| 2.0 | 2026-05-18 | iterate-agent | Full rewrite to Fabric-only platform |
| 2.1 | 2026-05-18 | iterate-agent | Structural review and delegation detail |
| 2.2 | 2026-05-18 | iterate-agent | Added Fabric runtime readiness, governance, semantic model, CI/CD, and monitoring expansion |
| 2.3 | 2026-06-10 | iterate-agent | Simplification-first redesign: removed CI/CD and advanced monitoring from this phase, reduced setup complexity, kept Bronze/Silver/Gold, made Spark SQL the default for DDL/materialization, required `notebookutils`, and replaced ad hoc reuse patterns with Fabric function/variable objects where needed |
| 2.4 | 2026-06-10 | iterate-agent | Rebuilt DESIGN from `docs/` with denser source-grounded architecture, layer contracts, notebook/pipeline responsibilities, source-specific transformations, minimal shared-object policy, and explicit deferral of CI/CD, FUAM, Fabric CLI-centered operations, and advanced monitoring |
| 2.5 | 2026-06-10 | iterate-agent | Refined DESIGN so high documentary detail is explicitly decoupled from build breadth; tightened scope language around reference data, shared objects, semantic-model implications, monitoring expectations, and optional assets |
| 2.6 | 2026-06-10 | iterate-agent | Added notebook-bootstrap setup design based on `Deploy_FUAM.ipynb`: `%pip install ms-fabric-cli`, session-scoped token export, connection validation/creation, current-workspace resolution, environment-bound item import/update, and bootstrap-only use of CLI behavior |
| 2.7 | 2026-06-10 | iterate-agent | Realigned DESIGN to the canonical template by restoring Metadata, Components, Agent Assignment Rationale, manifest dependencies/agents, Code Patterns, Integration Points, Testing Strategy, Error Handling, Configuration, Observability, Pipeline Architecture, and Validation Contract sections without widening scope |
| 2.8 | 2026-06-10 | iterate-agent | Adjusted DESIGN section order to better match the canonical template by placing File Manifest before Agent Assignment Rationale and standardizing the agent-discovery wording |

---

## Next Step

**Ready for:** `/workflow:build ~/.config/opencode/sdd/features/observability-hub/DESIGN_OBSERVABILITY_HUB.md`
