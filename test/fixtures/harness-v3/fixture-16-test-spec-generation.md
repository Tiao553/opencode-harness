# Fixture: TEST-SPEC Generation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-16-test-spec-generation |
| Title | Validation-heavy change requires TEST-SPEC |
| Purpose | Preserve behavior: Altitude generates TEST-SPEC when validation strategy must be explicit (migrations, complex logic, risk scenarios) |
| Group | Artifact Generation |

## Request

**User input (during design):**
```
"We're migrating 50M customer records to a new schema. 
How do we validate data integrity? What edge cases must we test?"
```

## Expected Behavior

### Route
- Coordinator: `Altitude`
- Mode: Design (TEST-SPEC is design phase artifact)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| `.specs/changes/{id}/test-spec.md` | created | Validation strategy using template |

### Allocation
- **Global scope:** .specs/changes/
- **Forbidden scope:** Code until TEST-SPEC is approved
- **Specialists:** QA/validation specialist (reason: test design expertise)

### Todos
- [ ] Map acceptance criteria to test cases — verify: 1:1 mapping documented
- [ ] Define regression scenarios — verify: at least 3 "must not break" scenarios
- [ ] Define edge cases (nulls, duplicates, large batches, failures) — verify: 2+ edge cases documented
- [ ] Define golden fixtures (sample data, expected outcomes) — verify: test data is reproducible
- [ ] Design validation commands/checks — verify: each test case has a command or manual check

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| TEST-SPEC complete | template audit | Scope, objective, acceptance mapping, golden fixtures, regression scenarios, edge cases all present |
| tests are executable | review | Each test case is runnable or manually checkable |
| evidence plan clear | reading | Clear what proof constitutes pass/fail |
| stakeholder approval | sign-off | QA/validator approves test plan |

### State Update
- TEST-SPEC created with status: draft → approved
- linked to change

## Must Not

- ❌ Skip TEST-SPEC for high-risk changes (migrations, permission changes, data transformations)
- ❌ Write code before TEST-SPEC is approved
- ❌ Define "test later" instead of upfront validation planning
- ❌ Assume manual testing is sufficient without defining test cases

## Notes

This fixture validates TEST-SPEC generation for validation-critical work.
TEST-SPEC is required when shipping depends on proof (migrations, security changes, data integrity).
