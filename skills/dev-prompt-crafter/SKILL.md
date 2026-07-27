---
name: dev-prompt-crafter
description: >-
  Use when the user needs to build a PROMPT.md file with SDD-lite phases,
  agent matching, or context-aware task specifications. Trigger phrases:
  'create a PROMPT.md', 'build a prompt spec', 'match agents to files',
  'design a prompt for this task'. Do NOT use for general prompt engineering
  or LLM output optimization — use dev-llm-specialist for that.
---

# Dev Skill: Prompt Crafter

## When to use

- User needs a structured PROMPT.md for agentic task delegation.
- User wants to decompose a task into agent-matched sub-specifications.
- User asks "which agents should handle these files?"

## Workflow

1. Read the user's task description and target repository/codebase.
2. Apply SDD-lite phases: Explore → Define → Design → Match.
3. Explore: glob key files, read architecture docs if present.
4. Define: identify the task goal, scope, constraints, and evidence requirement.
5. Design: decompose the task into atomic sub-tasks with clear inputs and outputs.
6. Match: assign each sub-task to the most capable agent from the available roster.
7. Produce the PROMPT.md artifact.

## Output schema (PROMPT.md)

```markdown
# Prompt Spec: {task name}
## Goal
## Scope (in / out)
## Agent Assignments
| Sub-task | Agent | Input | Output | Evidence |
## Constraints
## Success Criteria
```

## Harness Integration

- **Invoked by:** When a user asks for a PROMPT.md for a complex agentic task.
- **Output feeds:** The PROMPT.md is used as input to a Task agent or leaf session.
- **Gate:** No specific wave gate; used ad-hoc during Altitude Design/Plan phase.

## Concrete output example

```markdown
# Prompt Spec: Migrate altitude-maestro routing to skill-based dispatch
## Goal
Replace embedded coordinator logic with lazy-loaded rule files.

## Scope
In scope: staged/AGENTS.next.md, rules/*.md
Out of scope: opencode.json, agents/altitude-maestro.agent.md (until W6)

## Agent Assignments
| Sub-task | Agent | Input | Output | Evidence |
| Design kernel outline | altitude-plan | W1 ADRs + W2 contract | AGENTS.next.md skeleton | evidence/T-050.md |
| Write skill triggers | altitude-execution | SKILL.md files | Section 6 in kernel | evidence/T-054.md |

## Constraints
- Kernel ≤ 350 lines
- No inline phase logic

## Success Criteria
- bash test/w4-structural.sh exits 0
- All 10+ skills referenced in trigger matrix
```

```yaml
required_skills: [dev-prompt-crafter]
loaded_skills: [dev-prompt-crafter]
confirmed_by: "PROMPT.md with agent assignment table produced"
```

## Stop conditions

- STOP if the task description is too vague to define scope without clarification.
- Ask ONE clarification question if the intent is ambiguous.
