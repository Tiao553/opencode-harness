# OpenCode Personal Config

> Reusable OpenCode configuration with command entrypoints, specialist agents, KB grounding, and AgentSpec workflow assets.

## Overview

This repository is a shareable OpenCode setup rooted in `~/.config/opencode/`. It is not an application codebase in the usual sense. Instead, it defines how OpenCode should route work, which agents are available, how command families behave, which knowledge domains can be consulted, and how spec-driven delivery is executed from requirements through validation.

The workspace combines six layers:

- command entrypoints in `commands/`
- reusable execution skills in `skills/`
- specialist agent definitions in `agents/`
- routing, security, and grounding policy in `config/`
- audit and implementation guidance in `docs/`
- AgentSpec workflow documentation and templates in `sdd/`

This makes the directory useful both as a personal operating layer and as a reusable baseline for teams that want a structured OpenCode environment with stronger routing, review, and delivery conventions.

## What This Repo Optimizes For

- deterministic routing through `config/routing.json`
- lazy context loading instead of preloading everything
- specialized execution through focused agents rather than one generic assistant
- spec-driven delivery through the AgentSpec workflow in `sdd/`
- privacy-first local state management through a restrictive `.gitignore`
- strong coverage for data engineering, review, and workflow orchestration use cases

## Repository Layout

| Path | Purpose |
| --- | --- |
| `AGENTS.md` | Global orchestration entrypoint and routing policy for this setup |
| `agents/` | Specialist agent definitions across workflow, architecture, cloud, platform, Python, testing, and data engineering |
| `commands/` | Native slash-command entrypoints such as `workflow:*`, `data:*`, `core:*`, `review:*`, `knowledge:*`, `context:*`, and `visual:*` |
| `config/` | Shared configuration including routing, security defaults, and grounding guidance |
| `docs/` | Audit dossier, phased implementation checklists, and other project-level documentation artifacts |
| `kb/` | Curated knowledge-base domains used to ground specialist work |
| `skills/` | Reusable command and workflow skills that standardize how commands execute |
| `plugins/` | Runtime config plugins that enforce behavior such as permission hardening |
| `sdd/` | AgentSpec documentation, templates, contracts, and local feature lifecycle artifacts |
| `knowledge_context/` | Local per-project context artifacts and templates |
| `storage/` | Local persistent memory and runtime storage |
| `opencode.json` / `opencode.jsonc` | OpenCode runtime configuration, including default agent and MCP wiring |

## Command Surface

The `commands/` folder currently exposes 37 slash-command entrypoints. They are grouped by intent instead of by implementation language.

| Family | Examples | Purpose |
| --- | --- | --- |
| Workflow | `/workflow:brainstorm`, `/workflow:define`, `/workflow:design`, `/workflow:build`, `/workflow:validate`, `/workflow:ship`, `/workflow:iterate`, `/workflow:create-pr` | Execute the full spec-driven delivery lifecycle |
| Data | `/data:pipeline`, `/data:schema`, `/data:data-quality`, `/data:lakehouse`, `/data:sql-review`, `/data:ai-pipeline`, `/data:data-contract`, `/data:migrate` | Access specialist data engineering workflows |
| Core | `/core:meeting`, `/core:memory`, `/core:readme-maker`, `/core:status`, `/core:sync-context` | Project utility commands |
| Review | `/review:review`, `/review:judge`, `/review:diff-review`, `/review:fact-check`, `/review:plan-review` | Review, validation, and second-opinion flows |
| Knowledge | `/knowledge:create-kb`, `/knowledge:update-kb`, `/knowledge:refresh-stale-kbs` | Knowledge-base authoring and maintenance |
| Context | `/context:create-context`, `/context:update-context`, `/context:check-context` | Project context management |
| Visual | `/visual:generate-web-diagram`, `/visual:generate-visual-plan`, `/visual:project-recap`, `/visual:generate-slides`, `/visual:share` | Visual explanation and presentation helpers |

The command files are thin entrypoints. The real behavior lives in the referenced skill docs and the selected specialist agents.

## Header Standards

All registrable Markdown artifacts in this repo should start with YAML frontmatter and a single top-level `H1` in the body.

- `agents/*.agent.md`: use `name`, `description`, `mode`, optional `model`, and `permission` in frontmatter, then start the body with `# <Display Name>`.
- `commands/*.md`: use `description`, optional `agent`, and optional `subtask` in frontmatter, then start the body with `# /namespace:command Command`.
- `skills/*/SKILL.md`: use `name`, `description`, optional `license`, `compatibility`, and `metadata` in frontmatter, then start the body with `# <Display Name>`.
- `skills/*/commands/*.md`: use `name` and `description` in frontmatter, then start the body with `# <Display Name> Command`.

This keeps the OpenCode loader metadata predictable and makes command, skill, and agent files easier to scan and maintain.

## AgentSpec Workflow

The `sdd/` directory documents a validated Spec-Driven Development workflow branded here as AgentSpec.

```text
Brainstorm -> Define -> Design -> Build -> Validate -> Ship
```

The workflow is intentionally explicit:

- `Brainstorm` is optional and used to clarify vague ideas
- `Define` captures requirements and technical context
- `Design` creates the architecture, file manifest, and agent assignments
- `Build` executes the implementation
- `Validate` is a mandatory quality gate before shipping
- `Ship` archives approved outcomes and lessons learned

Key references:

- `sdd/_index.md` for the compact workflow overview
- `sdd/README.md` for the full framework explanation
- `sdd/architecture/WORKFLOW_CONTRACTS.yaml` for workflow contracts and gates
- `sdd/templates/` for canonical artifact templates

## Routing, Grounding, and Execution Model

The repository uses a layered control model rather than a single monolithic prompt.

| File | Role |
| --- | --- |
| `AGENTS.md` | Global routing and execution policy |
| `docs/AGENTIC_GAP_DOSSIER.md` | Audit record and phased upgrade rationale |
| `docs/tasks/` | Phase-by-phase implementation checklists derived from the dossier |
| `config/routing.json` | Intent-to-agent routing map with lazy KB loading |
| `config/security-settings.json` | Command safety profile and approval behavior |
| `config/grounding.md` | Additional grounding policy for high-risk or policy-sensitive situations |
| `plugins/permission-hardening.ts` | Runtime permission enforcement and agent authority shaping |
| `opencode.json` / `opencode.jsonc` | Local runtime config, including default agent and MCP configuration |

In practice, commands route to the smallest useful context first, then load deeper instructions only when the current task actually needs them.

## Skills and Agents

Two concepts do most of the orchestration work in this repo:

- `skills/` standardize reusable behavior for command families such as `core-commands`, `workflow-commands`, `review`, `knowledge`, and `data-engineering`
- `agents/` define specialist capabilities such as codebase exploration, code review, SQL optimization, Spark troubleshooting, cloud architecture, dashboard layout, and workflow execution

This separation keeps high-level command behavior stable while allowing specialist implementation logic to evolve independently.

## Privacy-First Versioning

The root `.gitignore` is intentionally restrictive.

- it ignores everything by default
- it explicitly re-allows only reusable framework files
- it keeps local memory, runtime state, generated workflow outputs, package-manager noise, and common secret patterns out of version control

### Safe To Share

These paths are intended to be versioned when they are generic and sanitized:

- `AGENTS.md`
- `agents/`
- `commands/`
- `config/`
- `docs/`
- `kb/`
- `plugins/`
- `opencode.json`
- `opencode.jsonc`
- `skills/`
- `sdd/architecture/`
- `sdd/templates/`
- `sdd/README.md`
- `sdd/_index.md`

### Kept Local

These paths are ignored because they can contain personal context, generated artifacts, or runtime state:

- `package.json`
- `package-lock.json`
- `node_modules/`
- `storage/`
- `knowledge_context/`
- `sdd/features/`
- `sdd/archive/`
- `sdd/reports/`
- `.env*`
- `*.local`
- `*.log`

## Working On This Config

If you want to extend this setup, the usual paths are straightforward:

1. Add or update a slash command in `commands/`.
2. Attach the command to the right reusable skill in `skills/`.
3. Add or update the specialist agent in `agents/`.
4. Update `config/routing.json` if natural-language routing should discover it.
5. Add KB references only when the workflow needs grounding.
6. Keep the root docs aligned when command behavior or workflow contracts change.

## Current Scope and Caveats

- This workspace is primarily documentation, routing, and orchestration configuration.
- The root `package.json` is minimal and only declares the local `@opencode-ai/plugin` dependency.
- There is no obvious root-level executable test suite declared in `package.json`.
- Runtime state and per-project memory are intentionally local, not part of the reusable framework surface.

## Before Publishing

Run a quick review before pushing this directory anywhere:

1. Check tracked files with `git status`.
2. Inspect exactly what would be committed with `git diff --cached`.
3. Confirm `config/` and `kb/` do not contain tokens, URLs with credentials, private project names, or customer-specific content.
4. Confirm any examples in docs are templates or sanitized samples rather than live project state.
5. Review `.gitignore` if you introduced any new top-level folders that should remain private.

## Notes

- New top-level folders are ignored unless they are explicitly allowed in `.gitignore`.
- That behavior is intentional: local additions should stay private by default until they are consciously promoted into the reusable framework.
