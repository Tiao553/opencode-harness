# DEFINE: Observability Hub

> Fabric-native observability hub that unifies ODI, ETLTOOLS, Elastic `NOT_STARTED`, and Power BI operational evidence into canonical Gold facts with a notebook-and-pipeline-first implementation.

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | OBSERVABILITY_HUB |
| **Date** | 2026-06-10 |
| **Author** | iterate-agent |
| **Status** | ✅ Complete (Designed) |
| **Clarity Score** | 15/15 |
| **Change Type** | Modifying |
| **Primary Content Source** | `docs/` in this repository |

---

## Canonical Sources

| Source | Role in this DEFINE |
|--------|---------------------|
| `docs/discovery/contrato_canonico.md` | Canonical Gold facts, mandatory fields, lifecycle rules, and source-specific derivation logic |
| `docs/discovery/arquitetura_de_dados.md` | Canonical medallion flow, ingestion topology, and Fabric execution model |
| `docs/architecture/gold_serving_decision.md` | Confirms Gold Lakehouse on Delta as the authoritative Gold store for this phase |
| `docs/architecture/onelake_organization.md` | Governs layer separation, naming, and table-placement discipline |
| `docs/architecture/fabric_setup.md` | Setup sequence, connection discipline, and bootstrap boundaries |
| `docs/architecture/fabric_environment_topology.md` | Fixed DEV/HOMOLOG/PROD workspace topology prepared one workspace at a time |
| `Deploy_FUAM.ipynb` | Notebook bootstrap reference for `%pip install ms-fabric-cli`, workspace discovery, and connection provisioning patterns |
| `docs/security/secrets_rotation_policy.md` | Secret-handling guardrails for connections and notebook execution |
| `docs/security/rbac_matrix.md` | Operational personas and least-privilege access boundaries |
| `docs/operations/slo_sla_operacional.md` | Freshness and operational timing targets |
| `docs/operations/alerting_matrix.md` | Minimum alert/evidence semantics used as reference only |
| `docs/runbooks/*.md` | Recovery expectations and correction-path intent |
| User iteration request via `/workflow:iterate` on 2026-06-10 | Simplification constraint: detailed docs, narrow implementation scope |

---

## Executive Summary

The business problem is unchanged: operations still need one reliable place to answer what executed, what failed, and where to go next for correction. What changed in this iteration is the delivery stance.

This phase keeps the solution:

- Microsoft Fabric only
- OneLake + Delta only
- Bronze → Silver → Gold unchanged
- Gold contract-driven
- Spark SQL-first for schema creation and materialization
- `notebookutils`-based for runtime context inside notebooks
- notebook-scoped bootstrap setup may use `%pip install ms-fabric-cli` only when provisioning is required
- basic operational visibility only

This phase explicitly defers:

- CI/CD rollout
- FUAM-style operating expansion
- standalone Fabric CLI-centered day-2 operations
- advanced KQL/alert-pack implementation as build scope
- broader governance and monitoring estates beyond what is needed to run and inspect notebooks and pipelines

**Sources:** `docs/discovery/contrato_canonico.md` §1–§6; `docs/discovery/arquitetura_de_dados.md` §1–§3; `Deploy_FUAM.ipynb`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Problem Statement

Operations need a single operational view that answers three questions reliably:

1. what executed or failed to start,
2. what is in error and for how long,
3. where the operator should go to correct it.

Previous working documents accumulated too much rollout and platform-program complexity for the current phase. This phase must produce the smallest Fabric implementation that still honors the canonical contract, medallion structure, source-specific nuances, and operator auditability.

**Sources:** `docs/discovery/contrato_canonico.md` §1; `docs/discovery/arquitetura_de_dados.md` §1–§3; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Target Users

| User | Role | Pain Point |
|------|------|------------|
| Operations / On-call | Incident response and first-line triage | Needs one place to see execution failures, active errors, and the next correction target |
| Data / Platform Engineers | Root-cause analysis and pipeline reliability | Needs source-safe lineage across ODI, ETLTOOLS, Elastic, and Power BI without manual correlation |
| Service / Domain Owners | Responsible follow-up on recurring failures and SLA breaches | Needs contract-safe evidence, correction links, and ownership context to act quickly |

**Sources:** `docs/security/rbac_matrix.md`; `docs/operations/slo_sla_operacional.md`; `docs/runbooks/odi_failure.md`; `docs/runbooks/etltools_not_started.md`; `docs/runbooks/powerbi_credential.md`.

---

## Goals

What success looks like (prioritized):

| Priority | Goal |
|----------|------|
| **MUST** | Preserve Bronze/Silver/Gold exactly as the structural backbone |
| **MUST** | Keep Gold aligned to `docs/discovery/contrato_canonico.md` |
| **MUST** | Center implementation on Fabric notebooks and Fabric Data Factory pipelines |
| **MUST** | Use Spark SQL as the default language for DDL and layer materialization |
| **MUST** | Require `notebookutils` for notebook runtime parameters and context |
| **MUST** | Support notebook-scoped bootstrap setup for environment preparation, including `%pip install ms-fabric-cli`, connection validation/creation, and current-workspace resolution when provisioning is required |
| **MUST** | Keep Bronze notebooks thin: extract, stamp metadata, persist raw rows, audit |
| **MUST** | Keep auditability through `stg_ingestion_audit` and contract timestamps/flags |
| **SHOULD** | Use Fabric-native function and variable objects only when repetition makes them simpler than inline logic |
| **SHOULD** | Keep day-2 runtime operable from Fabric UI after bootstrap without a separate shell-first workflow |
| **COULD** | Add broader monitoring, CI/CD, deployment automation, and richer serving surfaces later |

**Priority Guide:**
- **MUST** = MVP fails without this
- **SHOULD** = Important, but workaround exists
- **COULD** = Nice-to-have, cut first if needed

**Sources:** `docs/discovery/arquitetura_de_dados.md` §1–§4; `docs/architecture/gold_serving_decision.md`; `docs/architecture/fabric_setup.md` §Phase 3–§Phase 5; `Deploy_FUAM.ipynb`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Architectural Invariants

1. **Platform invariant:** the feature runs only on Microsoft Fabric.
2. **Storage invariant:** managed data lives in OneLake-backed Delta tables.
3. **Layer invariant:** Bronze, Silver, and Gold remain distinct layers.
4. **Contract invariant:** `fct_execution_event` and `fct_error_event` remain canonical Gold outputs.
5. **Serving invariant:** Gold stays authoritative in the Gold Lakehouse for this phase.
6. **Operating invariant:** notebooks and Fabric Data Factory pipelines remain the primary execution model.
7. **Scope invariant:** this iteration cannot reintroduce CI/CD, FUAM rollout, standalone Fabric CLI-centered operations, or advanced monitoring as required build scope.
8. **Interpretation invariant:** documentary detail does not broaden build scope unless the document explicitly says the phase must create the asset.

**Sources:** `docs/discovery/arquitetura_de_dados.md` §1–§3; `docs/architecture/gold_serving_decision.md`; `docs/architecture/onelake_organization.md`; `Deploy_FUAM.ipynb`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Functional Requirements

### FR Group 1 — Platform and Topology

- **FR-01** — The solution shall run only on Microsoft Fabric.
- **FR-02** — The solution shall use separate Bronze, Silver, and Gold lakehouse layers according to the medallion organization.
- **FR-03** — Gold shall remain the authoritative curated layer and shall be stored as Delta-backed Fabric tables.
- **FR-04** — Gold naming and schema decisions shall stay compatible with the accepted Gold serving decision.

### FR Group 2 — Bronze Ingestion

- **FR-05** — Bronze shall include raw staging for ODI execution and error evidence.
- **FR-06** — Bronze shall include raw staging for ETLTOOLS Oracle lot/error evidence.
- **FR-07** — Bronze shall include raw staging for ETLTOOLS `NOT_STARTED` evidence from Elastic.
- **FR-08** — Bronze shall include raw staging for Power BI refresh/status evidence.
- **FR-09** — Bronze writes shall add only ingestion metadata needed for auditability such as `fabric_pipeline_run_id`, `collected_at`, and `ingestion_date`.
- **FR-10** — Bronze shall not apply business normalization beyond metadata stamping and safe typing required to persist the raw payload.

### FR Group 3 — Silver Normalization

- **FR-11** — Silver shall normalize source timestamps into contract-compatible time semantics.
- **FR-12** — Silver shall normalize source execution statuses into canonical statuses.
- **FR-13** — Silver shall preserve the ETLTOOLS split between started executions (Oracle SQL path) and `NOT_STARTED` errors (Elastic path).
- **FR-14** — Silver shall apply deduplication in the normalization boundary, not in Bronze.
- **FR-15** — Silver shall preserve enough lineage to derive `correction_url`, `detected_at`, `resolved_at`, and related operational fields in Gold.

### FR Group 4 — Gold Contract Outputs

- **FR-16** — Gold shall materialize `fct_execution_event` according to the canonical contract.
- **FR-17** — Gold shall materialize `fct_error_event` according to the canonical contract.
- **FR-18** — Gold shall materialize a simplified snapshot/reporting surface for operational consumption.
- **FR-19** — Gold shall materialize a completeness/status surface driven by ingestion evidence and lightweight expected-count inputs where needed.
- **FR-20** — Gold shall preserve lifecycle semantics for `open_flag`, `resolved_at`, `time_to_detect_ms`, and `time_in_error_ms`.
- **FR-21** — Gold shall propagate a valid `correction_url` strategy for ODI, ETLTOOLS, Elastic `NOT_STARTED`, and Power BI.

### FR Group 5 — Orchestration and Setup

- **FR-22** — The phase shall include a notebook-scoped bootstrap path for environment preparation that may begin with `%pip install ms-fabric-cli` when item provisioning or update is required.
- **FR-23** — The bootstrap path shall acquire transient session tokens from `notebookutils` and expose them only to the notebook session for Fabric CLI commands.
- **FR-24** — The bootstrap path shall validate or create approved Fabric workspace connections while keeping logical connection names stable per environment.
- **FR-25** — The bootstrap path shall resolve the current workspace dynamically before importing, updating, or organizing environment-bound Fabric items.
- **FR-26** — Setup notebooks shall create Bronze, Silver, and Gold schemas primarily through Spark SQL.
- **FR-27** — The phase shall use Fabric Data Factory pipelines as the normal orchestration surface for source collection and Gold materialization.
- **FR-28** — The minimum core pipeline set shall remain limited to ODI collection, ETLTOOLS collection, Power BI collection, and Gold materialization.
- **FR-29** — Each pipeline run shall be auditable through a stable run identifier and a corresponding ingestion-audit record.

### FR Group 6 — Operational Evidence

- **FR-30** — The design shall expose enough evidence in core data artifacts and Fabric runtime history for runbook-driven triage without requiring extra monitoring platforms in this phase.
- **FR-31** — The design shall support inspection of failed runs through Fabric UI plus lakehouse tables.
- **FR-32** — The design shall preserve per-source evidence needed by the runbooks, including identifiers, timestamps, and correction targets.

**Sources:** `docs/discovery/contrato_canonico.md` §2–§6; `docs/discovery/arquitetura_de_dados.md` §2–§5; `docs/architecture/onelake_organization.md`; `docs/architecture/fabric_setup.md`; `docs/architecture/fabric_environment_topology.md`; `Deploy_FUAM.ipynb`; `docs/runbooks/*.md`.

---

## Non-Functional Requirements

### NFR Group 1 — Simplicity and Maintainability

- **NFR-01** — The build shall prefer explicit source-specific notebooks over generalized frameworks.
- **NFR-02** — Bronze notebooks shall remain short enough that an operator can understand their full control flow quickly in Fabric UI.
- **NFR-03** — Shared code/config shall be introduced only where reuse is clear, repeated, and simpler than inline logic.

### NFR Group 2 — Runtime and Security Discipline

- **NFR-04** — No secrets shall be embedded in notebooks, JSON artifacts, or Markdown files.
- **NFR-05** — Notebooks shall reference approved Fabric connections or equivalent secret-backed runtime patterns.
- **NFR-06** — The design shall remain compatible with least-privilege and promotion-only production access.

### NFR Group 3 — Observability Boundaries

- **NFR-07** — This phase shall provide basic operational visibility through pipeline history, notebook results, `stg_ingestion_audit`, and Gold status outputs.
- **NFR-08** — Advanced KQL packs, broad alert routing, and expanded observability engineering are deferred and shall not become build prerequisites in this phase.

### NFR Group 4 — Performance and Freshness Targets

- **NFR-09** — Bronze availability should stay within the published operational windows.
- **NFR-10** — Gold availability should stay within the published operational windows.
- **NFR-11** — The design should support per-window completeness tracking using lightweight expected-count inputs where needed.

**Sources:** `docs/discovery/arquitetura_de_dados.md` §1–§5; `docs/architecture/fabric_setup.md`; `docs/security/secrets_rotation_policy.md`; `docs/security/rbac_matrix.md`; `docs/operations/slo_sla_operacional.md`; `docs/operations/alerting_matrix.md`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Success Criteria

Measurable outcomes:

- [ ] Bronze evidence from all 4 target source surfaces is available within **30 minutes** of each collection window.
- [ ] Gold required outputs (`fct_execution_event`, `fct_error_event`, snapshot, completeness) are available within **60 minutes** of the planned Gold materialization window.
- [ ] **100%** of `NOT_STARTED` Gold rows keep `execution_event_id IS NULL`, `run_id IS NULL`, and `server_name` populated.
- [ ] **0** secrets are persisted in notebooks, JSON artifacts, or Markdown documentation.
- [ ] Mandatory contract fields for required Gold facts show **0 nulls** in sampled validation queries for identifiers and lifecycle timestamps.
- [ ] Operators can navigate from a Gold error/execution record to a correction target in **2 steps or fewer**.
- [ ] Normal phase operation requires no more than **4 core pipelines** and no standalone CLI workflow after bootstrap.

**Sources:** `docs/discovery/contrato_canonico.md`; `docs/discovery/arquitetura_de_dados.md`; `docs/operations/slo_sla_operacional.md`; `docs/runbooks/*.md`; `Deploy_FUAM.ipynb`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Acceptance Tests

| ID | Scenario | Given | When | Then |
|----|----------|-------|------|------|
| AT-001 | Bronze collector readability | A Bronze notebook for one source | An engineer opens it in Fabric | The flow is visibly limited to parameters → extract → metadata → raw write → audit |
| AT-001A | Bootstrap setup path | A fresh environment workspace with approved credentials available | The bootstrap notebook runs | It installs `ms-fabric-cli` only in-session, resolves the current workspace, and validates or creates the required logical Fabric connections without embedded secrets |
| AT-002 | Medallion preservation | A fresh Fabric setup | Setup notebooks run | Bronze, Silver, and Gold are created as separate layer-aligned assets |
| AT-003 | Spark SQL setup | Empty target schemas | Setup notebooks execute | Table creation happens primarily via Spark SQL DDL |
| AT-004 | ODI contract path | ODI Bronze and Silver data exist | Gold materialization runs | ODI events land correctly in `fct_execution_event` and `fct_error_event` |
| AT-005 | ETLTOOLS started-execution path | ETLTOOLS Oracle evidence exists | Silver and Gold run | SQL-path ETLTOOLS rows become execution/error facts with valid lineage |
| AT-006 | ETLTOOLS NOT_STARTED path | Elastic `NOT_STARTED` evidence exists | Silver and Gold run | Gold emits `fct_error_event` rows with `execution_event_id IS NULL`, `run_id IS NULL`, and `server_name` populated |
| AT-007 | Power BI credential/error path | Power BI refresh evidence exists | Gold materialization runs | Power BI failures classify into Gold facts with correction targeting intact |
| AT-008 | Basic operability | A pipeline run succeeds or fails | Operator checks Fabric UI and audit tables | Outcome is understandable without external observability tooling |
| AT-009 | Scope guard | The feature is deployed for this phase | Operators run normal setup/execution | No CI/CD or standalone Fabric CLI dependency is required for standard operation after bootstrap |
| AT-010 | Contract integrity | Gold tables are queried | Mandatory fields and operational timestamps follow canonical rules |

---

## Out of Scope

Explicitly NOT included in this feature phase:

- CI/CD workflows, release automation, and promotion pipelines as required build scope
- FUAM rollout or broader operating framework adoption
- standalone Fabric CLI-centered environment setup or execution outside notebook-scoped bootstrap
- advanced monitoring packs, KQL dashboard bundles, or full alert-routing implementation
- Warehouse-first or dual-authority Gold serving
- semantic-model artifacts, bindings, or optimization work as required build outputs
- broad governance estates beyond connection, secret, and RBAC guardrails that constrain notebook and pipeline design

**Sources:** user iteration request via `/workflow:iterate`, 2026-06-10; `docs/architecture/gold_serving_decision.md`; `docs/operations/alerting_matrix.md`.

---

## Constraints

| Type | Constraint | Impact |
|------|------------|--------|
| Platform | Microsoft Fabric only | No alternate orchestration or runtime stack |
| Storage | OneLake + Delta only for managed layer storage | No parallel local or external primary store |
| Architecture | Bronze/Silver/Gold must stay intact | Simplification cannot collapse layers |
| Contract | `contrato_canonico.md` is authoritative for Gold | Gold drift is not allowed |
| Orchestration | Notebook + Fabric Data Factory pipeline first, with notebook-scoped bootstrap allowed for environment setup | No separate shell/CLI operator path required |
| Setup style | Spark SQL first for DDL/materialization; setup bootstrap may use `ms-fabric-cli` inside the notebook session when provisioning is needed | Avoid deep framework-style bootstrapping |
| Runtime ergonomics | `notebookutils` mandatory for notebook runtime context | Keep notebooks Fabric-native |
| Reuse policy | Prefer Fabric-native function/variable objects only when reuse is real | Avoid helper sprawl |
| Monitoring scope | Basic only in this phase | No advanced observability estate required |
| Delivery scope | No CI/CD, no FUAM rollout, no standalone Fabric CLI operating model in this phase | Existing broader rollout artifacts are stale for this scope |

**Sources:** `docs/discovery/arquitetura_de_dados.md` §1–§3; `docs/architecture/fabric_setup.md`; `Deploy_FUAM.ipynb`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Technical Context

> Essential context for Design and Build phases.

| Aspect | Value | Notes |
|--------|-------|-------|
| **Deployment Location** | Fabric workspace items under `notebooks/`, `pipelines/`, and `fabric/` | Build output is a Fabric-oriented artifact tree; SDD mirrors remain in `./specs/` |
| **KB Domains** | None loaded for this iteration | Source of truth is the repository `docs/` set plus `Deploy_FUAM.ipynb` |
| **IaC Impact** | Modify existing / bootstrap-created Fabric items and connections | No separate CI/CD or infra rollout is required in this phase |

**Why This Matters:**

- **Location** → keeps Build aligned to the Fabric artifact layout instead of local-code assumptions.
- **KB Domains** → avoids inventing external patterns when the repo docs already define the phase.
- **IaC Impact** → limits setup to notebook-scoped bootstrap and approved Fabric items.

**Sources:** `docs/architecture/fabric_setup.md`; `docs/architecture/fabric_environment_topology.md`; `Deploy_FUAM.ipynb`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Data Contract

> This feature involves data pipelines and canonical Gold facts.

### Source Inventory

| Source | Type | Volume | Freshness | Owner |
|--------|------|--------|-----------|-------|
| ODI control tables | Oracle relational | Low thousands of execution rows/day | Window-based collection | ODI / operations |
| ETLTOOLS Oracle control + error tables | Oracle relational | Hundreds to low thousands of lot/error rows/day | Window-based collection | ETLTOOLS team |
| Elastic `NOT_STARTED` logs | Log stream / search index | Variable, event-driven | Near-real-time evidence collected by window | ETLTOOLS / operations |
| Power BI refresh/status APIs | REST API | Low hundreds of refresh rows/day | Window-based collection | Platform / BI |

### Schema Contract

| Column | Type | Constraints | PII? |
|--------|------|-------------|------|
| `execution_event_id` | STRING | NOT NULL, unique in `fct_execution_event` | No |
| `error_event_id` | STRING | NOT NULL, unique in `fct_error_event` | No |
| `system_name` | STRING | NOT NULL, enum per contract | No |
| `source_table` | STRING | NOT NULL | No |
| `process_id` | STRING | NOT NULL | No |
| `run_id` | STRING | Required except Elastic `NOT_STARTED` path in `fct_error_event` | No |
| `detected_at` | TIMESTAMP | NOT NULL | No |
| `resolved_at` | TIMESTAMP | Nullable while incident remains open | No |
| `correction_url` | STRING | NOT NULL | No |
| `server_name` | STRING | Required only for Elastic `NOT_STARTED` rows | No |

### Freshness SLAs

| Layer | Target | Measurement |
|-------|--------|-------------|
| Bronze / staging | Within 30 minutes of source window | Window timestamp vs `collected_at` |
| Silver / normalization | Within 45 minutes of Bronze completion | Notebook completion timestamp |
| Gold / facts | Within 60 minutes of materialization window | Gold availability vs planned Gold run |

### Completeness Metrics

- 100% of target source surfaces land in Bronze each scheduled window.
- 100% of required Gold outputs are materialized for each completed Gold run.
- 0 mandatory contract identifiers missing in required Gold facts.

### Lineage Requirements

- Preserve source-specific lineage from Bronze through Silver into Gold.
- Preserve fields required for runbook-driven triage: `detected_at`, `resolved_at`, `open_flag`, `time_to_detect_ms`, `time_in_error_ms`, `correction_url`.
- Keep audit correlation through `fabric_pipeline_run_id` and `stg_ingestion_audit`.

**Sources:** `docs/discovery/contrato_canonico.md` §2–§6; `docs/discovery/arquitetura_de_dados.md` §2–§5; `docs/runbooks/*.md`; `docs/operations/slo_sla_operacional.md`.

---

## Dependencies

| Dependency | Why it matters | Current handling |
|------------|----------------|------------------|
| `dim_catalog_load` coverage | Required to populate severity, ownership, and SLA references | Keep only the minimum reference data needed by current fact joins |
| Fabric workspace connections | Required to reach ODI, ETLTOOLS, Elastic, and Power BI safely | Approved Fabric connections / secret-backed access only |
| Notebook-scoped `ms-fabric-cli` availability | Required only for bootstrap provisioning/update steps | Setup-only dependency, not a runtime orchestration dependency |
| Source-side access validation | ODI/ETLTOOLS queries and Power BI access depend on upstream validity | Build/setup prerequisite, not redefined as feature scope |
| Expected-count definitions | Needed for completeness reporting | Lightweight setup seeds, small config inputs, or variable objects |
| Runbook alignment | Needed so `correction_url` and evidence fields stay operationally useful | Gold field semantics must match runbook expectations |

**Sources:** `docs/discovery/contrato_canonico.md` §2–§6; `docs/architecture/fabric_setup.md`; `docs/security/secrets_rotation_policy.md`; `docs/runbooks/*.md`; `Deploy_FUAM.ipynb`.

---

## Assumptions

Assumptions that if wrong could invalidate the design:

| ID | Assumption | If Wrong, Impact | Validated? |
|----|------------|------------------|------------|
| A-001 | Gold remains Lakehouse/Delta authoritative in this phase | Serving design would need a new iteration and broader architecture review | [ ] |
| A-002 | `stg_ingestion_audit` is sufficient as the minimum operational audit surface for this phase | Additional operational tables or monitoring surfaces would be needed | [ ] |
| A-003 | Fabric-native functions/variables remain optional because reuse may stay low in the first build | More shared assets may be required, increasing build scope and design complexity | [ ] |
| A-004 | Security and secret handling are enforced through approved connections and secret storage, not embedded notebook credentials | The implementation would violate security policy and need redesign | [ ] |
| A-005 | Existing build/validate outputs predating this iteration are stale for implementation truth | Teams may validate against obsolete scope and get false readiness signals | [x] |
| A-006 | Notebook sessions can install `ms-fabric-cli` and use transient `FAB_TOKEN` / `FAB_TOKEN_ONELAKE` values without persisting credentials | Bootstrap would need a different provisioning approach | [ ] |

**Sources:** `docs/architecture/gold_serving_decision.md`; `docs/security/secrets_rotation_policy.md`; `docs/security/rbac_matrix.md`; `Deploy_FUAM.ipynb`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Known Risks

| Risk | Why it matters | Design implication |
|------|----------------|-------------------|
| Incomplete catalog coverage | Gold severity/owner/SLA enrichment can degrade | Keep seed/reference handling explicit and minimal |
| ETLTOOLS dual-path complexity | Started and not-started events have different semantics | Silver and Gold must keep the paths separate |
| Elastic log pattern drift | `NOT_STARTED` detection can silently degrade | Parser logic must stay explicit and testable |
| Power BI credential ambiguity | Some failures resemble gateway/capacity faults | Preserve raw evidence for later classification |
| Over-abstraction pressure | Shared utilities could reintroduce complexity | Enforce reuse only after repeated need is clear |
| Scope inflation by interpretation | Dense documentation can be misread as a request for more assets | Build must follow explicit scope statements only |
| Bootstrap package/runtime drift | Notebook bootstrap depends on `ms-fabric-cli`, Fabric APIs, and session token behavior | Keep bootstrap explicit, version-aware, and separately verifiable |

**Sources:** `docs/discovery/contrato_canonico.md` §3–§6; `docs/discovery/arquitetura_de_dados.md` §4–§5; `docs/runbooks/*.md`; `Deploy_FUAM.ipynb`; user iteration request via `/workflow:iterate`, 2026-06-10.

---

## Clarity Score Breakdown

| Element | Score (0-3) | Notes |
|---------|-------------|-------|
| Problem | 3 | Business problem and simplification target are explicit |
| Users | 3 | Primary operational and engineering personas are named with specific pain points |
| Goals | 3 | Priorities are explicit and aligned to scope boundaries |
| Success | 3 | Success criteria are measurable and tied to the canonical contract |
| Scope | 3 | In-scope, out-of-scope, constraints, and assumptions are explicit |
| **Total** | **15/15** | |

**Scoring Guide:**
- 0 = Missing entirely
- 1 = Vague or incomplete
- 2 = Clear but missing details
- 3 = Crystal clear, actionable

**Minimum to proceed: 12/15**

---

## Open Questions

None — ready for Build after DESIGN alignment. Runtime verification items now belong to `/workflow:build` and `/workflow:validate`, and any pre-refresh build/validation artifacts remain stale until rebuilt.

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-17 | define-agent | Initial DEFINE from BRAINSTORM |
| 1.1 | 2026-04-17 | iterate-agent | Build strategy: combinar design + build localmente (DuckDB/Parquet) |
| 1.2 | 2026-04-18 | iterate-agent | Clarificou Phase 1 Local vs Phase 2 Fabric |
| 1.3 | 2026-05-18 | iterate-agent | Breaking change: Fabric-only platform and canonical contract alignment |
| 1.4 | 2026-06-10 | iterate-agent | Simplification-first iteration: notebooks/pipelines as primary operating model; basic monitoring only; no CI/CD in this phase; no direct FUAM adoption; Spark SQL-first setup/materialization; mandatory `notebookutils`; Fabric function/variable objects preferred for reuse |
| 1.5 | 2026-06-10 | iterate-agent | Rebuilt DEFINE from `docs/` with denser source-grounded requirements, stronger source-specific scope, explicit operational evidence model, expanded acceptance coverage, and reinforced simplicity guardrails |
| 1.6 | 2026-06-10 | iterate-agent | Refined DEFINE so documentary detail is explicitly separated from build scope; tightened wording around semantic readiness, shared objects, dimensions/reference data, monitoring expectations, and scope interpretation |
| 1.7 | 2026-06-10 | iterate-agent | Added notebook-bootstrap setup requirements based on `Deploy_FUAM.ipynb`: `%pip install ms-fabric-cli`, session-scoped token usage, connection validation/creation, current-workspace resolution, and per-environment bootstrap boundaries |
| 1.8 | 2026-06-10 | iterate-agent | Aligned DEFINE to the canonical template by adding Target Users, Technical Context, Data Contract, Clarity Score Breakdown, and Open Questions while preserving the current source-grounded scope |

---

## Next Step

**Ready for:** `/workflow:build ~/.config/opencode/sdd/features/observability-hub/DESIGN_OBSERVABILITY_HUB.md`

**Build note:** implementation, build evidence, and validation evidence created before this DEFINE/DESIGN refresh must be treated as stale until rebuilt against the refreshed design.
