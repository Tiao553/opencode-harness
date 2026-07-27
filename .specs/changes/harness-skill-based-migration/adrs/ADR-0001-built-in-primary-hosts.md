---
template_id: adr
template_version: 1.0.0
document_type: architecture-decision-record
title: "ADR-0001: Built-in primary hosts only"
status: accepted
owner: parent
authors:
  - harness-skill-based-migration
reviewers:
  - T-V01 independent validator
approvers:
  - user (D-01 confirmed in session)
created: "2026-07-20"
updated: "2026-07-20"
effective_date: "2026-07-20"
domain: harness-architecture
system: opencode-harness-v3
confidentiality: internal
related_work_items:
  - T-010
  - D-01
related_documents:
  - OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md
  - .specs/changes/harness-skill-based-migration/state.md
  - .specs/changes/harness-skill-based-migration/evidence/t-003-agent-summary.md
tags:
  - architecture
  - agents
  - primary-host
  - w1
summary: "Only OpenCode built-in build and plan agents may serve as the primary session host; no custom agent may be declared mode: primary."
---

# ADR-0001: Built-in Primary Hosts Only

## Decision metadata

| Field | Value |
|---|---|
| ADR ID | `ADR-0001` |
| Status | `accepted` |
| Decision date | `2026-07-20` |
| Decision owner | harness-skill-based-migration parent |
| Technical area | harness-architecture |
| Affected environments | global config (`~/.config/opencode`) |
| Supersedes | none |
| Superseded by | none |

---

## 1. Context

The W0 baseline (T-003, 2026-07-20) confirmed the following concrete state:

| Fact | Value | Source |
|---|---|---|
| Custom primary agents | 2 (`altitude-maestro`, `data-engineer`) | `t-003-agent-summary.md` |
| `altitude-maestro` size | 203 lines | `agents/altitude-maestro.agent.md` |
| `data-engineer` file state | Deleted from worktree; inline config survives in `opencode.json` | `t-003-agent-summary.md` |
| Subagents with effective `task: allow` | 75 (inherited from global `permission: allow`) | T-003, T-004 |
| Explicit `todowrite: deny` on any agent | 0 | T-003 |
| `altitude-maestro` permission in `opencode.json` | `"permission": "allow"` (grants all tools) | `opencode.json` lines 39–44 |
| Static enforcement of primary-count rule | None — T-004 found no runtime gate | `t-004-behavior-ownership.md` |

Custom primary agents control the system prompt, tool grants, and session behavior for every user interaction. Having more than one custom primary creates:

- **Ambiguous host selection:** When two primaries are registered, OpenCode may surface either depending on invocation path. The `data-engineer` inline entry still resolves as a primary even though its backing file is deleted — confirmed by `opencode debug agent data-engineer` during T-003.
- **Duplicate coordination logic:** `altitude-maestro` has 9 routing gates in its prompt; `data-engineer` has a separate tactical routing model. Neither knows the other's gate state.
- **Brittle permission inheritance:** Both primaries carry `"permission": "allow"`, which grants every tool to every subagent in their session with no file-scope restriction. This means any of the 75 subagents inherits Task, TODOWRITE, BASH, EDIT, and EXTERNAL_DIRECTORY without constraint.
- **Maintenance burden:** `altitude-maestro.agent.md` grew to 203 lines by Wave 25. Each new gate or routing rule added to the harness requires an edit to this file. T-004 found no mechanism to split the prompt into lazy-loaded pieces.
- **Migration risk:** Removing `altitude-maestro` and `data-engineer` from `opencode.json` at cutover is a single-step operation only if done atomically through the activation bundle. Partial removal — for example, removing `data-engineer` without simultaneously replacing the global permission model — leaves the harness with one custom primary instead of zero, which is still a ship-criteria failure.

---

## 2. Problem statement

We need to decide which agent is permitted to serve as the primary session host so that the harness behavior is predictable and auditable without introducing a custom coordination surface that competes with OpenCode's built-in hosts.

---

## 3. Decision drivers

| Driver | Priority | Explanation |
|---|---:|---|
| Predictability | High | The user must know exactly which agent is active at session start |
| Auditability | High | Every routing decision must be traceable to a rule file, not to prompt logic embedded in a coordinator |
| Permission safety | High | The primary host determines the root permission set for the session |
| Maintenance | High | Custom primary prompts accumulate and become hard to validate |
| Migration safety | High | Removing a custom primary mid-migration risks breaking the active session |
| OpenCode compatibility | High | Using built-in primaries reduces schema and update risk |

---

## 4. Considered options

### Option A: Keep custom primary agents indefinitely

**Description:** Retain `altitude-maestro` and `data-engineer` as custom primaries with full routing logic embedded in their prompts. Accept drift between the two prompts as a maintenance cost.

**Concrete failure mode:** `altitude-maestro` already has 9 routing gates across 203 lines. Adding W2–W12 logic to this file will push it past 400 lines. Beyond that, the model must parse the full primary prompt before every response regardless of request type — including simple direct answers that need no routing. The context cost of this is not bounded by request complexity. Additionally, `data-engineer` is an orphaned inline entry: its file was deleted before T-001, so its prompt is empty, but it still appears as a `mode: primary` in the runtime. Any session that selects `data-engineer` as the host has no instructions.

**Why rejected:** Violates invariant 1 (no custom primary at cutover) and invariant 2 (no managed leaf calls Task) simultaneously. It also prevents the context-budget optimization in ADR-0006 because the large coordinator prompt loads unconditionally.

---

### Option B: One custom primary only

**Description:** Remove the orphaned `data-engineer` entry from `opencode.json`. Keep `altitude-maestro` as the single custom primary. Reduce its prompt to a reasonable size.

**Concrete failure mode:** Even a single custom primary must be maintained in lockstep with every harness change. The W4 AGENTS.md rewrite, the W5 skill additions, and the W6 leaf-profile changes all require editing `altitude-maestro.agent.md` or `opencode.json` before they take effect. If a wave task forgets to update the coordinator, the runtime behavior and the documented behavior diverge silently. A single custom primary also means the global permission model remains `"permission": "allow"` until a later wave, which leaves all 75 subagents with unrestricted Task access. This option defers the permission problem rather than solving it.

**Why rejected:** Still violates invariant 1. Does not reduce context cost significantly because a single 200-line coordinator is still always loaded. Does not isolate the host's permission from routing logic.

---

### Option C: Built-in `build` and `plan` as the only primaries (chosen)

**Description:** The OpenCode built-in `build` (default interactive) and `plan` (plan mode) agents serve as the only primary hosts. Routing, coordination, and workflow logic moves to AGENTS.md instructions, mandatory skills triggered by pattern, and explicit command files. No `.agent.md` file and no `opencode.json` agent entry declares `mode: primary`.

**Pros:**
- Satisfies the non-negotiable invariant and the global ship criterion.
- Built-in primaries receive OpenCode updates without custom migration.
- Routing logic lives in AGENTS.md and skills, which are independently auditable and testable.
- Permission model is explicit per subagent, not inherited from a coordinator.
- Atomic cutover: removing custom primary entries from `opencode.json` is a single deterministic action.

**Cons:**
- AGENTS.md must carry all dispatch and routing logic that was previously in the primary prompt.
- Skills must be loaded lazily and correctly triggered; incorrect trigger rules cause missed routing.
- W4 (AGENTS.md kernel rewrite) is a prerequisite before this is fully operational.

**When this option is best:** When the harness must be deterministically auditable, OpenCode-compatible, and safely cutovarable in one atomic operation.

---

## 5. Decision

We decided to **use only built-in `build` and `plan` as primary hosts (Option C)**.

The decision is:

- No `.agent.md` file and no `opencode.json` agent entry may declare `mode: primary` at or after W12 cutover.
- `altitude-maestro` and `data-engineer` are frozen as custom primaries for the duration of the migration and removed in W6 (T-081).
- All routing and coordination logic moves to the compact AGENTS.md kernel (W4) and mandatory skill triggers.
- The built-in `build` agent is the default interactive host.
- The built-in `plan` agent is the plan-mode host.
- Subagents remain as `mode: subagent` file-backed agents with explicit allocation-bounded permissions.

This means the system will:

- Start every interactive session through the built-in `build` agent loading the compact kernel.
- Load phase rules, skills, and workflow contracts lazily via AGENTS.md trigger patterns.
- Produce no unresolvable routing conflict between two custom primaries.
- Allow static validation of the primary host with a single grep: `mode: primary` must not appear in any agent file after cutover.

---

## 6. Rationale

| Decision driver | How Option C satisfies it | Trade-off accepted |
|---|---|---|
| Predictability | One known built-in host per mode; no ambiguity | AGENTS.md must be well-structured |
| Auditability | Routing logic in AGENTS.md and skills is independently readable | More files to maintain than a single coordinator prompt |
| Permission safety | Per-subagent permissions; no broad primary grant | Each subagent must have explicit permission configuration |
| Maintenance | Built-in agents do not require prompt maintenance | W4 AGENTS.md rewrite is required before this is operational |
| Migration safety | Single atomic cutover action to remove two `opencode.json` entries | W6 preparation is a prerequisite |
| OpenCode compatibility | Uses the intended host mechanism; no schema risk | Requires W4 completion before it is fully testable |

---

## 7. Consequences

### Positive consequences

- Custom primary count reaches zero at W12 cutover — satisfying the global ship criterion.
- AGENTS.md becomes the single auditable source for dispatch logic.
- Static validation (`grep mode: primary`) works without spawning a session.
- OpenCode schema and version updates do not break custom coordinator prompts.
- T-V12 can verify compliance mechanically.

### Negative consequences

- W4 AGENTS.md rewrite is a blocking prerequisite before this decision is fully live.
- AGENTS.md context budget must be managed carefully to keep the kernel compact.
- Lazy skill loading depends on correct trigger patterns; missing triggers cause silent routing failures.

### Neutral consequences

- `/workflow:*` command files remain unchanged; they route to subagents, not to a primary.
- The user-facing interaction model is unchanged; the difference is internal to the host agent.

---

## 8. Implementation notes

| Area | Required decision rule |
|---|---|
| Agent files | No `.agent.md` may declare `mode: primary` at or after W12 cutover |
| Config | `opencode.json` `agent` block entries for `altitude-maestro` and `data-engineer` are removed in W6 T-081 |
| AGENTS.md | W4 delivers the compact kernel and global dispatch START |
| Testing | W4 T-057 adds structural tests that fail on `mode: primary` in agent files |
| Static validation | `grep -r "mode: primary" agents/` must return zero results after W6 |
| Rollback | Restore `altitude-maestro` and `data-engineer` `opencode.json` entries from T-001 baseline checksums |

---

## 9. Migration plan

| Step | What to do concretely | Owner | Verification command | Risk |
|---|---|---|---|---|
| 1 | Accept ADR; add comment `# frozen — ADR-0001` to `altitude-maestro` and `data-engineer` entries in `opencode.json` without changing behavior | W1 T-010 | `grep "frozen" opencode.json` | Low |
| 2 | Write `AGENTS.md` compact kernel: max 350 lines, global dispatch START, Altitude START trigger, AgentSpec START trigger, source-of-truth hierarchy pointer | W4 T-050 | `wc -l AGENTS.md; grep "mode: primary" agents/` returns zero new files | Medium |
| 3 | Create staged `opencode.json` fragment: remove `altitude-maestro` and `data-engineer` `agent` entries, replace global `permission: allow` with default-deny + explicit parent leaf allowlist | W6 T-081 | `opencode debug agent altitude-maestro` on staged config returns error (agent not found) | Low |
| 4 | Include fragment in activation bundle; rehearse rollback by restoring T-001 `opencode.json` checksum | W10 T-149 | `sha256sum opencode.json` matches T-001 manifest; then restore and re-verify | Low |
| 5 | Apply bundle atomically at cutover; run post-cutover smoke (`opencode run "BASELINE_OK"`) | W12 T-174 | Positive fixture returns BASELINE_OK; `grep -r "mode: primary" agents/` returns zero | Low |

---

## 10. Validation plan

| Validation item | Method | Evidence expected | Owner |
|---|---|---|---|
| No custom primary at cutover | `grep -r "mode: primary" agents/` returns zero results | Command output | W6 T-081 |
| Built-in build/plan respond correctly | Positive CLI fixture via `opencode run` | Test log | W4 T-057 |
| AGENTS.md kernel loads without custom primary | Runtime session start with `OPENCODE_PURE=0` | Agent list output | W4 T-057 |
| Static architecture check | Pre-commit or CI grep gate | Check log | W4 T-057 |

---

## 11. Reassessment triggers

Create a new ADR if one of these conditions becomes true:

- OpenCode introduces a new host mode that supersedes `build` and `plan`.
- The compact kernel cannot carry the required routing logic within the context budget.
- A new wave requires a temporary custom primary for a specific capability gap.

---

## 12. Related documents

- Roadmap V2: Confirmed decision D-01 and non-negotiable invariant 1.
- T-003 evidence: `evidence/t-003-agent-summary.md` — 2 current custom primaries.
- T-004 evidence: `evidence/t-004-behavior-ownership.md` — permission and enforcement baseline.
- W4: AGENTS.md kernel rewrite (T-050–T-059).
- W6: Leaf protocol and custom primary removal (T-080–T-089).
- W12: Cutover and cleanup (T-170–T-181).

---

## Review checklist

- [x] The objective is explicit and does not depend on hidden context.
- [x] Scope and non-scope are both defined.
- [x] The owner, reviewers, approvers, dates, status, and related work items are filled.
- [x] Assumptions, risks, dependencies, and open questions are visible.
- [x] Acceptance criteria or validation criteria are testable.
- [x] Evidence links are concrete, not generic statements.
- [x] Rollback, mitigation, or contingency is defined where risk exists.
- [x] Terms, IDs, tables, environments, and systems use canonical names.
- [x] The document can be understood by a new reviewer without the original meeting context.

---

## Change log

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-20 | harness-skill-based-migration | Initial draft | T-010 W1 ADR |
