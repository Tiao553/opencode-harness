# T-000 Package Creation Evidence

## Baseline

- Repository root: `/home/ubuntu/.config/opencode`
- Branch: `main`
- Baseline commit: `d219678b66909e4c30c28f9bb64b8c75004926d9`
- Baseline status: dirty worktree preserved without modification by T-000

## Authoritative Inputs

| Input | SHA-256 |
|---|---|
| `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md` | `e4cc02bac9e9960be36164ab7343ecab3cbd66d13412bafcd81fca2a318a694a` |
| `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_BACKLOG_V2.csv` | `cad4efa7a88c290baa28b99f71aa77f50df120943eaf50fa60e4590d73b76d54` |
| `OPENCODE_HARNESS_DETERMINISTIC_AUDIT.md` | `6be50482b750511ba848cd28fdbb83aa0705626b2d522be41d3807d988d41633` |

## Package Tree

```text
.specs/changes/harness-skill-based-migration/
  allocation.yaml
  evidence/
    t-000-package-creation.md
  state.md
  tasks/
    T-000.md
```

## Scope Evidence

- User approved recording D-01 through D-18.
- User approved an isolated package.
- `.specs/memory/active-state.md` remains unchanged until T-009.
- No active runtime, agent, command, skill, plugin, tool, test, archive, or legacy surface is modified by T-000.

## Verification Result

- All five approved files exist.
- `rtk git diff --check` returned no whitespace errors.
- State records D-01 through D-18.
- The legacy global state contains no reference to `harness-skill-based-migration`.
