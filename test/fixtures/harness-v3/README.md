# Harness V3 Golden Fixtures

## Purpose

These fixtures define expected Harness V3 behavior before runtime, command, coordinator, or plugin migration. They are intentionally markdown-first so the behavior can be reviewed before an automated runner hardens it.

## Fixture Contract

Every fixture must define:

- `id`
- `request`
- `expected_route`
- `expected_mode`
- `expected_artifacts`
- `expected_allocation`
- `expected_context`
- `expected_todos`
- `expected_validation`
- `expected_state`
- `must_not`

## Fixture Inventory

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

## Runner Readiness

These fixtures become runner-ready when a parser validates the contract fields, route values, forbidden behaviors, and state transitions. Until then, they are reviewable golden behavior snapshots.
