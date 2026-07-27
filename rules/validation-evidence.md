# Validation and Evidence Rule

**Trigger:** Validation phase entry, evidence file creation, or task closure.
**Load scope:** Lazy — loaded on validation phase entry or evidence write.
**Governing authority:** W2 `altitude-workflow-contract.md` sec. 8, `execution-loop-contract.md`.

---

## Core rule

No task is done without an evidence file. No wave advances without its T-Vxx PASS.

## Required evidence file fields

```markdown
## Task — {ID and title}
## Inputs — {list with paths}
## Actions taken — {numbered list}
## Verification result — command + key output
## Acceptance criteria — [x] each criterion with method
## Scope compliance — out-of-scope files: none | secret values: none
```

**Minimum required in every evidence file:** `evidence_file` path recorded in the ledger entry; `criteria_met` confirmed for each acceptance criterion.

## Validation independence

- Validator must not be the same session that implemented the tasks.
- W0–W4: transitional adapter approved (documented in `bootstrap-decisions.md`).
- W5+: `dev-faithfulness-guard` and `dev-judge` skills required.

## Verdict semantics

| Verdict | Action |
|---|---|
| PASS | Advance to next phase or wave |
| FAIL | Create remediation task; do not advance; do not auto-repair |
| BLOCKED | Surface missing prerequisite to user; do not advance |

## Stop conditions

- STOP if a task is marked done without an evidence file.
- STOP if T-Vxx has not returned PASS before the next wave starts.
- STOP if validation attempts to auto-repair a defect — create a remediation task instead.

---

*Governing: W2 contract, `execution-loop-contract.md`.*
