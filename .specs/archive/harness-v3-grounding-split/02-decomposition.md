# Harness V3 Grounding Split - Decomposition

## Task GS-001 - Split Grounding Index

status: ready

### Objective

Replace `config/grounding.md` with a thin index that delegates policy authority to `.specs/shared` contracts.

### Allowed Files

- `config/grounding.md`
- `.specs/changes/harness-v3-grounding-split/*`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `.specs/memory/active-state.md`

### Forbidden Scope

- runtime plugins
- command deletion
- agent prompt rewrites
- `opencode.json`

### Verification

- every `.specs/shared` file referenced by `config/grounding.md` exists
- `config/grounding.md` no longer contains full duplicated policy sections
- validation ledger records the split

