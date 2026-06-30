#!/bin/bash
# Wave 10 Metrics Collection — Smoke Test Fixture
# Tests: metrics-collector.sh collect and report commands

set -euo pipefail

PROJECT_ROOT="/home/ubuntu/.config/opencode"
SCRIPT_DIR="$PROJECT_ROOT/tools"
METRICS_DIR="$PROJECT_ROOT/.specs/changes/waves-7-17-implementation/metrics"
TRACES_DIR="$PROJECT_ROOT/.specs/changes/waves-7-17-implementation/traces"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Wave 10: Performance Metrics Collection — Smoke Tests     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verify prerequisites
echo "[Setup] Verifying prerequisites..."
test -f "$SCRIPT_DIR/metrics-collector.sh" || { echo "ERROR: metrics-collector.sh not found"; exit 1; }
test -f "$PROJECT_ROOT/.specs/shared/metrics-contract.md" || { echo "ERROR: metrics-contract.md not found"; exit 1; }
test -f "$PROJECT_ROOT/tools/metrics-collector.contract.md" || { echo "ERROR: metrics-collector.contract.md not found"; exit 1; }
test -d "$TRACES_DIR" || { echo "ERROR: traces directory not found"; exit 1; }
test -f "$TRACES_DIR/test-w7.yaml" || { echo "ERROR: test-w7.yaml not found"; exit 1; }
echo "✓ All prerequisites satisfied"
echo ""

# Clean up previous test runs
echo "[Setup] Cleaning up previous test runs..."
rm -rf "$METRICS_DIR"
mkdir -p "$METRICS_DIR"
echo "✓ Metrics directory cleaned"
echo ""

# Scenario 1: Collect Metrics from Trace
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Scenario 1: Collect Metrics from Trace                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "[Scenario 1.1] Collect metrics from test-w7 trace..."
if "$SCRIPT_DIR/metrics-collector.sh" collect --trace-id test-w7 > /tmp/w10-collect-1.log 2>&1; then
    echo "✓ Collection succeeded"
else
    echo "✗ Collection failed"
    cat /tmp/w10-collect-1.log
    exit 1
fi
echo ""

echo "[Scenario 1.2] Verify metrics file was created..."
if ls "$METRICS_DIR"/sess-*.yaml > /dev/null 2>&1; then
    METRICS_FILE=$(ls "$METRICS_DIR"/sess-*.yaml | head -1)
    echo "✓ Metrics file created: $(basename "$METRICS_FILE")"
else
    echo "✗ Metrics file not found"
    exit 1
fi
echo ""

echo "[Scenario 1.3] Verify metrics file contains expected fields..."
if grep -q "metrics_entry:" "$METRICS_FILE" && \
   grep -q "session_id:" "$METRICS_FILE" && \
   grep -q "execution_metrics:" "$METRICS_FILE" && \
   grep -q "token_metrics:" "$METRICS_FILE" && \
   grep -q "decision_latencies:" "$METRICS_FILE" && \
   grep -q "quality_metrics:" "$METRICS_FILE"; then
    echo "✓ All expected fields found in metrics file"
else
    echo "✗ Missing expected fields in metrics file"
    cat "$METRICS_FILE"
    exit 1
fi
echo ""

echo "[Scenario 1.4] Verify ledger was appended..."
LEDGER="$PROJECT_ROOT/.specs/changes/waves-7-17-implementation/03-metrics-ledger.md"
if grep -q "session_id:" "$LEDGER" 2>/dev/null; then
    echo "✓ Ledger appended successfully"
else
    echo "✗ Ledger not found or not updated"
    exit 1
fi
echo ""

echo "[Scenario 1.5] Collect metrics from test-w7c trace (all traces)..."
if "$SCRIPT_DIR/metrics-collector.sh" collect > /tmp/w10-collect-all.log 2>&1; then
    echo "✓ Batch collection succeeded"
    COLLECT_COUNT=$(grep -c "Collected metrics" /tmp/w10-collect-all.log || echo 0)
    echo "  → Collected from $COLLECT_COUNT traces"
else
    echo "✗ Batch collection failed"
    cat /tmp/w10-collect-all.log
    exit 1
fi
echo ""

# Scenario 2: Generate Reports
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Scenario 2: Generate Metrics Reports                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "[Scenario 2.1] Generate summary report..."
if REPORT_OUTPUT=$("$SCRIPT_DIR/metrics-collector.sh" report 2>&1); then
    echo "✓ Summary report generated"
    echo "  → Report contains:" $(echo "$REPORT_OUTPUT" | wc -l) "lines"
else
    echo "✗ Summary report generation failed"
    echo "$REPORT_OUTPUT"
    exit 1
fi
echo ""

echo "[Scenario 2.2] Verify summary report has execution_time..."
if echo "$REPORT_OUTPUT" | grep -q "execution_time"; then
    echo "✓ Report contains execution_time metric"
else
    echo "✗ Report missing execution_time metric"
    echo "$REPORT_OUTPUT"
    exit 1
fi
echo ""

echo "[Scenario 2.3] Verify summary report has metrics table..."
if echo "$REPORT_OUTPUT" | grep -q "Session" && echo "$REPORT_OUTPUT" | grep -q "Decisions"; then
    echo "✓ Report contains metrics table"
else
    echo "✗ Report missing metrics table"
    echo "$REPORT_OUTPUT"
    exit 1
fi
echo ""

echo "[Scenario 2.4] Generate session-specific report..."
SESSION_ID=$(ls "$METRICS_DIR"/sess-*.yaml | head -1 | xargs basename -s .yaml | sed 's/^sess-//')
SESSION_FULL="sess-$SESSION_ID"
if SESSION_REPORT=$("$SCRIPT_DIR/metrics-collector.sh" report "$SESSION_FULL" 2>&1); then
    echo "✓ Session-specific report generated"
    echo "  → Session ID: $SESSION_FULL"
    echo "  → Report contains:" $(echo "$SESSION_REPORT" | wc -l) "lines"
else
    echo "✗ Session report generation failed"
    echo "$SESSION_REPORT"
    exit 1
fi
echo ""

echo "[Scenario 2.5] Verify session report has decision quality..."
if echo "$SESSION_REPORT" | grep -q "Pass Rate"; then
    echo "✓ Report contains pass rate"
else
    echo "✗ Report missing pass rate"
    echo "$SESSION_REPORT"
    exit 1
fi
echo ""

echo "[Scenario 2.6] Verify session report has latency stats..."
if echo "$SESSION_REPORT" | grep -q "Minimum" && echo "$SESSION_REPORT" | grep -q "Maximum"; then
    echo "✓ Report contains latency statistics"
else
    echo "✗ Report missing latency statistics"
    echo "$SESSION_REPORT"
    exit 1
fi
echo ""

# Final validation
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Final Validation                                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "[Validation] Verifying all deliverables..."
DELIVERABLES=(
    "$PROJECT_ROOT/.specs/shared/metrics-contract.md"
    "$PROJECT_ROOT/tools/metrics-collector.sh"
    "$PROJECT_ROOT/tools/metrics-collector.contract.md"
    "$METRICS_DIR"
    "$LEDGER"
)

ALL_PRESENT=true
for deliverable in "${DELIVERABLES[@]}"; do
    if [[ -e "$deliverable" ]]; then
        echo "✓ $(basename "$deliverable")"
    else
        echo "✗ $(basename "$deliverable") - NOT FOUND"
        ALL_PRESENT=false
    fi
done
echo ""

if [[ "$ALL_PRESENT" == true ]]; then
    echo "╔════════════════════════════════════════════════════════════╗"
    printf "║  ${GREEN}✓ ALL SMOKE TESTS PASSED${NC}                              ║\n"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Summary:"
    echo "  ✓ Metrics collected from traces"
    echo "  ✓ Metrics files created"
    echo "  ✓ Ledger updated"
    echo "  ✓ Summary report generated"
    echo "  ✓ Session reports generated"
    echo "  ✓ All expected fields present"
    echo ""
    exit 0
else
    echo "╔════════════════════════════════════════════════════════════╗"
    printf "║  ${RED}✗ SOME SMOKE TESTS FAILED${NC}                           ║\n"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi
