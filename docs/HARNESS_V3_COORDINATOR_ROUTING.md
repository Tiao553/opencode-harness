# Harness V3 Coordinator Routing

## Purpose

Define how the `Altitude` strategic coordinator classifies incoming requests and routes them to the appropriate phase handler or escalates to tactical coordinators.

---

## Classification Decision Tree

### Entry Point: `altitude` Coordinator

When a user invokes strategic work, the `altitude` meta-route classifies the request.

```text
User Request
    ↓
[Altitude Classification]
    ├─ Is this a new durable strategic change?
    │  └─ YES → Intent phase (create/clarify problem)
    │
    ├─ Is there an active .specs change?
    │  └─ YES → Resolve state
    │     ├─ Next phase is Structure?  → Structure
    │     ├─ Next phase is Design?     → Design/Plan
    │     ├─ Next phase is Execution?  → Execution
    │     ├─ Next phase is Validate?   → Validation
    │     ├─ Next phase is Ship?       → Report/Memory
    │     └─ State conflict?           → Conflict detection
    │
    ├─ Is this bounded tactical work?
    │  └─ YES → Recommend Data Engineer coordinator
    │
    ├─ Is this a visual artifact request?
    │  └─ YES → Recommend visual:*
    │
    ├─ Is this README generation/update?
    │  └─ YES → Recommend core:readme-maker
    │
    └─ Unknown or ambiguous?
       └─ Ask one focused question or state conflict gate
```

---

## Classification Rules

### Rule 1: New Durable Strategic Work

**Signal**: User describes a new architecture, system design, multi-step feature, or durable policy change.

**Examples**:
- "I need to refactor the harness architecture"
- "Design a new data pipeline for our lakehouse"
- "Plan a multi-wave migration strategy"
- "Create a new system for user onboarding"

**Action**: Route to `altitude-intent`

**Altitude Intent Behavior**:
- Create or update `.specs/changes/{change-id}/00-intent.md`
- Clarify problem, goal, stakeholders, constraints, assumptions
- Ask for confirmation before moving to Structure
- Block execution until Intent is approved

---

### Rule 2: Existing `.specs` Change

**Signal**: User references an existing change ID or the system detects an active change from `.specs/memory/active-state.md`.

**Examples**:
- "Resume the harness-refactor change"
- "What's the next step?" (when active state exists)
- "Execute task pack-002 for the migration"

**Action**: Resolve phase from change state

**State Resolution**:
1. Load `.specs/memory/active-state.md` → find active change
2. Load `.specs/changes/{change-id}/state.md` → find current phase
3. Compare phase with user instruction
4. If conflict detected → Stop (see Rule 7: State Conflict)
5. If aligned → Route to phase-appropriate agent:
   - Phase = Intent    → `altitude-intent`
   - Phase = Structure → `altitude-structure`
   - Phase = Design    → `altitude-plan`
   - Phase = Execution → `altitude-execution`
   - Phase = Validate  → `altitude-validation`
   - Phase = Ship      → `altitude-report` or `altitude-memory`

---

### Rule 3: Bounded Tactical Data Work

**Signal**: User describes SQL fix, dbt model issue, schema design, data quality investigation, pipeline debugging, migration, Fabric/GCP work, Spark/Airflow task.

**Examples**:
- "Optimize this slow SQL query"
- "Create a dbt incremental model"
- "Debug the Airflow DAG failure"
- "Design a star schema for sales"

**Action**: Recommend Data Engineer coordinator

**Recommendation Message**:
```
This is bounded tactical data-engineering work.
Use the Data Engineer coordinator for focused implementation.

Route: data-engineer (or specific specialist)
Escalation: If this becomes multi-wave, strategic, or affects harness architecture,
            escalate to Altitude by prefixing "strategic: " or creating a .specs change.
```

**Note**: Tactical work does not automatically create a `.specs` change. Escalate when:
- Work spans multiple waves or iterations
- Work affects harness architecture or governance
- Work requires PRD/ADR/TEST-SPEC durable record
- Work impacts multiple data domains or systems

---

### Rule 4: Visual Artifact Request

**Signal**: User requests final diagram, architecture visualization, dashboard mockup, presentation slide.

**Examples**:
- "Create an architecture diagram for this system"
- "Design a dashboard layout with these metrics"
- "Visualize the data flow pipeline"

**Action**: Recommend `visual:*` command

**Visual Coordinator Scope**:
- Creates visual artifacts for presentation, documentation, planning
- Does not own lifecycle state or .specs mutations
- Does not own implementation sequencing

---

### Rule 5: README Generation/Update

**Signal**: User requests README creation, update, or generation from project structure.

**Examples**:
- "Generate a README for this project"
- "Update the README with the new features"
- "Create API documentation"

**Action**: Recommend `core:readme-maker` command

**README Coordinator Scope**:
- Generates documentation artifacts
- Does not own lifecycle state or .specs mutations
- Does not own implementation sequencing

---

### Rule 6: Escalation from Tactical to Strategic

**Signal**: User indicates bounded work has become strategic, multi-wave, or needs durable planning.

**Examples**:
- "This SQL optimization should be part of a bigger data platform refactor"
- "These Spark tuning changes need an architecture decision document"
- "We should make this a durable change with PRD and test strategy"

**Action**: Create `.specs` change and route to `altitude-intent`

**Escalation Process**:
1. Ask user: "Should this be a durable `.specs` change? Or is it still bounded tactical work?"
2. If YES → Route to `altitude-intent` to start Intent phase
3. If NO → Continue with Data Engineer coordinator

---

### Rule 7: State Conflict

**Signal**: Active state exists, but user instruction conflicts with it.

**Examples**:
- Active change is in Design phase, but user says "Go back to Intent"
- Task is marked `completed`, but user says "Re-execute task"
- Two changes are active simultaneously in system memory

**Action**: Stop and apply state conflict resolution

**Conflict Resolution Process**:
1. Report conflict: "Current state says [X], but you asked for [Y]"
2. Present options:
   - A) Trust active state — continue from state's phase
   - B) Trust user instruction — validate new instruction against state
   - C) Reset to earlier phase — requires user confirmation
   - D) Create repair task — document conflict for later resolution
3. Wait for user choice

**Conflict Detection**:
- Load `.specs/shared/state-conflict-resolution-policy.md`
- Apply precedence: User instruction > Active state > Inference
- Stop before executing unless user explicitly resolves conflict

---

### Rule 8: Ambiguous Request

**Signal**: Request does not clearly map to one path; multiple interpretations are possible.

**Examples**:
- "Fix the system" (could be tactical fix or strategic refactor)
- "Data pipeline" (could be SQL, Airflow, schema, or full pipeline design)
- "Architecture work" (could be system design, infrastructure, or data platform)

**Action**: Ask one focused question

**Question Format**:
```
This request could be either:

A. Option 1 — Explanation with trade-off
B. Option 2 — Explanation with trade-off
C. Option 3 — Explanation with trade-off

Which best matches your intent?
```

**Do not guess**. Stop and ask.

---

## Phase Subagent Routing

Once Altitude has classified the request to an existing `.specs` change, it routes to the phase subagent:

| Phase | Subagent | Owns |
|-------|----------|------|
| Intent | `altitude-intent` | Problem clarification, PRD/ADR drafts, stakeholder confirmation |
| Structure | `altitude-structure` | Repository surface mapping, module identification, risk analysis, impact scope |
| Design/Plan | `altitude-plan` | Requirements, architecture, task packs, allocation, validation strategy, gates |
| Execution | `altitude-execution` | Execute one approved task or task batch; produce evidence; report blockers |
| Validation | `altitude-validation` | Verify evidence, tests, acceptance criteria, regressions, scope compliance |
| Report | `altitude-report` | Executive summary, decision log, evidence archive, lessons learned, next action |
| Memory | `altitude-memory` | Update `.specs/memory/`, archive completed changes, update operational state |

---

## Coordinator Routing Map

### Strategic Durable Work → Altitude

```text
Altitude
├─ altitude-intent        [Intent phase]
├─ altitude-structure     [Structure phase]
├─ altitude-plan          [Design/Plan phase]
├─ altitude-execution     [Execution phase]
├─ altitude-validation    [Validation phase]
├─ altitude-report        [Report/Ship phase]
└─ altitude-memory        [Memory/Archive phase]
```

### Tactical Data Work → Data Engineer

```text
Data Engineer
├─ sql-optimizer          [SQL review, query tuning]
├─ dbt-specialist         [dbt models, macros, tests]
├─ data-quality-analyst   [quality checks, contracts, SodaSQL]
├─ schema-designer        [DDL, dimensional models, SCD]
├─ airflow-specialist     [DAG, orchestration, sensors]
├─ spark-specialist       [Spark optimization, PySpark]
├─ streaming-engineer     [Kafka, Flink, CDC, Debezium]
├─ lakeflow-specialist    [Databricks DLT, Unity Catalog]
├─ fabric-architect       [Microsoft Fabric, lakehouse]
└─ [+ others]
```

---

## Integration with AGENTS.md

- **AGENTS.md § 1**: Harness V3 Operating Model — two visible coordinators
- **AGENTS.md § 6**: Primary Coordinators — Altitude + Data Engineer
- **AGENTS.md § 7**: Request Classification — 7 routing rules (matches this doc)
- **AGENTS.md § 19**: Execution Rules — conditions before execution
- **AGENTS.md § 22**: Activation Gates — confidence gate, stop conditions

## Integration with Tactical Routing Documentation

- **docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md**: Defines tactical scope, escalation triggers, and Ralph Loop applied to data tasks
- **docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md**: Defines 9 internal data-engineer routes (sql-review, dbt, schema, data-quality, pipeline, etc.) and old `/data:*` command mapping

---

## Configuration

### config/routing.json

```json
{
  "id": "altitude",
  "triggers": [
    "altitude",
    "durable change",
    "new architecture",
    "strategic work",
    "criar change",
    ".specs",
    "change request",
    "strategic",
    "novo projeto",
    "harness work",
    "refactor"
  ],
  "agent": "~/.config/opencode/agents/altitude.agent.md",
  "description": "Altitude strategic coordinator: classifies durable work and routes to appropriate phase",
  "category": "altitude",
  "priority": 100
},
{
  "id": "data-engineer",
  "triggers": [
    "data-engineer",
    "data engineering",
    "sql",
    "dbt",
    "pipeline",
    "schema",
    "data quality",
    "airflow",
    "spark",
    "streaming",
    "lakehouse"
  ],
  "agent": "~/.config/opencode/agents/data-engineer.agent.md",
  "description": "Data Engineer tactical coordinator: classifies bounded data work and routes to specialist",
  "category": "data-engineering",
  "priority": 95
}
```

### config/opencode.json

```json
{
  "agent": {
    "altitude": {
      "mode": "primary",
      "description": "Harness V3 strategic coordinator for durable .specs work.",
      "max_steps": 32,
      "permission": { ... }
    },
    "altitude-intent": {
      "mode": "subagent",
      "hidden": true,
      ...
    },
    ...
  }
}
```

---

## Validation Checklist

After implementing Wave 2:

- [ ] `config/routing.json` has "altitude" route with `priority: 100`
- [ ] "altitude" route is first in routes array (or highest priority)
- [ ] Triggers include: "altitude", "durable change", "strategic work", ".specs"
- [ ] `opencode.json` shows `altitude: mode = "primary"`
- [ ] All phase subagents have `hidden: true` (not primary entrypoints)
- [ ] `docs/HARNESS_V3_COORDINATOR_ROUTING.md` exists with classification logic
- [ ] `AGENTS.md` § 34 references this routing doc
- [ ] `test/fixtures/harness-v3/fixture-01-strategic-new-change.md` still passes
- [ ] `test/fixtures/harness-v3/fixture-02-resume-existing-change.md` still passes

After implementing Wave 2A:

- [ ] `config/routing.json` has "data-engineer" route with `priority: 95`
- [ ] Triggers include: "data-engineer", "sql", "dbt", "pipeline", "schema", "data quality", "lakehouse", "airflow"
- [ ] `docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md` exists with tactical scope and escalation triggers
- [ ] `docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md` exists with 9 internal routes and `/data:*` mapping
- [ ] `docs/HARNESS_V3_COORDINATOR_ROUTING.md` references tactical routing docs
- [ ] `AGENTS.md` § 7 mentions Data Engineer (verify already present)
- [ ] `test/fixtures/harness-v3/fixture-04-tactical-sql-fix.md` still passes
- [ ] `test/fixtures/harness-v3/fixture-05-data-quality-investigation.md` still passes

---

## Rollback

If Wave 2 breaks something:

```bash
git revert HEAD  # Undo Wave 2 commit
# Restore original config/routing.json (altitude route removed)
# Restore original AGENTS.md (if needed)
```

---

## Next Steps (Wave 3+)

- Wave 3: Unified Phase Contract implementation (phase templates, gates, PRD/ADR/TEST-SPEC rules)
- Wave 3B: Artifact Templates finalization (.specs/templates/)
- Wave 5-11: Ralph Loop, Task-Spec, Delegation, Modes, RTK/Headroom, Command cleanup
