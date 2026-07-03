# Memory Contract

## Purpose

Define explicit write triggers, schema, and enforcement for Harness V3 operational memory.

Memory is not auto-maintained. Writes must be triggered by explicit events and enforced in all 9 altitude/data-engineer agents.

## Schema

```yaml
memory:
  entry_id: "{change_id}-{bloco}-{trigger}"
  timestamp: "ISO 8601"
  trigger: "phase_gate | bloco_completion | conflict_resolution | specialist_handoff | critical_failure"
  change_id: "wave-X or change-id"
  bloco_id: "BLOCO N"
  altitude: "intent | structure | plan | execution | validate | ship"
  agent: "altitude-{phase} or data-engineer"
  
  # Trigger-specific fields
  phase_gate:
    from_phase: "intent | structure | plan | execution | validate | ship"
    to_phase: "intent | structure | plan | execution | validate | ship"
    decision: "{description of decision at gate}"
    evidence_path: ".specs/changes/..."
    
  bloco_completion:
    bloco_id: "BLOCO N"
    completed_tasks: ["T-01", "T-02", ...]
    file_count: "{ before: 58, after: 48 }"
    consolidation: "{ deleted: 5, archived: 5, merged: 3 }"
    
  conflict_resolution:
    conflict_type: "state | allocation | artifact | scope"
    source_authority: "artifact | task | state | inference"
    resolution: "{how the conflict was resolved}"
    
  specialist_handoff:
    specialist_agent: "architect.schema-designer | data-engineering.spark-specialist | ..."
    task_id: "T-123"
    scope: "{ allowed_files: [...], forbidden_files: [...] }"
    reason: "{why specialist was allocated}"
    
  critical_failure:
    failure_type: "blocked_task | invalid_state | scope_violation | auth_error"
    task_id: "T-123"
    error: "{description}"
    recovery_initiated: "yes | no"
    recovery_path: "{manual | automated}"
```

## Write Triggers (5 Mandatory)

### 1. Phase Gate Completion
**When:** Transition from one phase to next (Intent→Structure→Plan→Execution→Validate→Ship)  
**Who:** altitude-{phase} agent at gate  
**What:** Record decision + evidence path

```yaml
- entry_id: "wave-25-BLOCO-1-phase_gate_completion"
  trigger: "phase_gate"
  from_phase: "intent"
  to_phase: "structure"
  decision: "User confirmed problem scope and stakeholder alignment"
  evidence_path: ".specs/changes/wave-25/01-intent.md"
```

### 2. BLOCO Completion
**When:** Each BLOCO N finishes all tasks  
**Who:** altitude-execution agent at BLOCO close  
**What:** Record file deltas + consolidation metrics

```yaml
- entry_id: "phase-0-BLOCO-1-completion"
  trigger: "bloco_completion"
  bloco_id: "BLOCO 1"
  completed_tasks: ["T-01", "T-02", "T-03", "T-04", "T-05"]
  file_count: { before: 16, after: 4 }
  consolidation: { deleted: 5, archived: 7 }
```

### 3. Conflict Resolution
**When:** State conflict detected + resolved (stop condition triggered)  
**Who:** altitude-{phase} agent that detected conflict  
**What:** Record conflict type + resolution choice + evidence

```yaml
- entry_id: "wave-25-conflict-001"
  trigger: "conflict_resolution"
  conflict_type: "allocation"
  source_authority: "local_allocation_vs_global_allocation"
  resolution: "Broadening approved by user; new allocation created"
```

### 4. Specialist Handoff
**When:** Specialist agent allocated (T-06 onwards)  
**Who:** altitude-execution or routing agent  
**What:** Record specialist name + scope + reason

```yaml
- entry_id: "wave-25-specialist-001"
  trigger: "specialist_handoff"
  specialist_agent: "architect.schema-designer"
  task_id: "T-06"
  scope: { allowed_files: ["schema/**/*.sql"], forbidden_files: ["agents/**"] }
  reason: "Complex dimensional model requires expert DDL"
```

### 5. Critical Failure
**When:** Task blocked, recovery initiated (Ralph Loop failure)  
**Who:** altitude-execution or recovery agent  
**What:** Record error type + recovery path

```yaml
- entry_id: "wave-25-failure-001"
  trigger: "critical_failure"
  failure_type: "blocked_task"
  task_id: "T-12"
  error: "File deletion would violate allocation constraints"
  recovery_path: "manual"
```

## Memory Maintenance

### Write Responsibility
- **altitude-maestro:** Phase gate completions
- **altitude-{phase}:** Conflict resolutions, specialist handoffs
- **altitude-execution:** BLOCO completions, critical failures
- **data-engineer:** Tactical conflict resolutions, specialist handoffs

### Enforcement
1. Each agent loads `.specs/memory/index.md` at startup (list of active memory entries)
2. At each write trigger, agent calls `memory.write(entry)` (documented in agent recovery protocols)
3. Timestamp auto-filled at write time
4. No manual memory updates (all via contract triggers)

### Query & Reporting
- Use `memory.query(trigger_type, change_id)` to fetch memory entries
- Use `memory.timeline(change_id)` to view chronological decision trail
- Use memory in validation reports: "Decisions made: [timeline of 5 triggers]"

## Location
- **Memory index:** `.specs/memory/index.md` (list of all entries + entry_ids)
- **Memory entries:** `.specs/memory/{change_id}/{entry_id}.yaml`
- **Validation queries:** use `memory.query()` in altitude-validation workflows

## Enforcement Checklist
- [ ] All 9 agents (altitude + data-engineer) load memory-contract.md in their Recovery Protocol
- [ ] Each agent implements memory.write() at the 5 trigger points
- [ ] Validation agents query memory for decision trail before shipping
- [ ] TODOWRITE logs every memory.write() call with entry_id
- [ ] Phase gates require memory entry before advancing

## Known Limitations
- Memory is append-only (no edits, only corrections via new entry with "supersedes" field)
- Wave 24 RTK compression may truncate memory.yaml if context budget exceeded
- Headroom budget is checked before memory writes (may escalate if budget tight)

## Next Steps
1. Initialize `.specs/memory/` directory
2. Create `.specs/memory/index.md` (master registry)
3. Update AGENTS.md Section 8-9 with memory protocol reference
4. Update all 9 agents with memory.write() calls (Phase 0 T-29-30)
