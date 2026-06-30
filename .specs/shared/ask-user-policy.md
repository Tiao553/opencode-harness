# Ask-User Policy

## Purpose

Define when and how the harness should prefer structured `Ask-User` interaction, with a bias toward multiple-choice prompts.

This policy exists because structured questions reduce ambiguity, speed up decisions, and lower the cognitive cost of high-frequency interactions.

## Default Rule

Use `Ask-User` with multiple-choice options **whenever possible**.

Open-ended questions are still allowed, but they are the fallback, not the default.

## When Multiple Choice Is Mandatory

Use multiple-choice prompts when the coordinator needs:

- intent clarification under ambiguity
- phase transition confirmation
- scope boundary confirmation
- tradeoff selection between valid options
- escalation direction
- task selection for explicit execution
- rollback versus continue decision
- routing choice between strategic and tactical paths

## Interaction Model

### Good

```text
Question: Which execution slice should run next?
Options:
1. T-006B1 - Repair Fabric Copilot capacity contradiction
2. T-005B - Rewrite workflow build surfaces
3. Pause and re-plan
```

### Bad

```text
What do you want to do next?
```

## Design Rules

- Lead with the recommended option first.
- Keep options mutually exclusive when possible.
- Use a short explanation for each option.
- Offer custom input only when the choice space is genuinely open.
- Ask one decision at a time for high-impact transitions.

## Use By Layer

| Layer | Default Ask-User posture |
| --- | --- |
| Strategic coordinator | multiple choice by default |
| Tactical data-engineer coordinator | multiple choice by default |
| Validation gates | mandatory multiple choice when a human must decide |
| Documentation and planning | multiple choice when selecting architecture or scope branches |

## Human-In-The-Loop Rule

Phase transitions and explicit execution selection must prefer multiple-choice `Ask-User` prompts over vague freeform confirmation.

## Doubt Resolution Rule

**MANDATORY: When in doubt, always use `question` tool.**

If any of these conditions exist:

- Confidence < 0.80 on the correct interpretation
- Multiple valid interpretations of user intent exist
- Next action affects file scope, phase transition, or execution boundary
- A coordination decision needs explicit user validation
- The cost of being wrong exceeds the cost of asking

Then: **Do not proceed silently. Ask.**

### Doubt Pattern Examples

| Situation | Action |
|---|---|
| User says "fix the pipeline" (ambiguous scope) | Ask: Which pipeline layer? (Bronze/Silver/Gold) |
| Two valid architectural paths exist | Ask: Which approach? (with tradeoff table) |
| Tactical vs. Strategic unclear | Ask: Should this be a one-off fix or durable change? |
| File scope seems larger than intended | Ask: Should I expand scope or narrow it? |
| Specialist delegation is optional | Ask: Allocate specialist or proceed with coordinator? |
| Agent infers user meant X but user said Y | Ask: Did you mean X or did you mean Y? |

### Confidence Threshold

```
confidence < 0.80 → must use question
confidence 0.80-0.90 → use question for destructive/irreversible work
confidence > 0.90 → proceed; but still ask if scope seems large
```

## Anti-Patterns

- asking open-ended questions when the real choice is already known
- batching unrelated decisions into one question
- hiding the recommended option
- asking for a task choice without naming the tasks explicitly
- proceeding silently when doubt exists
- assuming user intent without clarification
