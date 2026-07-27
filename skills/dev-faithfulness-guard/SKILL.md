---
name: dev-faithfulness-guard
description: >-
  Use ONLY when validating that a response or plan faithfully follows the
  behavioral principles defined in AGENTS.md or the active harness rules.
  Trigger phrases: 'validate this response', 'check faithfulness',
  'faithfulness check', 'audit this output', 'did the agent follow the rules'.
  Do NOT use for general code review or architecture analysis.
---

# Dev Skill: Faithfulness Guard

## When to use

- User asks to validate a plan or response against AGENTS.md behavioral principles.
- User asks "did the agent follow the rules?"
- A phase gate requires faithfulness validation before advancing.

## Workflow

1. Read `AGENTS.md` (or `staged/AGENTS.next.md` if W4+ is active) to load current principles.
2. Read the target plan or response provided by the caller.
3. Evaluate each principle independently:
   - **Think Before Coding** — assumptions listed? ambiguities surfaced?
   - **Simplicity First** — only what was asked? no speculative features?
   - **Surgical Changes** — only required files? no adjacent cleanup?
   - **Goal-Driven Execution** — success criteria explicit? multi-step outputs have verify pairs?
   - **Source Discipline** — every architectural claim cited to a source?
4. Try `faithfulness_gate` tool if available; if not, perform the audit manually.
5. Assign PASS / WARN / FAIL per principle with a one-line reason.
6. Produce overall verdict with correction proposals for every FAIL or WARN.

## Output schema

```markdown
## Faithfulness Scorecard
| Principle | Verdict | Reason |
|---|---|---|
| Think Before Coding | PASS/WARN/FAIL | {reason} |
...

## Overall Verdict: PASS / WARN / FAIL
## Correction Proposals
{numbered list for every FAIL or WARN}
```

## Harness Integration

- **Invoked by:** W4 T-V04, W5 T-V05, and all T-Vxx gates as the independent validator.
- **Output feeds:** T-Vxx validation report `verdict` field.
- **Gate:** W11 T-157 runs judge + faithfulness review; W11 T-165 audits load receipts.

## Concrete output example

```markdown
## Faithfulness Scorecard
| Principle | Verdict | Reason |
|---|---|---|
| Think Before Coding | PASS | ADR-0001 cited before deciding on built-in primary |
| Simplicity First | WARN | AGENTS.next.md added a loading-mechanism section not explicitly requested |
| Surgical Changes | PASS | Only staged/AGENTS.next.md was modified |
| Goal-Driven Execution | PASS | Each section maps to a T-05x task acceptance criterion |
| Source Discipline | PASS | All invariants traced to ADR-000x |

## Overall Verdict: WARN
## Correction Proposals
1. [Simplicity First] Section 8b was added in T-QA-W4 gap-fix — acceptable if T-QA evidence documents this.
```

```yaml
required_skills: [dev-faithfulness-guard]
loaded_skills: [dev-faithfulness-guard]
confirmed_by: "scorecard produced with per-principle verdicts"
```

## Stop conditions

- STOP if `faithfulness_gate` tool is unavailable and emit WARN that the automated gate did not run.
- Do NOT produce a PASS verdict without checking all five principles.
