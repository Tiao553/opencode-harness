# Harness V3 Grounding Split - Executive Report

change: harness-v3-grounding-split
status: validated
date: 2026-06-28
owner: altitude-report

## Executive Summary

The Grounding Split wave is complete. `config/grounding.md` is now a thin index over `.specs/shared` contracts instead of a monolithic policy file.

## Completed Work

- Replaced embedded grounding policies with contract references.
- Preserved legacy workflow behavior as compatibility-only.
- Separated documentation mode from production code mode.
- Made Ask-User, todo projection, allocation, and specialist allocation explicit references.
- Validated all referenced shared-contract files exist.

## Validation Evidence

- `.specs/changes/harness-v3-grounding-split/evidence/E-001-grounding-split.md`
- `.specs/changes/harness-v3-grounding-split/04-validation.md`

## Risk

The split is policy/documentation-only. Runtime enforcement still depends on later plugin/runtime integration waves.

## Next Recommended Action

Open the Strategic Coordinator Introduction wave or harden fixture semantic validation before modifying coordinator/runtime behavior.

