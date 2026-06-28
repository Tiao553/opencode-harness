# Fixture: Specialist Allocation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-11-specialist-allocation |
| Title | Task requires specialist, allocated before execution |
| Purpose | Preserve behavior: Specialist assigned in Design/Plan phase, given allowed scope, evidence requirements, and verification responsibility |
| Group | Task & Allocation |

## Request

**User input (during decomposition):**
```
Task requires dbt model review. Data engineer needed before execution.
```

## Expected Behavior

### Route
- Coordinator: `Altitude` (planning)
- Mode: Design/Plan (allocation happens here, not during execution)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| .specs task contract | includes specialist field | Specialist allocated before execution task generated |
| allocation context | clear scope + evidence | Specialist knows what files to touch and what evidence to produce |

### Allocation
- **Global scope:** dbt models, schema, tests
- **Forbidden scope:** Pipeline orchestration, warehouse schema
- **Specialists:** dbt specialist (reason: SQL/model correctness review)

### Todos (projected):
- [ ] Specialist reviews dbt model logic — verify: feedback provided
- [ ] Coordinator accepts/rejects specialist output — verify: decision recorded

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| specialist allocated before execution | task contract review | specialist field populated in Plan phase |
| scope defined | allocation section | allowed/forbidden files explicit |
| evidence requirements clear | evidence field | Specialist knows what proof is needed (test results, review notes, etc.) |
| verification responsibility assigned | task contract | Clear: who validates specialist output |

### State Update
- No phase change yet (allocation is planning decision)
- Task contract updated with specialist
- actual task execution deferred until execution phase

## Must Not

- ❌ Allocate specialist during execution (too late)
- ❌ Give specialist unscoped authority (must narrow global allocation)
- ❌ Expect specialist to invent verification criteria
- ❌ Treat specialist allocation as implicit/hidden

## Notes

This fixture validates specialist allocation as part of planning (not late binding in execution).
Allocation is explicit in task contract before execution begins.
