# Judge Setup

This file documents the minimum local setup required by the external judge flow used by `/review:judge`.

## Purpose

The judge flow is advisory. It shells out to an external runtime and must not fabricate verdicts when the runtime is unavailable.

## Required environment

```bash
export OPENROUTER_API_KEY=sk-or-v1-...
```

Optional:

```bash
export JUDGE_MODEL=openai/gpt-4o-mini
export JUDGE_BUDGET=10
```

## Runtime contract

The repo assumes a `judge-runner` executable is available on `PATH`.

Minimum behavior:

- Accept the arguments passed by `/review:judge`
- Read the target file
- Call the external judge model
- Return a structured verdict or a clear runtime/config failure

## Verification

Check that the runtime is installed:

```bash
command -v judge-runner
```

Check that the API key is present:

```bash
test -n "$OPENROUTER_API_KEY" && echo "OPENROUTER_API_KEY set"
```

## Failure handling

If either prerequisite is missing:

- stop the judge flow
- report the missing prerequisite
- do not invent a second-opinion verdict

## Notes

- This setup file documents the contract only; it does not bundle the external runtime.
- Ledger writes are expected to go to `~/.config/opencode/storage/judge-ledger.jsonl`.
