---
id: W10-METRICS
title: "Wave 10: Performance Metrics Collection"
status: implemented
effort: M
budget: 48000
agent: altitude-report
severity: feature
depends_on: [W7-RALPH-LOOP]
touches_paths:
  - .specs/shared/metrics-contract.md
  - tools/metrics-collector.sh
  - tools/metrics-collector.contract.md
  - agents/altitude-report.agent.md
  - test/fixtures/harness-v3/wave-10-metrics-smoke.fixture.md
---

# Wave 10: Performance Metrics Collection

## Goal

Measure execution performance (wall-clock, tokens, latency):
- ✅ Collect metrics from Ralph Loop traces (Wave 7)
- ✅ Estimate token usage per phase
- ✅ Capture decision latency
- ✅ Generate metrics report in altitude-report
- ✅ 2 smoke scenarios (collect, report)

## Success Criteria

```bash
eval_1() { grep -q "measurement_schema:" .specs/shared/metrics-contract.md; }
eval_2() { tools/metrics-collector.sh collect > /dev/null 2>&1 && tools/metrics-collector.sh report | grep -q "execution_time"; }
eval_3() { grep -q "metrics-collector" agents/altitude-report.agent.md; }
eval_4() { bash test/fixtures/harness-v3/wave-10-metrics-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```

## Anti-Patterns
❌ **Don't** measure wall-clock without NTP sync
❌ **Don't** estimate tokens without LLM-specific token counters
❌ **Don't** log metrics to stdout (metrics file only)
