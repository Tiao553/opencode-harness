# AgentSpec for OpenCode

This global OpenCode setup is rooted at `~/.config/opencode`.

Use it as a lightweight orchestration layer:

- classify intent
- load the smallest useful context
- route to agents, commands, skills, KB, knowledge context, SDD, MCP, or shell only when required

## Global Policies

Two policies apply to every SDD phase:

| Policy | Rule | Contract Reference |
|---|---|---|
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
|---|---|---|
| confidence < 0.80 OR request maps to ≥2 routes | STOP | Ask one question — do not route yet |
| task touches auth / RLS / secrets / PII | GATE | Route through `dev.security-guardian` first |
| task modifies > 3 files | GATE | Confirm scope with user before proceeding |
| output contradicts documented rule or spec | GATE | Invoke `product.rules-qa-agent` |
| no source for architectural claim | WARN | State "source not found" explicitly |
| agent returns Stop Condition | REROUTE | Re-route to indicated specialist |
| multi-step task | LOOP | Apply `verify_step` for each step when the runtime exposes it; otherwise keep the same loop manually |

## Verification Loop

When the active runtime exposes `verify_step`, call it at each multi-step task boundary. If it is unavailable, keep the same step + verification discipline manually and say so explicitly:

```
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
1. Explicit slash command → read only the matching command file.
2. For ambiguous natural-language work, load `using-agent-skills` first and select the smallest useful skill before choosing agents.
3. Otherwise use `graph-router` / Graphify-first candidate ranking.
4. Fall back to `~/.config/opencode/config/routing.json` when confidence is low, the request is ambiguous, or policy/security gates apply.
5. Load only the smallest useful agent, KB, or local repo context.

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

## Execution Heuristic

- Repo/file discovery, reference checks, validation → use search tools and parallel reads.
- Shared routing, config, or instruction edits → serialize writes.
- External behavior may have changed → use MCP, web, or official docs.
- Security/commit/secret handling → route through `dev.security-guardian` and the security settings file.
- Workflow phases → use native workflow commands only.
- Missing or ambiguous references → validate existence before loading or editing.

## Reference Policy

- Keep canonical content in the owning agent, skill, KB, knowledge context, or SDD file.
- This entrypoint should route to those files, not duplicate them.

## Project Docs

- `docs/AGENTIC_GAP_DOSSIER.md` is the running audit and upgrade rationale for the harness.
- `docs/tasks/README.md` and `docs/tasks/phase-*.md` are execution checklists, not source-of-truth policy.
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml` remains the canonical workflow contract.
