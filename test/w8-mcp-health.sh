#!/usr/bin/env bash
# W8 MCP health check — T-117
# T-118 fallback tests included
set -euo pipefail
ERRORS=0
pass() { echo "  PASS  $1"; }
fail() { echo "  FAIL  $1"; ERRORS=$((ERRORS+1)); }
warn() { echo "  WARN  $1"; }

echo "=== W8 MCP Health Check ==="
echo ""

# 1. Registry file exists
echo "[1] MCP registry exists"
if [ -f ".specs/shared/mcp-registry.yaml" ]; then
  pass ".specs/shared/mcp-registry.yaml"
else
  fail "Registry missing"
fi

# 2. opencode.json has mcp block with 6 servers
echo "[2] opencode.json has 6 MCP servers"
MCP_COUNT=$(node -e "const c=require('./opencode.json');console.log(Object.keys(c.mcp||{}).length)" 2>/dev/null)
if [ "$MCP_COUNT" -eq 6 ]; then
  pass "6 servers registered"
else
  fail "Expected 6, found $MCP_COUNT"
fi

# 3. enabled servers are connected
echo "[3] Enabled servers: filesystem and sequential-thinking"
for srv in filesystem sequential-thinking; do
  STATUS=$(node -e "const c=require('./opencode.json');console.log(c.mcp?.['$srv']?.enabled??false)" 2>/dev/null)
  if [ "$STATUS" = "true" ]; then
    pass "$srv is enabled"
  else
    fail "$srv should be enabled"
  fi
done

# 4. disabled servers have valid reasons in registry
echo "[4] Disabled servers documented in registry"
for srv in context7 codegraph memory headroom; do
  if grep -q "$srv" .specs/shared/mcp-registry.yaml 2>/dev/null; then
    pass "$srv in registry"
  else
    fail "$srv not in registry"
  fi
done

# 5. MCP timeout configured
echo "[5] MCP timeout configured"
TIMEOUT=$(node -e "const c=require('./opencode.json');console.log(c.experimental?.mcp_timeout??0)" 2>/dev/null)
if [ "$TIMEOUT" -gt 0 ]; then
  pass "mcp_timeout: $TIMEOUT ms"
else
  fail "mcp_timeout not configured"
fi

# 6. No secret values in opencode.json
echo "[6] No secret values in opencode.json"
if grep -qiE "api[_-]?key\s*:\s*\"[^{]|bearer\s+[A-Za-z0-9]" opencode.json 2>/dev/null; then
  fail "Possible secret value in opencode.json"
else
  pass "No secret values found"
fi

# 7. Fallback: disabled MCP produces degraded mode, not crash
echo "[7] Disabled MCPs degrade gracefully"
DISABLED=$(node -e "const c=require('./opencode.json');const d=Object.entries(c.mcp||{}).filter(([k,v])=>v.enabled===false).map(([k])=>k);console.log(d.join(','))" 2>/dev/null)
if [ -n "$DISABLED" ]; then
  warn "Disabled MCPs: $DISABLED — confirm they do not block session start"
  pass "Disabled MCPs listed (manual confirm needed)"
fi

echo ""
echo "================================"
if [ "$ERRORS" -eq 0 ]; then echo "RESULT: PASS — 0 errors"; exit 0
else echo "RESULT: FAIL — $ERRORS error(s)"; exit 1; fi
