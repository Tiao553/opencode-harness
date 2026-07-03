# Harness V3 Migration Test Plan

## Purpose

Capture golden behavior before runtime, command, coordinator, or plugin migration. These tests prevent a cleaner architecture from silently deleting useful behavior.

## Fixture Schema

Each fixture should define:

| Field | Meaning |
| --- | --- |
| `id` | stable fixture identifier |
| `request` | user prompt or command |
| `expected_route` | coordinator/command path |
| `expected_mode` | phase or tactical mode |
| `expected_artifacts` | artifacts created/read/updated |
| `expected_allocation` | global/local/specialist allocation |
| `expected_context` | minimum context loaded |
| `expected_todos` | todo projection with verify clauses |
| `expected_validation` | tests/manual checks/evidence |
| `expected_state` | machine state transition |
| `must_not` | forbidden behavior |

## Golden Fixtures

| ID | Scenario | Expected route |
| --- | --- | --- |
| fixture-01-strategic-new-change | user requests new durable architecture work | Altitude Intent |
| fixture-02-resume-existing-change | active `.specs` state exists | Altitude current phase |
| fixture-03-state-conflict | task/state/memory disagree | state conflict gate |
| fixture-04-tactical-sql-fix | bounded SQL issue | Data Engineer tactical |
| fixture-05-data-quality-investigation | data-quality diagnosis | Data Engineer tactical |
| fixture-06-documentation-generation | dense architecture doc | Altitude artifact path |
| fixture-07-visual-artifact-request | final diagram/visual | `visual:*` |
| fixture-08-readme-generation | README update | `core:readme-maker` |
| fixture-09-command-deprecation | legacy command route | compatibility notice |
| fixture-10-task-spec-leaf-generation | S/M leaf task | Task-Spec bridge |
| fixture-11-specialist-allocation | task needs specialist | allocation before delegation |
| fixture-12-headroom-budget | large context load | Headroom enforced or advisory result |
| fixture-13-rtk-context | shell/search work | RTK active or explicit fallback |
| fixture-14-prd-generation | requirements-heavy change | PRD artifact |
| fixture-15-adr-generation | architecture trade-off | ADR artifact |
| fixture-16-test-spec-generation | validation-heavy change | TEST-SPEC artifact |
| fixture-17-global-allocation | wave/phase ownership | global allocation |
| fixture-18-local-allocation | task/todo ownership | local allocation |

## Acceptance Criteria

- Every fixture has an expected route.
- Every fixture has an expected state outcome.
- Every executable fixture has expected verification.
- Every fixture names forbidden behavior.
- Runtime mutation cannot begin until the fixture set exists.

## First Implementation Strategy

Start with markdown fixtures under `test/fixtures/harness-v3/`. Do not require a full automated runner until the expected behavior is stable. The first lightweight validator is:

```bash
test/fixtures/harness-v3/validate-fixtures.sh
```

It verifies the expected fixture count, required contract sections, filename/id alignment, non-empty route and mode sections, `verify:` clauses in todos, and forbidden-behavior bullets. Later waves can replace or extend it with a parser that validates route values, state transitions, and allocation inheritance.
