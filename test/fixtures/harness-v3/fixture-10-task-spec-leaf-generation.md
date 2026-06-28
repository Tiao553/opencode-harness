# Fixture: Task-Spec Leaf Generation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-10-task-spec-leaf-generation |
| Title | Coordinator generates Task-Spec leaf task from .specs task contract |
| Purpose | Preserve behavior: Phase engine generates Task-Spec, maps .specs fields to Task-Spec schema, specialist and allocation inherited |
| Group | Task & Allocation |

## Request

**User input (implicit during plan→execution transition):**
```
User has approved a Design plan with task pack defined.
Coordinator bridges to Task-Spec for execution.
```

## Expected Behavior

### Route
- Coordinator: `Altitude` (plan→execution transition)
- Mode: Execution (planning complete, leaf task generated)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| Task-Spec leaf task | created | Generated from .specs task contract + allocation + PRD/ADR/TEST-SPEC refs |
| `.specs` task contract | read | Source for Task-Spec fields |

### Allocation
- **Global scope:** .specs task-level files, Task-Spec outputs
- **Forbidden scope:** execution before Task-Spec complete
- **Specialists:** Inherited from .specs task allocation

### Todos (projected in Task-Spec):
- [ ] Execute Task-Spec step 1 — verify: {acceptance check}
- [ ] Execute Task-Spec step 2 — verify: {acceptance check}

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| mapping complete | .specs ↔ Task-Spec field audit | All required fields mapped |
| specialist inherited | Task-Spec specialist field | Matches .specs allocation |
| evidence requirements clear | Task-Spec evidence field | Mirrors .specs evidence |
| allowed files correct | Task-Spec allowed/forbidden | Narrowing global allocation is OK |

### State Update
- phase: Plan → Execution
- active_task: Task-Spec-generated ID assigned
- status: ready → executing

## Must Not

- ❌ Generate Task-Spec before Plan is approved
- ❌ Lose specialist or allocation context in mapping
- ❌ Broaden global allowed scope in Task-Spec
- ❌ Skip evidence field mapping

## Notes

This fixture validates Task-Spec as official leaf-task engine (Wave 6).
Maps .specs change control → Task-Spec execution contract.
