# Compatibility Policy

## Purpose

Define how legacy commands, agents, skills, and docs survive during Harness V3 migration.

## Rule

Compatibility is allowed only when a legacy surface routes into the V3 model or remains as a clearly bounded exception.

## Classes

| Class | Meaning |
| --- | --- |
| retained | remains primary |
| compatibility wrapper | remains but delegates to V3 authority |
| absorbed | behavior moved into contracts/coordinators |
| advisory | kept as reference, not authority |
| removed | deleted after preservation fixtures pass |

## Current Compatibility Classes

| Surface | Class | Owner |
| --- | --- | --- |
| `workflow:*` commands | compatibility wrapper | `Altitude` plus `phase-engine-contract` |
| `/data:*` commands | compatibility wrapper | `Data Engineer` tactical coordinator |
| `sdd/architecture/WORKFLOW_CONTRACTS.yaml` | advisory migration reference | `phase-engine-contract` |
| old workflow phase agents | advisory or subagent-only during migration | coordinator contract |
| `core:readme-maker` | retained | command surface |
| `visual:*` | retained | command surface |

## Workflow Wrapper Requirements

Any surviving `workflow:*` path must:

- load `.specs/shared/phase-engine-contract.md`
- resolve active state before creating or mutating artifacts
- treat old SDD artifacts as compatibility evidence, not current authority
- preserve the build output gate while routing execution through approved tasks
- preserve validation evidence while reporting verdict through V3 validation artifacts
- update `.specs/changes/...` state when work is durable
- stop when the requested action would skip a human gate

## Removal Gate

Before removal:

- useful behavior is named
- new owner is named
- fixture proves replacement behavior
- rollback path exists
