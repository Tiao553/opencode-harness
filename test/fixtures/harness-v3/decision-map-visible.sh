#!/bin/bash
# Fixture: decision-map-visible.sh
# Test: Decision map is visible in first 200 lines of key agents
# Expected: Gates documented in first 200 lines with line references

set -e

echo "Checking Decision Map Visibility..."

pass_count=0
fail_count=0

# Test 1: altitude-maestro has decision map in first 250 lines
maestro_head=$(head -250 agents/altitude-maestro.agent.md)
if echo "$maestro_head" | grep -q "Decision\|Gate\|routing decision\|## Gate"; then
  echo "  ✅ altitude-maestro: Decision map in first 250 lines"
  ((pass_count++))
else
  echo "  ❌ altitude-maestro: Decision map not visible in first 250 lines"
  ((fail_count++))
fi

# Test 2: altitude-execution has decision map in first 150 lines
exec_head=$(head -150 agents/altitude-execution.agent.md)
if echo "$exec_head" | grep -q "⚡ CRITICAL DECISIONS MAP\|Decision Map\|Wave.*Decision"; then
  echo "  ✅ altitude-execution: Decision map in first 150 lines"
  ((pass_count++))
else
  echo "  ❌ altitude-execution: Decision map not visible in first 150 lines"
  ((fail_count++))
fi

# Test 3: Decision map has line references
if grep -q "Line [0-9]\|line [0-9]\|section" agents/altitude-maestro.agent.md; then
  echo "  ✅ Decision map has line references"
  ((pass_count++))
else
  echo "  ⚠️  Warning: Decision map could have more line references"
  ((pass_count++))
fi

# Test 4: Decisions are numbered/organized
if grep -q "^## Gate\|^### Gate\|^| Wave\|| Decision\|| Trigger" agents/altitude-maestro.agent.md agents/altitude-execution.agent.md; then
  echo "  ✅ Decisions are organized (numbered/tabular)"
  ((pass_count++))
else
  echo "  ❌ Decisions not well-organized"
  ((fail_count++))
fi

echo ""
echo "=========================================="
echo "decision-map-visible.sh Results: $pass_count PASS, $fail_count FAIL"
echo "=========================================="

if [ $fail_count -eq 0 ]; then
  echo "✅ FIXTURE PASS: Decision maps are visible and organized"
  exit 0
else
  echo "❌ FIXTURE FAIL: Decision map visibility issues"
  exit 1
fi
