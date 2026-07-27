# Harness V3 — Roadmap Quick Reference

## 📊 Status Atual

**Progress:** 7/17 waves (41%) — ~20k / 45k lines

| Status | Count | Notes |
|--------|-------|-------|
| ✅ Merged | 7 waves | All on main branch |
| ⏳ Pending | 10 waves | Ready to start, no blockers |
| 📝 Total Lines | ~45,000 | estimated final (~20k done, ~25k remaining) |
| 📁 Total Files | ~200+ | estimated final (~67+ created, ~130+ remaining) |

---

## ✅ Completed Waves

| Wave | Name | Commit | Files | Lines | Key Deliverable |
|------|------|--------|-------|-------|-----------------|
| **0** | Architecture Freeze | 7e231d5 | 8 | 3,000 | Contracts (allocation, execution, Ralph Loop) |
| **0A** | Golden Fixtures | c034811 | 18 | 2,500 | 18 test scenarios |
| **4** | Grounding Split & AGENTS | c9552ea | 10 | 4,000 | 6 phase agents + config/grounding |
| **2** | Strategic Routing | 2103fb4 | 6 | 2,500 | Altitude routing, artifact registry |
| **2A** | Tactical Data Engineer | 0bfaadd | 5 | 2,000 | Data Engineer coordinator |
| **2B** | File Organization | d971b47 | 10+ | 2,000 | .specs reorganization |
| **3** | Feature-Level Junta | 09b3684 | 10 | 2,723 | 4-junta + council + scoring [LATEST] |

---

## ⏳ Pending Waves (Execution Order)

### 🔴 CRITICAL (Next 2 weeks)

**Wave 3B — Runtime Validation Enforcement** [NEXT]
- Goal: Make validation gates active at runtime
- Effort: 1,500 lines, 5 files
- Tasks:
  1. altitude-execution checks validation status
  2. Block execution if score < 90
  3. Block ship if status ≠ PASSED
- Acceptance: Execution and ship are blocked without passing validation

**Wave 4 — Artifact Versioning**
- Goal: Track generation history, enable timeline queries
- Effort: 2,000 lines, 8 files
- Key: Generation registry YAML, immutable checksums

### 🟡 HIGH (Next 1 month)

**Wave 5 — Global/Task Allocation**
- Goal: Runtime enforcement of file scope boundaries
- Effort: 1,800 lines, 6 files
- Key: Validate tasks stay within allowed_files, detect scope creep

**Wave 6 — Context Budget**
- Goal: Prevent context overflow
- Effort: 2,000 lines, 7 files
- Key: Token budget, Headroom validator

### 🟢 MEDIUM (Next 2 months)

**Wave 7 — Ralph Loop Verification**
- Goal: Step-by-step verification in Ralph Loop
- Effort: 1,500 lines, 5 files

**Wave 8 — Task-Spec Validation**
- Goal: Standardize task-spec quality
- Effort: 1,800 lines, 6 files

**Wave 9 — Delegation Hardening**
- Goal: Enforce specialist allocation
- Effort: 1,500 lines, 5 files

### 🔵 LOW (Next 3+ months)

**Wave 10** — RTK Integration (1,200 lines)
**Wave 11** — Legacy Cleanup (2,000 lines)
**Wave 12** — Rendering Expansion (2,500 lines)
**Wave 13** — KB Quality (3,000 lines)
**Wave 14-17** — Multi-Phase, Metrics, Security, AI Safety (8,500 lines)

---

## ✅ What's Ready Now

| Component | Status | Notes |
|-----------|--------|-------|
| Altitude Coordinator | ✅ READY | All 6 phases operational |
| Data Engineer Coordinator | ✅ READY | Tactical work |
| Junta Orchestration | ✅ READY | 4-junta + council (Phases 0-5) |
| Evidence Freeze | ✅ READY | Immutable snapshot |
| Deterministic Scoring | ✅ READY | Arithmetic formula |
| Phase Governance | ✅ READY | Intent → Ship gates |
| Routing | ✅ READY | Altitude + Data Engineer |
| Documentation | ✅ READY | 1,300+ lines |
| Golden Fixtures | ✅ READY | 18 scenarios |
| **Validation Gates (runtime)** | ⏳ PENDING | Wave 3B |
| **Artifact Versioning** | ⏳ PENDING | Wave 4 |
| **Allocation Enforcement** | ⏳ PENDING | Wave 5 |

---

## 📍 Where Everything Is

```
~/.config/opencode/
├── .specs/shared/           (11 shared contracts)
├── agents/                  (7 phase agents)
├── config/                  (routing, grounding)
├── docs/                    (20+ documentation files)
├── skills/workflow-commands/references/  (5 junta prompts)
├── test/fixtures/harness-v3/  (18+ scenarios)
└── sdd/                     (legacy, for reference)
```

---

## 🎯 Next Action

1. **Start Wave 3B** (Runtime Validation Enforcement)
   - Effort: ~1 week
   - Blocker: None
   - Next commands:
     ```
     1. Create .specs/shared/validation-gate-enforcement.md
     2. Update agents/altitude-execution.agent.md
     3. Update agents/altitude-report.agent.md
     4. Create validation-block fixtures
     5. Test end-to-end
     6. Commit and merge
     ```

2. **Then Wave 4** (Artifact Versioning)
3. **Then Wave 5** (Allocation Enforcement)

---

## 📋 Key Files to Know

| File | Purpose |
|------|---------|
| AGENTS.md | Primary coordinator interface (1,325 lines) |
| .specs/shared/*.md | Behavioral contracts (source of truth) |
| agents/altitude*.agent.md | Phase-specific orchestrators |
| docs/HARNESS_V3_*.md | Architecture documentation |
| skills/workflow-commands/references/harness-*.md | Junta prompts |

---

## 🎓 Learning Path

1. Read AGENTS.md (primary interface)
2. Read docs/HARNESS_V3_ARCHITECTURE.md (system design)
3. Read docs/HARNESS_V3_VALIDATION_JUNTA_PATTERN.md (validation details)
4. Review agents/ folder (phase implementations)
5. Review .specs/shared/ folder (contracts)

---

**Last Updated:** 2026-06-29  
**Status:** Harness V3 operational, ready for Wave 3B
