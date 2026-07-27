# Task

task_id: T-006B3
title: Audit remaining Fabric high-impact claims for quick-reference parity
status: validated
change: harness-360-refactor
owner_agent: altitude-execution
slice_type: kb-audit
effort_class: M

## Objective

Audit the remaining high-impact Fabric claims that influence architecture, deployment, and security decisions, and check parity between entry files and deeper files.

## Context

After the first contradiction cluster and governance metadata land, the Fabric domain still needs a focused audit on other high-impact claims.

## Source References

- `docs/HARNESS_KB_GOVERNANCE_STANDARD.md`
- `kb/microsoft-fabric/index.md`
- `kb/microsoft-fabric/quick-reference.md`

## Allowed Files

- `.specs/changes/harness-360-refactor/evidence/E-004-fabric-governance-rollout-and-parity-audit.md`
- `.specs/changes/harness-360-refactor/02-decomposition.md`
- `.specs/changes/harness-360-refactor/tasks/T-006B3-audit-fabric-high-impact-claims.md`
- `.specs/changes/harness-360-refactor/tasks/T-009A-repair-fabric-eventhouse-warehouse-parity.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`

## Forbidden Scope

- broad full-domain rewrite

## Dependencies

- T-006B2

## Implementation Steps

1. enumerate remaining critical claims
2. rank by risk
3. choose the next contradiction cluster
4. prepare the focused repair task or tasks

## Acceptance Criteria

- the remaining high-impact Fabric claims are triaged by risk and parity posture
- any unresolved high-impact parity gap produces a focused next task instead of a broad rewrite

## Verification Commands

- claim inventory review

## Evidence Required

- triage notes in the ledger and resulting focused next tasks

## Rollback

No product rollback; this is an audit slice.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Verification completed or justified
- [x] Evidence saved
- [x] Execution ledger updated
- [x] Ready for validation
