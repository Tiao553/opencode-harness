# Fixture: Headroom Budget

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-12-headroom-budget |
| Title | Large context load triggered, Headroom budget checked |
| Purpose | Preserve behavior: Runtime checks context budget before heavy load, warns or blocks if unsafe, compression strategy applied if configured |
| Group | Runtime Features |

## Request

**User input (implicit):**
```
Coordinator attempts to load 10+ large files for complex task context.
Headroom plugin monitors budget.
```

## Expected Behavior

### Route
- Coordinator: `Altitude` (or any)
- Mode: Any (context loading happens transversally)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| Context loaded or truncated | n/a | Budget enforcement result |

### Allocation
- N/A (Headroom is runtime, not allocation)

### Todos
- None (Headroom is passive monitoring)

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| budget computed | runtime trace | Context size calculated before load |
| warning if close to limit | user message | Advisory shown if approaching budget |
| compression applied | trace | Compression or omission applied if configured |
| load successful or blocked | outcome | Safe load or explicit block message |

### State Update
- No state change (Headroom is advisory or enforcement-level)
- Context loading succeeds or fails based on budget policy

## Must Not

- ❌ Silently omit context without user visibility
- ❌ Load without budget check
- ❌ Crash on budget exceeded (should be graceful or warn)
- ❌ Claim budget enforcement if Headroom is not actually wired into runtime

## Notes

This fixture validates Headroom as either truly enforced (Wave 10) or explicitly advisory.
If Headroom is not active in runtime, this fixture must be marked "expected: advisory" or behavior adjusted.
