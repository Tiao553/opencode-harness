---
template_id: adr
template_version: 1.0.0
document_type: architecture-decision-record
title: "ADR-0007: Delegation allowlist, sequential concurrency, and manual invocation policy"
status: accepted
owner: parent
authors:
  - harness-skill-based-migration
reviewers:
  - T-V01 independent validator
approvers:
  - user (D-03, D-05, D-13, D-14 confirmed in session)
created: "2026-07-20"
updated: "2026-07-20"
effective_date: "2026-07-20"
domain: harness-architecture
system: opencode-harness-v3
confidentiality: internal
related_work_items:
  - T-017
  - D-03
  - D-05
  - D-13
  - D-14
related_documents:
  - OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md
  - .specs/changes/harness-skill-based-migration/adrs/ADR-0002-single-writer-todo.md
tags:
  - delegation
  - concurrency
  - allowlist
  - leaf
  - w1
summary: "Managed delegation is default-deny with an explicit parent allowlist, sequential by default, and manual invocation is out-of-band from managed state."
---

# ADR-0007: Delegation Allowlist, Concurrency, and Manual Invocation

## Decision metadata

| Field | Value |
|---|---|
| ADR ID | `ADR-0007` |
| Status | `accepted` |
| Decision date | `2026-07-20` |
| Decision owner | harness-skill-based-migration parent |
| Technical area | harness-architecture / delegation |
| Supersedes | none |
| Superseded by | none |

---

## 1. Context

The W0 baseline confirmed:

| Fact | Value | Source |
|---|---|---|
| Subagents with effective `task: allow` | 75 | T-003 |
| Subagents with explicit `task: deny` | 0 | T-003 |
| Parent allowlist mechanism | Absent | T-004 |
| Recursive delegation enforcement | None — T-004 found no static or runtime gate | T-004 |
| Documented concurrency limit | None | T-004 |
| Manual `@agent` invocation behavior | No defined policy; no state isolation | T-004 |

**Concrete failure scenario:** During W0 T-009 (state repair), the parent session was the only active agent. If a second terminal session had opened a new OpenCode session against the same working directory and a user ran `/workflow:build my-feature`, the `workflow.build-agent` subagent would have had `task: allow` and could have invoked additional subagents. Those subagents would have had `edit: allow` and could have modified `.specs/memory/active-state.md` — the same file T-009 was rewriting. There is no lock, no detection, and no audit trail distinguishing the two sessions' writes.

**Second concrete scenario:** The T-004 behavior inventory found that `dev.faithfulness-guard` is a subagent with `task: allow` but its effective scope is undefined. If it was invoked as part of a validation step and decided to delegate to `dev.judge-agent` (also `task: allow`) to get a second opinion, that recursive chain would proceed without any parent knowledge or ledger entry.

---

## 2. Problem statement

We need to decide who may delegate work to subagents and under what conditions, so that the delegation chain is bounded, auditable, and cannot be extended by a leaf into an unbounded recursive call tree.

---

## 3. Decision drivers

| Driver | Priority | Explanation |
|---|---:|---|
| Bounded delegation | High | The delegation graph must be a tree with known depth, not an unbounded call chain |
| Auditable state | High | Every delegation must appear in the parent ledger with a task ID and evidence contract |
| Permission safety | High | 75 subagents with `task: allow` is an unbounded attack surface |
| Operational predictability | High | Sequential execution makes timing, resource, and conflict behavior predictable |

---

## 4. Considered approaches

### Approach A: Unrestricted delegation (current state)

**Concrete failure mode:** `dev.faithfulness-guard` (subagent, `task: allow`) validates a response and decides it needs a second opinion. It delegates to `dev.judge-agent` (subagent, `task: allow`), which decides it needs a third source and delegates to `data-engineering.ai-data-engineer` (subagent, `task: allow`). Each of these three sessions can write to allowed paths, call APIs, and produce evidence files — none of which appears in the parent ledger. The parent closes the ledger with a single delegation entry; the actual work involved three nested sessions. This is not detectable post-hoc.

**Why rejected:** Unbounded recursive chains produce evidence that the parent did not authorize, approve, or verify.

---

### Approach B: Sequential convention — leaves should not call task

**Concrete failure mode:** T-004 found no runtime enforcement. A convention requires every leaf prompt to include a "do not delegate" instruction. If a prompt is long enough, the model may not attend to that instruction. The T-005 baseline fixture showed that the default agent processed a request labeled "baseline negative fixture" without any restriction — conventions are not reliable for security-critical behavior.

**Why rejected:** Same failure mode as the current state when the prompt is complex or when prompt injection occurs.

---

### Approach C: Default-deny allowlist with sequential execution and explicit lease (chosen)

---

## 5. Decision

We decided on **explicit parent allowlist, sequential default, and out-of-band manual invocation**.

The decisions are:

**Delegation allowlist (D-13):**
- The parent session has a `task: allow` permission for all subagents via the global config.
- At cutover, the managed parent Task permission becomes default-deny with an explicit allowlist of pre-registered leaf names.
- No leaf may be delegated to without an entry in the allowlist and a parent TODO ID.
- Allowlist entries include: name, scope, allowed files, forbidden files, evidence contract, and stop condition.

**Recursive delegation (D-05):**
- Managed leaf subagents may not call `task` to create further subagents.
- Any attempted recursive delegation is a stop condition.
- Unmanaged chains from manual invocation are out-of-band and do not affect managed state.

**Sequential default (D-14):**
- Managed delegation is sequential by default: one active leaf at a time.
- Parallel delegation requires pre-registered independent tasks with no shared file scope.
- The parent must declare parallel tasks before execution begins; runtime discovery of parallelism is not permitted.

**Manual invocation policy:**
- Manual `@agent` invocation from the user is out-of-band from managed state.
- A manually invoked agent cannot close a managed task, update the managed ledger, or advance wave state.
- If a manual session produces output that the parent needs, the parent must explicitly import it with evidence.

---

## 7. Consequences

### Positive consequences

- Delegation scope is bounded and auditable before execution.
- Recursive delegation is prevented structurally, not by convention.
- Parallel work requires advance declaration, which prevents hidden scope conflicts.
- Manual invocation cannot corrupt managed state.

### Negative consequences

- W6 must implement `task: deny` on all leaf profiles and build the allowlist mechanism.
- Parallel tasks require upfront planning, which adds W1 design overhead.
- Manual agent output cannot be automatically imported; it requires a parent import step.

---

## 8. Implementation notes

| Area | Required rule |
|---|---|
| Parent Task permission | Default-deny at cutover; allowlist in activation bundle (W6 T-088) |
| Leaf `task` permission | `task: deny` in all leaf profiles (W6 T-085) |
| Recursive delegation | Detected by static check: no leaf may have `task: allow` (W4 T-057) |
| Sequential default | Documented in W9 TODO protocol (T-130) |
| Parallel tasks | Declared in Design/Plan before execution; independent file scope required |
| Manual invocation | Documented in W6 T-089; tested in W11 T-158 |

---

## 9. Migration plan

| Step | What to do concretely | Owner | Verification command | Risk |
|---|---|---|---|---|
| 1 | Accept ADR | T-017 | ADR accepted | Low |
| 2 | Write `agents/*.agent.md` batch edit: add `task: deny` and `todowrite: deny` to permission block of every non-primary agent (73 files) | W6 T-085 | `grep -rL "task: deny" agents/` returns only `altitude-maestro.agent.md` | Medium |
| 3 | Add parent Task allowlist to staged `opencode.json` fragment: `"agent.altitude-execution": { "permission": { "task": { "altitude-intent": "allow", "altitude-structure": "allow", ... } } }` | W6 T-088 | `opencode debug agent altitude-execution` shows only allowlisted agents | Medium |
| 4 | Add static check: `grep -r "task: allow" agents/` must fail the pre-commit hook | W4 T-057 | `pre-commit run --all-files` fails on any leaf `task: allow` | Low |
| 5 | Test manual invocation isolation: invoke `altitude-validation` manually while a parent session is active; verify no managed task closes | W11 T-158 | Ledger unchanged; manual session produces no ledger entry | Low |

---

## Change log

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-20 | harness-skill-based-migration | Initial draft | T-017 W1 ADR |
