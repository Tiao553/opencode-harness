# T-009 State Repair Evidence

- Decision: preserve legacy Wave 25 evidence without moving or deleting it.
- Active change: `harness-skill-based-migration` only.
- Legacy lifecycle: Wave 25 is shipped and explicitly retained in active/archive locations as historical evidence.
- Canonical control surface: `control/`.
- Historical control surface: `.specs/control/`.
- Index: `kb-index.yaml` regenerated from current filesystem counts; missing `docs/` remains explicit.
- Rollback: restore the T-001 baseline versions of `active-state.md`, `kb-index.yaml`, and both control README files.
