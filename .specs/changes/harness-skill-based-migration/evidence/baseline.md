# T-001 Repository Baseline

- Captured at: `2026-07-20T16:32:14.079Z`
- Repository root: `/home/ubuntu/.config/opencode`
- Checksum scope: 446 present, migration-sensitive, non-secret files.
- Excluded by rule: any file named `.env` or beginning `.env.`.

## Git State

```text
## main...origin/main [ahead 1]
 M .gitignore
 M agents/altitude-intent.agent.md
 M agents/altitude-maestro.agent.md
 M agents/altitude-memory.agent.md
 M agents/altitude-plan.agent.md
 M agents/altitude-report.agent.md
 M agents/altitude-structure.agent.md
 M agents/altitude-validation.agent.md
 D agents/data-engineer.agent.md
 D agents/product.external-integration-agent.agent.md
 D agents/product.frontend-react-agent.agent.md
 D agents/product.rules-qa-agent.agent.md
 D agents/product.supabase-backend-agent.agent.md
 D agents/product.system-design-agent.agent.md
 D agents/product.ux-design-system-agent.agent.md
 D docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md
 D docs/HARNESS_V3_ARCHITECTURE.md
 D docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md
 D docs/README.md
 D docs/archive/HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md
 D docs/archive/HARNESS_V3_LEGACY_PRESERVATION_MATRIX.md
 D docs/archive/HARNESS_V3_MIGRATION_GUIDE.md
 D docs/archive/HARNESS_V3_MIGRATION_TEST_PLAN.md
 D docs/archive/HARNESS_V3_TASK_SPEC_INTEGRATION.md
 D docs/archive/HARNESS_V3_VALIDATION_JUNTA_PATTERN.md
 D docs/archive/HARNESS_V3_WAVES_7-17_ROADMAP.md
 M opencode.json
 D plugins/permission-hardening.ts
?? OPENCODE_HARNESS_DETERMINISTIC_AUDIT.md
?? OPENCODE_HARNESS_SKILL_BASED_MIGRATION_BACKLOG_V2.csv
?? OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md
```

## Active Commit

```text
d219678b66909e4c30c28f9bb64b8c75004926d9
HEAD -> main
Wave 25A: Allocation Consolidation — SHIPPED TO PRODUCTION
```

## Working-Tree Diff Summary

```text
 .gitignore                                         |   1 +
 agents/altitude-intent.agent.md                    |   8 +-
 agents/altitude-maestro.agent.md                   |   6 +-
 agents/altitude-memory.agent.md                    |   6 +-
 agents/altitude-plan.agent.md                      |   8 +-
 agents/altitude-report.agent.md                    |   8 +-
 agents/altitude-structure.agent.md                 |   6 +-
 agents/altitude-validation.agent.md                |   6 +-
 agents/data-engineer.agent.md                      | 256 ---------
 agents/product.external-integration-agent.agent.md | 245 ---------
 agents/product.frontend-react-agent.agent.md       | 244 ---------
 agents/product.rules-qa-agent.agent.md             | 223 --------
 agents/product.supabase-backend-agent.agent.md     | 244 ---------
 agents/product.system-design-agent.agent.md        | 249 ---------
 agents/product.ux-design-system-agent.agent.md     | 249 ---------
 docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md    | 132 -----
 docs/HARNESS_V3_ARCHITECTURE.md                    | 114 ----
 docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md       |  81 ---
 docs/README.md                                     |  57 --
 .../HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md        |  70 ---
 .../HARNESS_V3_LEGACY_PRESERVATION_MATRIX.md       |  45 --
 docs/archive/HARNESS_V3_MIGRATION_GUIDE.md         | 287 ----------
 docs/archive/HARNESS_V3_MIGRATION_TEST_PLAN.md     |  64 ---
 docs/archive/HARNESS_V3_TASK_SPEC_INTEGRATION.md   | 112 ----
 .../archive/HARNESS_V3_VALIDATION_JUNTA_PATTERN.md | 452 ----------------
 docs/archive/HARNESS_V3_WAVES_7-17_ROADMAP.md      | 456 ----------------
 opencode.json                                      |  26 +-
 plugins/permission-hardening.ts                    | 581 ---------------------
 28 files changed, 50 insertions(+), 4186 deletions(-)
```

## Migration-Sensitive Inventory

| Surface | State | File count |
|---|---|---:|
| `AGENTS.md` | present | 1 |
| `opencode.json` | present | 1 |
| `opencode.jsonc` | present | 1 |
| `agents` | present | 74 |
| `skills` | present | 160 |
| `commands` | present | 35 |
| `plugins` | present | 6 |
| `tools` | present | 32 |
| `docs` | missing | 0 |
| `.specs/shared` | present | 51 |
| `test` | present | 85 |

## Missing Surfaces

- `docs`

## Checksum Coverage

- Manifest: `evidence/checksums.sha256`
- Every present file listed above has one SHA-256 record.
- Missing surfaces are recorded above and have no synthetic checksum.
- No file content, credential, token, or secret value is included in this report.

## Verification Result

- `sha256sum --check --status evidence/checksums.sha256` passed for all 446 entries.
- The checksum manifest contains no `.env` or `.env.*` path.
- `rtk git diff --check` returned no whitespace errors.
- `.specs/memory/active-state.md` contains no reference to this change.
