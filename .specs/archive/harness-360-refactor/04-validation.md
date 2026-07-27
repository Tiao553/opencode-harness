# Harness 360 Refactor - Validation

## Validation V-001

- Task: T-001
- Verdict: validated
- Validation method: manual consistency review against the grounding files listed in the task and master plan
- Scope check: passed
- Evidence check: passed
- Notes: the target operating model aligns with the user-approved decisions and the current harness contracts

## Validation V-002

- Task: T-002
- Verdict: validated
- Validation method: manual consistency review against `.specs/shared/mcp-governance.md`, `AGENTS.md`, `docs/ALTITUDE_SPECS_HARNESS.md`, `opencode.json`, and `config/opencode.example.jsonc`
- Scope check: passed
- Evidence check: passed
- Notes: the matrix clarifies live runtime expectations and removes the assumption that MCP is always available

## Validation V-003

- Task: T-003
- Verdict: validated
- Validation method: manual consistency review against `.specs/shared/task-contract.md`, `agents/altitude-plan.agent.md`, `skills/workflow-commands/commands/build.md`, `sdd/architecture/WORKFLOW_CONTRACTS.yaml`, and `docs/HARNESS_TARGET_OPERATING_MODEL.md`
- Scope check: passed
- Evidence check: passed
- Notes: the decomposition model now explicitly blocks oversized execution and removes ambiguity around the `Task-Spec` leaf-task role

## Validation V-004

- Task: T-004A
- Verdict: validated
- Validation method: manual consistency review of `README.md` and `config/grounding.md` against `docs/HARNESS_TARGET_OPERATING_MODEL.md` and the change ledger
- Scope check: passed
- Evidence check: passed
- Notes: the canonical policy surface now points to `.specs/memory`; `AGENTS.md` required no edit because it did not contain an active `knowledge_context/` dependency

## Validation V-005

- Task: T-005A
- Verdict: validated
- Validation method: policy consistency review across `config/routing.json`, `AGENTS.md`, and `skills/workflow-commands/SKILL.md`
- Scope check: passed
- Evidence check: passed
- Notes: the routing layer was brought into alignment with the already-correct command-first policy docs, so `AGENTS.md` and `skills/workflow-commands/SKILL.md` needed no content change

## Validation V-006

- Task: T-007A
- Verdict: validated
- Validation method: manual review of the new standard against the user-requested density goals and existing harness document types
- Scope check: passed
- Evidence check: passed
- Notes: the standard now codifies density, architecture views, traceability, anti-patterns, and validation posture

## Validation V-007

- Task: T-007B
- Verdict: validated
- Validation method: representative review of `.specs` templates, especially `task.template.md`, `change.template.md`, and `validation.template.md`
- Scope check: passed
- Evidence check: passed
- Notes: `.specs` templates now carry enough structural detail to support KT and architecture-aware execution

## Validation V-008

- Task: T-007C,T-007D
- Verdict: validated
- Validation method: representative review of `sdd/templates/DESIGN_TEMPLATE.md`, `DEFINE_TEMPLATE.md`, `RUNBOOK_TEMPLATE.md`, and the workflow/create-skills instructions
- Scope check: passed
- Evidence check: passed
- Notes: the authoring path is now reinforced both in templates and in the skills that produce those artifacts

## Validation V-009

- Task: T-006A
- Verdict: validated
- Validation method: manual consistency review against the operating model, MCP governance matrix, Fabric KB entry files, and KB architect behavior
- Scope check: passed
- Evidence check: passed
- Notes: the standard is now explicit about metadata, freshness, contradiction handling, evidence, and the Fabric golden-domain rollout sequence

## Validation V-010

- Task: T-006B1
- Verdict: validated
- Validation method: source-backed comparison between the three updated Fabric KB files and Microsoft Learn `fundamentals/copilot-enable-fabric` (updated 2026-06-11)
- Scope check: passed
- Evidence check: passed
- Notes: the contradiction was resolved in favor of the current Microsoft Learn prerequisite model: Copilot is enabled by default for paid Fabric capacities (`F2` or higher), Power BI Premium capacities (`P1` or higher) are also supported for the relevant Power BI path, and Pro/PPU workspaces require Fabric Copilot capacity and workspace assignment

## Validation V-011

- Task: T-006B2
- Verdict: validated
- Validation method: review of Fabric entry files and machine-readable spec against the KB governance standard
- Scope check: passed
- Evidence check: passed
- Notes: governance metadata and the first critical-claim register are now explicit on the domain entry surfaces and in `fabric-config.yaml`

## Validation V-012

- Task: T-006B3
- Verdict: validated
- Validation method: parity audit across Fabric entry files and supporting deep files for the remaining high-impact claims
- Scope check: passed
- Evidence check: passed
- Notes: the audit found one remaining focused parity gap, `FABRIC-CC-004` (Eventhouse for Warehouse), and converted it into `T-009A`; the remaining reviewed claims in this pass were aligned enough to avoid wider scope expansion

## Validation V-013

- Task: T-009A
- Verdict: validated
- Validation method: source-backed manual review against current Microsoft Learn Eventhouse endpoint and Warehouse pages, followed by local parity grep across Fabric entry and concept surfaces
- Scope check: passed
- Evidence check: passed
- Notes: `FABRIC-CC-004` is now narrowed to the supported Eventhouse endpoint posture: read-oriented KQL/Real-Time Intelligence access over Warehouse tables, with Warehouse remaining the T-SQL/DML owner; the entry files, deeper concept files, and machine-readable critical-claim register now agree
