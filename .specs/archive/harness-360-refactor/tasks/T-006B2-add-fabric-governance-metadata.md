# Task

task_id: T-006B2
title: Add Fabric governance metadata and critical-claim register
status: validated
change: harness-360-refactor
owner_agent: altitude-execution
slice_type: kb-governance-rollout
effort_class: S

## Objective

Apply the KB governance standard to the Fabric domain entry surfaces by adding governance metadata and a critical-claim register.

## Context

After the first contradiction cluster is resolved, Fabric must start carrying the governance metadata expected from the new KB standard.

## Source References

- `docs/HARNESS_KB_GOVERNANCE_STANDARD.md`
- `kb/microsoft-fabric/index.md`
- `kb/microsoft-fabric/quick-reference.md`

## Allowed Files

- `kb/microsoft-fabric/index.md`
- `kb/microsoft-fabric/quick-reference.md`
- `kb/microsoft-fabric/specs/fabric-config.yaml`

## Forbidden Scope

- deeper Fabric concept/pattern files
- Fabric agent prompts

## Dependencies

- T-006B1

## Implementation Steps

1. Add or align governance metadata on the entry files.
2. Identify the first explicit critical-claim set.
3. Update machine-readable governance structure where needed.

## Acceptance Criteria

- Fabric entry files expose governance metadata consistent with the KB standard
- the first critical-claim set is explicit

## Verification Commands

- metadata review
- entry-point parity review

## Evidence Required

- updated Fabric entry files

## Rollback

Restore entry-file metadata if the chosen shape proves incompatible with the wider KB standard.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Verification completed or justified
- [x] Evidence saved
- [x] Execution ledger updated
- [x] Ready for validation
