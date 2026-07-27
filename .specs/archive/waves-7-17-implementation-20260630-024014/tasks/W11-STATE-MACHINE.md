---
id: W11-STATE-MACHINE
title: "Wave 11: State Machine Formalization"
status: implemented
effort: M
budget: 77000
tokens_used: 65000
agent: altitude-execution
severity: feature
depends_on: [W7-RALPH-LOOP]
blocks: [W12-RECOVERY, W13-ORCHESTRATION, W16-HARDENING]
completed: 2026-06-29T23:27Z
touches_paths:
  - .specs/shared/state-machine-contract.md
  - tools/state-validator.sh
  - tools/state-validator.contract.md
  - agents/altitude-plan.agent.md
  - test/fixtures/harness-v3/wave-11-state-machine-smoke.fixture.md
---

# Wave 11: State Machine Formalization

## Goal

Formalize phase FSM and prevent invalid transitions:
- ✅ States: Intent, Structure, Design, Execution, Validate, Ship
- ✅ Valid transitions documented (no backward jumps)
- ✅ Enforce transitions in altitude-plan
- ✅ Detect deadlocks
- ✅ 3 smoke scenarios (valid, invalid, deadlock)

## Success Criteria

```bash
eval_1() { grep -q "^states:" .specs/shared/state-machine-contract.md && grep -q "^transitions:" .specs/shared/state-machine-contract.md; }
eval_2() { tools/state-validator.sh validate Intent Structure && ! tools/state-validator.sh validate Ship Intent; }
eval_3() { grep -q "state_validator" agents/altitude-plan.agent.md && grep -q "deadlock" agents/altitude-plan.agent.md; }
eval_4() { bash test/fixtures/harness-v3/wave-11-state-machine-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```
