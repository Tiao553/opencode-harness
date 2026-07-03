#!/bin/bash
# Fixture: maestro-routing.sh
# Test: Altitude-maestro routes requests to correct phase agent
# Expected: Routes "new" → intent, "resume" → phase agent, "multi-wave" → orchestration

set -e

agent_file="agents/altitude-maestro.agent.md"

if [ ! -f "$agent_file" ]; then
  echo "❌ FAIL: agents/altitude-maestro.agent.md not found"
  exit 1
fi

agent_content=$(cat "$agent_file")
pass_count=0
fail_count=0

# Test 1: New strategic work routes to intent
if echo "$agent_content" | grep -q "new durable architecture.*altitude-intent\|new.*intent"; then
  echo "✅ PASS: new architecture → altitude-intent"
  ((pass_count++))
else
  echo "❌ FAIL: new architecture routing missing"
  ((fail_count++))
fi

# Test 2: Resume existing change routes to phase agent
if echo "$agent_content" | grep -q "existing change.*phase\|resume.*state.md\|active.*phase"; then
  echo "✅ PASS: resume existing → phase agent (state-based routing)"
  ((pass_count++))
else
  echo "❌ FAIL: resume routing missing"
  ((fail_count++))
fi

# Test 3: Tactical work routes to data engineer
if echo "$agent_content" | grep -q "tactical.*Data Engineer\|data.*engineer.*coordinator"; then
  echo "✅ PASS: tactical → Data Engineer coordinator"
  ((pass_count++))
else
  echo "❌ FAIL: tactical routing missing"
  ((fail_count++))
fi

# Test 4: Multi-wave routes to orchestration
if echo "$agent_content" | grep -q "multi-wave\|orchestration\|wave scheduler"; then
  echo "✅ PASS: multi-wave → orchestration section"
  ((pass_count++))
else
  echo "❌ FAIL: multi-wave routing missing"
  ((fail_count++))
fi

# Test 5: Decision map present
if echo "$agent_content" | grep -q "CRITICAL DECISIONS MAP\|## Gate\|routing decision\|Mission"; then
  echo "✅ PASS: Decision map visible in agent"
  ((pass_count++))
else
  echo "❌ FAIL: Decision map missing"
  ((fail_count++))
fi

echo ""
echo "=========================================="
echo "maestro-routing.sh Results: $pass_count PASS, $fail_count FAIL"
echo "=========================================="

if [ $fail_count -eq 0 ]; then
  echo "✅ FIXTURE PASS: Altitude-maestro routing verified"
  exit 0
else
  echo "❌ FIXTURE FAIL: Routing issues detected"
  exit 1
fi
