---
template_id: "task"
template_version: "1.0.0"
document_type: "task-specification"
title: "Task: <task title>"
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

# Task: <task title>

## How to use this template

Use this for executable work. A good task is small enough to review, explicit enough to test, and constrained enough to prevent scope creep. It should be possible to close the task by checking acceptance criteria and evidence.

## Task metadata

| Field | Value |
|---|---|
| Task ID | `TASK-0000` |
| Parent epic/change/PRD | `<link>` |
| Priority | `P0` / `P1` / `P2` / `P3` |
| Assignee | `<name/team>` |
| Reviewer | `<name/team>` |
| Estimate | `<hours/days/points>` |
| Target environment | `dev` / `hml` / `prd` |
| Due date | `YYYY-MM-DD` |
| Status | `todo` / `in_progress` / `blocked` / `in_review` / `done` |

## 1. Objective

State the task objective in one sentence.

> Implement `<change>` so that `<outcome>` without `<constraint/risk>`.

## 2. Context

Explain why this task exists. Link to PRD, ADR, decision, incident, or change request.

Relevant context:

- `<context point>`
- `<context point>`

## 3. Scope

### In scope

- `<specific file/module/table/service/config>`
- `<specific behavior>`

### Out of scope

- `<explicit non-scope>`
- `<future task>`

## 4. Inputs

| Input | Source | Required? | Notes |
|---|---|---|---|
| `<input>` | `<source>` | yes/no | `<notes>` |

## 5. Expected deliverables

| Deliverable | Location | Acceptance evidence |
|---|---|---|
| `<code/doc/config/test>` | `<path/link>` | `<evidence>` |

## 6. Acceptance criteria

Use criteria that can be tested or reviewed.

- [ ] Given `<context>`, when `<action>`, then `<expected result>`.
- [ ] `<observable behavior>` is implemented.
- [ ] `<test>` passes in `<environment>`.
- [ ] `<logging/metrics/tracing/audit>` is present where relevant.
- [ ] `<documentation/runbook>` is updated where relevant.
- [ ] No unrelated files or behaviors are changed.

## 7. Technical approach

Write a short implementation plan. Do not over-design.

1. `<step>`
2. `<step>`
3. `<step>`

## 8. Files, modules, or assets allowed to change

| Path/asset | Allowed change | Notes |
|---|---|---|
| `<path>` | `<change>` | `<notes>` |

## 9. Forbidden scope

Explicitly prevent accidental expansion.

- Do not change `<area>`.
- Do not refactor `<module>` unless required for this task.
- Do not modify production configuration without a change record.
- Do not introduce a new dependency without reviewer approval.

## 10. Dependencies and blockers

| Dependency/blocker | Owner | Status | Impact |
|---|---|---|---|
| `<dependency>` | `<owner>` | open/closed | `<impact>` |

## 11. Test plan

| Test | Type | Command/method | Expected result |
|---|---|---|---|
| `<test>` | unit/integration/e2e/data-quality/model-eval/manual | `<command>` | `<result>` |

## 12. Observability and operations

| Signal | Required? | Implementation/evidence |
|---|---|---|
| Logs | yes/no | `<details>` |
| Metrics | yes/no | `<details>` |
| Traces | yes/no | `<details>` |
| Audit record | yes/no | `<details>` |
| Alerting | yes/no | `<details>` |
| Runbook update | yes/no | `<details>` |

## 13. Security, privacy, and compliance

| Question | Answer |
|---|---|
| Does this touch secrets or credentials? | `<yes/no/details>` |
| Does this touch personal/sensitive data? | `<yes/no/details>` |
| Does this change permissions? | `<yes/no/details>` |
| Does this require data governance review? | `<yes/no/details>` |
| Does this introduce a third-party dependency? | `<yes/no/details>` |

## 14. Completion evidence

| Evidence | Link | Notes |
|---|---|---|
| Pull request | `<link>` | `<notes>` |
| Test run | `<link>` | `<notes>` |
| Dashboard/log/trace | `<link>` | `<notes>` |
| Review approval | `<link>` | `<notes>` |

## 15. Handoff notes

Add concise notes for whoever continues, reviews, or operates the work.

- What changed: `<summary>`
- How to verify: `<steps>`
- Known limitations: `<limitations>`
- Follow-up tasks: `<links>`

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
