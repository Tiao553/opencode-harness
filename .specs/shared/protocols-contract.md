# Protocols Contract — Wave 14 (Agent Messaging)

**Wave:** 14 (Inter-Agent Protocols & Messaging)  
**Version:** 1.0  
**Date:** 2026-06-30  
**Status:** Active  

---

## 1. Purpose

This contract defines the standardized inter-agent communication protocol for Harness V3, enabling agents to coordinate work without direct coupling.

---

## 2. Message Schema

```yaml
message:
  version: "1.0"
  message_id: "msg-uuid"
  timestamp: "2026-06-30T12:00:00Z"
  sender: "agent-name"
  receiver: "agent-name" | "broadcast"
  topic: "string"
  payload: "object"
  
  # Optional
  reply_to: "msg-uuid"
  priority: "high" | "normal" | "low"
  timeout: 30 # seconds
  ack_required: true | false
```

---

## 3. Topics

Standard topics for inter-agent coordination:

- `phase.transition` — Phase change notification
- `task.created` — New task assigned
- `task.completed` — Task finish notification
- `error.recovery` — Error recovery in progress
- `validation.request` — Request validation
- `validation.result` — Validation result
- `metrics.report` — Metrics/observability data
- `coordination.lock` — Work coordination lock

---

## 4. Delivery Guarantees

- **At-least-once:** Messages are retried if not acked
- **Ordered:** Messages to same receiver processed in order
- **Timeout:** Default 30s, configurable per message
- **No persistence:** Messages are in-memory only (no replay after restart)

---

## 5. Tool Command Reference

`tools/agent-messenger.sh publish <topic> <message>`
`tools/agent-messenger.sh subscribe <topic>`
`tools/agent-messenger.sh route <message> <target>`
`tools/agent-messenger.sh ledger <change_id>`

---

**Reference Document:** `.specs/shared/protocols-contract.md`
