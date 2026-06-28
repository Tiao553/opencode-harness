# Git Policy

Git operations are evidence and release hygiene, not the workflow itself.

## Rules

- Inspect status and diff before summarizing changes.
- Do not suggest a commit before the configured security gate runs.
- Do not run destructive git commands without explicit approval.
- Record meaningful verification output before shipping.
- Keep generated private `.specs` runtime artifacts out of commits unless a project explicitly opts in.
