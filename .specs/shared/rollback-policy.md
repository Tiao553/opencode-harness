# Rollback Policy

Every executable task must include rollback notes.

## Required Fields

- changed files
- rollback command or manual reversal note
- risk if rollback fails
- verification after rollback

## Validation Checks

`altitude-validation` must check:

- diff matches allowed files
- no extra files were changed
- no unrequested refactor occurred
- no contract changed without a decision record
