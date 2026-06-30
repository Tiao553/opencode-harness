# Metrics Collector Tool Contract

**Version:** 1.0  
**Status:** Authoritative  
**Date:** 2026-06-29  
**Wave:** Wave 10 (Metrics Collection)

---

## Tool Location

```
tools/metrics-collector.sh
```

---

## Purpose

Collect performance metrics from Ralph Loop traces and generate human-readable reports.

This tool reads trace files (`.specs/changes/waves-7-17-implementation/traces/*.yaml`), extracts timing data, calculates metrics, and generates reports.

---

## Commands

### `metrics-collector.sh collect [--trace-id <id>]`

Collect metrics from trace file(s).

**Inputs:**
- `--trace-id <id>` (optional): Specific trace ID to collect from (e.g., `test-w7`)
  - If omitted: Collects from all traces in `traces/` directory

**Outputs:**
- YAML metrics file: `.specs/changes/waves-7-17-implementation/metrics/sess-<session-id>.yaml`
- Appends entry to: `.specs/changes/waves-7-17-implementation/03-metrics-ledger.md`
- Logs: `✓ Collected metrics from <trace> (session: <id>)`

**Exit Code:**
- `0`: Success
- `1`: Trace file not found or parse error

**Example:**
```bash
$ tools/metrics-collector.sh collect --trace-id test-w7
✓ Collected metrics from traces/test-w7.yaml (session: sess-2026-06-29-test-w7)

$ tools/metrics-collector.sh collect
✓ Collected metrics from traces/test-w7.yaml (session: sess-2026-06-29-test-w7)
✓ Collected metrics from traces/test-w7c.yaml (session: sess-2026-06-29-test-w7c)
```

---

### `metrics-collector.sh report [<session-id>]`

Generate human-readable metrics report.

**Inputs:**
- `<session-id>` (optional): Specific session to report on (e.g., `sess-2026-06-29-test-w7`)
  - If omitted: Generates summary report across all sessions

**Outputs:**
- Markdown report to stdout (can be redirected to file)
- No file writes (report-only command)

**Exit Code:**
- `0`: Success
- `1`: Session not found

**Example:**
```bash
$ tools/metrics-collector.sh report
# Performance Metrics Summary Report

**Generated:** 2026-06-29T23:05:00Z

## Summary

| Metric | Value |
|--------|-------|
| Sessions Analyzed | 2 |
| Total Execution Time | 58 ms |
| Average Execution Time | 29 ms |
| Total Decisions | 5 |
| Average Decisions/Session | 2 |
| Overall Pass Rate | 100% |

## Sessions

| Session ID | Time (ms) | Decisions | Pass Rate |
|------------|-----------|-----------|-----------|
| sess-2026-06-29-test-w7 | 42 ms | 4 | 100% |
| sess-2026-06-29-test-w7c | 16 ms | 1 | 100% |

$ tools/metrics-collector.sh report sess-2026-06-29-test-w7
# Performance Metrics Report

**Session ID:** sess-2026-06-29-test-w7
**Total Execution Time:** 42 ms

## Summary

| Metric | Value |
|--------|-------|
| Total Decisions | 4 |
| Passed | 4 |
| Failed | 0 |
| Blocked | 0 |
| Pass Rate | 100% |
| Estimated Tokens | 2 K |

## Decision Latency

| Metric | Value (ms) |
|--------|-----------|
| Minimum | 0 |
| Maximum | 0 |
| Mean | 0 |
| Median | 0 |
| P95 | 0 |
```

---

## Metrics Collected

### Per-Decision Metrics

- **execution_time_ms:** Wall-clock duration from timestamp_start to timestamp_end
- **decision_latency_ms:** Same as execution_time_ms for the decision
- **verdict:** PASS, FAIL, or BLOCKED

### Per-Session Aggregation

- **total_execution_time_ms:** Sum of all decision times
- **total_decisions:** Count of decisions
- **passed_decisions:** Count of PASS verdicts
- **failed_decisions:** Count of FAIL verdicts
- **blocked_decisions:** Count of BLOCKED verdicts
- **pass_rate:** (passed / total) * 100

### Latency Statistics

- **min_latency_ms:** Minimum decision latency
- **max_latency_ms:** Maximum decision latency
- **mean_latency_ms:** Average decision latency
- **median_latency_ms:** Median decision latency
- **p95_latency_ms:** 95th percentile latency

### Token Estimates (Advisory)

- **estimated_total_tokens:** ~0.5K per decision + 2K overhead
- **confidence:** Always "low" (estimates are not exact)
- **estimation_method:** "advisory-per-decision"

---

## Metrics Storage

### Individual Metrics Files

**Location:** `.specs/changes/waves-7-17-implementation/metrics/sess-<session-id>.yaml`

**Format:** YAML with metrics_entry structure (see metrics-contract.md)

**Retention:** Keep for 30 days; archive to `metrics/archive/` after 30 days

### Metrics Ledger

**Location:** `.specs/changes/waves-7-17-implementation/03-metrics-ledger.md`

**Format:** Markdown with append-only entries

**Entries:**
```yaml
- session_id: <session-id>
  collected_at: <ISO-8601>
  total_decisions: <count>
  execution_time_ms: <time>
  pass_rate: <percent>%
```

---

## Dependencies

- **Ralph Loop traces:** Requires `.specs/changes/waves-7-17-implementation/traces/*.yaml` files
- **Bash:** 4.0+
- **Standard utilities:** date, awk, grep, sort
- **Wave 7:** W7-RALPH-LOOP must be complete (trace files must exist)

---

## Constraints

- ⚠️ **Wall-clock timing:** Uses `bash date` command (NTP sync recommended but not required)
- ⚠️ **Token estimates:** Advisory only; use "low" confidence
- ⚠️ **No stdout logging:** Metrics written to files only; reports sent to stdout only
- ⚠️ **No PII:** Aggregated metrics only; sensitive data excluded

---

## Error Handling

| Error | Exit Code | Recovery |
|-------|-----------|----------|
| Trace file not found | 1 | Check trace directory and session ID |
| Metrics file not found | 1 | Run `collect` first to generate metrics |
| Invalid YAML format | 1 | Verify trace file is valid YAML |
| Parse error | 1 | Check trace file structure matches schema |

---

## Examples

### Example 1: Collect from All Traces

```bash
$ cd ~/.config/opencode
$ tools/metrics-collector.sh collect
✓ Collected metrics from traces/test-w7.yaml (session: sess-2026-06-29-test-w7)
✓ Collected metrics from traces/test-w7c.yaml (session: sess-2026-06-29-test-w7c)
```

### Example 2: Collect from Specific Trace

```bash
$ tools/metrics-collector.sh collect --trace-id test-w7
✓ Collected metrics from traces/test-w7.yaml (session: sess-2026-06-29-test-w7)
```

### Example 3: Generate Summary Report

```bash
$ tools/metrics-collector.sh report
# Performance Metrics Summary Report

**Generated:** 2026-06-29T23:05:00Z

## Summary

| Metric | Value |
|--------|-------|
| Sessions Analyzed | 2 |
| Total Execution Time | 58 ms |
| Average Execution Time | 29 ms |
| Total Decisions | 5 |
| Average Decisions/Session | 2 |
| Overall Pass Rate | 100% |
```

### Example 4: Generate Session-Specific Report

```bash
$ tools/metrics-collector.sh report sess-2026-06-29-test-w7
# Performance Metrics Report

**Session ID:** sess-2026-06-29-test-w7
**Total Execution Time:** 42 ms

## Summary

| Metric | Value |
|--------|-------|
| Total Decisions | 4 |
| Passed | 4 |
| Failed | 0 |
| Blocked | 0 |
| Pass Rate | 100% |
```

### Example 5: Redirect Report to File

```bash
$ tools/metrics-collector.sh report > metrics-report.md
$ tools/metrics-collector.sh report sess-2026-06-29-test-w7 > test-w7-report.md
```

---

## Integration with Other Tools

### With verify_step (Wave 7)

- `verify_step` records traces in `.specs/changes/waves-7-17-implementation/traces/`
- `metrics-collector` reads those traces and extracts metrics

### With altitude-report (Wave 10)

- `altitude-report` calls `metrics-collector report` to include metrics in executive reports
- Metrics added to "Performance Analysis" section of reports

### With artifact-timeline (Wave 4)

- Metrics can be tracked alongside artifact versions
- Compare: "Did metrics improve after design refinement?"

---

## Testing

### Smoke Test: Collect Command

```bash
tools/metrics-collector.sh collect --trace-id test-w7 > /dev/null 2>&1
echo $?  # Should output: 0
```

### Smoke Test: Report Command

```bash
tools/metrics-collector.sh report | grep -q "execution_time"
echo $?  # Should output: 0
```

### Fixture: wave-10-metrics-smoke.fixture.md

Located in `test/fixtures/harness-v3/wave-10-metrics-smoke.fixture.md`

Runs both commands; exits 0 if both pass.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-29 | Initial release |
