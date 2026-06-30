# Security Scan Command Reference

**Version:** 1.0  
**Command:** `tools/security-scan.sh`  
**Owner:** altitude-execution  

## Overview

Pre-write security scanning tool for Harness V3 execution harness. Detects secrets and PII before file writes.

## Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Safe | No findings or LOW only |
| 1 | Warnings | MEDIUM findings detected (non-blocking) |
| 2 | Blocked | HIGH/CRITICAL findings detected |

## Commands

### scan <files...>

Scan files for secrets (AWS keys, API tokens, private keys, etc.).

**Usage:**
```bash
security-scan.sh scan agents/altitude-execution.agent.md
security-scan.sh scan .specs/changes/w9-security/*.md
```

**Output:**
```
[BLOCKED] HIGH: AWS_ACCESS_KEY detected at agents/test.md:45 (redacted)
[WARNED] MEDIUM: GENERIC_API_KEY detected at agents/test.md:60 (redacted)
```

**Exit Codes:**
- 0 = No secrets found
- 1 = MEDIUM secrets found
- 2 = HIGH/CRITICAL secrets found (blocking)

**Patterns Detected:**
- AWS_ACCESS_KEY (HIGH)
- AWS_SECRET_KEY (HIGH)
- GITHUB_TOKEN (HIGH)
- SLACK_TOKEN (HIGH)
- GENERIC_API_KEY (MEDIUM)
- JWT_TOKEN (MEDIUM)
- PRIVATE_KEY (HIGH)
- PASSWORD_VAR (MEDIUM)

---

### pii <files...>

Scan files for PII (Social Security Numbers, phone numbers, credit cards, emails).

**Usage:**
```bash
security-scan.sh pii docs/user-guide.md
security-scan.sh pii test/fixtures/harness-v3/*.md
```

**Output:**
```
[BLOCKED] HIGH: SSN detected at docs/user-guide.md:12 (redacted)
[WARNED] MEDIUM: PHONE_US detected at docs/user-guide.md:18 (redacted)
```

**Exit Codes:**
- 0 = No PII found
- 1 = MEDIUM PII found
- 2 = HIGH/CRITICAL PII found (blocking)

**Patterns Detected:**
- SSN (HIGH) — `XXX-XX-XXXX` format
- CREDIT_CARD (HIGH) — Card number format
- PHONE_US (MEDIUM) — US phone number
- EMAIL (LOW) — Email addresses

---

### check-file <file>

Pre-write gate: check a single file for both secrets and PII.

**Usage:**
```bash
security-scan.sh check-file agents/new-agent.md || exit 1
```

**Output:**
```
[BLOCKED] HIGH: GITHUB_TOKEN detected at agents/new-agent.md:20 (redacted)
```

**Exit Codes:**
- 0 = File is safe to write
- 1 = Warnings detected
- 2 = File is blocked (contains HIGH secrets)

**Integration:**
```bash
# In altitude-execution before writing
if ! security-scan.sh check-file "$target_file"; then
  echo "[BLOCKED] Security scan failed"
  exit 2
fi
```

---

### report

Generate summary report of all findings (HIGH, MEDIUM, LOW counts).

**Usage:**
```bash
security-scan.sh report
```

**Output:**
```
Security Scan Report
====================

HIGH/CRITICAL findings:  0
MEDIUM warnings:         1
LOW info:                3

Last 10 audit entries:

[2026-06-29T14:22:15] [INFO] MEDIUM: GENERIC_API_KEY detected at agents/test.md:60 (redacted)
[2026-06-29T14:21:50] [INFO] LOW: EMAIL detected at docs/guide.md:12 (redacted)
...

Status: WARNED (MEDIUM findings detected)
```

**Exit Codes:**
- 0 = All safe
- 1 = MEDIUM warnings exist
- 2 = HIGH/CRITICAL findings exist

---

### audit

Display full audit trail with timestamps and all historical findings.

**Usage:**
```bash
security-scan.sh audit
```

**Output:**
```
Full audit trail: .specs/changes/w9-security/evidence/security-audit.log

[2026-06-29T14:22:15Z] [INFO] MEDIUM: GENERIC_API_KEY detected at agents/test.md:60 (redacted)
[2026-06-29T14:21:50Z] [INFO] LOW: EMAIL detected at docs/guide.md:12 (redacted)
[2026-06-29T14:20:30Z] [INFO] HIGH: AWS_ACCESS_KEY detected at config/.env:5 (redacted)
```

---

## Logging

### Audit Log

Location: `.specs/changes/w9-security/evidence/security-audit.log`

Format:
```
[ISO8601_TIMESTAMP] [LEVEL] SEVERITY: PATTERN_NAME detected at FILE:LINE (redacted)
```

Example:
```
[2026-06-29T14:22:15Z] [INFO] HIGH: AWS_ACCESS_KEY detected at .env:5 (redacted)
```

### Console Output

High and Medium severity findings printed to stderr:
```
[BLOCKED] HIGH: GITHUB_TOKEN detected at file.md:20 (redacted)
[WARNED] MEDIUM: API_KEY detected at file.md:30 (redacted)
```

Low severity findings only logged to audit file (not printed to console).

---

## File Handling

### In-Scope Files

- Source code: `.sh`, `.md`, `.ts`, `.py`, `.js`, `.json`, `.yaml`, `.yml`
- Configuration files: `.json`, `.yaml`, `.yml`
- Documentation: `.md`
- Specs and allocation: `.md`

### Out-of-Scope Files

- Binary files: `.png`, `.jpg`, `.zip`, `.tar`, `.gz`
- Vendor directories: `node_modules/`, `venv/`, `.git/`
- Third-party code

---

## Integration with altitude-execution

### Pre-Write Gate

Before writing any file, call `check-file`:

```bash
# In altitude-execution
target_file="agents/new-agent.md"

if ! "${SCRIPT_DIR}/security-scan.sh" check-file "$target_file"; then
  echo "[BLOCKED] Security scan failed for $target_file"
  exit 2
fi

# Safe to write
write_file "$target_file"
```

### Validation Gate

Post-write validation:

```bash
# Generate report
security-scan.sh report
exit_code=$?

if [[ $exit_code -eq 2 ]]; then
  echo "[FAILED] HIGH security findings"
  exit 2
fi
```

---

## Remediation Workflow

If a file is blocked:

1. **View findings:**
   ```bash
   security-scan.sh check-file blocked-file.md
   ```

2. **Check audit log:**
   ```bash
   security-scan.sh audit
   ```

3. **Remove or mask sensitive data** from the file

4. **Rotate exposed credentials** (if applicable)

5. **Re-run scan:**
   ```bash
   security-scan.sh check-file blocked-file.md
   ```

6. **Commit evidence:**
   ```bash
   # Verify clean
   security-scan.sh report
   ```

---

## Testing

Fixtures: `test/fixtures/harness-v3/wave-9-security-smoke.fixture.md`

Scenarios:
1. Safe file → passes scan (exit 0)
2. File with AWS key → blocked (exit 2)
3. File with email → warning (exit 0, audit only)

---

## Performance

- Per-file: ~50-500ms depending on file size
- Caching: No pattern caching; real-time scanning
- Memory: Minimal (line-by-line processing)

---

## Future Enhancements

- [ ] Integration with gitleaks for extended patterns
- [ ] Entropy-based secret detection
- [ ] Machine learning anomaly detection
- [ ] Integration with credential vaults
- [ ] Performance optimization with pattern caching
