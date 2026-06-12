---
name: security-and-hardening
description: Secrets, least privilege, auth boundary, dependency, and release hardening workflow. Use when code, config, or release work touches security-sensitive behavior.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: lifecycle
---

# Security And Hardening

## When to Use

- Use when work touches secrets, credentials, auth, RLS, PII, production access, or release gates.
- Use when security review must happen before a commit, deploy, or backend policy change.
- Do not use as a substitute for domain-specific implementation detail when the main task is purely feature delivery.

## Workflow

1. Identify the security boundary: secret handling, access control, data exposure, or release surface.
2. Check least privilege first.
3. Verify that no credential, token, or private key is hardcoded or staged accidentally.
4. Confirm deny cases, not just allow cases, for auth or policy work.
5. If release-related, run the required security gate before suggesting the release step.
6. Block on critical findings; do not downgrade them into stylistic warnings.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "It's only dev data." | Hardcoded secrets and weak policy patterns leak into production over time. |
| "The happy-path policy works." | Security design without deny-case checks is incomplete. |
| "We can clean up secrets before merge." | Secrets staged now are already a release blocker. |

## Red Flags

- Credentials appear in code, config, or staged diffs.
- Auth logic has no explicit deny tests.
- Service-role or bypass behavior has no justification.
- A critical finding is treated as informational.

## Verification

- [ ] The relevant security boundary was named.
- [ ] Least privilege was checked.
- [ ] Secrets and credentials were checked explicitly.
- [ ] Deny cases were considered for access-control work.
- [ ] Critical findings block the next sensitive step.
