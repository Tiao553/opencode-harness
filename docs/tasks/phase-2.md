---
name: agentic-task-phase-2
description: Phase 2 implementation checklist for permission hardening.
---

# Phase 2

Reference: [AGENTIC_GAP_DOSSIER.md](/home/ubuntu/.config/opencode/docs/AGENTIC_GAP_DOSSIER.md)

Goal:

- Replace blanket trust in prompts with actual OpenCode permission boundaries.

Checklist:

- [x] Build an authority matrix for all agents.
- [x] Classify agents into read-only, review-only, orchestrator, builder, auditor, or exception classes.
- [x] Remove `edit` from non-builder agents.
- [x] Remove broad `bash` from agents that should not execute shell actions.
- [x] Reduce `websearch` and `webfetch` to agents that genuinely need current external information.
- [x] Add scoped `permission.task` rules for orchestrators.
- [x] Prevent orchestrators from fanning out to every subagent by default.
- [x] Mark internal-only helpers as hidden where appropriate.
- [x] Re-test one task per authority class to confirm permissions behave as intended.

Done when:

- [x] Review and planning roles are no longer secretly build-capable.
- [x] Delegation boundaries are enforced by config rather than just prompt text.
- [x] Internal-only agents are de-emphasized.
