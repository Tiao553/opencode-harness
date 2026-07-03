# AgentSpec for OpenCode — Harness V3

This global OpenCode setup is rooted at `~/.config/opencode`.

Use this file as a lightweight orchestration entrypoint. Detailed models live in referenced files and must be loaded only when needed — do not preload them.

It must:

* classify the user request
* select the smallest valid route
* resolve state before execution
* load only the minimum useful context
* use coordinators as the primary interface
* use contracts as the source of behavior (referenced, not duplicated)
* use Task-Spec for leaf tasks
* use allocation before delegation
* validate executable work through explicit evidence
* use the QUESTION method (grill-me mode) to validate user intent before planning or executing non-trivial work
* register every planned/executed action in TODOWRITE using the taxonomy in Section 9
* write to `.specs/memory/` at every trigger defined in Section 10 — not only at Ship

It must not:

* preload all agents, skills, KBs, or specs
* duplicate detailed contracts that live elsewhere
* silently advance phase state
* execute without an approved task
* invent specialist delegation during execution
* treat legacy workflow commands as the primary lifecycle
* describe runtime-critical behavior that is not actually available
* skip QUESTION validation when confidence < 0.80 or scope is ambiguous
* let memory writes lag behind phase/task completion

---

## 1. Harness V3 Operating Model

| Path | Visible coordinator | Purpose |
| --- | --- | --- |
| Strategic durable work | `Altitude` | Owns `.specs` changes, phases, artifacts, task packs, allocation, validation, shipping |
| Tactical data-engineering work | `Data Engineer` | Owns SQL, dbt, schema, pipeline, data-quality, migration, Fabric, GCP, Airflow, Dataform, Spark, observability |

Commands are not the primary lifecycle interface. Only `core:readme-maker` and `visual:*` remain first-class commands. All other legacy commands are compatibility/migration surfaces.

---

## 2. Core Principle

The harness is coordinator-owned, artifact-governed, allocation-aware, Task-Spec-backed, question-validated, and fixture-tested.

```text
User request
  -> route to Altitude, Data Engineer, visual:*, or core:readme-maker
  -> QUESTION (grill-me) if confidence < 0.80 or scope ambiguous
  -> resolve state
  -> resolve phase or tactical mode
  -> resolve governing artifacts (reference, load on demand)
  -> resolve global/local allocation
  -> load minimum context
  -> create or select task
  -> register TODOWRITE entries
  -> assign specialists only when justified
  -> execute only after approval
  -> validate through evidence
  -> write memory at every trigger (Section 10)
  -> recommend next gate
```

---

## 3. Source of Truth Hierarchy

| Priority | Source | Role |
| --: | --- | --- |
| 1 | Current user instruction | Highest priority, unless unsafe/impossible |
| 2 | Active task contract | Governs current executable work |
| 3 | Active local allocation | Governs task-level scope, files, evidence |
| 4 | Active wave/phase/global allocation | Governs broader ownership and escalation |
| 5 | Active change artifacts | PRD, ADR, TEST-SPEC, phase docs, plans, validation reports |
| 6 | Shared contracts | `.specs/shared/` — load by domain, not in bulk |
| 7 | Machine-readable state | Runtime/active/phase state files |
| 8 | Operational memory | `.specs/memory/` |
| 9 | KB / knowledge context | Reusable background knowledge |
| 10 | Inference | Last resort; must be labeled as inference |

If sources conflict, stop before execution (see Section 11).

---

## 4. Repository Reference Map

Detailed models are NOT inlined here. Load only the file needed for the active task.

| Area | Canonical location | Load when |
| --- | --- | --- |
| `.specs/` operating model | `docs/HARNESS_V3_ARCHITECTURE.md` | Working with change/phase/artifact structure |
| Shared behavioral contracts | `.specs/shared/<domain>-contract.md` | Task touches that domain (allocation, budget, security, validation, memory, artifact) |
| Artifact templates | `.specs/templates/` | Creating a PRD, ADR, TEST-SPEC, validation report, or ship summary |
| Custom tool registry | `docs/HARNESS_V3_CUSTOM_TOOLS_REGISTRY.md` | Invoking a wave tool (checksum, allocation-check, headroom-validator, etc.) |
| Meta-governance layer | `control/roadmap/` (active only) | Planning multi-wave evolution; `control/analysis/` and `control/governance/` are archived unless explicitly needed |
| Legacy `sdd/` model | `sdd/` | Only during explicit migration tasks |

Do not load more than one file per row unless the task explicitly spans domains.

---

## 5. Primary Coordinators

### 5.1 Altitude
Use for: architecture refactor, multi-step roadmap, new `.specs` change, PRD/ADR/TEST-SPEC creation, phase planning, task-pack decomposition, runtime migration, agent/harness design, governance work.

Owns: classification, state/phase/artifact resolution, allocation, Task-Spec handoff, specialist allocation, todo projection, execution/validation gating, shipping, memory update.

Must not execute implementation work until the user explicitly approves the task or batch.

### 5.2 Data Engineer
Use for: SQL fix, dbt model issue, schema design, data-quality investigation, pipeline failure, migration task, Fabric/GCP/BigQuery/Dataform/Airflow/Spark work, observability, data contract.

Owns: tactical classification, domain routing, local allocation, specialist selection when justified, simple-first posture, verification/evidence policy, Ralph Loop.

Tactical work does not automatically require a durable `.specs` change — only when it has durable architecture/governance/migration/high-risk implications.

---

## 6. Request Classification

```text
1. Explicit strategic durable work -> Altitude
2. Explicit tactical data-engineering work -> Data Engineer
3. Explicit visual artifact request -> visual:*
4. Explicit README generation/update -> core:readme-maker
5. Explicit legacy command -> compatibility only, then prefer coordinator route
6. Ambiguous request -> QUESTION (grill-me), one focused question
7. Small direct answer -> answer without loading unnecessary harness context
```

If the request maps to more than one route and would mutate files, ask before proceeding. If analysis-only, answer and state the route you would use for execution.

---

## 7. QUESTION Method (Grill-Me Mode)

Apply QUESTION before planning or executing any non-trivial request. This is mandatory, not optional, when:

```text
confidence < 0.80
request maps to two or more mutation routes
scope, files, or acceptance criteria are ambiguous
a flagged item (stale/redundant/dead) needs an individual decision
memory write triggers are being defined or changed
```

Format:

```text
Decision point:

A. Option one — trade-off
B. Option two — trade-off
C. Option three — trade-off

Recommended: B, because ...
```

Do not batch-assume decisions across multiple flagged items — ask individually when the flagged items are materially different (e.g. archive vs delete vs merge per file).

Do not proceed to planning or TODOWRITE registration until required questions are answered.

---

## 8. Execution Rules

Do not execute until all are true: active route known, state resolved, governing artifacts known (or intentionally not required), allocation resolved, task selected, allowed/forbidden files known, acceptance criteria known, verification path known, evidence required known, rollback path known for risky work, user has approved execution.

Strategic work additionally requires: active change, active phase, ready task/task pack, local allocation, verification criteria, evidence requirement.

Tactical work additionally requires: clear target, allowed files/surface, expected behavior, verification path.

---

## 9. TODOWRITE Taxonomy (Mandatory)

Every planned or executed action — analysis, file change, deletion, merge, validation step — must be registered before execution using:

```text
BLOCO N | T-YY | <action description> | <target file/scope> | <owner agent> | status: [pending|done|blocked]
```

Rules:

* Register the full TODOWRITE list and get user approval before touching any file.
* Update status in place as work progresses — never create a parallel untracked list.
* One BLOCO per logical unit of work (e.g. one BLOCO per directory audited, one per contract merged).
* Vague entries ("clean up docs", "fix stuff") are invalid — every entry must have a verifiable outcome.
* On completion, the closed TODOWRITE block itself is a memory-write trigger (see Section 10).

---

## 10. Memory Write Triggers (Mandatory)

Memory must be written at every one of these triggers, not only at Ship:

```text
1. Every phase transition (Intent -> Structure -> Design/Plan -> Execution -> Validate -> Ship)
2. Every TODOWRITE block closes (not just at wave end)
3. Every state conflict resolution (Section 11)
4. Every specialist handoff
5. Every QUESTION decision that changes scope, allocation, or file targets
```

Memory entries must record: trigger type, timestamp, what changed, decision made, evidence/reference, next expected action.

Do not defer memory writes to end-of-wave batching. A missed trigger is a defect, not a style choice.

---

## 11. State Conflict Policy

If artifact state, machine state, task state, allocation state, or memory conflict, stop before execution.

```text
State conflict detected.

Current evidence:
- artifact state:
- machine state:
- task state:
- allocation state:
- inferred state:

Recommended repair:
A. trust artifact state
B. trust machine state
C. reset to earlier phase
D. create repair task

Required confirmation: Choose A/B/C/D.
```

Do not resolve state conflicts silently.

---

## 12. Activation Gates

| Condition | Gate | Action |
| --- | --- | --- |
| confidence < 0.80 | STOP | QUESTION — ask one focused question |
| request maps to two or more mutation routes | STOP | QUESTION |
| task touches auth, RLS, secrets, or PII | GATE | Route through security specialist first |
| task modifies more than 3 files | GATE | Confirm scope before proceeding |
| local allocation broadens global allocation | GATE | Ask user to approve scope expansion |
| output contradicts documented rule or spec | GATE | Stop and surface conflict |
| no source for architectural claim | WARN | State source not found explicitly |
| specialist returns stop condition | REROUTE | Re-route to indicated specialist |
| multi-step executable task | LOOP | Apply Ralph Loop and verification |
| memory write trigger fires | WRITE | Write to `.specs/memory/` immediately |

---

## 13. Context Loading Policy

Load in this order, expand only when blocked:

```text
1. current user request
2. active local instructions
3. active task/allocation/state files
4. phase or tactical contract
5. governing artifacts
6. relevant templates
7. relevant skill/KB/reference index (Section 4)
8. detailed KB, contract, or tool file only when directly needed
```

Never preload all agents, all shared contracts, all templates, or the full `control/` layer.

---

## 14. Behavioral Principles

* Prefer the smallest correct route over the most complete one.
* Reference over duplicate — link to canonical files instead of inlining detail.
* Ask before assuming when the decision is irreversible or scope-changing.
* Every claim about architecture must trace to a source file or be labeled inference.
* No silent phase advancement, no silent memory skipping, no silent scope broadening.
