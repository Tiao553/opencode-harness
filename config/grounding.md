# Legacy Policy Reference — GitHub Copilot AgentSpec

This file preserves reusable execution policies for the `~/.copilot` runtime. It is no longer a mandatory every-response grounding file. Load it only when a task needs permissions policy, SDD gates, security constraints, or historical workflow behavior.

Use lightweight context selection instead:

1. If the message invokes a command skill, read `~/.config/opencode/skills/<name>/SKILL.md` and the referenced command file.
2. If no command skill is invoked, consult `~/.config/opencode/config/routing.json` and identify the smallest matching agent route.
3. Read the selected agent file only after the route is known.
4. Load KB files lazily:
   - Prefer route `kb` entries, usually `index.md` or `quick-reference.md`.
   - Load `kb_full` or detailed `concepts/` and `patterns/` files only when the lightweight entry is insufficient.
   - Keep the default maximum at 3 KB files per request.
5. Load knowledge context only when the task is project-specific and the registry has an active project.
6. If no route matches, use `default_agent` from `routing.json`.

Emit a lightweight active-specialist header for operational work:

```markdown
> **Specialist Activated:** `<agent-or-skill-name>`
> **Path:** `<~/.config/opencode/... or none>`
```

Do not emit the old full grounding table by default. Show loaded files, token counts, or detailed diagnostics only when useful for planning, debugging, validation, or user-requested traceability.

## Permissions Policy

When `~/.config/opencode/config/security-settings.json` exists and the task involves shell, tools, writes, commits, secrets, infrastructure, or external systems, apply it as an execution gate.

The agent must apply `permissions` as an execution gate:

- `alwaysAllow`: commands and tools considered safe for inspection, local validation, and reading. Can be executed without requesting new confirmation, respecting the active sandbox.
- `alwaysAsk`: commands that change state, dependencies, Git history, environment, containers, or files outside controlled edits. Must request explicit approval before executing.
- `alwaysDeny`: destructive commands, high-risk database operations, irreversible Git cleanup, force push/reset, dangerous system changes, services, registry, or processes. Must be refused unless the user explicitly requests with precise scope and an additional confirmation.

Application rules:

- The match must consider the full command and its arguments, not just the binary.
- When in doubt between categories, use the most restrictive category.
- Chained commands must be evaluated per segment; if any segment falls under `alwaysAsk` or `alwaysDeny`, the entire execution must follow the most restrictive category.
- The policy does not replace the sandbox, environment approvals, or agent security rules; it adds a mandatory layer.
- Manual edits via editing tools follow the same intent: edits within the workspace are allowed when they are part of the task; destructive edits, broad reversions, or removals must be treated as `alwaysAsk` or `alwaysDeny` based on risk.

## Skill Priority

When the input contains `/<name>`, the corresponding `SKILL.md` is the primary execution source. The agent route cannot override skill instructions.

Recommended order with skill:

```text
1. ~/.config/opencode/skills/<name>/SKILL.md
2. Skill command file
3. Agent files declared by the skill
4. KB/context/SDD files declared by the skill, lazily
5. ~/.config/opencode/config/security-settings.json when risk requires it
6. ~/.config/opencode/config/routing.json only for complementary routing
```

If the cited skill does not exist at `~/.config/opencode/skills/<name>/SKILL.md`, stop and report the missing path. Do not execute the flow as a generic request.

## SDD Workflow Initialization

SDD workflow phases (`/workflow:brainstorm`, `/workflow:define`, `/workflow:design`, `/workflow:build`, `/workflow:validate`, `/workflow:ship`, `/workflow:iterate`, `/workflow:create-pr`) can only be initialized via:

```text
/workflow:<phase> ...
```

Natural language requests such as "do the build", "run the design", "ship this feature", or "create the define phase" must be treated as incomplete intent. Respond with the exact expected command and do not start the phase.

Exception: it is allowed to directly edit SDD documents when the user requests a specific change to a named file, without starting a workflow phase.

## Response Language Policy

- All assistant responses must be in English only.
- The assistant may read and interpret user requests written in any language, but the reply must remain in English.
- Preserve code, file paths, commands, logs, and user-provided literals in their original form when needed.

Include the lightweight active-specialist header in operational responses. Add full route or grounding diagnostics only when they clarify planning, debugging, validation, or explicit user-requested traceability.

## Agent Execution Loop (Ralph Loop)

When an agent task involves file generation, code editing, or validation, use the Ralph Loop as a bounded execution protocol when the active skill, route, or SDD contract requires traceable iteration.

### Loop Protocol

```text
┌─────────────────────────────────────────────────────────────┐
│                      RALPH LOOP (max 6 iterations)          │
│                                                             │
│  1. READ    → Read current file state + errors + output     │
│  2. ACT     → Write / edit / run command                    │
│  3. LOOP    → Observe result: done? → exit / else continue  │
│  4. PLAN    → Reformulate if output ≠ expected              │
│  5. HANDLE  → Catch failure → retry, replan, or escalate    │
└─────────────────────────────────────────────────────────────┘
```

### Loop Gates (Analysis Checkpoints)

Each iteration must pass the following gates before proceeding to the next:

| Gate | Trigger | Check | Action on Failure |
|---|---|---|---|
| **G1 — Syntax** | After every file write | `get_errors` returns `[]` | Fix syntax → retry (same iteration) |
| **G2 — Lint** | Iterations 1, 3, 5 | No lint warnings in errors | Fix lint → continue loop |
| **G3 — Test** | After every terminal run | Exit code `0` + no FAIL lines | Diagnose → replan → next iteration |
| **G4 — Contract** | Iterations 2, 4, 6 | Output matches WORKFLOW_CONTRACTS schema | Adjust against contract → continue |
| **G5 — Regression** | Final iteration only | Previously passing tests still pass | Rollback last edit → escalate |
| **G6 — Escalation** | Iteration limit reached (6) | Any gate still failing | Write BLOCKER to report → halt phase |

### Loop Execution Rules

- `max_iterations: 6` — hard limit per file or task unit
- After iteration 3, log a **Mid-Loop Analysis** entry: what changed, what still fails, revised plan
- After iteration 6 with failures, write a `BLOCKER` entry in the phase report — do **not** silently continue
- If G5 (regression) fails, do not proceed to next file — escalate immediately
- Loop evidence must be recorded in `BUILD_REPORT` or `VALIDATION_REPORT` as `loop_trace`

### Loop Evidence Format (append to phase report)

```markdown
### Loop Trace — {file or task}
| Iter | Gate | Result | Action Taken |
|------|------|--------|--------------|
| 1    | G1   | FAIL   | Fixed missing import |
| 2    | G1,G4| PASS   | Continued |
| 3    | G3   | FAIL   | Test expected 200, got 404 — replanned endpoint |
| 4    | G1,G3| PASS   | Clean |
```

---

## Token Budget Strategy

| Situation | Action |
|---|---|
| Simple conceptual question | Only `quick-reference.md` from the relevant KB |
| Implementation with known pattern | `quick-reference.md` + specific pattern file |
| Complex implementation / new domain | `index.md` + up to 3 files from `concepts/` or `patterns/` |
| Multi-domain task | `quick-reference.md` from each domain (max 3 domains) |
| Large Task / full SDD | Use `the-planner` to break into subtasks with individual budgets |

Never load an entire KB directory in a single call.
Declare loaded files only when that trace helps planning, debugging, validation, or auditability.

## Response Compression Policy

- Prefer references to canonical files instead of restating their full content.
- Summarize only the delta between files when comparing documentation.
- Do not reproduce long command tables or workflow tables when a file reference is sufficient.
- Keep final answers to the smallest format that fully resolves the request: short paragraphs by default, lists only when the content is inherently list-shaped.
- When reporting edits, group changes by purpose instead of by file unless file-level detail is necessary.
- For technical work, inspect the minimum file set needed to answer or act; expand only when blocked.
- Reuse the active route KB quick-reference before loading any broader KB material.
- If the user asks for a plan, provide a compact phased plan first and avoid full implementation detail unless requested.

## Rules

- Do not respond from memory when required files must be inspected
- Do not emit full grounding diagnostics unless they are useful or requested
- Do not ignore `/<name>`; skill takes priority over intent-based routing
- Do not start SDD phases without `/<phase>`
- Do not assume project context without checking `_meta/` and `~/.config/opencode/knowledge_context/_registry.yaml`
- Do not load full KB when quick-reference is sufficient
- Do not start BUILD without SDD gates verified when applicable
- Always prefer `COPILOT.md` as the canonical source if there is a conflict
- **Before suggesting `git commit`, always run `pre-commit run --all-files` as a security gate** — CRITICAL findings block the commit; delegate to `dev.security-guardian` when the context involves commits, secrets, or code auditing
