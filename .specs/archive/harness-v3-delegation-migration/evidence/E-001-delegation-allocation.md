# E-001 - Delegation Allocation

## Scope

Wave 7 migrated delegation rules into allocation/task contracts.

## Files Changed

- `.specs/shared/specialist-allocation-contract.md`
- `.specs/shared/local-allocation-contract.md`
- `.specs/shared/task-contract.md`
- `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
- `agents/altitude.agent.md`

## Evidence

Delegation marker validator:

```text
delegation-allocation-contract-ok
```

Fixture validator:

```text
Harness V3 fixture contract OK: 18 fixtures with ids, route/mode, verify clauses, and forbidden behavior
```

Grounding validator:

```text
grounding-links-ok
```

## Result

Specialist use now requires pre-execution allocation, grounding bundle, evidence contract, validation responsibility, stop condition, and an accepting owner. The contracts also define over-delegation rules and prevent specialists from becoming hidden task owners.
