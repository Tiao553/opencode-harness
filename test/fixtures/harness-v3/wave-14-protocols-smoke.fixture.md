#!/usr/bin/env bash

###############################################################################
# wave-14-protocols-smoke.fixture.md
#
# Multi-Agent Communication Protocol Smoke Tests
# Scenario 1: Send message and verify queue
# Scenario 2: Acknowledge message and verify cleared
###############################################################################

set -eu

# Get the root directory (3 levels up from fixtures)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
QUEUE_BASE="${ROOT_DIR}/.specs/changes/waves-7-17-implementation/queue"
TEST_AGENT="altitude-test-agent"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

cleanup() {
  # Clean up test queue
  rm -rf "${QUEUE_BASE:?}/${TEST_AGENT}" 2>/dev/null || true
}

test_pass() {
  echo "✓ $1"
  ((TESTS_PASSED++))
}

test_fail() {
  echo "✗ $1"
  ((TESTS_FAILED++))
  return 1
}

###############################################################################
# Scenario 1: Send message and verify queue
###############################################################################

scenario_1_send_and_queue() {
  echo "→ Scenario 1: Send message and verify queue"

  # Register test agent
  bash "${ROOT_DIR}/tools/agent-messenger.sh" register-agent --name "$TEST_AGENT" > /dev/null || test_fail "Could not register test agent"
  test_pass "Test agent registered"

  # Send message
  bash "${ROOT_DIR}/tools/agent-messenger.sh" send --to "$TEST_AGENT" --msg '{"agent_from":"altitude-execution","message_type":"task","payload":{"task_id":"W14-PROTOCOLS","action":"execute"}}' > /dev/null || test_fail "Could not send message"
  test_pass "Message sent successfully"

  # Verify message in queue (pending)
  local pending_count
  pending_count=$(find "${QUEUE_BASE}/${TEST_AGENT}/pending" -name "msg-*.json" 2>/dev/null | wc -l) || pending_count=0

  if (( pending_count != 1 )); then
    test_fail "Expected 1 pending message, found $pending_count"
  fi
  test_pass "Message queued in pending directory"

  # Get message ID from pending directory
  local msg_file
  msg_file=$(find "${QUEUE_BASE}/${TEST_AGENT}/pending" -name "msg-*.json" 2>/dev/null | head -1) || test_fail "No message file found"

  local msg_id
  msg_id=$(basename "$msg_file" | sed 's/msg-//; s/.json//')

  if [[ -z "$msg_id" ]]; then
    test_fail "Could not extract message_id"
  fi
  test_pass "Message has valid message_id: $msg_id"

  # Store msg_id for next scenario
  echo "$msg_id" > "${QUEUE_BASE}/test-msg-id.tmp"
}

###############################################################################
# Scenario 2: Acknowledge message and verify cleared
###############################################################################

scenario_2_ack_and_clear() {
  echo "→ Scenario 2: Acknowledge message and verify cleared"

  # Retrieve message ID from scenario 1
  if [[ ! -f "${QUEUE_BASE}/test-msg-id.tmp" ]]; then
    test_fail "Message ID not found (scenario 1 must run first)"
  fi

  local msg_id
  msg_id=$(cat "${QUEUE_BASE}/test-msg-id.tmp")

  # Verify message is still pending
  local pending_count_before
  pending_count_before=$(find "${QUEUE_BASE}/${TEST_AGENT}/pending" -name "msg-*.json" 2>/dev/null | wc -l) || pending_count_before=0

  if (( pending_count_before != 1 )); then
    test_fail "Expected 1 pending message before ACK, found $pending_count_before"
  fi
  test_pass "Message pending before ACK"

  # Acknowledge the message
  bash "${ROOT_DIR}/tools/agent-messenger.sh" ack --msg-id "$msg_id" > /dev/null || test_fail "Could not acknowledge message"
  test_pass "Message acknowledged successfully"

  # Verify message cleared from pending
  local pending_count_after
  pending_count_after=$(find "${QUEUE_BASE}/${TEST_AGENT}/pending" -name "msg-*.json" 2>/dev/null | wc -l) || pending_count_after=0

  if (( pending_count_after != 0 )); then
    test_fail "Expected 0 pending messages after ACK, found $pending_count_after"
  fi
  test_pass "Message cleared from pending directory"

  # Verify message exists in processed
  local processed_count
  processed_count=$(find "${QUEUE_BASE}/${TEST_AGENT}/processed" -name "msg-*.json" 2>/dev/null | wc -l) || processed_count=0

  if (( processed_count != 1 )); then
    test_fail "Expected 1 processed message, found $processed_count"
  fi
  test_pass "Message moved to processed directory"
}

###############################################################################
# Main Test Runner
###############################################################################

main() {
  echo "=========================================="
  echo "Wave 14: Protocol Smoke Tests"
  echo "=========================================="
  echo ""

  # Setup
  cleanup

  # Run scenarios
  scenario_1_send_and_queue || true
  scenario_2_ack_and_clear || true

  # Cleanup
  cleanup
  rm -f "${QUEUE_BASE}/test-msg-id.tmp"

  # Summary
  echo ""
  echo "=========================================="
  echo "Test Summary"
  echo "=========================================="
  echo "Passed: $TESTS_PASSED"
  echo "Failed: $TESTS_FAILED"
  echo ""

  if (( TESTS_FAILED == 0 )); then
    echo "All tests passed!"
    return 0
  else
    echo "Some tests failed."
    return 1
  fi
}

main "$@"
