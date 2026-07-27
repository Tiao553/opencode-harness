# Harness 360 Refactor - Executive Report

change: harness-360-refactor
status: validated
date: 2026-06-28
owner: altitude-report

## Executive Summary

The `harness-360-refactor` change moved the OpenCode harness from a loosely connected prompt/config model toward a governed, evidence-backed operating model.

The change established `Altitude` as the durable-work coordinator, clarified MCP governance, tightened decomposition into smaller executable tasks, introduced dense Markdown artifact standards, and upgraded Microsoft Fabric into the first governed KB domain. The final execution slice repaired the remaining Fabric `FABRIC-CC-004` parity gap by aligning Eventhouse and Warehouse concept files with the current Eventhouse endpoint posture.

## Current Status

Validated. All tasks in the active queue through `T-009A` are complete and validated.

The change is ready for ship review and archive preparation. The broader Harness V3 roadmap remains a future program and is not considered completed by this change.

## Architecture Status

### Current Operating Topology

```text
User request
  -> AGENTS.md / active .specs state
  -> Altitude durable-work path
  -> task contract with allowed files, evidence, and validation gates
  -> execution ledger
  -> validation ledger
  -> report / ship artifact
```

### Current Diagram

```mermaid
flowchart LR
    A[User Request] --> B[Altitude State]
    B --> C[Task Contract]
    C --> D[Execution Ledger]
    D --> E[Evidence]
    E --> F[Validation]
    F --> G[Report and Ship Note]
```

## Completed Work

- Froze the target operating model for the harness.
- Defined MCP governance and the runtime expectation matrix.
- Defined the decomposition model and the `SDD` vs `Task-Spec` selection rule.
- Replaced the canonical `knowledge_context/` dependency with `.specs/memory`.
- Removed generic natural-language workflow phase routes from routing.
- Created the Markdown authoring standard for dense durable artifacts.
- Upgraded `.specs` templates, SDD templates, and Markdown-producing skills for architecture-aware output.
- Defined the KB governance standard and Fabric golden-domain rollout model.
- Resolved the Fabric Copilot capacity contradiction.
- Added Fabric governance metadata and critical-claim registers.
- Audited high-impact Fabric claims and isolated the Eventhouse/Warehouse parity gap.
- Repaired `FABRIC-CC-004` by aligning Eventhouse, Warehouse, entry, quick-reference, and machine-readable Fabric registers.

## Pending Work

No pending tasks inside `harness-360-refactor`.

Future work belongs to the broader Harness V3 roadmap, especially:

- golden behavior fixtures
- coordinator contract extraction
- state resolution contract
- phase engine contract
- allocation contracts
- Task-Spec integration
- runtime verification for RTK and Headroom

## Traceability Snapshot

| Workstream | Status | Evidence | Risk |
| --- | --- | --- | --- |
| Operating model freeze | validated | `E-001`, `V-001` | low |
| MCP governance | validated | `V-002` | medium |
| Decomposition model | validated | `V-003` | medium |
| Knowledge-context policy replacement | validated | `V-004` | low |
| Workflow route narrowing | validated | `V-005` | medium |
| Markdown density standard | validated | `V-006` to `V-008` | low |
| KB governance standard | validated | `V-009` | medium |
| Fabric Copilot contradiction repair | validated | `V-010` | low |
| Fabric governance rollout and parity audit | validated | `E-004`, `V-011`, `V-012` | medium |
| Fabric Eventhouse/Warehouse parity repair | validated | `E-005`, `V-013` | low |

## Risks

- Runtime enforcement is still incomplete for some V3 policies; several controls are currently policy-backed rather than plugin-enforced.
- The Harness V3 roadmap is intentionally larger than this change and still requires fixture-backed migration waves before runtime mutation.
- Fabric is the first governed KB domain; other KB domains may still contain stale or unsupported claims.

## Blockers

None for this change.

## Decisions

- Keep `Altitude` as the durable-work coordinator path.
- Treat `.specs` as the live change state and `.specs/memory` as the active memory surface.
- Treat Fabric as the golden KB governance rollout domain.
- Narrow `Eventhouse for Warehouse` to the supported Eventhouse endpoint posture: read-oriented KQL / Real-Time Intelligence access over Warehouse tables, with Warehouse remaining the T-SQL/DML owner.

## Validation Evidence

- `.specs/changes/harness-360-refactor/04-validation.md`
- `.specs/changes/harness-360-refactor/evidence/E-004-fabric-governance-rollout-and-parity-audit.md`
- `.specs/changes/harness-360-refactor/evidence/E-005-fabric-eventhouse-warehouse-parity-repair.md`

## Business Impact

The harness now has clearer operational rules for durable work, better handoff artifacts, and a stronger pattern for keeping critical KB guidance accurate.

## Technical Impact

The change improved routing policy, decomposition discipline, artifact templates, KB governance, and Fabric domain consistency without taking on the larger Harness V3 runtime migration yet.

## Operational Impact

Future harness work should start from active `.specs` state, execute one ready task at a time, record evidence, and validate before reporting or shipping.

## Next Recommended Action

Archive or close `harness-360-refactor`, then start the Harness V3 roadmap with the safety-foundation task pack:

```text
1. coordinator contract
2. state resolution contract
3. artifact registry
4. migration test plan
5. legacy preservation matrix
6. phase engine spec
7. artifact template catalog
8. allocation contracts
```
