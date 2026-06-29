#!/bin/bash
# tools/artifact-checksum.sh
# Compute, verify, and manage artifact checksums

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: artifact-checksum.sh <command> [options]

Commands:
  compute <artifact>        Compute SHA256 checksum of artifact
  verify <artifact>         Verify artifact checksum matches header
  compare <artifact1> <artifact2>  Compare checksums of two artifacts
  list-all <change_id>      List all checksums in a change
  detect-changes <registry> <artifact_slug>  Detect changes via registry
  validate-chain <registry> <artifact_slug>  Validate prior_checksum chain
  help                      Show this help message

Examples:
  artifact-checksum.sh compute .specs/changes/wave-4/prd.md
  artifact-checksum.sh verify .specs/changes/wave-4/prd.md
  artifact-checksum.sh compare .specs/changes/wave-4/prd-v1.md .specs/changes/wave-4/prd-v2.md
  artifact-checksum.sh list-all wave-4-artifact-versioning
  artifact-checksum.sh detect-changes artifact-generation-registry.yaml prd
  artifact-checksum.sh validate-chain artifact-generation-registry.yaml prd

EOF
}

# Helper: compute SHA256 on a file
compute_sha256() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ File not found: $file${NC}" >&2
        return 1
    fi
    
    # Compute SHA256
    local hash=$(sha256sum "$file" | awk '{print $1}')
    echo "sha256:$hash"
}

# Helper: extract checksum from artifact header (Markdown)
extract_checksum_md() {
    local file=$1
    
    # Extract checksum from YAML frontmatter
    yq -r '.checksum' "$file" 2>/dev/null || echo ""
}

# Helper: extract checksum from artifact header (JSON)
extract_checksum_json() {
    local file=$1
    
    # Extract checksum from JSON
    jq -r '.checksum' "$file" 2>/dev/null || echo ""
}

# Command: compute
cmd_compute() {
    local artifact=$1
    
    if [ -z "$artifact" ]; then
        echo "Error: artifact path required"
        return 1
    fi
    
    compute_sha256 "$artifact"
}

# Command: verify
cmd_verify() {
    local artifact=$1
    
    if [ -z "$artifact" ]; then
        echo "Error: artifact path required"
        return 1
    fi
    
    if [ ! -f "$artifact" ]; then
        echo -e "${RED}✗ File not found: $artifact${NC}" >&2
        return 1
    fi
    
    # Try to extract checksum from header
    local header_checksum=""
    
    if [[ "$artifact" == *.md ]]; then
        header_checksum=$(extract_checksum_md "$artifact")
    elif [[ "$artifact" == *.json ]]; then
        header_checksum=$(extract_checksum_json "$artifact")
    fi
    
    if [ -z "$header_checksum" ]; then
        echo -e "${YELLOW}⚠ No checksum found in header${NC}"
        return 1
    fi
    
    # Compute current checksum
    local current_checksum=$(compute_sha256 "$artifact")
    
    if [ "$header_checksum" == "$current_checksum" ]; then
        echo -e "${GREEN}✓ Checksum valid${NC}"
        echo "  Checksum: $current_checksum"
        return 0
    else
        echo -e "${RED}✗ Checksum mismatch!${NC}"
        echo "  Expected: $header_checksum"
        echo "  Current:  $current_checksum"
        echo ""
        echo "Action: artifact was modified outside of registry"
        return 1
    fi
}

# Command: compare
cmd_compare() {
    local artifact1=$1
    local artifact2=$2
    
    if [ -z "$artifact1" ] || [ -z "$artifact2" ]; then
        echo "Error: two artifact paths required"
        return 1
    fi
    
    local checksum1=$(compute_sha256 "$artifact1")
    local checksum2=$(compute_sha256 "$artifact2")
    
    echo "Comparing checksums:"
    echo "  File 1: $artifact1"
    echo "  Hash 1: $checksum1"
    echo ""
    echo "  File 2: $artifact2"
    echo "  Hash 2: $checksum2"
    echo ""
    
    if [ "$checksum1" == "$checksum2" ]; then
        echo -e "${GREEN}✓ Checksums match (artifacts are identical)${NC}"
        return 0
    else
        echo -e "${RED}✗ Checksums differ (artifacts are different)${NC}"
        return 1
    fi
}

# Command: list-all
cmd_list_all() {
    local change_id=$1
    
    if [ -z "$change_id" ]; then
        echo "Error: change_id required"
        return 1
    fi
    
    local registry=".specs/changes/$change_id/artifact-generation-registry.yaml"
    
    if [ ! -f "$registry" ]; then
        echo -e "${RED}✗ Registry not found: $registry${NC}" >&2
        return 1
    fi
    
    echo "Artifact checksums in change: $change_id"
    echo ""
    
    yq '.artifact_generations | to_entries[] | {
        artifact: .key,
        generations: .value.generation_count,
        latest_checksum: .value.generations[-1].checksum
    }' "$registry" | yq -C '.'
}

# Command: detect-changes
cmd_detect_changes() {
    local registry=$1
    local artifact_slug=$2
    
    if [ -z "$registry" ] || [ -z "$artifact_slug" ]; then
        echo "Error: registry and artifact_slug required"
        return 1
    fi
    
    if [ ! -f "$registry" ]; then
        echo -e "${RED}✗ Registry not found: $registry${NC}" >&2
        return 1
    fi
    
    # Check if artifact has multiple generations
    local gen_count=$(yq ".artifact_generations.$artifact_slug.generation_count" "$registry" 2>/dev/null || echo "0")
    
    if [ "$gen_count" -lt 2 ]; then
        echo -e "${GREEN}✓ No changes detected (only 1 generation)${NC}"
        return 0
    fi
    
    # Get checksums of successive generations
    echo "Change history for $artifact_slug:"
    echo ""
    
    yq ".artifact_generations.$artifact_slug.generations[] | {
        generation: .generation_number,
        checksum: .checksum,
        prior: .prior_generation_checksum,
        timestamp: .generated_at
    }" "$registry" | \
    yq -C '.' | \
    awk '
        NR==1 { line=$0 }
        /^--$/ && NR>1 {
            print line
            print "  ↓ CHANGED"
            line=$0
            next
        }
        { if (NR>1) line=$0 }
        END { print line }
    '
    
    echo ""
    echo -e "${YELLOW}Summary: $artifact_slug was regenerated $gen_count times${NC}"
}

# Command: validate-chain
cmd_validate_chain() {
    local registry=$1
    local artifact_slug=$2
    
    if [ -z "$registry" ] || [ -z "$artifact_slug" ]; then
        echo "Error: registry and artifact_slug required"
        return 1
    fi
    
    if [ ! -f "$registry" ]; then
        echo -e "${RED}✗ Registry not found: $registry${NC}" >&2
        return 1
    fi
    
    echo "Validating checksum chain for $artifact_slug..."
    echo ""
    
    local gen_count=$(yq ".artifact_generations.$artifact_slug.generation_count" "$registry")
    local all_valid=true
    
    for ((i=0; i<gen_count; i++)); do
        local gen_num=$(yq ".artifact_generations.$artifact_slug.generations[$i].generation_number" "$registry")
        local checksum=$(yq ".artifact_generations.$artifact_slug.generations[$i].checksum" "$registry")
        local prior=$(yq ".artifact_generations.$artifact_slug.generations[$i].prior_generation_checksum" "$registry")
        
        if [ "$gen_num" -gt 1 ]; then
            local prior_checksum=$(yq ".artifact_generations.$artifact_slug.generations[$((i-1))].checksum" "$registry")
            
            if [ "$prior" == "$prior_checksum" ]; then
                echo -e "${GREEN}✓ Gen $gen_num:${NC} prior link valid"
            else
                echo -e "${RED}✗ Gen $gen_num:${NC} prior link broken!"
                echo "  Expected: $prior_checksum"
                echo "  Got:      $prior"
                all_valid=false
            fi
        else
            echo -e "${GREEN}✓ Gen $gen_num:${NC} first generation (no prior link)"
        fi
    done
    
    echo ""
    if [ "$all_valid" = true ]; then
        echo -e "${GREEN}✓ Chain validation: PASSED${NC}"
        return 0
    else
        echo -e "${RED}✗ Chain validation: FAILED${NC}"
        return 1
    fi
}

# Main dispatcher
main() {
    local command=${1:-help}
    
    case "$command" in
        compute) shift; cmd_compute "$@" ;;
        verify) shift; cmd_verify "$@" ;;
        compare) shift; cmd_compare "$@" ;;
        list-all) shift; cmd_list_all "$@" ;;
        detect-changes) shift; cmd_detect_changes "$@" ;;
        validate-chain) shift; cmd_validate_chain "$@" ;;
        help|--help|-h) usage ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
