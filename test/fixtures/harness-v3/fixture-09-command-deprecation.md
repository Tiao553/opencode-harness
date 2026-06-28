# Fixture: Command Deprecation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-09-command-deprecation |
| Title | Legacy workflow:* command called |
| Purpose | Preserve behavior: Old commands route through compatibility wrapper, user sees deprecation notice, routed to coordinator path |
| Group | Legacy & Command Behavior |

## Request

**User input:**
```
"/workflow:build"
```

## Expected Behavior

### Route
- Coordinator: Compatibility router → `Altitude` (internal)
- Mode: `deprecated_command_gate`

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| Deprecation notice | printed | User sees command is deprecated and which path to use instead |
| Routing to Altitude | silently | User still gets the work done |

### Todos
- None (pass-through behavior)

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| deprecation notice shown | user output | Clear message: "workflow:* is deprecated, use Altitude coordinator instead" |
| routing works | behavior | Request is routed to Altitude build logic |
| no error | exit code | Deprecation is advisory, not fatal |

### State Update
- No state change (routing is transparent)

## Must Not

- ❌ Error on deprecated command (breaks existing workflows during transition)
- ❌ Hide the deprecation warning
- ❌ Remove the command in Wave 1A (must soft-deprecate first)
- ❌ Change the command's behavior

## Notes

This fixture validates soft-deprecation workflow during command migration.
Wave 1A soft-deprecates, Wave 1B hard-removes, but this fixtures ensures 1A doesn't break existing usage.
