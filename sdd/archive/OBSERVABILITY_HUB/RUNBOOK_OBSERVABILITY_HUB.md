# RUNBOOK: OBSERVABILITY_HUB

> Production operations guide generated after the validation gate approves release readiness.

## Document Control

| Attribute | Value |
|-----------|-------|
| Feature | OBSERVABILITY_HUB |
| Generated At | 2026-05-18 |
| Status | Approved for Production |
| Release Owner | Engineering Lead |
| Operations Owner | Platform / On-call |
| Related Validation | `VALIDATION_REPORT_OBSERVABILITY_HUB.md` |

---

## Release Summary

OBSERVABILITY_HUB passes final validation with a composite score of 91.5, a significant improvement from the prior run's 80.75. The single CRITICAL finding from the first validation — a dedup_id mismatch between DDL and MERGE logic — has been fully remediated alongside all P0/P1 issues. The feature now delivers all 10 requirements, including all 7 MUST items, with strong spec alignment (94), architecture fidelity (95), and a perfect production-readiness delta (100).

The remediation work between validation runs was thorough and well-targeted: 38 new tests were added, SQL injection prevention was implemented for JDBC paths, Silver replaceWhere was properly scoped, and the Gold schedule was corrected. This demonstrates a disciplined response to validation feedback and materially reduced the operational risk profile of the feature.

### Release Decision

| Check | Required State | Current State |
|-------|----------------|---------------|
| Validation score | At least 90/100 | 91.5/100 |
| Critical findings | 0 | 0 |
| Rollback plan | Documented and executable | Documented |
| Monitoring | Metrics, logs, and alerts identified | Documented |

---

## Pre-flight Checklist

Complete every item before production deployment.

- [ ] Latest `VALIDATION_REPORT_OBSERVABILITY_HUB.md` has verdict `Approved for Prod`.
- [ ] CI/CD pipeline completed successfully for the release commit.
- [ ] Oracle connection credentials (ODI, ETLTOOLS) configured in Fabric Workspace Connections / Key Vault.
- [ ] Power BI app registration (tenant_id, client_id, client_secret) configured in Key Vault.
- [ ] Elastic endpoint, index, and permissions validated.
- [ ] Fabric workspaces (`OBSERVABILITY-HUB-DEV/test/prod`) provisioned.
- [ ] Gold schema bootstrapped via `create_schema_gold.ipynb` in target environment.
- [ ] Dimension seed data loaded via `seed_dimensions.ipynb`.
- [ ] Semantic model deployed and DirectLake bindings verified.
- [ ] Monitoring dashboards (KQL) and alerts configured per `alerting_matrix.md`.
- [ ] Rollback owner and communication channel confirmed.

---

## Deployment Plan

| Step | Action | Command / Evidence | Owner | Expected Result |
|------|--------|--------------------|-------|-----------------|
| 1 | Promote artifacts DEV → TEST via Deployment Pipeline | Fabric Deployment Pipeline UI | Release Owner | All notebooks, pipelines, TMDL in TEST |
| 2 | Run `create_schema_gold.ipynb` + `seed_dimensions.ipynb` in TEST | Manual notebook execution | Engineering | Gold schema bootstrapped |
| 3 | Trigger full pipeline cycle in TEST (ODI 18h → ETLTOOLS 22h → Gold 23:30) | Pipeline manual trigger or wait for schedule | Engineering | End-to-end data flow verified |
| 4 | Validate data quality in Gold tables | `fct_completeness_report` + spot-check correction_urls | Operations | Completeness ≥ 95%, correction_urls resolve |
| 5 | Promote TEST → PROD via Deployment Pipeline with approval gate | Fabric Deployment Pipeline UI | Release Owner | Production deployment complete |
| 6 | Monitor first 3 production cycles | KQL dashboards + pipeline run history | Operations | No failures, SLA met |

---

## Configuration and Dependencies

| Item | Value / Location | Validation Method |
|------|------------------|-------------------|
| Runtime environment | Microsoft Fabric Lakehouse (OneLake + Delta Lake) | Workspace access verified |
| Required secrets | Oracle ODI connection, Oracle ETLTOOLS connection, PBI app registration, Elastic credentials | Key Vault / Workspace Connections check |
| External services | ODI Oracle DB, ETLTOOLS Oracle DB, Elastic cluster, Power BI REST API | JDBC connectivity test, API auth test |
| Data dependencies | `SNP_SESSION`, `SNP_STEP_REPORT`, `INTERFACE.ETL_*`, `INTERFACE.ERRO`, Elastic NOT_STARTED logs, PBI refresh history | Source availability during collection windows |
| Feature flags | `include_not_started_from_elastic` (pipeline parameter, default `true`) | Pipeline parameter check |

---

## Observability

| Signal | Source | Healthy Threshold | Alert / Owner |
|--------|--------|-------------------|---------------|
| Pipeline success rate | `stg_ingestion_audit` + Fabric pipeline history | ≥ 95% per day | Platform on-call |
| Data freshness | `collected_at` vs schedule window | ≤ 30 min after window | Platform on-call |
| Completeness | `fct_completeness_report` | ≥ 95% per source per window | Data Engineering |
| Error rate | `fct_error_event` open_flag=true count | < 10 concurrent open errors | Operations |
| Semantic model refresh | `semantic_model_refresh_failures.kql` | 0 failures per day | BI Engineering |
| Capacity throttling | `capacity_throttling.kql` | No critical throttling events | Platform on-call |

### Operational Notes

- Gold pipeline is scheduled at 23:30 UTC — confirm this does not conflict with upstream Silver completion windows
- correction_url_builder.ipynb was flagged as potential dead code; verify it is either wired into a pipeline or removed to avoid confusion
- stg_ingestion_audit DDL is not present in setup notebooks — ensure it is created via a separate bootstrapping process or add it to setup
- Monitor NOT_STARTED flow path carefully in the first production cycles since the filter fix was a prior CRITICAL remediation
- CI pipeline would benefit from adding coverage, linting, and type-checking gates in a follow-up hardening pass

---

## Incident Response

| Symptom | First Check | Escalation | Mitigation |
|---------|-------------|------------|------------|
| Pipeline failure (Bronze) | Fabric pipeline run history + `stg_ingestion_audit` | Data Engineering | Retry pipeline; check source connectivity |
| Pipeline failure (Gold) | `pipeline_materialize_gold` run history + audit | Data Engineering | Re-trigger Gold pipeline after Bronze/Silver success |
| NOT_STARTED events missing | `fct_error_event` filtered by `error_type=NOT_STARTED` | Data Engineering | Check Elastic connectivity + `collect_elastic.ipynb` logs |
| Dedup collision unexpected | `fct_dedup_registry` occurrence_count spike | Data Engineering | Verify `dedup_id` generation logic per source |
| correction_url broken | Manual drill-down test from dashboard | Engineering | Verify `_build_correction_url` UDF parameters |
| Semantic model refresh failure | `semantic_model_refresh_failures.kql` | BI Engineering | Check DirectLake binding + capacity |

---

## Rollback Plan

**Rollback trigger:** Any CRITICAL data quality issue (>5% null rate on required fields) or persistent pipeline failures (>2 consecutive windows).

| Step | Action | Command / Evidence | Owner | Expected Result |
|------|--------|--------------------|-------|-----------------|
| 1 | Pause all scheduled pipelines | Fabric pipeline disable | Release Owner | No new data ingested |
| 2 | Restore previous Gold table versions | Delta time travel: `RESTORE TABLE fct_execution_event TO VERSION AS OF <n>` | Data Engineering | Previous good state restored |
| 3 | Validate restored data quality | `fct_completeness_report` check | Operations | Completeness metrics recover |
| 4 | Record incident notes | Incident channel + JIRA | Operations | Timeline and actions captured |

---

## Post-deployment Validation

| Validation | Command / Evidence | Pass Criteria |
|------------|--------------------|---------------|
| Pipeline success | 3 consecutive window cycles complete without failure | All 4 pipelines succeed |
| Data quality | `fct_completeness_report` per source ≥ 95% | No source below threshold |
| Dedup correctness | `fct_dedup_registry` occurrence_count distribution | No unexpected spikes |
| Drill-down test | Dashboard → error → correction_url | URL resolves in < 2 sec |
| Monitoring coverage | KQL dashboards show data | All 3 KQL queries return results |
| Stakeholder confirmation | Operations sign-off | Release acknowledged |

---

## Handoff

| Topic | Owner | Notes |
|-------|-------|-------|
| Release ownership | Engineering Lead | Accountable for deployment execution |
| Operations ownership | Platform / On-call | Accountable for monitoring and incident response |
| Remediation ownership | Data Engineering | Accountable for post-release defects and hardening items |
## Status: ✅ Shipped
