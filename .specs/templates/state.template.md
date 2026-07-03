---
template_id: "state"
template_version: "1.0.0"
document_type: "state-report"
title: "State: <system or initiative>"
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

# State: <system or initiative>

## How to use this template

Use this document as a current-state snapshot. It is useful for handoffs, weekly reviews, incident recovery, initiative tracking, and context loading for agents. It should describe the present state, not the desired roadmap.

## State metadata

| Field | Value |
|---|---|
| State ID | `STATE-0000` |
| As of | `YYYY-MM-DD HH:mm TZ` |
| Status level | `green` / `yellow` / `red` |
| Update cadence | `daily` / `weekly` / `per release` / `on demand` |
| Next review | `YYYY-MM-DD` |
| Maintainer | `<name/team>` |

## 1. Current state summary

Write the current state in a short narrative.

> As of `<date>`, `<system/initiative>` is `<status>`. The main stable areas are `<areas>`. The main concerns are `<concerns>`. The next review should focus on `<focus>`.

## 2. Scope of this state report

### Included

- `<system/process/team/release/domain>`

### Excluded

- `<not covered>`

## 3. State dashboard

| Area | Status | Evidence | Notes |
|---|---|---|---|
| Delivery | Green/Yellow/Red | `<link>` | `<notes>` |
| Operations | Green/Yellow/Red | `<link>` | `<notes>` |
| Data quality | Green/Yellow/Red | `<link>` | `<notes>` |
| Security/governance | Green/Yellow/Red | `<link>` | `<notes>` |
| Cost/capacity | Green/Yellow/Red | `<link>` | `<notes>` |
| User/adoption | Green/Yellow/Red | `<link>` | `<notes>` |

## 4. Stable facts

List facts that are known and unlikely to change before the next review.

- `<fact>`
- `<fact>`

## 5. Recently changed

| Change | When | Impact | Related artifact |
|---|---|---|---|
| `<change>` | `YYYY-MM-DD` | `<impact>` | `<link>` |

## 6. Known issues

| Issue | Severity | Current workaround | Owner | Target resolution |
|---|---|---|---|---|
| `<issue>` | low/medium/high/critical | `<workaround>` | `<owner>` | `YYYY-MM-DD` |

## 7. Risks and dependencies

| Risk/dependency | Type | Status | Impact | Next action |
|---|---|---|---|---|
| `<item>` | risk/dependency | open/mitigating/closed | `<impact>` | `<action>` |

## 8. Decisions and ADRs in force

| Decision/ADR | Summary | Impact on current state |
|---|---|---|
| `<DEC/ADR link>` | `<summary>` | `<impact>` |

## 9. Metrics snapshot

| Metric | Current value | Expected range | Status | Source |
|---|---:|---:|---|---|
| `<metric>` | `<value>` | `<range>` | green/yellow/red | `<link>` |

## 10. Next actions

| Action | Owner | Due date | Expected effect |
|---|---|---|---|
| `<action>` | `<owner>` | `YYYY-MM-DD` | `<effect>` |

## 11. Context for next reviewer or agent

Include concise context that prevents lost-in-the-middle behavior when another person or agent continues the work.

- Most important constraint: `<constraint>`
- Do not change without approval: `<area>`
- Current best entry point: `<file/doc/dashboard>`
- Most likely failure mode: `<failure mode>`
- Recommended next read: `<link>`

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
