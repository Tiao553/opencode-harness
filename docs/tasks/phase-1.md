---
name: agentic-task-phase-1
description: Phase 1 implementation checklist for integrity fixes.
---

# Phase 1

Reference: [AGENTIC_GAP_DOSSIER.md](/home/ubuntu/.config/opencode/docs/AGENTIC_GAP_DOSSIER.md)

Goal:

- Remove confirmed breakage before changing permissions, skills, or routing behavior.

Checklist:

- [x] Resolve the missing `graph-router` path.
- [x] Decide whether to add `agents/graph-router.agent.md` or remove all dead references.
- [x] Reconcile routing claims in [AGENTS.md](/home/ubuntu/.config/opencode/AGENTS.md), [agents/DEFAULT.AGENT.agent.md](/home/ubuntu/.config/opencode/agents/DEFAULT.AGENT.agent.md), and [agents/dev.agent-router.agent.md](/home/ubuntu/.config/opencode/agents/dev.agent-router.agent.md).
- [x] Fix the `visual-explainer` dependency chain.
- [x] Decide whether to restore `skills/visual-explainer/SKILL.md` or rewrite/remove dependent `visual:*` and `review:*` commands.
- [x] Fix the missing judge setup reference.
- [x] Decide whether to add `docs/getting-started/judge-setup.md` or remove all references to it.
- [x] Make `faithfulness_gate` and `verify_step` runtime exposure explicit.
- [x] Align [tools/](/home/ubuntu/.config/opencode/tools) usage with documented OpenCode tool loading expectations.
- [x] Normalize agent markdown structure.
- [x] Fix the structural outlier in [agents/dashboard-layout-specialist.agent.md](/home/ubuntu/.config/opencode/agents/dashboard-layout-specialist.agent.md).
- [x] Remove redundant template noise where it adds no behavioral value.

Done when:

- [x] No confirmed broken reference remains unresolved.
- [x] Tool claims are truthful about runtime integration.
- [x] The agent surface is structurally consistent enough to maintain.
