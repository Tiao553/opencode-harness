---
template_id: "ship-summary"
template_version: "1.0.0"
document_type: "ship-summary"
title: "Ship summary: <release title>"
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

# Ship summary: <release title>

## How to use this template

Use this after a release, deployment, migration, model publish, data pipeline change, or user-facing launch. The document records what actually shipped, not only what was planned.

## Release metadata

| Field | Value |
|---|---|
| Release ID | `REL-0000` |
| Version/tag | `<vX.Y.Z or release name>` |
| Ship date | `YYYY-MM-DD HH:mm TZ` |
| Environments | `dev`, `hml`, `prd` |
| Release owner | `<name/team>` |
| Change record | `<CHG-ID/link>` |
| Validation report | `<VAL-ID/link>` |
| Rollback status | `not-needed` / `partial` / `executed` / `not-available` |

## 1. Summary

Write a short release note that can be shared broadly.

> Shipped `<capability/version>` to `<environment/audience>`. The release includes `<main changes>`. Post-release validation is `<passed/partial/failed>`. Follow-ups are `<summary>`.

## 2. What shipped

| Item | Type | User/business impact | Technical impact | Link |
|---|---|---|---|---|
| `<item>` | feature/fix/data/model/config/infra | `<impact>` | `<impact>` | `<PR/task>` |

## 3. What did not ship

| Planned item | Reason deferred | New target | Owner |
|---|---|---|---|
| `<item>` | `<reason>` | `<date/release>` | `<owner>` |

## 4. User-facing changes

Describe only what users, analysts, operations, or stakeholders may notice.

- `<visible change>`
- `<visible limitation>`
- `<new instruction or behavior>`

## 5. Technical changes

| Area | Change | Notes |
|---|---|---|
| API/service | `<change>` | `<notes>` |
| Data pipeline | `<change>` | `<notes>` |
| Data model/schema | `<change>` | `<notes>` |
| AI/model/prompt | `<change>` | `<notes>` |
| Infrastructure | `<change>` | `<notes>` |
| Observability | `<change>` | `<notes>` |
| Security | `<change>` | `<notes>` |

## 6. Deployment timeline

| Time | Event | Result | Evidence |
|---|---|---|---|
| `HH:mm` | `<event>` | `<result>` | `<link>` |

## 7. Post-release validation

| Check | Expected | Actual | Status | Evidence |
|---|---|---|---|---|
| `<check>` | `<expected>` | `<actual>` | pass/warning/fail | `<link>` |

## 8. Incidents, anomalies, or deviations

| Issue | Severity | Impact | Mitigation | Follow-up |
|---|---|---|---|---|
| `<issue>` | low/medium/high/critical | `<impact>` | `<mitigation>` | `<task/link>` |

## 9. Metrics after ship

| Metric | Before | After | Expected? | Notes |
|---|---:|---:|---|---|
| `<metric>` | `<value>` | `<value>` | yes/no/too early | `<notes>` |

## 10. Operational notes

- Runbook updated: `<yes/no/link>`
- Alerts updated: `<yes/no/link>`
- Dashboards updated: `<yes/no/link>`
- On-call notified: `<yes/no/channel>`
- Support/customer-facing documentation updated: `<yes/no/link>`

## 11. Follow-up actions

| Action | Owner | Due date | Priority | Link |
|---|---|---|---|---|
| `<action>` | `<owner>` | `YYYY-MM-DD` | high/medium/low | `<link>` |

## 12. Final release conclusion

Release conclusion: `successful` / `successful-with-warnings` / `partial` / `rolled-back` / `failed`

Reason:

> `<reason>`

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
