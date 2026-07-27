# Task: security-contract

**Task ID:** security-contract  
**Status:** ready  
**Parent Change:** w9-security  
**Owner:** altitude-execution  

## Goal

Create `.specs/shared/security-contract.md` defining security scan rules, sensitivity levels, and log format.

## Allowed Files

- `.specs/shared/security-contract.md` (new)

## Forbidden Scope

- agents/
- tools/
- test/
- docs/

## Acceptance Criteria

- [ ] security-contract.md created with ~100-120 lines
- [ ] Defines scan rules (AWS keys, tokens, PII patterns)
- [ ] Defines 3 sensitivity levels: HIGH (block), MEDIUM (warn), LOW (info)
- [ ] Defines log format for secure tracing (no secret exposure)
- [ ] Includes section on integration points (altitude-execution, altitude-validation)

## Verification

```bash
# Check file exists and has content
[ -f .specs/shared/security-contract.md ] && wc -l .specs/shared/security-contract.md

# Check for required sections
grep -q "sensitivity.*levels\|HIGH\|MEDIUM\|LOW" .specs/shared/security-contract.md
```

## Evidence Required

- `.specs/changes/w9-security/evidence/security-contract-created.md`
