# AgentSpec for OpenCode

This global OpenCode setup is rooted at `~/.config/opencode`. Use it as a lightweight orchestration layer: classify intent, load the smallest useful context, and route to agents, commands, skills, KB, knowledge context, SDD, MCP, or shell only when required.

## Global Policies

Two policies apply to every SDD phase:

| Policy | Rule | Contract Reference |
|---|---|---|
| **Write-then-Copy** | Every SDD artifact is written to `~/.config/opencode/sdd/features/{feature-name}/` first, then copied flat to `./specs/{PHASE}_{FEATURE}.md`. Never write the local artifact separately and never create feature subfolders under `./specs/`. | `artifact_storage` in `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| **Build Output Gate** | At the start of every `/workflow:build`, ask the user where generated code must be written before loading design context or creating files. There is no default output path and it must not be read from `DESIGN`. | `build_output_gate` in `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |

## Routing Flow

1. Classify the request: command, implementation, review, research, planning, documentation, KB/context, SDD, security, or general help.
2. If the user invokes a native command such as `/workflow:brainstorm`, `/workflow:build`, `/knowledge:create-kb`, `/review:review`, `/core:meeting`, or `/data:schema`, read only that command file under `~/.config/opencode/commands/`, then load the referenced skill and specialist files on demand.
3. Otherwise consult `~/.config/opencode/config/routing.json`, choose the smallest deterministic route, and load only the matched agent file.
4. Load KB, knowledge context, or SDD files lazily and only when they directly affect the task.
5. Use local repository instructions such as `AGENTS.md`, `COPILOT.md`, `_meta/STATUS.md`, or `_meta/CONTEXT.md` only when they exist and are relevant to the active workspace.
6. Use MCP, web, or shell when local context is stale, missing, version-sensitive, or insufficient for correctness.

## Route Hints

| Task signal | Route | Context to load | Avoid |
|---|---|---|---|
| Native slash command | `~/.config/opencode/commands/<command>.md` | Command file, referenced skill, referenced agent only if needed | Intent routing before the explicit command |
| Agent/domain intent | `~/.config/opencode/config/routing.json` | Matched route agent and listed KB entry points | Loading every agent or full KB trees |
| SDD lifecycle | `/workflow:brainstorm`, `/workflow:define`, `/workflow:design`, `/workflow:build`, `/workflow:validate`, `/workflow:ship`, `/workflow:iterate`, `/workflow:create-pr` | Workflow command, workflow skill, contract, phase agent | Starting phases by direct agent invocation |
| KB creation/update/audit | `/knowledge:create-kb`, `/knowledge:update-kb`, `/knowledge:refresh-stale-kbs` | Target KB domain files, templates, registry | Preloading the entire KB |
| Knowledge context setup/audit | `/context:create-context`, `/context:update-context`, `/context:check-context` | Active project context only | Loading all project contexts |
| Review or judge | `/review:review`, `/review:judge` | Target files and review/review:judge agent | Generic summaries before findings |
| Security, commits, secrets | `dev.security-guardian` | Diff, staged files, security settings | Commit or secret handling without policy checks |
| Ambiguous large task | `architect.the-planner` | Minimal project inventory first | Large multi-file execution without decomposition |

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

| Situation | Use |
|---|---|
| Repo/file discovery, reference checks, validation | Shell or built-in search tools; parallelize reads |
| Multiple independent read-only questions | Parallel file reads/searches |
| Shared routing, config, or instruction edits | Serialized writes |
| External behavior may have changed | MCP, web, or official docs |
| High-risk security, commit, or secret handling | `dev.security-guardian` and `~/.config/opencode/config/security-settings.json` |
| SDD phase execution | Native workflow commands only |
| Missing or ambiguous references | Validate existence before loading or editing |

## Reference Policy

- Keep canonical content in the owning agent, skill, KB, knowledge context, or SDD file.
- This entrypoint should route to those files, not duplicate them.
