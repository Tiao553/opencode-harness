#!/usr/bin/env bash
# W9 state and TODO verification
set -euo pipefail
ERRORS=0
pass() { echo "  PASS  $1"; }
fail() { echo "  FAIL  $1"; ERRORS=$((ERRORS+1)); }
echo "=== W9 State and Memory Integrity Check ==="
echo ""

CHANGE=".specs/changes/harness-skill-based-migration"

echo "[1] active-state.md points to this migration"
if grep -q "harness-skill-based-migration" .specs/memory/active-state.md 2>/dev/null; then
  pass "active-state.md correct"
else
  fail "active-state.md missing migration reference"
fi

echo "[2] Writer lease schema documented"
if grep -q "session_id" "$CHANGE/evidence/w9-validation/w9-protocols.md" 2>/dev/null && \
   grep -q "expiry_at" "$CHANGE/evidence/w9-validation/w9-protocols.md" 2>/dev/null; then
  pass "Writer lease schema present"
else
  fail "Writer lease schema missing"
fi

echo "[3] Memory governance namespace defined"
if grep -q "namespace" "$CHANGE/evidence/w9-validation/w9-protocols.md" 2>/dev/null; then
  pass "Memory namespace defined"
else
  fail "Memory namespace missing"
fi

echo "[4] Native TODO mapping documented"
if grep -q "BLOCO W" "$CHANGE/evidence/w9-validation/w9-protocols.md" 2>/dev/null; then
  pass "Native TODO mapping documented"
else
  fail "TODO mapping missing"
fi

echo "[5] Dual-write protocol references local-first"
if grep -q "synchronous, blocking" "$CHANGE/evidence/w9-validation/w9-protocols.md" 2>/dev/null; then
  pass "Local-first memory write confirmed"
else
  fail "Local-first not confirmed"
fi

echo ""
echo "================================"
if [ "$ERRORS" -eq 0 ]; then echo "RESULT: PASS — 0 errors"; exit 0
else echo "RESULT: FAIL — $ERRORS error(s)"; exit 1; fi
