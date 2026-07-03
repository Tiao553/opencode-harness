---
template_id: "evidence"
template_version: "1.0.0"
document_type: "evidence-record"
title: "Evidence: <evidence title>"
status: "draft" # draft | in_review | approved | deprecated | superseded
owner: "<team-or-person>"
authors:
  - "<name>"
reviewers:
  - "<name-or-team>"
approvers:
  - "<name-or-role>"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
effective_date: null
domain: "<business-or-technical-domain>"
system: "<system-product-or-platform>"
confidentiality: "internal" # public | internal | restricted | confidential
related_work_items:
  - "<Jira/GitHub/Linear/ServiceNow/etc>"
related_documents:
  - "<relative-link-or-url>"
tags:
  - "<tag>"
summary: "<one-sentence summary>"
---

# Evidence: <evidence title>

## How to use this template

Use this document to register objective evidence for testing, validation, production readiness, audit, incident review, security control, data quality, model evaluation, or release verification. Evidence should support a claim. It should not be a vague statement such as "tests passed" without artifacts.

## Evidence metadata

| Field | Value |
|---|---|
| Evidence ID | `EVD-0000` |
| Evidence type | `test-result` / `log` / `dashboard` / `screenshot` / `query-result` / `trace` / `report` / `approval` |
| Collected by | `<name/team>` |
| Collected on | `YYYY-MM-DD HH:mm TZ` |
| Source system | `<system/tool>` |
| Environment | `dev` / `hml` / `prd` |
| Retention class | `short-term` / `release` / `audit` / `regulated` |
| Integrity reference | `<checksum, immutable URL, artifact ID, run ID>` |

## 1. Claim supported by this evidence

State the exact claim this evidence supports.

Example:

> The production ingestion pipeline for source `crm_core` completed successfully for the `2026-07-03` collection window, wrote 1,248,902 rows to bronze, produced zero critical data quality failures, and emitted audit metrics.

Claim:

> `<claim>`

## 2. Related requirement, test, task, or change

| Artifact type | ID/link | Relationship |
|---|---|---|
| Requirement | `<REQ-ID/link>` | `<supports/verifies/validates>` |
| Test spec | `<TEST-SPEC-ID/link>` | `<evidence for scenario>` |
| Task | `<TASK-ID/link>` | `<completion evidence>` |
| Change | `<CHG-ID/link>` | `<post-change verification>` |
| Validation report | `<VAL-ID/link>` | `<input evidence>` |
| Incident/problem | `<INC/PRB-ID/link>` | `<evidence for analysis>` |

## 3. Evidence source

| Field | Value |
|---|---|
| Tool/system | `<GitHub Actions / Airflow / Datadog / Grafana / BigQuery / Fabric / MLflow / etc>` |
| Artifact URL/path | `<link>` |
| Run ID/query ID/job ID | `<id>` |
| Time window | `<start> to <end>` |
| Dataset/table/model/service | `<name>` |
| Collector identity | `<user/service account>` |

## 4. Collection method

Describe how the evidence was collected. Include query, command, dashboard filter, log filter, test run parameters, model version, data window, and any relevant environment variables.

```bash
# Optional command or script used to collect evidence
<command>
```

```sql
-- Optional query used to collect evidence
<select statement>
```

## 5. Observed result

| Observation | Expected | Actual | Pass/fail | Notes |
|---|---|---|---|---|
| `<metric/check>` | `<expected>` | `<actual>` | pass/fail/warning | `<notes>` |

## 6. Screenshots, logs, traces, or artifacts

List concrete evidence artifacts. Do not paste large logs unless necessary; link to immutable artifacts when possible.

| Artifact | Type | Location | Notes |
|---|---|---|---|
| `<artifact name>` | `<screenshot/log/query/trace/report>` | `<link/path>` | `<notes>` |

## 7. Interpretation

Explain what the evidence means.

This evidence shows:

- `<supported conclusion>`
- `<supported conclusion>`

This evidence does not show:

- `<limitation>`
- `<limitation>`

## 8. Limitations and risks

| Limitation | Impact | Mitigation |
|---|---|---|
| `<limitation>` | `<why it matters>` | `<how it is handled>` |

## 9. Evidence quality assessment

| Quality attribute | Rating | Explanation |
|---|---|---|
| Objectivity | High/Medium/Low | `<explanation>` |
| Reproducibility | High/Medium/Low | `<explanation>` |
| Completeness | High/Medium/Low | `<explanation>` |
| Integrity | High/Medium/Low | `<explanation>` |
| Timeliness | High/Medium/Low | `<explanation>` |

## 10. Evidence decision

Conclusion: `accepted` / `accepted-with-limitations` / `rejected` / `needs-more-evidence`

Reason:

> `<reason>`

Follow-up evidence required:

- `<additional evidence>`

---

## Review checklist

Use this checklist before marking the document as `in_review` or `approved`.

- [ ] The objective is explicit and does not depend on hidden context.
- [ ] Scope and non-scope are both defined.
- [ ] The owner, reviewers, approvers, dates, status, and related work items are filled.
- [ ] Assumptions, risks, dependencies, and open questions are visible.
- [ ] Acceptance criteria or validation criteria are testable.
- [ ] Evidence links are concrete, not generic statements.
- [ ] Rollback, mitigation, or contingency is defined where risk exists.
- [ ] Terms, IDs, tables, environments, and systems use canonical names.
- [ ] The document can be understood by a new reviewer without the original meeting context.

## Change log

| Date | Author | Change | Reason |
|---|---|---|---|
| YYYY-MM-DD | <name> | Initial draft | Created from template |
