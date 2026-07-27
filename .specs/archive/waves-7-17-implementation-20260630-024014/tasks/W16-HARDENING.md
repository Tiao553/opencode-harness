---
id: W16-HARDENING
title: "Wave 16: Production Hardening & Chaos Testing"
status: implemented
effort: M
budget: 65000
agent: altitude-report
severity: feature
depends_on: [W11-STATE-MACHINE, W12-RECOVERY, W13-ORCHESTRATION]
blocks: [W17-FINAL-VALIDATION]
touches_paths:
  - .specs/shared/hardening-contract.md
  - tools/chaos-tester.sh
  - tools/chaos-tester.contract.md
  - agents/altitude-report.agent.md
  - test/fixtures/harness-v3/wave-16-hardening-smoke.fixture.md
---

# Wave 16: Production Hardening & Chaos Testing

## Goal

Chaos and load testing for resilience:
- ✅ Load test (concurrent)
- ✅ Chaos test (inject failures)
- ✅ Recovery validation
- ✅ Hardening metrics
- ✅ 2 smoke scenarios

## Success Criteria

```bash
eval_1() { grep -q "chaos_patterns:" .specs/shared/hardening-contract.md; }
eval_2() { tools/chaos-tester.sh load > /dev/null 2>&1 && tools/chaos-tester.sh chaos > /dev/null 2>&1; }
eval_3() { grep -q "chaos-tester" agents/altitude-report.agent.md; }
eval_4() { bash test/fixtures/harness-v3/wave-16-hardening-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```
