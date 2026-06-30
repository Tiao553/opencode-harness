#!/bin/bash
#
# wave-7-ralph-loop-smoke.fixture.md — Smoke test for verify_step tool
# Scenarios: Happy path (3 steps), Decision fork (with branch)
#

set -euo pipefail

FIXTURE_NAME="wave-7-ralph-loop-smoke"
TOOL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/tools/verify-step.sh"
TEST_TMPDIR="/tmp/wave7_smoke_test_$$"

# Ensure tool exists
if [[ ! -x "$TOOL_PATH" ]]; then
    echo "ERROR: $TOOL_PATH not found or not executable" >&2
    exit 1
fi

# Create test directory
mkdir -p "$TEST_TMPDIR"
cd "$TEST_TMPDIR" || exit 1

# Setup: Create traces directory structure
mkdir -p ".specs/changes/waves-7-17-implementation/traces"

echo "=== Smoke Test: $FIXTURE_NAME ==="
echo ""

# ============================================================================
# Scenario 1: Happy Path (3 steps, no forks)
# ============================================================================
echo "## Scenario 1: Happy Path (3 steps, no decision forks)"
echo ""

SESSION_1="sess-$(date -u +%Y-%m-%dT%H:%M:%SZ)-smoke-test-happy"

# Step 1: Load configuration
echo "Step 1: Load configuration"
DEC_1=$("$TOOL_PATH" start --session-id "$SESSION_1" --step "Load configuration file" 2>&1)
echo "  → Decision ID: $DEC_1"
if [[ ! "$DEC_1" =~ ^dec- ]]; then
    echo "ERROR: Invalid decision ID format" >&2
    exit 1
fi

"$TOOL_PATH" check --session-id "$SESSION_1" --verdict PASS 2>&1 > /dev/null
echo "  ✓ Recorded PASS verdict"

# Step 2: Validate schema
echo "Step 2: Validate schema"
DEC_2=$("$TOOL_PATH" start --session-id "$SESSION_1" --step "Validate configuration schema" 2>&1)
echo "  → Decision ID: $DEC_2"
"$TOOL_PATH" check --session-id "$SESSION_1" --verdict PASS 2>&1 > /dev/null
echo "  ✓ Recorded PASS verdict"

# Step 3: Initialize system
echo "Step 3: Initialize system"
DEC_3=$("$TOOL_PATH" start --session-id "$SESSION_1" --step "Initialize system with config" 2>&1)
echo "  → Decision ID: $DEC_3"
"$TOOL_PATH" check --session-id "$SESSION_1" --verdict PASS 2>&1 > /dev/null
echo "  ✓ Recorded PASS verdict"

# Dump and validate ledger
echo ""
echo "Dumping session ledger for Scenario 1:"
LEDGER_1=$("$TOOL_PATH" ledger --session-id "$SESSION_1" --format yaml 2>&1)
echo "$LEDGER_1" | head -10
echo "  ..."
echo ""

# Verify ledger contains expected decision IDs
if echo "$LEDGER_1" | grep -q "decision_id:"; then
    echo "✓ Ledger contains decision IDs"
else
    echo "ERROR: Ledger missing decision_id field" >&2
    exit 1
fi

# Replay validation
echo "Replaying Scenario 1 trace:"
REPLAY_1=$("$TOOL_PATH" replay --session-id "$SESSION_1" 2>&1)
echo "  $REPLAY_1"
if [[ "$REPLAY_1" == "REPLAY_OK"* ]]; then
    echo "✓ Replay successful"
else
    echo "ERROR: Replay failed" >&2
    exit 1
fi

echo ""
echo "✅ Scenario 1 PASSED"
echo ""

# ============================================================================
# Scenario 2: Decision Fork (with multiple paths)
# ============================================================================
echo "## Scenario 2: Decision Fork (user chooses between paths)"
echo ""

SESSION_2="sess-$(date -u +%Y-%m-%dT%H:%M:%SZ)-smoke-test-fork"

# Step 1: Assess readiness
echo "Step 1: Assess readiness"
DEC_4=$("$TOOL_PATH" start --session-id "$SESSION_2" --step "Assess task readiness" 2>&1)
echo "  → Decision ID: $DEC_4"
"$TOOL_PATH" check --session-id "$SESSION_2" --verdict PASS 2>&1 > /dev/null
echo "  ✓ Recorded PASS verdict"

# Step 2: Fork point (user chooses path_a: proceed)
echo "Step 2: Decision fork - user chooses 'proceed'"
DEC_5=$("$TOOL_PATH" start --session-id "$SESSION_2" --step "Choose execution path" 2>&1)
echo "  → Decision ID: $DEC_5"
echo "  Options: path_a (proceed), path_b (loop_back)"
echo "  User chose: path_a"
"$TOOL_PATH" check --session-id "$SESSION_2" --verdict PASS --fork-decision "path_a" 2>&1 > /dev/null
echo "  ✓ Recorded PASS verdict with fork decision: path_a"

# Step 3: Continue on chosen path
echo "Step 3: Execute on chosen path"
DEC_6=$("$TOOL_PATH" start --session-id "$SESSION_2" --step "Execute task on selected path" 2>&1)
echo "  → Decision ID: $DEC_6"
"$TOOL_PATH" check --session-id "$SESSION_2" --verdict PASS 2>&1 > /dev/null
echo "  ✓ Recorded PASS verdict"

# Dump ledger
echo ""
echo "Dumping session ledger for Scenario 2:"
LEDGER_2=$("$TOOL_PATH" ledger --session-id "$SESSION_2" --format yaml 2>&1)
echo "$LEDGER_2" | head -12
echo "  ..."
echo ""

# Verify fork_decision is recorded
if echo "$LEDGER_2" | grep -q "fork_decision:"; then
    echo "✓ Ledger contains fork_decision field"
else
    echo "ERROR: Ledger missing fork_decision field" >&2
    exit 1
fi

# Replay validation
echo "Replaying Scenario 2 trace:"
REPLAY_2=$("$TOOL_PATH" replay --session-id "$SESSION_2" --verbose 2>&1) || true
echo "$REPLAY_2" | head -5
echo "  ..."
FULL_REPLAY=$("$TOOL_PATH" replay --session-id "$SESSION_2" 2>&1) || true
if [[ "$FULL_REPLAY" == "REPLAY_OK"* ]]; then
    echo "✓ Replay successful"
else
    echo "ERROR: Replay failed" >&2
    exit 1
fi

echo ""
echo "✅ Scenario 2 PASSED"
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "=== Test Summary ==="
echo ""
echo "✅ Scenario 1 (Happy Path): PASSED"
echo "   - 3 decisions recorded"
echo "   - Ledger validated"
echo "   - Replay successful"
echo ""
echo "✅ Scenario 2 (Decision Fork): PASSED"
echo "   - 3 decisions recorded with fork"
echo "   - Fork decision captured"
echo "   - Replay successful"
echo ""
echo "All smoke tests PASSED"
echo ""

# Cleanup
cd /
rm -rf "$TEST_TMPDIR"

exit 0
