# Local Allocation Contract

## Purpose

Local allocation defines ownership for one task or todo.

## Required Fields

- task id or todo id
- owner
- deliverable
- allowed files
- forbidden scope
- specialist support if any
- verification command or manual check
- evidence required

## Optional Fields

- specialist support
- related PRD requirement
- related ADR decision
- related TEST-SPEC scenario
- risk class
- rollback step

## Todo Rule

Every operational todo must include a `verify:` clause. Todos without verification are planning notes, not executable work.

## Execution Rule

Local allocation is executable only when:

- the global allocation exists or the task is explicitly standalone
- allowed files and forbidden scope are both present
- verification is concrete
- evidence can be recorded
- any specialist support has a reason and stop condition
- any specialist support has a grounding bundle and evidence contract

## Stop Conditions

- task requires files outside allowed scope
- verification command cannot run and no manual substitute is named
- evidence would rely only on chat memory
- specialist support would become the real owner instead of bounded help
- specialist support is requested before local allocation is complete
