---
name: dev-security-guardian
description: >-
  Use as a MANDATORY pre-commit gate and whenever the task touches auth, RLS,
  secrets, PII, or permissions. Trigger phrases: 'commit this', 'git commit',
  'pre-commit', 'check for secrets', 'security review', 'audit this code',
  'check for PII'. Always invoke before git operations that stage production
  changes.
---

# Dev Skill: Security Guardian

## When to use (mandatory gate)

This skill is a **mandatory gate** when:
- Any git commit or push is requested.
- The task touches authentication, authorization, secrets, credentials, PII, or permissions.
- A security review is explicitly requested.

## Workflow

1. Run pre-commit hooks if available: `pre-commit run --all-files`.
2. Run secret scanner: check staged diff for API keys, tokens, bearer headers, passwords.
3. Run gitleaks if installed: `gitleaks detect --staged`.
4. Scan for PII patterns: email addresses, phone numbers, national IDs in code strings.
5. Check permission changes: new `allow: *`, new `mode: primary`, new MCP configurations.
6. Report findings by severity: CRITICAL (block commit), HIGH (require fix), MEDIUM (warn), LOW (info).
7. Suggest the exact commit command only after CRITICAL and HIGH are resolved.

## Output schema

```markdown
## Security Review Verdict: PASS / BLOCK
## Staged files reviewed: {count}
## Findings
| Severity | Finding | File | Line |
|---|---|---|---|
## Suggested commit command (only if PASS)
`git commit -m "..."`
```

## Harness Integration

- **Invoked by:** Mandatory gate before any `git commit` in the harness migration; W11 T-155 security review.
- **Output feeds:** W11 T-155 security report; BLOCK verdict prevents cutover.
- **Gate:** W11 T-155 exercises this skill end-to-end.

## Concrete output example

```markdown
## Security Review Verdict: PASS
## Staged files reviewed: 8
## Findings
| Severity | Finding | File | Line |
|---|---|---|---|
| low | FROZEN notice added to dev agent files may confuse some models | agents/dev.faithfulness-guard.agent.md | 3 |

## Suggested commit command
`git commit -m "W5: Add 6 dev skills; freeze legacy dev agent files"`
```

```yaml
required_skills: [dev-security-guardian]
loaded_skills: [dev-security-guardian]
confirmed_by: "PASS/BLOCK verdict with findings table; commit command only on PASS"
```

## Stop conditions

- STOP and emit BLOCK if any CRITICAL finding exists. Do not suggest a commit command.
- STOP if `pre-commit` or `gitleaks` cannot run and emit WARN (not PASS).
- Do NOT bypass this gate even if the user says "just commit it."
