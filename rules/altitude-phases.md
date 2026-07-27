# Altitude Phase Rules

**Trigger:** Altitude phase transition or phase-specific action.
**Load scope:** Lazy — loaded on phase entry.
**Governing authority:** W2 `altitude-workflow-contract.md`, `state-machine-contract.md`.

---

## Core rule

Phase transitions are forward-only (except Validation → Design/Plan for rework). Required phases cannot be skipped. Each phase requires its artifact before advancing.

## Phase sequence

```text
Intent → Structure → Design/Plan → Execution → Validation → Ship
                                       ↑            ↓
                            (rework: Validation → Design/Plan)
```

## Per-phase minimum artifact

| Phase | Required artifact | Minimum requirement |
|---|---|---|
| Intent | `00-intent.md` | Problem, Non-goals, Success criteria, Open questions, Scope boundary; ≥200 words |
| Structure | `01-structure.md` | Surface map, Constraints, Risk register, Dependencies |
| Design/Plan | PRD + ADR + TEST-SPEC + DESIGN | 4-Doc Gate must pass before Execution starts |
| Execution | Evidence file per task | `evidence/T-{N}-{slug}.md` with all required fields |
| Validation | `04-validation.md` | PASS/FAIL/BLOCKED verdict, task checklist, defect count |
| Ship | `05-ship-summary.md` | All required fields; archive complete; memory written |

## Memory event required at each transition

Write `phase_gate` event to `.specs/memory/{change_id}/{entry_id}.yaml` before advancing.

## Stop conditions

- STOP if the required artifact is absent or below minimum length.
- STOP if a forbidden transition is attempted (e.g., Intent → Execution).
- STOP if the 4-Doc Gate fails and Execution is attempted.
- STOP if the writer lease is not held before any state write.

---

*Full contract: `.specs/changes/harness-skill-based-migration/contracts/altitude-workflow-contract.md` sec. 4–9.*
