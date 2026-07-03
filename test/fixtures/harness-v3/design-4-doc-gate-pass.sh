#!/bin/bash
# Fixture: design-4-doc-gate-pass.sh
# Test: Design 4-doc gate passes when all 4 docs exist
# Expected: When PRD/ADR/TEST-SPEC/DESIGN exist, gate allows decomposition (exit 0)

set -e

change_dir=".specs/changes/waves-18-23-implementation"

# Verify all 4 required docs exist in the real change
echo "Checking Design 4-doc gate (all docs must exist)..."

docs_found=0
docs_missing=0

for doc in "PRD.md" "ADR.md" "TEST-SPEC.md" "DESIGN.md"; do
  if [ -f "$change_dir/$doc" ]; then
    echo "  ✅ $doc exists ($(wc -l < "$change_dir/$doc") lines)"
    ((docs_found++))
  else
    echo "  ❌ $doc MISSING"
    ((docs_missing++))
  fi
done

echo ""
echo "=========================================="
echo "Design 4-Doc Gate Results: $docs_found/4 docs exist"
echo "=========================================="

if [ $docs_missing -eq 0 ]; then
  echo "✅ PASS: Design 4-doc gate allows phase transition"
  exit 0
else
  echo "❌ FAIL: Design 4-doc gate blocked ($docs_missing docs missing)"
  exit 1
fi
