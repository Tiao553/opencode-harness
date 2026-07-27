---
id: W14-PROTOCOLS
title: "Wave 14: Multi-Agent Communication Protocol"
status: implemented
effort: M
budget: 48000
agent: altitude-execution
severity: feature
depends_on: [W7-RALPH-LOOP]
completed_at: 2026-06-29T23:51Z
tokens_used: 18000
touches_paths:
  - .specs/shared/protocol-contract.md
  - tools/agent-messenger.sh
  - tools/agent-messenger.contract.md
  - agents/altitude-*.agent.md
  - test/fixtures/harness-v3/wave-14-protocols-smoke.fixture.md
---

# Wave 14: Multi-Agent Communication Protocol

## Goal

Agent-to-agent messaging with routing and acknowledgments:
- ✅ Message format (JSON with routing)
- ✅ Queue and delivery system
- ✅ Acknowledgments
- ✅ All agents updated
- ✅ 2 smoke scenarios

## Success Criteria

```bash
eval_1() { grep -q "message_format:" .specs/shared/protocol-contract.md; }
eval_2() { tools/agent-messenger.sh send --to altitude-execution --msg '{}' > /dev/null 2>&1; }
eval_3() { grep -q "agent-messenger" agents/altitude-execution.agent.md; }
eval_4() { bash test/fixtures/harness-v3/wave-14-protocols-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```
