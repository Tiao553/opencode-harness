# Context Loading Policy

## Purpose

Keep Harness V3 context loading deliberate, bounded, and traceable.

## Loading Order

```text
1. current user request
2. active state
3. active task or mode contract
4. directly referenced files
5. source references from task/artifact
6. minimal repo search
7. deeper docs/KB only when blocked
```

## Rules

- Do not preload all agents, skills, KBs, or docs.
- Prefer `index.md` or `quick-reference.md` before deep concept files.
- Load memory when the task depends on active repo/project state.
- For high-risk claims, verify current official docs when facts can drift.
- Use RTK or equivalent token-efficient reads when available.

## Evidence

For complex work, record the loaded context in the task, evidence, report, or final response when traceability matters.

