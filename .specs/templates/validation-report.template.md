---
template_id: "validation-report"
template_version: "1.0.0"
document_type: "validation-report"
title: "Validation report: <release/change/system>"
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

# Validation report: <release/change/system>

## How to use this template

Use this document to conclude whether a release, change, model, data product, service, or capability is valid for its intended use. Validation is broader than test execution: it connects requirements, test results, evidence, defects, risk acceptance, and release decision.

## Validation metadata

| Field | Value |
|---|---|
| Validation ID | `VAL-0000` |
| Validation type | `release` / `change` / `system` / `data-product` / `model` / `security` / `operational-readiness` |
| Release/change reference | `<REL/CHG/link>` |
| Version/build | `<version/hash/tag>` |
| Environment | `dev` / `hml` / `prd-shadow` / `prd` |
| Executed on | `YYYY-MM-DD` |
| Validation owner | `<name/team>` |
| Final conclusion | `approved` / `approved-with-conditions` / `rejected` / `inconclusive` |

## 1. Executive validation conclusion

State the conclusion clearly.

> `<release/change/system>` is `<approved/approved with conditions/rejected/inconclusive>` for `<intended use>` because `<main evidence>`. Residual risks are `<summary>`. Required follow-ups are `<summary>`.

## 2. Scope of validation

### Validated

- `<capability/system/workflow/model/pipeline>`

### Not validated

- `<explicit exclusion>`

## 3. Intended use

Describe the use for which this validation applies.

| User/system | Intended use | Conditions/limits |
|---|---|---|
| `<actor>` | `<use>` | `<limits>` |

## 4. References

| Artifact | Link | Purpose |
|---|---|---|
| PRD | `<link>` | Requirements source |
| ADR/decision | `<link>` | Design rationale |
| Test spec | `<link>` | Test plan |
| Evidence | `<link>` | Objective evidence |
| Change record | `<link>` | Deployment/change control |
| Ship summary | `<link>` | Release facts |

## 5. Requirement validation matrix

| Requirement ID | Requirement summary | Test/evidence | Result | Notes |
|---|---|---|---|---|
| FR-001 | `<summary>` | `<TST/EVD link>` | pass/fail/partial/not-tested | `<notes>` |
| NFR-001 | `<summary>` | `<TST/EVD link>` | pass/fail/partial/not-tested | `<notes>` |

## 6. Test execution summary

| Test area | Planned | Executed | Passed | Failed | Blocked/skipped | Evidence |
|---|---:|---:|---:|---:|---:|---|
| Functional | `<n>` | `<n>` | `<n>` | `<n>` | `<n>` | `<link>` |
| Integration | `<n>` | `<n>` | `<n>` | `<n>` | `<n>` | `<link>` |
| Data quality | `<n>` | `<n>` | `<n>` | `<n>` | `<n>` | `<link>` |
| Performance | `<n>` | `<n>` | `<n>` | `<n>` | `<n>` | `<link>` |
| Security | `<n>` | `<n>` | `<n>` | `<n>` | `<n>` | `<link>` |
| AI/model evaluation | `<n>` | `<n>` | `<n>` | `<n>` | `<n>` | `<link>` |
| Operational readiness | `<n>` | `<n>` | `<n>` | `<n>` | `<n>` | `<link>` |

## 7. Evidence reviewed

| Evidence ID | Claim | Quality | Accepted? | Notes |
|---|---|---|---|---|
| EVD-001 | `<claim>` | high/medium/low | yes/no/with limitations | `<notes>` |

## 8. Defects, deviations, and exceptions

| ID | Description | Severity | Status | Decision | Owner |
|---|---|---|---|---|---|
| `<defect/deviation>` | `<description>` | critical/high/medium/low | open/closed/accepted | `<decision>` | `<owner>` |

## 9. Risk assessment

| Residual risk | Likelihood | Impact | Mitigation | Accepted by |
|---|---|---|---|---|
| `<risk>` | low/medium/high | low/medium/high | `<mitigation>` | `<name/role>` |

## 10. Operational readiness

| Readiness item | Status | Evidence | Notes |
|---|---|---|---|
| Monitoring dashboard | pass/fail/partial | `<link>` | `<notes>` |
| Alerts | pass/fail/partial | `<link>` | `<notes>` |
| Runbook | pass/fail/partial | `<link>` | `<notes>` |
| Rollback/degrade path | pass/fail/partial | `<link>` | `<notes>` |
| On-call/support handoff | pass/fail/partial | `<link>` | `<notes>` |
| Access/secrets/config | pass/fail/partial | `<link>` | `<notes>` |

## 11. Final validation decision

Decision: `approved` / `approved-with-conditions` / `rejected` / `inconclusive`

Reason:

> `<reason>`

Conditions before ship or continued operation:

- `<condition>`

Follow-up after ship:

- `<follow-up>`

## 12. Approval

| Role | Name | Decision | Date | Notes |
|---|---|---|---|---|
| Validation owner | `<name>` | approved/rejected | `YYYY-MM-DD` | `<notes>` |
| Product owner | `<name>` | approved/rejected | `YYYY-MM-DD` | `<notes>` |
| Tech lead | `<name>` | approved/rejected | `YYYY-MM-DD` | `<notes>` |
| Operations owner | `<name>` | approved/rejected | `YYYY-MM-DD` | `<notes>` |
| Security/governance | `<name>` | approved/rejected | `YYYY-MM-DD` | `<notes>` |

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
