# Grounding Index

## Purpose

This file is the lightweight grounding index for the OpenCode harness. It is no longer the policy source of truth.

Use it to find the smallest governing contract for the current task, then load only the referenced file(s) needed for that task.

## Authority

Policy authority is split across `.specs/shared/` contracts.

| Concern | Owning contract |
| --- | --- |
| runtime enforcement posture | `.specs/shared/runtime-policy.md` |
| context loading and token discipline | `.specs/shared/context-loading-policy.md` |
| active state and precedence | `.specs/shared/state-resolution-contract.md` |
| state conflict handling | `.specs/shared/state-conflict-resolution-policy.md` |
| phase semantics and gates | `.specs/shared/phase-engine-contract.md` |
| execution loop / Ralph Loop | `.specs/shared/execution-loop-contract.md` |
| documentation density | `.specs/shared/documentation-mode-policy.md` |
| code generation posture | `.specs/shared/production-code-mode-policy.md` |
| legacy command and skill compatibility | `.specs/shared/compatibility-policy.md` |
| structured user clarification | `.specs/shared/ask-user-policy.md` |
| todo projection | `.specs/shared/todo-allocation-contract.md` |
| allocation ownership | `.specs/shared/allocation-contract.md` |
| global allocation | `.specs/shared/global-allocation-contract.md` |
| local allocation | `.specs/shared/local-allocation-contract.md` |
| specialist allocation | `.specs/shared/specialist-allocation-contract.md` |
| MCP posture | `.specs/shared/mcp-governance.md` |
| security guardrails | `.specs/shared/security-guardrails.md` |
| rollback | `.specs/shared/rollback-policy.md` |
| definition of done | `.specs/shared/definition-of-done.md` |
| Markdown authoring | `.specs/shared/markdown-authoring-standard.md` |

## Default Loading Path

```text
1. Read current user request.
2. Read `.specs/memory/active-state.md` when the task is repo/project-stateful.
3. Load the active change/task contract when one exists.
4. Load only the shared contract(s) matching the task concern.
5. Load commands, skills, agents, KB, or SDD files only when selected by route or referenced by the active task.
```

## Coordinator Defaults

| Request shape | Preferred owner |
| --- | --- |
| durable strategic change, roadmap, PRD, ADR, TEST-SPEC, architecture plan | Altitude |
| tactical SQL, pipeline, schema, data quality, Fabric/GCP/Airflow/Dataform work | Data Engineer |
| final architecture diagram or visual artifact | `visual:*` |
| README generation/update | `core:readme-maker` |
| explicit `/workflow:*` invocation | compatibility path through `.specs/shared/compatibility-policy.md` |

## Legacy Compatibility

Legacy workflow and SDD references are migration-only unless a user explicitly invokes a native workflow command.

`/workflow:*` commands may remain as compatibility wrappers, but they do not own Harness V3 state or phase semantics. Use `.specs/shared/phase-engine-contract.md` and `.specs/shared/state-resolution-contract.md` for durable work.

## Runtime Enforcement Rule

Do not claim a rule is runtime-enforced unless the active runtime, plugin, tool, or test proves it.

If enforcement is unavailable, say so and follow the manual contract path from `.specs/shared/runtime-policy.md`.

## Language Policy

User interaction may be Portuguese or English, but durable harness artifacts default to English unless an active task says otherwise.

## Minimal Diagnostics

Do not emit full grounding diagnostics by default. Report loaded files, route decisions, or token/context details only when they help planning, debugging, validation, auditability, or the user explicitly asks.
