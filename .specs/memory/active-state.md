# Active State

active_change: harness-skill-based-migration
active_change_path: .specs/changes/harness-skill-based-migration/
active_phase: W1
active_task: W12 CUTOVER PENDING — all waves implemented; awaiting manual approval
last_update: 2026-07-20T17:46:42+00:00

## Canonical Status

W0–W12 implementation is complete. Cutover bundle staged and ready. W12 cutover requires explicit user approval.

## Legacy Lifecycle Record

- `wave-25-allocation-consolidation` is SHIPPED and no longer active.
- Its directory remains under `.specs/changes/` as retained operational evidence and under `.specs/archive/` as shipped validation evidence.
- This duplicate is an explicit retained-evidence lifecycle exception, not two active changes. It must be reconsidered by W12 cleanup, not silently deleted in W0.

## Canonical Control Surface

- Active meta-governance: `control/`.
- `.specs/control/` is historical reference material only and must not define current runtime authority.

## Next Gate

W12 cutover awaits manual approval. When approved: run `docs/MIGRATION_GUIDE.md` cutover steps, then `bash test/w11-static-checks.sh` post-cutover.
