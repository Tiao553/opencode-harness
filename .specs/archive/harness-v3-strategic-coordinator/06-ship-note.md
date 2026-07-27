# Harness V3 Strategic Coordinator - Ship Note

change: harness-v3-strategic-coordinator
status: shipped
date: 2026-06-28
owner: altitude-report

## Summary

Shipped the visible strategic `altitude` coordinator.

## What Shipped

- one visible `altitude` primary agent
- hidden phase-specific `altitude-*` subagents
- coordinator prompt that owns classification, state resolution, phase routing, allocation, and execution gates

## Validation Reference

```text
opencode-json-ok
altitude -> primary
altitude-* -> subagent hidden
```

## Risks Accepted

- No live OpenCode session was executed through the coordinator in this validation.
- The phase agents still exist for internal routing and rollback.

## Follow-Up

Create the second visible coordinator: Data Engineer.

