---
change_id: harness-skill-based-migration
status: in_progress
current_wave: W0
current_task: W12-CUTOVER-PENDING
phase: STRUCTURE
updated_at: 2026-07-20T17:21:51+00:00
---

# Harness Skill-Based Migration State

## Authority

1. Current user instruction.
2. Current files and runtime state on disk.
3. `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md`.
4. `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_BACKLOG_V2.csv`.
5. `OPENCODE_HARNESS_DETERMINISTIC_AUDIT.md`.

## Current Status

- Wave: W0 - Baseline, freeze, and evidence.
- Task: T-001 - Snapshot repository and active branch.
- Active phase for this change: STRUCTURE until the W0 baseline is complete.
- Global pointer: intentionally unchanged. `.specs/memory/active-state.md` remains review-only until T-009 reconciles legacy state.
- T-000 status: complete; final independent W0 validation remains T-V00.
- T-001 status: complete; 446 migration-sensitive non-secret files are checksum-verified and `docs/` is explicitly absent.
- W0 execution mode: approved sequential batch. Internal dependencies remain mandatory; W1 remains blocked until T-V00 PASS.
- T-002 status: complete. The repository and global config roots are the same physical directory; no environment override or project-local `.opencode/` source is active.
- T-003 status: complete. 75 custom agents are represented; two custom primaries and global Task/TODO inheritance are recorded.
- T-004 status: complete. 35 commands, 7 skills, 6 plugins, missing references, and non-hard enforcement are recorded.
- T-005 status: complete. CLI positive fixture passed; unknown-agent fallback is a recorded baseline defect.
- T-006 status: complete. The scorecard defines measurable migration targets and fallback behavior.
- T-007 status: complete. Runtime `1.18.3` and schema hash are pinned; updates remain externally controlled and disabled by process.
- T-008 status: complete. The global config and repository roots are one physical directory; no project-local override exists.
- T-009 status: complete. State, lifecycle, control authority, index status, and W0 artifact contracts are reconciled without deletion.
- W4–W12 implementation complete. All static checks PASS. W12 cutover awaits manual user approval.
- Current state: CUTOVER_PENDING — staged bundle ready; wave validation complete for W4–W11 static scope.

## Canonical Task Registry

- Roadmap: `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md`
- Backlog: `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_BACKLOG_V2.csv`
- Backlog checksum: `cad4efa7a88c290baa28b99f71aa77f50df120943eaf50fa60e4590d73b76d54`
- Task count: 164
- Waves: W0 through W12
- W0 entry gate: none
- W0 exit gate: T-V00 PASS

The Backlog V2 is the machine-readable task and dependency registry. Task-Spec files are compiled only when their Definition of Ready is satisfied; no placeholder Task-Spec represents readiness.

## Confirmed Decisions

- D-01: Only built-in `build` and `plan` are primary hosts.
- D-02: The parent session is the only managed TODO and state writer.
- D-03: Leaf subagents deny `task` and `todowrite` and receive complete envelopes.
- D-04: Leaf read scope is worktree-wide by default; write scope is allocation-bounded.
- D-05: Recursive delegation is forbidden.
- D-06: Every execution task belongs to a predeclared validation block.
- D-07: The six dev agents become skills; legacy files are deleted only after consumer migration and cutover validation.
- D-08: Altitude and AgentSpec keep separate workflow contracts and START rules.
- D-09: Explicit `/workflow:*` names remain compatible.
- D-10: All requested MCPs remain in the target architecture.
- D-11: `.specs` is authoritative operational state; memory MCP is semantic duplication.
- D-12: All active runtime changes are staged and applied through one atomic cutover bundle.
- D-13: Parent Task permissions are default-deny with an explicit leaf allowlist.
- D-14: Managed delegation is sequential by default; parallelism requires independent pre-registered tasks.
- D-15: A writer lease prevents concurrent parent mutation of the same change.
- D-16: OpenCode runtime, schema, MCP packages, and plugin compatibility are pinned for migration.
- D-17: Only the compact kernel/global dispatch is always loaded; activity/phase rules and skills are lazy.
- D-18: MCP output is untrusted data unless its source is explicitly an instruction authority.

## Open Risks

| Risk | Severity | Owner | Status |
|---|---|---|---|
| Legacy `.specs` state and archive conflict | critical | T-009 | open |
| Dirty baseline includes config and agent changes | high | T-001 | open |
| Effective OpenCode config provenance is unresolved | high | T-002 | open |
| W0 validator skills and memory MCP are not currently available | critical | T-004, T-V00 | open |

## Artifact Hardening

| Artifact | Required completion | Owner |
|---|---|---|
| State | metadata, dashboard, risks, next gate, and evidence links | T-009 |
| T-006 through T-009 | exact inputs, allowed/forbidden scope, verification, evidence, rollback, and stop conditions | T-009 |
| Scorecard and topology | source, verification, rollback, and limitations | T-009 |
| Control index | active authority and historical-reference links | T-009 |

## Decision Log

| Decision | User choice | Effect | Evidence |
|---|---|---|---|
| Confirmed decisions to record | D-01 through D-18 | T-000 records all confirmed decisions | `evidence/t-000-package-creation.md` |
| Legacy state conflict | Isolated package | Do not change global active-state pointer before T-009 | `.specs/memory/harness-skill-based-migration/bootstrap-decisions.md` |
| T-001 baseline scope | Approved | Capture Git state, inventory, and checksums without secret values | `tasks/T-001.md` |
| T-001 baseline result | Passed | 446 checksums verify; `.env` entries excluded; `docs/` recorded missing | `evidence/baseline.md` |
| W0 batch execution | Approved | Execute remaining W0 tasks without routine task-by-task approval; T-V00 remains the wave gate | `bootstrap-decisions.md` |
| T-V00 transitional validator | Approved | Use current role-equivalent read-only validators until W5 skills exist; record the exception in validation evidence | `tasks/T-V00.md` |
| T-002 config provenance | Passed with diagnostic limitation | Global config is active; MCP CLI is empty; `opencode debug config` exits zero but emits non-JSON output | `evidence/t-002-config-provenance.md` |
| T-003 agent inventory | Passed | 75 custom agents, two custom primaries, six W5 conversion targets | `evidence/t-003-agent-summary.md` |
| T-004 behavior ownership | Passed | Command/skill/plugin ownership and six missing references recorded | `evidence/t-004-behavior-ownership.md` |
