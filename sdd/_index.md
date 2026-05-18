# AgentSpec

> validated development workflow with Agent Matching and Delegation, specialized for Data Engineering.
> *"Brainstorm -> Define -> Design -> Build -> Validate -> Ship"*

---

## Overview

AgentSpec provides Agent Matching (Design phase) and Agent Delegation (Build phase):

| Traditional Approach | AgentSpec |
|---------------|--------------|
| 8 phases | **validated phases** (Brainstorm optional) |
| 3 development modes | **1 unified stream** |
| Generic agents only | **62 specialized agents** across 8 categories |
| No domain expertise | **26 KB domains** for data engineering |
| 12+ commands | **folder-invoked command skills** |
| 11+ artifact types | **validated SDD artifacts** |
| Separate ADR files | **Inline decisions** |
| Pre-generated tasks | **On-the-fly execution** |

---

## The Validated Pipeline

```mermaid
flowchart LR
    A["Brainstorm"] --> B["Define"]
    B --> C["Design"]
    C --> D["Build"]
    D --> E["Validate"]
    E --> F{"score >= 90<br/>0 critical"}
    F -->|yes| G["Ship"]
    F -->|no| H["Remediate"]
    H --> C
```

---

## Commands

### SDD Workflow (7)

| Command | Phase | Purpose | Model |
|---------|-------|---------|-------|
| `/workflow:brainstorm` | 0 | Explore ideas through collaborative dialogue | Opus |
| `/workflow:define` | 1 | Capture and validate requirements | Opus |
| `/workflow:design` | 2 | Create architecture and specification | Opus |
| `/workflow:build` | 3 | Execute implementation with verification | Sonnet |
| `/workflow:validate` | 3.5 | Validate implementation before Ship | Sonnet |
| `/workflow:ship` | 4 | Archive with lessons learned | Haiku |
| `/workflow:iterate` | Any | Update documents when changes needed | Sonnet |
| `/workflow:create-pr` | -- | Create pull request | -- |

### Data Engineering (8)

| Command | Purpose |
|---------|---------|
| `/data:pipeline` | DAG/data:pipeline scaffolding |
| `/data:schema` | Interactive schema design |
| `/data:data-quality` | Quality rules generation |
| `/data:lakehouse` | Table format + catalog guidance |
| `/data:sql-review` | SQL-specific code review |
| `/data:ai-pipeline` | RAG/embedding scaffolding |
| `/data:data-contract` | Contract authoring (ODCS) |
| `/data:migrate` | Legacy ETL migration |

### Core & Utilities (6)

| Command | Purpose |
|---------|---------|
| `/knowledge:create-kb` | Create KB domain |
| `/review:review` | Code review |
| `/core:meeting` | Meeting transcript analysis |
| `/core:memory` | Save session insights |
| `/core:sync-context` | Update CLAUDE.md |
| `/core:readme-maker` | Generate README |

---

## Artifacts

| Artifact | Phase | Location |
|----------|-------|----------|
| `BRAINSTORM_{FEATURE}.md` | 0 | `~/.config/opencode/sdd/features/` |
| `DEFINE_{FEATURE}.md` | 1 | `~/.config/opencode/sdd/features/` |
| `DESIGN_{FEATURE}.md` | 2 | `~/.config/opencode/sdd/features/` |
| `BUILD_REPORT_{FEATURE}.md` | 3 | `~/.config/opencode/sdd/features/{feature-name}/` |
| `VALIDATION_REPORT_{FEATURE}.md` | 3.5 | `~/.config/opencode/sdd/features/{feature-name}/` |
| `RUNBOOK_{FEATURE}.md` | 3.5 | `~/.config/opencode/sdd/features/{feature-name}/` |
| `ROADMAP_{FEATURE}.md` | 3.5 | `~/.config/opencode/sdd/features/{feature-name}/` |
| `SHIPPED_{DATE}.md` | 4 | `~/.config/opencode/sdd/archive/{feature-name}/` |

---

## Quick Start

### Data Engineering Feature (Full Pipeline)

```bash
# Phase 0: Explore the idea (optional)
/workflow:brainstorm "Build an incremental orders pipeline with SCD Type 2"

# Phase 1: Define requirements (from brainstorm output)
/workflow:define ~/.config/opencode/sdd/features/orders-pipeline/BRAINSTORM_ORDERS_PIPELINE.md

# Phase 2: Create technical design
/workflow:design ~/.config/opencode/sdd/features/orders-pipeline/DEFINE_ORDERS_PIPELINE.md

# Phase 3: Build the code
/workflow:build ~/.config/opencode/sdd/features/orders-pipeline/DESIGN_ORDERS_PIPELINE.md

# Phase 3.5: Validate before ship
/workflow:validate ~/.config/opencode/sdd/features/orders-pipeline/BUILD_REPORT_ORDERS_PIPELINE.md

# Phase 4: Archive when validation is approved
/workflow:ship ~/.config/opencode/sdd/features/orders-pipeline/DEFINE_ORDERS_PIPELINE.md
```

### DE-Specific Commands (Skip SDD)

```bash
# Design a star schema
/data:schema "Star schema for e-commerce analytics"

# Scaffold a pipeline
/data:pipeline "Daily orders ETL from Postgres to Snowflake"

# Generate quality checks
/data:data-quality models/staging/stg_orders.sql
```

### Making Changes Mid-Stream

```bash
# Update DEFINE with new requirement
/workflow:iterate DEFINE_ORDERS_PIPELINE.md "Add support for late-arriving facts"

# Update DESIGN with architecture change
/workflow:iterate DESIGN_ORDERS_PIPELINE.md "Switch to incremental strategy"
```

---

## Folder Structure

```text
~/.config/opencode/sdd/
+-- _index.md                    # This file (workflow overview)
+-- README.md                    # Comprehensive documentation
+-- features/                    # Active feature documents
|   +-- {feature-name}/
|       +-- BRAINSTORM_{FEATURE}.md
|       +-- DEFINE_{FEATURE}.md
|       +-- DESIGN_{FEATURE}.md
|       +-- BUILD_REPORT_{FEATURE}.md
|       +-- VALIDATION_REPORT_{FEATURE}.md
|       +-- RUNBOOK_{FEATURE}.md         (if score >= 90)
|       +-- ROADMAP_{FEATURE}.md         (if score 70-89)
|       +-- _validate/                   # Intermediate junta outputs
|           +-- 01_SPEC_REPORT_{FEATURE}.json
|           +-- 02_CODE_REPORT_{FEATURE}.json
|           +-- 03_DELIVERY_DELTA_{FEATURE}.json
|           +-- 04_COUNCIL_VERDICT_{FEATURE}.json
|           +-- 05_SCORING_{FEATURE}.json
+-- archive/                     # Shipped features
|   +-- {feature-name}/
|       +-- BRAINSTORM_{FEATURE}.md  (if used)
|       +-- DEFINE_{FEATURE}.md
|       +-- DESIGN_{FEATURE}.md
|       +-- BUILD_REPORT_{FEATURE}.md
|       +-- VALIDATION_REPORT_{FEATURE}.md
|       +-- RUNBOOK_{FEATURE}.md
|       +-- SHIPPED_{DATE}.md
+-- templates/                   # Document templates
|   +-- BRAINSTORM_TEMPLATE.md
|   +-- DEFINE_TEMPLATE.md
|   +-- DESIGN_TEMPLATE.md
|   +-- BUILD_REPORT_TEMPLATE.md
|   +-- VALIDATION_REPORT_TEMPLATE.md
|   +-- RUNBOOK_TEMPLATE.md
|   +-- ROADMAP_TEMPLATE.md
|   +-- SHIPPED_TEMPLATE.md
+-- architecture/                # Workflow contracts
    +-- WORKFLOW_CONTRACTS.yaml
    +-- VALIDATE_JUNTAS_CONTRACT.yaml
    +-- ARCHITECTURE.md
```

---

## Phase Details

### Phase 0: Brainstorm (Optional)

**Purpose:** Explore ideas through collaborative dialogue before capturing requirements.

**When to Use:**
- Vague idea that needs exploration
- Multiple possible approaches to consider
- Uncertain about scope or users
- Need to apply YAGNI before diving in

**When to Skip:**
- Clear requirements already known
- Meeting notes with explicit asks
- Simple feature request

**Input:** Raw idea, problem statement, or vague request.

**Output:** `BRAINSTORM_{FEATURE}.md` with:
- Discovery questions and answers
- 2-3 approaches explored with trade-offs
- Selected approach with reasoning
- Features removed (YAGNI applied)
- Draft requirements for /workflow:define

**Quality Gate:** Min 3 questions, 2+ approaches, 2+ validations, user confirmed

### Phase 1: Define

**Purpose:** Capture and validate requirements from any input.

**Input:** BRAINSTORM document, raw notes, emails, conversations, or direct requirements.

**Output:** `DEFINE_{FEATURE}.md` with:
- Problem statement
- Target users
- Success criteria (measurable)
- Acceptance tests (Given/When/Then)
- Technical Context (deployment location, KB domains, data lineage)
- Out of scope

**Quality Gate:** Clarity Score >= 12/15

### Phase 2: Design

**Purpose:** Create complete technical design with inline decisions.

**Input:** `DEFINE_{FEATURE}.md`

**Output:** `DESIGN_{FEATURE}.md` with:
- Architecture diagram (ASCII)
- Key decisions with rationale
- File manifest with agent assignments
- Code patterns (copy-paste ready)
- Testing strategy

**Quality Gate:** Complete file manifest, all files have agents, no shared dependencies

### Phase 3: Build

**Purpose:** Execute implementation following the design with agent delegation.

**Input:** `DESIGN_{FEATURE}.md`

**Output:**
- Code files (as specified in manifest)
- `BUILD_REPORT_{FEATURE}.md` with agent attribution

**Quality Gate:** All tasks complete, all tests pass

### Phase 4: Ship

**Purpose:** Archive completed feature with lessons learned.

**Input:** All feature artifacts

**Output:**
- `archive/{FEATURE}/` folder with all documents
- `SHIPPED_{DATE}.md` with lessons learned

---

## Key Principles

| Principle | Application |
|-----------|-------------|
| **Single Stream** | No mode switching, one unified workflow |
| **Inline Decisions** | ADRs in DESIGN document, not separate files |
| **On-the-Fly Tasks** | Tasks generated from file manifest during build |
| **Self-Contained** | Each deployable unit works independently |
| **Config Over Code** | Use YAML for configuration, not hardcoded values |
| **Iterate Anywhere** | Changes can be made at any phase via `/workflow:iterate` |
| **Data Engineering First** | Pipelines, schemas, and quality are built-in concerns |

---

## Model Assignment

| Phase | Model | Rationale |
|-------|-------|-----------|
| Brainstorm | Opus | Creative thinking and nuanced dialogue |
| Define | Opus | Nuanced understanding of requirements |
| Design | Opus | Architectural decisions require depth |
| Build | Sonnet | Fast, accurate code generation |
| Validate | Sonnet | 4 juntas via task tool, deterministic scoring |
| Ship | Haiku | Simple archival operations |
| Iterate | Sonnet | Balanced speed and understanding |

---

## References

| Resource | Location |
|----------|----------|
| SDD Commands | `~/.config/opencode/skills/workflow-commands/commands/` |
| DE Commands | `~/.config/opencode/skills/data-engineering/commands/` |
| Core Commands | `~/.config/opencode/skills/core-commands/commands/` |
| Agents (62 + DEFAULT) | `~/.config/opencode/agents/` |
| KB Domains (26) | `~/.config/opencode/kb/` |
| Templates | `~/.config/opencode/sdd/templates/` |
| Workflow Contract | `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| Validate Juntas Contract | `~/.config/opencode/sdd/architecture/VALIDATE_JUNTAS_CONTRACT.yaml` |
| Junta Prompts | `~/.config/opencode/skills/workflow-commands/references/` |
| Template Renderer | `~/.config/opencode/skills/workflow-commands/scripts/render.py` |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2026-03-26 | Multi-cloud coverage: 62 agents, 8 categories, 26 KB domains |
| 2.0.0 | 2026-03-26 | Data engineering pivot: 11 KB domains, 11 DE agents, 8 DE commands |
| 1.0.0 | 2026-02-17 | Public release as AgentSpec v1.0.0 |
