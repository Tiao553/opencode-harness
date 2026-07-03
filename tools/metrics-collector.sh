#!/bin/bash
# metrics-collector.sh — Performance metrics collection tool
# Collects execution metrics from Ralph Loop traces

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
METRICS_DIR="${PROJECT_ROOT}/.specs/changes/waves-7-17-implementation/metrics"
TRACES_DIR="${PROJECT_ROOT}/.specs/changes/waves-7-17-implementation/traces"
LEDGER="${PROJECT_ROOT}/.specs/changes/waves-7-17-implementation/03-metrics-ledger.md"

# Ensure metrics directory exists
mkdir -p "$METRICS_DIR"

# Initialize ledger if needed
if [[ ! -f "$LEDGER" ]]; then
    echo "# Metrics Collection Ledger" > "$LEDGER"
    echo "" >> "$LEDGER"
fi

cmd_collect() {
    local trace_id="${1:-}"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    if [[ -z "$trace_id" ]]; then
        # Collect from all traces
        for trace_file in "$TRACES_DIR"/*.yaml; do
            if [[ -f "$trace_file" ]]; then
                _collect_one "$trace_file" "$timestamp"
            fi
        done
    else
        # Collect from specific trace
        local trace_file="$TRACES_DIR/$trace_id.yaml"
        if [[ ! -f "$trace_file" ]]; then
            echo "Error: Trace not found: $trace_id" >&2
            return 1
        fi
        _collect_one "$trace_file" "$timestamp"
    fi
}

_collect_one() {
    local trace_file="$1"
    local timestamp="$2"

    # Extract session_id
    local session_id=$(grep '^ *session_id:' "$trace_file" | head -1 | sed 's/.*: "//' | sed 's/".*//')
    if [[ -z "$session_id" ]]; then
        return 0
    fi

    # Count decisions
    local total_decisions=$(grep -c '^ *- decision_id:' "$trace_file" || echo 0)
    local passed=$(grep -c 'verdict: "PASS"' "$trace_file" || echo 0)
    local failed=$(grep -c 'verdict: "FAIL"' "$trace_file" || echo 0)
    local blocked=$(grep -c 'verdict: "BLOCKED"' "$trace_file" || echo 0)

    # Extract timestamps
    local first_start=$(grep '^ *timestamp_start:' "$trace_file" | head -1 | sed 's/.*: "//' | sed 's/".*//')
    local last_end=$(grep '^ *timestamp_end:' "$trace_file" | tail -1 | sed 's/.*: "//' | sed 's/".*//')

    # Calculate total time (simple: just count seconds)
    local start_secs=$(date -d "$first_start" +%s 2>/dev/null || echo 0)
    local end_secs=$(date -d "$last_end" +%s 2>/dev/null || echo 0)
    local total_time_ms=$(( (end_secs - start_secs) * 1000 ))

    # Calculate pass rate
    local pass_rate=0
    if [[ $total_decisions -gt 0 ]]; then
        pass_rate=$((passed * 100 / total_decisions))
    fi

    # Estimate tokens
    local estimated_tokens=$((total_decisions / 2 + 2))

    # Write metrics file
    local metrics_file="$METRICS_DIR/sess-$session_id.yaml"
    if [[ ! -f "$metrics_file" ]] && [[ "$session_id" =~ ^sess- ]]; then
        session_id="${session_id#sess-}"
        metrics_file="$METRICS_DIR/sess-$session_id.yaml"
    fi
    cat > "$metrics_file" << EOF
metrics_entry:
  session_id: "$session_id"
  collected_at: "$timestamp"
  source: "trace"
  execution_metrics:
    total_execution_time_ms: $total_time_ms
  token_metrics:
    estimated_total_tokens: $estimated_tokens
    confidence: "low"
  decision_latencies:
    min_latency_ms: 0
    max_latency_ms: 0
  quality_metrics:
    total_decisions: $total_decisions
    passed_decisions: $passed
    failed_decisions: $failed
    blocked_decisions: $blocked
    pass_rate: $pass_rate
  metadata:
    change_id: "waves-7-17-implementation"
    collection_agent: "altitude-report"
    trace_file: "$(basename "$trace_file")"
EOF

    # Append to ledger
    {
        echo "- session_id: $session_id"
        echo "  collected_at: $timestamp"
        echo "  total_decisions: $total_decisions"
        echo "  execution_time_ms: $total_time_ms"
        echo "  pass_rate: ${pass_rate}%"
        echo ""
    } >> "$LEDGER"

    echo "✓ Collected metrics from $(basename "$trace_file") (session: $session_id)"
}

cmd_report() {
    local session_id="${1:-}"

    if [[ -z "$session_id" ]]; then
        _report_all
    else
        _report_one "$session_id"
    fi
}

_report_all() {
    local total_decisions=0
    local session_count=0
    local total_time=0

    echo "# Performance Metrics Summary Report"
    echo ""
    echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""

    # Count metrics
    local found_any=false
    if [[ -d "$METRICS_DIR" ]]; then
        for metrics_file in "$METRICS_DIR"/sess-*.yaml; do
            [[ -f "$metrics_file" ]] || continue
            found_any=true

            local sid=$(grep "session_id:" "$metrics_file" | head -1 | sed 's/.*: "//' | sed 's/".*//')
            local exec_time=$(grep "total_execution_time_ms:" "$metrics_file" | sed 's/.*: //')
            local decisions=$(grep "total_decisions:" "$metrics_file" | sed 's/.*: //')
            local pass_rate=$(grep "pass_rate:" "$metrics_file" | sed 's/.*: //')

            total_decisions=$((total_decisions + decisions))
            total_time=$((total_time + exec_time))
            ((session_count++)) || true
        done
    fi

    if [[ "$found_any" == false ]]; then
        echo "No metrics collected yet."
        return 0
    fi

    echo "## Summary"
    echo ""
    echo "| Sessions | Decisions | Total Time (ms) | Pass Rate |"
    echo "|----------|-----------|-----------------|-----------|"
    echo "| $session_count | $total_decisions | $total_time | — |"
    echo ""
    echo "## Details"
    echo ""
    echo "| Session | Decisions | execution_time (ms) | Pass Rate |"
    echo "|---------|-----------|---------------------|-----------|"

    if [[ -d "$METRICS_DIR" ]]; then
        for metrics_file in "$METRICS_DIR"/sess-*.yaml; do
            [[ -f "$metrics_file" ]] || continue

            local sid=$(grep "session_id:" "$metrics_file" | head -1 | sed 's/.*: "//' | sed 's/".*//')
            local exec_time=$(grep "total_execution_time_ms:" "$metrics_file" | sed 's/.*: //')
            local decisions=$(grep "total_decisions:" "$metrics_file" | sed 's/.*: //')
            local pass_rate=$(grep "pass_rate:" "$metrics_file" | sed 's/.*: //')

            echo "| $sid | $decisions | $exec_time | $pass_rate% |"
        done
    fi
}

_report_one() {
    local session_id="$1"
    local metrics_file="$METRICS_DIR/sess-$session_id.yaml"
    if [[ ! -f "$metrics_file" ]] && [[ "$session_id" =~ ^sess- ]]; then
        session_id="${session_id#sess-}"
        metrics_file="$METRICS_DIR/sess-$session_id.yaml"
    fi

    if [[ ! -f "$metrics_file" ]]; then
        echo "Error: Metrics not found for session: $session_id" >&2
        return 1
    fi

    local sid=$(grep "session_id:" "$metrics_file" | sed 's/.*: "//' | sed 's/".*//')
    local exec_time=$(grep "total_execution_time_ms:" "$metrics_file" | sed 's/.*: //')
    local decisions=$(grep "total_decisions:" "$metrics_file" | sed 's/.*: //')
    local passed=$(grep "passed_decisions:" "$metrics_file" | sed 's/.*: //')
    local failed=$(grep "failed_decisions:" "$metrics_file" | sed 's/.*: //')
    local pass_rate=$(grep "pass_rate:" "$metrics_file" | sed 's/.*: //')
    local min_lat=$(grep "min_latency_ms:" "$metrics_file" | sed 's/.*: //')
    local max_lat=$(grep "max_latency_ms:" "$metrics_file" | sed 's/.*: //')

    echo "# Performance Metrics Report"
    echo ""
    echo "**Session:** $sid"
    echo "**Execution Time:** ${exec_time} ms"
    echo ""
    echo "## Decision Quality"
    echo ""
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| Total Decisions | $decisions |"
    echo "| Passed | $passed |"
    echo "| Failed | $failed |"
    echo "| Pass Rate | ${pass_rate}% |"
    echo ""
    echo "## Latency Statistics"
    echo ""
    echo "| Metric | Value (ms) |"
    echo "|--------|-----------|"
    echo "| Minimum | $min_lat |"
    echo "| Maximum | $max_lat |"
}

main() {
    local command="${1:-}"

    case "$command" in
        collect)
            shift || true
            # Parse optional --trace-id argument
            if [[ "${1:-}" == "--trace-id" ]]; then
                cmd_collect "${2:-}"
            else
                cmd_collect "${1:-}"
            fi
            ;;
        report)
            shift || true
            cmd_report "${1:-}"
            ;;
        *)
            echo "Usage: metrics-collector.sh <command> [options]"
            echo "Commands: collect, report"
            exit 1
            ;;
    esac
}

main "$@"
