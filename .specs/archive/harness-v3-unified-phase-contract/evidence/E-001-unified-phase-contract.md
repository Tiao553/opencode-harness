# E-001 - Unified Phase Contract

## Scope

Wave 3 tightened the Harness V3 phase authority without mutating runtime behavior or deleting legacy commands.

## Files Changed

- `docs/HARNESS_V3_PHASE_ENGINE_SPEC.md`
- `.specs/shared/phase-engine-contract.md`
- `.specs/shared/compatibility-policy.md`
- `.specs/changes/harness-v3-unified-phase-contract/**`

## Evidence

Contract mapping check:

```text
12 matches across:
- docs/HARNESS_V3_PHASE_ENGINE_SPEC.md
- .specs/shared/phase-engine-contract.md
- .specs/shared/compatibility-policy.md
```

Fixture check:

```text
Harness V3 fixture contract OK: 18 fixtures with ids, route/mode, verify clauses, and forbidden behavior
```

Grounding check:

```text
grounding-links-ok
```

Coordinator registration check:

```text
coordinator-config-ok
```

## Result

The old workflow lifecycle is now explicitly mapped into Harness V3 phase behavior:

- Brainstorm -> Intent
- Define -> PRD or Intent requirements
- Design -> Structure plus Design/Plan
- Build -> Execution of approved task or batch
- Validate -> Validate
- Ship -> Ship
- Iterate -> gated repair to the owning phase

`workflow:*` remains a compatibility wrapper, not a phase authority.
