# docs/ — Harness V3 Architecture & Runtime Documentation

This directory contains **explanatory documentation** that teaches how Harness V3 works. All files here are read-only references for understanding the system.

## Core Architecture (Foundation)

- **HARNESS_V3_ARCHITECTURE.md** — Harness V3 operating model: two-coordinator pattern, phase lifecycle, allocation model
- **HARNESS_V3_COORDINATOR_CONTRACT.md** — Altitude & Data Engineer coordinator responsibilities and boundaries
- **HARNESS_V3_PHASE_ENGINE_SPEC.md** — 6-phase lifecycle specification (Intent → Structure → Design → Execution → Validate → Ship)

## Routing & Classification

- **HARNESS_V3_COORDINATOR_ROUTING.md** — Request classification decision tree and routing rules (8 classification rules)
- **HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md** — Tactical data-engineering coordinator scope, escalation triggers, Ralph Loop
- **HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md** — Internal data-engineer routes and legacy `/data:*` command mapping

## State & Artifacts

- **HARNESS_V3_STATE_RESOLUTION_CONTRACT.md** — State conflict detection and resolution policies
- **HARNESS_V3_ARTIFACT_REGISTRY.md** — Artifact types: PRD, ADR, TEST-SPEC, validation reports, ship summary
- **HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md** — Links to 15 templates in `.specs/templates/`

## Integration

- **HARNESS_V3_TASK_SPEC_INTEGRATION.md** — Task-Spec leaf-task integration model and phase handoff
- **HARNESS_V3_LEGACY_PRESERVATION_MATRIX.md** — Legacy behavior preservation strategy and fixture coverage
- **HARNESS_V3_MIGRATION_TEST_PLAN.md** — Migration test plan: 18 golden fixtures, conformance tests

---

## Purpose

**Teaching** how Harness V3 works. All content is explanatory, not prescriptive for operations.

**Use case**: When you need to understand *how* Harness V3 functions, what the phases are, or how requests flow through the system.

**Do NOT use** for: Operational decisions or planning (see `.specs/control/` instead)

---

## Navigation

- **Getting Started**: Start with `HARNESS_V3_ARCHITECTURE.md`
- **How Requests Flow**: See `HARNESS_V3_COORDINATOR_ROUTING.md`
- **Phase Lifecycle**: See `HARNESS_V3_PHASE_ENGINE_SPEC.md`
- **Tactical Data Work**: See `HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md`
- **Artifacts**: See `HARNESS_V3_ARTIFACT_REGISTRY.md` and `HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md`
- **Implementation**: See `AGENTS.md` (in root) for complete system specification

---

## Related Files

- **AGENTS.md** (root) — Complete 1,325-line Harness V3 specification (39 sections)
- **.specs/shared/** — 28 runtime contracts (policies, execution loop, allocation, etc.)
- **.specs/control/** — Operational planning and control artifacts (separate from documentation)
- **config/grounding.md** — Thin index to .specs/shared/ contracts
