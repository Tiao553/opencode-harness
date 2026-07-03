---
template_id: "adr"
template_version: "1.0.0"
document_type: "architecture-decision-record"
title: "ADR: <decision title>"
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

# ADR: <decision title>

## How to use this template

Use this document when a decision changes architecture, platform boundaries, runtime behavior, data contracts, integration patterns, security posture, observability, deployment strategy, or long-term maintainability. Do not use an ADR for a minor implementation detail that can be explained in a pull request.

Recommended file name: `docs/adr/ADR-0001-short-title.md`.

## Decision metadata

| Field | Value |
|---|---|
| ADR ID | `ADR-0000` |
| Status | `proposed` / `accepted` / `rejected` / `deprecated` / `superseded` |
| Decision date | `YYYY-MM-DD` |
| Decision owner | `<name/team>` |
| Technical area | `<data-platform / ai-platform / backend / frontend / infra / security>` |
| Affected environments | `dev`, `hml`, `prd` |
| Supersedes | `<ADR-ID or none>` |
| Superseded by | `<ADR-ID or none>` |

## 1. Context

Describe the situation that forced the decision. Include current architecture, pain points, constraints, production incidents, scale expectations, team skills, cost pressure, compliance needs, and deadlines.

Write this section as a problem narrative, not as a solution pitch.

Example:

> The current ingestion layer uses one Airflow DAG per source. This works for a small number of sources, but it is becoming expensive to maintain as the number of pipelines grows. Configuration changes require code changes, and the same scheduling, retry, audit, and dependency logic is duplicated across DAGs.

## 2. Problem statement

State the decision problem in one sentence.

`We need to decide <what> so that <outcome> without <major constraint or risk>.`

Example:

`We need to decide how pipeline orchestration should be generated so that new data sources can be onboarded consistently without duplicating DAG code or increasing operational risk.`

## 3. Decision drivers

| Driver | Priority | Explanation |
|---|---:|---|
| Operational reliability | High | The decision must reduce failure modes and make recovery explicit. |
| Maintainability | High | The team must be able to change pipelines without fragile duplicated code. |
| Cost | Medium | Extra services are acceptable only if operational value justifies them. |
| Time to implement | Medium | The first version must be deliverable in the current release window. |
| Team familiarity | Medium | The solution should not require a large skill jump without a migration plan. |
| Compliance/security | High/Medium/Low | Explain audit, access, encryption, secrets, data retention, or privacy constraints. |

## 4. Considered options

### Option A: <option name>

Description:

- What this option does.
- Which components it introduces or removes.
- How it behaves in dev, hml, and prd.
- What operational ownership it requires.

Pros:

- `<benefit>`
- `<benefit>`

Cons:

- `<trade-off>`
- `<risk>`

When this option is best:

- `<condition>`

When this option is bad:

- `<condition>`

### Option B: <option name>

Repeat the same structure.

### Option C: <option name>

Repeat the same structure.

## 5. Decision

We decided to **<chosen option>**.

The decision is to:

- `<specific architectural rule>`
- `<specific boundary or ownership>`
- `<specific technology or pattern>`
- `<specific non-goal>`

This means the system will:

- `<runtime behavior>`
- `<deployment behavior>`
- `<observability behavior>`
- `<failure handling behavior>`

## 6. Rationale

Explain why the chosen option is better than the alternatives given the drivers above. Explicitly mention the trade-offs accepted.

| Decision driver | How the chosen option satisfies it | Trade-off accepted |
|---|---|---|
| Reliability | `<explanation>` | `<trade-off>` |
| Maintainability | `<explanation>` | `<trade-off>` |
| Cost | `<explanation>` | `<trade-off>` |
| Security/compliance | `<explanation>` | `<trade-off>` |
| Team operation | `<explanation>` | `<trade-off>` |

## 7. Consequences

### Positive consequences

- `<expected benefit>`
- `<expected benefit>`

### Negative consequences

- `<cost, complexity, migration burden, or limitation>`
- `<new dependency or operational risk>`

### Neutral consequences

- `<behavior that changes but is neither good nor bad>`

## 8. Implementation notes

This section is not a full implementation plan. Keep only the notes that are necessary to preserve architectural intent.

| Area | Required decision rule |
|---|---|
| Code organization | `<module/package/repository boundary>` |
| Configuration | `<where config lives and who owns it>` |
| CI/CD | `<required pipeline checks>` |
| Testing | `<minimum automated test coverage>` |
| Observability | `<logs/metrics/traces/audit expectations>` |
| Security | `<authn/authz/secrets/encryption requirements>` |
| Data contracts | `<schema/versioning/backward compatibility rules>` |
| Rollback | `<how the decision can be reversed or degraded>` |

## 9. Migration plan

| Step | Description | Owner | Exit criteria | Risk |
|---|---|---|---|---|
| 1 | `<prepare foundation>` | `<owner>` | `<criteria>` | `<risk>` |
| 2 | `<migrate first target>` | `<owner>` | `<criteria>` | `<risk>` |
| 3 | `<scale adoption>` | `<owner>` | `<criteria>` | `<risk>` |
| 4 | `<deprecate old path>` | `<owner>` | `<criteria>` | `<risk>` |

## 10. Validation plan

| Validation item | Method | Evidence expected | Owner |
|---|---|---|---|
| Functional correctness | `<test/integration/replay>` | `<link to evidence>` | `<owner>` |
| Performance | `<benchmark/load test>` | `<metric threshold>` | `<owner>` |
| Reliability | `<failure simulation>` | `<recovery evidence>` | `<owner>` |
| Observability | `<dashboard/log/trace review>` | `<dashboard link>` | `<owner>` |
| Security | `<review/scanning/access test>` | `<evidence link>` | `<owner>` |

## 11. Reassessment triggers

Create a new ADR if one of these conditions becomes true:

- `<scale threshold is exceeded>`
- `<cost threshold is exceeded>`
- `<incident pattern invalidates the decision>`
- `<security/compliance requirement changes>`
- `<vendor/tool/product capability changes materially>`
- `<team ownership or operating model changes>`

## 12. Related documents

- PRD: `<link>`
- Task: `<link>`
- Test spec: `<link>`
- Evidence: `<link>`
- Validation report: `<link>`
- Change request: `<link>`

## Example summary

Use the pattern below when summarizing an accepted ADR in another document:

> ADR-0007 accepted the use of configuration-driven DAG generation for ingestion pipelines. The main driver was maintainability at pipeline scale. The accepted trade-off is additional validation logic for configuration changes before deployment.

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
