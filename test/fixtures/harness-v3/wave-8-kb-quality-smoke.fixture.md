#!/bin/bash
# wave-8-kb-quality-smoke.fixture.md
# Smoke test scenarios for KB indexer
#
# Eval: bash test/fixtures/harness-v3/wave-8-kb-quality-smoke.fixture.md > /dev/null 2>&1

set -e

WORK_DIR="/tmp/kb-indexer-smoke-$$"
KB_DIR="$WORK_DIR/kb"
mkdir -p "$KB_DIR"

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# =====================================================================
# Scenario 1: Fresh KB (last updated <7 days)
# =====================================================================

echo "[FIXTURE] Scenario 1: Fresh KB"

# Create fresh domain (modified within last 7 days)
mkdir -p "$KB_DIR/fresh-domain"
echo "# Fresh KB Domain" > "$KB_DIR/fresh-domain/index.md"
# Touch to current time (recent - 1 day old)
touch -d "1 day ago" "$KB_DIR/fresh-domain/index.md"

# Index the KB
cd "$WORK_DIR"
tools_path="$(cd /home/ubuntu/.config/opencode && pwd)/tools/kb-indexer.sh"
"$tools_path" index kb/ > /dev/null 2>&1

# Verify fresh domain is detected
freshness=$("$tools_path" freshness --domain fresh-domain)
echo "$freshness" | grep -q "Status: fresh" || {
  echo "ERROR: Fresh domain not detected as fresh"
  exit 1
}

echo "  ✓ Fresh domain correctly identified"

# =====================================================================
# Scenario 2: Stale KB (last updated >30 days)
# =====================================================================

echo "[FIXTURE] Scenario 2: Stale KB"

# Create stale domain (modified >30 days ago)
mkdir -p "$KB_DIR/stale-domain"
echo "# Stale KB Domain" > "$KB_DIR/stale-domain/index.md"
# Touch to 45 days ago
touch -d "45 days ago" "$KB_DIR/stale-domain/index.md"

# Re-index the KB (should include new domain)
"$tools_path" index kb/ > /dev/null 2>&1

# Verify stale domain is detected
freshness=$("$tools_path" freshness --domain stale-domain)
echo "$freshness" | grep -q "Status: stale" || {
  echo "ERROR: Stale domain not detected as stale"
  echo "Got: $freshness"
  exit 1
}

echo "  ✓ Stale domain correctly identified"

# =====================================================================
# Scenario 3: List command output
# =====================================================================

echo "[FIXTURE] Scenario 3: List command format"

list_output=$("$tools_path" list)
echo "$list_output" | grep -q "domain_id" || {
  echo "ERROR: List output missing header"
  exit 1
}

echo "$list_output" | grep -q "fresh-domain" || {
  echo "ERROR: List output missing fresh-domain"
  exit 1
}

echo "$list_output" | grep -q "stale-domain" || {
  echo "ERROR: List output missing stale-domain"
  exit 1
}

echo "  ✓ List command format valid"

# =====================================================================
# Scenario 4: JSON output
# =====================================================================

echo "[FIXTURE] Scenario 4: JSON format"

json_output=$("$tools_path" list --format json)
echo "$json_output" | grep -q "fresh-domain" || {
  echo "ERROR: JSON output missing fresh-domain"
  exit 1
}

echo "$json_output" | grep -q '"status"' || {
  echo "ERROR: JSON output missing status field"
  exit 1
}

echo "  ✓ JSON output valid"

# =====================================================================
# Scenario 5: Confidence scoring
# =====================================================================

echo "[FIXTURE] Scenario 5: Confidence scoring"

# Fresh domain should have high confidence (>70 for fresh/recent)
fresh_confidence=$("$tools_path" freshness --domain fresh-domain --format json | grep confidence | awk '{print $2}' | tr -d ',')
[ "$fresh_confidence" -gt 70 ] || {
  echo "ERROR: Fresh domain confidence too low: $fresh_confidence"
  exit 1
}

# Stale domain should have lower confidence (<90)
stale_confidence=$("$tools_path" freshness --domain stale-domain --format json | grep confidence | awk '{print $2}' | tr -d ',')
[ "$stale_confidence" -lt 80 ] || {
  echo "ERROR: Stale domain confidence too high: $stale_confidence"
  exit 1
}

echo "  ✓ Confidence scoring valid"

# =====================================================================
# Scenario 6: Cache behavior
# =====================================================================

echo "[FIXTURE] Scenario 6: Cache and idempotency"

# Run index twice, should produce same result
out1=$("$tools_path" list)
"$tools_path" index kb/ > /dev/null 2>&1
out2=$("$tools_path" list)

[ "$out1" = "$out2" ] || {
  echo "ERROR: Index not idempotent"
  exit 1
}

echo "  ✓ Caching and idempotency valid"

echo ""
echo "[FIXTURE] ✅ All smoke tests PASSED"
