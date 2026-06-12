---
name: agentic-task-phase-4
description: Phase 4 implementation checklist for agent consolidation.
---

# Phase 4

Reference: [AGENTIC_GAP_DOSSIER.md](/home/ubuntu/.config/opencode/docs/AGENTIC_GAP_DOSSIER.md)

Goal:

- Reduce overlapping agents after skills and permissions are stabilized.

Checklist:

- [x] Collapse the Spark cluster into a front door plus a diagnostics path.
- [x] Move Spark troubleshooting and optimization detail into skills where possible.
- [x] Collapse the Lakeflow cluster into one front door plus one extra role only if justified.
- [x] Merge prompt and LLM specialists into a smaller coherent set.
- [x] Keep one obvious default route for general prompt or LLM work.
- [x] Merge duplicated Supabase coverage into one canonical backend route.
- [x] Simplify Fabric and AWS/GCP specialist splits where the difference is mostly template wording.
- [x] Update [config/routing.json](/home/ubuntu/.config/opencode/config/routing.json) before disabling or deleting redundant agents.

Done when:

- [x] High-overlap clusters are materially smaller.
- [x] Routing favors clear front doors over duplicate variants.
- [x] Disabled or removed agents are no longer active discovery paths.
