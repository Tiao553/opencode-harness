---
name: workflow-define
description: /workflow:define, DEFINE artifact, requirements extraction, clarity scoring, and gap filling. Use ONLY when executing Phase 1 or updating the DEFINE workflow logic.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: workflow
---

# Workflow Define

## When to Use

- Use for `/workflow:define`.
- Use when the goal is to transform raw notes, brainstorm output, or direct requests into `DEFINE_{FEATURE}.md`.
- Do not use for architecture design, file manifests, or implementation planning. Those belong to `workflow-design`.

## Workflow

1. Read `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` and `~/.config/opencode/sdd/templates/DEFINE_TEMPLATE.md`.
2. Resolve the input type: brainstorm artifact, notes, email thread, direct requirement, or mixed sources.
3. Extract the minimum requirement set:
   - problem statement
   - target users
   - goals with MoSCoW priority
   - success criteria
   - constraints
   - explicit out of scope
4. Gather the minimum technical context needed for the next phase:
   - likely implementation location
   - KB domains for design
   - whether infrastructure or IaC changes are in scope
5. Calculate clarity score out of 15.
6. If score is below 12, ask only targeted gap-filling questions and rescore.
7. Write the global artifact first, then copy it flat to `./specs/DEFINE_{FEATURE}.md`.
8. End with a handoff to `/workflow:design`.

## Clarity Rules

- Problem must be one clear actionable sentence.
- Users must include at least one pain point.
- Success criteria must be measurable.
- Out-of-scope cannot be empty.
- Assumptions must be stated when facts are missing.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "We can infer the missing scope later in design." | Missing scope in DEFINE creates design drift. |
| "A vague success criterion is fine for now." | If it is not measurable here, it is not verifiable later. |
| "Out of scope is optional." | Missing exclusions is one of the fastest ways to create scope creep. |

## Red Flags

- The problem statement is really a solution statement.
- Users are named but their pain is not.
- Success criteria use words like "better" or "improved" without numbers.
- KB domains are skipped entirely.
- The DEFINE artifact would move forward with score below 12/15.

## Verification

- [ ] `WORKFLOW_CONTRACTS.yaml` and `DEFINE_TEMPLATE.md` were read.
- [ ] Problem, users, goals, success criteria, constraints, and out-of-scope were extracted.
- [ ] Technical context includes location, KB domains, and IaC impact.
- [ ] Clarity score is present and is at least 12/15.
- [ ] Artifact was written globally first and copied flat to `./specs/`.
- [ ] Next step points to `/workflow:design`.
