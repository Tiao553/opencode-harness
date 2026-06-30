#!/bin/bash

# Wave 11: State Machine Formalization — Smoke Test Fixture
# Tests: valid transitions, invalid blocking, deadlock detection, rework loop

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
STATE_VALIDATOR="$OPENCODE_ROOT/tools/state-validator.sh"

# === Test Configuration ===

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

log_test() {
  echo "[TEST] $*"
}

log_pass() {
  echo "  ✓ $*"
  ((TESTS_PASSED++))
}

log_fail() {
  echo "  ✗ $*"
  ((TESTS_FAILED++))
  return 1
}

log_skip() {
  echo "  ⊗ $*"
  ((TESTS_SKIPPED++))
}

# === Scenario 1: Valid State Transitions ===

scenario_valid_transitions() {
  log_test "Scenario 1: Valid Happy Path (Intent → Structure → Design → Execution → Validate → Ship)"

  local transitions=(
    "Intent:Structure"
    "Structure:Design"
    "Design:Execution"
    "Execution:Validate"
    "Validate:Ship"
  )

  for trans in "${transitions[@]}"; do
    IFS=: read -r from to <<< "$trans"
    if "$STATE_VALIDATOR" validate "$from" "$to" > /dev/null 2>&1; then
      log_pass "$from → $to"
    else
      log_fail "$from → $to should be valid"
      return 1
    fi
  done

  # Fast-track path (Design → Validate, skip Execution)
  if "$STATE_VALIDATOR" validate "Design" "Validate" > /dev/null 2>&1; then
    log_pass "Design → Validate (fast-track)"
  else
    log_fail "Design → Validate should be valid"
    return 1
  fi

  # Rework loop (Validate → Design)
  if "$STATE_VALIDATOR" validate "Validate" "Design" > /dev/null 2>&1; then
    log_pass "Validate → Design (rework loop)"
  else
    log_fail "Validate → Design should be valid"
    return 1
  fi
}

# === Scenario 2: Invalid Transitions Blocked ===

scenario_invalid_transitions() {
  log_test "Scenario 2: Invalid Transitions Blocked"

  local forbidden=(
    "Ship:Intent"
    "Intent:Execution"
    "Structure:Intent"
    "Execution:Design"
    "Validate:Execution"
    "Design:Design"
    "Intent:Intent"
    "Ship:Ship"
  )

  for trans in "${forbidden[@]}"; do
    IFS=: read -r from to <<< "$trans"
    if "$STATE_VALIDATOR" validate "$from" "$to" > /dev/null 2>&1; then
      log_fail "$from → $to should be INVALID but passed"
      return 1
    else
      log_pass "$from → $to correctly rejected"
    fi
  done
}

# === Scenario 3: Deadlock Detection ===

scenario_deadlock_detection() {
  log_test "Scenario 3: Deadlock Detection"

  # Create a circular trace (deadlock scenario)
  local trace_file=$(mktemp)
  cat > "$trace_file" << 'TRACE'
# Circular wait deadlock
state Execution waiting_for Validate_gate
state Validate waiting_for TestResults
state TestRunner waiting_for Execution
TRACE

  if "$STATE_VALIDATOR" deadlock-check --trace "$trace_file" > /dev/null 2>&1; then
    log_fail "Should have detected deadlock"
    rm "$trace_file"
    return 1
  else
    log_pass "Circular wait correctly detected as deadlock"
    rm "$trace_file"
  fi

  # Create a non-circular trace (no deadlock)
  local clean_trace=$(mktemp)
  cat > "$clean_trace" << 'TRACE'
# Linear progression (no deadlock)
state Intent waiting_for user_approval
state Structure waiting_for scope_review
state Design waiting_for architecture_approval
TRACE

  if "$STATE_VALIDATOR" deadlock-check --trace "$clean_trace" > /dev/null 2>&1; then
    log_pass "Linear trace correctly passes deadlock check"
    rm "$clean_trace"
  else
    log_fail "Should not detect deadlock in linear trace"
    rm "$clean_trace"
    return 1
  fi
}

# === Scenario 4: Rework Loop ===

scenario_rework_loop() {
  log_test "Scenario 4: Rework Loop (Validate → Design → Execution → Validate → Ship)"

  local transitions=(
    "Design:Execution"
    "Execution:Validate"
    "Validate:Design"  # Rework begins
    "Design:Execution"  # Rework second pass
    "Execution:Validate"
    "Validate:Ship"
  )

  for trans in "${transitions[@]}"; do
    IFS=: read -r from to <<< "$trans"
    if "$STATE_VALIDATOR" validate "$from" "$to" > /dev/null 2>&1; then
      log_pass "$from → $to"
    else
      log_fail "$from → $to should be valid in rework loop"
      return 1
    fi
  done
}

# === Scenario 5: Early Validation (Fast-track) ===

scenario_fast_track() {
  log_test "Scenario 5: Fast-Track (Design → Validate, skip Execution)"

  local transitions=(
    "Intent:Structure"
    "Structure:Design"
    "Design:Validate"  # Skip Execution
    "Validate:Ship"
  )

  for trans in "${transitions[@]}"; do
    IFS=: read -r from to <<< "$trans"
    if "$STATE_VALIDATOR" validate "$from" "$to" > /dev/null 2>&1; then
      log_pass "$from → $to"
    else
      log_fail "$from → $to should be valid in fast-track"
      return 1
    fi
  done
}

# === Scenario 6: Idempotent Validation ===

scenario_idempotent_validation() {
  log_test "Scenario 6: Idempotent Validation (same input → same result)"

  # Run the same validation multiple times
  for i in {1..3}; do
    if "$STATE_VALIDATOR" validate "Intent" "Structure" > /dev/null 2>&1; then
      log_pass "Run $i: Intent → Structure passed"
    else
      log_fail "Run $i: Intent → Structure should pass"
      return 1
    fi
  done

  for i in {1..3}; do
    if "$STATE_VALIDATOR" validate "Ship" "Intent" > /dev/null 2>&1; then
      log_fail "Run $i: Ship → Intent should fail"
      return 1
    else
      log_pass "Run $i: Ship → Intent failed (correct)"
    fi
  done
}

# === Scenario 7: FSM Graph Visualization ===

scenario_dump_graph() {
  log_test "Scenario 7: FSM Graph Visualization"

  local graph_output=$("$STATE_VALIDATOR" dump-graph)

  # Check for key elements
  if echo "$graph_output" | grep -q "Intent"; then
    log_pass "Graph includes Intent state"
  else
    log_fail "Graph should include Intent state"
    return 1
  fi

  if echo "$graph_output" | grep -q "Validate.*Design"; then
    log_pass "Graph includes rework edge (Validate → Design)"
  else
    log_fail "Graph should include rework edge"
    return 1
  fi

  if echo "$graph_output" | grep -q "Forbidden"; then
    log_pass "Graph includes forbidden transitions list"
  else
    log_fail "Graph should include forbidden transitions"
    return 1
  fi
}

# === Error Code Verification ===

scenario_error_codes() {
  log_test "Scenario 8: Error Code Verification"

  # Valid transition returns 0
  "$STATE_VALIDATOR" validate "Intent" "Structure" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    log_pass "Valid transition returns 0"
  else
    log_fail "Valid transition should return 0"
    return 1
  fi

  # Invalid transition returns 1
  local exit_code
  "$STATE_VALIDATOR" validate "Ship" "Intent" > /dev/null 2>&1
  exit_code=$?
  if [ $exit_code -eq 1 ]; then
    log_pass "Invalid transition returns 1"
  else
    log_fail "Invalid transition should return 1 (got $exit_code)"
    return 1
  fi

  # Unknown state returns 3
  "$STATE_VALIDATOR" validate "Intent" "Unknown" > /dev/null 2>&1
  exit_code=$?
  if [ $exit_code -eq 3 ]; then
    log_pass "Unknown state returns 3"
  else
    log_fail "Unknown state should return 3 (got $exit_code)"
    return 1
  fi

  # Self-loop returns 4
  "$STATE_VALIDATOR" validate "Design" "Design" > /dev/null 2>&1
  exit_code=$?
  if [ $exit_code -eq 4 ]; then
    log_pass "Self-loop returns 4"
  else
    log_fail "Self-loop should return 4 (got $exit_code)"
    return 1
  fi
}

# === Smoke Test Summary ===

run_all_scenarios() {
  echo "=========================================="
  echo "Wave 11: State Machine Smoke Tests"
  echo "=========================================="
  echo

  scenario_valid_transitions || return 1
  echo
  scenario_invalid_transitions || return 1
  echo
  scenario_deadlock_detection || return 1
  echo
  scenario_rework_loop || return 1
  echo
  scenario_fast_track || return 1
  echo
  scenario_idempotent_validation || return 1
  echo
  scenario_dump_graph || return 1
  echo
  scenario_error_codes || return 1
  echo

  echo "=========================================="
  echo "Test Results:"
  echo "  ✓ Passed:  $TESTS_PASSED"
  echo "  ✗ Failed:  $TESTS_FAILED"
  echo "  ⊗ Skipped: $TESTS_SKIPPED"
  echo "=========================================="

  if [ $TESTS_FAILED -gt 0 ]; then
    return 1
  fi

  return 0
}

# === Main ===

if [ ! -x "$STATE_VALIDATOR" ]; then
  echo "ERROR: state-validator.sh not found or not executable: $STATE_VALIDATOR" >&2
  exit 1
fi

run_all_scenarios
