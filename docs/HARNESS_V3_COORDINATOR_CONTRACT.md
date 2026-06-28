# Harness V3 Coordinator Contract

## Purpose

Define how Harness V3 coordinators classify work, resolve state, load context, allocate ownership, and decide whether to answer, ask, create artifacts, execute, validate, or ship.

## Coordinator Paths

| Path | Owns | Does not own |
| --- | --- | --- |
| Altitude | durable strategic `.specs` changes, phase movement, artifacts, task packs | tactical one-off data fixes unless promoted to durable work |
| Data Engineer | bounded SQL, pipeline, schema, data quality, and analytics-engineering work | multi-wave harness architecture migration |
| `visual:*` | final diagram/visual artifact generation | lifecycle state |
| `core:readme-maker` | README production/update | lifecycle state |

## Runtime Registration

Harness V3 exposes one visible strategic coordinator:

```text
agents/altitude.agent.md
opencode.json -> agent.altitude.mode = primary
```

Phase-specific Altitude agents remain available as hidden internal subagents:

```text
altitude-intent
altitude-structure
altitude-plan
altitude-execution
altitude-validation
altitude-report
altitude-memory
```

The visible coordinator owns classification, state resolution, phase detection, allocation, and gate decisions. Phase subagents provide specialized phase behavior after the coordinator has selected the correct path.

## Request Lifecycle

```text
1. classify request
2. select coordinator path
3. resolve active state
4. resolve phase or tactical mode
5. resolve governing artifacts
6. resolve global and local allocation
7. load minimum required context
8. choose action type
9. ask user if blocked
10. create or update task/artifact
11. allocate specialists when justified
12. project todos with verify clauses
13. execute only when authorized
14. run Ralph Loop for executable work
15. validate
16. update state and memory
17. recommend next gate
```

## Classification

| Classification | Signals | Coordinator |
| --- | --- | --- |
| strategic durable work | roadmap, architecture, `.specs`, PRD, ADR, TEST-SPEC, multi-step refactor | Altitude |
| tactical data engineering | SQL/dbt/Fabric/GCP/Airflow/Dataform, schema, pipeline, data quality | Data Engineer |
| visual artifact | architecture diagram, explainer, presentation visual | `visual:*` |
| README artifact | README create/update | `core:readme-maker` |
| ambiguous | more than one plausible path, missing scope, conflicting state | ask user |

## Action Types

| Action | Allowed when | Writes? |
| --- | --- | --- |
| `answer_only` | user asks explanation or current state | no |
| `ask_user` | ambiguity blocks correctness or phase transition needs gate | no |
| `create_or_update_artifact` | durable planning/reporting artifact is requested or required | yes |
| `create_or_update_task` | work needs executable task contract | yes |
| `execute_task` | active task is ready and user authorized execution | yes |
| `validate` | task/artifact/code needs acceptance evidence | maybe |
| `ship` | acceptance passed or residual risks are explicit | yes |

## Ask-User Gate

Ask one focused question when:

- confidence is below the required threshold
- state sources conflict
- local allocation would exceed global allocation
- execution lacks a ready task
- security, production data, or secrets are affected without explicit authority

Prefer structured options when the runtime supports them.

## Context Loading Rule

Load the smallest context that can decide the next action:

```text
entry instructions
  -> active state
  -> active task
  -> source references
  -> touched files
  -> validation/evidence surfaces
```

Do not preload all agents, commands, KBs, or old specs.

## Specialist Allocation

Specialists are allocated before execution. Each allocation must state:

- reason
- scope
- allowed files or data
- grounding bundle
- evidence expected
- verification responsibility
- stop condition
- accepting owner

Delegation without allocation is invalid.

Specialists must not become hidden task owners. The coordinator or local task owner remains responsible for accepting, rejecting, validating, and recording specialist output.

## Ralph Loop Policy

Before executable work, the coordinator must classify loop posture:

| Posture | Use |
| --- | --- |
| `mandatory` | code, config, runtime, command, plugin, validation, production-data, or critical artifact work |
| `advisory` | discovery, planning, non-critical artifact drafting |
| `not_applicable` | answer-only or trivial read-only work |

For `mandatory` work, the coordinator must:

1. name the current step and success criterion
2. execute within allowed files and forbidden scope
3. verify with a command or manual check
4. call `verify_step` when the active runtime exposes it
5. record manual verification when `verify_step` is unavailable
6. repair bounded failures within allocation
7. stop when repair would broaden scope or validation fails repeatedly

The coordinator must not claim runtime enforcement if the active runtime does not expose the tool. In that case, the manual loop contract from `.specs/shared/execution-loop-contract.md` applies.

## Done Condition

A coordinator turn is complete only when one of these is true:

- answer delivered
- artifact/task created and validated enough for its phase
- execution completed and validation recorded
- blocker recorded with required user decision
- next gate recommended with evidence
