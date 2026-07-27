---
id: W12-RECOVERY
title: "Wave 12: Error Recovery & Rollback"
status: implemented
effort: M
budget: 60000
agent: altitude-execution
severity: feature
depends_on: [W11-STATE-MACHINE]
blocks: [W16-HARDENING]
touches_paths:
  - .specs/shared/recovery-contract.md
  - tools/recovery-manager.sh
  - tools/recovery-manager.contract.md
  - agents/altitude-execution.agent.md
  - test/fixtures/harness-v3/wave-12-recovery-smoke.fixture.md
---

# Wave 12: Error Recovery & Rollback

## Goal

Implement atomic recovery and safe failure:
- ✅ State snapshots at checkpoints
- ✅ Rollback to snapshot on failure
- ✅ Validation of restoration
- ✅ Zero data loss
- ✅ 2 smoke scenarios

## Success Criteria

```bash
eval_1() { grep -q "snapshot_schema:" .specs/shared/recovery-contract.md; }
eval_2() { SNAP=$(tools/recovery-manager.sh snapshot --state '{}') && tools/recovery-manager.sh rollback --to "$SNAP" > /dev/null 2>&1; }
eval_3() { grep -q "recovery-manager" agents/altitude-execution.agent.md; }
eval_4() { bash test/fixtures/harness-v3/wave-12-recovery-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```
