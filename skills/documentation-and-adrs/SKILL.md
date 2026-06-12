---
name: documentation-and-adrs
description: README, design notes, ADRs, and decision capture workflow. Use when documenting systems, APIs, or architectural decisions for humans who were not in the chat.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: lifecycle
---

# Documentation And ADRs

## When to Use

- Use when producing README content, module documentation, runbooks, or ADR-style decisions.
- Use when the output must explain what was decided, why it was decided, and how to use or operate it.
- Do not use when the task is a quick internal note with no lasting value.

## Workflow

1. Identify the audience: operator, maintainer, contributor, or reviewer.
2. Capture only facts that are supported by code, artifacts, or explicit requirements.
3. For ADRs, record context, decision, alternatives, and consequences.
4. For usage docs, verify that quick-start or example steps match the current codebase.
5. Prefer concise structure over exhaustive prose.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "The code already explains it." | Important decisions and operational steps often do not live in code. |
| "We can document the rationale later." | Architecture history degrades quickly when context is not captured immediately. |
| "A broad README section is enough." | Decision records and operational docs solve different problems. |

## Red Flags

- The document states decisions without rationale.
- Example commands were not checked against the current project shape.
- Architecture trade-offs are implied but not written.
- The target audience is unclear.

## Verification

- [ ] The audience was identified.
- [ ] Claims are grounded in code, specs, or artifacts.
- [ ] ADRs include context, decision, alternatives, and consequences.
- [ ] Usage or setup steps reflect the current repository.
- [ ] The document is concise enough for the target audience.
