# Fixture: RTK Context

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-13-rtk-context |
| Title | Search or shell-level work attempted, RTK context available |
| Purpose | Preserve behavior: RTK plugin provides token-saving context shortcuts, coordinator can report RTK usage, fallback works if RTK unavailable |
| Group | Runtime Features |

## Request

**User input (implicit):**
```
Coordinator needs to search repository or execute shell tasks.
RTK context is available if wired.
```

## Expected Behavior

### Route
- Coordinator: Any
- Mode: Search/shell mode (transversal)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| Search results or shell output | created | RTK-accelerated or fallback result |

### Allocation
- N/A (RTK is runtime)

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| RTK active or fallback | trace | Coordinator reports: "using RTK" or "RTK unavailable, using fallback" |
| search works | result | Results returned (via RTK or fallback) |
| performance acceptable | time | Response time reasonable |

### State Update
- No state change (RTK is transparent)

## Must Not

- ❌ Error if RTK is not available (fallback must work)
- ❌ Claim RTK is active if it isn't (coordinator must be honest)
- ❌ Silently use fallback without user visibility

## Notes

This fixture validates RTK as either truly active (Wave 10) or explicit fallback behavior.
If RTK is not wired, this fixture must expect "RTK unavailable" message, not failure.
