# W4 Validation Report

**Wave:** W4 — AGENTS.md kernel rewrite
**Date:** 2026-07-25
**Verdict:** PASS

## Deliverables

| Task | File | Lines | Status |
|---|---|---|---|
| T-050–T-056, T-058 | `staged/AGENTS.next.md` | 168 | Kernel ≤350; no inline logic |
| T-057 | `test/w4-structural.sh` | 7 checks, all PASS | Automated |
| T-059 | `staged/activation-manifest.md` | Pre-checks, rollback | Complete |

## Structural Test: PASS (7/7 checks)

- Kernel 168 lines ≤ 350 ✅
- 1 custom file-backed primary (acceptable until W6) ✅
- References rules/START.md, altitude-start.md, agentspec-start.md ✅
- Skill trigger matrix with 10+ skills ✅
- Non-negotiable invariants stated ✅
- No inlined phase logic ✅
- All rule files ≤ 150 lines ✅

## Completeness: PASS (16/16 terms)

All required terms present in AGENTS.next.md and activation-manifest.md.

## Invariants

- Kernel does not replace the live AGENTS.md — staged only (D-12)
- No new custom primary created
- All behavioral detail delegated to rules/ files (ADR-0006)
