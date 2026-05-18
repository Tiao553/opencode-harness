# AgentSpec Architecture

> Visual reference for the AgentSpec validated development workflow

---

## System Overview

```text
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         AGENTSPEC VALIDATED SDD PIPELINE                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  PHASE 0        PHASE 1        PHASE 2        PHASE 3        PHASE 3.5       PHASE 4        │
│  BRAINSTORM  -> DEFINE   ->    DESIGN   ->    BUILD    ->    VALIDATE  ->    SHIP           │
│  optional        what/why       how            do             gate            close          │
│                                                                                             │
│  ┌──────────┐    ┌────────┐     ┌────────┐     ┌────────┐     ┌──────────┐    ┌────────┐    │
│  │ Raw idea │───▶│ DEFINE │────▶│ DESIGN │────▶│ BUILD  │────▶│ VALIDATE │───▶│  SHIP  │    │
│  └────┬─────┘    └────────┘     └───┬────┘     └───┬────┘     └────┬─────┘    └───┬────┘    │
│       │                             │              │               │              │         │
│       ▼                             ▼              ▼               ▼              ▼         │
│  BRAINSTORM_*                  File manifest   projects/     VALIDATION_*     archive/      │
│                                + decisions     BUILD_REPORT  RUNBOOK or       SHIPPED_*     │
│                                                              ROADMAP                        │
│                                                                                             │
│                                      VALIDATION DECISION                                     │
│                                                                                             │
│                         score >= 90 and zero CRITICAL issues?                               │
│                                  │                         │                                  │
│                                yes                        no                                  │
│                                  │                         │                                  │
│                                  ▼                         ▼                                  │
│                          RUNBOOK generated          ROADMAP or report-only                    │
│                          Ship can proceed           remediation returns to Design/Build       │
│                                                                                             │
│                                      CROSS-PHASE ITERATE                                     │
│                                                                                             │
│              Changes in BRAINSTORM, DEFINE, or DESIGN cascade forward before rebuild.        │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase Flow

```text
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    WORKFLOW FLOW                                         │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   RAW IDEA                                                                               │
│   (vague request,         PHASE 0: BRAINSTORM (Optional)                                │
│    problem)          ────────────────────────▶   BRAINSTORM_{FEATURE}.md                │
│                           One Q at a time        - Discovery Q&A                         │
│                           2-3 Approaches         - Approaches Explored                   │
│                           YAGNI Ruthlessly       - Features Removed                      │
│                                                  - Selected Approach                     │
│                                  │                                                       │
│                                  ▼                                                       │
│   RAW INPUT                                                                              │
│   (notes, emails,         PHASE 1: DEFINE                                               │
│    brainstorm doc)   ────────────────────────▶   DEFINE_{FEATURE}.md                    │
│                           Extract + Validate     - Problem Statement                     │
│                           Clarity Score ≥12      - Target Users                          │
│                                                  - Success Criteria                      │
│                                                  - Acceptance Tests                      │
│                                                  - Out of Scope                          │
│                                  │                                                       │
│                                  ▼                                                       │
│                           PHASE 2: DESIGN                                               │
│   DEFINE_{FEATURE}.md ───────────────────────▶   DESIGN_{FEATURE}.md                    │
│                           Architect + Decide     - Architecture Diagram                  │
│                           No Shared Deps         - Key Decisions (inline)                │
│                                                  - File Manifest                         │
│                                                  - Code Patterns                         │
│                                                  - Testing Strategy                      │
│                                  │                                                       │
│                                  ▼                                                       │
│                           PHASE 3: BUILD                                                │
│   DESIGN_{FEATURE}.md ───────────────────────▶   CODE + BUILD_REPORT                    │
│                           Execute + Verify       - All files from manifest               │
│                           Tests Pass             - Verification results                  │
│                                                  - Issues encountered                    │
│                                  │                                                       │
│                                  ▼                                                       │
│                           PHASE 3.5: VALIDATE                                           │
│   BUILD_REPORT + code ───────────────────────▶   VALIDATION_REPORT                      │
│                           Quality Gate          - Score and critical issues              │
│                                                 - RUNBOOK or ROADMAP                     │
│                                  │                                                       │
│                                  ▼                                                       │
│                           PHASE 4: SHIP                                                 │
│   Approved validation ───────────────────────▶   archive/{FEATURE}/                     │
│                           Archive + Learn        - All artifacts moved                   │
│                                                  - SHIPPED_{DATE}.md                     │
│                                                  - Lessons learned                       │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Folder Structure

```text
.github
+-- skills/                      # 8 folder-invoked command skills
|   +-- workflow-commands/       # SDD workflow commands
|   +-- validate/                # Phase 3.5 quality gate
|   +-- data-engineering-commands/
|   +-- core-commands/
|   +-- visual-explainer/
|   +-- knowledge-commands/
|   +-- review-commands/
|   +-- excalidraw-diagram/
|
+-- agents/                      # 62 specialized agents
|   +-- workflow/                # 7 SDD phase agents
|   +-- architect/               # 8 system-level design
|   +-- cloud/                   # 11 AWS, GCP, CI/CD
|   +-- platform/                # 6 Microsoft Fabric
|   +-- python/                  # 6 code quality, prompts
|   +-- test/                    # 3 testing, contracts
|   +-- data-engineering/        # 15 DE implementation
|   +-- dev/                     # 6 developer productivity
|
+-- kb/                          # 26 curated KB domains
|   +-- dbt/                     # dbt patterns
|   +-- spark/                   # PySpark, Spark SQL
|   +-- sql-patterns/            # SQL best practices
|   +-- airflow/                 # DAG patterns
|   +-- streaming/               # Flink, Kafka, CDC
|   +-- data-modeling/           # Star schema, Data Vault
|   +-- ... (20 more domains)
|
+-- sdd/
    +-- _index.md                # Workflow overview
    +-- README.md                # Comprehensive documentation
    +-- features/                # Active feature documents
    +-- archive/                 # Shipped features
    +-- templates/               # SDD document templates
    +-- architecture/            # Workflow contracts
        +-- WORKFLOW_CONTRACTS.yaml
        +-- ARCHITECTURE.md      # This file
```

---

## Model Assignment

```text
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              STRATEGIC MODEL ASSIGNMENT                                  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   ┌────────────────────────────────────────────────────────────────────────────────┐    │
│   │                                    OPUS                                         │    │
│   │                    (Nuanced Understanding & Creative Thinking)                  │    │
│   │                                                                                 │    │
│   │   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐            │    │
│   │   │   BRAINSTORM    │    │     DEFINE      │    │     DESIGN      │            │    │
│   │   │     AGENT       │    │     AGENT       │    │     AGENT       │            │    │
│   │   │                 │    │                 │    │                 │            │    │
│   │   │ Collaborative   │    │ Requirements    │    │ Architecture    │            │    │
│   │   │ exploration     │    │ extraction      │    │ decisions       │            │    │
│   │   └─────────────────┘    └─────────────────┘    └─────────────────┘            │    │
│   └────────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                          │
│   ┌────────────────────────────────────────────────────────────────────────────────┐    │
│   │                                   SONNET                                        │    │
│   │                           (Fast, Accurate Coding)                               │    │
│   │                                                                                 │    │
│   │   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐            │    │
│   │   │      BUILD      │    │    VALIDATE     │    │     ITERATE     │            │    │
│   │   │      AGENT      │    │      AGENT      │    │      AGENT      │            │    │
│   │   │                 │    │                 │    │                 │            │    │
│   │   │ Code generation │    │ Quality gate    │    │ Change          │            │    │
│   │   │ & verification  │    │ & readiness     │    │ management      │            │    │
│   │   └─────────────────┘    └─────────────────┘    └─────────────────┘            │    │
│   └────────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                          │
│   ┌────────────────────────────────────────────────────────────────────────────────┐    │
│   │                                    HAIKU                                        │    │
│   │                             (Fast, Simple Tasks)                                │    │
│   │                                                                                 │    │
│   │   ┌─────────────────┐                                                          │    │
│   │   │      SHIP       │                                                          │    │
│   │   │      AGENT      │                                                          │    │
│   │   │                 │                                                          │    │
│   │   │ Archive &       │                                                          │    │
│   │   │ document        │                                                          │    │
│   │   └─────────────────┘                                                          │    │
│   └────────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

```text
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    DATA FLOW                                             │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   ╔═══════════════════╗                                                                 │
│   ║    RAW IDEA       ║   (Optional Phase 0)                                            │
│   ║  (Vague request)  ║                                                                 │
│   ╚═════════╤═════════╝                                                                 │
│             │                                                                            │
│             ▼                                                                            │
│   ┌───────────────────┐                                                                 │
│   │ BRAINSTORM_*.md   │─────┐                                                           │
│   │                   │     │                                                           │
│   │ - Discovery Q&A   │     │                                                           │
│   │ - Approaches      │     │ (or skip to DEFINE                                        │
│   │ - YAGNI List      │     │  with raw input)                                          │
│   │ - Selected Path   │     │                                                           │
│   └─────────┬─────────┘     │                                                           │
│             │               │                                                           │
│             ▼               ▼                                                           │
│   ┌───────────────────┐         ┌───────────────────┐                                   │
│   │ DEFINE_*.md       │────────▶│ DESIGN_*.md       │                                   │
│   │                   │         │                   │                                   │
│   │ - Problem         │         │ - Architecture    │                                   │
│   │ - Users           │         │ - Decisions       │                                   │
│   │ - Success         │         │ - File Manifest   │                                   │
│   │ - Tests           │         │ - Patterns        │                                   │
│   │ - Scope           │         │ - Testing         │                                   │
│   └───────────────────┘         └─────────┬─────────┘                                   │
│                                           │                                              │
│             ┌─────────────────────────────┴─────────────────────────────┐               │
│             │                                                           │               │
│             ▼                                                           ▼               │
│   ┌───────────────────┐                                       ┌───────────────────┐    │
│   │ CODE FILES        │                                       │ BUILD_REPORT_*.md │    │
│   │                   │                                       │                   │    │
│   │ (From manifest)   │                                       │ - Tasks completed │    │
│   │                   │                                       │ - Verification    │    │
│   │                   │                                       │ - Issues          │    │
│   └─────────┬─────────┘                                       └─────────┬─────────┘    │
│             │                                                           │               │
│             └─────────────────────────────┬─────────────────────────────┘               │
│                                           │                                              │
│                                           ▼                                              │
│                              ┌───────────────────────┐                                  │
│                              │ VALIDATION_REPORT_*.md│                                  │
│                              │                       │                                  │
│                              │ - Spec alignment      │                                  │
│                              │ - Code quality        │                                  │
│                              │ - Architecture fit    │                                  │
│                              │ - Security & DevOps   │                                  │
│                              │ - Readiness score     │                                  │
│                              └───────────┬───────────┘                                  │
│                                          │                                              │
│                    ┌─────────────────────┴─────────────────────┐                        │
│                    ▼                                           ▼                        │
│          ┌───────────────────┐                       ┌───────────────────┐              │
│          │ RUNBOOK_*.md      │                       │ ROADMAP_*.md      │              │
│          │ score >= 90       │                       │ remediation path  │              │
│          │ 0 critical issues │                       │ if not approved   │              │
│          └─────────┬─────────┘                       └─────────┬─────────┘              │
│                    │                                           │                        │
│                    ▼                                           ▼                        │
│         ╔═══════════════════════╗                  Return to DESIGN/BUILD               │
│         ║  archive/{FEATURE}/   ║                  then rerun VALIDATE                  │
│         ║                       ║                                                         │
│         ║  - BRAINSTORM_*.md    ║                                                         │
│         ║  - DEFINE_*.md        ║                                                         │
│         ║  - DESIGN_*.md        ║                                                         │
│         ║  - BUILD_REPORT_*.md  ║                                                         │
│         ║  - VALIDATION_*.md    ║                                                         │
│         ║  - RUNBOOK_*.md       ║                                                         │
│         ║  - SHIPPED_*.md       ║                                                         │
│         ╚═══════════════════════╝                                                         │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Iteration Flow

```text
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                  ITERATION FLOW                                          │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│                         /workflow:iterate DEFINE_*.md "change"                                   │
│                                      │                                                   │
│                                      ▼                                                   │
│                              ┌──────────────┐                                            │
│                              │ DETECT PHASE │                                            │
│                              └──────┬───────┘                                            │
│                                     │                                                    │
│                    ┌────────────────┴────────────────┐                                   │
│                    ▼                                 ▼                                   │
│            ┌──────────────┐                  ┌──────────────┐                            │
│            │   DEFINE_*   │                  │   DESIGN_*   │                            │
│            │   (Phase 1)  │                  │   (Phase 2)  │                            │
│            └──────┬───────┘                  └──────┬───────┘                            │
│                   │                                 │                                    │
│                   ▼                                 ▼                                    │
│            ┌──────────────┐                  ┌──────────────┐                            │
│            │ APPLY CHANGE │                  │ APPLY CHANGE │                            │
│            │ + VERSION    │                  │ + VERSION    │                            │
│            └──────┬───────┘                  └──────┬───────┘                            │
│                   │                                 │                                    │
│                   ▼                                 ▼                                    │
│            ┌──────────────┐                  ┌──────────────┐                            │
│            │ CASCADE      │                  │ CASCADE      │                            │
│            │ CHECK        │                  │ CHECK        │                            │
│            └──────┬───────┘                  └──────┬───────┘                            │
│                   │                                 │                                    │
│          ┌───────┴────────┐                ┌───────┴────────┐                            │
│          ▼                ▼                ▼                ▼                            │
│   ┌────────────┐   ┌────────────┐   ┌────────────┐   ┌────────────┐                      │
│   │  No Impact │   │ DESIGN     │   │  No Impact │   │   CODE     │                      │
│   │            │   │ may need   │   │            │   │ may need   │                      │
│   │            │   │ update     │   │            │   │ update     │                      │
│   └────────────┘   └────────────┘   └────────────┘   └──────┬─────┘                      │
│                                                            │                             │
│                                                            ▼                             │
│                                                   ┌──────────────────┐                   │
│                                                   │ REBUILD REQUIRED │                   │
│                                                   │ if code changed  │                   │
│                                                   └────────┬─────────┘                   │
│                                                            │                             │
│                                                            ▼                             │
│                                                   ┌──────────────────┐                   │
│                                                   │ RERUN VALIDATE   │                   │
│                                                   │ before Ship      │                   │
│                                                   └────────┬─────────┘                   │
│                                                            │                             │
│                                      ┌─────────────────────┴─────────────────────┐       │
│                                      ▼                                           ▼       │
│                             ┌─────────────────┐                         ┌──────────────┐ │
│                             │ RUNBOOK result  │                         │ ROADMAP      │ │
│                             │ Ship can proceed│                         │ iterate again│ │
│                             └─────────────────┘                         └──────────────┘ │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Quality Gates

```text
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                   QUALITY GATES                                          │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   PHASE 0: BRAINSTORM (Optional)                                                         │
│   ══════════════════════════════                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐                   │
│   │ Exploration Checklist                                            │                   │
│   ├─────────────────────────────────────────────────────────────────┤                   │
│   │ [ ] Minimum 3 discovery questions asked                          │                   │
│   │ [ ] 2-3 approaches explored with trade-offs                      │                   │
│   │ [ ] YAGNI applied (features removed section not empty)           │                   │
│   │ [ ] Minimum 2 incremental validations completed                  │                   │
│   │ [ ] User confirmed selected approach                             │                   │
│   │ [ ] Draft requirements ready for /workflow:define                         │                   │
│   └─────────────────────────────────────────────────────────────────┘                   │
│                                                                                          │
│   PHASE 1: DEFINE                                                                        │
│   ═══════════════                                                                        │
│   ┌─────────────────────────────────────────────────────────────────┐                   │
│   │ Clarity Score Breakdown                         Minimum: 12/15  │                   │
│   ├─────────────────────────────────────────────────────────────────┤                   │
│   │ Problem:  [0-3] Clear, specific, actionable?                    │                   │
│   │ Users:    [0-3] Identified with pain points?                    │                   │
│   │ Goals:    [0-3] Measurable outcomes?                            │                   │
│   │ Success:  [0-3] Testable criteria?                              │                   │
│   │ Scope:    [0-3] Explicit boundaries?                            │                   │
│   └─────────────────────────────────────────────────────────────────┘                   │
│                                                                                          │
│   PHASE 2: DESIGN                                                                        │
│   ═══════════════                                                                        │
│   ┌─────────────────────────────────────────────────────────────────┐                   │
│   │ Checklist                                                        │                   │
│   ├─────────────────────────────────────────────────────────────────┤                   │
│   │ [ ] Architecture diagram present                                 │                   │
│   │ [ ] At least one decision with rationale                         │                   │
│   │ [ ] Complete file manifest                                       │                   │
│   │ [ ] Code patterns are copy-paste ready                           │                   │
│   │ [ ] Testing strategy defined                                     │                   │
│   │ [ ] No shared dependencies across units                          │                   │
│   └─────────────────────────────────────────────────────────────────┘                   │
│                                                                                          │
│   PHASE 3: BUILD                                                                         │
│   ══════════════                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐                   │
│   │ Verification                                                     │                   │
│   ├─────────────────────────────────────────────────────────────────┤                   │
│   │ [ ] All files from manifest created                              │                   │
│   │ [ ] All verification commands pass                               │                   │
│   │ [ ] Lint check passes                                              │                   │
│   │ [ ] Tests pass                                                    │                   │
│   │ [ ] No TODO comments in code                                     │                   │
│   └─────────────────────────────────────────────────────────────────┘                   │
│                                                                                          │
│   PHASE 3.5: VALIDATE                                                                    │
│   ═══════════════════                                                                    │
│   ┌─────────────────────────────────────────────────────────────────┐                   │
│   │ Pre-Ship Quality Gate                                            │                   │
│   ├─────────────────────────────────────────────────────────────────┤                   │
│   │ [ ] DEFINE, DESIGN, BUILD_REPORT all present                     │                   │
│   │ [ ] Code tree exists under {output_path}/              │                   │
│   │ [ ] VALIDATION_REPORT generated                                  │                   │
│   │ [ ] Spec alignment, code quality, architecture, DevOps scored    │                   │
│   │ [ ] Score >= 90 for Ship                                         │                   │
│   │ [ ] Zero CRITICAL issues for Ship                                │                   │
│   │ [ ] RUNBOOK generated when approved                              │                   │
│   │ [ ] ROADMAP generated when remediation is required               │                   │
│   └─────────────────────────────────────────────────────────────────┘                   │
│                                                                                          │
│   PHASE 4: SHIP                                                                          │
│   ═════════════                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐                   │
│   │ Pre-Ship Checklist                                               │                   │
│   ├─────────────────────────────────────────────────────────────────┤                   │
│   │ [ ] BUILD_REPORT shows 100% completion                           │                   │
│   │ [ ] VALIDATION_REPORT score is >= 90                              │                   │
│   │ [ ] VALIDATION_REPORT has zero CRITICAL issues                    │                   │
│   │ [ ] RUNBOOK exists                                               │                   │
│   │ [ ] All tests passing                                            │                   │
│   │ [ ] No blocking issues                                           │                   │
│   │ [ ] Acceptance tests verified                                    │                   │
│   └─────────────────────────────────────────────────────────────────┘                   │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2026-03-26 | Updated folder structure for 62 agents, 8 categories, 26 KB domains |
| 2.0.0 | 2026-03-26 | Data engineering pivot |
| 1.0.0 | 2026-02-17 | Public release as AgentSpec v1.0.0 |
