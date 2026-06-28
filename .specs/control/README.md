# .specs/control/ — Harness V3 Control & Planning Files

This directory contains **operational control and planning artifacts** for the Harness V3 refactor, separate from runtime documentation.

## Structure

### `/roadmap/`
High-level planning and evolution strategy for Harness V3.

- **HARNESS_V3_REFACTOR_ROADMAP.md** — Master 17-wave refactor roadmap with phase descriptions, wave dependencies, risk assessment, and exit criteria
- **HARNESS_EVOLUTION_TREE.md** — Vision and evolution path for Harness V3: from legacy SDD to modular coordinator model
- **HARNESS_TARGET_OPERATING_MODEL.md** — Target end-state architecture: two-coordinator model, phase lifecycle, allocation, evidence

### `/governance/`
Governance standards, matrices, and structural decisions.

- **HARNESS_KB_GOVERNANCE_STANDARD.md** — Knowledge base domain governance: KB structure, validation, freshness, deprecation
- **HARNESS_MCP_GOVERNANCE_MATRIX.md** — MCP server governance and integration matrix
- **HARNESS_DECOMPOSITION_MODEL.md** — Strategic decomposition model for Wave 1 (command removal) and Wave 3 (phase contract)

### `/analysis/`
Gap analysis, discovery, and detailed specifications.

- **AGENTIC_GAP_DOSSIER.md** — Complete gap analysis: identified issues, root causes, and resolution approach
- **ALTITUDE_SPECS_HARNESS.md** — Legacy detailed specifications for Altitude coordinator (mostly superseded by AGENTS.md)

### Root Level
- **agent-authority-matrix.md** — Authority matrix for agents, specialists, and phase handlers

---

## Purpose

These files drive **operational decisions** about the refactor. They are **not** runtime documentation.

**Use case**: When you need to understand *why* a decision was made, *what* the plan is, or *how* the roadmap flows.

**Do NOT use** for: Explaining how to use Harness V3 (see `docs/` instead)

---

## Navigation

- **Planning**: See `/roadmap/HARNESS_V3_REFACTOR_ROADMAP.md` for wave sequencing
- **Current Issues**: See `/analysis/AGENTIC_GAP_DOSSIER.md` for identified gaps
- **Future State**: See `/roadmap/HARNESS_TARGET_OPERATING_MODEL.md` for target architecture
- **Governance Rules**: See `/governance/` for standards and matrices
