# Hardening & Chaos Testing Contract [Wave 16]

## Purpose

Define resilience validation through chaos and load testing.

Validate that the Harness V3 system (FSM, recovery, orchestration) can:
- Handle concurrent load
- Recover from injected failures
- Remain responsive under stress
- Maintain data consistency during chaos

---

## Load Testing Profiles

### Light Load (Development & CI)

```yaml
load_profile: light
concurrent_tasks: 5
duration_seconds: 60
task_type: simple_operation
expected_throughput_min: 2 ops/sec
expected_error_rate_max: 0.5%
```

**Use case:** CI/CD, rapid iteration, quick validation.

### Medium Load (Integration Testing)

```yaml
load_profile: medium
concurrent_tasks: 20
duration_seconds: 60
task_type: standard_operation
expected_throughput_min: 8 ops/sec
expected_error_rate_max: 1.0%
```

**Use case:** Pre-merge validation, staging environment.

### Heavy Load (Stress Testing)

```yaml
load_profile: heavy
concurrent_tasks: 100
duration_seconds: 30
task_type: intensive_operation
expected_throughput_min: 20 ops/sec
expected_error_rate_max: 2.0%
```

**Use case:** Scale limits, capacity planning, endurance testing.

---

## Chaos Patterns

### State-Flip

**Definition:** Randomly change component state mid-execution.

```yaml
pattern_name: state-flip
description: Inject state inconsistency to test FSM resilience
trigger_probability: 0.05
target: agent state, task state, phase state
seed_based: true
deterministic: true
```

**Validates:** FSM transition guards, recovery from invalid state.

### Message Drop

**Definition:** Simulate lost messages or dropped task results.

```yaml
pattern_name: message-drop
description: Drop random task results or state updates
trigger_probability: 0.03
target: orchestration messages, state updates
seed_based: true
deterministic: true
```

**Validates:** Protocol robustness, idempotency, retry logic.

### Latency Injection

**Definition:** Add random delays to simulate slow operations.

```yaml
pattern_name: latency-injection
description: Inject random delays (50-500ms) into operations
delay_min_ms: 50
delay_max_ms: 500
trigger_probability: 0.10
target: operation execution
seed_based: true
deterministic: true
```

**Validates:** Timeout handling, user experience under congestion.

### Deadlock Simulation

**Definition:** Force circular wait conditions (FSM from W11).

```yaml
pattern_name: deadlock-simulation
description: Create wait-for cycles to test deadlock detection
trigger_probability: 0.02
target: resource locking, state transitions
seed_based: true
deterministic: true
recovery_mechanism: deadlock detection timer (from W11)
```

**Validates:** Deadlock detection (W11), recovery automation.

---

## Stress Metrics

### Throughput

```yaml
metric: throughput
unit: operations/second
calculation: total_completed_tasks / duration_seconds
reporting: min, max, mean, p50, p95, p99
```

### Latency

```yaml
metric: latency
unit: milliseconds
calculation: time from task start to completion
reporting: min, p50, p99, max
```

### Error Rate

```yaml
metric: error_rate
unit: percentage
calculation: (failed_tasks / total_tasks) * 100
acceptable_under_chaos: <= 2%
```

### Recovery Time

```yaml
metric: recovery_time
unit: seconds
calculation: time from chaos injection to system stabilization
definition_of_stable: error rate < 1%, throughput > 80% of baseline
```

### Resource Usage

```yaml
metric: resource_usage
estimate: CPU time (user + system), memory footprint
reporting: min, mean, max
note: Estimates based on task execution time, no external monitoring required
```

---

## Validation Criteria

### Must-Pass Criteria

- **No data loss:** All state changes must be persisted or recoverable
- **Responsiveness:** System must respond to requests within 5 seconds (even under chaos)
- **Recovery:** After chaos injection, system must stabilize within 10 seconds
- **Error rate:** Maximum 2% errors under heavy load with chaos

### Pass Conditions

```bash
# Light load: All tasks complete, error rate < 0.5%
eval_light() {
  completed=$(($(grep -c "task_complete" chaos_log.txt)))
  errors=$(($(grep -c "task_error" chaos_log.txt)))
  rate=$(( (errors * 100) / completed ))
  [ "$rate" -lt 1 ] && [ "$completed" -gt 250 ]
}

# Medium load: All tasks complete, error rate < 1%
eval_medium() {
  completed=$(($(grep -c "task_complete" chaos_log.txt)))
  errors=$(($(grep -c "task_error" chaos_log.txt)))
  rate=$(( (errors * 100) / completed ))
  [ "$rate" -lt 2 ] && [ "$completed" -gt 480 ]
}

# Heavy load: Tasks complete, error rate < 2%
eval_heavy() {
  completed=$(($(grep -c "task_complete" chaos_log.txt)))
  errors=$(($(grep -c "task_error" chaos_log.txt)))
  rate=$(( (errors * 100) / completed ))
  [ "$rate" -lt 3 ] && [ "$completed" -gt 600 ]
}

# Chaos resilience: State machine remains valid
eval_chaos_resilience() {
  invalid_states=$(($(grep -c "invalid_fsm_state" chaos_log.txt)))
  [ "$invalid_states" -eq 0 ]
}
```

---

## Deterministic Chaos

### Seed-Based Randomness

All chaos patterns use a seed to ensure reproducibility.

```bash
# Initialize chaos with seed
export CHAOS_SEED=12345

# Run 1: Seed 12345 produces identical chaos pattern
chaos-tester.sh chaos --pattern state-flip --seed 12345

# Run 2: Seed 12345 produces same chaos pattern (reproducible)
chaos-tester.sh chaos --pattern state-flip --seed 12345

# Different seed produces different chaos
chaos-tester.sh chaos --pattern state-flip --seed 54321
```

### Non-Destructive

All chaos testing must:
- Operate on isolated test state (not production data)
- Clean up after tests complete
- Leave no dangling processes or file handles
- Restore filesystem to clean state

---

## Reporting

### Summary Report Format

```
Chaos Testing Report
====================
Test Date: 2026-06-30
Duration: 60 seconds
Load Profile: medium

Throughput:
  Total Tasks: 1,200
  Completed: 1,176 (98%)
  Failed: 24 (2%)
  Ops/sec: 19.6

Latency (ms):
  Min: 10
  P50: 45
  P99: 250
  Max: 510

Chaos Patterns Applied:
  state-flip: 5 injections, 0 recovery failures
  message-drop: 3 injections, 0 data loss
  latency-injection: 12 injections, no timeouts
  deadlock-simulation: 2 injections, detected and recovered

Recovery Time:
  Baseline error rate: 0.2%
  After chaos: 1.8%
  Time to stabilize: 2.1 seconds

Resource Usage:
  CPU: mean=18%, max=35%
  Memory: mean=42MB, max=67MB

Status: PASS ✓
```

---

## Constraints

### No External Dependencies

- Use only bash (Bourne-Again Shell)
- No Docker, Kubernetes, or container orchestration
- No external monitoring tools
- No cloud services
- Simulate concurrency with bash job control (`&` and `wait`)

### Simulated Workload

Load tests simulate work with configurable patterns:

```bash
# Simple operation: sleep + random failure
simple_task() {
  sleep 0.1
  [ $((RANDOM % 200)) -lt 1 ] && return 1 || return 0
}

# Standard operation: sleep + state update
standard_task() {
  sleep 0.2
  update_state_file
  [ $((RANDOM % 100)) -lt 1 ] && return 1 || return 0
}

# Intensive operation: sleep + cpu spin
intensive_task() {
  for i in $(seq 1 10000); do
    expr $i % 100 > /dev/null
  done
  [ $((RANDOM % 50)) -lt 1 ] && return 1 || return 0
}
```

### Reproducibility

- All random numbers seeded (`CHAOS_SEED` environment variable)
- Same seed = same chaos pattern and workload
- Test results are deterministic and comparable

---

## Integration Points

### With W11 (State Machine)

FSM validation:
- State-flip chaos validates FSM transition guards
- Invalid state rejection prevents cascading failures
- FSM logs state transitions for audit

### With W12 (Recovery)

Recovery validation:
- Message-drop chaos validates idempotent recovery
- Deadlock simulation validates deadlock detection (W11) and recovery
- Recovery time metric measures effectiveness of W12 mechanisms

### With W13 (Orchestration)

Orchestration validation:
- Multi-task load testing validates task scheduling
- Message-drop chaos validates orchestration protocol
- Throughput metric validates scheduler efficiency

### With W17 (Final Validation)

W17 uses hardening metrics:
- Load profile results (throughput, latency, error rate)
- Chaos resilience scores (recovery time, data consistency)
- Stress test capacity limits
- Recommendations for production deployment

---

## Success Definition

**All 4 evals must pass:**

```bash
eval_1() { grep -q "chaos_patterns:" .specs/shared/hardening-contract.md; }
eval_2() { tools/chaos-tester.sh load > /dev/null 2>&1 && tools/chaos-tester.sh chaos > /dev/null 2>&1; }
eval_3() { grep -q "chaos-tester" agents/altitude-report.agent.md; }
eval_4() { bash test/fixtures/harness-v3/wave-16-hardening-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```
