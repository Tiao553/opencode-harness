# Task: security-scan-script

**Task ID:** security-scan-script  
**Status:** ready  
**Parent Change:** w9-security  
**Owner:** altitude-execution  

## Goal

Create `tools/security-scan.sh` bash script implementing security scanning with three commands: scan, pii, report.

## Allowed Files

- `tools/security-scan.sh` (new)

## Forbidden Scope

- agents/
- .specs/
- test/

## Acceptance Criteria

- [ ] Script created: `tools/security-scan.sh`
- [ ] `security-scan.sh scan <files>` detects secrets
- [ ] `security-scan.sh pii <files>` detects PII
- [ ] `security-scan.sh report` generates summary
- [ ] Exit 0 if safe, non-zero if findings
- [ ] No secret values logged to stdout
- [ ] Uses patterns from security-contract.md

## Verification

```bash
# Check file exists and is executable
[ -x tools/security-scan.sh ] || exit 1

# Test scan command
tools/security-scan.sh scan test/fixtures/harness-v3/safe-file.md
exit_code=$?
[ $exit_code -eq 0 ] || exit 1

# Test pii command
tools/security-scan.sh pii test/fixtures/harness-v3/safe-file.md
exit_code=$?
[ $exit_code -eq 0 ] || exit 1

# Test blocked secret
tools/security-scan.sh scan test/fixtures/harness-v3/secret-file.md
exit_code=$?
[ $exit_code -ne 0 ] || exit 1
```

## Evidence Required

- `.specs/changes/w9-security/evidence/security-scan-script-created.md`
