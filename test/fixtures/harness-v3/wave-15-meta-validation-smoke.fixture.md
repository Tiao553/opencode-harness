#!/bin/bash
# wave-15-meta-validation-smoke.fixture.md — Smoke test for junta auditor
# Scenario 1: Audit one junta (Ralph Loop validator from W7)
# Scenario 2: Audit all juntas and detect bias patterns

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TOOLS_DIR="${PROJECT_ROOT}/tools"

echo "=== Wave 15: Meta-Validation Junta Audit Smoke Test ==="
echo ""

# ============================================================================
# Scenario 1: Audit a single junta (e.g., Ralph Loop validator from W7)
# ============================================================================
echo "Scenario 1: Audit single junta (ralph-loop)"
echo "---------------------------------------------"

audit_output=$("$TOOLS_DIR/junta-auditor.sh" audit ralph-loop 2>&1 || echo "AUDIT_FAILED")

if echo "$audit_output" | grep -q "quality_status"; then
    echo "✓ Scenario 1 PASSED: Single junta audit produced JSON output"
    
    # Verify JSON structure
    if echo "$audit_output" | grep -q "overall_quality_score"; then
        echo "✓ JSON contains quality_score field"
    else
        echo "✗ JSON missing quality_score field"
        exit 1
    fi
    
    if echo "$audit_output" | grep -q "bias_detection"; then
        echo "✓ JSON contains bias_detection field"
    else
        echo "✗ JSON missing bias_detection field"
        exit 1
    fi
else
    echo "✗ Scenario 1 FAILED: No quality_status in output"
    exit 1
fi

echo ""

# ============================================================================
# Scenario 2: Audit all juntas and check for bias patterns
# ============================================================================
echo "Scenario 2: Audit all juntas and detect biases"
echo "-----------------------------------------------"

# Run audit-all
audit_all_output=$("$TOOLS_DIR/junta-auditor.sh" audit-all 2>&1 || echo "AUDIT_ALL_FAILED")

if echo "$audit_all_output" | grep -q "Audit Summary"; then
    echo "✓ Scenario 2a PASSED: audit-all produced summary"
    
    # Check that summary has numbers
    if echo "$audit_all_output" | grep -q "Total juntas:"; then
        echo "✓ Summary contains junta count"
    else
        echo "✗ Summary missing junta count"
        exit 1
    fi
else
    echo "✗ Scenario 2a FAILED: No audit summary"
    exit 1
fi

# Run bias-report
bias_report_output=$("$TOOLS_DIR/junta-auditor.sh" bias-report 2>&1 || echo "BIAS_REPORT_FAILED")

if echo "$bias_report_output" | grep -q "Overall Bias Statistics"; then
    echo "✓ Scenario 2b PASSED: bias-report produced summary"
    
    # Check for bias counts
    if echo "$bias_report_output" | grep -q "Total Critical Biases"; then
        echo "✓ Bias report contains critical count"
    else
        echo "✗ Bias report missing critical count"
        exit 1
    fi
else
    echo "✗ Scenario 2b FAILED: No bias report"
    exit 1
fi

echo ""

# ============================================================================
# Scenario 3: List audits
# ============================================================================
echo "Scenario 3: List audit files"
echo "-----------------------------"

list_output=$("$TOOLS_DIR/junta-auditor.sh" list 2>&1 || echo "LIST_FAILED")

if echo "$list_output" | grep -q "Available audits"; then
    echo "✓ Scenario 3 PASSED: list command produced output"
else
    echo "✗ Scenario 3 FAILED: No audit files listed"
    exit 1
fi

echo ""

# ============================================================================
# Summary
# ============================================================================
echo "=== Test Results ==="
echo "✓ Scenario 1: Single junta audit — PASSED"
echo "✓ Scenario 2: All juntas audit + bias report — PASSED"
echo "✓ Scenario 3: List audits — PASSED"
echo ""
echo "All smoke tests PASSED"
exit 0
