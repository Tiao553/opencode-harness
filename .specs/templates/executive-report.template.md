---
template_id: "executive-report"
template_version: "1.0.0"
document_type: "executive-report"
title: "Executive report: <initiative name>"
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

# Executive report: <initiative name>

## How to use this template

Use this report for leadership updates. It should be concise, decision-oriented, and honest about risk. Avoid turning it into a task dump. Keep details in linked artifacts.

## Report metadata

| Field | Value |
|---|---|
| Report ID | `EXEC-0000` |
| Reporting period | `YYYY-MM-DD` to `YYYY-MM-DD` |
| Audience | `<executive / directors / managers / steering committee>` |
| Initiative phase | `discovery` / `delivery` / `pilot` / `rollout` / `operation` |
| Overall status | `green` / `yellow` / `red` |
| Prepared by | `<name/team>` |

## 1. Executive summary

Write three to five short paragraphs or bullets.

- Current status in plain language.
- What changed since the last report.
- Biggest progress signal.
- Biggest risk or decision needed.
- What leadership should do, if anything.

Example:

> The program remains yellow. Delivery progress improved after stabilizing the ingestion framework, but production readiness still depends on closing two observability gaps and validating rollback for high-volume sources. No scope change is requested this week.

## 2. Status at a glance

| Dimension | Status | Explanation |
|---|---|---|
| Scope | Green/Yellow/Red | `<summary>` |
| Schedule | Green/Yellow/Red | `<summary>` |
| Cost/capacity | Green/Yellow/Red | `<summary>` |
| Quality | Green/Yellow/Red | `<summary>` |
| Security/governance | Green/Yellow/Red | `<summary>` |
| Adoption/readiness | Green/Yellow/Red | `<summary>` |

## 3. Outcomes and KPIs

| Outcome | Baseline | Current | Target | Trend | Notes |
|---|---:|---:|---:|---|---|
| `<outcome>` | `<value>` | `<value>` | `<value>` | up/down/flat | `<notes>` |

## 4. Progress this period

| Item delivered | Impact | Evidence |
|---|---|---|
| `<delivery>` | `<business or technical impact>` | `<link>` |

## 5. Planned next period

| Priority | Work planned | Expected outcome | Owner | Dependency |
|---:|---|---|---|---|
| 1 | `<work>` | `<outcome>` | `<owner>` | `<dependency>` |

## 6. Risks, blockers, and mitigations

| Risk/blocker | Status | Impact | Mitigation | Owner | Decision needed |
|---|---|---|---|---|---|
| `<risk>` | open/mitigating/closed | `<impact>` | `<mitigation>` | `<owner>` | yes/no |

## 7. Decisions needed from leadership

| Decision | Why now | Options | Recommendation | Deadline |
|---|---|---|---|---|
| `<decision>` | `<reason>` | `<options>` | `<recommendation>` | `YYYY-MM-DD` |

## 8. Financial, capacity, or resource view

| Area | Planned | Actual/current | Variance | Action |
|---|---:|---:|---:|---|
| Budget | `<value>` | `<value>` | `<value>` | `<action>` |
| Team capacity | `<value>` | `<value>` | `<value>` | `<action>` |
| Cloud/runtime cost | `<value>` | `<value>` | `<value>` | `<action>` |

## 9. Stakeholder and adoption view

| Stakeholder group | Current sentiment/readiness | Issue | Action |
|---|---|---|---|
| `<group>` | `<ready/blocked/neutral/resistant>` | `<issue>` | `<action>` |

## 10. Evidence and appendix links

Do not paste all details here. Link to the artifacts that support the report.

- PRD: `<link>`
- ADRs: `<links>`
- State report: `<link>`
- Validation report: `<link>`
- Ship summary: `<link>`
- Metrics dashboard: `<link>`
- Risk register: `<link>`

## 11. One-line message for forwarding

> `<one sentence that a leader can forward without editing>`

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
