# Fixture: PRD Generation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-14-prd-generation |
| Title | Requirements-heavy change requires PRD artifact |
| Purpose | Preserve behavior: Altitude detects requirements-driven work, generates PRD from intent/structure, uses PRD template |
| Group | Artifact Generation |

## Request

**User input:**
```
"Design a new workspace permission model. 
Requirements are complex, multiple stakeholders, conflicting needs."
```

## Expected Behavior

### Route
- Coordinator: `Altitude`
- Mode: Design/Plan (PRD is planning artifact)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| `.specs/changes/{id}/prd.md` | created | Requirements capture using template |

### Allocation
- **Global scope:** .specs/changes/
- **Forbidden scope:** Code
- **Specialists:** Product/requirements specialist if stakeholder alignment is complex

### Todos
- [ ] Gather and document requirements from stakeholders — verify: 3+ stakeholder inputs captured
- [ ] Define acceptance criteria — verify: each AC is testable
- [ ] Identify non-goals — verify: at least 2 non-goals explicit
- [ ] Validate PRD with stakeholders — verify: stakeholder sign-off recorded

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| PRD complete | template audit | Problem, goal, non-goals, requirements, acceptance criteria, constraints, links all present |
| testable criteria | review | Each AC is verifiable |
| stakeholders aligned | feedback | Approval recorded |

### State Update
- PRD created and associated with change
- PRD status: draft → approved (by user/stakeholders)

## Must Not

- ❌ Skip PRD if requirements are complex
- ❌ Write code before PRD is approved
- ❌ Create PRD and ignore it during execution
- ❌ Assume requirements are stable without PRD validation

## Notes

This fixture validates PRD generation for product/requirements-driven work (not all changes need PRD, only those with requirements complexity).
