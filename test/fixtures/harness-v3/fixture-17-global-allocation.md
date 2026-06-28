# Fixture: Global Allocation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-17-global-allocation |
| Title | Multi-wave change requires global allocation definition |
| Purpose | Preserve behavior: Wave/phase ownership is defined upfront, allowed scope and forbidden scope are explicit, specialists are pre-registered |
| Group | Task & Allocation |

## Request

**User input (during structure/design):**
```
Multi-week migration affecting agents, skills, .specs, and docs.
Who owns what? What files are off-limits?
```

## Expected Behavior

### Route
- Coordinator: `Altitude`
- Mode: Structure/Design (global allocation defined here)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| `.specs/changes/{id}/allocation/global-allocation.md` | created | Wave/phase ownership explicit |

### Allocation
- **Global scope:** docs/, .specs/, agents/, skills/
- **Forbidden scope:** plugins/ (unless explicitly approved), runtime code (unless explicitly approved)
- **Specialists:** documented in allocation

### Todos
- [ ] Define change owner and coordinators — verify: primary owner named
- [ ] List global specialists and their scope — verify: each specialist has reason/scope/evidence requirement
- [ ] Define allowed files — verify: explicit list or pattern
- [ ] Define forbidden files — verify: explicit "off-limits" list
- [ ] Define escalation rules — verify: when does coordinator stop and ask user

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| allocation complete | template audit | Scope, owner, specialists, allowed/forbidden, escalation all present |
| scope is clear | review | No ambiguity about which files are in scope |
| specialists have constraints | reading | Each specialist knows what they can/cannot touch |
| escalation rules exist | reading | Coordinator knows when to stop and ask |

### State Update
- Global allocation created and linked to change
- Active for entire change lifecycle
- Local allocations must not broaden global scope

## Must Not

- ❌ Define allocation during execution (too late)
- ❌ Broaden allocation mid-wave without user approval
- ❌ Leave "everything is allowed" (no constraints = no safety)
- ❌ Forget to define forbidden scope

## Notes

This fixture validates global allocation as planning-phase decision.
Local allocations can narrow but never broaden global scope.
