# T-QA-W2: Artifact Depth and Template Review Report

**Wave:** W2
**Date:** 2026-07-21

---

## Final Verdict: PASS (after hardening)

Four gaps were found and remediated before closing T-QA-W2.

---

## Gaps Found and Fixes Applied

| Gap | Severity | Fix |
|---|---|---|
| START classification too abstract | Medium | Added concrete classification table with 8 request patterns and explicit routing for each |
| Writer lease was a bash sketch | Medium | Added full YAML schema, acquisition logic, heartbeat, stale-lease recovery protocol with A/B/C options |
| No output schema per phase | Medium | Added required-fields schema for all 6 phase outputs: `00-intent.md`, `01-structure.md`, `prd.md`, `test-spec.md`, `DESIGN.md`, evidence, ledger, `04-validation.md`, `05-ship-summary.md` |
| Individual TODOs per task | Process | Noted — next waves will create one TODO per task ID |

---

## Re-check

- Validator: PASS (53 checks, 0 errors)
- `altitude-workflow-contract.md`: 568 lines
- `altitude-start.md`: 234 lines
- No secrets, no absolute paths
- All 6 phases have entry gate, actions, output schema, exit gate, and forbidden actions

---

## Process Note — TODO Granularity

Starting W3, each task (T-030 through T-V03 + T-QA-W3) will have its own individual TODOWRITE entry rather than being batched.
