# Altitude START and State-Resolution Contract

**Version:** 1.0
**Status:** draft — W2; active in W3 when rules directory is created.
**Target location:** `rules/altitude-start.md`
**Current location:** `.specs/changes/harness-skill-based-migration/contracts/altitude-start.md`

**Governing ADRs:** ADR-0001, ADR-0004, ADR-0005, ADR-0006

---

## 1. Purpose

This contract defines:
1. The trigger conditions that activate the Altitude workflow.
2. The state-resolution steps the parent must complete before any Altitude phase executes.
3. The classification rules that distinguish Altitude from AgentSpec, direct-answer, and tactical routing.

---

## 2. Altitude START Trigger

Altitude START activates when **all** of the following are true:

| Condition | Concrete test |
|---|---|
| Not a `/workflow:*` command | First non-whitespace word is not `/workflow:` |
| Not a pure direct-answer request | Completing the request requires creating or modifying at least one `.specs/` or harness file |
| Not tactical data-engineering | Request does not contain keywords: SQL, dbt, schema, pipeline, Spark, BigQuery, Airflow, data quality, data contract (use Data Engineer coordinator for these) |
| Not a visual artifact request | Request does not start with `/visual:` |
| Not a README update | Request does not start with `core:readme-maker` |
| Requires a durable artifact | Response must produce one of: `00-intent.md`, `01-structure.md`, `prd.md`, ADR, `DESIGN.md`, `tasks/T-*.md`, or wave evidence |

**Ambiguous request handling:**

If two or more conditions above could apply, ask ONE focused question before routing:

```text
Decision point:

A. This is Altitude strategic durable work → create or advance a change under .specs/changes/.
B. This is AgentSpec feature work → use /workflow:* commands.
C. This is a direct answer → no state mutation needed.

Recommended: [state which based on request content]
```

Do not route silently. Do not default to Altitude for every large request.

---

## 3. Request Classification Table

Use the following table to classify every request before activating Altitude START:

| Request pattern | Classification | Route to |
|---|---|---|
| "Design a new X", "Plan migration of Y", "Create a system for Z" | Altitude new change | Intent phase |
| "Continue the migration", "Resume T-009", "What's next in W2?" | Altitude resume | Active phase agent |
| "Fix this SQL query" | Tactical data-engineering | Data Engineer coordinator |
| "What does this function do?" | Direct answer | No workflow activation |
| `/workflow:build my-feature` | AgentSpec | AgentSpec START |
| "Update the README" | Documentation | `core:readme-maker` |
| "Create a diagram of X" | Visual | `/visual:*` command |
| Ambiguous | Ask one question | See above |

---

## 4. State-Resolution Protocol

Before any Altitude phase executes, the parent must complete the following steps in order:

### Step 1 — Read active state

```bash
cat .specs/memory/active-state.md
```

Extract:
- `active_change`: the current change ID or absent.
- `active_task`: the current task ID and status.
- `active_phase`: the current phase.

### Step 2 — Detect conflict

A conflict exists if:
- `active-state.md` and the matching `state.md` disagree on phase.
- `active-state.md` references a change ID that does not exist in `.specs/changes/`.
- Two sources at the same priority level (ADR-0005) disagree on a destructive action.

If a conflict exists, apply the **state conflict policy**:

```text
STOP — do not proceed.

Present to the user:
A. Trust active-state.md (higher priority for machine-readable state).
B. Trust the change state.md (higher priority for change-specific artifacts).
C. Reset to a known good state (requires T-001 baseline checksums).

Do not resolve silently.
```

### Step 3 — Determine request classification

| Request type | Altitude action |
|---|---|
| New change | Create new change ID; start Intent phase |
| Resume active change | Route to the active phase agent |
| Resume specific past change | Confirm with user; restore from archive if needed |
| Ambiguous | Ask one focused clarification question |

### Step 4 — Acquire writer lease

The writer lease prevents two parent sessions from mutating the same change simultaneously.

**Lease schema:**

```yaml
# .specs/changes/{change_id}/.writer-lease.yaml
session_id: "{unique session identifier — use OPENCODE_SESSION_ID or timestamp}"
change_id: "{active change ID}"
acquired_at: "{ISO-8601 timestamp}"
heartbeat_interval_seconds: 60
expiry_at: "{acquired_at + 5 minutes — updated each heartbeat}"
host: "build | plan"
```

**Acquisition logic:**

1. Read `.specs/changes/{change_id}/.writer-lease.yaml` if it exists.
2. Extract `expiry_at` and `session_id`.
3. If `expiry_at` is in the future AND `session_id` differs from the current session:
   - **BLOCKED.** Do not proceed. Report: `"Writer lease held by session {session_id} until {expiry_at}. Cannot proceed."`
4. If `expiry_at` is in the past OR no lease file exists:
   - Write a new lease file with current session ID and expiry 5 minutes from now.
5. During the session, update `expiry_at` every 60 seconds (heartbeat).
6. On session end (Ship phase or error exit): delete the lease file.

**Stale lease recovery (W9 T-136 will implement programmatically; until then, use this manual protocol):**

```text
STALE LEASE DETECTED:
  session_id: {old session}
  expired_at: {time}

Options:
A. Take over — write new lease with current session; old session had a clean exit or crash.
B. Investigate — read the old session's evidence to determine if writes completed.
C. Abort — do not proceed; restore from T-001 baseline.

User must confirm A before takeover. Record the decision in bootstrap-decisions.md.
```

**Lease is NOT required for:**
- Read-only operations (reading state, evidence, contracts).
- Direct answers with no file mutation.
- Manual `@agent` invocations (out-of-band from managed state per ADR-0007).

---

### Step 5 — Load minimum context

Per ADR-0006 (staged activation):
- Always loaded: compact AGENTS.md kernel (W4+).
- Load on activation: Altitude workflow contract (this document).
- Load on phase entry: the specific phase sub-section of this contract.
- Load on task entry: the Task-Spec and relevant allocation.
- Do not preload all phases, all ADRs, or all shared contracts.

---

## 4. Altitude START Rule Text

The following text is the START rule to be placed in `rules/altitude-start.md` during W3:

```markdown
# Altitude START

**Activation condition:** Strategic durable work that requires creating or advancing a change under `.specs/changes/`.

**Do not activate for:**
- `/workflow:*` commands → AgentSpec START
- Simple questions with no file mutation → direct answer
- Tactical data-engineering work → Data Engineer coordinator

**On activation:**

1. Read `.specs/memory/active-state.md`.
2. Detect and resolve any state conflict (see `contracts/altitude-start.md` Step 2).
3. Determine request classification (new, resume, ambiguous).
4. Acquire writer lease for the active change ID.
5. Load `contracts/altitude-workflow-contract.md` (lazy, on activation only).
6. Route to the appropriate phase agent or start Intent phase.

**Source-of-truth hierarchy for state resolution:** ADR-0005, priority 1–10.
```

---

## 5. AgentSpec Bridge Prohibition Rule Text

The following prohibition clause is added to the Altitude workflow contract and to the START rule:

```text
An Altitude phase may not invoke any /workflow:* command or call the AgentSpec
workflow contract. If a sub-problem requires AgentSpec, create a separate
AgentSpec change request and pass control to the user. Do not automate the
bridge between the two workflows.
```

---

## 6. State Conflict Decision Record

Any state conflict resolved during a session must be recorded:

```yaml
# In .specs/memory/harness-skill-based-migration/bootstrap-decisions.md or equivalent
- entry_id: "{change_id}-conflict-{seq}"
  trigger: conflict_resolution
  conflict_type: state
  source_authority: current user instruction
  resolution: "{which source won and why}"
  evidence: "{path to conflicting files}"
```

---

## Changelog

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-21 | harness-skill-based-migration | Initial draft | T-021 W2 |
