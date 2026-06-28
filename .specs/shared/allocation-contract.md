# Allocation Contract

## Purpose

Allocation defines ownership before delegation or execution.

## Allocation Types

| Type | Scope |
| --- | --- |
| global allocation | change, wave, or phase ownership |
| local allocation | task or todo ownership |
| specialist allocation | delegated expert contribution |

## Required Fields

- owner
- scope
- allowed files or data
- forbidden scope
- context bundle
- evidence required
- verification responsibility
- rollback responsibility

## Precedence

```text
global allocation
  -> local allocation
  -> specialist allocation
  -> todo execution
```

Lower levels may narrow scope. They must not broaden ownership, allowed files, data access, or authority without explicit user confirmation or a new accepted allocation.

## Task-Spec Mapping

When a Task-Spec leaf task is created, it must inherit:

- global allocation id or change id
- local task owner
- allowed files
- forbidden scope
- context bundle
- evidence required
- verification command or manual check
- rollback responsibility

Task-Spec may add implementation detail, but it must not override allocation authority.

## Rule

Delegation is a subset of allocation. No specialist may be invoked without a reason, scope, evidence expectation, and stop condition.

## Invalid Allocation States

- specialist invoked without local allocation
- local task broadens global allocation
- todo lacks a `verify:` clause
- execution has allowed files but no forbidden scope
- evidence required is missing or unverifiable
- rollback owner is missing for risky changes
