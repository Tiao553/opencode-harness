# T-005 Baseline Test Result

- Primary adapter: `opencode run --format json`.
- Fallback adapter: documented manual TUI harness.
- Positive fixture: PASS. Prompt returned exactly `BASELINE_OK`; reported cost was zero.
- Negative fixture: BASELINE DEFECT. `--agent does-not-exist` emitted a warning and fell back to the default agent instead of returning a hard failure.
- Test impact: later runtime validation must assert that unknown-agent fallback is either intentionally retained and documented or replaced by a deterministic failure.
- No response content beyond the expected positive marker, secret, token, or credential was preserved.
