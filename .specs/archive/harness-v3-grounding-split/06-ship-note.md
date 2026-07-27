# Harness V3 Grounding Split - Ship Note

change: harness-v3-grounding-split
status: shipped
date: 2026-06-28
owner: altitude-report

## Summary

Shipped the Grounding Split as a policy-surface refactor. `config/grounding.md` now indexes the shared contracts and no longer embeds the full legacy policy stack.

## What Shipped

- Thin `config/grounding.md`
- Grounding split evidence
- Validation ledger

## Validation Reference

```text
grounding-links-ok
0 matches for old monolithic section headings
```

## Risks Accepted

- Runtime plugins were not rewired.
- Some legacy behavior is preserved by compatibility references, not enforcement.

## Follow-Up

Use this split as the base for the next V3 coordinator/runtime waves.
