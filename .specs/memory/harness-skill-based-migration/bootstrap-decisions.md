---
entry_id: harness-skill-based-migration-W0-conflict-resolution-001
timestamp: 2026-07-20T15:41:27+00:00
trigger: conflict_resolution
change_id: harness-skill-based-migration
bloco_id: W0
altitude: structure
agent: parent
conflict_type: state
source_authority: current user instruction
---

# Bootstrap Decisions

- Decision: record confirmed decisions D-01 through D-18 in T-000.
- Decision: create the migration package in isolation.
- Decision: do not modify `.specs/memory/active-state.md` before T-009.
- Evidence: user selections B and A; `state.md`; `allocation.yaml`.
- Next action: validate T-000, then submit T-001 evidence for independent review.

## T-001 Scope Approval

- Trigger: user-approved scope decision.
- Decision: capture Git state, inventory, and checksums in the five T-001 paths.
- Safety: exclude `.env` and `.env.*`; do not alter global state or runtime surfaces.
- Evidence: `tasks/T-001.md` and `allocation.yaml`.

## Initial Batch Completion

- Timestamp: 2026-07-20T16:34:03+00:00
- Trigger: bloco_completion
- Completed tasks: T-000, T-001.
- Evidence: `evidence/t-000-package-creation.md`, `evidence/baseline.md`, and `evidence/checksums.sha256`.
- Result: package and sanitized baseline are complete; W0 remains open pending independent review before T-002.

## W0 Batch Execution Approval

- Timestamp: 2026-07-20T17:12:26+00:00
- Trigger: scope decision
- Decision: execute all remaining W0 tasks as one sequential batch; retain dependencies and block W1 until T-V00 PASS.
- Validation exception: T-V00 may use current role-equivalent read-only validators until the target `dev-judge` and `dev-faithfulness-guard` skills are created in W5.
- Evidence: `state.md`, `allocation.yaml`, and `tasks/T-V00.md`.

## T-009 State Resolution

- Timestamp: 2026-07-20T17:46:42+00:00
- Trigger: conflict_resolution
- Resolution: preserve Wave 25 as shipped retained evidence; make this migration the only active change; use `control/` as canonical; regenerate the index.
- Evidence: `evidence/t-009-state-repair.md`.

## T-009 Artifact Hardening

- Trigger: scope decision
- Decision: re-open T-009 and normalize W0 state, task, scorecard, topology, evidence, and control-index artifacts before T-V00.
- Evidence: `state.md`, `tasks/T-006.md` through `tasks/T-009.md`, `migration-scorecard.md`, `installation-topology.md`, and `control/INDEX.md`.
