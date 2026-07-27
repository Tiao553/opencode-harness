# DESIGN: Firestore Pipeline Config Decoupling

> Technical design for implementing Firestore Pipeline Config Decoupling

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | FIRESTORE_PIPELINE_CONFIG_DECOUPLING |
| **Date** | 2026-06-04 |
| **Author** | design-agent |
| **DEFINE** | [DEFINE_FIRESTORE_PIPELINE_CONFIG_DECOUPLING.md](./DEFINE_FIRESTORE_PIPELINE_CONFIG_DECOUPLING.md) |
| **Status** | Ready for Build |

---

## Architecture Overview

**Primary sources:**
- DEFINE: `specs/DEFINE_FIRESTORE_PIPELINE_CONFIG_DECOUPLING.md`
- Current implementation: `dags/medallion_factory/config_loader.py`, `dags/medallion_factory/settings.py`, `dags/bronze_medallion_dag.py`, `dags/silver_medallion_dag.py`, `dags/gold_medallion_dag.py`
- Current YAML contracts: `dags/config/bronze/*.yaml`, `dags/config/silver/*.yaml`, `dags/config/gold/*.yaml`, `dags/config/schedules.yaml`
- User-provided Bronze full examples in this iterate request/conversation (canonical source for final nested Bronze payload)
- Airflow KB: `~/.config/opencode/kb/airflow/patterns/dag-factory.md`, `~/.config/opencode/kb/airflow/patterns/error-handling.md`, `~/.config/opencode/kb/airflow/quick-reference.md`
- GCP KB: `~/.config/opencode/kb/gcp/quick-reference.md`, `~/.config/opencode/kb/gcp/concepts/iam.md`
- Firestore client docs: Context7 `/googleapis/python-firestore` for collection streaming and document-by-ID access
- User-approved iterate change request in this conversation: introduce a backend-selected config store abstraction for local development and tests, keeping Firestore as the final target and MongoDB as a temporary/local backend

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                  BACKEND-SELECTED CONFIG STORE DAG FACTORY                  │
├──────────────────────────────────────────────────────────────────────────────┤
│ MEDALLION_CONFIG_BACKEND                                                    │
│   ├─ firestore  -> Firestore adapter -> 1_Bronze / 2_Silver / 3_Gold        │
│   └─ mongodb    -> MongoDB adapter   -> 1_Bronze / 2_Silver / 3_Gold        │
│                                  │                                           │
│             common contract: list_pipeline_metadata(collection)              │
│                              get_pipeline(collection, pipeline_id)           │
│                                  │                                           │
│                                  ▼                                           │
│                    [config_registry.build_dag_specs()]                       │
│                                  │                                           │
│                validate one dag_id -> one schedule contract                  │
│                                  │                                           │
│                                  ▼                                           │
│                 [config_store_medallion_factory.py globals()]                │
│                   │              │                │                           │
│             Bronze DAGs      Silver DAGs      Gold DAGs                      │
│                   │              │                │                           │
│                   ▼              ▼                ▼                           │
│          runtime fetch task uses selected adapter for canonical payload       │
│                   │              │                │                           │
│                   ▼              ▼                ▼                           │
│         Cloud Run/Dataflow   Dataform invoke    Dataform invoke              │
│                   │              │                │                           │
│                   └────── structured logs + latency/error metrics ───────────┘
└──────────────────────────────────────────────────────────────────────────────┘
```

**Recommended architecture:** a backend-selected config-store DAG factory replaces file-system YAML discovery, while preserving Firestore as the production target store. A common adapter contract fronts two separate backends: Firestore for target/prod behavior and MongoDB for temporary local development and tests. Runtime tasks fetch the full canonical document immediately before execution through the selected adapter. This follows the DEFINE requirement for lightweight parse-time discovery plus runtime point-reads, while adapting the Airflow DAG factory pattern from `dag-factory.md` away from YAML and toward a stable config-store contract.

**Implementation scope alignment:** for this DESIGN iteration, every current DEFINE goal is mandatory build scope, including goals still labeled `SHOULD` in the DEFINE priority table. Optionality remains only where the schema contract itself marks individual fields as optional or nullable; it does not make migration completeness, `dag_id` schedule validation, Bronze schema preservation, or Silver/Gold schema preservation optional for implementation planning.

**Sources:** DEFINE Goals, Success Criteria, Acceptance Tests AT-005/006/009/010; user-approved iterate change request in this conversation.

---

## Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| `config_store_medallion_factory.py` | Airflow entrypoint that materializes DAGs from backend-selected metadata | Airflow DAG discovery + Python module globals |
| `config_store.py` | Common config-store contract and backend selector | Python protocol/factory |
| `firestore_config_store.py` | Firestore adapter for metadata queries and document point-reads | `google-cloud-firestore` |
| `mongodb_config_store.py` | MongoDB adapter for temporary/local metadata queries and point-reads | `pymongo` |
| `config_registry.py` | Parse-time metadata scanner and `dag_id` schedule validator over the common contract | Adapter contract + dataclasses |
| `firestore_models.py` | Canonical document and DAG spec models | Python dataclasses |
| `runtime_config_loader.py` | Runtime task helpers that fetch and normalize full documents through the selected adapter | TaskFlow / Python helpers |
| existing DAG operator builders | Convert canonical config into Cloud Run/Dataform operator arguments | Airflow operators already used in repo |
| migration script | Imports YAML configs into Firestore and validates completeness | Python CLI |
| external IaC requirements doc | Captures Firestore enablement and IAM changes that live outside this repo | Markdown handoff artifact |

---

## Key Decisions

### Decision 1: Firestore remains the canonical target store, but access is mediated by a config-store abstraction

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-04 |

**Context:** The DEFINE requires 100% of active Bronze, Silver, and Gold configs to be sourced from Firestore and explicitly calls out redeploy-free edits through Firebase Console. Current code in `dags/medallion_factory/config_loader.py` and layer DAG files is file-based and tied to `dags/config/**.yaml`.

**Choice:** Keep Firestore as the canonical target store for active pipeline documents in collections `1_Bronze`, `2_Silver`, and `3_Gold`, but require application access to go through a config-store abstraction. YAML remains migration input only, not runtime source of truth. MongoDB is introduced only as a temporary/local backend for development and tests.

**Rationale:** This directly satisfies the MUST goals in DEFINE and removes the dual lifecycle between Composer YAMLs and Dataflow YAMLs.

**Alternatives Rejected:**
1. Keep YAML as primary and mirror to Firestore - rejected because it preserves redeploy coupling and dual-write drift.
2. Reuse the same code path by "just changing the host" - rejected because the user-approved iterate request requires separate adapters with a common contract, not backend behavior hidden behind connection-string swaps.
3. Move configs to another GCP store - rejected because DEFINE explicitly keeps Firestore and marks other stores out of scope.

**Consequences:**
- Firestore availability and IAM remain hard production dependencies.
- Local development and adapter-contract testing can proceed without current Firestore access.
- Operators can change config without Composer redeploy once migration completes.

**Sources:** DEFINE Goals, Success Criteria, Out of Scope, Constraints.

---

### Decision 2: Split config-store access into parse-time metadata reads and runtime full-document reads

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-04 |

**Context:** DEFINE requires parse-time reads to stay lightweight and runtime executions to fetch the full document by `pipeline_id`. The iterate request additionally requires adapters with a shared contract: `list_pipeline_metadata(collection)` and `get_pipeline(collection, pipeline_id)`. Current DAG files bind operator parameters from fully parsed local YAML at import time.

**Choice:** Introduce two explicit access paths behind one common contract:
- **Parse time:** `list_pipeline_metadata(collection)` returns only metadata needed for DAG materialization (`pipeline_id`, `dag_id`, `schedules`). For Firestore, `pipeline_id` comes from `doc.id`; for MongoDB, it comes from `_id`. Collection name provides layer context; `env` is validated from the full document at runtime.
- **Runtime:** `get_pipeline(collection, pipeline_id)` point-reads the full canonical document by `pipeline_id`, then downstream operators template from that runtime payload.

**Rationale:** This is the smallest design that satisfies AT-001, AT-002, and AT-003 without pushing full config fetches into scheduler import time.

**Alternatives Rejected:**
1. Full-document reads during DAG parse - rejected because DEFINE forbids heavyweight parse-time behavior regardless of backend.
2. Continue parse-time binding from static documents - rejected because config changes would still require DAG re-import semantics and would not guarantee runtime freshness.

**Consequences:**
- DAG structure is determined from metadata; execution arguments are determined at runtime.
- Build phase must add runtime fetch tasks and XCom-templated operator inputs.
- Both adapters must satisfy identical contract tests so local Mongo behavior cannot drift from the Firestore contract surface.

**Sources:** DEFINE Success Criteria, Acceptance Tests AT-001/002/003, Constraints; Context7 `/googleapis/python-firestore` for collection streaming and `collection.document(document_id)` point-read patterns; user-approved iterate change request in this conversation.

---

### Decision 3: Replace layer-specific static DAG construction with a backend-selected DAG factory

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-04 |

**Context:** Airflow KB `dag-factory.md` recommends module-level DAG generation for many similar pipelines. DEFINE AT-001 requires the factory to group documents by `dag_id` and create one DAG per valid `dag_id`. Current repo has fixed DAG files like `bronze_medallion_dag.py` and `silver_medallion_dag.py` with schedules hardcoded through `settings.py`.

**Choice:** Add one top-level DAG factory module that:
1. resolves the backend from `MEDALLION_CONFIG_BACKEND`,
2. scans metadata across the three collections through the selected adapter,
3. groups documents by `dag_id`,
4. validates that all docs in a group resolve to one schedule definition,
5. builds one DAG object per valid `dag_id`,
6. injects all DAGs into module globals for Airflow discovery.

**Rationale:** This matches the Airflow DAG factory pattern and the DEFINE acceptance criteria better than expanding the existing static files.

**Alternatives Rejected:**
1. Patch existing six DAG files to query a backend directly - rejected because it still assumes a fixed DAG inventory and does not naturally satisfy one-DAG-per-`dag_id` discovery.
2. Generate Python DAG files from Firestore docs - rejected because it reintroduces file generation and redeploy coupling.

**Consequences:**
- Existing fixed DAG modules stop constructing DAGs and are reduced to import-safe wrappers that delegate discovery to `config_store_medallion_factory.py` without defining independent static DAG inventories.
- New `dag_id` values can be introduced through config, subject to validation rules.
- Backend selection is explicit and environment-driven, not inferred from endpoint shape.

**Sources:** DEFINE Acceptance Test AT-001, Technical Context, `dags/medallion_factory/settings.py`, Airflow KB `patterns/dag-factory.md`.

---

### Decision 4: Keep the existing operator stack, but insert a runtime config normalization boundary

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-04 |

**Context:** Current Bronze DAGs invoke Cloud Run jobs; Silver and Gold DAGs invoke Dataform operators. The repo already has working orchestration semantics, dependency wiring, and dataset chaining.

**Choice:** Keep Cloud Run/Dataform operator usage, but add a normalization boundary that converts backend-returned canonical documents into typed runtime objects before operator invocation.

**Rationale:** This is simpler and safer than redesigning all orchestration semantics. It preserves existing medallion behavior while replacing only the config source and timing of config resolution.

**Alternatives Rejected:**
1. Rewrite all DAGs to pure TaskFlow operators - rejected because existing Google provider operators already map to the workload.
2. Pass raw Firestore dictionaries through all tasks - rejected because current repo already favors typed dataclass parsing in `config_loader.py`.

**Consequences:**
- Typed parsing logic remains central and testable.
- Build phase should reuse current dataclass conventions (`frozen=True`, `slots=True`) where possible.

**Sources:** `dags/medallion_factory/config_loader.py`, `dags/bronze_medallion_dag.py`, `dags/silver_medallion_dag.py`, `dags/gold_medallion_dag.py`, `python.python-developer` agent guidance.

---

### Decision 5: Treat external IaC and IAM enablement as a required delivery dependency, not an implicit code assumption

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-04 |

**Context:** DEFINE explicitly says repo-local Terraform sources were not found and that Firestore access plus Composer service-account permissions must be updated externally.

**Choice:** Include an explicit repo-local handoff artifact documenting external IaC requirements and required least-privilege access patterns, but do not invent external Terraform paths or implementation details.

**Rationale:** This preserves source discipline. The design can require Firestore read capability and least privilege without fabricating the external repo boundary.

**Alternatives Rejected:**
1. Omit IaC from the design - rejected because the feature would be incomplete in production.
2. Invent Terraform file paths in this repo - rejected because source not found.

**Consequences:**
- Build scope includes both code changes and the required external IaC/IAM handoff artifact; platform owners may implement infra changes in parallel, but the feature is not considered complete without that delivery evidence.
- Validation must treat missing IaC delivery evidence as a blocker for shipping.
- Successful local Mongo-backed validation is necessary but not sufficient for production readiness.

**Sources:** DEFINE Constraints, Technical Context, Open Questions; GCP KB `concepts/iam.md` for least-privilege principle. Exact Firestore role name source not found in loaded KB and must be confirmed during build/IaC implementation.

---

### Decision 6: Local development uses MongoDB as a temporary backend with the canonical contract unchanged

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | 2026-06-04 |

**Context:** The user-approved iterate request states that current development cannot rely on present Firestore access and asks for a temporary/local backend. The same request explicitly preserves the canonical document contract and requires collection mapping `1_Bronze` / `2_Silver` / `3_Gold` with Mongo `_id = pipeline_id`.

**Choice:** Support `mongodb` as a local/dev backend selected by `MEDALLION_CONFIG_BACKEND`, with one collection per layer using the same collection names as Firestore. Mongo documents keep the canonical payload unchanged; only identity storage differs, with `_id` carrying the canonical `pipeline_id`.

**Rationale:** This gives developers and tests a working local path without weakening the Firestore target architecture or mutating the document contract.

**Alternatives Rejected:**
1. Block all development until Firestore access is available - rejected because it stalls implementation unnecessarily.
2. Store `pipeline_id` both in Mongo `_id` and payload - rejected because it would violate the canonical contract kept by DEFINE.

**Consequences:**
- Local fixtures and tests can exercise DAG discovery, runtime fetch, and normalization through MongoDB.
- Production validation still requires real Firestore connectivity, Composer identity, and IAM verification.

**Sources:** user-approved iterate change request in this conversation; DEFINE Goals requiring Firestore as target store and `pipeline_id` only in document identity.

---

## File Manifest

| # | File | Action | Purpose | Agent | Dependencies |
|---|------|--------|---------|-------|--------------|
| 1 | `dags/config_store_medallion_factory.py` | Create | Airflow discovery entrypoint that emits DAGs from backend-selected specs | @data-engineering.airflow-specialist | 2, 5, 6, 7 |
| 2 | `dags/medallion_factory/config_store.py` | Create | Define the common contract and backend-selection factory for config stores | @python.python-developer | None |
| 3 | `dags/medallion_factory/firestore_config_store.py` | Create | Firestore adapter implementing the shared contract | @cloud.gcp-data-architect | 2 |
| 4 | `dags/medallion_factory/mongodb_config_store.py` | Create | MongoDB adapter implementing the shared contract for local/dev use | @python.python-developer | 2 |
| 5 | `dags/medallion_factory/firestore_models.py` | Create | Typed dataclasses for metadata rows, canonical docs, and DAG specs | @python.python-developer | None |
| 6 | `dags/medallion_factory/config_registry.py` | Create | Parse-time grouping by `dag_id` and schedule validation over the shared contract | @data-engineering.airflow-specialist | 2, 5 |
| 7 | `dags/medallion_factory/runtime_config_loader.py` | Create | Runtime helpers/tasks for full config fetch and normalization through the selected adapter | @python.python-developer | 2, 5, 8 |
| 8 | `dags/medallion_factory/config_loader.py` | Modify | Reuse existing parsing/validation rules behind backend-selected inputs instead of YAML paths | @python.python-developer | 5 |
| 9 | `dags/medallion_factory/settings.py` | Modify | Add backend-selection settings plus Firestore/Mongo connection and collection configuration | @python.python-developer | None |
| 10 | `dags/bronze_medallion_dag.py` | Modify | Replace static DAG construction with an import-safe wrapper that delegates to `config_store_medallion_factory.py` and creates no DAGs locally | @data-engineering.airflow-specialist | 1 |
| 11 | `dags/bronze_medallion_monthly_dag.py` | Modify | Replace static DAG construction with an import-safe wrapper that delegates to `config_store_medallion_factory.py` and creates no DAGs locally | @data-engineering.airflow-specialist | 1 |
| 12 | `dags/silver_medallion_dag.py` | Modify | Replace static DAG construction with an import-safe wrapper that delegates to `config_store_medallion_factory.py` and creates no DAGs locally | @data-engineering.airflow-specialist | 1 |
| 13 | `dags/silver_medallion_monthly_dag.py` | Modify | Replace static DAG construction with an import-safe wrapper that delegates to `config_store_medallion_factory.py` and creates no DAGs locally | @data-engineering.airflow-specialist | 1 |
| 14 | `dags/gold_medallion_dag.py` | Modify | Replace static DAG construction with an import-safe wrapper that delegates to `config_store_medallion_factory.py` and creates no DAGs locally | @data-engineering.airflow-specialist | 1 |
| 15 | `dags/gold_medallion_monthly_dag.py` | Modify | Replace static DAG construction with an import-safe wrapper that delegates to `config_store_medallion_factory.py` and creates no DAGs locally | @data-engineering.airflow-specialist | 1 |
| 16 | `scripts/migrate_pipeline_configs_to_firestore.py` | Create | One-time import from YAML to Firestore with completeness checks | @cloud.gcp-data-architect | 3, 5, 8 |
| 17 | `tests/unit/medallion_factory/test_config_store_selection.py` | Create | Unit tests for backend selection and adapter contract wiring | @python.python-developer | 2, 3, 4, 9 |
| 18 | `tests/unit/medallion_factory/test_firestore_config_store.py` | Create | Unit tests for Firestore metadata scan and point-read behavior | @cloud.gcp-data-architect | 3 |
| 19 | `tests/unit/medallion_factory/test_mongodb_config_store.py` | Create | Unit tests for MongoDB metadata scan, `_id` mapping, and point-read behavior | @python.python-developer | 4 |
| 20 | `tests/unit/medallion_factory/test_config_registry.py` | Create | Unit tests for `dag_id` grouping and schedule conflict errors | @data-engineering.airflow-specialist | 5, 6 |
| 21 | `tests/unit/medallion_factory/test_runtime_config_loader.py` | Create | Unit tests for runtime fetch + canonical normalization across adapters | @python.python-developer | 5, 7, 8 |
| 22 | `tests/integration/test_config_store_contract.py` | Create | Integration tests asserting Firestore and Mongo adapters satisfy the same contract surface | @python.python-developer | 3, 4, 6, 7 |
| 23 | `tests/integration/test_firestore_config_migration.py` | Create | Integration tests for YAML-to-Firestore migration completeness | @python.python-developer | 16 |
| 24 | `docs/firestore_pipeline_config_schema.md` | Create | Human-readable canonical Firestore document contract | (general) | 5 |
| 25 | `docs/external_iac_requirements_firestore_pipeline_config_decoupling.md` | Create | Required external infra/IAM handoff artifact because repo-local IaC source is missing | @cloud.gcp-data-architect | None |

**Total Files:** 25

---

## Agent Assignment Rationale

> Agents discovered from `~/.config/opencode/agents/` - Build phase invokes matched specialists.

| Agent | Files Assigned | Why This Agent |
|-------|----------------|----------------|
| @data-engineering.airflow-specialist | 1, 6, 10-15, 20 | Agent explicitly covers Airflow DAG development, event-driven pipeline design, and scheduling behavior. Source: `~/.config/opencode/agents/data-engineering.airflow-specialist.agent.md` |
| @cloud.gcp-data-architect | 3, 16, 18, 25 | Agent explicitly covers GCP data architectures, Cloud Composer, Cloud Run, and IAM-aware cloud patterns. Source: `~/.config/opencode/agents/cloud.gcp-data-architect.agent.md` |
| @python.python-developer | 2, 4-5, 7-9, 17, 19, 21-23 | Agent explicitly covers dataclasses, type hints, parser architecture, adapter contracts, and testable Python data-engineering code. Source: `~/.config/opencode/agents/python.python-developer.agent.md` |
| (general) | 24 | Documentation artifact; no more specialized doc-only workflow agent is required for build output |

**Agent Discovery:**
- Scanned: `~/.config/opencode/agents/**/*airflow*.md`, `~/.config/opencode/agents/**/*gcp*.md`, `~/.config/opencode/agents/**/*python*.md`
- Matched by: file purpose, domain keywords, and DEFINE KB domains (`airflow`, `gcp`)

---

## Code Patterns

### Pattern 1: Common config-store contract and backend selection

**Why this pattern:** the iterate request explicitly rejects a backend design based on only swapping host/connection values. Separate adapters with one shared contract keep backend behavior explicit while preserving one application-facing API.

```python
from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True, slots=True)
class PipelineMetadata:
    pipeline_id: str
    dag_id: str
    schedules: tuple[str, ...]
    layer: str
    collection_name: str


class ConfigStore(Protocol):
    def list_pipeline_metadata(self, collection: str) -> tuple[PipelineMetadata, ...]: ...

    def get_pipeline(self, collection: str, pipeline_id: str) -> dict[str, object]: ...


def build_config_store(settings: Settings) -> ConfigStore:
    if settings.config_backend == "firestore":
        return FirestoreConfigStore(settings)
    if settings.config_backend == "mongodb":
        return MongoDbConfigStore(settings)
    raise ValueError(f"Unsupported MEDALLION_CONFIG_BACKEND={settings.config_backend!r}")
```

**Sources:** user-approved iterate change request in this conversation; DEFINE Constraints on lightweight parse-time behavior.

### Pattern 2: Parse-time metadata scan and DAG spec construction over the shared contract

**Why this pattern:** Adapt the Airflow DAG factory pattern from `airflow/patterns/dag-factory.md` to Firestore metadata rather than YAML files, while keeping parse-time reads lightweight per DEFINE.

```python
from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True, slots=True)
class PipelineMetadata:
    pipeline_id: str
    dag_id: str
    schedules: tuple[str, ...]
    layer: str
    collection_name: str


@dataclass(frozen=True, slots=True)
class DagSpec:
    dag_id: str
    schedules: tuple[str, ...]
    pipeline_ids: tuple[str, ...]
    layers: tuple[str, ...]


class ConfigValidationError(ValueError):
    pass


def build_dag_specs(rows: Iterable[PipelineMetadata]) -> tuple[DagSpec, ...]:
    grouped: dict[str, list[PipelineMetadata]] = defaultdict(list)
    for row in rows:
        grouped[row.dag_id].append(row)

    specs: list[DagSpec] = []
    for dag_id, items in grouped.items():
        schedule_set = {item.schedules for item in items}
        if len(schedule_set) != 1:
            raise ConfigValidationError(
                f"dag_id '{dag_id}' has conflicting schedules: {sorted(schedule_set)}"
            )

        specs.append(
            DagSpec(
                dag_id=dag_id,
                schedules=items[0].schedules,
                pipeline_ids=tuple(sorted(item.pipeline_id for item in items)),
                layers=tuple(sorted({item.layer for item in items})),
            )
        )
    return tuple(sorted(specs, key=lambda spec: spec.dag_id))
```

**Sources:** DEFINE Acceptance Test AT-001 and schedule conflict criterion; Airflow KB `patterns/dag-factory.md`.

### Pattern 3: Runtime full-document fetch before operator execution

**Why this pattern:** Satisfy DEFINE runtime freshness requirements by moving full config reads to task execution time.

```python
from __future__ import annotations

from airflow.decorators import task


@task
def fetch_runtime_config(
    collection_name: str,
    pipeline_id: str,
) -> dict[str, object]:
    config_store = build_config_store(load_settings())
    document = config_store.get_pipeline(
        collection=collection_name,
        pipeline_id=pipeline_id,
    )
    normalized = normalize_canonical_document(document)
    return normalized


# Example operator usage in DAG build logic
runtime_cfg = fetch_runtime_config(
    collection_name="1_Bronze",
    pipeline_id="rel_demonstrativo_titular",
)

CloudRunExecuteJobOperator(
    task_id="launch_runtime_job",
    project_id="{{ ti.xcom_pull(task_ids='fetch_runtime_config')['runtime']['project_id'] }}",
    region="{{ ti.xcom_pull(task_ids='fetch_runtime_config')['runtime']['region'] }}",
    job_name="{{ ti.xcom_pull(task_ids='fetch_runtime_config')['bronze']['cloud_run_job_name'] }}",
    overrides={
        "container_overrides": [
            {
                "name": "ingestao-1",
                "env": [
                    {
                        "name": "PIPELINE_CONFIG_JSON",
                        "value": "{{ ti.xcom_pull(task_ids='fetch_runtime_config') | tojson }}",
                    }
                ],
            }
        ]
    },
)
```

**Sources:** DEFINE Success Criteria and Acceptance Tests AT-002/003/004; Airflow KB recommends TaskFlow as modern default in `quick-reference.md`; user-approved iterate change request in this conversation.

### Pattern 4: Canonical Firestore document shape

**Why this pattern:** preserve existing layer semantics while enforcing the corrected canonical contract independent of backend: `pipeline_id` only in the document identity (`doc.id` in Firestore, `_id` in MongoDB), required `dag_id`/`env`/`schedules[]`, Bronze nested fields sourced from the user-provided full examples, and Silver/Gold nested `silver`/`gold` objects sourced from the current repo YAMLs.

```yaml
# Firestore collection: 1_Bronze
# Firestore document id: rel_demonstrativo_titular   # canonical pipeline_id
dag_id: bronze_medallion
env: dev
schedules:
  - cron: "0 6 26 * *"
    type: incremental_event
comment: "Carga mensal consolidada"
rows_limit: null
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
    pk:
      - id_pagamento
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
    clustering_fields:
      - id_pagamento
compute:
  num_workers: 2
  max_workers: 8
  machine_type: n2-standard-4
metadata:
  source_system: composer_yaml_migration
  migrated_from: dags/config/bronze/rel_demonstrativo_titular_pipeline.yaml
  migrated_at: 2026-06-04T00:00:00Z
```

**Per-collection shape rules:**

- Global
  - required envelope: `dag_id`, `env`, `schedules[]`
  - `pipeline_id` must stay only in document identity (`doc.id` in Firestore, `_id` in MongoDB)
  - `schedules[].cron` is canonical
  - current repo YAML `schedule_frequency` must be translated through `dags/config/schedules.yaml`
  - `1 dag_id = 1 cron`
  - backend adapters must not inject a duplicate `pipeline_id` payload field
- `1_Bronze`
  - final contract source: user-provided Bronze examples in this conversation
  - nested coverage required for `comment`, `rows_limit`, optional `is_golden_gate`, `queries.select_to_bq.select`, `queries.select_to_bq.where`, `tables.origin.*`, `tables.destiny.*`, optional `compute.*`
  - `queries` optional; `compute` optional; `is_golden_gate` optional when present
  - execution type is observed in `schedules[].type`
  - do **not** assume a confirmed top-level `type` field without source
- `2_Silver`
  - required payload shape: nested `silver.included_targets`, nested `silver.assert_targets` (empty/default allowed), top-level `depends_on`
  - preserve current Silver/Dataform semantics from `dags/config/silver/*.yaml`
- `3_Gold`
  - required payload shape: nested `gold.included_targets`, top-level `depends_on`
  - preserve current Gold/Dataform semantics from `dags/config/gold/*.yaml`
  - `included_tags` is **source not found** in current local YAMLs and must be treated only as future extension if reintroduced later

**Canonical examples to keep aligned across docs:**

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

**Sources:** DEFINE Schema Contract, Completeness Metrics, Lineage Requirements; current Dataform config shapes in `dags/config/silver/*.yaml` and `dags/config/gold/*.yaml`; current parser baseline in `dags/medallion_factory/config_loader.py`; user-approved iterate change request for the final Firestore schema and backend abstraction.

---

## Data Flow

```text
1. Airflow imports `dags/config_store_medallion_factory.py`
   │   Source: Airflow DAG factory pattern + DEFINE AT-001
   ▼
2. Factory resolves `MEDALLION_CONFIG_BACKEND` and builds the matching adapter
   │   `firestore` for target/prod; `mongodb` for local/dev/tests
   ▼
3. Factory queries metadata across `1_Bronze`, `2_Silver`, `3_Gold`
   │   Reads only DAG-construction fields through `list_pipeline_metadata(collection)`
   ▼
4. Registry validates one `dag_id` -> one schedule definition
   │   On conflict, raise `ConfigValidationError` and stop DAG generation
   ▼
5. Factory creates one DAG object per valid `dag_id`
   │   Each DAG contains per-pipeline runtime config fetch tasks
   ▼
6. Runtime task point-reads full canonical document by `pipeline_id`
   │   Latest saved document is normalized into typed config
   ▼
7. Downstream operator executes
   │   Bronze -> Cloud Run/Dataflow
   │   Silver/Gold -> Dataform
   ▼
8. Structured logs and metrics record backend, config source, latency, and failures
```

---

## Integration Points

| External System | Integration Type | Authentication |
|-----------------|-----------------|----------------|
| Firestore Native Mode | Python client for metadata scans and document point-reads | Composer service account with least-privilege Firestore read access; exact role source not found in loaded KB and must be confirmed externally |
| MongoDB | Python client for temporary/local metadata scans and point-reads | Local/dev connection string or test container; no production authority |
| Cloud Run / Dataflow path | Existing Airflow Google provider operator invocation | Existing GCP connection + runtime service identity from current DAG model |
| Dataform | Existing Airflow Dataform operators | Existing GCP connection + Dataform service account fields in canonical config |
| Firebase Console | Human config editing surface | Out-of-scope auth redesign; governed operationally per DEFINE |
| External IaC repository | Firestore enablement + IAM bindings | External ownership, repo path unresolved in DEFINE |

---

## Testing Strategy

| Test Type | Scope | Files | Tools | Coverage Goal |
|-----------|-------|-------|-------|---------------|
| Unit | Backend selection, Firestore adapter, Mongo adapter, registry validation, runtime normalization | `tests/unit/medallion_factory/test_config_store_selection.py`, `test_firestore_config_store.py`, `test_mongodb_config_store.py`, `test_config_registry.py`, `test_runtime_config_loader.py` | pytest | 90% of new Python modules |
| Integration | YAML migration plus shared adapter contract compliance | `tests/integration/test_config_store_contract.py`, `test_firestore_config_migration.py` | pytest + Firestore fakes/mocks + Mongo test container/fakes | All acceptance-path adapters |
| DAG parse | Factory imports and schedule conflict failure | `tests/unit/medallion_factory/test_config_registry.py` plus import tests | pytest | All supported `dag_id` patterns |
| E2E | Backend-selected edit -> next run picks change without redeploy | Manual or environment-backed validation runbook | manual / staged env | AT-004 happy path |

**Sources:** DEFINE Acceptance Tests; Airflow KB `patterns/error-handling.md` for failure-focused validation emphasis.

---

## Local Validation Boundary

| Validation Scope | Can Be Validated Locally with `MEDALLION_CONFIG_BACKEND=mongodb` | Still Requires Real Firestore/IAM |
|------------------|---------------------------------------------------------------|-----------------------------------|
| DAG discovery contract | Yes - metadata scanning, `dag_id` grouping, schedule conflict failures | No |
| Canonical payload normalization | Yes - backend-independent contract and schema validation | No |
| Mongo collection mapping | Yes - `1_Bronze` / `2_Silver` / `3_Gold` with `_id = pipeline_id` | No |
| Adapter selection behavior | Yes - explicit env-driven backend switch | No |
| Runtime task wiring | Yes - TaskFlow/XCom path and operator templating | No |
| Firestore SDK behavior | No | Yes - exact client behavior, collection streaming, and point-read semantics |
| Composer service-account auth | No | Yes - real identity and IAM bindings |
| Firebase Console operational edit flow | No | Yes - end-to-end target behavior in the actual GCP environment |
| Production latency targets | Partially - relative checks only | Yes - actual Firestore/network path in environment |

**Flag to use in local tests:** `MEDALLION_CONFIG_BACKEND=mongodb`

**Sources:** user-approved iterate change request in this conversation; DEFINE Constraints and Acceptance Test AT-004.

---

## Error Handling

| Error Type | Handling Strategy | Retry? |
|------------|-------------------|--------|
| Firestore metadata scan transient failure | Fail DAG parse loudly; use bounded client retries but do not silently skip DAGs | Yes, bounded client retry only |
| `dag_id` schedule conflict | Raise `ConfigValidationError` during parse and block DAG generation for that invalid group | No |
| Runtime document missing by `pipeline_id` | Fail runtime fetch task with explicit pipeline and collection context | No |
| Unsupported backend selection | Fail fast during settings/config-store bootstrap with the invalid backend name | No |
| Runtime document schema mismatch | Normalize/validate and raise typed parse error before Cloud Run/Dataform invocation | No |
| Cloud Run/Dataform transient operator failure | Keep existing operator retry semantics and exponential backoff where appropriate | Yes |
| Migration import mismatch | Record diff summary and fail migration command until missing docs are resolved | No |

**Sources:** current repo exception style in `config_loader.py`; Airflow KB `patterns/error-handling.md`; DEFINE Acceptance Test AT-005.

---

## Configuration

| Config Key | Type | Default | Description |
|------------|------|---------|-------------|
| `MEDALLION_FIRESTORE_PROJECT_ID` | string | `DEFAULT_PROJECT_ID` fallback | Firestore project used by catalog client |
| `MEDALLION_FIRESTORE_DATABASE` | string | `(default)` | Firestore database name if non-default databases are later adopted |
| `MEDALLION_FIRESTORE_COLLECTION_BRONZE` | string | `1_Bronze` | Bronze collection name |
| `MEDALLION_FIRESTORE_COLLECTION_SILVER` | string | `2_Silver` | Silver collection name |
| `MEDALLION_FIRESTORE_COLLECTION_GOLD` | string | `3_Gold` | Gold collection name |
| `MEDALLION_CONFIG_BACKEND` | string | `firestore` | Selects `firestore` or `mongodb`; use `mongodb` for local/dev/tests |
| `MEDALLION_MONGODB_URI` | string | none | MongoDB connection string for temporary/local backend |
| `MEDALLION_MONGODB_DATABASE` | string | `medallion_config` | MongoDB database name for temporary/local backend |
| `MEDALLION_FIRESTORE_METADATA_FIELDS` | list[string] | `dag_id,schedules` | Parse-time metadata field allowlist; `pipeline_id` comes from Firestore document id and layer comes from collection context |
| `MEDALLION_CONFIG_SOURCE` | string | derived from selected backend | Explicit source marker for observability and migration cutover |

**Sources:** DEFINE Goals/Constraints and required collection names.

---

## Security Considerations

- Composer/ Airflow must use least-privilege service-account access for Firestore reads; broad project-wide editor roles are explicitly discouraged by GCP IAM guidance. Source: `~/.config/opencode/kb/gcp/concepts/iam.md`.
- No credentials or Firestore connection material should be hardcoded in DAG code; environment and platform identity should remain the boundary. Source: GCP quick reference common pitfalls.
- Firebase Console editing auth redesign is out of scope; design only assumes authorized operators can edit documents. Source: DEFINE Out of Scope.
- Canonical documents should remain non-PII based on DEFINE schema contract, but migration validation must preserve that assumption. Source: DEFINE Schema Contract.

---

## Observability

| Aspect | Implementation |
|--------|----------------|
| Logging | Structured logs with `dag_id`, `pipeline_id`, `collection_name`, `config_backend`, `config_source`, and fetch latency |
| Metrics | Parse-time metadata scan count, parse-time latency, runtime point-read latency, schedule conflict count, migration completeness count |
| Tracing | Optional per-fetch timing spans around Firestore metadata scan and runtime document read |

**Sources:** DEFINE Success Criteria on latency/freshness; existing logging context pattern in `dags/medallion_factory/settings.py`.

---

## Pipeline Architecture

> Included because the feature changes pipeline orchestration and config delivery for ETL workloads.

### DAG Diagram

```text
 [Firestore or Mongo 1_Bronze] --metadata--> [DAG Factory] --creates--> [bronze_* DAGs]
 [Firestore or Mongo 2_Silver] --metadata--> [DAG Factory] --creates--> [silver_* DAGs]
 [Firestore or Mongo 3_Gold]   --metadata--> [DAG Factory] --creates--> [gold_* DAGs]
                                         │
                                         ▼
                              [Runtime config fetch task]
                                 │             │
                                 ▼             ▼
                         [Cloud Run/Dataflow] [Dataform]
```

### Partition Strategy

| Table | Partition Key | Granularity | Rationale |
|-------|---------------|-------------|-----------|
| `1_Bronze` | `pipeline_id` (document id) | N/A | One canonical config per Bronze pipeline; preserves current identity model from DEFINE |
| `2_Silver` | `pipeline_id` (document id) | N/A | Same identity rule across layers |
| `3_Gold` | `pipeline_id` (document id) | N/A | Same identity rule across layers |

### Incremental Strategy

| Model | Strategy | Key Column | Lookback |
|-------|----------|------------|----------|
| Parse-time metadata discovery | Full metadata scan across active docs through selected adapter | `dag_id`, `pipeline_id` | None |
| Runtime config fetch | Point-read by unique key | `pipeline_id` | Latest only |
| Local backend validation | Mongo point-read by `_id` using canonical contract | `pipeline_id` | Latest only |
| Migration import | Upsert by document id | `pipeline_id` | Repeatable/idempotent reruns |

### Schema Evolution Plan

| Change Type | Handling | Rollback |
|-------------|----------|----------|
| New optional field | Add to canonical doc and normalization model with defaults | Stop reading field; leave stored data intact |
| New required field | Add validation rule, backfill existing docs before cutover | Revert validator requirement and backfill script |
| Layer-specific shape change | Version normalization logic in parser boundary, not DAG files | Revert parser mapping only |
| Column removal from source YAML | Deprecate in schema doc, verify no DAG/operator dependency before removal | Keep field in parser as optional |

### Data Quality Gates

| Gate | Tool | Threshold | Action on Failure |
|------|------|-----------|-------------------|
| Required metadata fields present | unit/integration tests | 0 missing document ids (`pipeline_id`), `dag_id`, `env`, `schedules[]` | Block build/validate |
| No duplicated `pipeline_id` field in payload | unit/integration tests | 0 violations | Block build/validate |
| One `dag_id` -> one schedule | registry validation | 100% compliance | Block DAG parse |
| Migration completeness | migration integration test | 100% source docs imported | Block cutover |
| Runtime fetch freshness | staged validation run | next run uses latest edited doc | Block go-live |

---

## Risks and Open Design Notes

| Risk | Impact | Mitigation | Source |
|------|--------|------------|--------|
| External IaC repo unresolved | Production rollout can stall after code is ready | Deliver explicit infra handoff doc and validate ownership before build completion | DEFINE Open Questions |
| Firestore SDK metadata projection shape not explicitly documented in loaded KB | Build may need a small implementation adjustment for exact query API | Keep design at metadata-only intent level and validate concrete SDK call during build | Source not found in loaded KB; Firestore docs only validated collection streaming and document point-read |
| Dynamic DAG inventory may surface previously hidden config drift | Scheduler import can fail until invalid configs are fixed | Fast-fail registry validation with actionable error text | DEFINE AT-005 |
| Adapter drift between Mongo local behavior and Firestore target behavior | Local success could mask target-backend incompatibilities | Require shared contract integration tests and separate real-Firestore validation evidence | user-approved iterate change request in this conversation |

---

## Validation Contract

> This section is read by `/workflow:validate` at Phase 3.5. The DEFINE contains goals and acceptance tests but no explicit requirement IDs, so the IDs below are derived from the DEFINE Goals section for traceability.
>
> **Scope rule for this iteration:** all current DEFINE goals are treated as mandatory for build and validation scope, including goals marked `SHOULD` in the DEFINE priority table. No goal-derived requirement in this section may be deferred as optional implementation work.

### Spec Junta Targets (alignment + architecture)

| Requirement ID | Description | Expected Evidence in Code |
|----------------|-------------|---------------------------|
| D-REQ-001 | Replace Composer-bucket YAML discovery with a Firestore-backed canonical configuration store for Bronze, Silver, and Gold pipelines. | `dags/config_store_medallion_factory.py`, `config_store.py`, `firestore_config_store.py`, `config_registry.py` |
| D-REQ-002 | Allow config changes through Firebase Console or equivalent UI without Composer redeploy. | Runtime point-read path in `runtime_config_loader.py`; no YAML read path in active DAG creation |
| D-REQ-003 | Airflow performs lightweight parse-time discovery and full runtime point-reads from Firestore. | Metadata scan in `config_registry.py`; full doc fetch task in `runtime_config_loader.py` |
| D-REQ-004 | Dataflow consumes the same canonical pipeline configuration payload Airflow uses. | Bronze runtime fetch task + Cloud Run/Dataflow operator templating in generated DAG builder |
| D-REQ-005 | Preserve layer separation through `1_Bronze`, `2_Silver`, and `3_Gold`. | Collection constants and routing logic in `settings.py` / adapter implementations |
| D-REQ-006 | Migrate existing YAML configurations into Firestore without data loss or schema regression. | `scripts/migrate_pipeline_configs_to_firestore.py` + migration integration test |
| D-REQ-007 | Enforce one `dag_id` maps to one schedule definition, failing fast during parse when violated. | `ConfigValidationError` raised by `config_registry.py` with schedule conflict tests |
| D-REQ-008 | Every canonical pipeline config document includes the operational `env` field. | Canonical model validation in `firestore_models.py` / runtime normalization |
| D-REQ-009 | Firestore document id is the canonical `pipeline_id`, and documents must not duplicate `pipeline_id` inside the payload. | Catalog/runtime loader derives identity from `doc.id` and rejects duplicated payload field |
| D-REQ-010 | Bronze preserves the agreed evolved nested Dataflow schema; Silver/Gold preserve current nested `silver`/`gold` Dataform schema plus the Firestore orchestration envelope. | Layer-specific models and validation paths exist in `firestore_models.py` / `runtime_config_loader.py` |
| D-REQ-011 | Config-store access must go through separate adapters with a common contract `list_pipeline_metadata(collection)` and `get_pipeline(collection, pipeline_id)`. | `config_store.py`, Firestore adapter, Mongo adapter, and contract tests |
| D-REQ-012 | MongoDB local/dev support must map collections `1_Bronze` / `2_Silver` / `3_Gold` with `_id = pipeline_id` while keeping the canonical payload contract unchanged. | `mongodb_config_store.py`, local contract tests, runtime normalization that rejects duplicated payload `pipeline_id` |

**Architecture decisions to verify:**

| Decision | Expected Pattern in Code |
|----------|--------------------------|
| Firestore-only canonical config store | Active DAG creation code reads Firestore, not local YAML directories |
| Split parse-time metadata from runtime full reads | Separate metadata scan function and runtime point-read task exist |
| DAG factory replaces static per-layer construction | One factory module emits DAGs from grouped `dag_id` metadata |
| Typed normalization boundary preserved | Dataclass/Python model layer exists between Firestore payloads and operators |
| `pipeline_id` only in document id | No runtime model requires duplicated payload field; loaders derive identity from Firestore doc id |
| External IaC explicitly tracked | Handoff document exists and validation notes unresolved external dependency if not delivered |
| Backend selection is explicit | One backend-selection setting resolves dedicated adapters instead of connection-string-only branching |

---

### Code Junta Targets (quality + devops)

| Dimension | Expectation |
|-----------|-------------|
| Type hints | All new Python functions and dataclasses use full type annotations |
| Error handling | Firestore access and normalization failures raise explicit typed errors with `pipeline_id`/collection context |
| Test coverage | Unit tests for backend selection, both adapters, registry, runtime normalization; integration tests for contract compliance and migration completeness |
| DevOps | No secrets in code; dependencies declared; external IaC handoff artifact present for Firestore/IAM changes |
| Security | No hardcoded credentials; Firestore access relies on service identity; least privilege documented |

---

### Delivery Junta Targets (manifest completeness)

All files in the File Manifest above are expected to exist in the code tree at build time.

| File | Delivery Status at Design Time |
|------|--------------------------------|
| `dags/config_store_medallion_factory.py` | Planned |
| `dags/medallion_factory/config_store.py` | Planned |
| `dags/medallion_factory/firestore_config_store.py` | Planned |
| `dags/medallion_factory/mongodb_config_store.py` | Planned |
| `dags/medallion_factory/firestore_models.py` | Planned |
| `dags/medallion_factory/config_registry.py` | Planned |
| `dags/medallion_factory/runtime_config_loader.py` | Planned |
| `dags/medallion_factory/config_loader.py` | Planned |
| `dags/medallion_factory/settings.py` | Planned |
| `dags/bronze_medallion_dag.py` | Planned |
| `dags/bronze_medallion_monthly_dag.py` | Planned |
| `dags/silver_medallion_dag.py` | Planned |
| `dags/silver_medallion_monthly_dag.py` | Planned |
| `dags/gold_medallion_dag.py` | Planned |
| `dags/gold_medallion_monthly_dag.py` | Planned |
| `scripts/migrate_pipeline_configs_to_firestore.py` | Planned |
| `tests/unit/medallion_factory/test_config_store_selection.py` | Planned |
| `tests/unit/medallion_factory/test_firestore_config_store.py` | Planned |
| `tests/unit/medallion_factory/test_mongodb_config_store.py` | Planned |
| `tests/unit/medallion_factory/test_config_registry.py` | Planned |
| `tests/unit/medallion_factory/test_runtime_config_loader.py` | Planned |
| `tests/integration/test_config_store_contract.py` | Planned |
| `tests/integration/test_firestore_config_migration.py` | Planned |
| `docs/firestore_pipeline_config_schema.md` | Planned |
| `docs/external_iac_requirements_firestore_pipeline_config_decoupling.md` | Planned |

**Acceptance criteria mapping** (from DEFINE → delivery evidence):

| Acceptance Test | Delivered By |
|-----------------|--------------|
| AT-001 Parse-time DAG discovery | `tests/unit/medallion_factory/test_config_registry.py` |
| AT-002 Runtime config fetch for Bronze | `tests/unit/medallion_factory/test_runtime_config_loader.py` |
| AT-003 Runtime config fetch for Silver/Gold | `tests/unit/medallion_factory/test_runtime_config_loader.py` |
| AT-004 No redeploy config update | staged validation procedure in runbook / manual validation after build |
| AT-005 Schedule contract violation | `tests/unit/medallion_factory/test_config_registry.py` |
| AT-006 Migration completeness | `tests/integration/test_firestore_config_migration.py` |
| AT-007 No duplicated `pipeline_id` field | `tests/unit/medallion_factory/test_runtime_config_loader.py` + migration validation |
| AT-008 Required orchestration envelope | `tests/unit/medallion_factory/test_config_registry.py` + `test_runtime_config_loader.py` |
| AT-009 Bronze evolved schema | `tests/unit/medallion_factory/test_runtime_config_loader.py` |
| AT-010 Silver/Gold layer-specific schema | `tests/unit/medallion_factory/test_runtime_config_loader.py` |
| Local adapter contract parity | `tests/integration/test_config_store_contract.py` |
| Mongo `_id = pipeline_id` mapping | `tests/unit/medallion_factory/test_mongodb_config_store.py` |

---

### Score Targets

| Junta | Minimum Score | Zero Tolerance |
|-------|---------------|----------------|
| Spec (alignment) | ≥ 90 | CRITICAL findings |
| Spec (architecture) | ≥ 90 | CRITICAL findings |
| Code (quality) | ≥ 90 | CRITICAL findings |
| Code (devops) | ≥ 70 | secrets in code |
| Delivery (delta) | ≥ 90 | MISSING requirements |
| **Overall** | **≥ 90** | **0 CRITICAL** |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-06-04 | design-agent | Initial version |
| 1.1 | 2026-06-04 | iterate-agent | Cascaded the final Firestore schema contract: explicit `1_Bronze`/`2_Silver`/`3_Gold` shapes, Document ID = `pipeline_id`, no duplicated `pipeline_id` field, required `dag_id`/`env`/`schedules[]`, and `1 dag_id = 1 cron` |
| 1.2 | 2026-06-04 | iterate-agent | Refined the final contract with full nested Bronze fields from the user-provided examples, corrected Silver/Gold to nested `silver`/`gold` objects plus top-level `depends_on`, translated legacy `schedule_frequency` to `schedules[]`, and marked Gold `included_tags` as source not found / future extension |
| 1.3 | 2026-06-04 | iterate-agent | Aligned DESIGN to the updated DEFINE by treating every DEFINE goal as mandatory build scope, restricting parse-time metadata to `dag_id` + `schedules`, and removing optional wording from implementation-critical deliverables |
| 1.4 | 2026-06-04 | iterate-agent | Added a backend-selected config-store abstraction for local development: explicit Firestore and MongoDB adapters with a shared contract, Mongo `_id = pipeline_id` mapping, env-based backend selection, and a local-vs-real-Firestore validation boundary while keeping the canonical document contract unchanged |

---

## Next Step

**Ready for:** `/workflow:build ~/.config/opencode/sdd/features/firestore-pipeline-config-decoupling/DESIGN_FIRESTORE_PIPELINE_CONFIG_DECOUPLING.md`
