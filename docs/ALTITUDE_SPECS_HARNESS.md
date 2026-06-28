# Altitude Specs Harness

## Current State

The harness is an OpenCode operating layer rooted at `~/.config/opencode`. It now has two complementary systems:

- `sdd/` is the reusable global method for spec-driven workflow contracts, templates, and gates.
- `.specs/` is the project-local execution ledger for real changes, tasks, evidence, state, memory, reports, and archive.

Preferred operation is agent-first through:

- `altitude-intent`
- `altitude-structure`
- `altitude-plan`
- `altitude-execution`
- `altitude-validation`
- `altitude-report`
- `altitude-memory`

Commands remain available as a compatibility layer, especially for existing `/workflow:*`, `/data:*`, `/review:*`, `/knowledge:*`, `/context:*`, and `/visual:*` habits.

## Gap Analysis

Closed by this migration:

- Added altitude primary agents.
- Added `.specs/shared` contracts.
- Added `.specs/templates` templates.
- Made altitude agents available through explicit selection and route triggers without overriding OpenCode's runtime default.
- Added fallback routing entries for altitude agents.
- Added plugin scaffolds for altitude context, specs state, RTK, Headroom, and context budget.
- Updated permission-hardening policy for altitude agents.
- Marked commands as compatibility surface in docs.

Still runtime-dependent:

- `specs-state.ts` cannot hard-block edits until the OpenCode plugin runtime exposes a stable pre-tool state hook.
- `rtk-native.ts` records safe rewrite policy, but shell-command interception requires a runtime hook.
- `context-budget.ts` records budget policy, but token/read telemetry requires runtime support.
- Headroom remains optional and falls back safely when not configured.

## Operating Contract

The user operates high. The agent descends deliberately.

```text
Intent -> Structure -> Decomposition -> Execution -> Validation -> Report -> Memory
```

No complex execution may skip Intent, Structure, and Decomposition.

## Change Request Structure

```text
.specs/changes/<id-slug>/
  00-intent.md
  01-structure.md
  02-decomposition.md
  03-execution-ledger.md
  04-validation.md
  05-executive-report.md
  06-ship-note.md
  state.md
  CHANGELOG.md
  tasks/
  decisions/
  evidence/
  reviews/
```

## Execution Gate

`altitude-execution` must not edit source unless:

- an active change exists
- an active task exists
- `change.status` is `ready_for_execution` or `in_execution`
- `task.status` is `ready`
- allowed files are defined
- forbidden scope is defined
- acceptance criteria are defined
- verification commands are defined
- evidence is required

## Validation Gate

`altitude-validation` can mark a task `validated` only when:

- acceptance criteria are met
- verification ran or failure is justified
- evidence is saved
- changed files stay inside allowed scope
- forbidden scope was not touched
- no contract changed without a decision record

## RTK Strategy

RTK is for tool-output compression, not planning.

Use RTK for safe verbose commands:

- `rtk git status`
- `rtk git diff`
- `rtk rg`
- `rtk ls`
- `rtk test <command>`

Never rewrite destructive commands automatically.

## Headroom Strategy

Headroom is optional until validated in the active runtime.

If compressed mode is requested and Headroom is unavailable, warn and use the normal provider path.

## MCP Governance

MCPs are exceptions, not defaults:

- `altitude-intent`: deny
- `altitude-structure`: ask for code graph or docs
- `altitude-plan`: ask for current docs
- `altitude-execution`: ask when framework/API recency matters
- `altitude-validation`: deny or ask
- `altitude-report`: deny external MCP
- `altitude-memory`: deny

No remote MCP with credentials without explicit approval.

## Migration Notes

Old concept mapping:

| Old | New |
| --- | --- |
| `specs/workflows/<feature>/00-brief.md` | `.specs/changes/<change>/00-intent.md` |
| `specs/workflows/<feature>/01-prd.md` | `.specs/changes/<change>/00-intent.md` and `01-structure.md` |
| `specs/workflows/<feature>/02-sdd.md` | `.specs/changes/<change>/01-structure.md` |
| `specs/workflows/<feature>/03-tst.md` | `.specs/changes/<change>/02-decomposition.md` and task criteria |
| `specs/workflows/<feature>/tasks/` | `.specs/changes/<change>/tasks/` |
| `specs/workflows/<feature>/evidence/` | `.specs/changes/<change>/evidence/` |
| `specs/workflows/<feature>/08-executive-report.md` | `.specs/changes/<change>/05-executive-report.md` |
| `specs/codebase/` | `.specs/memory/` |

## Validation Checklist

- [ ] `opencode.json` loads the altitude agent definitions and plugin chain without a custom `default_agent`.
- [ ] Each altitude agent is available in `agents/`.
- [ ] `config/routing.json` includes altitude routes.
- [ ] `.specs/shared` and `.specs/templates` are versionable.
- [ ] `.specs/changes`, `.specs/memory`, `.specs/archive`, and `.specs/reports` are ignored by default.
- [ ] Execution refuses to proceed without one ready task.
- [ ] Validation rejects scope expansion.
- [ ] Reports can be generated from artifacts without chat history.
