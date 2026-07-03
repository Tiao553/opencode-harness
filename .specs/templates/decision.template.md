---
template_id: "decision"
template_version: "1.0.0"
document_type: "decision-record"
title: "Decision: <decision question>"
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

# Decision: <decision question>

## How to use this template

Use this for non-architectural decisions that still need explicit reasoning: product trade-offs, process changes, operational rules, prioritization, team conventions, support policies, governance choices, or delivery sequencing. Use an ADR instead when the decision is architecturally significant.

## Decision metadata

| Field | Value |
|---|---|
| Decision ID | `DEC-0000` |
| Decision type | `product` / `technical` / `process` / `operational` / `governance` |
| Decision owner | `<name/team>` |
| Decision deadline | `YYYY-MM-DD` |
| Decided on | `YYYY-MM-DD or pending` |
| Status | `proposed` / `accepted` / `rejected` / `superseded` |
| Supersedes | `<decision-id or none>` |
| Superseded by | `<decision-id or none>` |

## 1. Decision question

Write the question in a form that can be answered.

Bad:

> Improve support process.

Good:

> Should we require a validation report before production deployment for medium-risk data pipeline changes?

Decision question:

> `<question>`

## 2. Context

Explain what changed, why a decision is needed now, and what constraints exist. Include relevant facts, incidents, deadlines, dependencies, stakeholder expectations, and known disagreements.

## 3. Objectives

| Objective | Why it matters | Priority |
|---|---|---:|
| `<objective>` | `<reason>` | High/Medium/Low |

## 4. Non-objectives

Clarify what this decision will not solve.

- `<out of scope>`
- `<future decision>`

## 5. Options considered

| Option | Description | Pros | Cons | Cost/effort | Risk |
|---|---|---|---|---|---|
| A | `<description>` | `<pros>` | `<cons>` | `<low/medium/high>` | `<low/medium/high>` |
| B | `<description>` | `<pros>` | `<cons>` | `<low/medium/high>` | `<low/medium/high>` |
| C | `<description>` | `<pros>` | `<cons>` | `<low/medium/high>` | `<low/medium/high>` |

## 6. Evaluation criteria

| Criterion | Weight | Option A | Option B | Option C |
|---|---:|---:|---:|---:|
| Value delivered | 30% | `<score>` | `<score>` | `<score>` |
| Risk reduction | 25% | `<score>` | `<score>` | `<score>` |
| Implementation effort | 20% | `<score>` | `<score>` | `<score>` |
| Operational simplicity | 15% | `<score>` | `<score>` | `<score>` |
| Reversibility | 10% | `<score>` | `<score>` | `<score>` |

Scoring guidance: use 1 to 5, where 5 is best. Adjust weights only when the decision owner approves.

## 7. Decision

Chosen option: **`<option>`**

Decision statement:

> We will `<decision>` because `<primary rationale>`. We accept `<trade-off>` to avoid `<worse outcome>`.

## 8. Rationale

Explain the reasoning in plain language. Include why the rejected options were not chosen.

| Rejected option | Reason rejected | Revisit condition |
|---|---|---|
| `<option>` | `<reason>` | `<condition>` |

## 9. Impact

| Area | Impact | Owner | Follow-up required |
|---|---|---|---|
| Product | `<impact>` | `<owner>` | `<task/link>` |
| Engineering | `<impact>` | `<owner>` | `<task/link>` |
| Data/AI | `<impact>` | `<owner>` | `<task/link>` |
| Security/governance | `<impact>` | `<owner>` | `<task/link>` |
| Operations/support | `<impact>` | `<owner>` | `<task/link>` |

## 10. Action items

| Action | Owner | Due date | Status | Link |
|---|---|---|---|---|
| `<action>` | `<owner>` | `YYYY-MM-DD` | pending/in_progress/done | `<link>` |

## 11. Communication

| Audience | Message | Channel | Owner | Date |
|---|---|---|---|---|
| `<audience>` | `<decision summary>` | `<channel>` | `<owner>` | `YYYY-MM-DD` |

## 12. Revisit criteria

This decision should be revisited if:

- `<metric threshold changes>`
- `<risk materializes>`
- `<dependency changes>`
- `<new constraint appears>`
- `<decision expires after date>`

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
