# Validation

## Validation V-001

- Task: AAH-001
- Verdict: validated
- Validation method: template/allocation marker check, fixture validator, grounding link resolver
- Scope check: passed
- Evidence check: passed

## Commands

```text
rtk proxy python3 - <<'PY' ...
rtk proxy bash test/fixtures/harness-v3/validate-fixtures.sh
rtk proxy python3 - <<'PY' ...
rtk grep 'source_authority|Task-Spec Mapping|Broadening Rule|Allocation Connection' ...
```

## Results

- Official V3 templates include source authority and allocation fields.
- Allocation contracts define precedence and broadening rules.
- Golden fixtures still pass.
- Grounding links still resolve.
