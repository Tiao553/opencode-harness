# ADR-001 Control Plane and Ledger Strategy

status: accepted
date: 2026-06-25
change: harness-360-refactor

## Context

The harness currently behaves like two systems at once:

- `Altitude + .specs` as the intended durable coordinator
- `workflow:* + sdd/features` as a still-live operational model

This increases drift, weakens trust, and makes decomposition and gating inconsistent.

## Decision

Adopt the following control-plane rules:

- `Altitude` is the primary coordinator for durable work.
- `.specs/changes/...` is the operational ledger.
- `docs/...` is the shareable mirror.
- `/workflow:*` remains as a compatibility wrapper, not a competing runtime.
- ambiguous intake uses explore plus interview/grill before deeper routing.

## Alternatives Considered

### Keep the current hybrid alive permanently

Rejected because it preserves split-brain behavior.

### Make `workflow:*` the primary coordinator again

Rejected because the current target direction is already centered on `Altitude` and `.specs`.

### Keep only the home-global artifacts and remove local mirrors

Rejected because the harness still benefits from a shareable mirror surface in `docs/`.

## Consequences

- future workflow docs and routing must align to the `Altitude` model
- decomposition must happen before execution
- any remaining `knowledge_context/` dependency becomes migration work
- master plan and live ledger must now be updated together

## Evidence

- `AGENTS.md`
- `docs/ALTITUDE_SPECS_HARNESS.md`
- `.specs/shared/altitude-contract.md`
- `skills/workflow-commands/SKILL.md`
- `skills/workflow-commands/commands/build.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`
