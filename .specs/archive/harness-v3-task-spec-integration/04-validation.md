# Validation

## Validation V-001

- Task: TSI-001
- Verdict: validated
- Validation method: Task-Spec bridge marker validator, fixture validator, grounding link resolver, template frontmatter inspection
- Scope check: passed
- Evidence check: passed

## Commands

```text
rtk proxy python3 - <<'PY' ...
rtk proxy bash test/fixtures/harness-v3/validate-fixtures.sh
rtk proxy python3 - <<'PY' ...
rtk proxy sed -n '1,38p' skills/task-spec/templates/task-spec.md.tpl
```

## Results

- Integration contract exists.
- Task-Spec template includes additive Harness V3 bridge fields.
- Generator tells authors to fill Harness V3 bridge context when generated from Harness V3.
- Fixture 10 remains valid in the golden fixture suite.
