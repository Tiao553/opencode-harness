#!/bin/bash
# tools/allocation-check.sh
# Enforce file-level allocation scope boundaries

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: allocation-check.sh <command> [options]

Commands:
  check-file <file> <allocation.yaml>      Is file allowed by allocation?
  check-pattern <file> <pattern>           Does file match pattern?
  expand-allocation <old.yaml> <new_files> Show scope expansion delta
  validate-scope <ledger.md> <change_id>   Audit trail for change
  help                                     Show this help message

Examples:
  allocation-check.sh check-file agents/altitude-execution.agent.md allocation.yaml
  allocation-check.sh check-pattern agents/altitude-execution.agent.md "agents/*.agent.md"
  allocation-check.sh expand-allocation old-allocation.yaml "AGENTS.md README.md"
  allocation-check.sh validate-scope 03-execution-ledger.md wave-5

EOF
}

# Helper: Match file against glob pattern
matches_pattern() {
    local file=$1
    local pattern=$2
    
    # If pattern ends with /, it's a directory
    if [[ "$pattern" == */ ]]; then
        # Match directory prefix
        if [[ "$file" == "$pattern"* ]] || [[ "$file" == "${pattern%/}"/* ]]; then
            return 0
        fi
    else
        # Use bash pattern matching (glob)
        # Convert simple glob to bash pattern
        local bash_pattern="${pattern//\*/.}"
        bash_pattern="${bash_pattern//?/.}"
        
        # Better: use case statement for glob matching
        case "$file" in
            $pattern) return 0 ;;
            *) return 1 ;;
        esac
    fi
    
    return 1
}

# Helper: Extract YAML array from file
get_yaml_array() {
    local file=$1
    local key=$2
    
    yq ".${key}[]" "$file" 2>/dev/null || echo ""
}

# Command: check-file
cmd_check_file() {
    local file=$1
    local allocation=$2
    
    if [ -z "$file" ] || [ -z "$allocation" ]; then
        echo "Error: file and allocation.yaml required"
        return 1
    fi
    
    if [ ! -f "$allocation" ]; then
        echo -e "${RED}✗ Allocation file not found: $allocation${NC}" >&2
        return 1
    fi
    
    # Get allowed and forbidden lists
    local allowed_rules=$(get_yaml_array "$allocation" "allowed_files")
    local forbidden_rules=$(get_yaml_array "$allocation" "forbidden_files")
    
    # Check allowed rules first
    local found_allowed=false
    local matched_rule=""
    
    while IFS= read -r rule; do
        [ -z "$rule" ] && continue
        if matches_pattern "$file" "$rule"; then
            found_allowed=true
            matched_rule="$rule"
            break
        fi
    done <<< "$allowed_rules"
    
    if [ "$found_allowed" = true ]; then
        # Check if forbidden overrides
        while IFS= read -r forbidden_rule; do
            [ -z "$forbidden_rule" ] && continue
            if matches_pattern "$file" "$forbidden_rule"; then
                echo -e "${RED}✗ FORBID${NC}"
                echo "  File: $file"
                echo "  Matched: allowed ($matched_rule) but forbidden ($forbidden_rule)"
                echo "  Decision: FORBIDDEN (forbidden overrides allowed)"
                return 1
            fi
        done <<< "$forbidden_rules"
        
        echo -e "${GREEN}✓ ALLOW${NC}"
        echo "  File: $file"
        echo "  Matched: $matched_rule"
        echo "  Decision: ALLOWED"
        return 0
    fi
    
    # Check forbidden rules (not in allowed)
    while IFS= read -r forbidden_rule; do
        [ -z "$forbidden_rule" ] && continue
        if matches_pattern "$file" "$forbidden_rule"; then
            echo -e "${RED}✗ FORBID${NC}"
            echo "  File: $file"
            echo "  Matched: forbidden ($forbidden_rule)"
            echo "  Decision: FORBIDDEN"
            return 1
        fi
    done <<< "$forbidden_rules"
    
    # Default deny
    echo -e "${RED}✗ DENY${NC}"
    echo "  File: $file"
    echo "  Decision: DENIED (not in allowed_files, default deny)"
    return 1
}

# Command: check-pattern
cmd_check_pattern() {
    local file=$1
    local pattern=$2
    
    if [ -z "$file" ] || [ -z "$pattern" ]; then
        echo "Error: file and pattern required"
        return 1
    fi
    
    if matches_pattern "$file" "$pattern"; then
        echo -e "${GREEN}✓ MATCH${NC}"
        echo "  File: $file"
        echo "  Pattern: $pattern"
        echo "  Decision: MATCHES"
        return 0
    else
        echo -e "${RED}✗ NO MATCH${NC}"
        echo "  File: $file"
        echo "  Pattern: $pattern"
        echo "  Decision: DOES NOT MATCH"
        return 1
    fi
}

# Command: expand-allocation
cmd_expand_allocation() {
    local old_file=$1
    shift
    local new_files=("$@")
    
    if [ -z "$old_file" ] || [ ${#new_files[@]} -eq 0 ]; then
        echo "Error: old-allocation.yaml and new_files required"
        return 1
    fi
    
    if [ ! -f "$old_file" ]; then
        echo -e "${RED}✗ Old allocation file not found: $old_file${NC}" >&2
        return 1
    fi
    
    echo -e "${BLUE}Scope Expansion Delta:${NC}"
    echo ""
    
    # Get current allowed files
    local old_allowed=$(get_yaml_array "$old_file" "allowed_files")
    
    echo "Current allowed_files:"
    echo "$old_allowed" | sed 's/^/  - /'
    echo ""
    
    echo "Files to add:"
    for file in "${new_files[@]}"; do
        # Check if already in old_allowed
        local already_allowed=false
        while IFS= read -r rule; do
            [ -z "$rule" ] && continue
            if matches_pattern "$file" "$rule"; then
                already_allowed=true
                break
            fi
        done <<< "$old_allowed"
        
        if [ "$already_allowed" = true ]; then
            echo -e "  ${GREEN}✓${NC} $file (already allowed)"
        else
            echo -e "  ${YELLOW}+ $file (NEW - expansion)${NC}"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Scope delta: $(echo "${new_files[@]}" | wc -w) files${NC}"
}

# Command: validate-scope
cmd_validate_scope() {
    local ledger=$1
    local change_id=$2
    
    if [ -z "$ledger" ] || [ -z "$change_id" ]; then
        echo "Error: ledger.md and change_id required"
        return 1
    fi
    
    if [ ! -f "$ledger" ]; then
        echo -e "${RED}✗ Ledger file not found: $ledger${NC}" >&2
        return 1
    fi
    
    echo -e "${BLUE}=== Allocation Audit: $change_id ===${NC}"
    echo ""
    
    # Extract allocation events
    local total_events=$(yq '.allocation_events | length' "$ledger" 2>/dev/null || echo "0")
    local assigned=$(yq ".allocation_events[] | select(.type == \"allocation_assigned\") | .type" "$ledger" 2>/dev/null | wc -l)
    local allowed=$(yq ".allocation_events[] | select(.type == \"file_write_allowed\") | .type" "$ledger" 2>/dev/null | wc -l)
    local expanded=$(yq ".allocation_events[] | select(.type == \"scope_expansion_requested\") | .type" "$ledger" 2>/dev/null | wc -l)
    local blocked=$(yq ".allocation_events[] | select(.type == \"violation_blocked\") | .type" "$ledger" 2>/dev/null | wc -l)
    local warnings=$(yq ".allocation_events[] | select(.type == \"warning\") | .type" "$ledger" 2>/dev/null | wc -l)
    
    echo -e "${YELLOW}Summary:${NC}"
    echo "  Total events: $total_events"
    echo -e "  ${GREEN}✓ Assigned: $assigned${NC}"
    echo -e "  ${GREEN}✓ Allowed writes: $allowed${NC}"
    echo -e "  ${YELLOW}⚠ Scope expansions: $expanded${NC}"
    echo -e "  ${RED}✗ Violations blocked: $blocked${NC}"
    echo -e "  ${YELLOW}⚠ Warnings (no allocation): $warnings${NC}"
    echo ""
    
    # Scope compliance check
    local all_safe=true
    
    if [ "$blocked" -gt 0 ]; then
        all_safe=false
        echo -e "${RED}Blocked violations:${NC}"
        yq '.allocation_events[] | select(.type == "violation_blocked") | {file: .file, decision: .decision, reason: .reason}' "$ledger" 2>/dev/null | yq -C '.' | sed 's/^/  /'
        echo ""
    fi
    
    if [ "$all_safe" = true ]; then
        echo -e "${GREEN}✓ Scope compliance: ALL WRITES WITHIN SCOPE${NC}"
        return 0
    else
        echo -e "${RED}✗ Scope compliance: VIOLATIONS DETECTED${NC}"
        return 1
    fi
}

# Main dispatcher
main() {
    local command=${1:-help}
    
    case "$command" in
        check-file) shift; cmd_check_file "$@" ;;
        check-pattern) shift; cmd_check_pattern "$@" ;;
        expand-allocation) shift; cmd_expand_allocation "$@" ;;
        validate-scope) shift; cmd_validate_scope "$@" ;;
        help|--help|-h) usage ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
