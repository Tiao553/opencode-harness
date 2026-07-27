# Dev Agent Parity Sheet — W5 Skill Conversion

**Purpose:** Record what each dev agent provides so the converted skill preserves full behavioral parity. Agent files are frozen after W5 and deleted after W11.

**Source:** T-003 agent inventory + direct agent file reads.
**Date:** 2026-07-25

---

## Parity Matrix

| Agent | Mode | Key tools | Trigger phrases | Load receipt required | Skill name |
|---|---|---|---|---|---|
| `dev.codebase-explorer` | subagent | bash, read, glob, grep, task, edit, skill | "explore codebase", "executive summary", "architecture analysis" | Yes | `dev-codebase-explorer` |
| `dev.faithfulness-guard` | subagent | read, bash, glob, grep, question | "validate response", "faithfulness check", "audit output" | Yes | `dev-faithfulness-guard` |
| `dev.judge-agent` | subagent | bash, read, glob, grep, task, webfetch | "judge this", "second opinion", "external review" | Yes | `dev-judge` |
| `dev.prompt-crafter` | subagent | bash, read, glob, grep, task, skill, edit | "create PROMPT.md", "build a prompt spec", "match agents to files" | Yes | `dev-prompt-crafter` |
| `dev.security-guardian` | subagent | bash, read, glob, grep, task, skill | "commit this", "security review", "check for secrets", "audit code" | Yes | `dev-security-guardian` |
| `dev.shell-script-specialist` | subagent | bash, read, glob, grep, task, edit, skill | "write a bash script", "create a shell script", "shell automation" | Yes | `dev-shell-script-specialist` |

## Freeze Decision

Agent files are frozen after W5 T-068. They remain in `agents/` until W11 validation confirms skill parity, then are deleted in W12 T-175. During W5–W11, the skill is the primary behavior; the agent file is legacy reference only.

## Overlap Assessment (T-069)

| Potential overlap | Resolution |
|---|---|
| `dev-faithfulness-guard` vs `review` skill | Distinct: faithfulness checks AGENTS.md principles; review checks code quality |
| `dev-judge` vs `review:judge` command | Distinct: judge skill is for second-opinion from external model; review:judge is the command entry point |
| `dev-security-guardian` vs security checks in review | Distinct: guardian is the pre-commit mandatory gate; review is analysis-only |
