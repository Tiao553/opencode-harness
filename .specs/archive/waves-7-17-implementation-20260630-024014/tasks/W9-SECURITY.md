---
id: W9-SECURITY
title: "Wave 9: Security & Secrets Detection — Pre-Write Security Gate"
status: implemented
format_version: 2.1
effort: M
budget: 48000
agent: altitude-execution
severity: security
execution_backend: any
touches_paths:
  - .specs/shared/security-contract.md
  - tools/security-scan.sh
  - tools/security-scan.contract.md
  - agents/altitude-execution.agent.md
  - test/fixtures/harness-v3/wave-9-security-smoke.fixture.md
source_note: waves-7-17-implementation/DESIGN.md
depends_on: [W7-RALPH-LOOP]
blocks: []
---

# Wave 9: Security & Secrets Detection

## Goal

Block sensitive writes at pre-execution security gate:
- ✅ Detect AWS keys, API tokens, secrets (gitleaks)
- ✅ Detect PII patterns (SSN, phone, email)
- ✅ Block writes containing secrets; ask user on escalation
- ✅ Log security events to trace (Wave 7)
- ✅ 2 smoke scenarios (safe write, blocked write)

## Success Criteria

### Eval 1: Security contract complete

```bash
eval_1() {
  test -f .specs/shared/security-contract.md || return 1
  grep -q "^scan_rules:" .specs/shared/security-contract.md || return 1
  grep -q "sensitivity_levels:" .specs/shared/security-contract.md || return 1
}
```

### Eval 2: security-scan tool working

```bash
eval_2() {
  test -x tools/security-scan.sh || return 1
  tools/security-scan.sh scan agents/ > /dev/null 2>&1 || return 1
  tools/security-scan.sh report | grep -q "scan_result:" || return 1
}
```

### Eval 3: altitude-execution integrated

```bash
eval_3() {
  grep -q "security-scan" agents/altitude-execution.agent.md || return 1
}
```

### Eval 4: Fixtures pass

```bash
eval_4() {
  bash test/fixtures/harness-v3/wave-9-security-smoke.fixture.md > /dev/null 2>&1 || return 1
}
```

### Exit Check
```bash
eval_1 && eval_2 && eval_3 && eval_4
```

---

## Rollback Plan

Remove security-scan calls from altitude-execution; leave tool in place.

---

## Anti-Patterns

❌ **Don't** hardcode secret patterns (use gitleaks config)
❌ **Don't** log detected secrets to stdout (log to secure trace only)
❌ **Don't** halt all writes on any finding (only halt on HIGH/CRITICAL)

---

## Do-Not-Touch

🚫 Waves 0-8
🚫 Source code
