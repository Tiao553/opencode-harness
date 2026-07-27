# W4 Activation Manifest — Staged Kernel

**Version:** 1.0
**Status:** Staged — activates on W12 cutover.
**Purpose:** Document exactly what changes when the W4 kernel is activated.

---

## Files Changed at Activation

| Action | File | Notes |
|---|---|---|
| Replace | `AGENTS.md` | Content replaced with `staged/AGENTS.next.md` |
| Add to `opencode.next.json` | `"instructions": ["rules/START.md", "AGENTS.next.md"]` | Lazy rule loading enabled |

---

## Pre-activation Checks

Before applying the W4 kernel, verify:

```bash
bash test/w4-structural.sh          # must exit 0
wc -l staged/AGENTS.next.md        # must be ≤ 350
test -f rules/START.md              # must exist
test -f rules/altitude-start.md    # must exist
test -f rules/agentspec-start.md   # must exist
test -f rules/_registry.md         # must exist
opencode run "BASELINE_OK" --format json  # positive fixture must PASS
```

---

## Rollback

1. Restore `AGENTS.md` from T-001 baseline: `sha256sum -c evidence/checksums.sha256` then restore.
2. Remove the `instructions` key from `opencode.next.json`.
3. Restart OpenCode.

---

## What the Kernel Does NOT Change

- Agent files in `agents/` — unchanged until W6.
- `opencode.json` — unchanged until W10.
- Skills in `skills/` — unchanged until W5.
- Commands in `commands/` — unchanged until W7.
