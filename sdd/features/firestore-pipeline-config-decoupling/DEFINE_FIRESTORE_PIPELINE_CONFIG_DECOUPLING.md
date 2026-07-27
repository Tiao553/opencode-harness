# DEFINE: Firestore Pipeline Config Decoupling

> Decouple pipeline configuration from Composer-managed YAML files into a Firestore-backed canonical config store.

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | FIRESTORE_PIPELINE_CONFIG_DECOUPLING |
| **Date** | 2026-06-04 |
| **Author** | define-agent |
| **Status** | Ready for Design |
| **Clarity Score** | 15/15 |

---

## Problem Statement

Pipeline configuration YAMLs are currently coupled to the Composer bucket and repository-backed DAG code, forcing redeploys for config changes and keeping Dataflow on a separate configuration lifecycle instead of sharing one canonical runtime configuration source.  
Source: `specs/BRAINSTORM_FIRESTORE_PIPELINE_CONFIG_DECOUPLING.md`, `dags/medallion_factory/config_loader.py`

---

## Target Users

| User | Role | Pain Point |
|------|------|------------|
| Data operations team | Maintains pipeline configurations | Must redeploy Composer or update bucket-managed YAMLs to change pipeline behavior. |
| Data engineers | Build and evolve Bronze/Silver/Gold pipelines | Must maintain duplicated or parallel configs across Composer-managed YAMLs and separate Dataflow config flows. |
| Airflow/Data platform maintainers | Own orchestration reliability | Need lightweight parse-time DAG discovery and fresh runtime config reads without scheduler slowdown. |

---

## Goals

What success looks like (prioritized):

| Priority | Goal |
|----------|------|
| **MUST** | Replace Composer-bucket YAML discovery with a Firestore-backed canonical configuration store for Bronze, Silver, and Gold pipelines. |
| **MUST** | Allow pipeline configs to be created and changed through Firebase Console or equivalent UI without Composer redeploy. |
| **MUST** | Enable Airflow to perform lightweight parse-time discovery and full runtime point-reads from Firestore for each pipeline. |
| **MUST** | Make Dataflow consume the same canonical pipeline configuration payload Airflow uses, removing the separate YAML lifecycle. |
| **MUST** | Preserve existing layer separation through three Firestore collections: `1_Bronze`, `2_Silver`, and `3_Gold`. |
| **MUST** | Use Firestore document id as the only `pipeline_id` representation, with no duplicated `pipeline_id` field stored in the document body. |
| **MUST** | Require `dag_id`, `env`, and `schedules[]` in every Bronze, Silver, and Gold document. |
| **SHOULD** | Migrate existing YAML configurations into Firestore without data loss or schema regression. |
| **SHOULD** | Enforce the contract that one `dag_id` maps to one schedule definition, failing fast during DAG parse when violated. |
| **SHOULD** | Preserve the agreed evolved Bronze/Dataflow schema with nested coverage for `comment`, `rows_limit`, optional `is_golden_gate`, `queries.select_to_bq`, `tables.origin`, `tables.destiny`, optional `compute`, and execution type carried in `schedules[].type` when sourced from the user-provided Bronze examples. |
| **SHOULD** | Preserve the current Dataform schema for Silver and Gold as nested `silver` / `gold` objects while adding the Firestore orchestration envelope (`dag_id`, `env`, `schedules[]`) and keeping `depends_on` top-level. |

**Priority Guide:**
- **MUST** = MVP fails without this
- **SHOULD** = Important, but workaround exists
- **COULD** = Nice-to-have, cut first if needed

---

## Success Criteria

Measurable outcomes (must include numbers):

- [ ] 100% of active Bronze, Silver, and Gold pipeline configs are sourced from Firestore instead of local Composer YAML files.
- [ ] Airflow parse-time config discovery reads only the fields needed to build DAGs (`dag_id` and `schedules`) and completes each config lookup path within 100 ms per Firestore interaction target.
- [ ] 100% of runtime pipeline executions fetch the full config document by `pipeline_id` from Firestore before invoking Dataflow or Dataform.
- [ ] 0 Composer redeploys are required to apply a configuration-only change after the migration is complete.
- [ ] 100% of migrated YAML configs are imported into one of the three target Firestore collections with no missing records.
- [ ] 100% of parse-time schedule conflicts for the same `dag_id` raise `ConfigValidationError` before DAG generation completes.
- [ ] 100% of pipeline config documents include the operational `env` field inside the canonical Firestore document.
- [ ] 100% of pipeline config documents use Firestore document id as `pipeline_id`, with 0 duplicated `pipeline_id` fields stored in document payloads.
- [ ] 100% of active Firestore documents include required `dag_id`, `env`, and `schedules[]` fields.
- [ ] 100% of Bronze documents conform to the agreed evolved Dataflow schema.
- [ ] 100% of Silver and Gold documents conform to their current Dataform schema plus the Firestore orchestration envelope.

---

## Acceptance Tests

| ID | Scenario | Given | When | Then |
|----|----------|-------|------|------|
| AT-001 | Parse-time DAG discovery | Firestore contains valid pipeline docs across the three collections | Airflow parses DAG definitions | The factory lists pipeline docs, groups them by `dag_id`, and creates one DAG per valid `dag_id` without reading full payloads. |
| AT-002 | Runtime config fetch for Bronze | A Bronze pipeline doc exists in `1_Bronze` | The DAG triggers the Bronze execution path | Airflow fetches the full Firestore document by `pipeline_id` and passes the canonical config to Dataflow/Cloud Run. |
| AT-003 | Runtime config fetch for Silver/Gold | A Silver or Gold pipeline doc exists with Dataform fields | The DAG triggers the layer execution path | Airflow fetches the full Firestore document by `pipeline_id` and passes the config to the Dataform invocation flow. |
| AT-004 | No redeploy config update | A pipeline config already exists in Firestore | An operator edits the config in Firebase Console | The next pipeline run uses the new config without Composer code redeploy. |
| AT-005 | Schedule contract violation | Two docs share the same `dag_id` but contain different schedules | Airflow parses the DAG factory | DAG generation fails fast with `ConfigValidationError`. |
| AT-006 | Migration completeness | YAML source files exist for currently active pipelines | The migration/import process runs | Every source YAML is represented once in Firestore with no missing pipeline record. |
| AT-007 | No duplicated `pipeline_id` field | A Firestore document exists in any target collection | The runtime loader validates the document shape | The pipeline identity is obtained from the document id only, and validation fails if a duplicated `pipeline_id` field exists in the payload. |
| AT-008 | Required orchestration envelope | A Firestore document exists in any target collection | Parse-time or runtime validation runs | The document is rejected if `dag_id`, `env`, or `schedules[]` is missing. |
| AT-009 | Bronze evolved schema | A document exists in `1_Bronze` | The runtime loader normalizes the Bronze payload | The payload contains the agreed nested Bronze fields `comment`, `rows_limit`, optional `is_golden_gate`, `queries.select_to_bq.select`, `queries.select_to_bq.where`, `tables.origin.*`, `tables.destiny.*`, optional `compute.*`, and uses `schedules[].type` when execution type is present in the user-provided source examples. |
| AT-010 | Silver/Gold layer-specific schema | A document exists in `2_Silver` or `3_Gold` | The runtime loader normalizes the payload | Silver accepts nested `silver.included_targets`, nested `silver.assert_targets` (empty/default allowed), top-level `depends_on`, and the Firestore envelope; Gold accepts nested `gold.included_targets`, top-level `depends_on`, and the Firestore envelope; `included_tags` is not validated as a confirmed current-repo field because source was not found in local YAMLs. |

---

## Out of Scope

Explicitly NOT included in this feature:

- Custom internal CRUD UI with schema-aware validation for Firestore documents.
- Firestore document versioning or history management beyond platform-native capabilities.
- Redesign of Gold scheduling semantics beyond the agreed single-`dag_id`/single-schedule contract.
- Broader Firebase Console authentication/authorization redesign beyond required access for config editing.
- Non-Firestore storage alternatives such as Bigtable, Memorystore, or Spanner.

---

## Constraints

| Type | Constraint | Impact |
|------|------------|--------|
| Technical | Solution must stay on GCP and use Firestore Native Mode rather than AWS-style equivalents. | Design must use GCP-native clients, IAM, and operational patterns. |
| Technical | Airflow/Composer must keep parse-time behavior lightweight and avoid loading full config payloads during DAG construction. | Design must separate list/discovery reads from runtime point-reads. |
| Technical | Existing layer model and pipeline identifiers must remain compatible with current Bronze/Silver/Gold config semantics. | Migration and document schema must mirror the current YAML structure closely. |
| Platform | Composer service access needs Firestore read permissions. | Infrastructure/IAM changes are required even though Terraform sources were not found in this repo. Source: brainstorm technical context; repo IaC source not found. |
| Operational | Config editors are expected to use Firebase Console or equivalent UI flow. | Validation and governance must tolerate out-of-band config changes without deploy gates. |

---

## Technical Context

> Essential context for Design phase - prevents misplaced files and missed infrastructure needs.

| Aspect | Value | Notes |
|--------|-------|-------|
| **Deployment Location** | `dags/medallion_factory/` | Source: brainstorm technical context and existing `dags/medallion_factory/config_loader.py`, which currently scans YAML files from disk. |
| **KB Domains** | `airflow`, `gcp` | Source: brainstorm “Relevant KB Domains”; these map to available KB directories under `~/.config/opencode/kb/`. |
| **IaC Impact** | Modify existing or external IaC | Firestore access and Composer service-account permissions are required. Source: brainstorm technical context; repo-local Terraform files were not found, so the exact IaC location remains external/TBD. |

**Why This Matters:**

- **Location** → Design should replace file-based config loading in `dags/medallion_factory/` rather than adding a parallel loader.
- **KB Domains** → Design should consult Airflow orchestration patterns and GCP/Firestore guidance.
- **IaC Impact** → Firestore and IAM enablement must be planned explicitly to avoid a design that works only in code.

---

## Data Contract (if applicable)

> Include this section when the feature involves data pipelines, ETL, or analytics.

### Source Inventory
| Source | Type | Volume | Freshness | Owner |
|--------|------|--------|-----------|-------|
| Composer config YAMLs in `dags/config/` | GCS-backed YAML files | ~5k docs max across 3 layers | Changes apply on push/redeploy today | Data platform team |
| Separate Dataflow YAML store | GCS-backed YAML files | Bronze subset | Manual / separate lifecycle | Data platform team |
| Firestore target store | Firestore Native collections | ~5k docs max | Runtime point-read, no redeploy target model | Data platform team |

### Schema Contract

**Contract sources for this DEFINE iteration:** user-provided Bronze examples in this conversation, repo YAMLs in `dags/config/silver/*.yaml`, `dags/config/gold/*.yaml`, `dags/config/schedules.yaml`, and the already-agreed Firestore rules from BRAINSTORM.

#### Global Firestore document rules

| Field / Rule | Type | Constraints | PII? |
|--------------|------|-------------|------|
| Firestore document id | string | **This is the canonical `pipeline_id`**; unique within the collection; required | No |
| `pipeline_id` field in payload | forbidden | Must **not** be duplicated inside the document body | No |
| `dag_id` | string | Required in every collection; shared by pipelines that belong to the same DAG | No |
| `env` | string | Required in every collection | No |
| `schedules[]` | array<object> | Required in every collection | No |
| `schedules[].cron` | string | Required canonical Firestore cron field | No |
| `1 dag_id = 1 cron` | rule | All docs grouped under one `dag_id` must resolve to one identical cron | No |
| `schedule_frequency` | legacy string | Present in current repo YAMLs; must be translated to `schedules[]` using `dags/config/schedules.yaml` | No |

#### `1_Bronze`

| Field | Type | Constraints | PII? |
|------|------|-------------|------|
| `comment` | string \| null | Optional operational note | No |
| `rows_limit` | integer \| null | Optional row cap | No |
| `is_golden_gate` | boolean | Optional when present | No |
| `queries` | object | Optional | No |
| `queries.select_to_bq.select` | string | Present when `queries` exists | No |
| `queries.select_to_bq.where` | string \| null | Present when `queries` exists | No |
| `tables.origin.dataset` | string | Required in final Bronze contract | No |
| `tables.origin.name` | string | Required in final Bronze contract | No |
| `tables.origin.bound_column` | string \| null | Required field, nullable allowed | No |
| `tables.origin.num_partition` | integer \| null | Required field, nullable allowed | No |
| `tables.origin.incremental_fields` | array<string> \| null | Required field; array or null | No |
| `tables.origin.pk` | array<string> | Required in final Bronze contract | No |
| `tables.origin.description` | string \| null | Required field, nullable allowed | No |
| `tables.origin.labels.responsable` | string | Required label in user-provided Bronze examples | No |
| `tables.origin.labels.team` | string | Required label in user-provided Bronze examples | No |
| `tables.destiny.dataset` | string | Required in final Bronze contract | No |
| `tables.destiny.name` | string | Required in final Bronze contract | No |
| `tables.destiny.partition_field_name` | string \| null | Required field, nullable allowed | No |
| `tables.destiny.partition_field_type` | string \| null | Required field, nullable allowed | No |
| `tables.destiny.partition_field_origin` | string \| null | Required field, nullable allowed | No |
| `tables.destiny.partition_field_origin_type` | string \| null | Required field, nullable allowed | No |
| `tables.destiny.clustering_fields` | array<string> | Required field; empty array allowed | No |
| `compute` | object | Optional | No |
| `compute.num_workers` | integer | Present when `compute` exists | No |
| `compute.max_workers` | integer | Present when `compute` exists | No |
| `compute.machine_type` | string | Present when `compute` exists | No |
| `schedules[].type` | string | Execution type is observed here in the user-provided Bronze examples | No |

**Bronze notes:**
- Do **not** claim a confirmed top-level `type` field without source.
- The local repo Bronze YAMLs are legacy/simple (`bronze.environment`, `dataset_name`, `table_name`, `processing_mode`) and serve only as migration context, not as the final nested Firestore contract.

#### `2_Silver`

| Field | Type | Constraints | PII? |
|------|------|-------------|------|
| `silver` | object | Required nested object | No |
| `silver.included_targets` | array<string> | Required; confirmed in current YAMLs | No |
| `silver.assert_targets` | array<string> | Optional when absent in current files; default/empty allowed; confirmed in template contract | No |
| `depends_on` | array<string> | Top-level; optional/empty allowed | No |

**Silver notes:**
- Current repo YAMLs use nested `silver`.
- Current repo YAMLs still use `schedule_frequency`; Firestore must persist the translated schedule in `schedules[]`.

#### `3_Gold`

| Field | Type | Constraints | PII? |
|------|------|-------------|------|
| `gold` | object | Required nested object | No |
| `gold.included_targets` | array<string> | Required; confirmed in current YAMLs | No |
| `depends_on` | array<string> | Top-level; optional/empty allowed | No |
| `included_tags` | unknown | **Source not found** in current local YAMLs; if kept later, treat as future extension rather than confirmed repo contract | No |

### Canonical examples

```yaml
# Bronze - query / incremental_event
dag_id: bronze_medallion
env: dev
schedules:
  - cron: "0 6 26 * *"
    type: incremental_event
queries:
  select_to_bq:
    select: "SELECT id_pagamento, data_referencia FROM origem"
    where: "data_referencia >= @last_ref"
tables:
  origin:
    dataset: relatorio
    name: rel_demonstrativo_titular
    bound_column: data_referencia
    num_partition: 32
    incremental_fields:
      - data_referencia
    pk: [id_pagamento]
    description: "Origem incremental"
    labels:
      responsable: ecad
      team: data-platform
  destiny:
    dataset: bronze_relatorio
    name: rel_demonstrativo_titular
    partition_field_name: data_referencia
    partition_field_type: timestamp
    partition_field_origin: data_referencia
    partition_field_origin_type: timestamp
    clustering_fields: [id_pagamento]
```

```yaml
# Bronze - com is_golden_gate
dag_id: bronze_medallion
env: dev
schedules:
  - cron: "0 6 * * *"
    type: full
is_golden_gate: true
tables:
  origin:
    dataset: arrecadacao
    name: grupo
    bound_column: null
    num_partition: null
    incremental_fields: null
    pk: [grupo_id]
    description: "Carga full"
    labels:
      responsable: ecad
      team: data-platform
  destiny:
    dataset: bronze_arrecadacao
    name: grupo
    partition_field_name: null
    partition_field_type: null
    partition_field_origin: null
    partition_field_origin_type: null
    clustering_fields: []
```

```yaml
# Bronze - full
dag_id: bronze_medallion
env: dev
schedules:
  - cron: "0 6 * * *"
    type: full
comment: "Carga bronze completa"
rows_limit: null
compute:
  num_workers: 1
  max_workers: 4
  machine_type: n2-standard-2
tables:
  origin:
    dataset: arrecadacao
    name: rubrica_grupo
    bound_column: null
    num_partition: null
    incremental_fields: null
    pk: [rubrica_id]
    description: "Tabela full"
    labels:
      responsable: ecad
      team: data-platform
  destiny:
    dataset: bronze_arrecadacao
    name: rubrica_grupo
    partition_field_name: null
    partition_field_type: null
    partition_field_origin: null
    partition_field_origin_type: null
    clustering_fields: []
```

```yaml
# Silver
dag_id: silver_medallion
env: dev
schedules:
  - cron: "0 6 * * *"
silver:
  included_targets:
    - assert_cadastros
    - assert_pagamentos_unificado
  assert_targets: []
depends_on:
  - fonograma_titular
  - obra_titular
  - rel_demonstrativo_titular
```

```yaml
# Gold
dag_id: gold_medallion
env: dev
schedules:
  - cron: "0 6 26 * *"
gold:
  included_targets:
    - ft_demonstrativo_titular
depends_on:
  - assert_pii_gold
```

### Freshness SLAs
| Layer | Target | Measurement |
|-------|--------|-------------|
| Parse/discovery metadata | Visible on next DAG parse cycle without redeploy | Airflow scheduler observes updated `dag_id`/`schedules` from Firestore |
| Runtime pipeline config | Latest saved document used on next pipeline execution | Point-read timestamp is newer than or equal to last document update |

### Completeness Metrics
- 100% of existing active YAML configs migrated into Firestore.
- 0 missing pipeline records after migration validation.
- 0 null Firestore document ids (`pipeline_id`), `dag_id`, or `env` values in active Firestore documents.
- 0 documents with duplicated `pipeline_id` stored in payload.

### Lineage Requirements
- Each Firestore document must map back to a single source pipeline identity through its Firestore document id (`pipeline_id`).
- Migration must preserve enough structure to validate equivalence between YAML source and Firestore target documents.

---

## Assumptions

Assumptions that if wrong could invalidate the design:

| ID | Assumption | If Wrong, Impact | Validated? |
|----|------------|------------------|------------|
| A-001 | Firestore Native Mode is available and approved for this environment. | Storage choice and IAM plan must be revisited before design can proceed safely. | [ ] |
| A-002 | Composer can authenticate to Firestore with low-latency reads that meet the <100 ms interaction target. | Parse-time and runtime access patterns may need caching or a different integration design. | [ ] |
| A-003 | Existing pipeline YAMLs can be normalized into a single evolved Firestore schema without losing required layer-specific behavior. | Migration scope expands and may require per-layer schema exceptions. | [ ] |
| A-004 | The missing Terraform/IaC sources are managed outside this repository and can be updated in parallel. | Delivery may block on infrastructure ownership and repo boundary clarification. | [ ] |

**Note:** Validate critical assumptions before DESIGN phase. Unvalidated assumptions become risks.

---

## Clarity Score Breakdown

| Element | Score (0-3) | Notes |
|---------|-------------|-------|
| Problem | 3 | Problem is explicit in brainstorm and corroborated by `config_loader.py` file-based loading. |
| Users | 3 | Primary operators, engineers, and platform maintainers are identifiable with concrete pain points. |
| Goals | 3 | Goals are explicit, prioritized, and directly tied to Firestore decoupling behavior. |
| Success | 3 | Success criteria are measurable with latency, completeness, and deployment-free change targets. |
| Scope | 3 | In-scope and out-of-scope boundaries are explicit, including rejected storage options and deferred UI/versioning work. |
| **Total** | **15/15** | Ready for Design |

**Scoring Guide:**
- 0 = Missing entirely
- 1 = Vague or incomplete
- 2 = Clear but missing details
- 3 = Crystal clear, actionable

**Minimum to proceed: 12/15**

---

## Open Questions

- Where is the canonical Terraform/IaC repository that will provision Firestore access and Composer IAM changes? Source not found in this repo.
- How exactly should the runtime loader normalize the legacy Bronze repo fields (`bronze.environment`, `dataset_name`, `table_name`, `processing_mode`) into the richer final Firestore Bronze contract sourced from the user-provided examples?

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-06-04 | define-agent | Initial DEFINE version from approved brainstorm and repo validation |
| 1.1 | 2026-06-04 | iterate-agent | Cascaded final agreed Firestore schema: explicit `1_Bronze`/`2_Silver`/`3_Gold` contracts, Document ID = `pipeline_id`, no duplicated `pipeline_id` field, required `dag_id`/`env`/`schedules[]`, and `1 dag_id = 1 cron` |
| 1.2 | 2026-06-04 | iterate-agent | Refined the Firestore contract with complete nested Bronze fields, corrected Silver/Gold to nested `silver`/`gold` objects plus top-level `depends_on`, translated legacy `schedule_frequency` to `schedules[]`, and marked Gold `included_tags` as source not found / future extension |

---

## Next Step

**Ready for:** `/workflow:design ~/.config/opencode/sdd/features/firestore-pipeline-config-decoupling/DEFINE_FIRESTORE_PIPELINE_CONFIG_DECOUPLING.md`
