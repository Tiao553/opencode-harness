# Fixture: ADR Generation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-15-adr-generation |
| Title | Architectural decision with trade-offs requires ADR |
| Purpose | Preserve behavior: Altitude generates ADR when architecture decision is made, records options and rationale |
| Group | Artifact Generation |

## Request

**User input (during design):**
```
"We need to decide: single lakehouse vs dual warehouse+lakehouse.
Document this decision and trade-offs."
```

## Expected Behavior

### Route
- Coordinator: `Altitude`
- Mode: Design (ADR is design phase artifact)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| `.specs/changes/{id}/decisions/ADR-{n}.md` | created | Decision record using template |

### Allocation
- **Global scope:** .specs/changes/
- **Forbidden scope:** Code
- **Specialists:** Architect/senior engineer (reason: design trade-off assessment)

### Todos
- [ ] List options and trade-offs — verify: 2+ options documented
- [ ] Gather team input — verify: feedback from affected teams
- [ ] Decide and record rationale — verify: decision explained and approved
- [ ] Document consequences — verify: positive/negative/operational consequences listed

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| ADR complete | template audit | Context, decision, options, rationale, consequences all present |
| trade-offs explicit | review | Each option has benefits and drawbacks |
| decision rationale clear | reading | Why the chosen option wins in this context |
| team aligned | feedback | Decision acknowledged by affected engineers |

### State Update
- ADR created with status: Proposed → Accepted (after approval)
- linked to change

## Must Not

- ❌ Skip ADR if decision is architectural
- ❌ Document decision without explaining trade-offs
- ❌ Decide alone without team input for high-impact decisions
- ❌ Create ADR and ignore it later ("we'll do it differently anyway")

## Notes

This fixture validates ADR generation for architectural decisions.
ADR is not for every decision, only for significant architecture choices with lasting consequences.
