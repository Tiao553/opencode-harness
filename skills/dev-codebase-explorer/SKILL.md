---
name: dev-codebase-explorer
description: >-
  Use when the user needs codebase exploration, architecture analysis, code
  health assessment, or an executive summary of a project. Trigger phrases:
  'explore this codebase', 'give me an executive summary', 'analyze the
  architecture', 'what is the health score'. Do NOT use for feature
  implementation or code changes.
---

# Dev Skill: Codebase Explorer

## When to use

- User asks to explore, summarize, or map a codebase.
- User needs architecture diagrams or code health assessment.
- User asks "what is the health score of this project?"

## Workflow

1. Glob and read the top-level structure first.
2. Identify entry points, key modules, and test coverage.
3. Read README, configuration files, and architecture docs if present.
4. Produce a structured overview: entry points, dependency map, health signals, and recommended next reads.

## Output schema

```markdown
## Codebase Summary
## Entry Points
## Architecture Map (or diagram)
## Code Health Signals
## Recommended Next Reads
```

## Harness Integration

- **Invoked by:** Altitude Structure phase (T-023) to map repository surfaces before design.
- **Output feeds:** `01-structure.md` surface map section.
- **Gate:** W5 T-071 verifies skill discovery; W11 T-165 audits load receipt presence.

## Concrete output example

```markdown
## Codebase Summary
OpenCode harness: global config at ~/.config/opencode. 74 subagents, 35 commands, 7 skills, 6 plugins, 286-line AGENTS.md coordinator.

## Entry Points
- AGENTS.md — global instruction file loaded on every session
- opencode.json — runtime config: providers, agents, permissions, plugins

## Architecture Map
agents/ ──► opencode.json (inline config merge)
skills/ ──► lazy-loaded by AGENTS.md triggers
rules/  ──► lazy-loaded by trigger blocks (staged W4)
.specs/ ──► operational state and memory

## Code Health Signals
- AGENTS.md is 286 lines (target: ≤350 after W4 kernel rewrite)
- specs-state.ts plugin is a no-op shim (target: hardened in W9)
- docs/ is empty (deleted in pre-migration Wave 25A)

## Recommended Next Reads
- .specs/changes/harness-skill-based-migration/state.md
- rules/_registry.md
- staged/AGENTS.next.md
```

## Load receipt

When this skill is triggered as a mandatory skill:
```yaml
required_skills: [dev-codebase-explorer]
loaded_skills: [dev-codebase-explorer]
confirmed_by: "structured summary produced"
```

## Stop conditions

- STOP if the codebase has no entry point and the user has not specified what to explore.
- Do NOT make code changes — this skill is read-only analysis only.
