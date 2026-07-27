# Task: altitude-execution-integration

**Task ID:** altitude-execution-integration  
**Status:** ready  
**Parent Change:** w9-security  
**Owner:** altitude-execution  

## Goal

Integrate pre-write security gate into `agents/altitude-execution.agent.md`.

## Allowed Files

- `agents/altitude-execution.agent.md` (modify)

## Forbidden Scope

- Other agents/
- tools/
- .specs/shared/
- test/

## Acceptance Criteria

- [ ] Pre-write security gate added (~15 lines)
- [ ] Calls `security-scan.sh check-file` before writing files
- [ ] Blocks on HIGH/CRITICAL (exit 2)
- [ ] Warns on MEDIUM (exit 1, continues)
- [ ] Integrated into execution workflow
- [ ] Documented in agent contract

## Verification

```bash
# Check that security gate is mentioned
grep -q "security-scan" agents/altitude-execution.agent.md || exit 1

# Check that check-file command is used
grep -q "check-file" agents/altitude-execution.agent.md || exit 1

# Verify integration section exists
grep -q "Security Gate\|security gate" agents/altitude-execution.agent.md || exit 1
```

## Evidence Required

- `.specs/changes/w9-security/evidence/altitude-execution-integration.md`
