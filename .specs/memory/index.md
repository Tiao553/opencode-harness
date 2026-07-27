# Memory Index

**Purpose:** Master registry of all operational memory entries across all changes and waves.

**Location:** `.specs/memory/{change_id}/{entry_id}.yaml`

**Update Policy:** Append-only. New entries trigger automatic index update via `memory.write()`.

## Master Registry

| Change ID | Wave | BLOCO | Trigger | Entry ID | Timestamp | Agent | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| phase-0 | 24-25 | BLOCO-1 | bloco_completion | phase-0-bloco-1-completion | 2026-07-03 | altitude-execution | ✅ active |

## Timeline View

### Wave 24 (Complete)
- 2026-06-26: Wave 24 BLOCO-1 (altitude-filestore plugin) — COMPLETE
- 2026-06-26: Wave 24 BLOCO-2 (plugin integrations) — COMPLETE
- 2026-06-26: Wave 24 BLOCO-3 (all 9 agents refactored) — COMPLETE
- 2026-06-26: Wave 24 BLOCO-4 (validation + commit) — COMPLETE

### Wave 25 (Phase 0 In Progress)
- 2026-07-03: Phase 0 BLOCO-1 (docs cleanup: 16→4 files) — IN PROGRESS

## Query Examples

### Find all entries for a change
```bash
memory.query("all", "phase-0")
```

### Find all phase gate completions
```bash
memory.query("phase_gate", "*")
```

### Find all specialist handoffs in a wave
```bash
memory.query("specialist_handoff", "wave-25")
```

### Get decision timeline for a change
```bash
memory.timeline("phase-0")
```

## Active Agents Using Memory
1. altitude-maestro (phase routing)
2. altitude-intent (Intent phase)
3. altitude-structure (Structure phase)
4. altitude-plan (Plan phase)
5. altitude-execution (Execution phase + BLOCO management)
6. altitude-validation (Validate phase)
7. altitude-report (Ship phase)
8. altitude-memory (memory updates + queries)
9. data-engineer (tactical memory + specialist handoffs)

## Recent Entries

### Phase 0 BLOCO Completions
- BLOCO-1 (DOC-CLEANUP): docs/ 16→4, 7 archived, 5 deleted
- BLOCO-2 (SHARED-CONSOLIDATION): shared/ 58→48, 5 deleted, 5 archived
- BLOCO-3 (TEMPLATES): templates/ 15→11, 4 deleted
- BLOCO-4 (CONTROL-CREATE): control/ NEW with 3 key files

## Next Actions
- [ ] Activate memory.write() calls in all 9 agents
- [ ] Confirm memory query methods available in runtime
- [ ] Create first memory entries for Phase 0 BLOCO completions
