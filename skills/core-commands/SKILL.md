---
name: core-commands
description: Reusable core guidance for the native commands /core:meeting, /core:memory, /core:readme-maker, /core:status, and /core:sync-context. Load this skill when running project utility commands.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 3.0.0
  category: commands
  migrated-from: ~/.config/opencode/skills/core-commands/commands/
---

# Core Commands

This skill standardizes utility commands so they run as repeatable workflows instead of a thin registry.

## When to Use

- Use for `/core:meeting`, `/core:memory`, `/core:readme-maker`, `/core:status`, and `/core:sync-context`.
- Use when the work is project utility work rather than delivery-phase execution.
- Do not use to start SDD phases.

## Workflow

1. Read the requested command file under `commands/`.
2. Load only the supporting agent and context required by that command.
3. Keep storage writes in `~/.config/opencode/storage/` and documentation writes in the project paths required by the command.
4. Stop if the command depends on a missing agent, storage path, or artifact instead of inventing a substitute flow.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "All core commands can use the same generic context." | Utility commands differ in storage, output format, and evidence needs. |
| "If an agent is missing, a nearby one is probably fine." | Silent substitution makes the utility command non-deterministic. |
| "This is close enough to workflow execution." | Core commands should stay outside SDD phase logic. |

## Red Flags

- The command starts an SDD phase.
- Storage writes happen outside `~/.config/opencode/storage/` with no reason.
- The command file is skipped and the agent is chosen heuristically.
- A missing dependency is silently replaced.

## Verification

- [ ] The requested command file was read.
- [ ] Only the needed agent and context were loaded.
- [ ] Storage and output paths match the command intent.
- [ ] No SDD phase was initiated from this skill.
- [ ] Missing dependencies were reported explicitly.
