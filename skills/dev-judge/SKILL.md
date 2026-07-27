---
name: dev-judge
description: >-
  Use when the user needs a cross-model second opinion on code correctness,
  schema migrations, IAM policies, high-risk outputs, or plan quality. Trigger
  phrases: 'judge this file', 'get a second opinion', 'review with external
  model', 'judge this migration'. Do NOT use for general code review within
  the same model.
---

# Dev Skill: Judge

## When to use

- User needs an independent second opinion on a high-risk artifact.
- A validation phase requires external judge verification.
- User asks "judge this migration file" or "get a second opinion on this plan."

## Workflow

1. Identify the artifact to judge (file path or content provided by caller).
2. Determine the judgment criteria: correctness, security, scope, or completeness.
3. Use the external judge runtime (OpenRouter or equivalent) if configured. If unavailable: perform the review manually and emit WARN that automated judging was not available.
4. Apply the judgment criteria against the artifact.
5. Return PASS / FAIL verdict with specific line-level findings.

## Output schema

```markdown
## Judge Verdict: PASS / FAIL
## Artifact: {file path}
## Criteria applied: {list}

## Findings
| Severity | Finding | Location |
|---|---|---|
| critical/high/medium/low | {finding} | {line or section} |

## Summary
{one paragraph}
```

## Harness Integration

- **Invoked by:** W11 T-157 (independent judge and faithfulness review).
- **Output feeds:** W11 validation report; a FAIL blocks T-V11.
- **Gate:** W5 T-063 creates this skill; W11 T-157 exercises it; W11 T-165 audits load receipt.

## Concrete output example

```markdown
## Judge Verdict: PASS
## Artifact: staged/AGENTS.next.md
## Criteria applied: correctness, ADR compliance, scope adherence

## Findings
| Severity | Finding | Location |
|---|---|---|
| medium | Section 8b loading mechanism example uses backtick in JSON — cosmetic | Section 8b |

## Summary
The kernel correctly delegates all behavioral logic to rules/ files, states all non-negotiable invariants, and references 3+ skill triggers. The one medium finding is cosmetic and does not affect runtime behavior.
```

```yaml
required_skills: [dev-judge]
loaded_skills: [dev-judge]
confirmed_by: "PASS/FAIL verdict with findings table produced"
```

## Stop conditions

- STOP if the artifact is not provided and cannot be derived from context.
- Do NOT emit a PASS verdict without applying at least one concrete criterion.
- If external judge runtime is missing: emit WARN, not PASS.
