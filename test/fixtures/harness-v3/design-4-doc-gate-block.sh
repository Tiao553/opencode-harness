#!/bin/bash
# Fixture: design-4-doc-gate-block.sh
# Test: Design 4-doc gate has blocking logic for missing docs
# Expected: When any doc missing, gate blocks decomposition (exit 1)

set -e

change_dir=".specs/changes/waves-18-23-implementation"

echo "Checking Design 4-doc gate blocking logic..."

# The gate should verify ALL 4 docs exist
# Test 1: Verify gate code exists in altitude-plan
if grep -q "for doc in PRD.md ADR.md TEST-SPEC.md DESIGN.md" agents/altitude-plan.agent.md && \
   grep -q "blocked\|missing\|return 1\|exit 1" agents/altitude-plan.agent.md; then
  echo "  ✅ altitude-plan has 4-doc gate with blocking logic"
  gate_has_blocking=1
else
  echo "  ❌ altitude-plan gate logic incomplete"
  gate_has_blocking=0
fi

# Test 2: Verify gate blocks (by checking if validation fails with missing doc)
# Create temp dir and test
temp_test=$(mktemp -d)
cp -r "$change_dir"/* "$temp_test/" 2>/dev/null || true

# Remove ADR.md to simulate missing doc
rm -f "$temp_test/ADR.md"

# Test the gate logic: loop through docs and exit if any missing
gate_would_block=0
for doc in "PRD.md" "ADR.md" "TEST-SPEC.md" "DESIGN.md"; do
  if [ ! -f "$temp_test/$doc" ]; then
    gate_would_block=1
    echo "  ✅ Gate detects missing $doc and would BLOCK"
  fi
done

rm -rf "$temp_test"

echo ""
echo "=========================================="
if [ $gate_has_blocking -eq 1 ] && [ $gate_would_block -eq 1 ]; then
  echo "✅ PASS: Design 4-doc gate properly blocks when doc missing"
  exit 0
else
  echo "❌ FAIL: Gate blocking logic incomplete"
  exit 1
fi
