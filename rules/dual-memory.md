# Dual-Memory Rule

**Trigger:** Any memory write or memory read operation.
**Load scope:** Lazy — loaded when a memory event fires.
**Governing ADR:** ADR-0003. Source: `.specs/shared/memory-contract.md`.

---

## Core rule

Write to `.specs/memory/` first, always. MCP duplicate is written second and non-blocking.

## Required write triggers

| Trigger | When |
|---|---|
| `phase_gate` | Every Altitude phase transition |
| `bloco_completion` | Every validation block closes |
| `conflict_resolution` | Any state conflict resolved |
| `specialist_handoff` | A leaf subagent is allocated |
| `critical_failure` | A task is blocked and recovery starts |

## Write procedure

1. Compose YAML event with `entry_id`, `timestamp`, `trigger`, `change_id`, `agent`, and trigger-specific fields.
2. Write to `.specs/memory/{change_id}/{entry_id}.yaml` — **blocking**.
3. Append to `.specs/memory/index.md`.
4. Attempt MCP duplicate async — **non-blocking**; log status.

## Read procedure

Read local `.specs/memory/` first. MCP recall is supplementary. If they disagree: local wins (ADR-0005 priority 8 > 10).

## Evidence must NOT contain

Secrets, tokens, PII, raw MCP dumps, or non-ISO-8601 timestamps.

## Stop conditions

- STOP if the local write fails — do not proceed without a local record.
- STOP if an event would require storing a secret value.

---

*Governing: ADR-0003, `.specs/shared/memory-contract.md`.*
