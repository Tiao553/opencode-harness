# Task: security-fixtures

**Task ID:** security-fixtures  
**Status:** ready  
**Parent Change:** w9-security  
**Owner:** altitude-execution  

## Goal

Create `test/fixtures/harness-v3/wave-9-security-smoke.fixture.md` with test scenarios for security scanning.

## Allowed Files

- `test/fixtures/harness-v3/wave-9-security-smoke.fixture.md` (new)

## Forbidden Scope

- agents/
- .specs/
- tools/
- docs/

## Acceptance Criteria

- [ ] Fixture file created with ~80-100 lines
- [ ] Scenario 1: Safe file passes scan (exit 0)
- [ ] Scenario 2: File with AWS key blocked (exit 2, HIGH)
- [ ] Scenario 3: File with email warning (LOW, audit only)
- [ ] Each scenario has input, expected output, and verification steps
- [ ] Executable or verifiable

## Verification

```bash
# Check file exists
[ -f test/fixtures/harness-v3/wave-9-security-smoke.fixture.md ] || exit 1

# Check for all scenarios
grep -q "Scenario 1\|Scenario 2\|Scenario 3" test/fixtures/harness-v3/wave-9-security-smoke.fixture.md || exit 1

# Check for verification steps
grep -q "Verification\|verify\|Expected" test/fixtures/harness-v3/wave-9-security-smoke.fixture.md || exit 1
```

## Evidence Required

- `.specs/changes/w9-security/evidence/security-fixtures-created.md`
