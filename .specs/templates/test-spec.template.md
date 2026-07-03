---
template_id: "test-spec"
template_version: "1.0.0"
document_type: "test-specification"
title: "Test spec: <feature/system>"
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

# Test spec: <feature/system>

## How to use this template

Use this document to define how a product, data pipeline, service, AI feature, model, integration, or release will be tested. The test spec should connect requirements to scenarios, expected evidence, and exit criteria.

## Test spec metadata

| Field | Value |
|---|---|
| Test spec ID | `TST-0000` |
| Test level | `unit` / `integration` / `system` / `acceptance` / `performance` / `security` / `data-quality` / `model-eval` |
| Environment | `dev` / `hml` / `prd-shadow` / `prd` |
| Build/version under test | `<version/hash/tag>` |
| Test owner | `<name/team>` |
| Related PRD/requirements | `<links>` |
| Related change/release | `<links>` |

## 1. Objective

State what testing must prove.

> This test spec verifies that `<system/capability>` satisfies `<requirements>` under `<conditions>` before `<release/change/approval>`.

## 2. Scope

### In scope

- `<feature/API/table/model/pipeline/user flow>`

### Out of scope

- `<not tested here>`

## 3. Items under test

| Item | Version/path | Owner | Notes |
|---|---|---|---|
| `<item>` | `<version/path>` | `<owner>` | `<notes>` |

## 4. Requirement traceability

| Requirement ID | Requirement summary | Test scenario IDs | Evidence expected |
|---|---|---|---|
| FR-001 | `<summary>` | TS-001, TS-002 | `<evidence>` |
| NFR-001 | `<summary>` | TS-010 | `<evidence>` |

## 5. Test strategy

Describe the approach and why it is sufficient.

| Test type | Purpose | Tool/method | Coverage expectation |
|---|---|---|---|
| Unit | `<purpose>` | `<tool>` | `<coverage>` |
| Integration | `<purpose>` | `<tool>` | `<coverage>` |
| Data quality | `<purpose>` | `<tool>` | `<coverage>` |
| Performance | `<purpose>` | `<tool>` | `<coverage>` |
| Security | `<purpose>` | `<tool>` | `<coverage>` |
| AI/model evaluation | `<purpose>` | `<tool>` | `<coverage>` |
| Manual/UAT | `<purpose>` | `<method>` | `<coverage>` |

## 6. Test environment

| Environment item | Value | Notes |
|---|---|---|
| Environment | `<dev/hml/prd-shadow>` | `<notes>` |
| Dataset/data window | `<dataset/window>` | `<notes>` |
| Feature flags | `<flags>` | `<notes>` |
| External dependencies | `<services>` | `<notes>` |
| Secrets/credentials | `<reference only>` | `<do not paste secrets>` |
| Monitoring tools | `<tools>` | `<notes>` |

## 7. Test data

| Dataset/input | Purpose | Source | Refresh/reset method | Privacy considerations |
|---|---|---|---|---|
| `<data>` | `<purpose>` | `<source>` | `<method>` | `<notes>` |

## 8. Entry criteria

- [ ] Requirements are approved or explicitly accepted as testable draft.
- [ ] Build/version under test is identified.
- [ ] Environment is available.
- [ ] Test data is available and compliant.
- [ ] Required mocks, stubs, connections, and permissions are configured.
- [ ] Observability is enabled where required.

## 9. Test scenarios

### TS-001: <scenario name>

| Field | Description |
|---|---|
| Requirement IDs | `<FR/NFR IDs>` |
| Priority | Must/Should/Could |
| Type | unit/integration/e2e/data-quality/performance/security/model-eval/manual |
| Preconditions | `<conditions>` |
| Steps | `1. <step>`<br>`2. <step>`<br>`3. <step>` |
| Expected result | `<result>` |
| Evidence to collect | `<log/screenshot/query/result/dashboard>` |
| Automation status | automated/manual/planned |
| Pass/fail criteria | `<criteria>` |

### TS-002: <scenario name>

Repeat the structure above.

## 10. Negative, edge, and failure scenarios

| Scenario | Failure simulated | Expected behavior | Evidence |
|---|---|---|---|
| `<scenario>` | `<failure>` | `<graceful degradation/retry/error/audit>` | `<evidence>` |

## 11. Performance and scale criteria

| Metric | Load/profile | Target | Measurement method |
|---|---|---:|---|
| `<metric>` | `<profile>` | `<target>` | `<method>` |

## 12. Data quality criteria

| Rule ID | Rule | Severity | Expected result | Evidence |
|---|---|---|---|---|
| DQ-001 | `<rule>` | critical/high/medium/low | `<result>` | `<evidence>` |

## 13. AI/model evaluation criteria

Use when the system includes LLMs, RAG, prompts, agents, ML models, or ranking.

| Evaluation item | Metric/method | Dataset | Threshold | Evidence |
|---|---|---|---:|---|
| Retrieval quality | `<recall@k/mrr/hit rate/manual eval>` | `<dataset>` | `<target>` | `<link>` |
| Answer quality | `<rubric/LLM-as-judge/human eval>` | `<dataset>` | `<target>` | `<link>` |
| Safety/guardrails | `<test suite>` | `<dataset>` | `<target>` | `<link>` |
| Drift | `<feature/data/model drift>` | `<window>` | `<target>` | `<link>` |

## 14. Defect management

| Severity | Definition | Expected response |
|---|---|---|
| Critical | Blocks release or creates unacceptable business/security/data risk | Fix before release or formally accept with sign-off |
| High | Major functionality or reliability issue | Fix or mitigation required |
| Medium | Workaround exists; limited impact | Fix scheduled or accepted |
| Low | Minor issue | Track as follow-up |

## 15. Exit criteria

- [ ] All Must scenarios passed or have approved exception.
- [ ] No open Critical defects.
- [ ] High defects have fix, mitigation, or formal acceptance.
- [ ] Evidence records are linked.
- [ ] Validation report is ready or explicitly not required.
- [ ] Release/change owner accepts residual risk.

## 16. Test execution summary

| Scenario ID | Status | Executed by | Date | Evidence | Defect link |
|---|---|---|---|---|---|
| TS-001 | pass/fail/blocked/skipped | `<name>` | `YYYY-MM-DD` | `<link>` | `<link>` |

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
