---
name: performance-optimization
description: Measurement-first performance workflow for queries, Spark jobs, pipelines, and runtime bottlenecks. Use when optimizing performance instead of guessing at speedups.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: lifecycle
---

# Performance Optimization

## When to Use

- Use when a task is explicitly about speed, latency, throughput, memory pressure, or cost from inefficient execution.
- Use when tuning SQL, Spark, streaming, or runtime-heavy application paths.
- Do not use when there is no baseline, no bottleneck evidence, or no measurable outcome.

## Workflow

1. Name the metric that matters: latency, runtime, throughput, memory, shuffle, scan size, or cost.
2. Capture the current baseline before changing anything.
3. Isolate the dominant bottleneck before proposing fixes.
4. Prefer one optimization at a time so impact stays attributable.
5. Re-measure after each meaningful change.
6. Keep optimizations that improve the target metric without unacceptable trade-offs.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "This pattern is usually faster." | Performance without a baseline is guesswork. |
| "We should apply all likely optimizations together." | Bundling changes makes it hard to know what actually helped. |
| "The query or job finished, so it is good enough." | Completion is not the same as acceptable performance. |

## Red Flags

- No target metric is named.
- No baseline exists before the optimization.
- Multiple unrelated tuning changes are proposed at once.
- Trade-offs are ignored after the speedup.

## Verification

- [ ] The performance metric was named.
- [ ] A baseline was captured first.
- [ ] The bottleneck was isolated before tuning.
- [ ] Changes were applied incrementally.
- [ ] The final result was re-measured.
