# Fixture: Tactical SQL Fix

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-04-tactical-sql-fix |
| Title | Bounded SQL/dbt issue reported |
| Purpose | Preserve behavior: Data Engineer routes to tactical task, dbt specialist allocated, verification via dbt test, no .specs change created |
| Group | Tactical Data |

## Request

**User input:**
```
"This dbt model is duplicating customers. Fix it."
```

## Expected Behavior

### Route
- Coordinator: `Data Engineer` (tactical classifier)
- Mode: `tactical` (not a phase)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| Task-Spec leaf task | created | SQL/dbt bounded task contract |
| `.specs/changes` artifact | NOT created | tactical work is not durable strategic change |

### Allocation
- **Global scope:** dbt models, SQL schema, test files
- **Forbidden scope:** .specs changes (unless user promotes to durable), pipeline orchestration, other models
- **Specialists:** dbt specialist allocated (reason: SQL verification requires domain knowledge)

### Context Loaded
- current dbt project structure
- model definitions
- test suite
- schema info

### Todos
- [ ] Investigate duplicate customer rows in dbt model output — verify: run model and check row count vs source
- [ ] Fix root cause in SQL/transformation logic — verify: dbt test passes
- [ ] Validate no new duplicates appear — verify: manual query on prod-like sample
- [ ] Document the fix — verify: model comments updated

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| model fixed | dbt test run | `dbt test` on model passes |
| no regression | upstream test | related models still pass |
| row count correct | query | duplicate customers eliminated |

### State Update
- No `.specs` state change
- No active_change recorded
- Tactical task logs to `Data Engineer` coordination log only

## Must Not

- ❌ Create a PRD for a one-off dbt fix
- ❌ Route to Altitude (not strategic)
- ❌ Require multi-week planning for bounded SQL issue
- ❌ Assume similar issues will be fixed (don't create architecture change)

## Notes

This fixture validates Data Engineer's simple-first tactical routing. Dbt specialist is allocated because verification requires SQL knowledge.
No .specs change created because fix is bounded and non-durable.
