# Intent

## Problem

Harness V3 documents Ralph Loop as mandatory for executable work, but the operational contract does not yet define loop posture, runtime-tool fallback, task fields, evidence requirements, or coordinator responsibilities in enough detail for later enforcement.

## Goal

Turn Ralph Loop into a global executable-work contract that applies to code edits, config edits, runtime changes, critical artifact generation, and validation work.

## Non-Goals

- Do not change runtime plugin code.
- Do not require `verify_step` to be present in every runtime.
- Do not convert every answer-only task into a loop.
- Do not remove legacy commands.

## Constraints

- Runtime enforcement must not be claimed unless the active runtime exposes the tool.
- Manual loop evidence is valid when runtime verification tooling is unavailable.
- Every executable task must carry loop posture before execution.
