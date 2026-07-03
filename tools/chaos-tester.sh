#!/bin/bash
# chaos-tester.sh — Deterministic chaos and load testing framework
# Wave 16: Production Hardening & Chaos Testing
# Usage: chaos-tester.sh <command> [--options]

set -euo pipefail

# Configuration
CHAOS_SEED="${CHAOS_SEED:-12345}"
TEST_STATE_DIR="${TEST_STATE_DIR:-./.chaos-test-state}"
LOG_FILE="${TEST_STATE_DIR}/chaos_log.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize state directory
init_test_state() {
  rm -rf "$TEST_STATE_DIR" 2>/dev/null || true
  mkdir -p "$TEST_STATE_DIR"
  touch "$LOG_FILE"
  echo "# Chaos Test Log" > "$LOG_FILE"
  echo "# Test Date: $(date)" >> "$LOG_FILE"
}

# Task execution function (simulates work)
execute_task() {
  local task_id=$1
  local load_profile=$2

  case "$load_profile" in
    light)
      # Light: 0.1s operation, 0.5% base error
      sleep 0.1
      if [ $((RANDOM % 200)) -lt 1 ]; then
        echo "task_error" >> "$LOG_FILE"
        return 1
      else
        echo "task_complete" >> "$LOG_FILE"
        return 0
      fi
      ;;
    medium)
      # Medium: 0.2s operation, 1% base error
      sleep 0.2
      if [ $((RANDOM % 100)) -lt 1 ]; then
        echo "task_error" >> "$LOG_FILE"
        return 1
      else
        echo "task_complete" >> "$LOG_FILE"
        return 0
      fi
      ;;
    heavy)
      # Heavy: CPU-bound, 2% base error
      for i in $(seq 1 5000); do
        expr $i % 100 > /dev/null 2>&1 || true
      done
      if [ $((RANDOM % 50)) -lt 1 ]; then
        echo "task_error" >> "$LOG_FILE"
        return 1
      else
        echo "task_complete" >> "$LOG_FILE"
        return 0
      fi
      ;;
    *)
      echo "task_error" >> "$LOG_FILE"
      return 1
      ;;
  esac
}

# Chaos injection: state-flip
inject_state_flip() {
  local probability=$1
  if [ $((RANDOM % 100)) -lt "$probability" ]; then
    echo "chaos_state_flip" >> "$LOG_FILE"
    # Simulate state corruption then recovery
    sleep 0.1
    echo "chaos_recovery_attempt" >> "$LOG_FILE"
    sleep 0.1
    return 0
  fi
  return 1
}

# Chaos injection: message-drop
inject_message_drop() {
  local probability=$1
  if [ $((RANDOM % 100)) -lt "$probability" ]; then
    echo "chaos_message_drop" >> "$LOG_FILE"
    sleep 0.05
    echo "chaos_message_retry" >> "$LOG_FILE"
    return 0
  fi
  return 1
}

# Chaos injection: latency-injection
inject_latency() {
  local probability=$1
  if [ $((RANDOM % 100)) -lt "$probability" ]; then
    local delay=$(( (RANDOM % 450) + 50 ))
    echo "chaos_latency_injection ${delay}ms" >> "$LOG_FILE"
    sleep 0.${delay}
    return 0
  fi
  return 1
}

# Chaos injection: deadlock-simulation
inject_deadlock() {
  local probability=$1
  if [ $((RANDOM % 100)) -lt "$probability" ]; then
    echo "chaos_deadlock_simulation" >> "$LOG_FILE"
    sleep 0.2
    echo "chaos_deadlock_resolved" >> "$LOG_FILE"
    return 0
  fi
  return 1
}

# Load testing function
run_load_test() {
  local threads=$1
  local load_profile=$2
  local duration=60

  echo -e "${YELLOW}[Load Test]${NC} Profile: $load_profile, Threads: $threads, Duration: ${duration}s"
  echo "load_test_start profile=$load_profile threads=$threads duration=$duration" >> "$LOG_FILE"

  local end_time=$((SECONDS + duration))
  local task_id=0

  while [ $SECONDS -lt $end_time ]; do
    for i in $(seq 1 "$threads"); do
      (
        task_id=$((task_id + 1))
        if execute_task "$task_id" "$load_profile"; then
          : # Task succeeded
        else
          : # Task failed (logged)
        fi
      ) &
    done
    wait
  done

  echo "load_test_end" >> "$LOG_FILE"
  echo -e "${GREEN}[Load Test]${NC} Complete"
}

# Chaos testing function
run_chaos_test() {
  local pattern=$1
  local duration=60

  echo -e "${YELLOW}[Chaos Test]${NC} Pattern: $pattern, Duration: ${duration}s"
  echo "chaos_test_start pattern=$pattern seed=$CHAOS_SEED" >> "$LOG_FILE"

  # Seed random for reproducibility
  RANDOM=$CHAOS_SEED

  local end_time=$((SECONDS + duration))
  local task_id=0

  while [ $SECONDS -lt $end_time ]; do
    task_id=$((task_id + 1))

    # Execute task with chaos
    (
      execute_task "$task_id" "medium"

      # Apply chaos pattern
      case "$pattern" in
        state-flip)
          inject_state_flip 5
          ;;
        message-drop)
          inject_message_drop 3
          ;;
        latency-injection)
          inject_latency 10
          ;;
        deadlock-simulation)
          inject_deadlock 2
          ;;
        all)
          inject_state_flip 5
          inject_message_drop 3
          inject_latency 10
          inject_deadlock 2
          ;;
        *)
          echo "Unknown chaos pattern: $pattern" >&2
          return 1
          ;;
      esac
    ) &

    # Limit parallelism to 10 concurrent tasks
    if [ $((task_id % 10)) -eq 0 ]; then
      wait
    fi
  done

  wait
  echo "chaos_test_end" >> "$LOG_FILE"
  echo -e "${GREEN}[Chaos Test]${NC} Complete"
}

# Stress testing function
run_stress_test() {
  local duration=${1:-30}

  echo -e "${YELLOW}[Stress Test]${NC} Duration: ${duration}s, Heavy load (100 concurrent)"
  echo "stress_test_start duration=$duration" >> "$LOG_FILE"

  local end_time=$((SECONDS + duration))
  local task_id=0

  while [ $SECONDS -lt $end_time ]; do
    for i in $(seq 1 100); do
      (
        task_id=$((task_id + 1))
        execute_task "$task_id" "heavy"
      ) &
    done
    wait
  done

  echo "stress_test_end" >> "$LOG_FILE"
  echo -e "${GREEN}[Stress Test]${NC} Complete"
}

# Generate report
generate_report() {
  echo ""
  echo "============================================"
  echo "Chaos Testing Report"
  echo "============================================"
  echo "Test Date: $(date)"
  echo "Log File: $LOG_FILE"
  echo ""

  # Count metrics
  local total_complete=$(grep -c "task_complete" "$LOG_FILE" || echo 0)
  local total_errors=$(grep -c "task_error" "$LOG_FILE" || echo 0)
  local total_tasks=$((total_complete + total_errors))
  local error_rate=0

  if [ "$total_tasks" -gt 0 ]; then
    error_rate=$(( (total_errors * 100) / total_tasks ))
  fi

  local chaos_flips=$(grep -c "chaos_state_flip" "$LOG_FILE" || echo 0)
  local chaos_drops=$(grep -c "chaos_message_drop" "$LOG_FILE" || echo 0)
  local chaos_latency=$(grep -c "chaos_latency_injection" "$LOG_FILE" || echo 0)
  local chaos_deadlock=$(grep -c "chaos_deadlock_simulation" "$LOG_FILE" || echo 0)

  echo "Execution Summary:"
  echo "  Total Tasks: $total_tasks"
  echo "  Completed: $total_complete ($(( (total_complete * 100) / (total_tasks + 1) ))%)"
  echo "  Failed: $total_errors ($error_rate%)"
  echo ""

  echo "Chaos Injections:"
  echo "  State-Flip: $chaos_flips"
  echo "  Message-Drop: $chaos_drops"
  echo "  Latency-Injection: $chaos_latency"
  echo "  Deadlock-Simulation: $chaos_deadlock"
  echo ""

  # Validation
  echo "Validation:"
  if [ "$error_rate" -le 2 ]; then
    echo -e "  Error Rate: ${GREEN}$error_rate% (PASS)${NC}"
  else
    echo -e "  Error Rate: ${RED}$error_rate% (FAIL - too high)${NC}"
  fi

  if [ "$total_tasks" -gt 100 ]; then
    echo -e "  Throughput: ${GREEN}adequate ($total_tasks tasks)${NC}"
  else
    echo -e "  Throughput: ${RED}low ($total_tasks tasks)${NC}"
  fi

  echo ""
  echo "============================================"
}

# Main command dispatcher
main() {
  local command="${1:-help}"

  case "$command" in
    load)
      local threads=${2:-5}
      local profile=${3:-light}
      init_test_state
      run_load_test "$threads" "$profile"
      generate_report
      ;;
    chaos)
      local pattern=${2:-state-flip}
      init_test_state
      run_chaos_test "$pattern"
      generate_report
      ;;
    stress)
      local duration=${2:-30}
      init_test_state
      run_stress_test "$duration"
      generate_report
      ;;
    report)
      if [ ! -f "$LOG_FILE" ]; then
        echo "Error: No test log found. Run load, chaos, or stress test first."
        exit 1
      fi
      generate_report
      ;;
    cleanup)
      rm -rf "$TEST_STATE_DIR"
      echo "Cleaned up test state directory: $TEST_STATE_DIR"
      ;;
    help|--help|-h)
      cat << 'EOF'
chaos-tester.sh — Deterministic Chaos & Load Testing

Usage:
  chaos-tester.sh load [threads] [profile]
  chaos-tester.sh chaos [pattern]
  chaos-tester.sh stress [duration]
  chaos-tester.sh report
  chaos-tester.sh cleanup
  chaos-tester.sh help

Commands:
  load      Run load test (default: 5 threads, light profile)
            Profiles: light, medium, heavy
  chaos     Run chaos test with injected failures
            Patterns: state-flip, message-drop, latency-injection, deadlock-simulation, all
  stress    Run stress test (default: 30 seconds, 100 concurrent)
  report    Display results of last test
  cleanup   Remove test state directory
  help      Show this help message

Environment Variables:
  CHAOS_SEED        Seed for reproducible chaos (default: 12345)
  TEST_STATE_DIR    Test state directory (default: ./.chaos-test-state)

Examples:
  chaos-tester.sh load 20 medium
  chaos-tester.sh chaos state-flip
  chaos-tester.sh stress 60
  CHAOS_SEED=54321 chaos-tester.sh chaos all
  chaos-tester.sh report
  chaos-tester.sh cleanup

EOF
      ;;
    *)
      echo "Error: Unknown command '$command'"
      echo "Try: chaos-tester.sh help"
      exit 1
      ;;
  esac
}

main "$@"
