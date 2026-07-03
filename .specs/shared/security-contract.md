# Security Contract

**Version:** 1.0
**Last Updated:** 2026-06-29
**Owner:** altitude-execution

## Overview

This contract defines pre-write security scanning rules, sensitivity classifications, and secure logging practices for the Harness V3 execution harness.

The security gate runs before any file write to:
- Detect secrets (AWS keys, API tokens, passwords)
- Detect PII (SSN, phone numbers, email patterns)
- Classify findings by severity
- Block HIGH/CRITICAL findings
- Warn on MEDIUM findings
- Log LOW findings for audit

## Scan Rules

### Secrets Detection

| Pattern | Name | Severity | Regex |
|---------|------|----------|-------|
| AWS_ACCESS_KEY | AWS Access Key ID | HIGH | `AKIA[0-9A-Z]{16}` |
| AWS_SECRET_KEY | AWS Secret Access Key | HIGH | `aws_secret_access_key\s*=\s*[^\s]{20,}` |
| GITHUB_TOKEN | GitHub Token | HIGH | `ghp_[A-Za-z0-9_]{36,255}` |
| SLACK_TOKEN | Slack Token | HIGH | `xoxb-[0-9]{10,13}-[0-9]{10,13}-[A-Za-z0-9]{24}` |
| GENERIC_API_KEY | Generic API Key | MEDIUM | `api[_-]?key\s*[:=]\s*[^\s]{16,}` |
| JWT_TOKEN | JWT Bearer Token | MEDIUM | `Bearer\s+eyJ[A-Za-z0-9_-]{10,}` |
| PRIVATE_KEY | Private Key Header | HIGH | `-----BEGIN (RSA\|EC\|OPENSSH) PRIVATE KEY-----` |
| PASSWORD_VAR | Password Assignment | MEDIUM | `password\s*[:=]\s*['\"][^\s]{8,}['\"]` |

### PII Detection

| Pattern | Name | Severity | Regex |
|---------|------|----------|-------|
| SSN | Social Security Number | HIGH | `\d{3}-\d{2}-\d{4}` |
| PHONE_US | US Phone Number | MEDIUM | `(\d{3}[-.\s]?){2}\d{4}` |
| CREDIT_CARD | Credit Card | HIGH | `\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}` |
| EMAIL | Email Address (in sensitive contexts) | LOW | `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` |

### Log Patterns

| Pattern | Name | Severity | Regex |
|---------|------|----------|-------|
| DEBUG_SECRET | Debug/Test Secret | MEDIUM | `(secret\|token\|key)\s*[:=]\s*['\"]?test['\"]?` |
| TODO_SECRET | TODO with secret | LOW | `TODO.*secret\|secret.*TODO` |

## Sensitivity Levels

### HIGH: Block Execution

**Action:** Halt write operation, log incident, return non-zero exit code
**Examples:** AWS keys, private keys, SSNs, credit cards
**Trace Behavior:** Log detection with file/line position (no exposed secret value)

```
[BLOCKED] HIGH: AWS_ACCESS_KEY detected at line 45 (character range redacted)
```

### MEDIUM: Warn and Continue

**Action:** Write succeeds but warning logged
**Examples:** API keys, JWT tokens, phone numbers, generic passwords
**Trace Behavior:** Log detection with file/line position

```
[WARNED] MEDIUM: GENERIC_API_KEY detected at line 12 (character range redacted)
```

### LOW: Log for Audit

**Action:** Write succeeds, minimal logging
**Examples:** Email addresses, debug tokens, TODO reminders
**Trace Behavior:** Log to audit file only (not stdout)

```
[AUDIT] LOW: EMAIL detected at line 7 (character range redacted)
```

## Log Format

All logging must use a structured format to trace incidents without exposing secrets:

```
[<TIMESTAMP>] [<LEVEL>] <SEVERITY>: <PATTERN_NAME> detected at <FILE>:<LINE>:<CHAR_RANGE> (redacted)
```

Example:
```
[2026-06-29T14:22:15] [INFO] HIGH: AWS_ACCESS_KEY detected at agents/test.agent.md:45:12-31 (redacted)
```

### Secure Logging Rules

1. **Never log secret values** — only log character position ranges
2. **Never log full file paths in stdout** — use relative paths
3. **Audit trail file** — keep full trace in `.specs/changes/w9-security/evidence/security-audit.log`
4. **Redaction format** — use `(redacted)` suffix to mark scanned content
5. **Exit codes:**
   - `0` = Safe (no findings or LOW only)
   - `1` = MEDIUM warnings (non-blocking)
   - `2` = HIGH/CRITICAL findings (blocking)

## Integration Points

### altitude-execution Pre-Write Gate

Before executing any file write:

```bash
if ! security-scan.sh check-file "$file_path"; then
  log "[BLOCKED] Security scan failed for $file_path"
  exit 2
fi
```

### altitude-validation Audit

Post-write validation:

```bash
security-scan.sh audit
```

### evidence/ Collection

All security findings recorded in:

```
.specs/changes/w9-security/evidence/security-audit.log
```

## Scope

### In Scope

- Source code files (`.sh`, `.md`, `.ts`, `.py`, `.js`)
- Configuration files (`.json`, `.yaml`, `.yml`)
- Task contracts and allocation files
- Agent specifications
- Documentation files

### Out of Scope

- Binary files (`.png`, `.jpg`, `.zip`)
- Third-party vendor code (node_modules/, venv/)
- Version control metadata (.git/)
- Temporary files (/tmp/)

## Remediation

If HIGH/CRITICAL findings are detected:

1. Stop execution immediately
2. Log full incident to audit file
3. Return detailed error message (without exposing secret)
4. Operator must:
   - Remove or mask the sensitive data
   - Rotate any exposed credentials
   - Re-run security scan
   - Commit evidence to audit trail

## Testing

Security contract compliance tested via:

- `test/fixtures/harness-v3/wave-9-security-smoke.fixture.md`
- Scenario 1: Safe file (passes scan)
- Scenario 2: File with AWS key (blocked with HIGH severity)
- Scenario 3: File with email (LOW severity audit)

## Future Enhancements

- [ ] Integration with gitleaks GitHub Action
- [ ] Entropy-based secret detection
- [ ] Machine learning anomaly detection
- [ ] Centralized credentials vault integration
