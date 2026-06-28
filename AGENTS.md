# AgentSpec for OpenCode

This global OpenCode setup is rooted at `~/.config/opencode`.

Use it as a lightweight orchestration layer:

- classify intent
- load the smallest useful context
- route to agents, commands, skills, KB, knowledge context, SDD, MCP, or shell only when required

## Altitude Specs Operating Model

The primary operating interface for durable change work is agent-first. Agent selection is explicit or route-triggered; no altitude agent is forced as the OpenCode runtime default.

| Altitude | Primary agent | Purpose |
| --- | --- | --- |
| Intent | `altitude-intent` | Clarify the problem and create/update `.specs/changes/{change}/00-intent.md` |
| Structure | `altitude-structure` | Map repository modules, contracts, constraints, and risks |
| Decomposition | `altitude-plan` | Create task packs with allowed files, forbidden scope, verification, evidence, and rollback |
| Execution | `altitude-execution` | Execute exactly one approved task at a time |
| Validation | `altitude-validation` | Validate scope, evidence, tests, and acceptance criteria |
| Report | `altitude-report` | Report from `.specs` artifacts, not chat history |
| Memory | `altitude-memory` | Update durable `.specs/memory` and archive shipped/cancelled changes |

Rules:

- The user operates high; agents descend altitude by altitude.
- Complex execution must not skip Intent, Structure, and Decomposition.
- No execution without an active change and a ready task.
- No execution without `allowed_files`, `forbidden_scope`, `acceptance_criteria`, `verification_commands`, and `evidence_required`.
- Commands remain a compatibility layer; preferred usage is switching to the relevant `altitude-*` primary agent.

### `.specs/` vs `sdd/`

| Path | Role |
| --- | --- |
| `sdd/` | Global reusable method, templates, workflow contracts, gates, and architecture docs |
| `.specs/shared/` | Project-local contracts copied from the harness baseline |
| `.specs/templates/` | Project-local templates copied from the harness baseline |
| `.specs/changes/` | Real project change requests, tasks, decisions, evidence, reports, and state |
| `.specs/memory/` | Real project operational memory |
| `.specs/archive/` | Shipped or cancelled changes |

The method is shareable. Real execution state is private by default.

## Global Policies

Two policies apply to every SDD phase:

| Policy | Rule | Contract Reference |
| --- | --- | --- |
| **Write-then-Copy** | Every SDD artifact is written to `~/.config/opencode/sdd/features/{feature-name}/` first, then copied flat to `./specs/{PHASE}_{FEATURE}.md`. Never write the local artifact separately and never create feature subfolders under `./specs/`. | `artifact_storage` in `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| **Build Output Gate** | At the start of every `/workflow:build`, ask the user where generated code must be written before loading design context or creating files. There is no default output path and it must not be read from `DESIGN`. | `build_output_gate` in `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |

## Behavioral Principles

Apply before routing, loading context, or implementing.

**1. Think Before Coding** — List assumptions before acting. Present multiple interpretations when they exist; never pick silently. When uncertain or unclear: stop, name the confusion, ask.

**2. Simplicity First** — Implement only what was asked. No speculative features, no abstractions for single-use code. Test: "Would a senior engineer call this overcomplicated?" If yes, simplify.

**3. Surgical Changes** — Touch only what the request requires. Preserve adjacent code, comments, and style. Remove only orphans your own changes created.

**4. Goal-Driven Execution** — Convert tasks to verifiable criteria: `1. [Step] → verify: [check]`. Never start multi-step work with a vague goal like "make it work".

**Confidence gate:** below 0.80 = ask before proceeding; 0.80–0.90 = proceed with stated caveat; above 0.90 = proceed directly.

**Source discipline:** Every architectural recommendation, rule, or design pattern must cite its source (KB file, spec, requirement doc) before being stated as fact. If no source exists, say so explicitly.

## Entry Rules

- Commands define explicit entrypoints.
- Skills carry reusable process.
- Agents carry role-specific judgment and execution.
- KB and knowledge context provide grounding.
- `WORKFLOW_CONTRACTS.yaml` is the workflow source of truth.

## Custom Tool Contract

Local custom tool implementations live under `~/.config/opencode/tools/`:

- `faithfulness_gate.ts`
- `verify_step.ts`

When the active OpenCode runtime exposes those tools, use them as described below.
If a runtime does not expose one of them, state that the automated check was unavailable and continue with a manual gate or verification note instead of implying the tool ran.

## Activation Conditionals

When the active runtime exposes `faithfulness_gate`, call it before proceeding when any condition below applies.

| Condition | Gate | Action |
| --- | --- | --- |
| confidence < 0.80 OR request maps to ≥2 routes | STOP | Ask one question — do not route yet |
| task touches auth / RLS / secrets / PII | GATE | Route through `dev.security-guardian` first |
| task modifies > 3 files | GATE | Confirm scope with user before proceeding |
| output contradicts documented rule or spec | GATE | Invoke `product.rules-qa-agent` |
| no source for architectural claim | WARN | State "source not found" explicitly |
| agent returns Stop Condition | REROUTE | Re-route to indicated specialist |
| multi-step task | LOOP | Apply `verify_step` for each step when the runtime exposes it; otherwise keep the same loop manually |

## Verification Loop

When the active runtime exposes `verify_step`, call it at each multi-step task boundary. If it is unavailable, keep the same step + verification discipline manually and say so explicitly:

```text
WHILE steps remain:
  1. State step + success criterion before executing
  2. Execute step
  3. Call verify_step(step, verdict: PASS | FAIL | BLOCKED) when available
     - FAIL → fix and retry (max 2×); on 3rd FAIL escalate to user
     - BLOCKED → surface to user, halt loop
     - PASS → advance to next step
COMPLETE when all steps return PASS
```

## Routing Flow

If intent is unclear after one read, ask one focused question first.

Routing order:

1. If the user is operating a durable change, select the matching `altitude-*` primary agent.
2. Explicit slash command → read only the matching command file.
3. For ambiguous natural-language work, load `using-agent-skills` first and select the smallest useful skill before choosing specialist agents.
4. Otherwise use `graph-router` / Graphify-first candidate ranking.
5. Fall back to `~/.config/opencode/config/routing.json` when confidence is low, the request is ambiguous, or policy/security gates apply.
6. Load only the smallest useful agent, KB, or local repo context.

## Context Loading Policy

- Do not preload all agents, skills, KBs, knowledge context, or SDD files.
- Prefer `quick-reference.md` or `index.md` before detailed KB concept or pattern files.
- Load at most the files needed to answer, edit, or validate the current task; expand only when blocked.
- `~/.config/opencode/config/grounding.md` is a legacy policy reference, not a mandatory preload.
- Local repository instructions win for folder-specific behavior; this global file wins for cross-repository orchestration.

## Command Policy

- Workflow phases must be invoked through native commands: `/workflow:brainstorm`, `/workflow:define`, `/workflow:design`, `/workflow:build`, `/workflow:validate`, `/workflow:ship`, `/workflow:iterate`, `/workflow:create-pr`.
- Do not reintroduce legacy unprefixed aliases such as `/build` or `/create-kb`.
- If the user asks for a workflow phase in natural language, route them through the matching native command behavior.
- For new durable project work, prefer the `altitude-*` primary agents over new slash commands.
- Do not add new slash commands as the main interface for Altitude Specs.

## Execution Heuristic

- Repo/file discovery, reference checks, validation → use search tools and parallel reads.
- Shared routing, config, or instruction edits → serialize writes.
- External behavior may have changed → use MCP, web, or official docs.
- Security/commit/secret handling → route through `dev.security-guardian` and the security settings file.
- Altitude execution → require `.specs/memory/active-state.md`, active change `state.md`, and exactly one ready task.
- Workflow phases → use native workflow commands only.
- Missing or ambiguous references → validate existence before loading or editing.

## Reference Policy

- Keep canonical content in the owning agent, skill, KB, knowledge context, or SDD file.
- This entrypoint should route to those files, not duplicate them.

## Project Docs

- `docs/AGENTIC_GAP_DOSSIER.md` is the running audit and upgrade rationale for the harness.
- `docs/tasks/README.md` and `docs/tasks/phase-*.md` are execution checklists, not source-of-truth policy.
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml` remains the canonical workflow contract.
