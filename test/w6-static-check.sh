#!/usr/bin/env bash
# W6 static check — leaf permission enforcement
# T-087 — exits 0 if PASS, exits 1 if FAIL
set -euo pipefail

ERRORS=0
pass() { echo "  PASS  $1"; }
fail() { echo "  FAIL  $1"; ERRORS=$((ERRORS+1)); }

echo "=== W6 Static Check: Leaf Permission Enforcement ==="
echo ""

# 1. No non-primary agent has task: allow
echo "[1] No non-primary agent has task: allow"
VIOLATIONS=$(node -e "
const fs=require('fs'),path=require('path'),dir='agents';
const v=fs.readdirSync(dir).filter(f=>f.endsWith('.agent.md')).filter(f=>{
  const s=fs.readFileSync(path.join(dir,f),'utf8');
  return !s.includes('mode: primary') && s.includes('task: allow');
});
process.stdout.write(v.join('\n'));
" 2>/dev/null || true)
if [ -z "$VIOLATIONS" ]; then
  pass "Zero non-primary agents have task: allow"
else
  fail "Agents still have task: allow:"
  echo "$VIOLATIONS" | sed 's/^/    /'
fi

# 2. All 73 non-primary agents have task: deny
echo "[2] All 73 non-primary agents have task: deny"
DENY_COUNT=$(node -e "
const fs=require('fs'),path=require('path'),dir='agents';
const n=fs.readdirSync(dir).filter(f=>f.endsWith('.agent.md')).filter(f=>{
  const s=fs.readFileSync(path.join(dir,f),'utf8');
  return !s.includes('mode: primary') && s.includes('task: deny');
}).length;
process.stdout.write(String(n));
" 2>/dev/null)
if [ "$DENY_COUNT" -ge 73 ]; then
  pass "$DENY_COUNT non-primary agents have task: deny"
else
  fail "Only $DENY_COUNT agents have task: deny (expected ≥73)"
fi

# 3. No non-primary agent has todowrite: allow
echo "[3] No non-primary agent has todowrite: allow"
TWRITE_VIOLATIONS=$(node -e "
const fs=require('fs'),path=require('path'),dir='agents';
const v=fs.readdirSync(dir).filter(f=>f.endsWith('.agent.md')).filter(f=>{
  const s=fs.readFileSync(path.join(dir,f),'utf8');
  return !s.includes('mode: primary') && s.includes('todowrite: allow');
});
process.stdout.write(v.join('\n'));
" 2>/dev/null || true)
if [ -z "$TWRITE_VIOLATIONS" ]; then
  pass "Zero non-primary agents have todowrite: allow"
else
  fail "Agents with todowrite: allow: $TWRITE_VIOLATIONS"
fi

# 4. altitude-maestro is the only file-backed primary
echo "[4] altitude-maestro is the only file-backed primary"
PRIMARY_FILES=$(grep -rl "^mode: primary" agents/ 2>/dev/null || true)
PRIMARY_COUNT=$(echo "$PRIMARY_FILES" | grep -c "." 2>/dev/null || echo 0)
if [ "$PRIMARY_COUNT" -eq 1 ] && echo "$PRIMARY_FILES" | grep -q "altitude-maestro"; then
  pass "altitude-maestro is the only file-backed primary"
else
  fail "Unexpected primaries: $PRIMARY_FILES"
fi

# 5. Dev agent files have FROZEN notice
echo "[5] Dev agent files have FROZEN notice"
DEV_FROZEN=$(grep -rl "FROZEN (W5)" agents/dev.*.agent.md 2>/dev/null | wc -l || echo 0)
if [ "$DEV_FROZEN" -ge 6 ]; then
  pass "$DEV_FROZEN dev agents have FROZEN notice"
else
  fail "Only $DEV_FROZEN dev agents have FROZEN notice (expected ≥6)"
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
