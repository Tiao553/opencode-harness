# Global Allocation Contract

## Purpose

Global allocation defines change, wave, or phase ownership before local tasks are generated.

## Required Fields

- change or wave id
- owner coordinator
- phase
- scope boundary
- artifact authority
- allowed paths
- forbidden paths
- validation posture
- escalation owner

## Optional Fields

- related PRD
- related ADR
- related TEST-SPEC
- source authority
- risk class
- rollback owner

## Precedence

Global allocation constrains local allocation. Local tasks may narrow scope but must not broaden it without user confirmation.

## Broadening Rule

A local task broadens global allocation when it adds:

- new directories outside allowed paths
- new data sources
- new runtime or security-sensitive behavior
- new stakeholder-facing behavior
- new validation burden not represented in the wave

When broadening is needed, return to Design/Plan or ask the user to approve the allocation change before execution.
