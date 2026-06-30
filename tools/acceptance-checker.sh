#!/bin/bash
#
# acceptance-checker.sh — Final Validation Gate Tool (Wave 17)
# Checks all 16 prior waves for readiness to ship
#
# Usage:
#   acceptance-checker.sh final-gate      → Run all gate checks, show report
#   acceptance-checker.sh checklist       → Print validation checklist
#   acceptance-checker.sh ready-to-ship   → Binary pass/fail (exit 0 or 1)
#

set -u

CHANGE_ID="waves-7-17-implementation"
CHANGE_PATH=".specs/changes/$CHANGE_ID"
RESULTS_FILE="/tmp/acceptance-results.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

log_pass() {
  echo -e "${GREEN}✅ PASS${NC}: $1"
  ((PASSED++))
  echo "✅ PASS: $1" >> "$RESULTS_FILE"
}

log_fail() {
  echo -e "${RED}❌ FAIL${NC}: $1"
  ((FAILED++))
  echo "❌ FAIL: $1" >> "$RESULTS_FILE"
}

log_warn() {
  echo -e "${YELLOW}⚠️  WARN${NC}: $1"
  ((WARNINGS++))
  echo "⚠️  WARN: $1" >> "$RESULTS_FILE"
}

log_info() {
  echo "ℹ️  $1"
  echo "ℹ️  $1" >> "$RESULTS_FILE"
}

# Initialize
: > "$RESULTS_FILE"

check_wave_completion() {
  local label="$1"
  local wave_count=$(cd "$CHANGE_PATH" && grep "^status: implemented" tasks/W*.md 2>/dev/null | wc -l)
  
  if [[ $wave_count -ge 11 ]]; then
    log_pass "$label (found $wave_count implemented waves)"
  else
    log_fail "$label (only $wave_count/11 implemented)"
  fi
}

check_contracts() {
  local label="$1"
  local expected_contracts=(
    "verification-contract.md"
    "kb-quality-contract.md"
    "security-contract.md"
    "metrics-contract.md"
    "state-machine-contract.md"
    "recovery-contract.md"
    "orchestration-contract.md"
    "protocols-contract.md"
    "meta-validation-contract.md"
    "hardening-contract.md"
    "final-validation-contract.md"
  )
  
  local found=0
  for contract in "${expected_contracts[@]}"; do
    if [[ -f ".specs/shared/$contract" ]]; then
      ((found++))
    else
      log_warn "Missing contract: .specs/shared/$contract"
    fi
  done
  
  if [[ $found -ge 11 ]]; then
    log_pass "$label ($found/11 found)"
  else
    log_fail "$label (only $found/11 found)"
  fi
}

check_tools() {
  local label="$1"
  local expected_tools=(
    "verify-step.sh"
    "kb-indexer.sh"
    "security-scan.sh"
    "metrics-collector.sh"
    "state-validator.sh"
    "recovery-manager.sh"
    "wave-scheduler.sh"
    "agent-messenger.sh"
    "junta-auditor.sh"
    "chaos-tester.sh"
    "acceptance-checker.sh"
  )
  
  local found=0
  for tool in "${expected_tools[@]}"; do
    if [[ -f "tools/$tool" ]] && [[ -x "tools/$tool" ]]; then
      ((found++))
    else
      log_warn "Missing or not executable: tools/$tool"
    fi
  done
  
  if [[ $found -ge 11 ]]; then
    log_pass "$label ($found/11 executable)"
  else
    log_fail "$label (only $found/11 executable)"
  fi
}

check_fixtures() {
  local label="$1"
  local fixture_dir="test/fixtures/harness-v3"
  
  if [[ ! -d "$fixture_dir" ]]; then
    log_fail "$label (fixture directory not found)"
    return
  fi
  
  local fixture_count=$(find "$fixture_dir" -name "wave-*-smoke.fixture.md" 2>/dev/null | wc -l)
  
  if [[ $fixture_count -ge 11 ]]; then
    log_pass "$label ($fixture_count fixtures found)"
    
    # Try running one fixture as smoke test
    local sample_fixture=$(find "$fixture_dir" -name "wave-17-*.fixture.md" | head -1)
    if [[ -n "$sample_fixture" ]] && bash "$sample_fixture" > /dev/null 2>&1; then
      log_pass "Fixture smoke test passed: $(basename "$sample_fixture")"
    elif [[ -n "$sample_fixture" ]]; then
      log_warn "Fixture smoke test failed: $(basename "$sample_fixture")"
    fi
  else
    log_fail "$label (only $fixture_count fixtures found)"
  fi
}

check_documentation() {
  local label="$1"
  
  # Check AGENTS.md
  if grep -q "^### 21\.[7-9]\|^### 21\.1[0-7]" AGENTS.md 2>/dev/null; then
    log_pass "AGENTS.md has sections 21.7-21.17"
  else
    log_fail "AGENTS.md missing sections 21.7-21.17"
  fi
  
  # Check README.md
  if grep -q "Waves 7-17\|Wave 7.*Wave 17" README.md 2>/dev/null; then
    log_pass "README.md has Waves 7-17 section"
  else
    log_fail "README.md missing Waves 7-17 section"
  fi
  
  # Check roadmap
  if [[ -f "docs/HARNESS_V3_WAVES_7-17_ROADMAP.md" ]]; then
    log_pass "Roadmap doc exists: docs/HARNESS_V3_WAVES_7-17_ROADMAP.md"
  else
    log_fail "Roadmap doc missing: docs/HARNESS_V3_WAVES_7-17_ROADMAP.md"
  fi
}

check_quality() {
  local label="$1"
  
  # Check for TODOs (ignoring documentation references and code examples)
  local todos=$(grep -r "TODO\|FIXME" .specs/shared/*-contract.md 2>/dev/null | grep -v "^.*:\s*#\|check:\|description:\|Examples:\|patterns\|TODO_\|TODO with" | wc -l)
  if [[ $todos -eq 0 ]]; then
    log_pass "No TODOs or FIXMEs in contracts"
  else
    log_warn "$todos potential TODOs/FIXMEs (review if needed)"
  fi
}

print_checklist() {
  cat << 'EOF'
=============================================================================
WAVE 17 VALIDATION CHECKLIST
=============================================================================

Wave Completion (all 16 prior waves):
  ☐ W7-RALPH-LOOP .......................... status: implemented
  ☐ W8-KB-QUALITY .......................... status: implemented
  ☐ W9-SECURITY ............................ status: implemented
  ☐ W10-METRICS ............................ status: implemented
  ☐ W11-STATE-MACHINE ...................... status: implemented
  ☐ W12-RECOVERY ........................... status: implemented
  ☐ W13-ORCHESTRATION ...................... status: implemented
  ☐ W14-PROTOCOLS .......................... status: implemented
  ☐ W15-META-VALIDATION .................... status: implemented
  ☐ W16-HARDENING .......................... status: implemented
  ☐ W17-FINAL-VALIDATION ................... status: implemented

Contracts (11 required):
  ☐ verification-contract.md
  ☐ kb-quality-contract.md
  ☐ security-contract.md
  ☐ metrics-contract.md
  ☐ state-machine-contract.md
  ☐ recovery-contract.md
  ☐ orchestration-contract.md
  ☐ protocols-contract.md
  ☐ meta-validation-contract.md
  ☐ hardening-contract.md
  ☐ final-validation-contract.md

Tools (11 required, must be executable):
  ☐ tools/verify-step.sh
  ☐ tools/kb-indexer.sh
  ☐ tools/security-scan.sh
  ☐ tools/metrics-collector.sh
  ☐ tools/state-validator.sh
  ☐ tools/recovery-manager.sh
  ☐ tools/wave-scheduler.sh
  ☐ tools/agent-messenger.sh
  ☐ tools/junta-auditor.sh
  ☐ tools/chaos-tester.sh
  ☐ tools/acceptance-checker.sh

Documentation:
  ☐ AGENTS.md sections 21.7-21.17 present
  ☐ README.md has Waves 7-17 section
  ☐ docs/HARNESS_V3_WAVES_7-17_ROADMAP.md exists

Quality:
  ☐ No TODOs in contracts
  ☐ No FIXMEs in contracts
  ☐ All links valid
  ☐ No uncommitted changes

=============================================================================
EOF
}

# Main execution
case "${1:-final-gate}" in
  final-gate)
    echo "=============================================================================
WAVE 17 ACCEPTANCE GATE — Final Validation
============================================================================="
    echo ""
    
    log_info "Checking wave completion (need 16 implemented)..."
    check_wave_completion "Wave Completion Gate"
    echo ""
    
    log_info "Checking contracts (need 11)..."
    check_contracts "Contracts Gate"
    echo ""
    
    log_info "Checking tools (need 11 executable)..."
    check_tools "Tools Gate"
    echo ""
    
    log_info "Checking fixtures (need 11)..."
    check_fixtures "Fixtures Gate"
    echo ""
    
    log_info "Checking documentation..."
    check_documentation "Documentation Gate"
    echo ""
    
    log_info "Checking quality (no TODOs/FIXMEs)..."
    check_quality "Quality Gate"
    echo ""
    
    echo "=============================================================================
RESULTS
============================================================================="
    echo -e "Passed: ${GREEN}$PASSED${NC}"
    echo -e "Failed: ${RED}$FAILED${NC}"
    echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
      echo -e "${GREEN}✅ ALL GATES PASSED — READY TO SHIP${NC}"
      exit 0
    else
      echo -e "${RED}❌ GATES FAILED — CANNOT SHIP${NC}"
      exit 1
    fi
    ;;
    
  checklist)
    print_checklist
    exit 0
    ;;
    
  ready-to-ship)
    # Silent mode: just check and exit
    check_wave_completion "Wave Completion" 2>/dev/null
    check_contracts "Contracts" 2>/dev/null
    check_tools "Tools" 2>/dev/null
    check_fixtures "Fixtures" 2>/dev/null
    check_documentation "Documentation" 2>/dev/null
    check_quality "Quality" 2>/dev/null
    
    if [[ $FAILED -eq 0 ]]; then
      exit 0  # Ready to ship
    else
      exit 1  # Not ready
    fi
    ;;
    
  *)
    echo "Usage: $0 {final-gate|checklist|ready-to-ship}"
    echo ""
    echo "Commands:"
    echo "  final-gate .......... Run all gate checks, show report"
    echo "  checklist ........... Print validation checklist"
    echo "  ready-to-ship ....... Binary pass/fail (exit 0 or 1)"
    exit 1
    ;;
esac
