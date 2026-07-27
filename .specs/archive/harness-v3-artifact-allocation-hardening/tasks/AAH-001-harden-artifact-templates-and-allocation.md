# AAH-001 - Harden Artifact Templates and Allocation

## Status

validated

## Objective

Upgrade official V3 templates and allocation contracts so later work has concrete fields for source authority, allocation, traceability, validation, evidence, and rollback.

## Acceptance Criteria

- PRD, ADR, TEST-SPEC, validation report, and ship summary templates include allocation and evidence fields.
- Allocation contracts define precedence, broadening rules, and Task-Spec mapping.
- Template catalog explains required fields and not-applicable handling.
- Validation proves required sections exist.

## Steps

1. [x] Harden official templates -> verify: required section validator passes.
2. [x] Harden allocation contracts -> verify: precedence and broadening rules exist.
3. [x] Update catalog -> verify: template inventory references allocation/evidence rules.
4. [x] Record evidence and validation -> verify: wave can ship.
