# State Resolution Contract

## Purpose

Provide the operational version of `docs/HARNESS_V3_STATE_RESOLUTION_CONTRACT.md` for agents and task contracts.

## Authority Order

```text
1. explicit user instruction in current turn
2. active task contract
3. active local allocation
4. active wave allocation
5. active phase allocation
6. active change request contract
7. durable artifacts in .specs/changes/...
8. machine-readable state file
9. memory notes
10. inferred repository context
```

## Required Outcome

Before execution, identify:

- active change or absence of one
- current phase/mode
- active task or absence of one
- allowed files and forbidden scope
- next valid action

## Conflict Rule

Conflicts block execution and must use `state-conflict-resolution-policy.md`.

