---
name: data-engineering
description: Reusable data-engineering guidance for the native commands /data:ai-pipeline, /data:data-contract, /data:data-quality, /data:lakehouse, /data:migrate, /data:pipeline, /data:schema, and /data:sql-review. Load this skill when routing specialist data work.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 2.0.0
  category: commands
  migrated-from: ~/.config/opencode/skills/data-engineering/
---

# Data-Engineering Commands

This skill standardizes specialist data work as workflows with lazy KB loading, explicit escalation, and verification.

## When to Use

- Use for `/data:*` commands.
- Use when the task is primarily about data pipelines, schemas, contracts, quality, SQL review, or lakehouse decisions.
- Do not use to start SDD phases.

## Workflow

1. Read the requested `/data:*` command file.
2. Load the primary specialist agent for that command.
3. Start KB loading from the smallest relevant `quick-reference.md` files only.
4. Escalate cross-domain only when the primary workflow cannot complete the task safely.
5. If the task is happening during build, keep generated code under `{output_path}/`.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "Loading the whole KB domain is easier." | Full-domain loading breaks the lazy-context rule and adds noise. |
| "Any nearby data specialist can probably answer this." | Data commands should stay aligned to the requested workflow first. |
| "Cross-domain escalation is harmless." | Unnecessary escalation creates conflicting guidance and larger context. |

## Red Flags

- A `/data:*` command starts by loading multiple full KB domains.
- Cross-domain escalation happens before the primary specialist is tried.
- The command drifts into workflow phase execution.
- Build-context code output ignores `{output_path}/`.

## Verification

- [ ] The command-specific file was read.
- [ ] The primary specialist agent was selected first.
- [ ] KB loading started from relevant quick references only.
- [ ] Any escalation was justified by a concrete cross-domain need.
- [ ] Build-context outputs stayed under `{output_path}/` when applicable.
