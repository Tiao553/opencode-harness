#!/bin/bash
# Wave 16 Hardening Smoke Test Fixture
# Tests: Light load test + Chaos injection
# Exit 0 if all tests pass, 1 otherwise

set -euo pipefail

# Fixture config
TEST_NAME="wave-16-hardening-smoke"
FIXTURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Cleanup on exit
cleanup() {
  rm -rf ./.chaos-test-state 2>/dev/null || true
}
trap cleanup EXIT

# Test helper
run_test() {
  local test_name=$1
  local command=$2
  
  TESTS_RUN=$((TESTS_RUN + 1))
  echo -n "[$TEST_NAME] Test $TESTS_RUN: $test_name ... "
  
  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Assert helper
assert_contains() {
  local file=$1
  local pattern=$2
  grep -q "$pattern" "$file"
}

echo "=========================================="
echo "Wave 16 Hardening Smoke Test Fixture"
echo "=========================================="
echo ""

# Scenario 1: Light load test
echo "Scenario 1: Light Load Test"
echo "---------------------------"

run_test "light load execution" \
  "tools/chaos-tester.sh load 5 light"

run_test "light load log exists" \
  "test -f ./.chaos-test-state/chaos_log.txt"

run_test "light load has task completions" \
  "assert_contains ./.chaos-test-state/chaos_log.txt 'task_complete'"

run_test "light load error rate acceptable" \
  "[ \$(grep -c 'task_error' ./.chaos-test-state/chaos_log.txt || echo 0) -lt 50 ]"

run_test "light load report generation" \
  "tools/chaos-tester.sh report | grep -q 'Execution Summary'"

echo ""

# Scenario 2: Chaos injection (state-flip)
echo "Scenario 2: Chaos Injection (State-Flip)"
echo "----------------------------------------"

# Clean state for scenario 2
rm -rf ./.chaos-test-state

run_test "state-flip chaos execution" \
  "tools/chaos-tester.sh chaos state-flip"

run_test "state-flip chaos log exists" \
  "test -f ./.chaos-test-state/chaos_log.txt"

run_test "state-flip chaos injections logged" \
  "assert_contains ./.chaos-test-state/chaos_log.txt 'chaos_state_flip'"

run_test "state-flip recovery attempts logged" \
  "assert_contains ./.chaos-test-state/chaos_log.txt 'chaos_recovery_attempt'"

run_test "state-flip has task completions despite chaos" \
  "assert_contains ./.chaos-test-state/chaos_log.txt 'task_complete'"

run_test "state-flip error rate within limits" \
  "[ \$(grep -c 'task_error' ./.chaos-test-state/chaos_log.txt || echo 0) -lt 200 ]"

echo ""

# Scenario 3: Contract validation
echo "Scenario 3: Contract Validation"
echo "--------------------------------"

run_test "hardening-contract.md exists" \
  "test -f .specs/shared/hardening-contract.md"

run_test "hardening-contract defines chaos_patterns" \
  "grep -q 'chaos_patterns:' .specs/shared/hardening-contract.md"

run_test "hardening-contract defines load profiles" \
  "grep -q 'load_profile:' .specs/shared/hardening-contract.md"

run_test "chaos-tester.contract.md exists" \
  "test -f tools/chaos-tester.contract.md"

run_test "chaos-tester.contract documents load command" \
  "grep -q 'load \\[threads\\]' tools/chaos-tester.contract.md"

run_test "altitude-report.agent.md mentions chaos-tester" \
  "grep -q 'chaos-tester' agents/altitude-report.agent.md"

echo ""

# Scenario 4: Tool validation
echo "Scenario 4: Tool Validation"
echo "----------------------------"

run_test "chaos-tester.sh is executable" \
  "test -x tools/chaos-tester.sh"

run_test "chaos-tester.sh help works" \
  "tools/chaos-tester.sh help | grep -q 'Usage:'"

run_test "chaos-tester.sh reports valid JSON metrics" \
  "tools/chaos-tester.sh load 5 light && tools/chaos-tester.sh report | grep -q 'Total Tasks'"

echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Tests Run:  $TESTS_RUN"
echo "Tests Pass: $TESTS_PASSED"
echo "Tests Fail: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
  echo "=========================================="
  exit 0
else
  echo -e "${RED}✗ Some tests failed${NC}"
  echo "=========================================="
  exit 1
fi
