# Fixture: Local Allocation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-18-local-allocation |
| Title | Single task requires local allocation (allowed/forbidden files) |
| Purpose | Preserve behavior: Task is assigned to owner/specialist, allowed files are narrower than global, forbidden scope enforced |
| Group | Task & Allocation |

## Request

**User input (during decomposition):**
```
Task: "Create dbt models for new fact table"
This task should only touch dbt models in specific directory.
dbt specialist assigned.
```

## Expected Behavior

### Route
- Coordinator: `Altitude`
- Mode: Design/Plan (local allocation in task contract)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| `.specs/changes/{id}/tasks/T-xxx.md` | includes local allocation | Allowed/forbidden files explicit in task |

### Allocation
- **Global scope (from global allocation):** docs/, .specs/, dbt/
- **Local scope (this task):** `dbt/models/fact_tables/sales_*` only
- **Forbidden scope (this task):** Tests, macros, snapshots (separate tasks) |
- **Specialists:** dbt specialist (reason: SQL correctness)

### Todos
- [ ] Review existing fact table patterns — verify: naming, structure, testing conventions
- [ ] Create new fact tables following pattern — verify: files created in allowed directory only
- [ ] Add tests — verify: test files colocated with models
- [ ] Validate against forbidden scope — verify: no changes outside allowed files

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| local allocation in task contract | audit task file | allowed_files and forbidden_files sections present |
| narrower than global | comparison | Local scope ⊂ global scope |
| specialist respects boundaries | code review | No changes outside allowed files |
| forbidden files untouched | diff scan | No modifications to forbidden files |

### State Update
- Local allocation defined in task contract
- Enforced during execution (specialist cannot broaden scope)

## Must Not

- ❌ Broaden allocation during execution ("just this once")
- ❌ Skip local allocation and assume global scope is enough
- ❌ Forget to define forbidden_files
- ❌ Allow specialist to modify outside allowed scope without approval

## Notes

This fixture validates local allocation as task-level boundary.
Local allocation narrows (or equals) global allocation, never broadens.
If specialist needs broader scope, new task or approval required.
