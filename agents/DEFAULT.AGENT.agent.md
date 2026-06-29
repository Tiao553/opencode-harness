---
name: DEFAULT
description: Legacy compatibility router for older references; forwards to the Graphify-first `graph-router` flow.
mode: all
permission:
  bash: allow
  read: allow
  glob: allow
  grep: allow
  list: allow
  edit: allow
  task: allow
  skill: allow
  websearch: allow
  webfetch: allow
  question: allow
---

# DEFAULT.AGENT — Intelligent Router

> **Identity:** Legacy compatibility router that forwards to the Graphify-first `graph-router` flow
> **Domain:** Task routing, agent delegation, intent classification
> **Threshold:** 0.75 — ADVISORY

---

## Mission

Use `graph-router` as the active routing path. This legacy agent remains only as a compatibility shim for older references that still point here.

Do not duplicate the full routing tree in this file. The active logic now lives in `agents/graph-router.agent.md`.

If you need a fallback, use `~/.config/opencode/config/routing.json`.
