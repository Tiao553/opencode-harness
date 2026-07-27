# CLI and Tool Routing Rule

**Trigger:** Any Bash command, shell invocation, or tool call.
**Load scope:** Lazy — loaded when Bash or a CLI tool is called.
**Governing ADR:** ADR-0006.

---

## Core rule

Use the most specific tool available. Prefer RTK wrappers for Git operations. Use raw commands only when RTK filters evidence required for diagnosis.

---

## Tool selection table

| Operation | Preferred tool | When to use raw |
|---|---|---|
| Git status / log / diff | `rtk git status`, `rtk git log`, `rtk git diff` | When RTK output is truncated and full diff is needed for evidence |
| GitHub operations | `gh` | Always |
| GCP operations | `gcloud` | Always |
| File search | `glob` tool | Replace `find` |
| Content search | `grep` tool | Replace `grep` (Bash) |
| Read file | `read` tool | Replace `cat`, `head`, `tail` |
| Edit file | `edit` tool | Replace `sed`, `awk` |
| Write new file | `write` tool | Replace `echo >`, `cat << EOF` |
| Checksum | `sha256sum` (raw bash) | No alternative |
| Count lines | `wc -l` (raw bash) | No alternative |
| Node.js scripts | `node -e '...'` (raw bash) | For data transforms only |

## Mandatory read-only policy for W3

All Bash commands in W3 must be read-only or write only to the allowed paths in `allocation.yaml`.

Forbidden commands in this wave:
- `git add`, `git commit`, `git push`, `git checkout`
- `npm install`, `bun install`
- Any command that writes to `agents/`, `commands/`, `skills/`, `plugins/`, `opencode.json`

## Evidence from commands

When a command is run as part of task evidence:
- Record the exact command in the evidence file.
- Record key output lines (not the full output unless it is short).
- Record the exit code if non-zero.

## Stop conditions

- STOP if a Bash command would write to a forbidden path.
- STOP if RTK is available but a raw Git command is used without documenting why.
- STOP if a command produces secrets or credentials in its output — redact before recording.

---

*Governing: ADR-0006, T-001 `evidence/baseline.md` (RTK availability).*
