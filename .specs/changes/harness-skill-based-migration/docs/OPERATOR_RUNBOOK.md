# Operator Runbook — Skill-Based Harness

**W12 T-171 | Date:** 2026-07-25
**Applies to:** OpenCode Harness post-W12 cutover.

---

## How to Start

The harness starts with the built-in `build` agent as the primary host. OpenCode loads `rules/START.md` and `AGENTS.next.md` from the `instructions` array.

```bash
# Verify runtime
opencode --version        # must be 1.18.3
opencode mcp list          # shows 2 connected MCPs
opencode debug skill       # shows 13+ skills including 6 dev-* skills
grep "mode: primary" agents/*.agent.md  # must return zero results
```

---

## Reading State

```bash
# What is the active change?
cat .specs/memory/active-state.md

# What is the current task?
cat .specs/changes/{change_id}/state.md
```

---

## How TODO Works

Only the parent session writes TODO. Entries use the format:
```text
BLOCO W{N} | T-{ID} | {title} | {scope} | owner: parent | validator: {name} | status: pending
```

Leaf subagents cannot write TODO (`task: deny`, `todowrite: deny` on all 73 agents).

---

## Leaf Delegation

1. Create envelope: task_id, allowed_files, forbidden_scope, acceptance_criteria, verification_commands, evidence_path, stop_conditions.
2. Leaf executes and returns result envelope.
3. Parent verifies evidence, updates ledger.

---

## MCP Health

```bash
opencode mcp list
# Expected: filesystem (connected), sequential-thinking (connected)
# Others: disabled pending configuration
```

If enabled MCP unavailable: continue in degraded mode. No fabricated results.

---

## Rollback

If any cutover check fails, restore immediately:

```bash
cp opencode.json.backup opencode.json
git checkout AGENTS.md
# Restart OpenCode
```

Full rollback procedure: `.specs/changes/harness-skill-based-migration/docs/MIGRATION_GUIDE.md` section "Rollback".

## Resume After Crash

1. Check `.specs/changes/{change_id}/.writer-lease.yaml` — if expired, safe to take over.
2. Read `active-state.md` + `state.md` — resolve conflicts (ADR-0005).
3. Confirm active task with user.
4. Re-acquire writer lease and continue.

---

## Common Failures

| Symptom | Action |
|---|---|
| Two sessions writing | Stop one; `bash test/w6-static-check.sh` |
| Task closed without evidence | Reopen task; create evidence file |
| MCP unavailable | Local-only mode; check `mcp-registry.yaml` |
| `mode: primary` agent found | `bash test/w6-static-check.sh`; fix |
| Kernel over 350 lines | Extract to lazy rule file |
