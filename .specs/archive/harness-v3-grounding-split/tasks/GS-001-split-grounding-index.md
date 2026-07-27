# GS-001 - Split Grounding Index

task_id: GS-001
status: validated
change: harness-v3-grounding-split
owner_agent: altitude-execution
slice_type: policy-split
effort_class: S

## Objective

Make `config/grounding.md` a thin index over shared contracts.

## Source References

- `docs/HARNESS_V3_REFACTOR_ROADMAP.md`
- `.specs/shared/runtime-policy.md`
- `.specs/shared/context-loading-policy.md`
- `.specs/shared/state-resolution-contract.md`
- `.specs/shared/phase-engine-contract.md`
- `.specs/shared/execution-loop-contract.md`
- `.specs/shared/documentation-mode-policy.md`
- `.specs/shared/production-code-mode-policy.md`
- `.specs/shared/compatibility-policy.md`

## Allowed Files

- `config/grounding.md`
- `.specs/changes/harness-v3-grounding-split/03-execution-ledger.md`
- `.specs/changes/harness-v3-grounding-split/04-validation.md`
- `.specs/changes/harness-v3-grounding-split/state.md`
- `.specs/changes/harness-v3-grounding-split/tasks/GS-001-split-grounding-index.md`
- `.specs/changes/harness-v3-grounding-split/evidence/E-001-grounding-split.md`
- `.specs/memory/active-state.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`

## Forbidden Scope

- runtime plugin edits
- command removals
- route changes
- agent prompt rewrites

## Acceptance Criteria

| ID | Criterion | Verification |
| --- | --- | --- |
| AC-001 | `config/grounding.md` is a thin index | manual review |
| AC-002 | every referenced shared contract exists | link/path check |
| AC-003 | legacy workflow references are compatibility-only | grep/manual review |
| AC-004 | docs mode and code mode are separated | referenced separate policy files |

## Verification Commands

```bash
for path in $(grep -oE '\.specs/shared/[A-Za-z0-9._/-]+\.md' config/grounding.md | sort -u); do test -f "$path"; done
grep -n '^## ' config/grounding.md
```

## Rollback

Restore the previous `config/grounding.md` content if the index loses required policy coverage.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Grounding index updated
- [x] Contract path check passed
- [x] Evidence recorded
- [x] Validation recorded
