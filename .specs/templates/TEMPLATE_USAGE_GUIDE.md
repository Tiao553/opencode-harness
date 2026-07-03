# Template Usage Guide

## Quick Reference

### "I'm starting a new project" → use:
1. change.template.md (document scope)
2. prd-template.md (define requirements)
3. adr-template.md (record architecture)

### "I'm executing a task" → use:
1. task.template.md (verify task spec)
2. evidence.template.md (capture results)

### "I'm done and shipping" → use:
1. validation-report-template.md (show test results)
2. ship-summary-template.md (document what shipped)

### "I need to track state" → use:
- state.template.md (any phase)

### "I need to record a decision" → use:
- decision.template.md (tactical)
- adr-template.md (strategic)

### "I'm communicating to executives" → use:
- executive-report.template.md (summary for non-technical)

---

## Template Selection Matrix

| Phase | Primary Template | Secondary | Optional |
| --- | --- | --- | --- |
| **Intent** | prd-template.md | change.template.md | - |
| **Structure** | adr-template.md | state.template.md | decision.template.md |
| **Design/Plan** | test-spec-template.md | task.template.md | adr-template.md |
| **Execution** | task.template.md | evidence.template.md | state.template.md |
| **Validate** | validation-report-template.md | evidence.template.md | - |
| **Ship** | ship-summary-template.md | executive-report.template.md | - |

---

## Anti-Patterns

- Don't mix PRD + ADR (separate concerns)
- Don't skip TEST-SPEC before execution
- Don't ship without validation-report
- Don't use state.template.md for permanent decisions (use adr-template.md)
- Don't create custom templates without consolidating to catalog first

---

**All 11 templates are in .specs/templates/**
