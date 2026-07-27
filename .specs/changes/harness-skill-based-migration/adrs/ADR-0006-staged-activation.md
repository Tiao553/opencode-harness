---
template_id: adr
template_version: 1.0.0
document_type: architecture-decision-record
title: "ADR-0006: Staged activation — compact kernel always loaded, rules and skills lazy"
status: accepted
owner: parent
authors:
  - harness-skill-based-migration
reviewers:
  - T-V01 independent validator
approvers:
  - user (D-17 confirmed in session)
created: "2026-07-20"
updated: "2026-07-20"
effective_date: "2026-07-20"
domain: harness-architecture
system: opencode-harness-v3
confidentiality: internal
related_work_items:
  - T-016
  - D-17
related_documents:
  - OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md
  - .specs/changes/harness-skill-based-migration/adrs/ADR-0001-built-in-primary-hosts.md
tags:
  - activation
  - context-budget
  - lazy-loading
  - rules
  - skills
  - w1
summary: "Only the compact AGENTS.md kernel and global dispatch rule are always loaded; all phase rules, activity rules, and skills are loaded lazily on explicit trigger."
---

# ADR-0006: Staged Activation and Lazy Rule Loading

## Decision metadata

| Field | Value |
|---|---|
| ADR ID | `ADR-0006` |
| Status | `accepted` |
| Decision date | `2026-07-20` |
| Decision owner | harness-skill-based-migration parent |
| Technical area | harness-architecture / context-budget |
| Supersedes | none |
| Superseded by | none |

---

## 1. Context

The W0 baseline confirmed:

| Fact | Value | Source |
|---|---|---|
| `altitude-maestro.agent.md` size | 203 lines | T-001 baseline inventory |
| Lines loaded unconditionally per session | ~203 (full agent file) | T-004 |
| Phase rules in separate rule files | 0 — all rules are embedded in the coordinator prompt | T-004 |
| Skill trigger rules in AGENTS.md | 0 — skills are referenced but no mandatory trigger matrix exists | T-004 `t-004-behavior-ownership.md` |
| Load receipt mechanism | Absent | T-004 |
| Missing skill files referenced by existing skills | 2 (`workflow-define/SKILL.md`, `workflow-design/SKILL.md`) | T-004 |
| Context consumed per simple direct-answer request | Full 203-line coordinator prompt + all plugin injections | T-004 |

**Concrete cost:** A user asking "what is the current wave?" triggers the load of 203 lines of routing gates, phase rules, wave orchestration logic, and GRILL ME patterns — none of which is relevant to answering that question. By W4, if the kernel is not compacted, adding rules for Altitude START, AgentSpec START, six skill triggers, and W2–W3 phase logic will push the always-loaded context past 600 lines for every request.

---

## 2. Problem statement

We need to decide what loads at session start versus on demand so that context budget is predictable, always-loaded instructions are auditable, and phase/activity/skill loading is traceable.

---

## 3. Decision drivers

| Driver | Priority | Explanation |
|---|---:|---|
| Context efficiency | High | A 203-line unconditional load for every request is not proportional to request complexity |
| Auditability | High | What is always loaded must be observable with a simple line count |
| Lazy correctness | High | A lazy skill that is not triggered when it should be causes silent routing failures |
| Traceability | High | Load receipts enable post-hoc verification that correct skills were loaded |

---

## 4. Considered approaches

### Approach A: Load everything unconditionally at session start

**Concrete failure mode:** With the current 203-line `altitude-maestro` prompt, every simple direct-answer question consumes the equivalent of ~1800 tokens before the user's message is processed. By W4, adding Altitude START, AgentSpec START, six skill triggers, and W2–W3 phase rules will push this to ~600 lines (~5400 tokens) unconditionally. The T-005 baseline fixture `opencode run "Reply with exactly BASELINE_OK"` consumed 18,710 input tokens for a 7-token response — a 2671:1 ratio. Expanding the always-loaded context by 3x makes this ratio worse by the same factor.

**Why rejected:** Context budget waste is not bounded by request complexity. The baseline already shows a ratio that is unsustainable at full harness scale.

---

### Approach B: Lazy loading with no trigger documentation (current skill state)

**Concrete failure mode:** T-004 found two skill files referenced in `workflow-commands/SKILL.md` that do not exist: `skills/workflow-define/SKILL.md` and `skills/workflow-design/SKILL.md`. These references are not documented as intentional gaps — they appear to be missing implementations. If a user runs `/workflow:define`, the skill is referenced but not loaded; the command silently falls back to the general context. There is no load receipt, so the validator cannot detect that the mandatory skill was absent.

**Why rejected:** Silent skill-load failures are indistinguishable from successful loads. Missing trigger documentation makes the harness non-auditable.

---

### Approach C: Compact kernel always loaded; all phase rules and skills lazy on explicit trigger (chosen)

We decided to use **staged activation with a compact always-loaded kernel**.

The decision is:

- **Compact kernel (always loaded):** AGENTS.md contains only the information needed to classify the request and dispatch it. Maximum practical size: 250–350 lines. Contents: global dispatch START, high-level routing rules, source-of-truth hierarchy, and pointers to skills and rule files.
- **Phase/activity rules (lazy):** Altitude phase rules (Intent, Structure, Plan, Execution, Validation, Ship), AgentSpec workflow rules, and security rules are loaded from dedicated rule files only when their trigger pattern matches.
- **Skills (lazy, mandatory on trigger):** Skills are loaded only when their trigger condition fires. When a skill is mandatory for a task, a load receipt must be produced in evidence.
- **Load receipt:** Every lazy load produces a receipt entry (`required_skills`, `loaded_skills`) in the task evidence or session log.
- **Forbidden preloading:** No phase rule, AgentSpec workflow rule, or skill may be loaded unconditionally at session start.

---

## 5. Decision

We decided to use **staged activation with a compact always-loaded kernel (Approach C)**.

---

## 6. Rationale

| Driver | How Approach C satisfies it | Trade-off accepted |
|---|---|---|
| Context efficiency | Direct-answer requests load only the compact kernel | W4 kernel rewrite is a blocking prerequisite |
| Auditability | `wc -l AGENTS.md` gives the unconditional context cost at a glance | Kernel size target must be enforced by a static test |
| Lazy correctness | Trigger conditions in AGENTS.md determine skill loads | Missing triggers cause silent failures → must be tested |
| Traceability | Load receipts in evidence create an audit trail | W5 must implement load receipt generation |

---

## 7. Consequences

### Positive consequences

- Context budget for simple direct-answer requests is dramatically reduced.
- Always-loaded instructions are auditable with a simple line count.
- Load receipts enable W11 T-160 to verify lazy behavior in fixtures.
- Skills can be updated without changing AGENTS.md.

### Negative consequences

- W4 AGENTS.md rewrite must produce a kernel under the size target.
- Trigger rules must be precise; overly broad triggers cause unnecessary loads.
- Missing trigger rules cause silent routing failures (lazy not loaded when needed).

### Neutral consequences

- Skills already loaded lazily today. This ADR formalises the requirement and adds load receipts.

---

## 8. Implementation notes

| Area | Required rule |
|---|---|
| AGENTS.md kernel size | Maximum 250–350 lines after W4 |
| Rule file discovery | `rules/` directory; each file named by activity or phase |
| Skill trigger patterns | Defined in each `SKILL.md` `description` field and AGENTS.md trigger matrix (W4 T-054) |
| Load receipts | `required_skills: [x]` and `loaded_skills: [x]` in task evidence (W5 T-067, T-071) |
| Validation | W11 T-160 runs trigger/non-trigger fixture pairs |

---

## 9. Migration plan

| Step | What to do concretely | Owner | Verification command | Risk |
|---|---|---|---|---|
| 1 | Accept ADR; add freeze note to `altitude-maestro.agent.md` | T-016 | Note present in file | Low |
| 2 | Create `rules/` directory; create `rules/registry.md` listing all planned rule files and their trigger patterns | W3 T-030 | `ls rules/` returns registry and at least one rule file | Low |
| 3 | Write compact AGENTS.md kernel ≤ 350 lines: global dispatch START, hierarchy pointer, skill trigger table; extract all phase logic to `rules/` | W4 T-050 | `wc -l AGENTS.md` returns ≤ 350; `grep "altitude-maestro\|routing gate" AGENTS.md` returns zero | Medium |
| 4 | Implement skill trigger matrix in AGENTS.md: each row maps a keyword pattern to a mandatory skill name | W4 T-054 | `grep -c "skill:" AGENTS.md` returns ≥ 6 | Low |
| 5 | Add load receipt to each skill invocation: write `required_skills: [x]`, `loaded_skills: [x]` to task evidence | W5 T-067 | `grep "loaded_skills" .specs/changes/harness-skill-based-migration/evidence/*.md` returns at least one | Medium |
| 6 | Run trigger/non-trigger fixture pairs: confirm each skill loads only when its trigger fires | W11 T-160 | Each fixture log shows "skill loaded" or "skill not loaded" with correct result | Low |

---

## Change log

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-20 | harness-skill-based-migration | Initial draft | T-016 W1 ADR |
