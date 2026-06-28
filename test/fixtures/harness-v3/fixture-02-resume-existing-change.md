# Fixture: Resume Existing Change

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-02-resume-existing-change |
| Title | Active .specs state exists, user resumes work |
| Purpose | Preserve behavior: Altitude detects active change, resolves current phase, loads prior artifacts, recommends next action |
| Group | Strategic Coordination |

## Request

**User input:**
```
"What's the status of the data pipeline work?"
```

## Expected Behavior

### Route
- Coordinator: `Altitude` (state resolver reads `.specs/changes/{id}/state.md`)
- Mode: Detected from state file (e.g., `Execution`, `Validate`, `Design`)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| `.specs/changes/{id}/state.md` | read | phase, active_task, status all loaded |
| `.specs/changes/{id}/01-structure.md` | read | context for structure phase decisions |
| `.specs/changes/{id}/02-decomposition.md` | read | task order and dependencies |
| `.specs/memory/active-state.md` | read | resume point validation |

### Allocation
- **Global scope:** docs/, .specs/changes/, .specs/memory/
- **Forbidden scope:** (no writing unless user explicitly authorizes action)
- **Specialists:** None; this is answer-only phase

### Context Loaded
- active change state
- current phase state
- decomposition and task queue
- validation history if available

### Todos
- None (this is answer_only action type)

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| change exists | state file check | `.specs/changes/{id}/state.md` readable |
| phase detected | read phase field | Known phase (Intent/Structure/Plan/Execution/Validate/Ship) |
| active task identified | read active_task field | Task ID or null |
| status reported | answer delivered | User sees current phase, active task, next action |

### State Update
- No mutations (answer_only)
- active_state may be refreshed in memory but not changed

## Must Not

- ❌ Mutate state without explicit user authorization
- ❌ Start new work without asking
- ❌ Overwrite active task with stale memory
- ❌ Assume prior decisions without showing user evidence

## Notes

This fixture validates state resolution's deterministic precedence (user instruction → active task → change state → memory).
Ensures resume behavior loads the right artifacts and recommends correct next action.
