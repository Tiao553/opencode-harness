#!/usr/bin/env bash
# W7 compatibility test — AgentSpec commands
# T-096 — exits 0 if PASS
set -euo pipefail
ERRORS=0
pass() { echo "  PASS  $1"; }
fail() { echo "  FAIL  $1"; ERRORS=$((ERRORS+1)); }
echo "=== W7 AgentSpec Command Compatibility ==="
echo ""

# 1. All 8 workflow commands exist
echo "[1] All 8 /workflow:* commands exist"
for cmd in brainstorm define design build validate ship iterate create-pr; do
  if [ -f "commands/workflow:${cmd}.md" ]; then
    pass "commands/workflow:${cmd}.md"
  else
    fail "MISSING: commands/workflow:${cmd}.md"
  fi
done

# 2. All have AgentSpec isolation preamble
echo "[2] AgentSpec isolation preamble present"
for cmd in brainstorm define design build validate ship iterate create-pr; do
  f="commands/workflow:${cmd}.md"
  if grep -q "AgentSpec Isolation" "$f" 2>/dev/null; then
    pass "$cmd has preamble"
  else
    fail "$cmd MISSING preamble"
  fi
done

# 3. workflow:build has Build Output Gate
echo "[3] Build Output Gate in workflow:build"
if grep -q "Build Output Gate" commands/workflow:build.md 2>/dev/null; then
  pass "Build Output Gate present"
else
  fail "Build Output Gate MISSING"
fi

# 4. No workflow command writes to .specs/changes/ (outside of the prohibition notice)
echo "[4] No workflow command adds .specs/changes/ as a write target"
for cmd in brainstorm define design build validate ship iterate create-pr; do
  f="commands/workflow:${cmd}.md"
  # Exclude the isolation preamble line itself (which mentions it as forbidden)
  WRITE_REFS=$(grep -v "must NOT write to" "$f" 2>/dev/null | grep -c "\.specs/changes/" 2>/dev/null || true)
  if [ "$WRITE_REFS" -eq 0 ]; then
    pass "workflow:${cmd} clean"
  else
    fail "workflow:${cmd} has $WRITE_REFS references to .specs/changes/ outside prohibition notice"
  fi
done

echo ""
echo "================================"
if [ "$ERRORS" -eq 0 ]; then echo "RESULT: PASS — 0 errors"; exit 0
else echo "RESULT: FAIL — $ERRORS error(s)"; exit 1; fi
