# Harness V3 Data Engineer Coordinator - Ship Note

change: harness-v3-data-engineer-coordinator
status: shipped
date: 2026-06-28
owner: altitude-report

## Summary

Shipped the visible tactical `data-engineer` coordinator.

## What Shipped

- `agents/data-engineer.agent.md`
- `docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md`
- `opencode.json` primary agent registration

## Validation Reference

```text
coordinator-config-ok
data-engineer -> primary
altitude -> primary
tactical route coverage present
```

## Risks Accepted

- Specialist execution was not live-tested.
- Legacy `/data:*` command files were not deleted or rewritten.

## Follow-Up

Audit the Unified Phase Contract wave and then continue toward Task-Spec integration.

