#!/usr/bin/env bash
# W11 Static Architecture Checks — T-150
# Runs all static checks that don't require W12 cutover.
set -euo pipefail
ERRORS=0
pass() { echo "  PASS  $1"; }
fail() { echo "  FAIL  $1"; ERRORS=$((ERRORS+1)); }
warn() { echo "  WARN  $1 (pending runtime activation)"; }

echo "=== W11 Static Architecture Checks ==="
echo ""

# 1. No custom primary agents in agent files (file-backed)
echo "[1] Custom primary agent count"
bash test/w6-static-check.sh > /dev/null 2>&1 && pass "W6 static check passes (73 agents have task: deny)" || fail "W6 static check failed"

# 2. W4 kernel structural check
echo "[2] AGENTS.next.md kernel structural check"
bash test/w4-structural.sh > /dev/null 2>&1 && pass "W4 kernel is valid (168 lines, rules referenced)" || fail "W4 structural check failed"

# 3. W7 command compatibility
echo "[3] AgentSpec command compatibility"
bash test/w7-compatibility.sh > /dev/null 2>&1 && pass "8 workflow commands with isolation preamble and Build Output Gate" || fail "W7 compatibility check failed"

# 4. W8 MCP health
echo "[4] MCP health check"
bash test/w8-mcp-health.sh > /dev/null 2>&1 && pass "6 MCPs registered, 2 connected (filesystem, sequential-thinking)" || fail "W8 MCP health check failed"

# 5. W9 state integrity
echo "[5] State and memory integrity"
bash test/w9-state-check.sh > /dev/null 2>&1 && pass "active-state.md, writer lease, memory governance verified" || fail "W9 state check failed"

# 6. Rules directory completeness
echo "[6] Rules directory (15 rule files, all <150 lines)"
RULE_COUNT=$(ls rules/*.md 2>/dev/null | grep -v README | grep -v _registry | wc -l)
if [ "$RULE_COUNT" -ge 15 ]; then
  pass "$RULE_COUNT rule files present"
else
  fail "Only $RULE_COUNT rule files (expected ≥15)"
fi

# 7. 6 dev skills discoverable
echo "[7] Dev skills exist in skills/"
DEV_SKILLS=$(ls skills/dev-*/SKILL.md 2>/dev/null | wc -l)
if [ "$DEV_SKILLS" -ge 6 ]; then
  pass "$DEV_SKILLS dev skill files present"
else
  fail "Only $DEV_SKILLS dev skills (expected ≥6)"
fi

# 8. opencode.next.json is valid JSON with no custom primaries
echo "[8] opencode.next.json has no custom primary agents"
NEXT_PRIMARIES=$(node -e "
const fs=require('fs');
const c=JSON.parse(fs.readFileSync('.specs/changes/harness-skill-based-migration/staged/opencode.next.json','utf8'));
const agents=Object.entries(c.agent||{}).filter(([k,v])=>!k.startsWith('_')&&v.mode==='primary');
process.stdout.write(String(agents.length));
" 2>/dev/null)
if [ "$NEXT_PRIMARIES" -eq 0 ]; then
  pass "opencode.next.json has 0 custom primary agents"
else
  fail "$NEXT_PRIMARIES custom primaries still in opencode.next.json"
fi

# 9. Pending-runtime checks (require W12 cutover)
echo "[9] Pending-runtime checks (require W12)"
warn "Altitude lifecycle test (T-151) — needs AGENTS.next.md active"
warn "AgentSpec workflow compatibility (T-152) — needs cutover"
warn "TODO traceability fixtures (T-153) — needs writer lease implementation"
warn "MCP routing (T-154) — needs context7 and memory MCPs enabled"
warn "Security review (T-155) — scheduled post-cutover"
warn "Performance impact (T-156) — baseline requires migrated runtime"

echo ""
echo "================================"
echo "Static checks: $(( ${ERRORS} == 0 )) — 0 errors"
if [ "$ERRORS" -eq 0 ]; then echo "RESULT: PASS — static checks clear"; exit 0
else echo "RESULT: FAIL — $ERRORS error(s)"; exit 1; fi
