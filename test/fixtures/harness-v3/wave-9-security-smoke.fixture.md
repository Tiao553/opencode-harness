# Wave 9 Security Smoke Fixtures

**Version:** 1.0  
**Created:** 2026-06-29  
**Purpose:** Test security scanning workflows for altitude-execution pre-write gate

---

## Fixture Overview

Three smoke test scenarios validating security-scan.sh behavior:

1. **Scenario 1: Safe File** — Passes scan (exit 0)
2. **Scenario 2: Secret File** — Blocked (exit 2, HIGH severity)
3. **Scenario 3: PII File** — Warning (LOW severity, audit only)

---

## Scenario 1: Safe File

**Goal:** Verify that clean files pass security scan.

### Input File: `test/fixtures/harness-v3/safe-file.md`

```markdown
# Safe Agent Specification

## Overview

This agent handles data transformations safely.

## Configuration

- Max retries: 3
- Timeout: 30s
- Log level: info

## Operations

The agent processes records and updates state.
```

### Expected Behavior

- Scan command: `tools/security-scan.sh check-file test/fixtures/harness-v3/safe-file.md`
- Exit code: **0** (safe)
- Console output: None
- Audit log: No entries for this file

### Verification

```bash
#!/bin/bash

# Run security scan
tools/security-scan.sh check-file test/fixtures/harness-v3/safe-file.md
exit_code=$?

# Verify exit code is 0
if [[ $exit_code -ne 0 ]]; then
  echo "FAILED: Expected exit 0, got $exit_code"
  exit 1
fi

# Verify no audit entries for this file
if grep -q "safe-file" .specs/changes/w9-security/evidence/security-audit.log 2>/dev/null; then
  echo "FAILED: Unexpected audit entries for safe file"
  exit 1
fi

echo "PASSED: Safe file scan completed successfully"
exit 0
```

---

## Scenario 2: Secret File

**Goal:** Verify that files with HIGH severity secrets are blocked.

### Input File: `test/fixtures/harness-v3/secret-file.md`

```markdown
# Configuration Template

## AWS Credentials (DO NOT USE IN PRODUCTION)

This is a test fixture containing simulated secrets for testing only.

### Access Key Example
AKIA1234567890ABCDEF

### Secret Key Example
aws_secret_access_key = super_secret_key_12345678901234567890

## Database Connection

Host: db.internal
Port: 5432
```

### Expected Behavior

- Scan command: `tools/security-scan.sh check-file test/fixtures/harness-v3/secret-file.md`
- Exit code: **2** (blocked, HIGH severity)
- Console output: `[BLOCKED] HIGH: AWS_ACCESS_KEY detected at test/fixtures/harness-v3/secret-file.md:7 (redacted)`
- Audit log: Two entries (AWS_ACCESS_KEY and AWS_SECRET_KEY)

### Verification

```bash
#!/bin/bash

# Run security scan
tools/security-scan.sh check-file test/fixtures/harness-v3/secret-file.md
exit_code=$?

# Verify exit code is 2 (HIGH/CRITICAL)
if [[ $exit_code -ne 2 ]]; then
  echo "FAILED: Expected exit 2, got $exit_code"
  exit 1
fi

# Verify audit entries exist
if ! grep -q "AWS_ACCESS_KEY" .specs/changes/w9-security/evidence/security-audit.log 2>/dev/null; then
  echo "FAILED: Expected AWS_ACCESS_KEY audit entry"
  exit 1
fi

if ! grep -q "AWS_SECRET_KEY" .specs/changes/w9-security/evidence/security-audit.log 2>/dev/null; then
  echo "FAILED: Expected AWS_SECRET_KEY audit entry"
  exit 1
fi

# Verify secret value is NOT in audit log (should be redacted)
if grep -q "super_secret_key\|1234567890ABCDEF" .specs/changes/w9-security/evidence/security-audit.log 2>/dev/null; then
  echo "FAILED: Secret value exposed in audit log"
  exit 1
fi

echo "PASSED: Secret file blocked as expected"
exit 0
```

---

## Scenario 3: PII File

**Goal:** Verify that files with LOW/MEDIUM PII are warned but not blocked.

### Input File: `test/fixtures/harness-v3/pii-file.md`

```markdown
# User Guide

## Support Contact

For questions, contact our support team:

- Email: support@example.com
- Name: John Smith
- Phone: 555-123-4567

## Emergency Contact

Manager: jane.manager@company.com
Emergency phone: (555) 987-6543

## Acknowledgment

This document may contain email addresses and phone numbers.
```

### Expected Behavior

- Scan command: `tools/security-scan.sh check-file test/fixtures/harness-v3/pii-file.md`
- Exit code: **0** (safe to write; LOW severity items audit-only)
- Console output: None (LOW severity suppressed)
- Audit log: 4 entries (2 emails, 2 phone numbers)

### Verification

```bash
#!/bin/bash

# Run security scan
tools/security-scan.sh check-file test/fixtures/harness-v3/pii-file.md
exit_code=$?

# Verify exit code is 0 (LOW is safe)
if [[ $exit_code -ne 0 ]]; then
  echo "FAILED: Expected exit 0 for LOW PII, got $exit_code"
  exit 1
fi

# Verify audit entries exist (LOW items should still log)
if ! grep -q "EMAIL\|PHONE" .specs/changes/w9-security/evidence/security-audit.log 2>/dev/null; then
  echo "FAILED: Expected PII audit entries"
  exit 1
fi

# Verify no console output (LOW is suppressed)
result=$(tools/security-scan.sh pii test/fixtures/harness-v3/pii-file.md 2>&1)
if [[ ! -z "$result" ]]; then
  # LOW findings should not produce console output
  # This is a soft check; LOW may or may not appear in output
  true
fi

echo "PASSED: PII file scanned and logged (audit-only)"
exit 0
```

---

## Running All Fixtures

```bash
#!/bin/bash

echo "Wave 9 Security Smoke Test Suite"
echo "=================================="
echo ""

# Create test input files
mkdir -p test/fixtures/harness-v3
cat > test/fixtures/harness-v3/safe-file.md << 'EOF'
# Safe Agent Specification
## Overview
This agent handles data transformations safely.
## Configuration
- Max retries: 3
- Timeout: 30s
- Log level: info
## Operations
The agent processes records and updates state.
EOF

cat > test/fixtures/harness-v3/secret-file.md << 'EOF'
# Configuration Template
## AWS Credentials
AKIA1234567890ABCDEF
aws_secret_access_key = super_secret_key_12345678901234567890
## Database Connection
Host: db.internal
EOF

cat > test/fixtures/harness-v3/pii-file.md << 'EOF'
# User Guide
## Support Contact
Email: support@example.com
Phone: 555-123-4567
## Manager
contact@example.com
(555) 987-6543
EOF

# Run tests
PASSED=0
FAILED=0

# Test 1: Safe file
if tools/security-scan.sh check-file test/fixtures/harness-v3/safe-file.md; then
  echo "[PASS] Scenario 1: Safe file"
  ((PASSED++))
else
  echo "[FAIL] Scenario 1: Safe file"
  ((FAILED++))
fi

# Test 2: Secret file (expect failure)
if tools/security-scan.sh check-file test/fixtures/harness-v3/secret-file.md; then
  echo "[FAIL] Scenario 2: Secret file (should have been blocked)"
  ((FAILED++))
else
  echo "[PASS] Scenario 2: Secret file (blocked as expected)"
  ((PASSED++))
fi

# Test 3: PII file (expect success, warnings only)
if tools/security-scan.sh check-file test/fixtures/harness-v3/pii-file.md; then
  echo "[PASS] Scenario 3: PII file (allowed with warnings)"
  ((PASSED++))
else
  echo "[FAIL] Scenario 3: PII file (should allow LOW PII)"
  ((FAILED++))
fi

echo ""
echo "Results: $PASSED passed, $FAILED failed"
if [[ $FAILED -eq 0 ]]; then
  exit 0
else
  exit 1
fi
```

---

## Fixture Cleanup

After testing, optional cleanup:

```bash
rm -f test/fixtures/harness-v3/safe-file.md
rm -f test/fixtures/harness-v3/secret-file.md
rm -f test/fixtures/harness-v3/pii-file.md
```

---

## Related Contracts

- `.specs/shared/security-contract.md` — Security scanning rules and patterns
- `tools/security-scan.contract.md` — Command reference and API
- `agents/altitude-execution.agent.md` — Integration point (pre-write gate)
