---
name: agentic-task-phase-3
description: Phase 3 implementation checklist for skill conversion.
---

# Phase 3

Reference: [AGENTIC_GAP_DOSSIER.md](/home/ubuntu/.config/opencode/docs/AGENTIC_GAP_DOSSIER.md)

Goal:

- Move reusable process logic out of large prompts and router-like skills into real workflow skills.

Checklist:

- [x] Add a real `using-agent-skills` skill.
- [x] Make skill discovery the default first step for ambiguous work.
- [x] Extract `define` into a dedicated workflow skill.
- [x] Move extraction, clarity scoring, and gap-filling out of [agents/workflow.define-agent.agent.md](/home/ubuntu/.config/opencode/agents/workflow.define-agent.agent.md).
- [x] Extract `design` into a dedicated workflow skill.
- [x] Move architecture, ADR, file-manifest, and validation-contract logic out of [agents/workflow.design-agent.agent.md](/home/ubuntu/.config/opencode/agents/workflow.design-agent.agent.md).
- [x] Convert router-like skills into process skills.
- [x] Reduce registry-like prose in [skills/workflow-commands/SKILL.md](/home/ubuntu/.config/opencode/skills/workflow-commands/SKILL.md), [skills/review/SKILL.md](/home/ubuntu/.config/opencode/skills/review/SKILL.md), [skills/core-commands/SKILL.md](/home/ubuntu/.config/opencode/skills/core-commands/SKILL.md), and [skills/data-engineering/SKILL.md](/home/ubuntu/.config/opencode/skills/data-engineering/SKILL.md).
- [x] Add workflow, rationalizations, red flags, and verification sections where missing.
- [x] Remove duplicated process prose from core agents after the new skills exist.

Done when:

- [x] `define` and `design` are skill-driven rather than prompt-heavy.
- [x] Skills carry reusable process logic.
- [x] Agents are materially smaller and clearer.
