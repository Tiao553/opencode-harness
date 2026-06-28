# Fixture: State Conflict

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-03-state-conflict |
| Title | Task, state, and memory disagree on current phase |
| Purpose | Preserve behavior: Coordinator detects conflict, blocks execution, surfaces evidence, asks user for repair decision |
| Group | Strategic Coordination |

## Request

**User input:**
```
"Execute the next task for the pipeline refactor."
```

**State conflict example:**
- artifact state: `phase = Execution`
- task contract: `status = pending (waiting for plan approval)`
- memory: `phase = Design`

## Expected Behavior

### Route
- Coordinator: `Altitude` (state resolver enters conflict mode)
- Mode: `state_conflict_gate`

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| conflict evidence collected | n/a | sources identified and displayed |
| no execution artifact created | n/a | blocked before mutation |

### Allocation
- **Global scope:** read-only .specs, memory
- **Forbidden scope:** No execution/mutation until conflict resolved
- **Specialists:** None

### Context Loaded
- change state file
- active task contract
- memory notes
- validation ledger (if relevant)

### Todos
- None (conflict gate is decision-only)

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| conflict detected | state resolution | Precedence rules applied, mismatch found |
| evidence presented | read output | User sees: artifact state / task state / memory / inferred state |
| options offered | multiple choice | A=artifact, B=task, C=memory, D=repair task |
| execution blocked | attempt to proceed | Coordinator refuses execution without user decision |

### State Update
- No state changes until user chooses repair
- Selected option repair triggers new state snapshot

## Must Not

- ❌ Silently assume one source is correct
- ❌ Proceed to execution with unresolved conflict
- ❌ Overwrite state without user confirmation
- ❌ Delete or hide conflicting evidence

## Notes

This fixture validates that coordinator blocks execution when state is ambiguous.
Tests precedence enforcement and conflict reporting.
