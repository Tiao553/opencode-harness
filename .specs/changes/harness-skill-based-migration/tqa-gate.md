# T-QA: Artifact Depth, Template Review, and Completeness Gate

**Purpose:** Mandatory quality gate applied after every wave's T-Vxx technical validation and before W(N+1) is unblocked. It reviews whether artifacts are deep enough, follow their template, AND cover all required cases.

**Applied to:** Every wave W0–W12 as `T-QA-W{N}`.

**Gate is independent of T-Vxx.** T-Vxx checks structural correctness and scope. T-QA checks depth, evidence grounding, template compliance, and completeness.

---

## The Three Questions

**Q1 — Depth:**
> "Os artefatos, documentacoes e .mds estao profundos e detalhando realmente tudo?"

Reviewable dimensions:

| Dimension | Pass condition |
|---|---|
| Context | Cites specific evidence (file names, line counts, commands, observation dates) |
| Options | Each option has concrete failure mode and "Why rejected" reason |
| Decision | Specific rules, testable, not aspirational |
| Consequences | Each has a concrete mechanism |
| Migration plan | Each step names what file/command changes, not just which task to run |
| Validation plan | Each item names a reproducible command or fixture |

**Q2 — Template:**
> "Qual o template seguido para responder isso?"

Check: frontmatter present, all required sections present, template structure followed.

**Q3 — Completeness (new — mandatory from W3 onwards):**
> "O artefato cobre todos os casos obrigatorios? Ha alguma lacuna de conteudo?"

Automated completeness checks run **before** the user question, not after. A completeness failure must be fixed before T-QA closes.

---

## Completeness Check Protocol

For each wave, maintain a completeness checker in the wave evidence. The checker uses case-insensitive term matching.

Format:
```javascript
const checks = {
  "filename.md": { required: ["term1", "term2", ...] },
  ...
};
```

All required terms must be present (case-insensitive). Coverage < 100% = FAIL → fix before T-QA closes.

Wave-specific completeness checks are recorded in each T-QA evidence file.

---

## Hardening Protocol

When any Q1/Q2/Q3 dimension fails:

1. Identify the specific artifact and the specific gap.
2. Apply a targeted edit with concrete evidence, trade-off reasoning, execution steps, or missing content.
3. Re-run the completeness check (automated) and re-ask the depth question (user).
4. Record all gaps and fixes in the T-QA evidence file.

---

## Evidence Required

For each T-QA task:
- `evidence/w{N}-qa/w{N}-qa-report.md` — gaps found, fixes applied, completeness check output, final verdict.

---

## Wave-Level Registry

| Wave | T-QA task | Status | Completeness check | Report |
|---|---|---|---|---|
| W1 | T-QA-W1 | done | Added retroactively | `evidence/w1-qa/w1-qa-report.md` |
| W2 | T-QA-W2 | done | Added retroactively | `evidence/w2-qa/w2-qa-report.md` |
| W3 | T-QA-W3 | done | Pass (10 files, 100%) | `evidence/w3-qa/w3-qa-report.md` |
| W4 | T-QA-W4 | pending | — | — |
| W5–W12 | pending | — | — | — |
