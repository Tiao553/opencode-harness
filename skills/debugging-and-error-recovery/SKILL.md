---
name: debugging-and-error-recovery
description: Reproduce, isolate, instrument, fix, and verify failures without guesswork. Use when diagnosing bugs, flaky behavior, or broken pipelines.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: lifecycle
---

# Debugging And Error Recovery

## When to Use

- Use when behavior is failing, flaky, slow, or unexpectedly blocked.
- Use when a build or specialist agent needs a reusable incident workflow.
- Do not use when there is no bug signal, reproduction path, or failure evidence.

## Workflow

1. Capture the failure signal exactly: error, stack trace, bad output, or missing state.
2. Reproduce the problem with the smallest reliable path.
3. Isolate one likely boundary at a time: input, state, dependency, environment, or code path.
4. Add only the minimum instrumentation needed to explain the failure.
5. Fix the root cause, not the symptom.
6. Re-run the reproduction path and one nearby regression path.
7. Remove temporary debugging noise if it is no longer needed.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "I already know the cause." | Debugging by intuition skips evidence and creates false fixes. |
| "I'll add broad logging everywhere." | Excess instrumentation adds noise and hides the real boundary. |
| "The symptom is gone, so the bug is fixed." | A non-reproduced symptom is not the same as a verified root-cause fix. |

## Red Flags

- No reproduction path exists.
- The proposed fix does not explain the observed failure.
- Instrumentation is wider than the suspected boundary.
- Verification only covers the original failing path and nothing adjacent.

## Verification

- [ ] The failure signal was captured explicitly.
- [ ] A minimal reproduction path was identified.
- [ ] The fix explains the root cause.
- [ ] The failing path was re-tested after the fix.
- [ ] One adjacent regression path was also checked.
