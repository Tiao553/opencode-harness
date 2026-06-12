---
name: using-agent-skills
description: Ambiguous request, skill discovery, route through skills before agents or fallback routing. Use when the request could match multiple command or domain workflows and you need the smallest useful skill first.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: routing
---

# Using Agent Skills

## When to Use

- Use when the request is ambiguous and could map to multiple skills, commands, or specialist agents.
- Use when the user asks in natural language and there is no explicit slash command yet.
- Use when the work is non-trivial and a reusable workflow likely exists.
- Do not use when the user already invoked an explicit native command.
- Do not use when the task is a single obvious file edit with no domain ambiguity.

## Workflow

1. Check for an explicit native command first. If present, that command wins.
2. If the request is a natural-language workflow phase, route to the matching native command before selecting an agent.
3. If the request is ambiguous, identify the smallest candidate skill set from user words, file names, and deliverable type.
4. Load one skill, not many. Expand only if the first skill cannot complete the task.
5. Only after skill selection should generic routing, fallback routing, or specialist agent delegation happen.
6. Keep context loading lazy: load the command file, skill, and only the supporting references needed for the active branch.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "I can jump straight to an agent because I know the repo." | Skipping skill discovery duplicates workflow logic and makes routing inconsistent. |
| "Loading several skills is safer." | Preloading many skills defeats the smallest-useful-context rule. |
| "Fallback routing is close enough." | Fallback routing is for low-confidence cases after skill discovery, not before it. |

## Red Flags

- The same request could plausibly map to more than one command family.
- The answer starts selecting agents before checking for a reusable skill.
- Multiple skills are loaded speculatively with no blocker.
- Generic routing is used even though a native command is an obvious fit.

## Verification

- [ ] Explicit native commands were checked first.
- [ ] Ambiguous requests went through skill discovery before fallback routing.
- [ ] Only the smallest useful skill was loaded.
- [ ] Additional context was loaded lazily, not preloaded.
- [ ] Any fallback to routing was explained by ambiguity or low confidence.
