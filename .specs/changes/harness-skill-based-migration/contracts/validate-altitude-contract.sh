#!/usr/bin/env bash
# validate-altitude-contract.sh
# T-028 — Altitude contract validator
# Checks that the altitude-workflow-contract.md and altitude-start.md are
# structurally complete and internally consistent.
# Usage: bash validate-altitude-contract.sh
# Exit 0 = PASS; Exit 1 = FAIL

set -euo pipefail

CONTRACT=".specs/changes/harness-skill-based-migration/contracts/altitude-workflow-contract.md"
START=".specs/changes/harness-skill-based-migration/contracts/altitude-start.md"
ERRORS=0

check() {
  local label="$1"
  local file="$2"
  local pattern="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "  PASS  $label"
  else
    echo "  FAIL  $label — pattern not found: $pattern"
    ERRORS=$((ERRORS + 1))
  fi
}

check_absent() {
  local label="$1"
  local file="$2"
  local pattern="$3"
  if ! grep -q "$pattern" "$file" 2>/dev/null; then
    echo "  PASS  $label"
  else
    echo "  FAIL  $label — forbidden pattern found: $pattern"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "=== Altitude Contract Validator ==="
echo ""

# --- File existence ---
echo "[1] File existence"
for f in "$CONTRACT" "$START"; do
  if [ -f "$f" ]; then
    echo "  PASS  $f exists"
  else
    echo "  FAIL  $f missing"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""

# --- Workflow contract structural checks ---
echo "[2] Workflow contract structure"
check "Has version"              "$CONTRACT" "^\\*\\*Version:\\*\\*"
check "Has six phases section"   "$CONTRACT" "## 2\\. Phases"
check "Intent phase defined"     "$CONTRACT" "## 4\\. Intent Phase"
check "Structure phase defined"  "$CONTRACT" "## 5\\. Structure Phase"
check "Design/Plan defined"      "$CONTRACT" "## 6\\. Design/Plan Phase"
check "Execution phase defined"  "$CONTRACT" "## 7\\. Execution Phase"
check "Validation phase defined" "$CONTRACT" "## 8\\. Validation Phase"
check "Ship phase defined"       "$CONTRACT" "## 9\\. Ship Phase"
check "Overrides defined"        "$CONTRACT" "## 10\\. Overrides"
check "Validation checklist"     "$CONTRACT" "## 11\\. Validation Checklist"
check "Changelog present"        "$CONTRACT" "## Changelog"
echo ""

# --- Phase completeness checks ---
echo "[3] Phase completeness"
for phase in "Intent" "Structure" "Design" "Execution" "Validation" "Ship"; do
  check "Phase $phase has entry gate"    "$CONTRACT" "### Entry gate"
  check "Phase $phase has actions"       "$CONTRACT" "### Actions"
  check "Phase $phase has exit gate"     "$CONTRACT" "### Exit gate"
  check "Phase $phase has forbidden"     "$CONTRACT" "### Forbidden actions"
done
echo ""

# --- ADR references ---
echo "[4] ADR references"
for adr in ADR-0001 ADR-0002 ADR-0004 ADR-0005 ADR-0006 ADR-0007; do
  check "References $adr" "$CONTRACT" "$adr"
done
echo ""

# --- START contract checks ---
echo "[5] START contract structure"
check "Has trigger conditions"      "$START" "Altitude START Trigger"
check "Has state-resolution steps"  "$START" "State-Resolution Protocol"
check "Has writer lease step"       "$START" "writer lease"
check "Has bridge prohibition"      "$START" "Bridge Prohibition"
check "Has conflict record format"  "$START" "conflict_resolution"
echo ""

# --- Invariant checks ---
echo "[6] Non-negotiable invariants"
check "No custom primary mention"            "$CONTRACT" "No custom primary host"
check "Parent-only writer stated"            "$CONTRACT" "Parent-only state and TODO writer"
check "MCP not authority stated"             "$CONTRACT" "MCP output is data"
check "AgentSpec bridge prohibition stated"  "$CONTRACT" "AgentSpec commands must not mutate Altitude state"
check "4-Doc Gate defined"                   "$CONTRACT" "4-Doc Gate"
echo ""

# --- Forbidden content ---
echo "[7] Forbidden content"
check_absent "No secret values"       "$CONTRACT" "api.key\|bearer \|token="
check_absent "No absolute home paths" "$CONTRACT" "/home/ubuntu"
echo ""

# --- Summary ---
echo "=================================="
if [ "$ERRORS" -eq 0 ]; then
  echo "RESULT: PASS — 0 errors"
  exit 0
else
  echo "RESULT: FAIL — $ERRORS error(s)"
  exit 1
fi
