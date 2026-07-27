# Validation

## Validation V-001

- Task: DM-001
- Verdict: validated
- Validation method: delegation marker validator, fixture validator, grounding link resolver, marker grep
- Scope check: passed
- Evidence check: passed

## Commands

```text
rtk proxy python3 - <<'PY' ...
rtk proxy bash test/fixtures/harness-v3/validate-fixtures.sh
rtk proxy python3 - <<'PY' ...
rtk grep 'Grounding Bundle|Evidence Contract|Over-Delegation|hidden owners|hidden task owners|must be allocated before execution' ...
```

## Results

- Specialist allocation now requires a grounding bundle and evidence contract.
- Local/task allocation now blocks late unsupported specialist use.
- Coordinator guidance prevents hidden ownership.
- Standard V3 fixture and grounding gates still pass.
