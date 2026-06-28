---
name: review
description: Reusable review guidance for the native commands /review:review and /review:judge. Load this skill when reviewing code or requesting a second opinion.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 2.0.0
  category: commands
---

# Review Commands

This skill standardizes review work so the process is evidence-first instead of route-table-first.

## When to Use

- Use for `/review:review` and `/review:judge`.
- Use when the primary output is findings, risk assessment, or a second opinion.
- Do not use to start SDD phases.

## Workflow

1. Read the requested review command file.
2. Load only the agent and KB context needed for that review branch.
3. For `/review:review`, keep the output findings-first, severity-ordered, and path-cited.
4. For `/review:judge`, verify that the external judge prerequisite exists before attempting any verdict.
5. Stop instead of improvising if the runtime, credential, or file target is missing.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "A summary is enough without concrete findings." | Review value comes from findings, not generic reassurance. |
| "If the judge runtime is missing, I can fake a second opinion." | A fabricated second opinion is worse than no second opinion. |
| "I only need the diff." | Many review risks depend on full-file context. |

## Red Flags

- The review output starts with summary instead of findings.
- File paths and line numbers are omitted.
- Missing external judge prerequisites are silently ignored.
- The skill starts routing into non-review workflows.

## Verification

- [ ] The command-specific review file was read.
- [ ] Only the smallest useful review context was loaded.
- [ ] Findings are first and ordered by severity.
- [ ] File references are concrete.
- [ ] Judge runtime prerequisites were verified before judging.
