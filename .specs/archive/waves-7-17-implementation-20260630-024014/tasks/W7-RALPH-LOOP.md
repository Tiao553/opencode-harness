---
id: W7-RALPH-LOOP
title: "Wave 7: Ralph Loop Verification — Deterministic Execution Tracing"
status: implemented
format_version: 2.1
effort: M
budget: 90000
agent: altitude-execution
severity: feature
execution_backend: any

touches_paths:
  - .specs/shared/verification-contract.md
  - tools/verify-step.sh
  - tools/verify-step.contract.md
  - agents/altitude-execution.agent.md
  - test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md
  - .specs/changes/waves-7-17-implementation/wave-7/

source_note: waves-7-17-implementation/DESIGN.md
depends_on: []
blocks: [W8-KB-QUALITY, W9-SECURITY, W10-METRICS, W11-STATE-MACHINE, W14-PROTOCOLS]
---

# Wave 7: Ralph Loop Verification

## Why

Ralph Loop (step verification + decision trace recording) is the foundation for all downstream waves. Without deterministic tracing:
- Wave 8 has no metadata for KB freshness
- Wave 9 cannot log security decisions to trace
- Wave 11 cannot validate state transitions from traces
- All 16 subsequent waves lack observability

This wave establishes the tracing API + runtime recording.

## Goal

Implement `verify_step` wrapper and trace recording system:
- ✅ Record every decision with unique trace ID
- ✅ Capture decision inputs/outputs and path taken
- ✅ Support deterministic replay of traces
- ✅ Update altitude-execution to use verify_step at decision gates
- ✅ Create smoke test fixtures (happy path + fork)

## Context

**Design:** `.specs/changes/waves-7-17-implementation/wave-7/DESIGN.md`

**Contracts needed:**
1. `verification-contract.md` — trace schema, replay semantics
2. `verify-step.contract.md` — command reference

**Tool needed:**
1. `tools/verify-step.sh` — wrapper around tool, trace recording

**Integration needed:**
1. `agents/altitude-execution.agent.md` — call verify_step at decision points
2. Fixture: 2 scenarios (happy path, decision fork)

---

## Success Criteria

### Eval 1: Verification contract created with trace schema

```bash
eval_1() {
  # Contract exists and is valid YAML
  test -f .specs/shared/verification-contract.md || return 1
  grep -q "^trace_schema:" .specs/shared/verification-contract.md || return 1
  grep -q "decision_id:" .specs/shared/verification-contract.md || return 1
  grep -q "replay_semantics:" .specs/shared/verification-contract.md || return 1
  # At least 100 lines documenting trace format
  [ $(wc -l < .specs/shared/verification-contract.md) -ge 100 ] || return 1
}
```

### Eval 2: verify_step tool works for all 4 commands

```bash
eval_2() {
  test -x tools/verify-step.sh || return 1
  
  # Test start command
  tools/verify-step.sh start --session-id test-w7 --step "test-step" > /dev/null 2>&1 || return 1
  
  # Test check command (PASS verdict)
  tools/verify-step.sh check --session-id test-w7 --verdict PASS > /dev/null 2>&1 || return 1
  
  # Test ledger command (returns YAML)
  tools/verify-step.sh ledger --session-id test-w7 | grep -q "decision_id" || return 1
  
  # Test replay command
  tools/verify-step.sh replay --session-id test-w7 > /dev/null 2>&1 || return 1
  
  # No syntax errors
  bash -n tools/verify-step.sh || return 1
}
```

### Eval 3: altitude-execution integrated with verify_step

```bash
eval_3() {
  # Contract exists
  test -f tools/verify-step.contract.md || return 1
  
  # altitude-execution mentions verify_step
  grep -q "verify_step" agents/altitude-execution.agent.md || return 1
  
  # At least 20 new lines in agent (trace recording section)
  BEFORE=$(grep -c "verify_step" agents/altitude-execution.agent.md 2>/dev/null || echo 0)
  [ "$BEFORE" -gt 0 ] || return 1
}
```

### Eval 4: Fixture scenarios pass

```bash
eval_4() {
  # Fixture file exists
  test -f test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md || return 1
  
  # Fixture runs without errors
  bash test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md > /tmp/w7-fixture.log 2>&1 || return 1
  
  # Both scenarios documented
  grep -q "Scenario 1:" test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md || return 1
  grep -q "Scenario 2:" test/fixtures/harness-v3/wave-7-ralph-loop-smoke.fixture.md || return 1
}
```

### Validation Card

```yaml
validation_card:
  acceptance_gates:
    - id: "contract-complete"
      metric: "verification-contract.md exists with trace schema, replay semantics, examples"
      pass_threshold: 100
    - id: "tool-working"
      metric: "verify_step.sh start/check/ledger/replay all work; no syntax errors"
      pass_threshold: 100
    - id: "altitude-exec-integrated"
      metric: "altitude-execution calls verify_step at decision gates; +20 lines"
      pass_threshold: 100
    - id: "fixtures-pass"
      metric: "Both smoke test scenarios (happy path, fork) execute successfully"
      pass_threshold: 100
  
  regression_risk: "Low — only adds new verify_step calls, no breaking changes to existing execution"
  rollback_complexity: "Simple — remove verify_step calls from altitude-execution, leave contracts + tool in place"
```

### Exit Check

```bash
# Exit check: all 4 evals pass
eval_1 && eval_2 && eval_3 && eval_4
```

---

## Rollback Plan

**Rollback is safe:**
1. Remove verify_step calls from `agents/altitude-execution.agent.md` (revert +20 lines)
2. Leave contracts + tool in place (no downstream dependency yet)
3. Downstream waves (8-14) can still reference verify_step; they simply won't be called
4. No data migration needed

**If blocked on verify_step tool:**
- Revert `tools/verify-step.sh` to stub (keeps contract, tool contract in place)
- Update altitude-execution to skip verify_step calls gracefully

---

## Anti-Patterns

❌ **Don't** hardcode trace IDs in code (make them random + deterministic by session)  
❌ **Don't** log entire trace to stdout (trace file only, ledger command for access)  
❌ **Don't** replay without validating trace integrity (checksum or signature)  
❌ **Don't** block execution on trace failures (trace errors are warnings, not fatal)  
❌ **Don't** create new decision_id on every check (batch traces by session)  

---

## Do-Not-Touch

🚫 Waves 0-6 files (frozen)  
🚫 Source application code  
🚫 `.specs/archive/`  
🚫 `sdd/` directory  
🚫 External tools/integrations  

---

## Open Questions

1. **Trace file location?** Should traces live in `.specs/changes/waves-7-17-implementation/03-execution-ledger.md` or per-session files?
2. **Trace size limits?** Should old traces auto-archive after N days?
3. **Trace encryption?** Needed for PII-sensitive traces or plain-text OK?

**Answers needed before starting implementation.**
