# Specialist Allocation Contract

## Purpose

Define specialist usage as a subset of allocation, not an ad hoc execution decision.

Specialists provide bounded expertise. They do not become hidden owners, broaden scope, or replace validation.

## Required Fields

- specialist or skill name
- reason for allocation
- parent task id
- scope
- allowed files/data
- forbidden scope
- grounding bundle
- expected output
- evidence required
- verification responsibility
- stop condition
- owner responsible for accepting or rejecting the output

## Grounding Bundle

Every specialist allocation must identify the smallest useful context bundle:

- active task or Task-Spec leaf task
- relevant PRD/ADR/TEST-SPEC when present
- allowed files and forbidden scope
- source references or KB/docs to inspect
- acceptance criteria and verification commands
- evidence format expected from the specialist

Do not ask a specialist to infer the task from chat history alone.

## Evidence Contract

Specialist output must include:

- files or sources inspected
- claims made
- recommendation or patch boundary
- validation performed or validation still required
- residual risk
- stop condition triggered, if any

The owning coordinator or task owner must validate specialist output before accepting it into the task ledger or implementation.

## When To Allocate

Allocate a specialist when:

- the task crosses a high-risk domain
- the owner lacks enough domain-specific context
- independent review materially reduces risk
- a plugin/skill is mandated by policy
- the task requires domain-specific validation that the primary coordinator should not improvise

## Over-Delegation Rules

Do not allocate a specialist when:

- the primary owner already has enough context and the task is low-risk
- delegation would cost more than direct execution
- the scope is unclear
- the task lacks allowed files or forbidden scope
- no evidence can be requested from the specialist
- the specialist would become the real task owner

## Delegation Lifecycle

```text
local allocation
  -> specialist allocation
  -> grounding bundle
  -> specialist output
  -> owner validation
  -> evidence ledger
  -> task continuation or replan
```

## Stop Conditions

Stop specialist use and replan when:

- specialist asks to broaden scope
- specialist cannot access required context
- specialist produces unsupported claims
- specialist output conflicts with active task contract
- specialist output requires security, production data, or user approval not already granted

## Anti-Patterns

- invoking specialists after work starts without scope
- using specialists to broaden the task silently
- accepting specialist output without validation
- hiding specialist evidence from the task/report
- calling multiple specialists to avoid making an ownership decision
- delegating a task that is not yet decomposed
