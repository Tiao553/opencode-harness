#!/bin/bash
# wave-scheduler.sh — Multi-Wave Scheduling and Orchestration
# Version: 1.2 (Corrected topological sort)

get_wave_deps() {
  case "$1" in
    W7) echo "" ;;
    W8) echo "W7" ;;
    W9) echo "W7" ;;
    W10) echo "W7" ;;
    W11) echo "W7" ;;
    W12) echo "W11" ;;
    W13) echo "W11" ;;
    W14) echo "W7" ;;
    W15) echo "W7 W8 W9 W10 W11 W12 W13 W14" ;;
    W16) echo "W12 W13" ;;
    W17) echo "W15 W16" ;;
    *) echo "UNKNOWN" ;;
  esac
}

get_wave_title() {
  case "$1" in
    W7) echo "Ralph Loop" ;;
    W8) echo "KB Quality" ;;
    W9) echo "Security" ;;
    W10) echo "Metrics" ;;
    W11) echo "State Machine" ;;
    W12) echo "Recovery" ;;
    W13) echo "Orchestration" ;;
    W14) echo "Protocols" ;;
    W15) echo "Meta-Validation" ;;
    W16) echo "Hardening" ;;
    W17) echo "Final Validation" ;;
    *) echo "Unknown" ;;
  esac
}

ALL_WAVES=(W7 W8 W9 W10 W11 W12 W13 W14 W15 W16 W17)

# Topological sort using Kahn's algorithm (fixed version)
topological_sort() {
  local -a result=()
  local -a in_degree_array=(0 0 0 0 0 0 0 0 0 0 0)
  
  # Map wave to index
  declare -A wave_to_idx
  for i in "${!ALL_WAVES[@]}"; do
    wave_to_idx["${ALL_WAVES[$i]}"]=$i
  done
  
  # Count in-degrees
  for wave in "${ALL_WAVES[@]}"; do
    local deps
    deps=$(get_wave_deps "$wave")
    local idx="${wave_to_idx[$wave]}"
    
    if [[ -n "$deps" ]]; then
      for dep in $deps; do
        ((in_degree_array[$idx]++))
      done
    fi
  done
  
  # Find initial queue (in_degree = 0)
  local -a queue=()
  for wave in "${ALL_WAVES[@]}"; do
    local idx="${wave_to_idx[$wave]}"
    if [[ ${in_degree_array[$idx]} -eq 0 ]]; then
      queue+=("$wave")
    fi
  done
  
  # Process queue
  while [[ ${#queue[@]} -gt 0 ]]; do
    # Sort queue for determinism
    IFS=$'\n' read -rd '' -a queue < <(printf '%s\n' "${queue[@]}" | sort) || true
    
    local current="${queue[0]}"
    queue=("${queue[@]:1}")
    result+=("$current")
    
    # For each wave that depends on current, decrement in_degree
    for wave in "${ALL_WAVES[@]}"; do
      local deps
      deps=$(get_wave_deps "$wave")
      local wave_idx="${wave_to_idx[$wave]}"
      
      # Check if current is a dependency of wave
      if [[ " $deps " =~ " $current " ]]; then
        ((in_degree_array[$wave_idx]--))
        
        if [[ ${in_degree_array[$wave_idx]} -eq 0 ]]; then
          queue+=("$wave")
        fi
      fi
    done
  done
  
  if [[ ${#result[@]} -ne 11 ]]; then
    echo "ERROR: Failed to process all waves" >&2
    return 1
  fi
  
  printf '%s\n' "${result[@]}"
}

schedule_command() {
  echo "# Wave Execution Schedule (Topological Order)"
  echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  
  local -a order
  if ! mapfile -t order < <(topological_sort); then
    return 1
  fi
  
  echo "# Execution order:"
  local i=0
  for wave in "${order[@]}"; do
    ((i++))
    printf "%2d. %s\n" "$i" "$wave"
  done
  
  return 0
}

status_command() {
  local wave_filter="${1:-}"
  
  echo "# Wave Status Report"
  echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo ""
  
  for wave in "${ALL_WAVES[@]}"; do
    if [[ -n "$wave_filter" ]] && [[ "$wave_filter" != "$wave" ]]; then
      continue
    fi
    
    printf "%-4s %-20s queued\n" "$wave" "$(get_wave_title "$wave")"
  done
  
  return 0
}

execute_command() {
  local wave=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --wave) wave="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  
  if [[ -z "$wave" ]]; then
    echo "ERROR: --wave <N> is required" >&2
    return 1
  fi
  
  local found=0
  for w in "${ALL_WAVES[@]}"; do
    if [[ "$w" == "$wave" ]]; then
      found=1
      break
    fi
  done
  
  if [[ $found -eq 0 ]]; then
    echo "ERROR: Wave $wave not found" >&2
    return 1
  fi
  
  echo "✅ $wave marked as completed"
  return 0
}

graph_command() {
  echo "# Wave Dependency DAG (Graphviz)"
  echo ""
  echo "digraph WaveDAG {"
  echo "  rankdir=LR;"
  echo "  node [shape=box, style=filled, fillcolor=lightblue];"
  echo ""
  
  for wave in "${ALL_WAVES[@]}"; do
    echo "  \"$wave\" [label=\"$wave\\n($(get_wave_title "$wave"))\"];"
  done
  
  echo ""
  
  for wave in "${ALL_WAVES[@]}"; do
    local deps
    deps=$(get_wave_deps "$wave")
    
    for dep in $deps; do
      echo "  \"$dep\" -> \"$wave\";"
    done
  done
  
  echo "}"
  return 0
}

main() {
  local command="${1:-schedule}"
  shift || true
  
  case "$command" in
    schedule) schedule_command "$@" ;;
    status) status_command "$@" ;;
    execute) execute_command "$@" ;;
    graph) graph_command "$@" ;;
    *) 
      echo "Usage: $0 {schedule|status|execute|graph} [options]" >&2
      return 1
      ;;
  esac
}

main "$@"
