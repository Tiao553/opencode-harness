# Harness V3 Strategic Coordinator - Executive Report

change: harness-v3-strategic-coordinator
status: validated
date: 2026-06-28
owner: altitude-report

## Executive Summary

The strategic coordinator wave is complete. The harness now exposes one visible `altitude` coordinator for durable strategic work, while the old phase-specific `altitude-*` agents remain available as hidden internal subagents.

## Completed Work

- Created `agents/altitude.agent.md`.
- Updated `opencode.json` with `altitude` as primary.
- Demoted `altitude-intent`, `altitude-structure`, `altitude-plan`, `altitude-execution`, `altitude-validation`, `altitude-report`, and `altitude-memory` to hidden subagents.
- Updated phase-agent frontmatter from `mode: primary` to `mode: subagent`.
- Updated the coordinator contract with runtime registration.

## Validation Evidence

- `.specs/changes/harness-v3-strategic-coordinator/evidence/E-001-altitude-coordinator.md`
- `.specs/changes/harness-v3-strategic-coordinator/04-validation.md`

## Risk

Validation confirms config shape, not a live OpenCode interaction through the new coordinator.

## Next Recommended Action

Open the Tactical Data Engineer Coordinator wave.

