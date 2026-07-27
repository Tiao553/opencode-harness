# E-001 - Ralph Loop Globalization

## Scope

Wave 5 made Ralph Loop a global executable-work contract.

## Files Changed

- `.specs/shared/execution-loop-contract.md`
- `.specs/shared/task-contract.md`
- `.specs/shared/todo-allocation-contract.md`
- `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
- `.specs/changes/harness-v3-ralph-loop-globalization/**`

## Evidence

Ralph Loop marker validator:

```text
ralph-loop-contract-ok
```

Fixture validator:

```text
Harness V3 fixture contract OK: 18 fixtures with ids, route/mode, verify clauses, and forbidden behavior
```

Grounding validator:

```text
grounding-links-ok
```

Marker grep:

```text
Loop Postures, Runtime Tool Rule, loop_posture, [loop:mandatory], and Ralph Loop Policy markers exist.
```

## Result

Executable work now carries loop posture:

- `mandatory`
- `advisory`
- `not_applicable`

Mandatory work requires step boundaries, verification, evidence, bounded repair, and explicit runtime-tool fallback behavior.
