# Intent

## Problem

Harness V3 already has phase-engine documentation, but the shared operational contract is too thin to prove the Wave 3 roadmap exit criteria. Useful legacy workflow semantics from `sdd/architecture/WORKFLOW_CONTRACTS.yaml` must be named as compatibility behavior and absorbed into V3 phase authority.

## Goal

Make the unified phase contract the clear authority for durable work while preserving the useful workflow lifecycle semantics as mapped compatibility behavior.

## Non-Goals

- Do not remove commands.
- Do not rewrite workflow agents.
- Do not mutate runtime plugins in this wave.
- Do not change user-facing command names.

## Constraints

- `Altitude` remains the strategic coordinator.
- `workflow:*` commands remain compatibility wrappers.
- Human-gated phase movement remains mandatory.
- Existing V3 fixtures must keep passing.
