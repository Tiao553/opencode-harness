# Security Guardrails

Security-sensitive work requires explicit scope and verification.

## Guardrails

- No secrets, tokens, credentials, or private keys in `.specs`.
- No destructive shell commands without explicit approval.
- No remote MCP with credentials unless approved for the active task.
- No auth, RLS, PII, or secret-handling changes without security review.
- Run the configured security gate before suggesting a commit.

## Required Evidence

Security-relevant tasks should record:

- files changed
- verification commands
- secret scan or pre-commit result when available
- residual risks
- rollback note
