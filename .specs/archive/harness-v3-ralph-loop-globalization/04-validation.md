# Validation

## Validation V-001

- Task: RLG-001
- Verdict: validated
- Validation method: Ralph Loop marker validator, fixture validator, grounding link resolver, marker grep
- Scope check: passed
- Evidence check: passed

## Commands

```text
rtk proxy python3 - <<'PY' ...
rtk proxy bash test/fixtures/harness-v3/validate-fixtures.sh
rtk proxy python3 - <<'PY' ...
rtk grep 'Loop Postures|Runtime Tool Rule|Ralph Loop Policy|loop_posture|\[loop:mandatory\]' ...
```

## Results

- Loop posture is explicit.
- Runtime `verify_step` use versus manual fallback is explicit.
- Task contracts require loop posture.
- Todos can project mandatory loop posture.
- Coordinator contract owns loop classification and failure behavior.
