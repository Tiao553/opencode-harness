---
name: workflow-commands
description: Reusable workflow guidance for the native commands /workflow:brainstorm, /workflow:define, /workflow:design, /workflow:build, /workflow:validate, /workflow:ship, /workflow:iterate, and /workflow:create-pr. Load this skill when executing an SDD phase or validating workflow policy.
license: MIT
compatibility: GitHub Copilot VS Code, GitHub Copilot cloud agent
metadata:
  version: 2.0.0
  category: commands
  legacy-source: claude workflow commands
---

# Workflow Commands

This skill carries the cross-phase rules for native workflow commands. Per-phase process lives in the phase skills or command-specific workflow files, not here.

## When to Use

- Use when a native `/workflow:*` command is already active.
- Use to enforce global workflow policy before loading the phase-specific process.
- Do not use as a generic router for natural-language requests.

## Workflow

1. Confirm that a native `/workflow:*` command triggered the work.
2. Read `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml` before executing any phase.
3. Apply the cross-phase rules that always matter:
   - command-first execution
   - canonical artifact paths
   - write global artifact first, then copy flat to `./specs/`
   - phase gates cannot be skipped silently
4. Load only the phase-specific workflow source needed next:
   - `/workflow:define` → `~/.config/opencode/skills/workflow-define/SKILL.md`
   - `/workflow:design` → `~/.config/opencode/skills/workflow-design/SKILL.md`
   - other phases → the matching command-specific file under `skills/workflow-commands/commands/`
5. Load the phase agent file only after the phase workflow has been selected.
6. If a gate fails, stop and name the exact missing file or unmet condition.

## Cross-Phase Rules

- Workflow phases must be started by native commands.
- `WORKFLOW_CONTRACTS.yaml` is the canonical source for gates, inputs, outputs, transitions, and path rules.
- Feature artifacts live under `~/.config/opencode/sdd/features/{feature-name}/` first.
- Local mirrors under `./specs/` are copies, not separate writes.
- `/workflow:build` still asks the user for output path at runtime.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "The phase is obvious, so I can skip the native command." | Native workflow commands are the contract boundary. |
| "The local mirror is enough." | The global artifact is the system of record. |
| "I can keep phase logic here for convenience." | Cross-phase rules belong here; phase logic belongs in dedicated skills. |

## Red Flags

- A phase is started from generic routing instead of a native command.
- The agent is selected before reading the workflow contract.
- A phase-specific workflow is duplicated here instead of in its own skill.
- An artifact is written directly to `./specs/` without a global source artifact.

## Verification

- [ ] A native `/workflow:*` command triggered execution.
- [ ] `WORKFLOW_CONTRACTS.yaml` was read before phase execution.
- [ ] The phase-specific workflow source was loaded after the contract.
- [ ] Global artifact write happened before any local mirror copy.
- [ ] Any gate failure was surfaced explicitly instead of bypassed.
