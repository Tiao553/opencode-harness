---
name: git-workflow-and-versioning
description: Safe commit, branch, PR, and release hygiene workflow. Use when work crosses commit, release, or versioning boundaries.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: lifecycle
---

# Git Workflow And Versioning

## When to Use

- Use when preparing commits, release checkpoints, PRs, or version-sensitive changes.
- Use when the agent must reason about staging, commit quality, or release sequencing.
- Do not use when the task does not cross a Git or release boundary.

## Workflow

1. Inspect the working tree and staged state before proposing a commit or release step.
2. Stage only the intended files.
3. Confirm that the change summary and commit message match the actual diff.
4. Run any mandatory quality or security gate before the commit suggestion.
5. Treat branching, tagging, and PR creation as explicit steps, not assumptions.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "I'll commit everything now and sort it out later." | Mixed commits reduce traceability and make rollback harder. |
| "The message can be generic if the diff is clear." | Generic commit messages lose intent and future audit value. |
| "The branch or PR step is obvious." | Release hygiene depends on explicit sequencing. |

## Red Flags

- The proposed commit includes unrelated changes.
- The commit message is generic.
- Mandatory gates were not run before a release-sensitive step.
- A PR or versioning step is implied without checking status or history.

## Verification

- [ ] Working tree and staged state were inspected.
- [ ] Only intended files are in scope.
- [ ] The message matches the actual diff.
- [ ] Mandatory gates ran before the sensitive Git step.
- [ ] Branch/PR/version sequencing was explicit.
