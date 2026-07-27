# Intent

## Problem

Wave 3B artifacts exist, but several templates and allocation contracts are too shallow to reliably guide future agents. They need explicit source authority, allocation, traceability, acceptance, evidence, and rollback fields.

## Goal

Make the artifact template and allocation layer enforceable enough for later Task-Spec, delegation, and runtime waves.

## Non-Goals

- Do not change runtime plugins.
- Do not delete legacy command surfaces.
- Do not change coordinator registration.
- Do not rewrite all older templates outside the official V3 set.

## Constraints

- Templates must stay readable and practical.
- Allocation must constrain local work before delegation.
- Validation must remain lightweight and file-based.
