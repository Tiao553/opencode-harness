---
template_id: adr
template_version: 1.0.0
document_type: architecture-decision-record
title: "ADR-0004: Altitude and AgentSpec are separate workflows with separate START rules"
status: accepted
owner: parent
authors:
  - harness-skill-based-migration
reviewers:
  - T-V01 independent validator
approvers:
  - user (D-08 confirmed in session)
created: "2026-07-20"
updated: "2026-07-20"
effective_date: "2026-07-20"
domain: harness-architecture
system: opencode-harness-v3
confidentiality: internal
related_work_items:
  - T-013
  - D-08
  - D-09
related_documents:
  - OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md
tags:
  - altitude
  - agentspec
  - workflow-isolation
  - w1
summary: "Altitude and AgentSpec are two separate workflows with independent contracts, START rules, and state; neither may mutate the other's state."
---

# ADR-0004: Altitude and AgentSpec Workflow Separation

## Decision metadata

| Field | Value |
|---|---|
| ADR ID | `ADR-0004` |
| Status | `accepted` |
| Decision date | `2026-07-20` |
| Decision owner | harness-skill-based-migration parent |
| Technical area | harness-architecture / workflow-isolation |
| Supersedes | none |
| Superseded by | none |

---

## 1. Context

The W0 baseline confirmed:

| Fact | Value | Source |
|---|---|---|
| Commands routing to workflow.* agents | 8 (`workflow:brainstorm`, `define`, `design`, `build`, `validate`, `ship`, `iterate`, `create-pr`) | T-004 `t-004-behavior-ownership.md` |
| Commands routing to altitude phase agents | 0 — all altitude routing is in coordinator prompts, not command files | T-004 |
| Shared canonical storage between both workflows | `altitude-maestro.agent.md` prompt handles both tactical and strategic routing | T-003 |
| AgentSpec write path | `sdd/features/{feature-name}/` via workflow commands | T-004 |
| Altitude write path | `.specs/changes/{change_id}/` via coordinator | T-004 |
| Enforcement preventing cross-write | None — T-004 found no static or runtime gate | T-004 |

**Concrete observed risk:** During the W0 execution, the active task was T-009 (state repair). If a user had simultaneously run `/workflow:ship` to ship a previous SDD feature, the workflow.ship-agent subagent would have been invoked. That subagent has `task: allow` and could have written to `.specs/changes/` if its prompt logic had been misdirected — there is no enforcement at the file-path level preventing it. The only isolation is prompt-level convention.

---

## 2. Problem statement

We need to decide whether Altitude and AgentSpec share a workflow contract so that routing and state isolation are deterministic without preventing both workflows from operating on the same repository.

---

## 3. Decision drivers

| Driver | Priority | Explanation |
|---|---:|---|
| State isolation | High | Altitude wave state must not be corrupted by AgentSpec commands |
| Compatibility | High | Existing `/workflow:*` command names must continue to work |
| Auditability | High | It must be possible to determine which workflow owns a given artifact |
| Simplicity | Medium | A single unified workflow would reduce documentation but creates isolation risk |

---

## 4. Considered options

### Option A: Unified workflow contract

**Concrete failure mode:** A unified contract must handle all possible request types through a single START rule. When the user says "ship the feature," the rule must decide whether to invoke `altitude-report` (Altitude Ship) or `workflow.ship-agent` (AgentSpec Ship). These two agents write to different paths and have different phase prerequisites. If the classification fails, `workflow.ship-agent` may archive `sdd/features/my-feature/` while Altitude mistakenly advances the wave state. There is no error message — both operations succeed individually, but the combined state is corrupted. The T-004 baseline found this exact risk: 8 workflow commands and 7 altitude phase agents share no classification boundary.

**Why rejected:** The consequence of a misclassification is silent state corruption across two different lifecycles with no automatic rollback.

---

### Option B: Separate contracts, separate START rules (chosen)

**Description:** Two independent workflow contracts and two independent START rules in AGENTS.md. A global dispatch START routes the request to one of the two. Altitude owns `.specs/changes/` state. AgentSpec owns `sdd/features/` artifacts. Neither may write to the other's canonical storage.

**Pros:**
- Isolation is structural, not a naming convention.
- Each workflow can evolve independently.
- `/workflow:*` commands remain backward-compatible (D-09).
- Altitude and AgentSpec can coexist on the same repository without collision.

**Cons:**
- Two contracts to maintain.
- Global dispatch START must correctly classify every request.
- W3 must define both START rules precisely.

---

## 5. Decision

We decided to **maintain separate workflow contracts and START rules (Option B)**.

The decision is:

- Altitude owns `.specs/changes/`, `.specs/memory/`, `.specs/archive/`, and the wave/phase lifecycle.
- AgentSpec owns `sdd/features/`, `sdd/archive/`, and the `/workflow:*` command lifecycle.
- A global dispatch START in AGENTS.md routes to the correct workflow.
- An Altitude-specific START activates when the request is strategic durable work.
- An AgentSpec-specific START activates when a `/workflow:*` command is invoked.
- No AgentSpec command may write to `.specs/changes/` or `.specs/memory/`.
- No Altitude phase may write to `sdd/features/`.
- Explicit `/workflow:*` command names remain compatible (D-09).

---

## 6. Rationale

| Driver | How Option B satisfies it | Trade-off accepted |
|---|---|---|
| State isolation | Separate canonical storage paths | Two contracts to maintain |
| Compatibility | `/workflow:*` names unchanged | AgentSpec still uses the same commands |
| Auditability | Each artifact path unambiguously identifies its workflow | Global dispatch must be well-tested |
| Simplicity | Single global START dispatches; specialists are behind it | W3 must define both START rules precisely |

---

## 7. Consequences

### Positive consequences

- Wave state cannot be corrupted by a `/workflow:build` invocation.
- Both workflows can be validated independently.
- W7 AgentSpec command refactoring is isolated from Altitude contract changes.

### Negative consequences

- W3 must define three START rules: global dispatch, Altitude START, and AgentSpec START.
- Ambiguous requests must be resolved by the global dispatch, not silently defaulted.

### Neutral consequences

- The six `workflow.*` agent files remain subagents; they are not affected by this ADR.

---

## 8. Implementation notes

| Area | Required decision rule |
|---|---|
| AGENTS.md | Global dispatch START + Altitude START + AgentSpec START (W3 T-040, T-041) |
| Storage | Altitude: `.specs/`; AgentSpec: `sdd/` |
| Prohibited cross-writes | AgentSpec must not write `.specs/changes/`; Altitude must not write `sdd/features/` |
| Command compatibility | `/workflow:*` commands route to AgentSpec START (D-09) |
| Validation | W7 T-152 verifies workflow isolation |

---

## 9. Migration plan

| Step | What to do concretely | Owner | Verification command | Risk |
|---|---|---|---|---|
| 1 | Accept ADR | T-013 | ADR accepted | Low |
| 2 | Create `rules/START.md` global dispatch rule: pattern-match on `/workflow:` prefix → AgentSpec START; explicit Altitude keywords → Altitude START | W3 T-031 | `grep "workflow:" rules/START.md` returns routing clause | Low |
| 3 | Create `rules/altitude-start.md`: activate only for strategic durable work; prohibit writes to `sdd/` | W3 T-040 | Altitude lifecycle fixture writes only to `.specs/changes/` | Medium |
| 4 | Create `rules/agentspec-start.md`: activate only on `/workflow:*` commands; prohibit writes to `.specs/changes/` | W3 T-041 | AgentSpec fixture writes only to `sdd/features/` | Medium |
| 5 | Add cross-write regression: assert `sdd/features/` unchanged after Altitude execution; assert `.specs/changes/` unchanged after AgentSpec execution | W7 T-152 | Both assertions pass in isolation fixture | Low |

---

## Change log

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-20 | harness-skill-based-migration | Initial draft | T-013 W1 ADR |
