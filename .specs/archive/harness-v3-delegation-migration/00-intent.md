# Intent

## Problem

Harness V3 says delegation is a subset of allocation, but the specialist contract still lacks task-level grounding bundle requirements, evidence contracts, and over-delegation gates.

## Goal

Move specialist delegation out of late execution decisions and into explicit allocation/task contracts.

## Non-Goals

- Do not rewrite subagents.
- Do not remove workflow build surfaces.
- Do not add runtime delegation tooling.
- Do not change visible coordinator registration.

## Constraints

- Specialists must be allocated before execution.
- Specialist output must be validated by the owning coordinator or task owner.
- Delegation must never broaden scope silently.
