# Data Engineering Tactical Coordinator Model

## Purpose

Define the tactical `data engineer` coordinator that complements the strategic `Altitude` coordinator.

This model exists because not all work should travel through the full strategic lifecycle. Day-to-day fixes, upgrades, and specialist data tasks need a narrower tactical entrypoint with stronger domain routing and less ceremony.

## Two-Agent Model

The final harness should expose two primary user-facing agents only:

1. `Altitude` — strategic coordinator for durable change work
2. `Data Engineer` — tactical coordinator for day-to-day data engineering work

## Architecture As Text

```text
[User request]
  -> [Routing decision]
  -> either [Altitude strategic path]
            or [Data engineer tactical path]

Data engineer tactical path
  -> [tactical coordinator]
  -> [internal router by intent and artifact type]
  -> [domain specialist]
  -> [verification and evidence]
```

## Tactical Scope

The tactical `data engineer` coordinator should handle work such as:

- dbt model fixes
- SQL review and optimization
- Airflow or pipeline adjustments
- schema tweaks
- data quality checks
- migration sub-slices
- short tactical implementation or review work in the data stack

## Tactical Non-Goals

The tactical coordinator should not own:

- broad strategic architecture programs
- cross-domain product/system decomposition
- large durable change planning waves that need full phase progression

Those remain in `Altitude`.

## Internal Tactical Router

The tactical coordinator should absorb the useful logic currently spread across `/data:*` commands and `skills/data-engineering/`.

### Internal Tactical Routes

```text
data engineer coordinator
├── dbt route
├── sql-review route
├── schema route
├── pipeline route
├── data-quality route
├── data-contract route
├── migration route
└── ai-pipeline route
```

The important rule is that these are **internal routes**, not explicit user-facing commands.

## Relationship To Current Skill Surface

Current state:

- `skills/data-engineering/SKILL.md` is command-centered
- `skills/data-engineering/routing_skill.json` maps `/data:*` commands to specialists

Target state:

- the `data engineer` coordinator uses the same specialist mapping ideas internally
- the user does not need explicit `/data:*` commands
- tactical routing is intent-driven and artifact-driven

## Specialist Allocation Model

The tactical coordinator should select a primary specialist from domain signals such as:

- file type
- problem type
- target artifact
- stack keywords

Examples:

| Tactical signal | Primary specialist |
| --- | --- |
| dbt model, macro, generic test | `data-engineering.dbt-specialist` |
| slow SQL, query plan, dialect translation | `data-engineering.sql-optimizer` |
| Airflow DAG or orchestration fix | `data-engineering.airflow-specialist` |
| schema modeling change | `architect.schema-designer` or successor tactical schema route |
| data quality checks | `test.data-quality-analyst` |

## Verification Posture

The tactical path still uses:

- source-backed grounding when required
- `verify:`-driven todos
- Ralph Loop for executable work
- evidence updates when the task is durable enough to require them

## Entry Rule

Use the tactical `data engineer` coordinator when the request is:

- clearly data-engineering scoped
- bounded enough to avoid full strategic lifecycle overhead
- still important enough to benefit from strong routing and verification

Use `Altitude` when the request is:

- broad
- ambiguous across domains
- strategic
- architecture-led
- clearly part of a larger durable change wave

## Roadmap Implication

The V3 refactor should include an explicit tactical track for `data engineer`, not only the strategic `Altitude` coordinator track.
