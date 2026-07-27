# File Ownership and Migration Matrix

**Purpose:** Record the current owner, migration action, target owner, and governing wave for every file surface touched by the skill-based migration.

**Source authority:** T-003 agent inventory, T-004 behavior ownership matrix, T-009 state repair, Roadmap V2 Sections 2–4.

**Last verified:** W0 baseline (2026-07-20).

**Reading this matrix:** `Current owner` is who controls the file today. `Migration action` is what the migration will do. `Target owner` is who controls it after W12. `Wave` is the earliest wave that changes this surface.

---

## AGENTS.md

| File | Current owner | Migration action | Target owner | Wave |
|---|---|---|---|---|
| `AGENTS.md` | altitude-maestro prompt | Rewrite to compact kernel + global dispatch START | Built-in `build`/`plan` via instructions | W4 |

---

## Agents directory (`agents/`)

| File group | Current state | Migration action | Target state | Wave |
|---|---|---|---|---|
| `altitude-maestro.agent.md` | Custom primary, 9 routing gates | Freeze; remove `mode: primary` from config | Retired as primary; kept as subagent reference until W12 | W6 |
| `data-engineer.agent.md` | Deleted from worktree; inline config remains | Remove inline config entry | Removed entirely | W6 |
| `altitude-*.agent.md` (7 files) | Subagent altitude phase agents | Retire after compact kernel replaces coordination | Removed in W6 | W6 |
| `dev.codebase-explorer.agent.md` | Subagent, W5 conversion target | Convert to skill; freeze file | Skill `dev-codebase-explorer`; file deleted after W11 | W5 |
| `dev.faithfulness-guard.agent.md` | Subagent, W5 conversion target | Convert to skill; freeze file | Skill `dev-faithfulness-guard`; file deleted after W11 | W5 |
| `dev.judge-agent.agent.md` | Subagent, W5 conversion target | Convert to skill; freeze file | Skill `dev-judge`; file deleted after W11 | W5 |
| `dev.prompt-crafter.agent.md` | Subagent, W5 conversion target | Convert to skill; freeze file | Skill `dev-prompt-crafter`; file deleted after W11 | W5 |
| `dev.security-guardian.agent.md` | Subagent, W5 conversion target | Convert to skill; freeze file | Skill `dev-security-guardian`; file deleted after W11 | W5 |
| `dev.shell-script-specialist.agent.md` | Subagent, W5 conversion target | Convert to skill; freeze file | Skill `dev-shell-script-specialist`; file deleted after W11 | W5 |
| All other 59 specialist subagents | Subagents with `task: allow` | Add explicit `task: deny`, `todowrite: deny` to profiles | Leaf subagents with allocation-bounded write scope | W6 |

---

## opencode.json

| Key | Current state | Migration action | Target state | Wave |
|---|---|---|---|---|
| `agent.altitude-maestro` | `mode: primary` inline | Move to staged fragment; remove `mode: primary` at cutover | Absent or subagent-only entry | W6, W10 |
| `agent.data-engineer` | `mode: primary` inline, file deleted | Remove inline entry in staged fragment | Absent | W6 |
| `agent.altitude-*` (7 subagents) | Inline hidden subagent entries | Retire inline entries as agents are removed | Absent | W6 |
| `permission.*` | Global `allow` for everything | Replace with default-deny + explicit leaf allowlist | Default-deny; parent allowlist only | W6 |
| `plugin` array | 6 plugins | Refactor/consolidate; apply disposition matrix | 3–5 plugins with explicit contracts | W10 |
| `mcp` block | Absent (no servers) | Build staged MCP fragment | 6 servers pinned in `opencode.next.json` | W8 |

---

## Skills directory (`skills/`)

| Skill | Current state | Migration action | Target state | Wave |
|---|---|---|---|---|
| `core-commands/` | Active | Retain; update trigger rules if needed | Active | W3 |
| `data-engineering/` | Active | Retain | Active | W3 |
| `performance-optimization/` | Active | Retain | Active | W3 |
| `review/` | Active | Retain; overlap assessment with dev skills | Active (overlap resolved) | W5 T-069 |
| `task-spec/` | Active | Retain | Active | — |
| `visual-explainer/` | Active | Retain | Active | — |
| `workflow-commands/` | Active | Retain; fix missing sub-skill references | Active | W3 |
| `dev-codebase-explorer/` | Absent | Create from dev agent | New skill | W5 |
| `dev-faithfulness-guard/` | Absent | Create from dev agent | New skill | W5 |
| `dev-judge/` | Absent | Create from dev agent | New skill | W5 |
| `dev-prompt-crafter/` | Absent | Create from dev agent | New skill | W5 |
| `dev-security-guardian/` | Absent | Create from dev agent | New skill | W5 |
| `dev-shell-script-specialist/` | Absent | Create from dev agent | New skill | W5 |
| `workflow-define/` | Absent (referenced but missing) | Create | New skill | W3 |
| `workflow-design/` | Absent (referenced but missing) | Create | New skill | W3 |

---

## Commands directory (`commands/`)

| Command group | Current state | Migration action | Target state | Wave |
|---|---|---|---|---|
| `/workflow:*` (8 commands) | Active; route to workflow.* subagents | Preserve command files; route through AgentSpec START | Preserved and compatible | W7 |
| `/data:*` (7 commands) | Active; route to specialist subagents | Retain; update skill references if needed | Active | W3 |
| `/review:*` (5 commands) | Active | Retain; review overlap with dev skills | Active (overlap resolved) | W5 |
| `/core:*` (5 commands) | Active | Retain | Active | — |
| `/visual:*` (5 commands) | Active | Retain | Active | — |
| `/knowledge:*` (3 commands) | Active | Retain | Active | — |
| `/context:*` (1 command) | Active | Retain | Active | — |

---

## Plugins (`plugins/`)

| Plugin | Current state | Migration action | Target state | Wave |
|---|---|---|---|---|
| `altitude-context.ts` | Active; phase-agent description injection | Refactor or remove (depends on disposition) | Refactored or removed | W10 |
| `altitude-filestore.ts` | Active | Retain neutral file/allocation behavior | Retained with updated contract | W10 |
| `specs-state.ts` | Active; no-op shim | Harden with durable hook if available; else retain as policy doc | Hardened or documented | W10 |
| `rtk-native.ts` | Active | Consolidate behavior | Retained and aligned | W10 |
| `headroom-guard.ts` | Active | Merge with context-budget | One canonical plugin | W10 |
| `context-budget.ts` | Active | Merge with headroom-guard | One canonical plugin | W10 |
| `permission-hardening.ts` | Deleted from worktree (pre-existing) | Remove inline reference; no restoration | Absent | W10 |

---

## `.specs/` layer

| Path | Current state | Migration action | Target state | Wave |
|---|---|---|---|---|
| `.specs/changes/harness-skill-based-migration/` | Active (this change) | Populate through W12; archive at ship | Archived | W12 |
| `.specs/changes/wave-25-allocation-consolidation/` | Retained shipped evidence | Keep as historical evidence; review at W12 | Archived definitively | W12 |
| `.specs/memory/active-state.md` | Points to this migration (T-009) | Update at each phase transition | Points to shipped migration | W12 |
| `.specs/shared/` | 41 active contracts | Normalize, merge duplicates | Lean contract set | W10 |
| `.specs/control/` | Historical reference | No change; remains historical | Historical reference | — |
| `control/` | Active meta-governance | Maintain INDEX and analysis files | Active | All waves |

---

## Docs (`docs/`)

| File | Current state | Migration action | Target state | Wave |
|---|---|---|---|---|
| All `docs/` files | Missing from worktree (deleted in dirty baseline) | No restoration in W0–W3; W12 T-170 updates architecture docs | New canonical docs written | W12 |

---

## `.gitignore` and untracked inputs

| File | Current state | Note |
|---|---|---|
| `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md` | Untracked (gitignored by `*` rule) | Canonical migration plan; must not be lost |
| `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_BACKLOG_V2.csv` | Untracked (gitignored) | Machine-readable task registry |
| `OPENCODE_HARNESS_DETERMINISTIC_AUDIT.md` | Untracked (gitignored) | Read-only rationale |

These files are the primary migration inputs. They must be preserved by the operator outside git tracking until a decision is made in W1 T-019 about their canonical storage.
