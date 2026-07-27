# Altitude-Specific START

**Trigger:** Request is classified as Altitude strategic durable work by `START.md`.
**Load scope:** Lazy — loaded immediately after `START.md` classifies the request as Altitude.
**Governing ADRs:** ADR-0001, ADR-0004, ADR-0005. Source: W2 `altitude-start.md`.

---

## What activates Altitude START

All of the following must be true:

1. Request is not a `/workflow:*` command.
2. Response requires creating or advancing a `.specs/changes/` artifact.
3. Request is not tactical data-engineering, direct-answer, visual, or README work.

---

## Core rule

On Altitude START: read active state, resolve any conflict, acquire the writer lease, and load only the phase context needed. Do not load all contracts or all ADRs unconditionally.

---

## State-resolution steps (in order)

### 1. Read active state
```bash
cat .specs/memory/active-state.md
```
Extract: `active_change`, `active_task`, `active_phase`.

### 2. Detect conflicts
If `active-state.md` and the change `state.md` disagree, stop and present to user:
- A: Trust `active-state.md`
- B: Trust change `state.md`
- C: Reset from T-001 baseline

Do not resolve silently.

### 3. Classify request
| Request | Action |
|---|---|
| New change | Create new ID; start Intent phase |
| Resume active change | Route to active phase |
| Ambiguous | Ask one focused question |

### 4. Acquire writer lease
Create `.specs/changes/{change_id}/.writer-lease.yaml` with fields: `session_id`, `change_id`, `acquired_at`, `heartbeat_interval_seconds: 60`, `expiry_at`.
If an unexpired lease from another session exists: STOP and report.

### 5. Load minimum context
Per ADR-0006 — load only:
- This file (already loaded).
- `altitude-phases.md` for the active phase.
- The active Task-Spec when executing.
- No bulk preloading of all contracts or all ADRs.

### 6. Route to phase
Load `altitude-phases.md` and route to the appropriate phase agent or action.

---

## AgentSpec bridge prohibition

This rule applies for the duration of any Altitude session:

> An Altitude phase must not invoke any `/workflow:*` command or any AgentSpec subagent.
> If a sub-problem requires AgentSpec, create a separate change and pass control to the user.

## Stop conditions

- STOP if active-state.md and the change state.md disagree — surface conflict before proceeding.
- STOP if the writer lease is held by another session.
- STOP if the request is ambiguous between Altitude and another route — ask one clarification question.
- STOP if a `/workflow:*` command is detected — route to `agentspec-start.md` instead.

---

*Governing: ADR-0004, ADR-0001. Full contract: `.specs/changes/harness-skill-based-migration/contracts/altitude-start.md`.*
