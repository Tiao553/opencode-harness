#!/bin/bash
# Fixture: lessons-learned-loaded.sh
# Test: Lessons learned file is loaded by altitude-memory during initialization
# Expected: altitude-memory.agent.md loads .specs/memory/WAVES-7-17-LESSONS-LEARNED.md

set -e

echo "Checking Lessons Learned Loading..."

lessons_file=".specs/memory/WAVES-7-17-LESSONS-LEARNED.md"
memory_agent="agents/altitude-memory.agent.md"

pass_count=0
fail_count=0

# Test 1: Lessons file exists
if [ -f "$lessons_file" ]; then
  line_count=$(wc -l < "$lessons_file")
  echo "  ✅ Lessons file exists ($line_count lines)"
  ((pass_count++))
else
  echo "  ❌ Lessons file missing: $lessons_file"
  ((fail_count++))
fi

# Test 2: Memory agent loads lessons
if grep -q "Load.*Lessons\|WAVES-7-17-LESSONS\|lessons learned" "$memory_agent"; then
  echo "  ✅ altitude-memory.agent.md loads lessons"
  ((pass_count++))
else
  echo "  ❌ altitude-memory.agent.md doesn't load lessons"
  ((fail_count++))
fi

# Test 3: Lessons file has structured sections
if grep -q "## \|### " "$lessons_file"; then
  echo "  ✅ Lessons file has structured sections"
  ((pass_count++))
else
  echo "  ❌ Lessons file structure invalid"
  ((fail_count++))
fi

# Test 4: Lessons contains W18-23 updates
if grep -q "WAVES 18-23\|W18-23\|W24" "$lessons_file"; then
  echo "  ✅ Lessons include W18-23 updates"
  ((pass_count++))
else
  echo "  ❌ W18-23 lessons missing"
  ((fail_count++))
fi

echo ""
echo "=========================================="
echo "lessons-learned-loaded.sh Results: $pass_count PASS, $fail_count FAIL"
echo "=========================================="

if [ $fail_count -eq 0 ]; then
  echo "✅ FIXTURE PASS: Lessons learned properly loaded"
  exit 0
else
  echo "❌ FIXTURE FAIL: Lessons loading issues"
  exit 1
fi
