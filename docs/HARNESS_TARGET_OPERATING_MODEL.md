# Harness Target Operating Model

## Purpose

Define the target operating model for the OpenCode harness before deeper config and agent refactors land.

This document is the design freeze for the control plane, state surfaces, intake model, decomposition model, execution boundaries, KB governance, MCP governance, and migration direction.

## Grounding

This operating model is grounded in:

- `AGENTS.md`
- `docs/ALTITUDE_SPECS_HARNESS.md`
- `.specs/shared/altitude-contract.md`
- `.specs/shared/task-contract.md`
- `.specs/shared/change-request-contract.md`
- `skills/workflow-commands/SKILL.md`
- `skills/workflow-commands/commands/build.md`
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- `config/routing.json`
- `opencode.json`
- `plugins/permission-hardening.ts`
- `plugins/specs-state.ts`

## Design Goals

- one durable coordinator for complex work
- smaller, more verifiable tasks
- explicit control over MCP activation
- stronger grounding and less drift between docs and runtime behavior
- easier maintenance and knowledge transfer
- compatibility for old workflow habits without preserving the split-brain model

## Core Model

### 1. Coordinator

`Altitude` is the coordinator for durable work.

Altitude owns the change lifecycle:

1. Intent
2. Structure
3. Decomposition
4. Execution
5. Validation
6. Report
7. Memory

No other surface owns a competing operational state machine.

### 2. State Surfaces

The system has two state surfaces with different purposes.

| Surface | Role | Mutability |
| --- | --- | --- |
| `.specs/changes/...` | operational ledger, active queue, tasks, evidence, validation | live, mutable |
| `docs/...` | shareable mirror of important operating documents | curated mirror |

For this self-hosted harness repo, the home-global and repo-local paths share the same physical workspace. The distinction is logical, not physical:

- `.specs/...` is the operational system of record
- `docs/...` is the shareable mirror and design surface

### 3. Workflow Commands

`/workflow:*` remains supported as a compatibility surface.

Its future role is:

- translate command intent into the `Altitude` operating model
- read the same contracts and shared policies
- avoid maintaining parallel execution state under `sdd/features/`

This means `workflow:*` can remain familiar while losing control-plane ownership.

## Intake Model

### Explicit Commands

If the user explicitly invokes a native command, that command still wins.

### Ambiguous Natural Language

For ambiguous requests, the intake path is:

1. lightweight repo/context exploration through `dev.codebase-explorer` or built-in `explore`
2. interview/grill flow to extract real intent and pressure-test assumptions
3. route into `altitude-intent` or the right specialist only after ambiguity is reduced

The intake rule is intentionally skeptical: the harness should not quietly fill gaps just to be helpful.

## Decomposition Model

### Selection Rule

The harness uses both `SDD` and `Task-Spec`, but not indiscriminately.

| Work shape | Primary model |
| --- | --- |
| S or M effort, bounded local change | `Task-Spec` leaf task inside an `Altitude` change |
| L or XL effort, multi-module, architectural, or high-risk | full `Altitude` change with richer decomposition |

### Leaf Task Rule

Every leaf task should:

- deliver one small vertical slice or one bounded document outcome
- touch at most three non-ledger files
- remain reversible
- have explicit acceptance criteria, verification, evidence, and rollback

Ledger files such as `state.md`, `03-execution-ledger.md`, `04-validation.md`, and task files do not count toward the three-file product limit.

### Decomposition Failure Rule

If work cannot be made small, reversible, and verifiable, the system must not continue into execution. It must escalate to extra planning refinement.

This is a hard operating rule, not a suggestion.

## Execution Model

### No On-the-Fly Task Invention

Execution consumes a ready task.

Execution does not invent its own operational task model at build time.

That means:

- no late `implementation_plan.md` as the real execution source of truth
- no chunk generation that bypasses prior decomposition
- no hidden scope expansion during build

### Full Contract Gate

Execution begins only when the active task defines:

- objective
- context
- source references
- allowed files
- forbidden scope
- dependencies
- implementation steps
- acceptance criteria
- verification commands
- evidence required
- rollback
- completion checklist

## Memory Model

`.specs/memory` replaces `knowledge_context/` as the durable project-memory surface.

The target memory surface is operationally complete and may include:

- `active-state.md`
- `INDEX.md`
- `project-map.md`
- `repo-structure.md`
- `architecture-map.md`
- `decisions.md` or decision indexes
- `anti-patterns.md`
- `traps.md`
- `runbooks.md`
- `domain-glossary.md`
- `context-budget.md`

The system should stop depending on the currently broken `knowledge_context/` path.

## MCP Model

The MCP posture is:

- central matrix first
- agent override second
- evidence always when MCP influences a decision

MCPs are not left to pure agent discretion for critical work.

Hard stops apply to critical Fabric, security, and Supabase work when:

- KB is stale or internally conflicting
- required MCP validation is unavailable

## KB Model

KBs are governed artifacts, not just helpful notes.

Each domain should ultimately carry:

- owner metadata
- freshness metadata
- source references
- contradiction checks for critical claims
- executable or reviewable examples where practical
- a documented refresh workflow

Microsoft Fabric is the first golden domain and the reference implementation for the KB standard.

## Agent Portfolio Model

The harness will consolidate aggressively.

High-level rule:

- keep the best front door for each domain
- keep a small number of clear specialists
- retire disabled, stale, or overlapping agent surfaces
- move reusable process into skills instead of repeating it in large prompts

## Language Policy

The harness is bilingual at the interaction layer and English-first at the artifact layer.

Rules:

- user interaction may be PT or EN
- operational artifacts and durable docs default to EN
- if a durable artifact mixes languages, the artifact should state the intended language policy explicitly

## Migration Implications

This operating model implies the following future code and policy changes:

1. `workflow:*` routing and docs must stop acting like a parallel control plane.
2. `altitude-plan` must become the real owner of decomposition.
3. execution must refuse work without a full ready task contract.
4. `knowledge_context/` references must be replaced by `.specs/memory`.
5. a central MCP governance matrix must be authoritative.
6. KB governance and Fabric remediation must become first-class workstreams.

## Success Criteria

This operating model is considered adopted when:

- `Altitude` is the undisputed coordinator for durable work
- `workflow:*` acts as compatibility, not a competing runtime
- ambiguous intake consistently uses explore plus interview/grill
- decomposition happens before execution and produces smaller tasks
- critical work has deterministic MCP posture and hard stops
- KB quality is measurable and Fabric operates as the golden domain
