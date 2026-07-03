---
template_id: "change"
template_version: "1.0.0"
document_type: "change-record"
title: "Change: <change title>"
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

# Change: <change title>

## How to use this template

Use this document for a planned production, homologation, infrastructure, data, model, security, configuration, or operational process change. The goal is to make the change reviewable before execution and auditable after execution.

## Change metadata

| Field | Value |
|---|---|
| Change ID | `CHG-0000` |
| Change type | `standard` / `normal` / `emergency` |
| Risk level | `low` / `medium` / `high` / `critical` |
| Target environment | `dev` / `hml` / `prd` |
| Planned window start | `YYYY-MM-DD HH:mm TZ` |
| Planned window end | `YYYY-MM-DD HH:mm TZ` |
| Implementation owner | `<name/team>` |
| Rollback owner | `<name/team>` |
| Communication owner | `<name/team>` |
| Related release | `<release/version>` |

## 1. Executive summary

Describe the change in five lines or fewer.

- What will change.
- Why it is needed.
- Who or what is affected.
- Expected user or business impact.
- Main operational risk.

Example:

> Move the production pipeline secrets from repository variables to the managed secret vault. The change reduces credential exposure risk and standardizes rotation. Pipelines will be restarted during the maintenance window. No user-facing downtime is expected, but failed secret lookup would stop ingestion until rollback.

## 2. Business and technical justification

| Dimension | Explanation |
|---|---|
| Business reason | `<why this matters to users, operations, revenue, compliance, or delivery>` |
| Technical reason | `<why the current state is insufficient>` |
| Risk of not changing | `<what gets worse if this is not done>` |
| Deadline or trigger | `<incident, audit, release, dependency, migration, cost, scale>` |

## 3. Scope

### In scope

- `<service/pipeline/table/model/component/config>`
- `<environment>`
- `<user group or workflow>`

### Out of scope

- `<explicitly not changing>`
- `<future improvement not included>`

## 4. Affected assets

| Asset | Type | Environment | Owner | Impact |
|---|---|---|---|---|
| `<asset>` | `<service/table/model/job/config>` | `<env>` | `<owner>` | `<read/write/restart/schema/auth/performance>` |

## 5. Impact assessment

| Area | Expected impact | Severity | Mitigation |
|---|---|---:|---|
| Users | `<none/degraded/visible change>` | Low/Medium/High | `<mitigation>` |
| Data freshness | `<expected lag or pause>` | Low/Medium/High | `<mitigation>` |
| Data quality | `<schema/values/dedup/scd impact>` | Low/Medium/High | `<mitigation>` |
| Security | `<permissions/secrets/network>` | Low/Medium/High | `<mitigation>` |
| Cost | `<one-time or recurring cost>` | Low/Medium/High | `<mitigation>` |
| Operations | `<on-call/runbook/support impact>` | Low/Medium/High | `<mitigation>` |

## 6. Preconditions

The change cannot start until all required preconditions are met.

- [ ] Approval received from `<role/team>`.
- [ ] Maintenance window confirmed.
- [ ] Backup/export/snapshot completed where required.
- [ ] Monitoring dashboard and alert channel are ready.
- [ ] Rollback path has been tested or reviewed.
- [ ] Required secrets, credentials, feature flags, config values, and permissions are available.
- [ ] Affected teams and stakeholders were notified.

## 7. Implementation plan

| Step | Action | Command/link/reference | Expected result | Owner | Timebox |
|---:|---|---|---|---|---|
| 1 | `<prepare>` | `<command/link>` | `<expected output>` | `<owner>` | `<duration>` |
| 2 | `<deploy/apply>` | `<command/link>` | `<expected output>` | `<owner>` | `<duration>` |
| 3 | `<verify>` | `<command/link>` | `<expected output>` | `<owner>` | `<duration>` |
| 4 | `<communicate>` | `<channel/message>` | `<expected response>` | `<owner>` | `<duration>` |

## 8. Validation during change

| Check | Method | Success criteria | Evidence link |
|---|---|---|---|
| Service health | `<dashboard/command/API>` | `<threshold>` | `<link>` |
| Pipeline execution | `<job/run history>` | `<success or expected warning>` | `<link>` |
| Data quality | `<DQ check>` | `<zero critical failures>` | `<link>` |
| Logs/traces | `<log query/trace>` | `<no unexpected errors>` | `<link>` |
| User flow | `<smoke test>` | `<expected behavior>` | `<link>` |

## 9. Rollback plan

Rollback must be executable under pressure. Avoid vague instructions.

| Trigger | Rollback action | Owner | Expected recovery time | Evidence required |
|---|---|---|---|---|
| `<condition>` | `<exact revert step>` | `<owner>` | `<RTO>` | `<link>` |

### Rollback commands or steps

```bash
# Example only. Replace with real command.
<rollback-command>
```

## 10. Communication plan

| Audience | Channel | Before change | During change | After change |
|---|---|---|---|---|
| Engineering | `<Slack/Teams/email>` | `<message>` | `<message>` | `<message>` |
| Business users | `<channel>` | `<message>` | `<message>` | `<message>` |
| Support/on-call | `<channel>` | `<message>` | `<message>` | `<message>` |

## 11. Approval

| Role | Name | Decision | Date | Notes |
|---|---|---|---|---|
| Change owner | `<name>` | pending/approved/rejected | `YYYY-MM-DD` | `<notes>` |
| Tech lead | `<name>` | pending/approved/rejected | `YYYY-MM-DD` | `<notes>` |
| Product/business owner | `<name>` | pending/approved/rejected | `YYYY-MM-DD` | `<notes>` |
| Security/data governance | `<name>` | pending/approved/rejected | `YYYY-MM-DD` | `<notes>` |

## 12. Execution log

| Time | Event | Result | Owner | Evidence |
|---|---|---|---|---|
| `HH:mm` | `<step started/completed>` | `<result>` | `<owner>` | `<link>` |

## 13. Post-implementation review

Complete this after the change.

| Question | Answer |
|---|---|
| Was the change completed as planned? | `<yes/no/partial>` |
| Was rollback needed? | `<yes/no>` |
| Were there incidents or unexpected warnings? | `<details>` |
| Were users affected? | `<details>` |
| Did monitoring detect the right signals? | `<details>` |
| What follow-up tasks are required? | `<links>` |

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
