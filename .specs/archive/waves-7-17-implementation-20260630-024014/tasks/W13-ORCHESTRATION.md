---
id: W13-ORCHESTRATION
title: "Wave 13: Multi-Wave Orchestration"
status: implemented
effort: M
budget: 70000
agent: altitude-coordinator
severity: feature
depends_on: [W11-STATE-MACHINE]
blocks: [W16-HARDENING]
touches_paths:
  - .specs/shared/orchestration-contract.md
  - tools/wave-scheduler.sh
  - tools/wave-scheduler.contract.md
  - agents/altitude-coordinator.agent.md
  - test/fixtures/harness-v3/wave-13-orchestration-smoke.fixture.md
evidence_path: .specs/changes/waves-7-17-implementation/evidence/W13-ORCHESTRATION-evidence.md
completed_at: 2026-06-30T01:25:00Z
all_evals_passed: true
---

# Wave 13: Multi-Wave Orchestration

## Goal

NEW agent altitude-coordinator for multi-wave scheduling:
- ✅ Wave DAG computation (respect dependencies)
- ✅ Deterministic scheduling
- ✅ Batch execution
- ✅ Orchestration state tracking
- ✅ 2 smoke scenarios

## Success Criteria

```bash
eval_1() { grep -q "wave_dag:" .specs/shared/orchestration-contract.md; }
eval_2() { tools/wave-scheduler.sh schedule > /dev/null 2>&1; }
eval_3() { test -f agents/altitude-coordinator.agent.md && grep -q "orchestrat" agents/altitude-coordinator.agent.md; }
eval_4() { bash test/fixtures/harness-v3/wave-13-orchestration-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```
