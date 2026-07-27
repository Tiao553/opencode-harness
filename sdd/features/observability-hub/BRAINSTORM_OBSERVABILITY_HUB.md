# BRAINSTORM — Observability Hub (Simplification Iteration)

**Date:** 2026-06-10
**Facilitator:** iterate-agent
**Status:** Reopened — cascaded through DEFINE and DESIGN

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-17 | brainstorm-agent | Initial BRAINSTORM |
| 1.1 | 2026-05-18 | iterate-agent | Removed Phase 1 Local / DuckDB strategy. Fabric became the single platform from the start. |
| 1.2 | 2026-06-10 | iterate-agent | Simplification-first reset: refocused scope on notebooks + data pipelines, kept Bronze/Silver/Gold, reduced monitoring to a basic level, removed CI/CD from this phase, rejected direct FUAM adoption, and required `notebookutils` plus Fabric function/variable objects for reusable logic. |

---

## Canonical Sources

| Source | Role |
|---|---|
| `docs/discovery/contrato_canonico.md` | Gold contract for `fct_execution_event` and `fct_error_event` |
| `docs/discovery/arquitetura_de_dados.md` | Canonical medallion structure and source flows |
| `docs/architecture/fabric_setup.md` | Reference baseline only for Fabric setup ideas; not a mandate to reproduce its full topology in this phase |
| User iteration request (2026-06-10) | Canonical source for this simplification direction |

---

## Executive Summary

The project remains a **Microsoft Fabric medallion solution** for ODI, ETLTOOLS, Elastic NOT_STARTED, and Power BI refresh telemetry, but the delivery approach is reset to be much simpler.

The new direction is:

1. **Focus on notebooks and Fabric Data Factory pipelines first**
2. **Keep the 3-layer lakehouse structure** from `arquitetura_de_dados.md`
3. **Use Spark SQL heavily**, especially for schema creation and table materialization
4. **Simplify Bronze notebooks aggressively** so they only collect raw data, stamp metadata, and persist
5. **Use `notebookutils` everywhere** for notebook-native operations
6. **Prefer Fabric function objects and variable objects** for shared logic/config instead of ad hoc utility patterns
7. **Keep monitoring basic for now** and rely on Fabric UI where it already solves the need
8. **Do not include CI/CD in this phase**
9. **Use the Fabric setup guide as reference only**; do not apply FUAM directly in this project

---

## Problem Reframing

The core product problem is still operational observability across ODI, ETLTOOLS, and Power BI.

The new delivery problem is different: **the current implementation/setup approach became too complex to operate**. The main friction points are excessive engineering around setup, deployment, monitoring, and reusable notebook structure, especially where the Fabric UI and native runtime already cover much of the workflow.

Success now depends on reducing moving parts without changing the core data model.

---

## What Stays

- Microsoft Fabric as the only platform
- Bronze → Silver → Gold lakehouse structure
- Gold contract from `contrato_canonico.md`
- Fabric Data Factory pipelines for orchestration
- Power BI as downstream consumer
- Elastic NOT_STARTED handling and canonical error modeling

## What Changes

- No CI/CD in this phase
- No direct FUAM rollout
- No Fabric CLI-centered operating model
- No advanced monitoring/KQL estate in this phase
- No unnecessary engineering where Fabric UI already provides the control surface
- Bronze notebooks become intentionally minimal

---

## Simplification Principles

1. **Notebook-first**: prefer a small number of clear notebooks over layered helper frameworks.
2. **Pipeline-first operations**: rely on Fabric pipeline scheduling, dependencies, and run history.
3. **Spark SQL first**: use SQL for DDL and most layer-to-layer transformations unless Python is clearly required for extraction.
4. **Native Fabric ergonomics**: use `notebookutils`, Fabric variables, and Fabric functions before inventing custom patterns.
5. **Basic monitoring only**: `stg_ingestion_audit`, Fabric run history, and a minimal completeness/status surface are enough for this phase.
6. **UI over engineering**: if Fabric UI already handles setup, execution, or inspection adequately, do not automate it yet.

---

## Out of Scope for This Iteration

- CI/CD workflows and deployment pipeline automation
- Multi-environment promotion design as a delivery requirement
- Advanced monitoring with dedicated KQL packs
- Full SRE/governance package for this phase
- Direct application of FUAM conventions/process in the project
- Reusable notebook utility sprawl (`utils/*.ipynb` style shared glue) when Fabric objects can do the job

---

## Next Step

This brainstorm iteration has already been cascaded into DEFINE and DESIGN.

**Ready for:** `/workflow:build`

**Build expectation:** align implementation to the simplified notebook/pipeline-first design before any new validation cycle.

## Status: 🔄 Reopened via `/workflow:iterate`
