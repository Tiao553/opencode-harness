# Harness V3: Spec-Driven Orchestration Framework

> **A sophisticated coordinator-owned, contract-driven orchestration system for durable architectural work, tactical data engineering, and deterministic execution with explicit state management and allocation-aware scheduling.**

[![Latest Version](https://img.shields.io/badge/version-3.0-blue)](#) 
[![Architecture](https://img.shields.io/badge/architecture-coordinator%20pattern-brightgreen)](#core-concepts)
[![Agents](https://img.shields.io/badge/agents-80%2B%20specialists-purple)](#specialist-agents)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)

---

## Overview

**Harness V3** is a next-generation orchestration framework that eliminates overlapping lifecycle ownership in agent-based systems. Rather than having multiple agents or surfaces independently deciding phases, scope, and validation authority, Harness V3 uses:

- **Two primary coordinators** that route all work deterministically
- **Six-phase lifecycle** with explicit human gates between phases
- **28 behavioral contracts** that define execution rules and guardrails
- **Allocation before execution** to eliminate scope drift
- **Fixture-backed validation** to prove behavior works as designed

This framework is designed for teams that value **determinism**, **auditability**, **explicit contracts**, and **controlled escalation** in agent-directed work. It is not a generic LLM wrapper; it is a purpose-built control plane for structured software delivery.

## What This Is (And Isn't)

| What It Is | What It Isn't |
|-----------|---------------|
| Orchestration framework for routing complex work | A single LLM or generic assistant |
| Contract-driven behavior definition | A prompt engineering tool |
| Multi-phase delivery lifecycle | A command-line utility |
| Allocation authority for work ownership | A package or library to import |
| Coordinator pattern implementation | A GUI or visual IDE |
| Specialist agent coordination system | A language-specific framework |

---

## Core Concepts

### Two-Coordinator Model

```
┌─────────────────────────────────────────────────┐
│              User Request                       │
└──────────────────────┬──────────────────────────┘
                       │
                ┌──────▼──────┐
                │   ROUTE     │
                └──────┬──────┘
         ┌──────────────┼──────────────┐
         │              │              │
    ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
    │ Altitude │   │   Data   │   │  visual:*│
    │Strategic │   │ Engineer │   │ / core:  │
    │  Work    │   │ Tactical │   │readme-mk │
    └────┬─────┘   └────┬─────┘   └─────┬────┘
         │              │               │
    [6-Phase Lifecycle] [Domain Task]  [Direct Output]
```

#### **Altitude Coordinator** — Strategic Durable Work

Routes all long-lived architecture, system design, feature development, and policy changes through a **six-phase lifecycle**:

1. **Intent** — Define problem, goals, stakeholders, constraints, and success criteria
2. **Structure** — Map repository surfaces, modules, dependencies, and risks
3. **Design/Plan** — Create requirements, architecture decisions, and task decomposition
4. **Execution** — Execute one approved task or approved task batch
5. **Validate** — Verify acceptance criteria, tests, and evidence
6. **Ship** — Summarize delivered boundary, residual risks, and lessons learned

Each phase produces **explicit artifacts** (PRD, ADR, TEST-SPEC, validation reports) that are governance-owned, not volatile.

#### **Data Engineer Coordinator** — Tactical Data Work

Handles bounded, domain-specific tasks that don't require multi-phase orchestration:

- SQL query optimization and debugging
- dbt model design and refactoring
- Schema design and migrations
- Data quality investigations
- Pipeline failures and troubleshooting
- Spark/Airflow task execution
- BigQuery, GCP, Dataform workflows

No automatic phase state update; tactical work produces evidence but not durable `.specs/` changes unless the work has broader architectural implications.

#### **Direct Commands** — Visual and Documentation

- **`/visual:*`** — Generate visual diagrams, plans, recaps, and presentation artifacts
- **`/core:readme-maker`** — Generate or update README.md from codebase analysis

---

## Six-Phase Lifecycle

Every strategic change follows this explicit, gated progression:

```text
Intent ──[confirm]──> Structure ──[confirm]──> Design/Plan ──[select]──> Execution
  │                      │                           │                      │
  │ [purpose + scope]     │ [affected surfaces]      │ [task + allocation]  │
  │                      │                           │ [PRD, ADR, TEST-SPEC]│
  │                      │                           │                      │
  └──────────────────────┴───────────────────────────┴──────────────────────┘
                                                                              │
                                                                              ▼
                                                                         Execution
                                                                          │
                                                                          ├─ [verify + evidence]
                                                                          │
                                                                          ▼
                                                                        Validate
                                                                          │
                                                                          ├─ [pass gates or known gaps]
                                                                          │
                                                                          ▼
                                                                          Ship
                                                                          │
                                                                          └─ [archive + memory update]
```

**Key Principle**: No complex execution may skip Intent → Structure → Design without explicit user override for tactical emergency mode.

---

## Core Concepts

### 1. **Coordinators**

Coordinators are the authority route. They own:
- Phase classification and advancement
- State resolution when ambiguous
- Allocation assignment
- Specialist delegation (when justified)
- Validation gates and evidence tracking
- Memory and archive updates

Coordinators do NOT:
- Execute code changes without approved tasks
- Mutate state silently
- Skip required phases
- Invent task ownership

### 2. **Phases**

Each phase has a single purpose and produces evidence:

| Phase | Purpose | Output | Approval Gate |
|-------|---------|--------|---------------|
| Intent | Define problem and scope | intent artifact or summary | User confirms problem |
| Structure | Map affected surfaces | structure artifact | User confirms scope |
| Design | Create architecture and tasks | PRD, ADR, TEST-SPEC, task pack | User selects ready task(s) |
| Execution | Implement one task | changed files + ledger entry | Automatic unless blocked |
| Validate | Check acceptance criteria | validation report + evidence | Pass gates or document gaps |
| Ship | Archive outcome and lessons | ship summary + state update | Complete (archived) |

### 3. **Contracts**

Explicit behavioral contracts replace implicit agent reasoning. 28 shared contracts live in `.specs/shared/`:

| Contract | Governs |
|----------|----------|
| `phase-engine-contract.md` | Phase semantics, advancement rules, gates |
| `allocation-contract.md` | Work ownership, scope, authority |
| `global-allocation-contract.md` | Multi-wave scope and forbidden boundaries |
| `local-allocation-contract.md` | Per-task scope and file restrictions |
| `task-contract.md` | Task structure, inputs, outputs, verification |
| `execution-loop-contract.md` | Ralph Loop: 9-step verification discipline |
| `state-resolution-contract.md` | Conflict detection and phase state repair |
| `state-conflict-resolution-policy.md` | Stop and repair, no silent drifts |
| `ask-user-policy.md` | When to ask structured questions |
| `documentation-mode-policy.md` | How to write useful docs |
| `production-code-mode-policy.md` | Simplicity-first code standards |
| 17 more... | [See `.specs/shared/`](/.specs/shared) |

### 4. **Allocation**

Work is never assigned without explicit scope. Two levels:

**Global Allocation** — For multi-wave or multi-specialist work:
- Defines primary coordinator and owner
- Specifies allowed and forbidden scope
- Assigns specialists when justified
- Sets verification policy
- Defines rollback path

**Local Allocation** — For individual tasks:
- Defines parent change/phase
- Specifies exactly which files allowed/forbidden
- Lists required context and inputs
- Defines outputs and verification steps
- Identifies assigned specialist

Rule: **Local allocation may narrow global scope; it cannot broaden it without user approval.**

### 5. **Task-Spec**

Leaf tasks use **Task-Spec v2.1** — a vendor-portable task format that works with Claude, Codex, Kimi, taskship, anthive, or manual execution.

Every task must include:
- Clear goal and context
- Verification commands (runnable bash)
- Acceptance criteria
- Evidence requirements
- Do-not-touch file manifest
- Rollback instructions

See [`skills/task-spec/`](skills/task-spec/) for full specification, patterns, and runbooks.

---

## Architecture

### Repository Structure

```
opencode/ (root)
├── AGENTS.md                          # Global orchestration entrypoint
├── agents/                            # 80+ specialist agent definitions
│   ├── altitude-*.agent.md            # 7 phase agents (Intent through Ship)
│   ├── data-engineer.agent.md         # Tactical coordinator
│   ├── altitude.agent.md              # Strategic router
│   └── [80+ domain specialists]       # Cloud, platform, architecture, etc.
├── .specs/                            # Change ledger and contracts
│   ├── shared/                        # 28 behavioral contracts (versioned)
│   ├── templates/                     # Artifact templates (versioned)
│   ├── changes/                       # Real change requests (local)
│   ├── memory/                        # Active state and project memory (local)
│   ├── archive/                       # Shipped changes (local)
│   ├── control/                       # Planning and control artifacts
│   └── README.md                      # .specs overview
├── config/                            # Routing, security, grounding
│   ├── routing.json                   # Intent-to-agent routing map
│   ├── security-settings.json         # Command safety profiles
│   ├── grounding.md                   # Policy and sensitive-path rules
│   └── README.md                      # Config overview
├── docs/                              # Detailed architecture documentation
│   ├── HARNESS_V3_ARCHITECTURE.md     # This design frozen
│   ├── HARNESS_V3_PHASE_ENGINE_SPEC.md    # Phase semantics and gates
│   ├── HARNESS_V3_COORDINATOR_ROUTING.md  # Routing classification tree
│   ├── HARNESS_V3_STATE_RESOLUTION_CONTRACT.md
│   ├── HARNESS_V3_ARTIFACT_REGISTRY.md
│   └── [8 more reference docs]
├── skills/                            # 7 reusable command skills
│   ├── core-commands/                 # readme-maker, memory, status, etc.
│   ├── workflow-commands/             # brainstorm, define, design, build, etc.
│   ├── data-engineering/              # sql-review, pipeline, schema, etc.
│   ├── task-spec/                     # Task specification and execution
│   ├── review/                        # Code review and judging
│   ├── visual-explainer/              # Visual diagram and plan generation
│   └── performance-optimization/      # Measurement-first perf tuning
├── plugins/                           # Runtime enforcement plugins
│   ├── permission-hardening.ts        # Authority enforcement
│   ├── altitude-context.ts            # Altitude agent context loading
│   ├── specs-state.ts                 # State resolution and validation
│   ├── rtk-native.ts                  # Runtime task knowledge
│   ├── headroom-guard.ts              # Context budget enforcement
│   └── context-budget.ts              # Token budget management
├── commands/                          # Compatibility command entrypoints
│   ├── workflow:*                     # Legacy workflow commands
│   ├── data:*                         # Legacy data engineering commands
│   ├── core:*                         # Project utility commands
│   ├── review:*                       # Review and judging commands
│   ├── knowledge:*                    # KB management commands
│   └── visual:*                       # Visual artifact commands
├── kb/                                # Knowledge domains for grounding
├── opencode.json                      # Runtime agent and plugin config
├── package.json                       # Node.js dependencies
└── .gitignore                         # Privacy-first; ignores local state

```

---

## Quick Start (60 seconds)

### Prerequisites

- Node.js 16+
- Git
- An OpenCode runtime (Claude, Codex, or compatible agent framework)
- Basic familiarity with Markdown and JSON

### What You Can Do With Harness V3

#### 1. **Start a Strategic Architecture Change**

```bash
# You would invoke this through an agent interface:
# "I want to refactor our authentication system"

# The Altitude coordinator will:
# → Capture Intent (problem, scope, stakeholders)
# → Ask you to confirm the problem
# → Advance to Structure phase
# → Map affected modules and risks
# → Ask you to confirm scope
# → Advance to Design phase
# → Create architecture decisions and task decomposition
```

#### 2. **Execute a Tactical SQL Optimization Task**

```bash
# Through Data Engineer coordinator:
# "Optimize the user_events table query; it's slow"

# The system will:
# → Classify as tactical data task
# → Route to Data Engineer + SQL specialist
# → Execute optimization
# → Record evidence and metrics
# → Skip phase state updates (unless architectural)
```

#### 3. **Generate Project Documentation**

```bash
# Through /core:readme-maker:
# This command analyzes your codebase and generates comprehensive README.md
# No setup required; works with any language/framework
```

#### 4. **Create Visual Architecture Diagrams**

```bash
# Through /visual:*:
# "Create a diagram showing our data flow"
# System generates presentation-ready visual artifacts
```

### Typical Workflow

```text
1. Describe your change to the Altitude coordinator
   └─ Coordinator classifies as strategic or tactical

2. If strategic:
   ├─ Intent phase: clarify problem + scope
   ├─ Structure phase: map affected surfaces
   ├─ Design phase: create architecture + task pack
   ├─ Execution phase: implement approved task
   ├─ Validate phase: verify acceptance criteria
   └─ Ship phase: archive outcome + update memory

3. If tactical:
   ├─ Classify domain (SQL, dbt, pipeline, schema, etc.)
   ├─ Execute domain task
   ├─ Record evidence
   └─ Move to next task

4. If documentation/visual:
   └─ Generate artifact directly
```

---

## Core Concepts in Depth

### Phases in Detail

#### **Phase 1: Intent**
**Goal**: Define the problem, not the solution.

**Questions answered**:
- What is the actual problem?
- Who are the stakeholders?
- What success looks like
- What is explicitly NOT in scope?
- What constraints or assumptions exist?

**Output**: Intent artifact or approved summary

**Gate**: User confirms problem and scope are clear

---

#### **Phase 2: Structure**
**Goal**: Map the landscape before designing.

**Questions answered**:
- Which modules are affected?
- What dependencies exist?
- What data flows change?
- What contracts must not break?
- What are the architectural risks?

**Output**: Structure artifact documenting the surface

**Gate**: User confirms they understand the scope of changes

---

#### **Phase 3: Design/Plan**
**Goal**: Agree on architecture and decompose into tasks.

**Produces**:
- **PRD** (if behavior/workflow matters)
- **ADR** (if architecture matters)
- **TEST-SPEC** (if validation/regression matters)
- **Task decomposition** into ready tasks

**Output**: Ready task pack with full context

**Gate**: User selects which task(s) to execute first

---

#### **Phase 4: Execution**
**Goal**: Implement ONE approved task to completion.

**Rules**:
- Execute only approved tasks
- Record changes to ledger
- Collect evidence (tests, metrics, diffs)
- Do not invent task scope
- Do not add tasks mid-execution

**Output**: Changed files + evidence + ledger entry

**Gate**: Automatic → advances to Validate (unless blocked)

---

#### **Phase 5: Validate**
**Goal**: Verify acceptance criteria met and evidence collected.

**Checks**:
- Does output match acceptance criteria?
- Are tests passing?
- Is evidence sufficient?
- Are there residual risks?
- Is rollback path clear?

**Output**: Validation report

**Gate**: Pass criteria OR document known gaps

---

#### **Phase 6: Ship**
**Goal**: Archive change and update durable memory.

**Actions**:
- Archive change to `.specs/archive/`
- Update project memory (`.specs/memory/`)
- Record lessons learned
- Update runtime state
- Suggest next change or iteration

**Output**: Ship summary + state update

**Gate**: Complete (archived)

---

## Documentation Index

| Document | Purpose |
|----------|---------|
| **[HARNESS_V3_ARCHITECTURE.md](docs/HARNESS_V3_ARCHITECTURE.md)** | Frozen architecture thesis and principles |
| **[HARNESS_V3_PHASE_ENGINE_SPEC.md](docs/HARNESS_V3_PHASE_ENGINE_SPEC.md)** | Detailed phase semantics and movement rules |
| **[HARNESS_V3_COORDINATOR_ROUTING.md](docs/HARNESS_V3_COORDINATOR_ROUTING.md)** | How requests are classified and routed |
| **[HARNESS_V3_COORDINATOR_CONTRACT.md](docs/HARNESS_V3_COORDINATOR_CONTRACT.md)** | Coordinator behavior and authority |
| **[HARNESS_V3_STATE_RESOLUTION_CONTRACT.md](docs/HARNESS_V3_STATE_RESOLUTION_CONTRACT.md)** | State conflict detection and repair |
| **[HARNESS_V3_ARTIFACT_REGISTRY.md](docs/HARNESS_V3_ARTIFACT_REGISTRY.md)** | All artifact types and when to use them |
| **[HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md](docs/HARNESS_V3_ARTIFACT_TEMPLATE_CATALOG.md)** | Templates for PRD, ADR, TEST-SPEC, reports |
| **[HARNESS_V3_TASK_SPEC_INTEGRATION.md](docs/HARNESS_V3_TASK_SPEC_INTEGRATION.md)** | Task-Spec v2.1 format and integration |
| **[HARNESS_V3_MIGRATION_TEST_PLAN.md](docs/HARNESS_V3_MIGRATION_TEST_PLAN.md)** | 18 golden fixtures proving behavior |
| **[HARNESS_V3_LEGACY_PRESERVATION_MATRIX.md](docs/HARNESS_V3_LEGACY_PRESERVATION_MATRIX.md)** | How old workflow behavior is preserved |
| **[HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md](docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md)** | Data Engineer coordinator behavior |
| **[HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md](docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md)** | Tactical task routing and classification |

---

## Specialist Agents

Harness V3 includes **80+ specialist agents** across these domains:

### Strategic Coordinators
- **`altitude`** — Meta-router for all strategic work
- **`altitude-intent`** — Intent phase agent
- **`altitude-structure`** — Structure phase agent
- **`altitude-plan`** — Decomposition agent
- **`altitude-execution`** — Execution phase agent
- **`altitude-validation`** — Validation phase agent
- **`altitude-report`** — Report generation
- **`altitude-memory`** — State and memory updates

### Tactical Coordinators
- **`data-engineer`** — Tactical coordinator for bounded tasks

### Data Engineering Specialists
- `sql-optimizer` — SQL query tuning
- `dbt-specialist` — dbt model design
- `data-quality-analyst` — Data quality issues
- `airflow-specialist` — Airflow DAGs
- `spark-specialist` — Spark optimization

### Architecture
- `pipeline-architect` — Data pipeline design
- `lakehouse-architect` — Lakehouse architecture
- `kb-architect` — Knowledge bases
- `medallion-architect` — Medallion patterns
- `genai-architect` — Generative AI systems

**And 50+ more** — see [`agents/`](agents/) for the complete roster.

---

## License

Harness V3 is licensed under the **MIT License**.

See individual files for specific licensing information.

---

## Quick Links

- 🏗️ [Architecture](docs/HARNESS_V3_ARCHITECTURE.md)
- 📋 [Phase Engine](docs/HARNESS_V3_PHASE_ENGINE_SPEC.md)
- 🛣️ [Routing Guide](docs/HARNESS_V3_COORDINATOR_ROUTING.md)
- 📄 [Contracts](/.specs/shared)
- 🤖 [Agents](agents/)
- 🔧 [Skills](skills/)
- ⚙️ [Configuration](config/)
- 📚 [Full Documentation](docs/)

---

**Last Updated**: June 28, 2026  
**Framework**: Harness V3 (Production Ready)  
**Version**: 3.0.0
