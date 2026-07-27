# W9 Protocol Implementation

**Wave:** W9 — TODO, state, validation, and memory integration
**Date:** 2026-07-25

---

## T-130: Parent TODO Protocol

The managed TODO ledger follows the taxonomy:
```text
BLOCO W{N} | T-{ID} | {title} | {scope} | owner: parent | validator: {name} | status: pending|in_progress|done|blocked
```

Rules (from `rules/todo-ownership.md`):
- Only the parent session calls `todowrite`.
- Every entry must have `actor: parent` and an `evidence:` path before closing.
- One `in_progress` at a time; blocked entries require an explicit reason.

---

## T-131: Block Validation Scheduling

A validation task (T-Vxx) is created when all execution tasks in a validation block reach `done`. The validator is independent from the implementer. FAIL creates remediation tasks — never auto-repairs.

Block assignment is declared in `DESIGN.md` before Execution starts (W2 contract sec. 6, 4-Doc Gate).

---

## T-132: Dual-Write Memory Events

Protocol (from `rules/dual-memory.md`):
1. Write to `.specs/memory/{change_id}/{entry_id}.yaml` — synchronous, blocking.
2. Append to `.specs/memory/index.md`.
3. Attempt MCP `memory` server duplicate — async, non-blocking. Log: `pending|synced|failed`.

Memory server is currently disabled (W8). Local write is the only active path. Dual-write activates when `memory` MCP is enabled.

---

## T-133: State and Memory Reconciliation

When a session resumes:
1. Read `.specs/memory/active-state.md`.
2. Read the change's `state.md`.
3. Compare — if conflict: apply ADR-0005 hierarchy (change `state.md` is priority 5; `active-state.md` is priority 7 — change artifacts win).
4. If MCP memory is enabled: compare local vs MCP — local wins.
5. Present conflict and resolution to user before advancing.

---

## T-134: Resume Protocol

```text
1. Check writer lease — acquire or confirm ownership.
2. Read active-state.md + change state.md.
3. Resolve conflicts (ADR-0005).
4. Re-run health checks (MCP available? Rules loaded?).
5. Confirm active task with user if ambiguous.
6. Load only the active phase rules.
```

---

## T-135: Audit and Trace Report

The trace report is generated from: `.specs/changes/{change_id}/tasks/*.md`, `.specs/changes/{change_id}/evidence/*.md`, and `.specs/memory/index.md`.

Format: `request → classification → phase → task → leaf → evidence → validation → memory → ship`.

Script: `tools/harness-trace-report.sh` (staged for W10 T-147 tool consolidation).

---

## T-136: Writer Lease Schema

```yaml
# .specs/changes/{change_id}/.writer-lease.yaml
session_id: "{OPENCODE_SESSION_ID or timestamp}"
change_id: "{change_id}"
acquired_at: "{ISO-8601}"
heartbeat_interval_seconds: 60
expiry_at: "{acquired_at + 5 minutes}"
host: "build"
```

Acquisition: write if file absent or expired. Block if file exists and not expired with different session_id. Recovery: user confirms takeover.

---

## T-137: Memory Governance

```yaml
namespace: "{harness_version}/{repo_id}/{change_id}/{entry_id}"
retention: "Active: keep. Archived: keep 90 days. Deleted: immediately."
redaction: "No secrets, PII, or raw MCP dumps."
isolation: "Change memory is scoped to change_id — no cross-change reads."
```

---

## T-138: Validation Block Declaration

Each `DESIGN.md` must include:
```markdown
## Validation Blocks
| Block ID | Tasks | Validator |
|---|---|---|
| V-1 | T-001, T-002 | independent-leaf-validator |
```

Block boundaries cannot change during Execution without parent/user approval.

---

## T-139: Native TODO Capability Mapping

OpenCode native TODO fields: `content` (string), `status` (pending|in_progress|completed|cancelled), `priority` (high|medium|low).

Harness semantic mapping:
- Harness `block_id` → encoded in `content` prefix `BLOCO W{N}`
- Harness `evidence` path → encoded in `content` suffix `| evidence: {path}`
- Harness `actor` → implicit (parent session always)
- Harness `validator` → encoded in `content` `validator: {name}`

Durable state for unsupported semantics: use `.specs/changes/{change_id}/state.md`.
