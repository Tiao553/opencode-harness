# Intent

## Problem

Harness V3 identifies `skills/task-spec/` as the official leaf-task engine, but the bridge from `.specs` change state, allocation, and artifacts into Task-Spec is not yet documented or represented in the Task-Spec template.

## Goal

Make Task-Spec the leaf-task engine while preserving `.specs/changes/...` as the change-level control surface.

## Non-Goals

- Do not replace `.specs` as the durable change ledger.
- Do not rewrite Task-Spec validator semantics.
- Do not require Task-Spec for L/XL work.
- Do not remove legacy commands.

## Constraints

- Integration must be additive to Task-Spec v2.1/v2.2 fields.
- Task-Spec must inherit allocation and artifact context.
- Task-Spec must not become a second control plane.
