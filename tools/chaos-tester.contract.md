# chaos-tester.sh — Contract & Command Reference [Wave 16]

## Overview

`chaos-tester.sh` is a deterministic, bash-only framework for load testing, chaos injection, and stress testing the Harness V3 system.

**Location:** `tools/chaos-tester.sh`  
**Executable:** Yes  
**Dependencies:** None (pure bash)

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Failure (unknown command, missing log, etc.) |

---

## Commands

### `load [threads] [profile]`

Run a load test with concurrent simulated tasks.

**Syntax:**
```bash
chaos-tester.sh load [threads] [profile]
```

**Parameters:**
- `threads` (optional, default: 5)
  - Number of concurrent tasks
  - Recommended: 5 (light), 20 (medium), 100 (heavy)
- `profile` (optional, default: light)
  - Workload profile: `light`, `medium`, `heavy`
  - Determines task complexity and duration

**Duration:** 60 seconds (fixed)

**Example:**
```bash
# Light load (5 concurrent, fast operations)
chaos-tester.sh load 5 light

# Medium load (20 concurrent)
chaos-tester.sh load 20 medium

# Heavy load (100 concurrent, CPU-intensive)
chaos-tester.sh load 100 heavy

# Default (5 light)
chaos-tester.sh load
```

**Output:**
- Console: Progress message and final report
- File: Appends to `.chaos-test-state/chaos_log.txt`

**Metrics Captured:**
- Total tasks attempted
- Tasks completed
- Tasks failed
- Error rate (percentage)
- Chaos injections (if any)

**Pass Criteria:**
- Light: error rate ≤ 0.5%, ≥ 250 completed tasks
- Medium: error rate ≤ 1.0%, ≥ 480 completed tasks
- Heavy: error rate ≤ 2.0%, ≥ 600 completed tasks

---

### `chaos [pattern]`

Run a chaos test with injected failures.

**Syntax:**
```bash
chaos-tester.sh chaos [pattern]
```

**Patterns:**
- `state-flip` (default)
  - Randomly flip component state during execution
  - Probability: 5% per cycle
  - Tests FSM resilience

- `message-drop`
  - Simulate lost messages or dropped results
  - Probability: 3% per cycle
  - Tests protocol robustness and idempotency

- `latency-injection`
  - Add random delays (50-500ms) to operations
  - Probability: 10% per cycle
  - Tests timeout handling and user expectations

- `deadlock-simulation`
  - Force circular wait conditions
  - Probability: 2% per cycle
  - Tests deadlock detection (W11) and recovery

- `all`
  - Apply all chaos patterns simultaneously
  - Combined probability: ~18% per cycle

**Duration:** 60 seconds (fixed)

**Example:**
```bash
# State-flip chaos (default)
chaos-tester.sh chaos

# Message-drop chaos
chaos-tester.sh chaos message-drop

# Latency injection
chaos-tester.sh chaos latency-injection

# Deadlock simulation
chaos-tester.sh chaos deadlock-simulation

# All patterns combined
chaos-tester.sh chaos all

# Reproducible chaos (same seed = same pattern)
CHAOS_SEED=12345 chaos-tester.sh chaos state-flip
```

**Output:**
- Console: Progress message and final report
- File: Appends to `.chaos-test-state/chaos_log.txt`

**Metrics Captured:**
- Total tasks
- Completed vs. failed
- Chaos injections applied
- Recovery attempts
- Error rate

**Pass Criteria:**
- Error rate ≤ 2% (even with chaos)
- All chaos injections logged
- Recoveries successful (no hung tasks)
- FSM state remains valid (no invalid state entries)

---

### `stress [duration]`

Run a stress test with sustained high concurrency.

**Syntax:**
```bash
chaos-tester.sh stress [duration]
```

**Parameters:**
- `duration` (optional, default: 30 seconds)
  - Test duration in seconds
  - Fixed concurrency: 100 tasks per cycle

**Example:**
```bash
# Standard stress test (30 seconds)
chaos-tester.sh stress

# Extended stress test (60 seconds)
chaos-tester.sh stress 60

# Quick stress test (10 seconds)
chaos-tester.sh stress 10
```

**Output:**
- Console: Progress message and final report
- File: Appends to `.chaos-test-state/chaos_log.txt`

**Metrics Captured:**
- Total tasks attempted
- Tasks completed
- Tasks failed
- Error rate
- Sustained throughput

**Pass Criteria:**
- Error rate ≤ 2%
- Throughput: ≥ 100 tasks/min (avg)
- System remains responsive (no hangs)
- Memory usage remains bounded

---

### `report`

Display the results of the last test run.

**Syntax:**
```bash
chaos-tester.sh report
```

**Output:**
- Execution summary (total, completed, failed, error rate)
- Chaos injections summary (by pattern)
- Validation results
- Pass/Fail status

**Example:**
```bash
# Run a test, then display results
chaos-tester.sh load 20 medium
chaos-tester.sh report

# View report without running test (if log exists)
chaos-tester.sh report
```

**Output Format:**

```
============================================
Chaos Testing Report
============================================
Test Date: 2026-06-30 10:15:32 UTC
Log File: ./.chaos-test-state/chaos_log.txt

Execution Summary:
  Total Tasks: 1,200
  Completed: 1,176 (98%)
  Failed: 24 (2%)

Chaos Injections:
  State-Flip: 5
  Message-Drop: 3
  Latency-Injection: 12
  Deadlock-Simulation: 2

Validation:
  Error Rate: 2% (PASS)
  Throughput: adequate (1,200 tasks)

============================================
```

**Exit Code:**
- 0: Report generated successfully
- 1: No log found (run a test first)

---

### `cleanup`

Remove test state directory and logs.

**Syntax:**
```bash
chaos-tester.sh cleanup
```

**Effect:**
- Deletes `.chaos-test-state/` directory (or `$TEST_STATE_DIR`)
- Removes all logs and temporary files

**Example:**
```bash
# Run tests, then clean up
chaos-tester.sh load 20 medium
chaos-tester.sh chaos state-flip
chaos-tester.sh cleanup
```

---

### `help`

Display command help.

**Syntax:**
```bash
chaos-tester.sh help
chaos-tester.sh --help
chaos-tester.sh -h
```

**Output:** Full usage guide and examples.

---

## Environment Variables

### `CHAOS_SEED`

**Default:** `12345`

Seed for reproducible random number generation in chaos tests.

**Effect:** Identical seed produces identical chaos patterns.

**Example:**
```bash
# Run 1: Seed 12345 (default)
chaos-tester.sh chaos state-flip

# Run 2: Seed 12345 (same chaos)
CHAOS_SEED=12345 chaos-tester.sh chaos state-flip

# Run 3: Seed 54321 (different chaos)
CHAOS_SEED=54321 chaos-tester.sh chaos state-flip
```

### `TEST_STATE_DIR`

**Default:** `./.chaos-test-state`

Directory for test logs and temporary state.

**Example:**
```bash
# Use custom state directory
TEST_STATE_DIR=/tmp/my-chaos-tests chaos-tester.sh load 20 medium
```

---

## Log Format

Test results are appended to `$TEST_STATE_DIR/chaos_log.txt`.

**Log Entry Format:**

```
# Chaos Test Log
# Test Date: 2026-06-30 10:15:32 UTC
load_test_start profile=light threads=5 duration=60
task_complete
task_error
task_complete
...
chaos_state_flip
chaos_recovery_attempt
...
load_test_end
```

**Log Entry Types:**
- `load_test_start` — Load test started
- `chaos_test_start` — Chaos test started
- `stress_test_start` — Stress test started
- `task_complete` — Task succeeded
- `task_error` — Task failed
- `chaos_state_flip` — State-flip injected
- `chaos_message_drop` — Message-drop injected
- `chaos_latency_injection <N>ms` — Latency injected
- `chaos_deadlock_simulation` — Deadlock injected
- `chaos_recovery_attempt` — Recovery attempted
- `*_test_end` — Test completed

---

## Determinism & Reproducibility

### Seed-Based Randomness

All random decisions (chaos injection timing, task failures) use seeded PRNG:

```bash
RANDOM=$CHAOS_SEED
```

Same seed + same command = identical behavior.

### Non-Destructive

Tests operate on isolated state:
- No modifications to application code
- No modifications to production data
- Temporary files cleaned up with `cleanup` command
- No dangling processes after test completes

### Deterministic Recovery

All recovery mechanisms are predictable:
- State-flip injection → 0.1s recovery delay
- Message-drop injection → 0.05s retry
- Latency injection → fixed 50-500ms delay
- Deadlock injection → 0.2s detection + recovery

---

## Integration with W11-W13

### W11 (State Machine)

State-flip chaos tests FSM resilience:
```bash
chaos-tester.sh chaos state-flip
```

Validates:
- FSM transition guards reject invalid states
- Recovery logic restores valid state
- No cascading failures from corrupted state

### W12 (Recovery)

Message-drop chaos tests recovery mechanisms:
```bash
chaos-tester.sh chaos message-drop
```

Validates:
- Idempotent recovery (retries safe)
- Message loss doesn't cause data loss
- System stabilizes after message drops

### W13 (Orchestration)

Multi-task load testing validates scheduling:
```bash
chaos-tester.sh load 20 medium
```

Validates:
- Task queue handles load
- No task starvation
- Throughput scales with threads

---

## Integration with W17 (Final Validation)

W17 uses hardening metrics from chaos-tester output:

```bash
# Collect metrics for final validation
chaos-tester.sh load 5 light && chaos-tester.sh report
chaos-tester.sh chaos state-flip && chaos-tester.sh report
chaos-tester.sh stress 30 && chaos-tester.sh report
```

Metrics fed to W17 validation gate:
- Throughput: operations/second
- Error rate: % of tasks failed
- Recovery time: seconds to stabilize
- Chaos resilience: % of chaos events recovered

---

## Testing Patterns

### Quick Smoke Test

```bash
# Run in CI/CD before merge
chaos-tester.sh load 5 light
chaos-tester.sh report
chaos-tester.sh cleanup
```

### Integration Test

```bash
# Run in staging before release
chaos-tester.sh load 20 medium
chaos-tester.sh chaos state-flip
chaos-tester.sh chaos message-drop
chaos-tester.sh report
chaos-tester.sh cleanup
```

### Endurance Test

```bash
# Run overnight for capacity planning
chaos-tester.sh stress 3600
chaos-tester.sh report
chaos-tester.sh cleanup
```

---

## Troubleshooting

### No Log File Found

**Error:** `Error: No test log found. Run load, chaos, or stress test first.`

**Solution:** Run a test before calling `report`:
```bash
chaos-tester.sh load 5 light
chaos-tester.sh report
```

### High Error Rate

**Problem:** Error rate > threshold

**Cause:** Workload too intense for system

**Solution:** Use lighter profile:
```bash
chaos-tester.sh load 5 light   # vs. 20 medium
```

### Test Hangs

**Problem:** Test doesn't complete in expected time

**Cause:** Too many concurrent tasks (system overload)

**Solution:** Reduce thread count:
```bash
chaos-tester.sh load 5 light   # vs. 100 heavy
```

### Non-Reproducible Chaos

**Problem:** Different chaos pattern each run

**Cause:** CHAOS_SEED not set or different seed

**Solution:** Set CHAOS_SEED environment variable:
```bash
export CHAOS_SEED=12345
chaos-tester.sh chaos state-flip
```

---

## Version

**Wave 16 Deliverable**  
**Version:** 1.0  
**Last Updated:** 2026-06-30
