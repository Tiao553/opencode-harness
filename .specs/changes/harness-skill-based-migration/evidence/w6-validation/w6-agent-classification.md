# W6 Agent Classification and Leaf Protocol

**Wave:** W6 — Subagent-only runtime and leaf protocol
**Date:** 2026-07-25

---

## T-080: Agent Classification by Role

| Category | Count | Target disposition |
|---|---|---|
| Custom primary (`altitude-maestro`) | 1 | Stage removal in W10 `opencode.next.json`; delete in W12 |
| Custom inline primary (`data-engineer`) | 1 (inline only, file deleted) | Remove from `opencode.next.json` in W10 |
| Altitude phase agents (`altitude-*`) | 7 | Retire in W6 (role superseded by rules/ + compact kernel) |
| Dev agents (frozen, skills created) | 8 | Frozen in W5; delete in W12 T-175 |
| Specialist subagents (all others) | 57 | Remain as subagents; `task: deny` enforced |

---

## T-081: Staged Removal of Custom Primary Configuration

Primary removal is staged in `opencode.next.json` (W10 T-140). Not applied until W12.

```json
// Remove from opencode.next.json agent block:
// "altitude-maestro": { "mode": "primary" }  → removed entirely
// "data-engineer": { "mode": "primary" }     → removed entirely
```

---

## T-082: Retire Altitude Phase Agents

The 7 altitude phase agents (`altitude-execution`, `altitude-intent`, `altitude-memory`, `altitude-plan`, `altitude-report`, `altitude-structure`, `altitude-validation`) are superseded by:
- `rules/altitude-phases.md` — phase contract (W3)
- `staged/AGENTS.next.md` — routing logic (W4)
- `rules/altitude-start.md` — state resolution (W3)

Retirement notice added to their files. Files deleted in W12 T-175 after W11 lifecycle test passes.

---

## T-083: Retire Data Engineer Coordinator

The inline `data-engineer` primary has no backing file. Its removal is staged in `opencode.next.json` (W10). The tactical routing it provides moves to the Data Engineer section of the compact kernel (Section 3 of AGENTS.next.md).

---

## T-084: Canonical Leaf Profiles

All 73 specialist subagents now have the following canonical permission profile:
- `task: deny` — no recursive delegation
- `todowrite: deny` — no ledger writes
- Standard tools: `bash: allow`, `read: allow`, `glob: allow`, `grep: allow`, `edit: allow` (within allocation bounds)

---

## T-085: Leaf Permission Enforcement

**Applied:** 73/73 non-primary agents have `task: deny` and `todowrite: deny` in their permission block. Verified by node check: violations = 0.

---

## T-086: Leaf Result Envelope

Standard envelope defined in `rules/leaf-execution.md`. Every leaf session receives:
- `task_id`, `allowed_files`, `forbidden_scope`, `acceptance_criteria`, `verification_commands`, `evidence_path`, `stop_conditions`

Returns: `verdict: PASS|FAIL|BLOCKED`, `evidence_file`, `criteria_met`, `scope_clean`.

---

## T-087: Recursive Delegation Test

Static check: `grep -r "task: allow" agents/` must return only `altitude-maestro.agent.md`. Added to `test/w4-structural.sh` check 2.

---

## T-088: Parent Task Allowlist

Defined in W1 ADR-0007. Parent allowlist is staged in `opencode.next.json` agent block (W10 T-149). Until then, the parent session enforces sequential execution via TODO protocol.

---

## T-089: Concurrency and Manual Invocation Protocol

- Sequential default enforced by TODO ownership rule (`rules/todo-ownership.md`).
- Manual `@agent` invocation is out-of-band from managed state (documented in `rules/leaf-execution.md`).
- Parallel tasks require pre-declared independent file scope (W9 T-138).
