# Schema and Compatibility Versioning Policy

**Purpose:** Define how OpenCode runtime version, schema, plugin API, and MCP packages are pinned, validated, and updated during and after the skill-based migration.

**Source authority:** T-007 runtime baseline, Roadmap V2 D-16, T-002 configuration provenance.

**Last verified:** W0 baseline (2026-07-20).

---

## Pinned Baseline (T-007)

| Component | Pinned value | SHA-256 |
|---|---|---|
| OpenCode version | `1.18.3` | — |
| OpenCode executable | `/home/ubuntu/.nvm/versions/node/v24.16.0/lib/node_modules/opencode-ai/bin/opencode.exe` | `915ca1cd9eb5a7b3e15bd89dc71c38cf0caa9a02d13c5371422675b4b370bffb` |
| Config schema | `https://opencode.ai/config.json` | `8ffffc8622f2bbee5e9b1e57bf2509910f2a6dfc237458766bfaa5e295787a2e` |
| Plugin package | `@opencode-ai/plugin` `1.16.2` | — |
| Node runtime | `v24.16.0` | — |
| OS | `Linux 6.17.0-1018-oracle aarch64` | — |

---

## Update Policy During Migration

| Rule | Detail |
|---|---|
| No automatic update | The NVM-managed installation is treated as externally controlled; no `npm update` or autoupdate command may run during W0–W12 validation |
| Schema snapshot | The schema SHA is re-verified before any `opencode.json` fragment is created |
| Plugin API | Any plugin must use `@opencode-ai/plugin` at the pinned version; bumps require a new schema check and W10 review |
| MCP packages | Each MCP server must pin an exact version or immutable reference; no floating `latest` (W8 T-119) |

---

## Compatibility Window

| Event | Required action |
|---|---|
| OpenCode minor version bump | Verify schema hash; re-run W4 structural tests before continuing |
| OpenCode major version bump | Stop migration; create a new runtime baseline task before proceeding |
| Plugin API version bump | Re-run plugin tests; update pin in `package.json` under W10 review |
| MCP server version change | Update provenance manifest; re-run W8 health-check fixture |

---

## Schema Validation Rule

Every `opencode.json` or `opencode.next.json` fragment produced during the migration must:

1. Include `"$schema": "https://opencode.ai/config.json"`.
2. Be validated against the schema before being added to the activation bundle.
3. Produce no unknown-key errors with the pinned version.

If validation fails, the task producing the fragment is a blocking defect for its wave.

---

## Artifact Versioning

| Artifact type | Versioning rule |
|---|---|
| ADR | `status` field with values: `accepted`, `deprecated`, `superseded` |
| Task-Spec | `status` field: `draft`, `in_progress`, `done` |
| Shared contracts | No formal version field; changes must be recorded in `bootstrap-decisions.md` or equivalent |
| Wave validation reports | Named by wave: `w{N}-validation-report.md`; never updated after PASS |
| Memory events | Append-only; corrections use a new entry with `supersedes` field |

---

## Rollback

If a version incompatibility is discovered during migration:

1. Stop the current task immediately.
2. Record the incompatibility in the task's stop-condition evidence.
3. Restore the T-001 baseline checksums for any affected files.
4. Create a remediation task before re-entering the wave.

---

## Next Review

This policy must be re-checked at T-V07 (before W8 MCP registration) and at T-V10 (before W11 regression validation).
