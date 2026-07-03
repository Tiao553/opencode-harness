# Fixture: Strategic New Change

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-01-strategic-new-change |
| Title | User requests new durable architecture work |
| Purpose | Preserve behavior: Altitude routes strategic requests to Intent phase, creates initial .specs artifact, projects planning todos |
| Group | Strategic Coordination |

## Request

**User input:**
```
"I need to design a new data pipeline orchestration layer. Multiple teams,
multi-week effort, needs architecture decisions and validation gates."
```

## Expected Behavior

### Route
- Coordinator: `Altitude` (strategic classifier detects scope > tactical)
- Mode: `Intent`

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| `.specs/changes/{change-id}/00-intent.md` | created | problem/goal scope captured |
| `.specs/changes/{change-id}/state.md` | created | phase = Intent, status = new |
| `.specs/memory/active-state.md` | updated | active_change = {change-id} |

### Allocation
- **Global scope:** docs/, .specs/changes/, .specs/memory/, .specs/shared/
- **Forbidden scope:** plugins/, commands/, opencode.json, runtime code
- **Specialists:** None allocated in Intent phase

### Context Loaded
- current .specs structure
- active change memory
- phase engine contract

### Todos
- [ ] Capture problem statement and stakeholders — verify: 3+ stakeholders named, success criteria explicit
- [ ] Map non-goals and constraints — verify: at least 2 non-goals, at least 1 constraint
- [ ] Identify assumptions — verify: at least 2 assumptions listed
- [ ] Recommend next phase (Structure) — verify: clear gate documented

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| intent artifact exists | file check | `.specs/changes/{id}/00-intent.md` readable |
| state file created | file check | `state.md` has phase=Intent |
| todos projected | read todos | All todos include verify: clauses |
| scope captured | artifact review | Problem, goal, non-goals, stakeholders present |

### State Update
- phase: None → `Intent`
- active_change: null → `{change-id}`
- active_task: null → None
- status: new → `planning`

## Must Not

- ❌ Ask user for detailed design yet (Intent only captures scope)
- ❌ Allocate specialists before Structure phase maps risks
- ❌ Create execution tasks yet (decomposition comes later)
- ❌ Assume what tools/languages will be used
- ❌ Write code or configs in Intent phase

## Notes

This fixture validates that Altitude can distinguish strategic multi-phase work from tactical one-off requests and route to Intent correctly.
