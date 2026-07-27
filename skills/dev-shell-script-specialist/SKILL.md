---
name: dev-shell-script-specialist
description: >-
  Use when the user needs production-grade Bash or shell scripts with best
  practices, error handling, and cross-platform compatibility. Trigger phrases:
  'write a bash script', 'create a shell script', 'help with shell
  automation', 'write a deploy script', 'create a cleanup script'.
---

# Dev Skill: Shell Script Specialist

## When to use

- User needs a production-grade Bash or POSIX sh script.
- User needs error handling, trap cleanup, and portable quoting.
- User asks "write a deploy script", "create a cleanup script", or "help with shell automation."

## Workflow

1. Clarify the script's purpose, inputs, expected outputs, and target shell.
2. Identify portability constraints (bash 3.x vs 4+, macOS vs Linux).
3. Write the script with:
   - `set -euo pipefail` at the top.
   - Quoted variables throughout (`"$var"` not `$var`).
   - `trap cleanup EXIT` for resource cleanup.
   - `--dry-run` flag for destructive operations.
   - Usage/help function at the top.
4. Validate the script: `bash -n script.sh` (syntax check).
5. If shellcheck is available: `shellcheck -S warning script.sh`.

## Output schema

```bash
#!/usr/bin/env bash
# Purpose: {purpose}
# Usage: {script.sh} [--dry-run]
set -euo pipefail

DRY_RUN=false
for arg in "$@"; do [[ "$arg" == "--dry-run" ]] && DRY_RUN=true; done

cleanup() { echo "Cleanup on exit"; }
trap cleanup EXIT

main() {
  # implementation
}
main "$@"
```

## Harness Integration

- **Invoked by:** Altitude Execution tasks that need bash scripts (e.g., `test/w4-structural.sh` in W4 T-057).
- **Output feeds:** Shell scripts used as evidence-producing verification commands.
- **Gate:** W11 T-160 tests rule loading (indirectly uses shell scripts as verification commands).

## Concrete output example

The W4 structural test (`test/w4-structural.sh`) was produced by this skill pattern:
- `set -euo pipefail` at top
- Named checks with `pass()`/`fail()` functions
- Explicit `ERRORS` counter
- Exit 0 on PASS, exit 1 on FAIL
- No hardcoded paths (uses variables)
- `bash -n` syntax check before delivery

```yaml
required_skills: [dev-shell-script-specialist]
loaded_skills: [dev-shell-script-specialist]
confirmed_by: "script with set -euo pipefail, quoted vars, trap, and syntax check"
```

## Stop conditions

- STOP if the script's purpose is unclear — ask for clarification before writing.
- Do NOT omit `set -euo pipefail` for production scripts.
- Do NOT suggest `eval` or unquoted variables.
