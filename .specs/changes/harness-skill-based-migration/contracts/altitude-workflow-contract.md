# Altitude Workflow Contract

**Version:** 2.0 (Skill-Based Migration target)
**Status:** draft — W2 in progress; becomes active in W4 when AGENTS.md kernel is rewritten.
**Location (target):** `.specs/shared/altitude-workflow-contract.md`
**Location (current):** `.specs/changes/harness-skill-based-migration/contracts/altitude-workflow-contract.md`
**Supersedes:** `.specs/shared/altitude-contract.md` (23-line reference list, insufficient as execution contract)

**Governing ADRs:**
- ADR-0001: Built-in primary hosts only
- ADR-0002: Parent-only TODO and state writer
- ADR-0004: Altitude and AgentSpec are separate workflows
- ADR-0005: Canonical source-of-truth hierarchy
- ADR-0006: Staged activation; compact kernel always loaded
- ADR-0007: Delegation allowlist; sequential default; manual invocation out-of-band

**Referenced contracts (load on demand, not inline):**
- `.specs/shared/state-machine-contract.md` — FSM transitions and deadlock detection
- `.specs/shared/execution-loop-contract.md` — Ralph Loop postures and evidence requirements
- `.specs/shared/allocation-contract.md` — global, local, and specialist allocation
- `.specs/shared/memory-contract.md` — write triggers and dual-memory architecture

---

## 1. What Altitude Is

Altitude is the workflow for **strategic durable work**: new systems, new architectural changes, multi-wave refactors, governance decisions, and migrations. Its output is a set of versioned, evidence-backed change artifacts stored under `.specs/changes/{change_id}/`.

Altitude is **not** the workflow for:
- Tactical single-file fixes → route to the relevant specialist agent directly.
- AgentSpec/SDD feature work → route to AgentSpec START via `/workflow:*` commands.
- Quick direct answers → no workflow activation required.

---

## 2. Phases

The Altitude workflow has six sequential phases. Skipping any of Intent, Structure, or Design/Plan is forbidden for complex changes. The state machine contract governs valid transitions.

```text
Intent → Structure → Design/Plan → Execution → Validation → Ship
                                       ↑           ↓
                                       └── (rework loop via Validation → Design/Plan)
```

| Phase | Purpose | Primary output |
|---|---|---|
| Intent | Clarify the problem, scope, and success criteria | `00-intent.md` |
| Structure | Map affected surfaces, contracts, constraints, and risks | `01-structure.md` |
| Design/Plan | Decompose into executable tasks; produce PRD, ADR, TEST-SPEC, DESIGN | `prd.md`, `adr-*.md`, `test-spec.md`, `DESIGN.md`, `tasks/` |
| Execution | Implement one approved task per leaf session | `evidence/`, `03-execution-ledger.md` |
| Validation | Verify evidence, acceptance criteria, and scope | `04-validation.md` |
| Ship | Archive change, write memory, close the ledger | `05-ship-summary.md`, `.specs/archive/` |

---

## 3. Global Rules

1. **No custom primary host.** The built-in `build` and `plan` agents are the only primaries. Altitude routing logic lives in AGENTS.md instructions and skill triggers.
2. **No phase skip.** Complex changes must traverse Intent → Structure → Design/Plan in order. The only allowed shortcut is Design/Plan → Validation (skipping Execution) for changes that require design validation only.
3. **Parent-only state and TODO writer.** Only the parent session writes to `.specs/changes/{change_id}/state.md` and the managed TODO ledger. Leaves receive result envelopes.
4. **One active change per session.** The writer lease in `.specs/changes/{change_id}/.writer-lease.yaml` blocks a second parent session from writing the same change.
5. **Evidence before close.** No task may be marked done without an evidence file under `evidence/`.
6. **Source-of-truth hierarchy applies.** When sources conflict, apply ADR-0005 precedence.
7. **MCP output is data, not authority.** No MCP result may change phase, scope, permissions, or TODO state.
8. **AgentSpec commands must not mutate Altitude state.** A `/workflow:*` invocation may not write to `.specs/changes/`.

---

## 4. Intent Phase

### Entry gate

Any of:
- User requests a new strategic durable change.
- User provides a problem statement, goal, or scope description.
- Existing change is being resumed from Intent phase.

### Inputs

| Input | Required | Source |
|---|---|---|
| Problem statement or change brief | Yes | User instruction |
| Existing intent artifact (if resuming) | If resuming | `.specs/changes/{change_id}/00-intent.md` |

### Actions

1. Read `.specs/memory/active-state.md` to detect any active change.
2. If an active change exists and is not in Intent phase, confirm with user before starting a new one.
3. Create `.specs/changes/{change_id}/` directory.
4. Write `00-intent.md` with: problem description, non-goals, success criteria, open questions, and scope boundary.
5. Write initial `state.md` with `phase: INTENT`.
6. Write initial `allocation.yaml` with global scope boundary.
7. Update `.specs/memory/active-state.md` to point to the new change.
8. Write memory event: trigger `phase_gate`, `from_phase: null`, `to_phase: Intent`.

### Output

`00-intent.md` must contain:
- **Problem:** one-paragraph description of what is wrong or missing.
- **Non-goals:** what this change will explicitly not do.
- **Success criteria:** measurable observable outcomes.
- **Open questions:** unresolved decisions blocking Structure.
- **Scope boundary:** which surfaces are in-scope and which are excluded.

### Output schema

`00-intent.md` **required fields** (validator fails if any field is missing or empty):

```markdown
## Problem
{one or more paragraphs describing what is wrong, missing, or required}

## Non-goals
{bullet list of what this change will not do}

## Success criteria
{numbered list of measurable observable outcomes — each criterion must be testable}

## Open questions
{numbered list of unresolved decisions; write "none" if resolved}

## Scope boundary
**In scope:** {comma-separated list of surfaces, directories, or systems}
**Out of scope:** {comma-separated list of explicitly excluded areas}
```

Minimum acceptable length: 200 words. A `00-intent.md` shorter than 200 words is considered incomplete.

### Forbidden actions

- Do not start Structure or Design/Plan without user approval of the intent.
- Do not write to `agents/`, `commands/`, `skills/`, `opencode.json`, or any runtime surface.
- Do not create task files or execution evidence in Intent phase.

---

## 5. Structure Phase

### Entry gate

- Intent phase has a user-approved `00-intent.md`.
- Parent session has the writer lease.

### Inputs

| Input | Required | Source |
|---|---|---|
| `00-intent.md` | Yes | `.specs/changes/{change_id}/` |
| Baseline inventory | Yes | T-001 `evidence/baseline.md` and `evidence/checksums.sha256` |
| File ownership matrix | Yes | `file-ownership-matrix.md` (W1 T-015) |

### Actions

1. Map every surface the change will touch against the file ownership matrix.
2. Identify contracts, constraints, shared-contract dependencies, and external integrations.
3. Identify risks: scope creep, conflicting allocations, missing skill coverage.
4. Write `01-structure.md` with: surface map, constraints table, risk register, and dependency list.
5. Update `state.md` with `phase: STRUCTURE`.
6. Write memory event: trigger `phase_gate`, `from_phase: Intent`, `to_phase: Structure`.

### Output

`01-structure.md` must contain:
- **Surface map:** table of files/directories, current owner, planned mutation, and wave.
- **Constraints:** non-negotiable invariants from governing ADRs that apply to this change.
- **Risk register:** each risk with severity, likelihood, and mitigation.
- **Dependencies:** other changes, waves, or skills this change depends on.

### Output schema

`01-structure.md` **required fields**:

```markdown
## Surface map
| Surface | Path | Current owner | Planned action | Wave |
|---|---|---|---|---|
| {name} | {path} | {owner} | {add/modify/delete/read-only} | {W0..W12} |

## Constraints
{numbered list of non-negotiable rules from governing ADRs or shared contracts that apply to this change}

## Risk register
| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| {risk description} | critical/high/medium/low | high/medium/low | {mitigation action} |

## Dependencies
{numbered list of other changes, waves, or skills this change depends on; write "none" if independent}
```

Minimum one row in surface map. Minimum one constraint. Minimum one risk.

### Forbidden actions

- Do not begin Design/Plan without reviewing the surface map with the parent.
- Do not skip the risk register if the change touches runtime surfaces.

---

## 6. Design/Plan Phase

### Entry gate

- `01-structure.md` exists and has been reviewed.
- All surfaces have identified owners.
- The **4-Doc Gate** must pass before Execution begins: PRD, ADR(s), TEST-SPEC, and DESIGN must all exist.

### Inputs

| Input | Required | Source |
|---|---|---|
| `01-structure.md` | Yes | `.specs/changes/{change_id}/` |
| Relevant ADRs | Yes | `.specs/changes/harness-skill-based-migration/adrs/` or `.specs/shared/` |
| Relevant shared contracts | As needed | `.specs/shared/` (load by domain) |
| Task-Spec skill | Mandatory | `task-spec` skill — load receipt required |

### Actions

1. Load the `task-spec` skill and produce a load receipt in evidence.
2. Write `prd.md`: requirements with testable acceptance criteria.
3. Write `adr-{N}.md` for each architectural decision required by this change.
4. Write `test-spec.md`: test scenarios for each acceptance criterion.
5. Write `DESIGN.md`: task breakdown, allocation map, file-change plan, and wave assignments.
6. Create `tasks/T-{N}.md` for each executable task, satisfying the Task-Spec Definition of Ready.
7. Assign each task to a validation block.
8. Update `state.md` with `phase: DESIGN`.
9. Write memory event: trigger `phase_gate`, `from_phase: Structure`, `to_phase: Design`.

### 4-Doc Gate

Before any Execution task may start:

```bash
test -f .specs/changes/{change_id}/prd.md
test -f .specs/changes/{change_id}/adr-*.md
test -f .specs/changes/{change_id}/test-spec.md
test -f .specs/changes/{change_id}/DESIGN.md
```

All four must pass. Missing any one blocks Execution entirely.

### Output schemas

**`prd.md` required fields:**

```markdown
## Requirements
| ID | Requirement | Acceptance criterion | Priority |
|---|---|---|---|
| REQ-001 | {requirement} | {testable criterion} | P0/P1 |

## Out of scope
{numbered list}
```

**`test-spec.md` required fields:**

```markdown
## Test scenarios
| ID | Scenario | Input | Expected output | Test type |
|---|---|---|---|---|
| T-001 | {scenario name} | {input} | {expected} | unit/integration/manual |
```

**`DESIGN.md` required fields:**

```markdown
## Task allocation map
| Task ID | Title | Owner agent | Allowed files | Validation block |
|---|---|---|---|---|
| T-001 | {title} | {agent} | {file list} | V-{N} |

## File-change plan
| File | Current state | Planned change | Wave |
|---|---|---|---|
| {file} | {current} | {add/modify/delete} | {wave} |
```

### Exit gate

4-Doc Gate passes and user approves the task list.

### Forbidden actions

- Do not start Execution without the 4-Doc Gate.
- Do not create tasks without explicit allowed/forbidden file scope.
- Do not assign a task to a leaf that has `task: allow` in the current harness (pre-W6).

---

## 7. Execution Phase

### Entry gate

- 4-Doc Gate passed.
- Active task has `status: ready` in its Task-Spec.
- Allowed files, forbidden scope, acceptance criteria, and verification command are defined.
- Parent has the writer lease.

### Inputs

| Input | Required | Source |
|---|---|---|
| Active Task-Spec (`tasks/T-{N}.md`) | Yes | `.specs/changes/{change_id}/tasks/` |
| `DESIGN.md` allocation map | Yes | `.specs/changes/{change_id}/DESIGN.md` |
| Relevant shared contracts | As needed | `.specs/shared/` |

### Actions

Per task:
1. Parent writes the task ID and status `in_progress` to the managed TODO ledger.
2. Parent creates a result envelope for the leaf session with: task ID, allowed files, forbidden scope, acceptance criteria, verification commands, and evidence path.
3. Leaf session executes using the Ralph Loop (mandatory posture for all file mutations).
4. Leaf returns the result envelope to the parent.
5. Parent verifies the evidence file exists and the acceptance criteria are met.
6. Parent closes the task in the ledger with `status: done` and evidence path.
7. Parent writes memory event: trigger `bloco_completion` when a validation block closes.

### Sequential default

One active task at a time. Parallel tasks require pre-declared independent file scope and explicit parent approval before Execution begins.

### Leaf protocol

The leaf session:
- Receives a complete envelope; it does not read state or TODO.
- May not call `todowrite` (deny at profile level post-W6).
- May not call `task` to create further subagents (deny at profile level post-W6; recursive delegation prohibited by ADR-0007).
- Returns evidence to the parent; the parent decides what to write to the ledger.

### Output schema

**`evidence/T-{N}-{slug}.md` required fields** (each task must have exactly one evidence file):

```markdown
## Task
{task ID and title}

## Inputs
{list of input files and their source}

## Actions taken
{numbered list of what was done}

## Verification result
{command or check run, and its output or outcome}

## Acceptance criteria
- [x] {criterion 1}
- [x] {criterion 2}

## Scope compliance
- No file outside allowed paths was changed: {yes/no}
- No secret value in this evidence file: {yes/no}
```

**`03-execution-ledger.md` required fields:**

```markdown
| Task ID | Status | Evidence file | Actor | Closed at |
|---|---|---|---|---|
| T-{N} | done | evidence/T-{N}-{slug}.md | parent | {timestamp} |
```

### Forbidden actions

- Do not mark a task done without an evidence file.
- Do not let a leaf write directly to the managed TODO ledger.
- Do not start a second task while the first is `in_progress`.
- Do not start Execution if the writer lease is held by another session.

---

## 8. Validation Phase

### Entry gate

- All Execution tasks in the validation block have `status: done` with evidence.
- An independent validator (not the task executor) is assigned.

### Inputs

| Input | Required | Source |
|---|---|---|
| All task evidence files | Yes | `.specs/changes/{change_id}/evidence/` |
| Task-Spec acceptance criteria | Yes | `tasks/T-{N}.md` |
| `DESIGN.md` allocation map | Yes | check scope |
| `test-spec.md` | Yes | check test coverage |
| Baseline checksums | Yes | `evidence/checksums.sha256` (T-001) |

### Actions

1. Review each task outcome, evidence, and acceptance criterion.
2. Verify no file outside the task's allowed scope was changed.
3. Run verification commands from each Task-Spec.
4. Run static architecture checks (post-W4: `grep "mode: primary" agents/`; post-W6: `grep "task: allow" agents/`).
5. Run security scan on changes that touch permissions, configs, or MCP surfaces.
6. Issue PASS, FAIL, or BLOCKED.
   - FAIL: create remediation tasks in the same wave; do not advance.
   - BLOCKED: surface dependency or missing resource; do not advance.
   - PASS: parent accepts verdict and advances to Ship or opens next validation block.
7. Write memory event: trigger `phase_gate`, `from_phase: Execution`, `to_phase: Validate`.

### Exit gate

Validator issues PASS. No critical or high unresolved defect remains.

### Output schema

**`04-validation.md` required fields:**

```markdown
## Verdict
{PASS | FAIL | BLOCKED}

## Task checklist
| Task | Status | Evidence | Criteria met | Scope clean |
|---|---|---|---|---|
| T-{N} | done | {path} | yes/no | yes/no |

## Defect summary
| Severity | Count | Unresolved |
|---|---|---|
| Critical | {N} | {N} |
| High | {N} | {N} |

## Scope audit result
{output of scope check or statement that no out-of-scope file was changed}

## Memory event status
{local write: done | MCP sync: done/pending/failed}
```

---

## 9. Ship Phase

### Entry gate

- Validation phase returned PASS for all blocks.
- No open critical or high defect.
- Parent has the writer lease.

### Inputs

All change artifacts: `00-intent.md`, `01-structure.md`, `prd.md`, ADRs, `test-spec.md`, `DESIGN.md`, all task specs, all evidence, `04-validation.md`.

### Actions

1. Write `05-ship-summary.md` with: delivered boundary, decisions made, evidence paths, residual risks, rollback reference, and lessons learned.
2. Archive the change: move `tasks/`, `evidence/`, and phase documents to `.specs/archive/{change_id}/`.
3. Write local memory event first: trigger `bloco_completion` or `phase_gate`, `to_phase: Ship`.
4. Attempt MCP semantic duplicate write (async; failure is logged, not blocking).
5. Update `.specs/memory/active-state.md` to clear the active change.
6. Release the writer lease.
7. Create follow-up changes for any residual risk or future work identified during ship.

### Exit gate

Change is archived, memory is written, and the active-state pointer is cleared.

### Output schema

**`05-ship-summary.md` required fields:**

```markdown
## Delivered boundary
{description of what was delivered and what was explicitly excluded}

## Decisions made
{numbered list of decisions with ADR or evidence reference}

## Evidence paths
{table or list of all evidence files produced}

## Residual risks
| Risk | Severity | Follow-up change |
|---|---|---|
| {risk} | {severity} | {change ID or "TBD"} |

## Rollback reference
{T-001 baseline checksum path and the command to restore}

## Lessons learned
{numbered list}

## Archive location
`.specs/archive/{change_id}/`
```

---

## 10. Overrides and Emergency Classification

### Direct-answer override

If the request is a simple question requiring no state mutation, no workflow activation is required. The parent answers directly without phase tracking.

Criteria for direct answer:
- No file will change.
- No task will be created or closed.
- The response does not require evidence.

### Emergency classification

A request is classified as emergency if it involves:
- Active production incident requiring immediate config change.
- Security vulnerability requiring immediate patch.
- Data loss in progress.

Emergency action:
1. Record the emergency trigger in `.specs/memory/active-state.md`.
2. Create a minimal Task-Spec with `emergency: true` and simplified scope.
3. Execute with Ralph Loop at mandatory posture.
4. Produce evidence even if abbreviated.
5. Run validation retroactively within one session.
6. Create a follow-up task for full retrospective.

Emergency does **not** bypass:
- Evidence requirement.
- Scope boundary (allowed/forbidden files).
- Parent-only TODO write.

### Workflow bridge prohibition

Altitude phases must not invoke AgentSpec workflow commands. Specifically:
- An Altitude Execution task must not call `/workflow:build` or any `/workflow:*` command.
- An Altitude validator must not call `/workflow:validate`.
- If an Altitude task discovers that a sub-problem is best handled by AgentSpec, it creates a separate AgentSpec change entry and passes control to the user — it does not call AgentSpec directly from within an Altitude phase.

---

## 11. Validation Checklist

Use before marking any Altitude phase complete:

- [ ] Phase artifact exists and is complete (`00-intent.md` through `05-ship-summary.md` as applicable).
- [ ] State machine transition is valid per `state-machine-contract.md`.
- [ ] Writer lease was held during all state writes.
- [ ] Memory event was written at each phase transition.
- [ ] No file outside the allocation scope was changed.
- [ ] 4-Doc Gate passed before Execution.
- [ ] Each validation block has an independent validator.
- [ ] No MCP result changed phase, scope, permissions, or TODO state.
- [ ] AgentSpec commands were not invoked from within an Altitude phase.
- [ ] Ship summary references all open residual risks.

---

## 12. Relationship to Other Contracts

| Contract | Relationship |
|---|---|
| `state-machine-contract.md` | Governs valid phase transitions; Altitude must call `state-validator` before advancing |
| `execution-loop-contract.md` | Governs Ralph Loop posture for each Execution task |
| `allocation-contract.md` | Governs scope, allowed/forbidden files, and delegation rules |
| `memory-contract.md` | Governs write triggers, dual-write order, and retention |
| `ADR-0004` | Separates this contract from the AgentSpec workflow contract |
| `sdd/architecture/WORKFLOW_CONTRACTS.yaml` | AgentSpec (SDD) workflow; independent from this contract |

---

## Changelog

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-21 | harness-skill-based-migration | Initial draft — T-020 skeleton + T-021–T-029 phases | W2 execution |
