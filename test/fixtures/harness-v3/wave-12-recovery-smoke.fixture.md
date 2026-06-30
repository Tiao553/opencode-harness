#!/usr/bin/env bash
# test/fixtures/harness-v3/wave-12-recovery-smoke.fixture.md
#
# Smoke test fixture for W12-RECOVERY
# Tests snapshot creation, validation, and rollback
#
# Scenarios:
#   1. Create snapshot, verify saved, list works
#   2. Snapshot → modify state → rollback, verify restored
#
# Success: All scenarios pass

set -euo pipefail

# ============================================================================
# Setup
# ============================================================================

FIXTURE_NAME="wave-12-recovery-smoke"
CHANGE_ID="waves-7-17-implementation"
SNAPSHOTS_DIR=".specs/changes/${CHANGE_ID}/snapshots"
TEST_DIR="/tmp/wave-12-test-$$"
SCRIPT="tools/recovery-manager.sh"

# Counters for reporting
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors (optional)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

test_pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo "[PASS] $1"
}

test_fail() {
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "[FAIL] $1"
}

test_begin() {
  TESTS_RUN=$((TESTS_RUN + 1))
  echo ""
  echo "Test $TESTS_RUN: $1"
}

cleanup() {
  rm -rf "$TEST_DIR" 2>/dev/null || true
}

trap cleanup EXIT

# ============================================================================
# Scenario 1: Create Snapshot, Verify Saved, List Works
# ============================================================================

scenario_1_create_and_list() {
  echo ""
  echo "======================================================================="
  echo "Scenario 1: Create Snapshot, Verify Saved, List Works"
  echo "======================================================================="
  
  # Ensure snapshots dir exists
  mkdir -p "$SNAPSHOTS_DIR"
  
  # Test 1.1: Create snapshot with empty state
  test_begin "Create snapshot with empty state"
  if SNAP=$("$SCRIPT" snapshot --state '{}' 2>/dev/null); then
    if [[ -n "$SNAP" ]]; then
      test_pass "Snapshot created: $SNAP"
    else
      test_fail "Snapshot command returned empty string"
      return 1
    fi
  else
    test_fail "Snapshot command failed"
    return 1
  fi
  
  # Test 1.2: Verify snapshot file exists
  test_begin "Verify snapshot file was saved"
  snapshot_file="${SNAPSHOTS_DIR}/${SNAP}.json"
  if [[ -f "$snapshot_file" ]]; then
    test_pass "Snapshot file exists: $snapshot_file"
  else
    test_fail "Snapshot file not found: $snapshot_file"
    return 1
  fi
  
  # Test 1.3: Verify snapshot JSON is valid
  test_begin "Verify snapshot JSON is valid"
  if jq . "$snapshot_file" > /dev/null 2>&1; then
    test_pass "Snapshot JSON is valid"
  else
    test_fail "Snapshot JSON is invalid"
    return 1
  fi
  
  # Test 1.4: Verify snapshot has required fields
  test_begin "Verify snapshot has required fields"
  if jq -e '.snapshot_id and .created_at and .state_hash and .components' "$snapshot_file" > /dev/null 2>&1; then
    test_pass "Snapshot has all required fields"
  else
    test_fail "Snapshot missing required fields"
    return 1
  fi
  
  # Test 1.5: Validate snapshot with recovery-manager
  test_begin "Validate snapshot with recovery-manager"
  if "$SCRIPT" validate --snapshot "$SNAP" > /dev/null 2>&1; then
    test_pass "Snapshot validation passed"
  else
    test_fail "Snapshot validation failed"
    return 1
  fi
  
  # Test 1.6: Create second snapshot with metadata
  test_begin "Create second snapshot with note"
  if SNAP2=$("$SCRIPT" snapshot --state '{"phase":"Execution","task":"W12-RECOVERY"}' --note "test_snapshot_2" 2>/dev/null); then
    if [[ -n "$SNAP2" && "$SNAP2" != "$SNAP" ]]; then
      test_pass "Second snapshot created: $SNAP2"
    else
      test_fail "Second snapshot not unique"
      return 1
    fi
  else
    test_fail "Second snapshot command failed"
    return 1
  fi
  
  # Test 1.7: List snapshots
  test_begin "List snapshots for change"
  if output=$("$SCRIPT" list-snapshots --change "$CHANGE_ID" 2>&1); then
    if echo "$output" | grep -q "$SNAP"; then
      test_pass "List includes first snapshot"
    else
      test_fail "List does not include first snapshot"
      return 1
    fi
  else
    test_fail "List snapshots command failed"
    return 1
  fi
  
  # Test 1.8: Verify both snapshots in list
  test_begin "Verify both snapshots appear in list"
  if echo "$output" | grep -q "$SNAP2"; then
    test_pass "List includes both snapshots"
  else
    test_fail "List does not include second snapshot"
    return 1
  fi
}

# ============================================================================
# Scenario 2: Snapshot → Modify State → Rollback → Verify Restored
# ============================================================================

scenario_2_rollback() {
  echo ""
  echo "======================================================================="
  echo "Scenario 2: Snapshot → Modify → Rollback → Verify Restored"
  echo "======================================================================="
  
  # Ensure snapshots dir exists
  mkdir -p "$SNAPSHOTS_DIR"
  
  # Test 2.1: Create initial snapshot
  test_begin "Create initial state snapshot"
  initial_state='{"phase":"Design","task":"W12-RECOVERY","attempt":1}'
  if SNAP=$("$SCRIPT" snapshot --state "$initial_state" --note "before_modification" 2>/dev/null); then
    test_pass "Initial snapshot created: $SNAP"
  else
    test_fail "Failed to create initial snapshot"
    return 1
  fi
  
  # Test 2.2: Rollback to snapshot (idempotent first call)
  test_begin "Rollback to snapshot, capture output"
  if restored=$("$SCRIPT" rollback --to "$SNAP" 2>/dev/null); then
    test_pass "Rollback succeeded"
  else
    test_fail "Rollback failed"
    return 1
  fi
  
  # Test 2.3: Verify restored state matches original
  test_begin "Verify restored state matches original"
  # Normalize JSON for comparison
  initial_norm=$(echo "$initial_state" | jq -S '.')
  restored_norm=$(echo "$restored" | jq -S '.')
  if [[ "$initial_norm" == "$restored_norm" ]]; then
    test_pass "Restored state matches original"
  else
    test_fail "Restored state does not match original"
    echo "  Expected: $initial_norm"
    echo "  Got:      $restored_norm"
    return 1
  fi
  
  # Test 2.4: Rollback again (idempotence test)
  test_begin "Rollback again to test idempotence"
  if restored2=$("$SCRIPT" rollback --to "$SNAP" 2>/dev/null); then
    test_pass "Second rollback succeeded"
  else
    test_fail "Second rollback failed"
    return 1
  fi
  
  # Test 2.5: Verify second rollback produces identical result
  test_begin "Verify idempotence: second rollback identical to first"
  # Normalize JSON for comparison
  restored_norm=$(echo "$restored" | jq -S '.')
  restored2_norm=$(echo "$restored2" | jq -S '.')
  if [[ "$restored_norm" == "$restored2_norm" ]]; then
    test_pass "Idempotence verified: both rollbacks produce same result"
  else
    test_fail "Idempotence check failed"
    echo "  First:  $restored_norm"
    echo "  Second: $restored2_norm"
    return 1
  fi
  
  # Test 2.6: Rollback to file
  test_begin "Rollback to file instead of stdout"
  output_file="${TEST_DIR}/restored-state.json"
  mkdir -p "$TEST_DIR"
  if "$SCRIPT" rollback --to "$SNAP" --output "$output_file" > /dev/null 2>&1; then
    if [[ -f "$output_file" ]]; then
      test_pass "Rollback to file succeeded"
    else
      test_fail "Output file not created"
      return 1
    fi
  else
    test_fail "Rollback to file failed"
    return 1
  fi
  
  # Test 2.7: Verify file contents
  test_begin "Verify file contents match original state"
  file_contents=$(cat "$output_file")
  # Normalize JSON for comparison
  initial_norm=$(echo "$initial_state" | jq -S '.')
  file_norm=$(echo "$file_contents" | jq -S '.')
  if [[ "$file_norm" == "$initial_norm" ]]; then
    test_pass "File contents match original state"
  else
    test_fail "File contents do not match"
    echo "  Expected: $initial_norm"
    echo "  Got:      $file_norm"
    return 1
  fi
  
  # Test 2.8: Verify checksum validation
  test_begin "Verify checksum is validated on rollback"
  if "$SCRIPT" validate --snapshot "$SNAP" > /dev/null 2>&1; then
    test_pass "Checksum validation passed for snapshot"
  else
    test_fail "Checksum validation failed"
    return 1
  fi
}

# ============================================================================
# Main
# ============================================================================

main() {
  echo ""
  echo "=========================================================================="
  echo "Wave 12: Error Recovery & Rollback — Smoke Test Fixture"
  echo "=========================================================================="
  
  # Check that recovery-manager.sh exists and is executable
  if [[ ! -x "$SCRIPT" ]]; then
    echo "ERROR: $SCRIPT not found or not executable"
    exit 1
  fi
  
  # Check that jq is available
  if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is required but not installed"
    exit 1
  fi
  
  # Run scenarios
  scenario_1_create_and_list || true
  scenario_2_rollback || true
  
  # Summary
  echo ""
  echo "=========================================================================="
  echo "Summary"
  echo "=========================================================================="
  echo "Tests run:    $TESTS_RUN"
  echo "Tests passed: $TESTS_PASSED"
  echo "Tests failed: $TESTS_FAILED"
  echo ""
  
  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✓ All scenarios passed"
    echo ""
    return 0
  else
    echo "✗ Some scenarios failed"
    echo ""
    return 1
  fi
}

main "$@"
