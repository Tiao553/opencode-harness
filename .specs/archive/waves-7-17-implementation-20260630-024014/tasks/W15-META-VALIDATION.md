---
id: W15-META-VALIDATION
title: "Wave 15: Cross-Validation Junta Audit"
status: implemented
effort: M
budget: 55000
budget_used: 45000
agent: altitude-validation
severity: feature
depends_on: [W7-RALPH-LOOP, W8-KB-QUALITY, W9-SECURITY, W10-METRICS, W11-STATE-MACHINE, W12-RECOVERY, W13-ORCHESTRATION, W14-PROTOCOLS]
blocks: [W17-FINAL-VALIDATION]
touches_paths:
  - .specs/shared/meta-validation-contract.md
  - tools/junta-auditor.sh
  - tools/junta-auditor.contract.md
  - agents/altitude-validation.agent.md
  - test/fixtures/harness-v3/wave-15-meta-validation-smoke.fixture.md
completed_at: 2026-06-30T12:30:00Z
---

# Wave 15: Cross-Validation Junta Audit

## Goal

Meta-validate the validators for quality and bias:
- ✅ Audit junta scoring rules
- ✅ Detect systematic biases
- ✅ Remediation paths
- ✅ 2 smoke scenarios

## Success Criteria

```bash
eval_1() { grep -q "junta_audit_rules:" .specs/shared/meta-validation-contract.md; }
eval_2() { tools/junta-auditor.sh audit requirements > /dev/null 2>&1; }
eval_3() { grep -q "junta-auditor" agents/altitude-validation.agent.md; }
eval_4() { bash test/fixtures/harness-v3/wave-15-meta-validation-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```
