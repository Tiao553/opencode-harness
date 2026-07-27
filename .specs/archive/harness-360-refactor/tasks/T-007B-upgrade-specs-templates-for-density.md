# Task

task_id: T-007B
title: Upgrade .specs templates for density
status: validated
change: harness-360-refactor
owner_agent: altitude-execution
slice_type: template-hardening
effort_class: M

## Objective

Upgrade the `.specs` templates so operational artifacts require architecture context, traceability, evidence intent, and stronger KT structure.

## Context

The `.specs` templates were structurally minimal and encouraged shallow operational documents.

## Why This Slice Exists

The harness cannot ask future artifacts to be dense if the operational templates still bias toward minimal headings and low-context notes.

## Architecture Context

### Current State

```text
Operational ledger templates capture basic fields, but many omit the system boundary, traceability, failure modes, or evidence interpretation needed by humans and smaller models.
```

### Target State

```text
Operational templates require enough architecture, verification, and evidence context to support execution, validation, reporting, and KT without chat history.
```

### Impact Diagram

```mermaid
flowchart LR
    A[.specs templates] --> B[Execution and validation artifacts]
    B --> C[Operators, reviewers, smaller models]
    C --> D[Lower ambiguity and better KT]
```

## Source References

- `.specs/shared/markdown-authoring-standard.md`
- `.specs/templates/*.md`

## Allowed Files

- `.specs/templates/*.md`

## Forbidden Scope

- `sdd/templates/**`
- runtime config

## Dependencies

- T-007A

## Edge Cases and Failure Modes

| Case | Why It Matters | Expected Handling |
| --- | --- | --- |
| Templates become verbose but still generic | KT does not improve | Add topology, traceability, and evidence-aware sections |

## Implementation Steps

1. Upgrade change and task templates.
2. Upgrade state, evidence, validation, and report templates.
3. Add author notes where misuse is common.

## Acceptance Criteria

| ID | Criterion | Verification Method | Evidence |
| --- | --- | --- | --- |
| AC-001 | `.specs` templates include denser architecture or traceability structure | Read templates | `.specs/templates/*.md` |
| AC-002 | Task and validation templates are evidence-friendly | Read templates | same artifact set |

## Verification Commands

| Command | Purpose | Expected Signal |
| --- | --- | --- |
| manual review | Confirm representative templates are materially denser | Architecture, traceability, verification, and KT sections present |

## Evidence Required

| Evidence | Why It Is Needed |
| --- | --- |
| updated `.specs/templates/*.md` | proves the operational authoring surface changed |

## Rollback

Restore prior templates if the new structure is unusably heavy.

## Reviewer Notes

Density is the goal; decorative section growth is not.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Verification completed or justified
- [x] Evidence saved
- [x] Execution ledger updated
- [x] Ready for validation
