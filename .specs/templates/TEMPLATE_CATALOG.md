# Template Catalog Rationale

## Purpose

This document explains the 11 canonical templates and when to use each.

## Core Templates (Required for Artifacts)

### 1. prd-template.md
**Use:** PRD (Product/Requirement Definition) artifacts
**When:** Strategic changes, feature designs, business requirements
**Phase:** Intent, Structure
**Keys:** goals, requirements, acceptance criteria, stakeholders

### 2. adr-template.md  
**Use:** ADR (Architecture Decision Record)
**When:** Technical decisions, trade-offs, architecture changes
**Phase:** Structure, Design/Plan
**Keys:** context, decision, consequences, alternatives

### 3. test-spec-template.md
**Use:** TEST-SPEC (Validation Strategy & Test Specification)
**When:** Before execution, to define validation approach
**Phase:** Design/Plan
**Keys:** acceptance criteria, test cases, fixtures, regression scenarios

### 4. validation-report-template.md
**Use:** Validation Report (evidence of test execution)
**When:** After execution, before shipping
**Phase:** Validate
**Keys:** verdict, scope check, acceptance criteria results, evidence

### 5. ship-summary-template.md
**Use:** Ship Summary (closure of a change/wave)
**When:** After validation, to ship or archive
**Phase:** Ship
**Keys:** shipped boundary, lessons learned, risks accepted, follow-up

---

## Operational Templates (For Harness State Management)

### 6. state.template.md
**Use:** Change State (durable state snapshot)
**When:** Track phase progression, active tasks, blockers
**Phase:** All phases
**Keys:** status, altitude, active agent, blocking reason, next recommended agent

### 7. change.template.md
**Use:** Change Request (high-level work request)
**When:** Start new change in Altitude coordinator
**Phase:** Intent
**Keys:** title, owner, scope, related artifacts

### 8. task.template.md
**Use:** Task Specification (durable work unit)
**When:** Decompose change into tasks
**Phase:** Plan
**Keys:** task_id, owner, allowed files, forbidden scope, verification

---

## Decision & Evidence Templates

### 9. decision.template.md
**Use:** Decision Record (single decision capture)
**When:** Record decisions during phases (lighter than ADR)
**Phase:** Any phase
**Keys:** question, options, decision, rationale

### 10. evidence.template.md
**Use:** Evidence Pack (proof of work completion)
**When:** Capture validation evidence, test results, audit trails
**Phase:** Validate, Ship
**Keys:** source, command, result, timestamp

### 11. executive-report.template.md
**Use:** Executive Report (summary for stakeholders)
**When:** Communicate results to non-technical stakeholders
**Phase:** Ship
**Keys:** summary, business impact, metrics, next steps

---

## Deleted Templates (Rationale)

| Deleted | Reason |
| --- | --- |
| `validation.template.md` | Duplicate of `validation-report-template.md` |
| `ship-note.template.md` | Subsumed by `ship-summary-template.md` |
| `active-state.template.md` | Subsumed by `state.template.md` |
| `executar-todas.template.md` | Dead "execute all" pattern (not used) |

---

## Usage Guidelines

1. **Artifact flow:** change → prd → adr → test-spec → validation-report → ship-summary
2. **State tracking:** state.template for any phase
3. **Decisions:** decision.template for tactical, adr-template for strategic
4. **Evidence:** evidence.template for validation proof
5. **Reports:** executive-report for stakeholder communication

---

**Last Updated:** Phase 0  
**Total Templates:** 11 canonical templates  
**Reduction:** 15 → 11 (27% reduction)
