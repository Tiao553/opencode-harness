# Migration and Rollback Guide — W12

**T-172 | Date:** 2026-07-25

---

## Prerequisites

```bash
bash test/w4-structural.sh     # PASS
bash test/w6-static-check.sh  # PASS
bash test/w7-compatibility.sh # PASS
bash test/w8-mcp-health.sh    # PASS
bash test/w9-state-check.sh   # PASS
bash test/w11-static-checks.sh # PASS
opencode run "BASELINE_OK"    # positive fixture PASS
```

---

## Cutover Steps (T-174 — awaiting manual approval)

1. Verify all prerequisite checks pass.
2. Back up current `opencode.json`: `cp opencode.json opencode.json.backup`.
3. Copy staged config: `cp .specs/changes/harness-skill-based-migration/staged/opencode.next.json opencode.json`.
4. Remove `_comment_status` key from `opencode.json`.
5. Copy kernel: `cp .specs/changes/harness-skill-based-migration/staged/AGENTS.next.md AGENTS.md`.
6. Restart OpenCode.
7. Run post-cutover smoke: `opencode run "BASELINE_OK"`.
8. Verify: `opencode mcp list`, `opencode debug skill`, `grep "mode: primary" agents/`.

---

## Rollback

If any post-cutover check fails:

```bash
cp opencode.json.backup opencode.json
git checkout AGENTS.md  # restore from T-001 baseline
```

The T-001 baseline checksum manifest is at:
`.specs/changes/harness-skill-based-migration/evidence/checksums.sha256`

---

## What Changes at Cutover

| Before | After |
|---|---|
| Custom primary: altitude-maestro | Built-in `build` as primary |
| AGENTS.md: 286 lines, coordinator-heavy | AGENTS.next.md: ~190 lines, kernel + triggers |
| No instructions in opencode.json | `instructions: [rules/START.md, AGENTS.next.md]` |
| 4 plugins (as before) | 4 plugins (altitude-context removed) |
| 2 MCPs connected | 2 MCPs connected (same) |

---

## What Does NOT Change at Cutover

- Agent files in `agents/` (the 6 dev agents are frozen but not deleted until T-175)
- Skills in `skills/`
- Commands in `commands/`
- `.specs/` state and memory
- Rules in `rules/`

---

## Post-Cutover Checklist (T-179)

```bash
opencode run "BASELINE_OK" --format json         # positive fixture
opencode debug agent altitude-maestro            # should no longer resolve as primary
opencode mcp list                                # filesystem + sequential-thinking connected
bash test/w11-static-checks.sh                  # all static checks still pass
```
