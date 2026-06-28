# Harness Refactor Master Plan

## Status

- State: active
- Current phase: Harness V3 Delegation Migration shipped; next wave pending user review
- System of record: `~/.config/opencode/.specs/changes/harness-v3-delegation-migration/`
- Shareable mirror: `docs/`

## Objective

Refactor the OpenCode harness into a single coordinated operating model where `Altitude` is the primary coordinator, `workflow:*` commands are compatibility wrappers, decomposition is smaller and stricter, MCP usage is explicitly governed, KB quality is measurable, and the system is easier to maintain, hand off, and trust.

## Update Protocol

Update this file on every meaningful step.

Each update must record:

- step id
- status change
- decisions made
- todo status changes
- files touched
- evidence produced
- next ready task
- blockers, if any

## Grounding

This plan is grounded in:

- `AGENTS.md`
- `README.md`
- `docs/ALTITUDE_SPECS_HARNESS.md`
- `.specs/shared/altitude-contract.md`
- `.specs/shared/change-request-contract.md`
- `.specs/shared/task-contract.md`
- `.specs/shared/definition-of-done.md`
- `.specs/shared/acceptance-criteria.md`
- `.specs/shared/mcp-governance.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- `skills/workflow-commands/SKILL.md`
- `skills/workflow-commands/commands/build.md`
- `config/routing.json`
- `opencode.json`
- `plugins/permission-hardening.ts`
- `plugins/specs-state.ts`
- `plugins/rtk-native.ts`
- `plugins/context-budget.ts`
- `kb/microsoft-fabric/index.md`
- `kb/microsoft-fabric/quick-reference.md`
- `kb/microsoft-fabric/08-ai-capabilities/concepts/copilot-customization.md`

## Locked Decisions

| ID | Decision |
| --- | --- |
| D-001 | `Altitude` is the primary coordinator for durable work. |
| D-002 | `/workflow:*` remains as compatibility wrappers, not a parallel operational state machine. |
| D-003 | `explore + interview/grill` is the front door for ambiguous natural-language work. |
| D-004 | The operational ledger lives in `.specs/changes/...`; `docs/...` is the shareable mirror. |
| D-005 | `SDD` vs `Task-Spec` selection is based on effort and scope. |
| D-006 | Leaf tasks deliver one small vertical slice and should touch at most three non-ledger files. |
| D-007 | If decomposition fails, escalate to an extra planner refinement instead of executing a larger task. |
| D-008 | Execution requires the full task contract before any real source edit. |
| D-009 | MCP governance uses a central matrix plus per-agent override rules. |
| D-010 | KB quality requires metadata, sources, and validation checks. |
| D-011 | KB refresh is on-demand, but must follow an explicit review-and-update workflow. |
| D-012 | `knowledge_context/` is replaced by `.specs/memory`. |
| D-013 | Microsoft Fabric is the golden domain pilot. |
| D-014 | Agent consolidation is high-aggression. |
| D-015 | Artifacts are English-first; interaction can be PT/EN. |
| D-016 | Durable Markdown artifacts must follow a dense authoring standard with architecture-as-text or Mermaid when system shape or flow matters. |

## Deliverables

| Deliverable | Status | Path |
| --- | --- | --- |
| Master plan | done | `docs/HARNESS_REFACTOR_MASTER_PLAN.md` |
| Target operating model | done | `docs/HARNESS_TARGET_OPERATING_MODEL.md` |
| MCP governance matrix | done | `docs/HARNESS_MCP_GOVERNANCE_MATRIX.md` |
| KB governance standard | done | `docs/HARNESS_KB_GOVERNANCE_STANDARD.md` |
| Harness evolution tree | done | `docs/HARNESS_EVOLUTION_TREE.md` |
| V3 refactor roadmap | done | `docs/HARNESS_V3_REFACTOR_ROADMAP.md` |
| V3 architecture freeze | done | `docs/HARNESS_V3_ARCHITECTURE.md` |
| V3 coordinator contract | done | `docs/HARNESS_V3_COORDINATOR_CONTRACT.md` |
| V3 state resolution contract | done | `docs/HARNESS_V3_STATE_RESOLUTION_CONTRACT.md` |
| V3 migration test plan | done | `docs/HARNESS_V3_MIGRATION_TEST_PLAN.md` |
| V3 golden fixtures | done | `test/fixtures/harness-v3/` |
| V3 grounding split | done | `config/grounding.md` |
| V3 strategic coordinator | done | `agents/altitude.agent.md` |
| V3 tactical data-engineer coordinator | done | `agents/data-engineer.agent.md` |
| V3 unified phase contract | done | `.specs/shared/phase-engine-contract.md` |
| V3 artifact/allocation hardening | done | `.specs/templates/` |
| V3 Ralph Loop globalization | done | `.specs/shared/execution-loop-contract.md` |
| V3 Task-Spec integration | done | `docs/HARNESS_V3_TASK_SPEC_INTEGRATION.md` |
| V3 delegation migration | done | `.specs/shared/specialist-allocation-contract.md` |
| Tactical data-engineering model | done | `docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md` |
| Live change ledger | done | `.specs/changes/harness-360-refactor/` |
| V3 safety-foundation ledger | done | `.specs/changes/harness-v3-safety-foundation/` |

## Workstream Roadmap

| Phase | Goal | Main outputs | Acceptance |
| --- | --- | --- | --- |
| 0 | Bootstrap tracking | live ledger, master plan, first ADR, first task pack | one canonical plan surface and one operational ledger exist |
| 1 | Freeze operating model | target operating model, wrapper rules, SDD vs Task-Spec selection | no unresolved control-plane ambiguity remains |
| 2 | Govern MCPs | matrix, hard-stop rules, evidence contract | MCP use is deterministic and auditable |
| 3 | Rebuild decomposition | stronger `altitude-plan`, leaf-task model, escalation rule | tasks are small, verifiable, and ready before build |
| 4 | Harden enforcement | permissions, execution refusal, validation boundaries | execution cannot proceed without full contract |
| 5 | Replace old context surface | `.specs/memory` replaces `knowledge_context/` references | no active workflow depends on the broken surface |
| 6 | Unify intake and routing | ambiguous intake, wrapper routing, policy consistency | routing no longer bypasses command policy |
| 7 | Consolidate agents and skills | remove stale overlap, upgrade skill anatomy | lower sprawl and clearer ownership |
| 8 | Repair KB governance and Fabric | KB standard, contradiction checks, Fabric cleanup | Fabric becomes a trustworthy golden domain |

## Task Board

| Task | Status | Summary |
| --- | --- | --- |
| T-000 | validated | Complete the 360 audit and decision harvest |
| T-001 | validated | Bootstrap the live ledger and freeze the target operating model |
| T-002 | validated | Define the central MCP governance matrix |
| T-003 | validated | Design the decomposition engine and the SDD vs Task-Spec selection matrix |
| T-004A | validated | Replace canonical `knowledge_context/` policy references with `.specs/memory` |
| T-004B | pending | Rewrite workflow brainstorm and legacy knowledge-context surfaces |
| T-005A | validated | Remove generic natural-language workflow-phase routes |
| T-005B | pending | Rewrite workflow build surfaces to stop late task invention |
| T-006A | validated | Define the KB governance standard |
| T-006B | validated | Repair Fabric contradictions and golden-domain metadata |
| T-006B1 | validated | Repair Fabric Copilot capacity contradiction and align entry points |
| T-006B2 | validated | Add Fabric governance metadata and critical-claim register |
| T-006B3 | validated | Audit remaining Fabric high-impact claims for quick-reference parity |
| T-007A | validated | Define the Markdown authoring standard |
| T-007B | validated | Upgrade `.specs` templates for density and architecture views |
| T-007C | validated | Upgrade `sdd` templates for denser architectural artifacts |
| T-007D | validated | Upgrade Markdown-producing skill guidance |
| T-008A | validated | Define Ask-User policy and Todo Allocation Contract |
| T-008B | validated | Add tactical data-engineering coordinator track to the V3 roadmap |
| T-009A | validated | Repair Fabric Eventhouse for Warehouse parity gap |

## Execution Log

### S00 - Audit 360

- Status: completed
- Result: structural 360 completed across agents, skills, config, plugins, `.specs`, `sdd`, and KB surfaces
- Evidence: chat audit plus grounded file review

### S01 - Decision Harvest

- Status: completed
- Result: locked the control-plane, decomposition, MCP, KB, and language decisions
- Evidence: decisions recorded in this plan and ADR-001

### S02 - Bootstrap Ledger

- Status: completed
- Files touched:
  - `.specs/changes/harness-360-refactor/00-intent.md`
  - `.specs/changes/harness-360-refactor/01-structure.md`
  - `.specs/changes/harness-360-refactor/02-decomposition.md`
  - `.specs/changes/harness-360-refactor/state.md`
  - `.specs/memory/active-state.md`
- Result: live ledger created and queue initialized
- Evidence: `.specs/changes/harness-360-refactor/evidence/E-001-bootstrap-and-phase-1-freeze.md`

### S03 - Freeze Target Operating Model

- Status: completed
- Task: `T-001`
- Files touched:
  - `docs/HARNESS_TARGET_OPERATING_MODEL.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: target operating model frozen before deeper config refactors
- Evidence: `.specs/changes/harness-360-refactor/04-validation.md`

### S04 - Define MCP Governance Matrix

- Status: completed
- Task: `T-002`
- Files touched:
  - `docs/HARNESS_MCP_GOVERNANCE_MATRIX.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: central MCP posture and hard stops frozen
- Evidence: `.specs/changes/harness-360-refactor/04-validation.md`

### S05 - Freeze Decomposition Engine

- Status: completed
- Task: `T-003`
- Files touched:
  - `docs/HARNESS_DECOMPOSITION_MODEL.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: the harness now has a frozen decomposition engine, a formal `SDD` vs `Task-Spec` selection rule, and an explicit three-file non-ledger leaf-task rule
- Evidence: `.specs/changes/harness-360-refactor/04-validation.md`

### S06 - Planning Refinement for Wave 2

- Status: completed
- Result: split the next two larger workstreams into smaller execution-ready leaf tasks
- Files touched:
  - `.specs/changes/harness-360-refactor/02-decomposition.md`
  - `.specs/changes/harness-360-refactor/tasks/T-004A-replace-canonical-knowledge-context-policy.md`
  - `.specs/changes/harness-360-refactor/tasks/T-005A-remove-natural-language-workflow-phase-routes.md`
  - `.specs/changes/harness-360-refactor/state.md`
  - `.specs/memory/active-state.md`

### S07 - Replace Canonical knowledge_context Policy References

- Status: completed
- Task: `T-004A`
- Files touched:
  - `README.md`
  - `config/grounding.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: the canonical policy surface now points to `.specs/memory` instead of the missing `knowledge_context/` registry model
- Evidence: `.specs/changes/harness-360-refactor/04-validation.md`

### S08 - Remove Generic Workflow-Phase Routes

- Status: completed
- Task: `T-005A`
- Files touched:
  - `config/routing.json`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: generic natural-language routing for workflow phases no longer bypasses command-first workflow policy
- Evidence: `.specs/changes/harness-360-refactor/04-validation.md`

### S09 - Prepare the KB Governance Standard Task

- Status: completed
- Result: prepared `T-006A` as the next execution-ready documentation task for the KB governance standard
- Files touched:
  - `.specs/changes/harness-360-refactor/02-decomposition.md`
  - `.specs/changes/harness-360-refactor/tasks/T-006A-define-kb-governance-standard.md`
  - `.specs/changes/harness-360-refactor/state.md`
  - `.specs/memory/active-state.md`

### S10 - Define Markdown Authoring Standard

- Status: completed
- Task: `T-007A`
- Files touched:
  - `.specs/shared/markdown-authoring-standard.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: the harness now has a canonical dense-authoring standard for durable Markdown artifacts
- Evidence: `.specs/changes/harness-360-refactor/evidence/E-002-markdown-template-hardening.md`

### S11 - Upgrade .specs Templates

- Status: completed
- Task: `T-007B`
- Files touched:
  - `.specs/templates/*.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: the `.specs` templates now require denser architecture, traceability, and evidence-friendly structure
- Evidence: `.specs/changes/harness-360-refactor/evidence/E-002-markdown-template-hardening.md`

### S12 - Upgrade SDD Templates and Markdown-Producing Skills

- Status: completed
- Task: `T-007C`, `T-007D`
- Files touched:
  - `sdd/templates/*.md`
  - `skills/create-skills/SKILL.md`
  - `skills/workflow-commands/SKILL.md`
  - `skills/workflow-define/SKILL.md`
  - `skills/workflow-design/SKILL.md`
- Result: both SDD templates and the skills that author durable Markdown now explicitly demand dense, architectural artifacts
- Evidence: `.specs/changes/harness-360-refactor/evidence/E-002-markdown-template-hardening.md`

### S13 - Define KB Governance Standard

- Status: completed
- Task: `T-006A`
- Files touched:
  - `docs/HARNESS_KB_GOVERNANCE_STANDARD.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: the harness now has a dense KB governance standard covering metadata, freshness, contradiction handling, validation, evidence, and Fabric golden-domain rollout
- Evidence: `.specs/changes/harness-360-refactor/04-validation.md`

### S14 - Split the Fabric Repair Wave

- Status: completed
- Result: decomposed the Fabric repair umbrella into smaller contradiction-cluster tasks, with `T-006B1` ready as the next execution slice
- Files touched:
  - `.specs/changes/harness-360-refactor/02-decomposition.md`
  - `.specs/changes/harness-360-refactor/tasks/T-006B1-repair-fabric-copilot-capacity-contradiction.md`
  - `.specs/changes/harness-360-refactor/tasks/T-006B2-add-fabric-governance-metadata.md`
  - `.specs/changes/harness-360-refactor/tasks/T-006B3-audit-fabric-high-impact-claims.md`
  - `.specs/changes/harness-360-refactor/state.md`
  - `.specs/memory/active-state.md`

### S15 - Publish the Harness Evolution Tree

- Status: completed
- Files touched:
  - `docs/HARNESS_EVOLUTION_TREE.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: published a text-architecture tree that explains how the harness evolves from intake to task delivery and project delivery
- Evidence: `docs/HARNESS_EVOLUTION_TREE.md`

### S16 - Publish the V3 Refactor Roadmap

- Status: completed
- Files touched:
  - `docs/HARNESS_V3_REFACTOR_ROADMAP.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: published the full phased roadmap for migrating to the coordinator-centered V3 architecture
- Evidence: `docs/HARNESS_V3_REFACTOR_ROADMAP.md`

### S17 - Add Ask-User, Todo Allocation, and Tactical Data-Engineer Track

- Status: completed
- Files touched:
  - `.specs/shared/ask-user-policy.md`
  - `.specs/shared/todo-allocation-contract.md`
  - `docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md`
  - `docs/HARNESS_V3_REFACTOR_ROADMAP.md`
  - `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- Result: the roadmap now includes the tactical `Data Engineer` coordinator track, plus explicit shared contracts for multiple-choice Ask-User and hierarchical todo projection
- Evidence: `.specs/shared/ask-user-policy.md`, `.specs/shared/todo-allocation-contract.md`, `docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md`

### S18 - Close the Remaining 006 and 007 Batch

- Status: completed
- Tasks: `T-006B2`, `T-006B3`
- Files touched:
  - `kb/microsoft-fabric/index.md`
  - `kb/microsoft-fabric/quick-reference.md`
  - `kb/microsoft-fabric/specs/fabric-config.yaml`
  - `.specs/changes/harness-360-refactor/tasks/T-006B2-add-fabric-governance-metadata.md`
  - `.specs/changes/harness-360-refactor/tasks/T-006B3-audit-fabric-high-impact-claims.md`
  - `.specs/changes/harness-360-refactor/tasks/T-009A-repair-fabric-eventhouse-warehouse-parity.md`
  - `.specs/changes/harness-360-refactor/evidence/E-004-fabric-governance-rollout-and-parity-audit.md`
- Result: completed the governance rollout and parity audit for the remaining 006 batch work, and isolated the next Fabric gap into `T-009A`
- Evidence: `.specs/changes/harness-360-refactor/evidence/E-004-fabric-governance-rollout-and-parity-audit.md`

### S19 - Repair Fabric Eventhouse/Warehouse Parity

- Status: completed
- Task: `T-009A`
- Files touched:
  - `kb/microsoft-fabric/01-logging-monitoring/concepts/eventhouse-basics.md`
  - `kb/microsoft-fabric/04-data-warehouse/concepts/warehouse-basics.md`
  - `kb/microsoft-fabric/index.md`
  - `kb/microsoft-fabric/quick-reference.md`
  - `kb/microsoft-fabric/specs/fabric-config.yaml`
- Result: closed `FABRIC-CC-004` by narrowing the claim to Eventhouse endpoint access over Warehouse tables, while preserving Warehouse as the T-SQL/DML owner
- Evidence: `.specs/changes/harness-360-refactor/evidence/E-005-fabric-eventhouse-warehouse-parity-repair.md`

### S20 - Ship Harness V3 Safety Foundation

- Status: completed
- Files touched:
  - `docs/HARNESS_V3_ARCHITECTURE.md`
  - `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
  - `docs/HARNESS_V3_STATE_RESOLUTION_CONTRACT.md`
  - `docs/HARNESS_V3_PHASE_ENGINE_SPEC.md`
  - `docs/HARNESS_V3_ARTIFACT_REGISTRY.md`
  - `docs/HARNESS_V3_MIGRATION_TEST_PLAN.md`
  - `docs/HARNESS_V3_LEGACY_PRESERVATION_MATRIX.md`
  - `docs/HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md`
  - `.specs/shared/*allocation*.md`
  - `.specs/shared/phase-engine-contract.md`
  - `.specs/shared/state-conflict-resolution-policy.md`
  - `.specs/templates/prd-template.md`
  - `.specs/templates/adr-template.md`
  - `.specs/templates/test-spec-template.md`
  - `.specs/templates/validation-report-template.md`
  - `.specs/templates/ship-summary-template.md`
  - `test/fixtures/harness-v3/`
  - `.specs/changes/harness-v3-safety-foundation/`
- Result: created the non-runtime safety foundation required before later V3 migration waves mutate commands, coordinators, plugins, or runtime behavior
- Evidence: `.specs/changes/harness-v3-safety-foundation/evidence/E-001-safety-foundation-and-fixtures.md`

### S21 - Ship Harness V3 Grounding Split

- Status: completed
- Files touched:
  - `config/grounding.md`
  - `.specs/changes/harness-v3-grounding-split/`
- Result: replaced the grounding monolith with a thin index over `.specs/shared` contracts
- Evidence: `.specs/changes/harness-v3-grounding-split/evidence/E-001-grounding-split.md`

### S22 - Ship Harness V3 Strategic Coordinator

- Status: completed
- Files touched:
  - `agents/altitude.agent.md`
  - `agents/altitude-*.agent.md`
  - `opencode.json`
  - `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
  - `.specs/changes/harness-v3-strategic-coordinator/`
- Result: introduced one visible `altitude` coordinator and demoted phase-specific Altitude agents to hidden subagents
- Evidence: `.specs/changes/harness-v3-strategic-coordinator/evidence/E-001-altitude-coordinator.md`

### S23 - Ship Harness V3 Data Engineer Coordinator

- Status: completed
- Files touched:
  - `agents/data-engineer.agent.md`
  - `docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md`
  - `opencode.json`
  - `.specs/changes/harness-v3-data-engineer-coordinator/`
- Result: introduced the visible `data-engineer` tactical coordinator and preserved `/data:*` behavior as internal routes
- Evidence: `.specs/changes/harness-v3-data-engineer-coordinator/evidence/E-001-data-engineer-coordinator.md`

### S24 - Ship Harness V3 Unified Phase Contract

- Status: completed
- Files touched:
  - `docs/HARNESS_V3_PHASE_ENGINE_SPEC.md`
  - `.specs/shared/phase-engine-contract.md`
  - `.specs/shared/compatibility-policy.md`
  - `.specs/changes/harness-v3-unified-phase-contract/`
- Result: mapped legacy workflow lifecycle semantics into the V3 phase contract and clarified that `workflow:*` remains a compatibility wrapper, not a phase authority
- Evidence: `.specs/changes/harness-v3-unified-phase-contract/evidence/E-001-unified-phase-contract.md`

### S25 - Ship Harness V3 Artifact Template and Allocation Hardening

- Status: completed
- Files touched:
  - `.specs/templates/prd-template.md`
  - `.specs/templates/adr-template.md`
  - `.specs/templates/test-spec-template.md`
  - `.specs/templates/validation-report-template.md`
  - `.specs/templates/ship-summary-template.md`
  - `.specs/shared/allocation-contract.md`
  - `.specs/shared/global-allocation-contract.md`
  - `.specs/shared/local-allocation-contract.md`
  - `docs/HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md`
  - `.specs/changes/harness-v3-artifact-allocation-hardening/`
- Result: official V3 templates now include source authority, allocation, evidence, validation, and rollback fields; allocation contracts define precedence, broadening rules, and Task-Spec inheritance
- Evidence: `.specs/changes/harness-v3-artifact-allocation-hardening/evidence/E-001-template-allocation-hardening.md`

### S26 - Ship Harness V3 Ralph Loop Globalization

- Status: completed
- Files touched:
  - `.specs/shared/execution-loop-contract.md`
  - `.specs/shared/task-contract.md`
  - `.specs/shared/todo-allocation-contract.md`
  - `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
  - `.specs/changes/harness-v3-ralph-loop-globalization/`
- Result: executable work now carries loop posture, step boundaries, verification evidence, bounded repair, runtime `verify_step` usage rules, and manual fallback behavior
- Evidence: `.specs/changes/harness-v3-ralph-loop-globalization/evidence/E-001-ralph-loop-globalization.md`

### S27 - Ship Harness V3 Task-Spec Integration

- Status: completed
- Files touched:
  - `docs/HARNESS_V3_TASK_SPEC_INTEGRATION.md`
  - `skills/task-spec/templates/task-spec.md.tpl`
  - `skills/task-spec/scripts/generate-task-spec.sh`
  - `.specs/changes/harness-v3-task-spec-integration/`
- Result: Task-Spec is now documented as the official S/M leaf-task engine and carries additive Harness V3 bridge metadata for parent change, phase, allocation, artifact sources, verification, evidence, rollback, and loop posture
- Evidence: `.specs/changes/harness-v3-task-spec-integration/evidence/E-001-task-spec-bridge.md`

### S28 - Ship Harness V3 Delegation Migration

- Status: completed
- Files touched:
  - `.specs/shared/specialist-allocation-contract.md`
  - `.specs/shared/local-allocation-contract.md`
  - `.specs/shared/task-contract.md`
  - `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
  - `agents/altitude.agent.md`
  - `.specs/changes/harness-v3-delegation-migration/`
- Result: delegation is now represented as pre-execution specialist allocation with grounding bundle, evidence contract, validation responsibility, stop condition, and over-delegation controls
- Evidence: `.specs/changes/harness-v3-delegation-migration/evidence/E-001-delegation-allocation.md`

## Current Queue

- Active change: `harness-v3-delegation-migration`
- Next ready task: none
- Recommended agent: `altitude-intent`
- Current focus: review shipped Delegation Migration, then audit Documentation Mode and Production Code Mode

## Evidence Index

| Evidence | Purpose |
| --- | --- |
| `.specs/changes/harness-360-refactor/evidence/E-001-bootstrap-and-phase-1-freeze.md` | bootstrap, plan, operating model, and MCP matrix evidence |
| `.specs/changes/harness-360-refactor/evidence/E-002-markdown-template-hardening.md` | markdown authoring standard and template hardening evidence |
| `.specs/changes/harness-360-refactor/evidence/E-004-fabric-governance-rollout-and-parity-audit.md` | Fabric governance metadata rollout and high-impact claim parity audit |
| `.specs/changes/harness-360-refactor/evidence/E-005-fabric-eventhouse-warehouse-parity-repair.md` | Fabric Eventhouse/Warehouse parity repair |
| `.specs/changes/harness-v3-safety-foundation/evidence/E-001-safety-foundation-and-fixtures.md` | Harness V3 safety-foundation docs, contracts, templates, and fixtures |
| `.specs/changes/harness-v3-grounding-split/evidence/E-001-grounding-split.md` | Harness V3 grounding split |
| `.specs/changes/harness-v3-strategic-coordinator/evidence/E-001-altitude-coordinator.md` | Harness V3 strategic coordinator |
| `.specs/changes/harness-v3-data-engineer-coordinator/evidence/E-001-data-engineer-coordinator.md` | Harness V3 tactical data-engineer coordinator |
| `.specs/changes/harness-v3-unified-phase-contract/evidence/E-001-unified-phase-contract.md` | Harness V3 unified phase contract |
| `.specs/changes/harness-v3-artifact-allocation-hardening/evidence/E-001-template-allocation-hardening.md` | Harness V3 artifact template and allocation hardening |
| `.specs/changes/harness-v3-ralph-loop-globalization/evidence/E-001-ralph-loop-globalization.md` | Harness V3 Ralph Loop globalization |
| `.specs/changes/harness-v3-task-spec-integration/evidence/E-001-task-spec-bridge.md` | Harness V3 Task-Spec integration |
| `.specs/changes/harness-v3-delegation-migration/evidence/E-001-delegation-allocation.md` | Harness V3 Delegation Migration |
| `.specs/changes/harness-360-refactor/03-execution-ledger.md` | execution trace |
| `.specs/changes/harness-360-refactor/04-validation.md` | validation trace |

## Blockers

- No runtime blocker yet.
- `plugins/specs-state.ts` still cannot hard-stop edits dynamically; this remains a known implementation constraint for later phases.

## Next Step

Review the shipped Harness V3 Data Engineer Coordinator, then choose the next wave:

- harden fixture validation into a semantic runner, or
- audit the Unified Phase Contract wave from `docs/HARNESS_V3_REFACTOR_ROADMAP.md`
