---
template_id: adr
template_version: 1.0.0
document_type: architecture-decision-record
title: "ADR-0002: Parent session is the only managed TODO and state writer"
status: accepted
owner: parent
authors:
  - harness-skill-based-migration
reviewers:
  - T-V01 independent validator
approvers:
  - user (D-02 confirmed in session)
created: "2026-07-20"
updated: "2026-07-20"
effective_date: "2026-07-20"
domain: harness-architecture
system: opencode-harness-v3
confidentiality: internal
related_work_items:
  - T-011
  - D-02
  - D-15
related_documents:
  - OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md
  - .specs/changes/harness-skill-based-migration/adrs/ADR-0001-built-in-primary-hosts.md
tags:
  - todo
  - state
  - single-writer
  - w1
summary: "The parent session is the only entity permitted to create, update, or close entries in the managed TODO ledger and the active change state."
---

# ADR-0002: Parent Session as Single TODO and State Writer

## Decision metadata

| Field | Value |
|---|---|
| ADR ID | `ADR-0002` |
| Status | `accepted` |
| Decision date | `2026-07-20` |
| Decision owner | harness-skill-based-migration parent |
| Technical area | harness-architecture / state-management |
| Affected environments | global config (`~/.config/opencode`) |
| Supersedes | none |
| Superseded by | none |

---

## 1. Context

The W0 baseline confirmed the following concrete state relevant to TODO ownership:

| Fact | Value | Source |
|---|---|---|
| Subagents with effective `task: allow` | 75 | T-003 `t-003-agent-summary.md` |
| Subagents with explicit `todowrite: deny` | 0 | T-003 |
| Runtime plugin blocking TODO writes from leaves | None — `specs-state.ts` is an explicit no-op shim | T-004 `t-004-behavior-ownership.md` |
| Hard enforcement of single-writer at session level | None | T-004 |
| Writer lease or session lock mechanism | Absent from codebase | T-004 |
| Concurrent session prevention | None | T-004 |

In the current state, any of the 75 subagents can call `todowrite` without restriction. If a leaf subagent in a session calls `todowrite` to mark a task complete — even with fabricated evidence — the ledger accepts it. There is no mechanism to distinguish a parent-owned close from a leaf-originated close after the fact.

The `specs-state.ts` plugin comment at line 9 states explicitly: *"The hard gate therefore lives in the altitude agents and shared contracts until a runtime hook is available."* This means the current single-writer intent is convention only.

**Concrete failure scenario observed in T-005 baseline fixture:** The negative fixture sent to an unknown agent was silently routed to the default agent instead of failing. If a leaf agent had called `todowrite` during that fallback session, the ledger would have accepted the write with no indication it came from an unintended subagent.

---

## 2. Problem statement

We need to decide who may write to the managed TODO ledger and active change state so that task status is traceable to a single authority without silent parallel updates from leaf subagents or concurrent sessions.

---

## 3. Decision drivers

| Driver | Priority | Explanation |
|---|---:|---|
| Traceability | High | Every TODO change must have one identifiable actor |
| Consistency | High | Concurrent writes create irreconcilable state conflicts |
| Audit | High | The ledger is the migration's source of truth for progress |
| Leaf isolation | High | Leaves must not be able to close tasks they did not execute |
| Resume safety | High | A resumed session must find exactly the state the previous session left |

---

## 4. Considered options

### Option A: Allow any agent to write TODO (current state)

**Concrete failure mode:** A leaf subagent executing T-050 (AGENTS.md kernel rewrite) is allowed to call `todowrite` to mark its own task complete. The parent session has no way to know whether the close came from itself or from the leaf. If the leaf closes the task with a falsified evidence path, the T-V04 validator reads a ledger entry that looks correct but was not produced by the parent. The migration progresses on corrupted state. This happened silently: T-004 confirmed no runtime hook can detect this.

**Why rejected:** The ledger becomes an unreliable audit trail. T-V01 through T-V12 require a trusted ledger to certify wave completion.

---

### Option B: Soft convention — leaves should not write TODO

**Concrete failure mode:** Conventions work until a prompt injection, misconfigured leaf, or operator mistake breaks them. The T-005 baseline fixture showed that an unknown agent silently fell back to the default agent — a behavior that is not documented or detectable from the ledger. If that default agent had TODO-write permission (which all 75 agents currently do), a convention-only rule would not prevent the write. Post-incident review would not be able to identify which agent wrote the entry.

**Why rejected:** Indistinguishable from the current broken state. Does not reduce the auditing burden.

---

### Option C: Parent-only write with writer lease (chosen)

**Description:** Only the parent session may call `todowrite`. Leaf subagents receive `todowrite: deny` in their profiles. A writer lease with change ID, session ID, heartbeat, and expiry prevents a second parent from writing the same active change. Stale leases require user-confirmed recovery.

**Pros:**
- Single source of truth for all task status changes.
- Leaf subagents cannot close tasks they did not own.
- Concurrent session conflict is detected and surfaced, not silently allowed.
- Resume produces a deterministic ledger state.

**Cons:**
- W6 must implement leaf `todowrite: deny` in all subagent profiles.
- W9 must implement the writer lease mechanism.
- Until W6, the current global allow remains active; this ADR documents intent, not current enforcement.

**When best:** When the migration ledger is the authoritative audit trail.

---

## 5. Decision

We decided to **implement parent-only write with writer lease (Option C)**.

The decision is:

- Only the parent session may call `todowrite` on the managed ledger.
- All managed leaf subagents receive `todowrite: deny` and `task: deny` in their W6 profiles.
- A writer lease is required before any parent session writes to an active change.
- The lease contains: change ID, session ID, owner, acquired time, heartbeat interval, and expiry.
- A second parent session detecting an active lease must stop and surface the conflict.
- Stale lease recovery requires explicit user confirmation.
- Leaf results, evidence, and verdicts are passed to the parent via the result envelope, not written directly to state.

---

## 6. Rationale

| Decision driver | How Option C satisfies it | Trade-off accepted |
|---|---|---|
| Traceability | Every ledger entry has one actor: the parent | Parent session must be long-running |
| Consistency | Writer lease prevents concurrent corruption | Lease management adds W9 complexity |
| Audit | Ledger state is canonical at every point | Leaf results must be enveloped, not direct writes |
| Leaf isolation | `todowrite: deny` prevents accidental closes | W6 is a prerequisite |
| Resume safety | Lease recovery is explicit and user-confirmed | Stale lease requires manual intervention |

---

## 7. Consequences

### Positive consequences

- Migration ledger is the authoritative single source of truth for W0–W12 progress.
- T-V01 through T-V12 can verify ledger integrity mechanically.
- Leaf subagents cannot silently advance wave state.

### Negative consequences

- W9 writer lease is a prerequisite for full enforcement.
- W6 leaf profile updates are a prerequisite for `todowrite: deny`.
- Until then, single-writer is a convention backed by this ADR, not a runtime gate.

### Neutral consequences

- Leaf subagents still produce result envelopes; the parent writes the outcome to the ledger.

---

## 8. Implementation notes

| Area | Required decision rule |
|---|---|
| Leaf profiles | All subagent profiles set `todowrite: deny` (W6 T-085) |
| Writer lease | Implemented in W9 T-136 |
| Parent session | Only entity permitted to call `todowrite` in the managed harness |
| Recovery | Stale lease recovery requires user confirmation; documented in W9 T-134 |
| Rollback | Remove writer lease mechanism; restore global `todowrite: allow` from T-001 baseline |

---

## 9. Migration plan

| Step | What to do concretely | Owner | Verification command | Risk |
|---|---|---|---|---|
| 1 | Accept ADR; document single-writer intent in `state.md` allocation section | T-011 | Present in state.md | Low |
| 2 | Add `todowrite: deny` and `task: deny` to each leaf profile in `agents/*.agent.md` — 73 files, automated via batch edit | W6 T-085 | `grep -rL "todowrite: deny" agents/` returns zero non-primary agents | Medium |
| 3 | Implement writer lease: create `.specs/changes/{change_id}/.writer-lease.yaml` with `session_id`, `acquired_at`, `heartbeat`, `expiry_seconds: 300`; block a second parent that finds an unexpired lease | W9 T-136 | Concurrent session fixture: second session logs "lease held by session X" and exits | Medium |
| 4 | Implement stale lease recovery: if `heartbeat` is older than `expiry_seconds`, prompt user with session ID, acquired time, and confirm before takeover | W9 T-136 | Stale-lease fixture: expired lease is replaced after user confirmation | Low |
| 5 | Validate full traceability: every closed ledger entry has `actor: parent` and `evidence:` path | W11 T-153 | `grep -c "actor: parent"` in ledger equals total closed task count | Low |

---

## 10. Validation plan

| Validation item | Method | Evidence |
|---|---|---|
| No leaf `task: allow` at cutover | `grep -r "task: allow" agents/` returns zero after W6 | Command output |
| Writer lease blocks second session | Concurrent session fixture | W9 T-164 test log |
| Ledger entries each have one actor | Audit trace report | W11 T-153 |

---

## 11. Reassessment triggers

- OpenCode introduces a native single-writer TODO mechanism that supersedes this lease.
- The harness requires genuinely parallel parent sessions for independent changes.

---

## Change log

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-20 | harness-skill-based-migration | Initial draft | T-011 W1 ADR |
