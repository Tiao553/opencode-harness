# Performance Metrics Collection Contract

**Version:** 1.0  
**Status:** Authoritative  
**Date:** 2026-06-29  
**Wave:** Wave 10 (Metrics Collection)

---

## Contract Specification

```yaml
measurement_schema:
  execution_time_ms: integer           # Wall-clock duration in milliseconds
  token_estimate: integer              # Advisory token count (not exact)
  decision_latency_ms: integer         # Latency of individual decision
  phase_name: string                   # Intent | Structure | Design | Execution | Validate | Ship
  session_id: string                   # Ralph Loop trace session ID
  trace_count: integer                 # Number of decisions in trace
  timestamp: ISO-8601                  # When metrics were collected

aggregation_rules:
  - per_decision: Calculate execution_time_ms from timestamp_start/timestamp_end
  - per_session: Sum all decision times; capture session total_steps
  - per_phase: Group decisions by metadata.phase; aggregate time and token estimates
  - token_estimate: Advisory only (0.5K per major decision + overhead)
  - latency: Time to first decision verdict

storage:
  primary: ".specs/changes/<change-id>/metrics/<session-id>.yaml"
  ledger: ".specs/changes/<change-id>/03-metrics-ledger.md"
  archive: ".specs/changes/<change-id>/metrics/archive/<date>-report.md"

retention:
  keep_raw_traces: 30 days
  keep_reports: 90 days
  archive_frequency: daily
```

---

## Purpose

This contract defines performance metrics collection for Harness V3 execution traces (Ralph Loop integration).

It specifies:
- **measurement_schema:** Structure and naming of metrics
- **per_phase_metrics:** How to aggregate metrics by phase
- **aggregation_rules:** Formulas for calculating metrics from traces
- **collection_strategy:** When and how to measure
- **reporting_strategy:** How to present metrics

---

## 1. Measurement Schema

### Core Metrics Entry

Each metrics collection produces one entry:

```yaml
metrics_entry:
  session_id: "sess-<timestamp>-<user>-<hash>"        # From trace
  collected_at: "<ISO-8601>"                          # When collected
  source: "trace" | "live"                            # Trace or live measurement
  
  execution_metrics:
    total_execution_time_ms: <integer>                # Total session time
    phase_breakdown:
      - phase: "Intent"
        duration_ms: <integer>
        decision_count: <integer>
        avg_decision_latency_ms: <float>
      - phase: "Structure"
        duration_ms: <integer>
        decision_count: <integer>
        avg_decision_latency_ms: <float>
      - phase: "Design"
        duration_ms: <integer>
        decision_count: <integer>
        avg_decision_latency_ms: <float>
      - phase: "Execution"
        duration_ms: <integer>
        decision_count: <integer>
        avg_decision_latency_ms: <float>
      - phase: "Validate"
        duration_ms: <integer>
        decision_count: <integer>
        avg_decision_latency_ms: <float>
      - phase: "Ship"
        duration_ms: <integer>
        decision_count: <integer>
        avg_decision_latency_ms: <float>
  
  token_metrics:
    estimated_total_tokens: <integer>                 # Advisory estimate
    estimated_tokens_per_phase:
      Intent: <integer>
      Structure: <integer>
      Design: <integer>
      Execution: <integer>
      Validate: <integer>
      Ship: <integer>
    estimation_method: "advisory-per-decision"
    confidence: "low"                                  # Always low for estimates
  
  decision_latencies:
    min_latency_ms: <integer>
    max_latency_ms: <integer>
    mean_latency_ms: <float>
    median_latency_ms: <float>
    p95_latency_ms: <float>
  
  quality_metrics:
    total_decisions: <integer>
    passed_decisions: <integer>
    failed_decisions: <integer>
    blocked_decisions: <integer>
    pass_rate: <float>                                 # % of passed decisions
  
  metadata:
    change_id: "<string>"
    task_ids: ["<task-1>", "<task-2>"]
    agent_names: ["<agent-1>", "<agent-2>"]
    source_trace_checksum: "<SHA-256>"
    collection_agent: "<agent-name>"
```

### Aggregated Session Report

```yaml
metrics_report:
  report_id: "report-<date>-<session-id>"
  generated_at: "<ISO-8601>"
  
  summary:
    sessions_analyzed: <integer>
    total_execution_time_ms: <integer>
    average_execution_time_ms: <float>
    total_decisions: <integer>
    average_decisions_per_session: <float>
    estimated_total_tokens: <integer>
    pass_rate: <float>
  
  phase_summary:
    - phase: "Intent"
      total_sessions: <integer>
      total_time_ms: <integer>
      avg_time_ms: <float>
      total_decisions: <integer>
      avg_latency_ms: <float>
    - phase: "Structure"
      ...
    - phase: "Design"
      ...
    - phase: "Execution"
      ...
    - phase: "Validate"
      ...
    - phase: "Ship"
      ...
  
  bottleneck_analysis:
    slowest_phase: "<phase-name>"
    slowest_phase_time_ms: <integer>
    fastest_phase: "<phase-name>"
    fastest_phase_time_ms: <integer>
  
  trend_data:
    previous_report_id: "<report-id>" | null
    time_trend: "improving" | "stable" | "degrading"
    decision_latency_trend: "improving" | "stable" | "degrading"
```

---

## 2. Per-Phase Metrics

Each phase should track:

```
Phase → Total Time (ms) → Decision Count → Avg Latency → Token Estimate
```

| Phase | Duration Target | Typical Decisions | Token Estimate |
|-------|-----------------|-------------------|----------------|
| Intent | 500–2000 ms | 2–5 | 1-2K |
| Structure | 1000–5000 ms | 5–10 | 2-4K |
| Design | 3000–15000 ms | 10–20 | 5-10K |
| Execution | 5000–60000 ms | 20–100 | 10-50K |
| Validate | 2000–10000 ms | 5–15 | 3-8K |
| Ship | 500–2000 ms | 2–5 | 1-2K |

---

## 3. Aggregation Rules

### Per-Decision Metrics

```bash
# Calculate execution time for a single decision
execution_time_ms = timestamp_end - timestamp_start (converted to ms)

# Decision latency = same as execution_time_ms for this decision
decision_latency_ms = execution_time_ms

# Token estimate for one decision
token_estimate = (execution_time_ms / 1000) * 0.5K base + complexity_factor
  where complexity_factor = "high" (2K) | "medium" (1K) | "low" (0.5K)
```

### Per-Session Aggregation

```bash
# Total execution time
total_execution_time_ms = SUM(all decision execution_time_ms)

# Average decision latency
avg_decision_latency_ms = MEAN(all decision execution_time_ms)

# Token estimate (advisory)
total_token_estimate = SUM(all decision token_estimates)

# Decision counts
passed = COUNT(verdict == PASS)
failed = COUNT(verdict == FAIL)
blocked = COUNT(verdict == BLOCKED)
pass_rate = (passed / total) * 100
```

### Per-Phase Aggregation

```bash
# Group decisions by metadata.phase

for each phase in [Intent, Structure, Design, Execution, Validate, Ship]:
  phase_time_ms = SUM(execution_time_ms for decisions in phase)
  phase_decisions = COUNT(decisions in phase)
  phase_avg_latency = MEAN(execution_time_ms for decisions in phase)
  phase_token_estimate = SUM(token_estimates for decisions in phase)
```

### Percentile Calculations

```bash
# For latency percentiles
p95_latency_ms = PERCENTILE(all decision latencies, 95)
median_latency_ms = PERCENTILE(all decision latencies, 50)
```

---

## 4. Collection Strategy

### When to Collect

- After each completed session (end of phase)
- After each completed task (batch metrics)
- On-demand via `metrics-collector.sh collect` command
- Stored in trace file; ledger entries created per session

### What to Collect

- All timestamps from trace session
- All decision_id, verdict, phase metadata
- Calculate derived metrics (latency, totals)
- Estimate tokens (advisory, low confidence)

### What NOT to Collect

- ❌ Raw LLM token counts (not available; estimates only)
- ❌ Memory usage (out of scope)
- ❌ Network latency (not measured)
- ❌ Filesystem I/O separately (included in execution time)

---

## 5. Reporting Strategy

### Human-Readable Report

```markdown
# Performance Metrics Report

**Session ID:** sess-2026-06-29-user-hash  
**Collected At:** 2026-06-29T23:05:00Z  
**Total Execution Time:** 42,500 ms (42.5 sec)

## Phase Breakdown

| Phase | Time (ms) | Decisions | Avg Latency (ms) | Token Est. |
|-------|-----------|-----------|------------------|-----------|
| Intent | 1,200 | 3 | 400 | 2K |
| Structure | 3,500 | 8 | 438 | 4K |
| Design | 15,000 | 25 | 600 | 12K |
| Execution | 18,000 | 40 | 450 | 20K |
| Validate | 4,300 | 10 | 430 | 4K |
| Ship | 800 | 2 | 400 | 1K |

**Total:** 42,800 ms | 88 decisions | 486 ms avg latency | ~43K tokens

## Decision Quality

- Passed: 86 (97.7%)
- Failed: 2 (2.3%)
- Blocked: 0 (0.0%)

## Bottleneck Analysis

- Slowest phase: **Design** (15,000 ms) — 35% of total time
- Fastest phase: **Ship** (800 ms) — 1.9% of total time

## Recommendations

- Design phase consumed 35% of time; consider caching or pre-validation
- Execution phase averaged 450 ms per decision; latency acceptable
- Overall pass rate 97.7%; quality is high
```

### Machine-Readable Report

YAML format stored in `.specs/changes/<change-id>/metrics/<session-id>.yaml`

---

## 6. Tool Integration

The `metrics-collector.sh` script reads trace files and generates both machine and human-readable reports.

**Commands:**
- `metrics-collector.sh collect [--trace-id <id>]` — Collect metrics from trace(s)
- `metrics-collector.sh report [<session-id>]` — Generate human-readable report
- `metrics-collector.sh ledger <change-id>` — Append to metrics ledger

---

## 7. Constraints

- ⚠️ **Wall-clock timing:** Use bash `date` command; NTP sync recommended but not required
- ⚠️ **Token estimates:** Advisory only; use "low" confidence in reports
- ⚠️ **Log to file only:** Metrics written to trace files; no stdout logging
- ⚠️ **No PII in metrics:** Exclude sensitive data; log only aggregated metrics

---

## 8. Validation

Metrics are valid when:
- ✅ All decision timestamps exist (timestamp_start ≤ timestamp_end)
- ✅ Execution times are positive (execution_time_ms ≥ 0)
- ✅ Decision counts match phase grouping
- ✅ Pass rate is between 0–100%
- ✅ Token estimates are advisory (labeled as such)

---

## 9. Examples

### Example: Collecting Metrics from a Trace

```bash
$ metrics-collector.sh collect --trace-id test-w7
→ Collected metrics from traces/test-w7.yaml
→ Stored in metrics/sess-2026-06-29-test-w7.yaml
→ Appended to 03-metrics-ledger.md
✓ Metrics collected (4 decisions, 42.5 sec total)
```

### Example: Generating a Report

```bash
$ metrics-collector.sh report sess-2026-06-29-test-w7
→ Performance Metrics Report

Session ID: sess-2026-06-29-test-w7
Collected At: 2026-06-29T23:05:00Z
Total Execution Time: 42,500 ms

Phase Breakdown:
  Intent:     1,200 ms (3 decisions)
  Structure:  3,500 ms (8 decisions)
  Design:    15,000 ms (25 decisions)
  Execution: 18,000 ms (40 decisions)
  Validate:   4,300 ms (10 decisions)
  Ship:         800 ms (2 decisions)

Total: 42,800 ms | 88 decisions | 97.7% pass rate
```

---

## 10. Related Contracts

- **Verification Contract** (Wave 7): Trace schema, session structure
- **Artifact Versioning** (Wave 4): Checksum and timeline tracking
- **Reporting Standard** (Shared): Output formatting
