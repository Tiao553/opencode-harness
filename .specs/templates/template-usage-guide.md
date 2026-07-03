# Template usage guide

This guide explains how to apply the template kit consistently for engineering, data, AI, platform, product, and operations work.

## 1. Basic rule

Use the smallest artifact that makes the work clear, reviewable, and auditable.

A task does not need a full PRD when the context is already known. A production change should not skip a change record just because the code change is small. A release involving data, AI, security, permissions, or production behavior should have objective evidence and a validation conclusion.

## 2. Choose the right starting point

| Starting situation | First template | Why |
|---|---|---|
| New feature, data product, AI capability, or platform capability | `prd-template.md` | Clarifies problem, users, success metrics, and requirements. |
| Architecture or platform direction is unclear | `adr-template.md` | Captures alternatives, decision drivers, and consequences. |
| A team/process/product decision is needed | `decision.template.md` | Records rationale without overusing ADRs. |
| Work is already understood and needs execution | `task.template.md` | Defines scope, acceptance, tests, and evidence. |
| A production-impacting change is planned | `change.template.md` | Adds risk, approval, implementation, validation, and rollback. |
| Test strategy must be explicit | `test-spec-template.md` | Connects requirements to scenarios and evidence. |
| You need proof that something worked | `evidence.template.md` | Captures objective, reusable evidence. |
| You need a go/no-go conclusion | `validation-report-template.md` | Connects tests, evidence, defects, risk, and approval. |
| Something was shipped | `ship-summary-template.md` | Records actual release facts and follow-ups. |
| You need the current picture | `state.template.md` | Captures present state for continuity. |
| Leadership needs a decision-oriented update | `executive-report.template.md` | Summarizes status, risks, metrics, and asks. |

## 3. Recommended lifecycle

### Discovery and alignment

1. Create a PRD when the problem, user, and success definition are not yet stable.
2. Create decision records for non-architectural trade-offs.
3. Create ADRs for architectural decisions.
4. Convert approved requirements and decisions into tasks.

### Delivery

1. Each task must have clear acceptance criteria.
2. Each task that touches production, data, AI, security, or platform operation must declare validation and evidence expectations.
3. Each medium/high-risk release must have a test spec.
4. Each production change must have a change record.

### Validation and ship

1. Execute tests and capture evidence.
2. Produce a validation report when there is a release, production change, model update, data contract change, or high-risk task.
3. Execute the change and update the execution log.
4. Produce the ship summary after deployment.
5. Update state and executive reports as needed.

## 4. Front matter rules

All templates use YAML front matter. Keep it valid and parseable.

Required practices:

- Use ISO dates: `YYYY-MM-DD`.
- Use lists for authors, reviewers, approvers, tags, related documents, and related work items.
- Do not paste secrets, tokens, passwords, or private keys.
- Keep `summary` to one sentence.
- Keep `status` aligned with the actual review stage.
- Use canonical system names.
- Link to stable artifacts where possible.

Example:

```yaml
---
template_id: "task"
template_version: "1.0.0"
document_type: "task-specification"
title: "Task: Add audit export for failed pipeline runs"
status: "in_review"
owner: "data-platform"
authors:
  - "Sebastião Ferreira"
reviewers:
  - "data-platform"
approvers:
  - "tech-lead"
created: "2026-07-03"
updated: "2026-07-03"
effective_date: null
domain: "data-platform"
system: "lakehouse-orchestration"
confidentiality: "internal"
related_work_items:
  - "JIRA-1234"
related_documents:
  - "../prd/PRD-0007-orchestration.md"
tags:
  - "audit"
  - "airflow"
summary: "Adds exportable audit evidence for failed pipeline runs."
---
```

## 5. Review model

Use this review expectation:

| Artifact | Required reviewers |
|---|---|
| PRD | Product owner, tech lead, domain owner, QA/data/AI owner when relevant |
| ADR | Tech lead, architecture/platform owner, affected service/data owners |
| Decision | Decision owner and affected stakeholders |
| Task | Assignee and code/design/data reviewer |
| Test spec | QA/test owner, engineering owner, data/AI owner when relevant |
| Evidence | Validation owner or reviewer of the related test/change |
| Validation report | Product owner, tech lead, operations owner, security/governance when relevant |
| Change | Change owner, operations owner, affected teams, approvers by risk level |
| Ship summary | Release owner and operations/support owner |
| State | Maintainer and consuming stakeholders |
| Executive report | Program owner and report audience delegate |

## 6. Risk-based depth

| Risk | Documentation depth |
|---|---|
| Low | Task + acceptance criteria + basic evidence. |
| Medium | Task + test spec + evidence + change record if production impact exists. |
| High | PRD/ADR as needed + task + test spec + evidence + validation report + change record + ship summary. |
| Critical | Same as high, plus explicit approvals, rollback proof, communication plan, and post-implementation review. |

## 7. Quality bar

A document is not ready if:

- The objective is unclear.
- Scope is open-ended.
- Acceptance criteria cannot be tested.
- Risks are hidden or generic.
- The evidence section says only "done" or "passed".
- Rollback is "revert code" without concrete steps.
- The document depends on meeting memory.
- Reviewers cannot tell what decision or action is requested.

## 8. Practical workflow example

For a new AI/RAG feature:

1. Create a PRD for the user problem, retrieval scope, answer quality goals, security constraints, and success metrics.
2. Create ADRs for vector store, chunking strategy, metadata model, and evaluation strategy if these decisions are significant.
3. Create tasks for ingestion, indexing, retrieval API, prompt versioning, evaluation dataset, monitoring, and UI/API integration.
4. Create a test spec covering retrieval quality, answer quality, latency, hallucination checks, access control, observability, and failure modes.
5. Capture evidence from evaluation runs, logs, traces, dashboard screenshots, and test reports.
6. Write a validation report with a clear release conclusion.
7. Open a change record for production deployment.
8. Write a ship summary after deployment.
9. Update state and executive report if this is part of a larger program.

## 9. Automation suggestions

Good future automation targets:

- Validate YAML front matter.
- Enforce required fields by document type.
- Check broken links.
- Check missing evidence links before closing tasks.
- Require validation report for medium/high-risk changes.
- Generate a traceability matrix from IDs.
- Generate executive summaries from state and ship summaries.
