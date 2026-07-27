#!/usr/bin/env bash
# W4 structural test for AGENTS.next.md
# T-057 — exits 0 if PASS, exits 1 if FAIL
set -euo pipefail

KERNEL=".specs/changes/harness-skill-based-migration/staged/AGENTS.next.md"
ERRORS=0

pass() { echo "  PASS  $1"; }
fail() { echo "  FAIL  $1"; ERRORS=$((ERRORS+1)); }

echo "=== W4 Structural Test ==="
echo ""

# 1. Kernel exists and is under 350 lines
echo "[1] Kernel size"
if [ -f "$KERNEL" ]; then
  LINES=$(wc -l < "$KERNEL")
  if [ "$LINES" -le 350 ]; then
    pass "Kernel exists and has $LINES lines (≤ 350)"
  else
    fail "Kernel has $LINES lines — exceeds 350-line budget"
  fi
else
  fail "Kernel file missing: $KERNEL"
fi

# 2. No custom primary agents in agents/ (only altitude-maestro is allowed during W4-W5)
echo "[2] Custom primary count (file-backed)"
PRIMARY_COUNT=$(grep -rl "^mode: primary" agents/ 2>/dev/null | wc -l || echo 0)
if [ "$PRIMARY_COUNT" -le 1 ]; then
  pass "Custom file-backed primaries: $PRIMARY_COUNT (altitude-maestro only, acceptable until W6)"
else
  fail "Custom file-backed primaries: $PRIMARY_COUNT — unexpected"
fi

# 3. Kernel references rules/ files, not inline logic
echo "[3] Rules referenced, not inlined"
if grep -q "rules/START.md" "$KERNEL" && grep -q "rules/altitude-start.md" "$KERNEL" && grep -q "rules/agentspec-start.md" "$KERNEL"; then
  pass "Kernel references rules/START.md, altitude-start.md, agentspec-start.md"
else
  fail "Kernel missing required rules/ references"
fi

# 4. Skill trigger matrix present
echo "[4] Skill trigger matrix"
if grep -q "task-spec" "$KERNEL" && grep -q "data-engineering" "$KERNEL" && grep -q "dev-faithfulness-guard" "$KERNEL"; then
  pass "Skill trigger matrix present with at least 3 skills"
else
  fail "Skill trigger matrix incomplete"
fi

# 5. Non-negotiable invariants stated
echo "[5] Non-negotiable invariants"
if grep -qi "no custom agent is primary" "$KERNEL" && grep -qi "no leaf" "$KERNEL" && grep -qi "MCP output is data" "$KERNEL"; then
  pass "Non-negotiable invariants stated"
else
  fail "One or more non-negotiable invariants missing"
fi

# 6. Kernel does not inline behavioral logic from rules
echo "[6] No inlined phase logic"
if grep -qE "### Entry gate|### Exit gate|## Phase sequence" "$KERNEL" 2>/dev/null; then
  fail "Phase execution logic found in kernel — move to rules/altitude-phases.md"
else
  pass "No phase execution logic inlined in kernel"
fi

# 7. Budget check across all rule files
echo "[7] Rule files within 150-line budget"
BUDGET_FAIL=0
for f in rules/*.md; do
  RLINES=$(wc -l < "$f")
  if [ "$RLINES" -gt 150 ]; then
    fail "$(basename "$f") has $RLINES lines — exceeds 150-line budget"
    BUDGET_FAIL=$((BUDGET_FAIL+1))
  fi
done
if [ "$BUDGET_FAIL" -eq 0 ]; then
  pass "All rule files are within 150 lines"
fi

echo ""
echo "================================"
if [ "$ERRORS" -eq 0 ]; then
  echo "RESULT: PASS — 0 errors"
  exit 0
else
  echo "RESULT: FAIL — $ERRORS error(s)"
  exit 1
fi
