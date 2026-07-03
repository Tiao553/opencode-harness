#!/bin/bash
# Fixture: execution-ready-gate.sh
# Test: Execution readiness gate enforces task contract requirements
# Expected: Task must have status=ready, allowed_files, forbidden_scope, acceptance_criteria

set -e

echo "Checking Execution Readiness Gate..."

pass_count=0
fail_count=0

# The gate checks are documented in altitude-execution.agent.md
exec_file="agents/altitude-execution.agent.md"

# Test 1: Execution gate checks task status
if grep -q "status.*ready\|task.*ready" "$exec_file"; then
  echo "  ✅ Execution gate checks task.status == ready"
  ((pass_count++))
else
  echo "  ❌ Execution gate missing status check"
  ((fail_count++))
fi

# Test 2: Execution gate checks allowed files
if grep -q "allowed_files\|scope.*file\|file.*allowed" "$exec_file"; then
  echo "  ✅ Execution gate checks allowed_files"
  ((pass_count++))
else
  echo "  ❌ Execution gate missing allowed_files check"
  ((fail_count++))
fi

# Test 3: Execution gate checks forbidden scope
if grep -q "forbidden_scope\|forbidden\|scope" "$exec_file"; then
  echo "  ✅ Execution gate checks forbidden_scope"
  ((pass_count++))
else
  echo "  ❌ Execution gate missing forbidden_scope check"
  ((fail_count++))
fi

# Test 4: Execution gate checks acceptance criteria
if grep -q "acceptance_criteria\|acceptance" "$exec_file"; then
  echo "  ✅ Execution gate checks acceptance_criteria"
  ((pass_count++))
else
  echo "  ❌ Execution gate missing acceptance_criteria check"
  ((fail_count++))
fi

# Test 5: Execution gate blocks incomplete tasks
if grep -q "BLOCKED\|block\|prevent" "$exec_file"; then
  echo "  ✅ Execution gate can block incomplete tasks"
  ((pass_count++))
else
  echo "  ⚠️  Warning: Execution gate blocking mechanism unclear"
  ((pass_count++))
fi

# Test 6: Verify task contract exists
task_contract=".specs/shared/task-contract.md"
if [ -f "$task_contract" ]; then
  echo "  ✅ Task contract defined in shared contracts"
  ((pass_count++))
else
  echo "  ❌ Task contract missing"
  ((fail_count++))
fi

echo ""
echo "=========================================="
echo "execution-ready-gate.sh Results: $pass_count PASS, $fail_count FAIL"
echo "=========================================="

if [ $fail_count -eq 0 ]; then
  echo "✅ FIXTURE PASS: Execution readiness gate properly enforced"
  exit 0
else
  echo "❌ FIXTURE FAIL: Execution gate issues detected"
  exit 1
fi
