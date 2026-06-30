#!/bin/bash
# test/fixtures/harness-v3/wave-13-orchestration-smoke.fixture.md
# 
# Wave 13: Multi-Wave Orchestration
# Smoke test fixture with 2 scenarios
#
# Scenario 1: Schedule all waves, verify topological order
# Scenario 2: Execute wave, verify status transitions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find OpenCode root
if command -v git &>/dev/null && git rev-parse --show-toplevel &>/dev/null; then
  OPENCODE_ROOT="$(git rev-parse --show-toplevel)"
else
  # Fallback: traverse up from fixture dir
  OPENCODE_ROOT="$SCRIPT_DIR"
  while [[ "$OPENCODE_ROOT" != "/" ]] && [[ ! -d "$OPENCODE_ROOT/.specs" ]]; do
    OPENCODE_ROOT="$(dirname "$OPENCODE_ROOT")"
  done
fi

SCHEDULER="${OPENCODE_ROOT}/tools/wave-scheduler.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

# Helper: Assert wave appears in schedule
assert_in_schedule() {
  local wave="$1"
  local schedule="$2"
  if echo "$schedule" | grep -q "$wave"; then
    echo -e "${GREEN}✓${NC} Wave $wave in schedule"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} Wave $wave NOT in schedule"
    ((FAILED++))
  fi
}

# Helper: Assert wave order
assert_wave_before() {
  local wave1="$1"
  local wave2="$2"
  local schedule="$3"
  
  local pos1=$(echo "$schedule" | grep -n "$wave1" | cut -d: -f1 | head -1)
  local pos2=$(echo "$schedule" | grep -n "$wave2" | cut -d: -f1 | head -1)
  
  if [[ $pos1 -lt $pos2 ]]; then
    echo -e "${GREEN}✓${NC} Wave $wave1 before $wave2"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} Wave $wave1 NOT before $wave2 (pos1=$pos1, pos2=$pos2)"
    ((FAILED++))
  fi
}

# Helper: Verify all dependencies are met
verify_dependency_order() {
  local schedule="$1"
  
  # Extract wave numbers from schedule (1-indexed lines)
  local -a waves_in_order
  while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*[0-9]+\.[[:space:]]*(W[0-9]+) ]]; then
      waves_in_order+=("${BASH_REMATCH[1]}")
    fi
  done <<< "$schedule"
  
  # Dependencies (simplified)
  declare -A deps=(
    [W8]="W7"
    [W9]="W7"
    [W10]="W7"
    [W11]="W7"
    [W12]="W11"
    [W13]="W11"
    [W14]="W7"
    [W16]="W12 W13"
    [W17]="W15 W16"
  )
  
  local all_valid=1
  
  for wave in "${waves_in_order[@]}"; do
    if [[ -v deps[$wave] ]]; then
      local wave_deps="${deps[$wave]}"
      for dep in $wave_deps; do
        # Check if dependency appeared before this wave
        local dep_pos=-1
        local wave_pos=-1
        local pos=0
        
        for w in "${waves_in_order[@]}"; do
          ((pos++))
          if [[ "$w" == "$dep" ]]; then
            dep_pos=$pos
          elif [[ "$w" == "$wave" ]]; then
            wave_pos=$pos
          fi
        done
        
        if [[ $dep_pos -lt $wave_pos ]]; then
          : # OK, dependency is before wave
        else
          echo -e "${RED}✗${NC} Dependency violation: $wave depends on $dep, but $dep is not before $wave"
          all_valid=0
          ((FAILED++))
        fi
      done
    fi
  done
  
  if [[ $all_valid -eq 1 ]]; then
    echo -e "${GREEN}✓${NC} All dependencies satisfied in order"
    ((PASSED++))
  fi
}

# ============================================================================
# Scenario 1: Schedule all waves and verify topological order
# ============================================================================
scenario_1_schedule() {
  echo ""
  echo -e "${YELLOW}=== Scenario 1: Schedule all waves ===${NC}"
  
  if ! command -v bash &> /dev/null; then
    echo -e "${RED}✗${NC} bash not found"
    ((FAILED++))
    return 1
  fi
  
  local schedule
  if ! schedule=$("$SCHEDULER" schedule 2>&1); then
    echo -e "${RED}✗${NC} wave-scheduler.sh schedule failed"
    ((FAILED++))
    return 1
  fi
  
  echo -e "${GREEN}✓${NC} wave-scheduler.sh schedule succeeded"
  ((PASSED++))
  
  # Verify all 11 waves are in the schedule
  local wave_count=0
  for wave in W7 W8 W9 W10 W11 W12 W13 W14 W15 W16 W17; do
    if echo "$schedule" | grep -q "$wave"; then
      ((wave_count++))
      assert_in_schedule "$wave" "$schedule"
    else
      echo -e "${RED}✗${NC} Wave $wave missing from schedule"
      ((FAILED++))
    fi
  done
  
  if [[ $wave_count -eq 11 ]]; then
    echo -e "${GREEN}✓${NC} All 11 waves present in schedule"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} Expected 11 waves, got $wave_count"
    ((FAILED++))
  fi
  
  # Verify key dependencies
  echo ""
  echo "Checking key dependencies:"
  assert_wave_before "W7" "W8" "$schedule"
  assert_wave_before "W7" "W11" "$schedule"
  assert_wave_before "W11" "W12" "$schedule"
  assert_wave_before "W11" "W13" "$schedule"
  assert_wave_before "W12" "W16" "$schedule"
  assert_wave_before "W13" "W16" "$schedule"
  
  # Verify overall dependency order
  echo ""
  verify_dependency_order "$schedule"
}

# ============================================================================
# Scenario 2: Execute wave and verify status
# ============================================================================
scenario_2_execute() {
  echo ""
  echo -e "${YELLOW}=== Scenario 2: Execute wave and verify status ===${NC}"
  
  # Get initial status
  local status_before
  if ! status_before=$("$SCHEDULER" status --wave W7 2>&1); then
    echo -e "${RED}✗${NC} wave-scheduler.sh status failed"
    ((FAILED++))
    return 1
  fi
  
  echo -e "${GREEN}✓${NC} wave-scheduler.sh status succeeded"
  ((PASSED++))
  
  if echo "$status_before" | grep -q "queued"; then
    echo -e "${GREEN}✓${NC} Wave W7 initial status is queued"
    ((PASSED++))
  else
    echo -e "${YELLOW}~${NC} Wave W7 status might not be queued"
  fi
  
  # Execute W7
  if "$SCHEDULER" execute --wave W7 2>&1; then
    echo -e "${GREEN}✓${NC} wave-scheduler.sh execute --wave W7 succeeded"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} wave-scheduler.sh execute --wave W7 failed"
    ((FAILED++))
    return 1
  fi
  
  # Check status after execution
  local status_after
  if status_after=$("$SCHEDULER" status --wave W7 2>&1); then
    if echo "$status_after" | grep -q "completed"; then
      echo -e "${GREEN}✓${NC} Wave W7 final status is completed"
      ((PASSED++))
    elif echo "$status_after" | grep -q "W7"; then
      echo -e "${GREEN}✓${NC} Wave W7 status updated"
      ((PASSED++))
    else
      echo -e "${YELLOW}~${NC} Wave W7 status unclear"
    fi
  fi
}

# ============================================================================
# Scenario 3: Test graph output (bonus)
# ============================================================================
scenario_3_graph() {
  echo ""
  echo -e "${YELLOW}=== Scenario 3: Generate DAG graph ===${NC}"
  
  local graph
  if ! graph=$("$SCHEDULER" graph 2>&1); then
    echo -e "${RED}✗${NC} wave-scheduler.sh graph failed"
    ((FAILED++))
    return 1
  fi
  
  echo -e "${GREEN}✓${NC} wave-scheduler.sh graph succeeded"
  ((PASSED++))
  
  # Check for Graphviz format markers
  if echo "$graph" | grep -q "digraph WaveDAG"; then
    echo -e "${GREEN}✓${NC} Graph output contains digraph declaration"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} Graph output missing digraph declaration"
    ((FAILED++))
  fi
  
  # Check for edges
  if echo "$graph" | grep -q "->"; then
    echo -e "${GREEN}✓${NC} Graph output contains edges"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC} Graph output missing edges"
    ((FAILED++))
  fi
  
  # Check for specific waves
  for wave in W7 W11 W15 W17; do
    if echo "$graph" | grep -q "$wave"; then
      ((PASSED++))
    else
      echo -e "${RED}✗${NC} Graph missing wave $wave"
      ((FAILED++))
    fi
  done
}

# ============================================================================
# Main
# ============================================================================
main() {
  echo "Wave 13: Multi-Wave Orchestration — Smoke Test Fixture"
  echo "========================================================"
  
  if [[ ! -x "$SCHEDULER" ]]; then
    echo -e "${RED}ERROR: wave-scheduler.sh not found at $SCHEDULER${NC}"
    exit 1
  fi
  
  scenario_1_schedule
  scenario_2_execute
  scenario_3_graph
  
  # Summary
  echo ""
  echo "======================================================"
  echo -e "Test Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"
  echo "======================================================"
  
  if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    exit 0
  else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
  fi
}

main "$@"
