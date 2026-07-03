#!/bin/bash
# tools/artifact-timeline.sh
# Query artifact generation history and timelines

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: artifact-timeline.sh <command> [options]

Commands:
  timeline <change_id> <artifact_slug>           Show all versions of artifact
  validation-runs <change_id>                    Show all validation runs + scores
  changed <change_id> <run_1> <run_2>           Show what changed between validation runs
  freshness <change_id>                          Show which artifacts are fresh/stale
  artifacts-at <change_id> <run_id>             Show artifacts analyzed in specific run
  integrity <change_id>                          Validate entire registry
  report <change_id>                             Full registry report
  help                                           Show this help message

Examples:
  artifact-timeline.sh timeline wave-4-artifact-versioning prd
  artifact-timeline.sh validation-runs wave-4-artifact-versioning
  artifact-timeline.sh changed wave-4-artifact-versioning validation-run-20260629-001 validation-run-20260629-002
  artifact-timeline.sh freshness wave-4-artifact-versioning
  artifact-timeline.sh artifacts-at wave-4-artifact-versioning validation-run-20260629-001
  artifact-timeline.sh integrity wave-4-artifact-versioning
  artifact-timeline.sh report wave-4-artifact-versioning

EOF
}

get_registry() {
    local change_id=$1
    local registry=".specs/changes/$change_id/artifact-generation-registry.yaml"

    if [ ! -f "$registry" ]; then
        echo -e "${RED}✗ Registry not found: $registry${NC}" >&2
        exit 1
    fi

    echo "$registry"
}

# Command: timeline
cmd_timeline() {
    local change_id=$1
    local artifact_slug=$2

    if [ -z "$change_id" ] || [ -z "$artifact_slug" ]; then
        echo "Error: change_id and artifact_slug required"
        return 1
    fi

    local registry=$(get_registry "$change_id")

    echo -e "${BLUE}Timeline for $artifact_slug:${NC}"
    echo ""

    yq ".artifact_generations.$artifact_slug.generations[] | {
        gen: .generation_number,
        timestamp: .generated_at,
        status: .status,
        checksum: .checksum | .[0:12] + \"...\"
    }" "$registry" | \
    yq -C 'to_entries | map("\(.key + 1). Gen \(.value.gen): \(.value.timestamp) [\(.value.status)] \(.value.checksum)")' | \
    jq -r '.[]'
}

# Command: validation-runs
cmd_validation_runs() {
    local change_id=$1

    if [ -z "$change_id" ]; then
        echo "Error: change_id required"
        return 1
    fi

    local registry=$(get_registry "$change_id")

    echo -e "${BLUE}Validation runs in $change_id:${NC}"
    echo ""

    yq ".artifact_generations.validation_report.generations[] | {
        run: .junta_run_id,
        score: .score,
        status: .status,
        timestamp: .generated_at
    }" "$registry" | \
    yq -C 'to_entries | map("
  Run \(.key + 1):
    ID:        \(.value.run)
    Score:     \(.value.score)/100
    Status:    \(.value.status)
    Timestamp: \(.value.timestamp)
  ")' | jq -r '.[]'
}

# Command: changed
cmd_changed() {
    local change_id=$1
    local run1=$2
    local run2=$3

    if [ -z "$change_id" ] || [ -z "$run1" ] || [ -z "$run2" ]; then
        echo "Error: change_id, run_1, and run_2 required"
        return 1
    fi

    local registry=$(get_registry "$change_id")

    echo -e "${BLUE}Artifacts changed between validation runs:${NC}"
    echo "  From: $run1"
    echo "  To:   $run2"
    echo ""

    # Get artifacts from run 1
    local run1_artifacts=$(yq ".artifact_generations.validation_report.generations[] | select(.junta_run_id == \"$run1\") | .artifacts_analyzed[].artifact_slug" "$registry")

    if [ -z "$run1_artifacts" ]; then
        echo -e "${RED}✗ Validation run not found: $run1${NC}"
        return 1
    fi

    local has_changes=false

    for artifact in $run1_artifacts; do
        local checksum_run1=$(yq ".artifact_generations.validation_report.generations[] | select(.junta_run_id == \"$run1\") | .artifacts_analyzed[] | select(.artifact_slug == \"$artifact\") | .checksum | .[0:12] + \"...\"" "$registry")
        local checksum_run2=$(yq ".artifact_generations.validation_report.generations[] | select(.junta_run_id == \"$run2\") | .artifacts_analyzed[] | select(.artifact_slug == \"$artifact\") | .checksum | .[0:12] + \"...\"" "$registry")

        if [ "$checksum_run1" == "$checksum_run2" ]; then
            echo -e "  ${GREEN}✓${NC} $artifact: ${GREEN}unchanged${NC}"
        else
            echo -e "  ${RED}✗${NC} $artifact: ${YELLOW}changed${NC}"
            echo "    $checksum_run1 → $checksum_run2"
            has_changes=true
        fi
    done

    echo ""
    if [ "$has_changes" = true ]; then
        echo -e "${YELLOW}Summary: Some artifacts changed between runs${NC}"
    else
        echo -e "${GREEN}Summary: No artifacts changed between runs${NC}"
    fi
}

# Command: freshness
cmd_freshness() {
    local change_id=$1

    if [ -z "$change_id" ]; then
        echo "Error: change_id required"
        return 1
    fi

    local registry=$(get_registry "$change_id")

    echo -e "${BLUE}Artifact freshness in $change_id:${NC}"
    echo ""

    local now=$(date +%s)
    local one_day=$((24 * 60 * 60))

    yq ".artifact_generations | to_entries[] | {
        artifact: .key,
        last_updated: .value.generations[-1].generated_at,
        age_seconds: (now - (.value.generations[-1].generated_at | fromdateiso8601))
    }" "$registry" | \
    yq -C ".[] |
        if .age_seconds < $one_day then
            \"  ${GREEN}✓${NC} \(.artifact): ${GREEN}fresh${NC} (last: \(.last_updated))\"
        else
            \"  ${YELLOW}⚠${NC} \(.artifact): ${YELLOW}stale${NC} (last: \(.last_updated))\"
        end" | jq -r '.'
}

# Command: artifacts-at
cmd_artifacts_at() {
    local change_id=$1
    local run_id=$2

    if [ -z "$change_id" ] || [ -z "$run_id" ]; then
        echo "Error: change_id and run_id required"
        return 1
    fi

    local registry=$(get_registry "$change_id")

    echo -e "${BLUE}Artifacts analyzed in validation run: $run_id${NC}"
    echo ""

    yq ".artifact_generations.validation_report.generations[] |
        select(.junta_run_id == \"$run_id\") |
        .artifacts_analyzed[] |
        {artifact: .artifact_slug, checksum: .checksum | .[0:12] + \"...\"}" "$registry" | \
    yq -C 'to_entries | map("  \(.key + 1). \(.value.artifact): \(.value.checksum)")' | \
    jq -r '.[]'
}

# Command: integrity
cmd_integrity() {
    local change_id=$1

    if [ -z "$change_id" ]; then
        echo "Error: change_id required"
        return 1
    fi

    local registry=$(get_registry "$change_id")

    echo -e "${BLUE}Registry integrity check for $change_id:${NC}"
    echo ""

    local all_valid=true

    # Check each artifact's prior_generation_checksum chain
    local artifacts=$(yq '.artifact_generations | keys[]' "$registry")

    for artifact in $artifacts; do
        local gens=$(yq ".artifact_generations.$artifact.generations | length" "$registry")

        for ((i=0; i<gens; i++)); do
            local gen_num=$(yq ".artifact_generations.$artifact.generations[$i].generation_number" "$registry")
            local prior=$(yq ".artifact_generations.$artifact.generations[$i].prior_generation_checksum" "$registry")

            if [ "$gen_num" -gt 1 ]; then
                local prior_checksum=$(yq ".artifact_generations.$artifact.generations[$((i-1))].checksum" "$registry")

                if [ "$prior" == "$prior_checksum" ] || [ "$prior" == "null" ]; then
                    echo -e "${GREEN}✓${NC} $artifact gen $gen_num: chain valid"
                else
                    echo -e "${RED}✗${NC} $artifact gen $gen_num: chain broken!"
                    all_valid=false
                fi
            fi
        done
    done

    echo ""
    if [ "$all_valid" = true ]; then
        echo -e "${GREEN}✓ Integrity check: PASSED${NC}"
    else
        echo -e "${RED}✗ Integrity check: FAILED${NC}"
    fi
}

# Command: report
cmd_report() {
    local change_id=$1

    if [ -z "$change_id" ]; then
        echo "Error: change_id required"
        return 1
    fi

    local registry=$(get_registry "$change_id")

    echo -e "${BLUE}=== Full Registry Report: $change_id ===${NC}"
    echo ""

    local total=$(yq '.total_artifacts_tracked' "$registry")
    local created=$(yq '.created_at' "$registry")
    local updated=$(yq '.last_updated_at' "$registry")

    echo -e "${YELLOW}Metadata:${NC}"
    echo "  Total artifacts: $total"
    echo "  Created:        $created"
    echo "  Last updated:   $updated"
    echo ""

    echo -e "${YELLOW}Artifacts:${NC}"
    yq ".artifact_generations | to_entries[] | {
        name: .key,
        type: .value.artifact_type,
        generations: .value.generation_count
    }" "$registry" | \
    yq -C 'to_entries | map("  \(.key + 1). \(.value.name) (\(.value.type)): \(.value.generations) generations")' | \
    jq -r '.[]'

    echo ""
    echo -e "${YELLOW}Recent validations:${NC}"
    yq ".artifact_generations.validation_report.generations[-3:] | .[] | {
        run: .junta_run_id,
        score: .score,
        status: .status
    }" "$registry" | \
    yq -C 'to_entries | map("  \(.key + 1). \(.value.run): \(.value.score)/100 [\(.value.status)]")' | \
    jq -r '.[]'
}

# Main dispatcher
main() {
    local command=${1:-help}

    case "$command" in
        timeline) shift; cmd_timeline "$@" ;;
        validation-runs) shift; cmd_validation_runs "$@" ;;
        changed) shift; cmd_changed "$@" ;;
        freshness) shift; cmd_freshness "$@" ;;
        artifacts-at) shift; cmd_artifacts_at "$@" ;;
        integrity) shift; cmd_integrity "$@" ;;
        report) shift; cmd_report "$@" ;;
        help|--help|-h) usage ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
