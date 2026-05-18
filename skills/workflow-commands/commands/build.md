---
name: build
description: Execute implementation with on-the-fly task generation (Phase 3)
---

# Build Command

> Execute implementation with on-the-fly task generation (Phase 3)

## Usage

```bash
/workflow:build <design-file>
```

## Examples

```bash
/workflow:build ~/.config/opencode/sdd/features/notification-system/DESIGN_NOTIFICATION_SYSTEM.md
/workflow:build DESIGN_USER_AUTH.md
```

---

## Overview

This is **Phase 3** of the 5-phase AgentSpec workflow:

```text
Phase 0: /workflow:brainstorm → ~/.config/opencode/sdd/features/{feature-name}/BRAINSTORM_{FEATURE}.md (optional)
Phase 1: /workflow:define     → ~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md
Phase 2: /workflow:design     → ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md
Phase 3: /workflow:build      → Code in {output_path}/ (asked at Step 0) + ~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md (THIS COMMAND)
Phase 3.5: /workflow:validate → ~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md
Phase 4: /workflow:ship       → ~/.config/opencode/sdd/archive/{feature-name}/SHIPPED_{DATE}.md
```

The `/workflow:build` command executes the implementation, generating tasks on-the-fly from the file manifest.

---

## What This Command Does

1. **Parse** - Extract Implementation Chunks from DESIGN
2. **Plan & Task** - ALWAYS create/update `implementation_plan.md` and `task.md` with extreme depth
3. **Isolate** - Identify the next `⏳ Pending` chunk
4. **Execute** - Create files for that specific chunk with verification
5. **Persist State** - ALWAYS update `~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md` after every file/interaction
6. **Report** - Finalize chunk status in the report and STOP

---

## Process

### Step 0: Resolve Output Path (Gate — BLOCKING, runs before anything else)

**STOP. Do NOT load context, do NOT read DESIGN, do NOT create any file.**

Use the `question` tool IMMEDIATELY with this question:

```text
"Where should the generated code and scripts be written? (enter the relative or absolute path)"
```

Rules:

- Do NOT suggest `./projects/` or any default path
- Do NOT read `output_path` from DESIGN metadata — this question is always asked, unconditionally
- Wait for the user's explicit answer before doing anything else
- Save the answer to `./specs/BUILD_OUTPUT_PATH.txt`
- Print: `> Build target confirmed: {user_answer}`
- Only then proceed to Step 1

> **There is no default.** Every `/workflow:build` invocation must ask. No reading DESIGN. No inference. No fallback.

---

### Step 1: Load Context

```markdown
Read(~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md)
Read(~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md)
Read(~/.config/opencode/AGENTS.md)
```

### Step 2: Planning & Task Extraction (Mandatory)

Before writing any code, you MUST generate or update two critical artifacts in the conversation's artifact directory:

1. **`implementation_plan.md`**:
   - **Extreme Depth**: Detail every technical decision, edge case, and architectural pattern.
   - **Agent Assignments**: A table mapping every file to a specialist agent found in `~/.config/opencode/config/routing.json`.
   - **Workflow Reference**: Explicitly link to `~/.config/opencode/skills/workflow-commands/commands/build.md`.
   - **Agent References**: Link to each specialist's `.agent.md` file in `~/.config/opencode/agents/`.

2. **`task.md`**:
   - **Granularity**: Break down chunks into tiny, verifiable sub-tasks.
   - **Allocation**: State which agent is responsible for each sub-task.

```markdown
Target: Chunk 1 - Foundation & State
```

```markdown
From DESIGN file manifest:
| File | Action | Agent Allocation (from routing.json) |
|------|--------|------------------------------------|

Generate:
- [ ] Sub-task 1.1: [Agent] Description
- [ ] Sub-task 1.2: [Agent] Description
- [ ] ...
```

### Step 3: Order by Dependencies

Analyze imports and dependencies to determine execution order.

### Step 4: Execute Chunk Files

**First Action:**
Create an isolated directory using the confirmed `output_path` from Step 0:

```bash
mkdir -p {output_path}/
```

> All implementation files MUST be written under `{output_path}/`, preserving relative paths from the DESIGN manifest.

**For each file:**

1. **Delegate (JIT Persona)** - Check the `implementation_plan.md` for the assigned agent.
2. **Reference Check (MANDATORY)** - You MUST read the specialist's rule file (from `~/.config/opencode/config/routing.json`) AND the `~/.config/opencode/config/routing.json` itself before execution.
3. **Banner Protocol** - Print `> [!IMPORTANT] Invoking Specialist: [Agent Name] (Path: [Agent Path])`.
4. **Write** - Create the file inside the output directory applying the exact rules, constraints, and code patterns from the invoked specialist and the `DESIGN` doc.
5. **Verify** - Run verification command (lint, type check, import test).
6. **Mark Complete** - Update progress in `task.md`.
7. **Persist (MANDATORY)** - Immediately update `~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md` then copy flat to local:

```bash
# Write global (system of record)
Write(~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md)

# Copy flat to local mirror
cp ~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md ./specs/BUILD_REPORT_{FEATURE}.md
```

### Step 5: Run Full Validation (For the Chunk)

After the chunk files are created:

```bash
# Lint check
ruff check .

# Type check (if applicable)
mypy .

# Run tests
pytest
```

### Step 6: Update Living Report

Update the `Chunk Execution Log` in the `BUILD_REPORT_{FEATURE}.md`:

- If all checks pass: Mark as ✅ Passed
- If checks fail (and auto-retries exhausted): Mark as ❌ Failed, log the error.

---

## Output

| Artifact         | Global Path                                                        | Local Path                              |
|------------------|--------------------------------------------------------------------|-----------------------------------------|
| **Code**         | `{output_path}/`                                                   | `{output_path}/`                        |
| **Build Report** | `~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md` | `./specs/BUILD_REPORT_{FEATURE}.md`     |

> Code goes to the `output_path` confirmed by the user at Step 0.
> BUILD_REPORT: write to global first, then `cp` flat to `./specs/`. Never write to only one location.

**Next Step:** `/workflow:validate ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md` (when ready)

---

## Execution Loop

The build agent follows this loop for each `/workflow:build` invocation:

```text
┌─────────────────────────────────────────────────────┐
│                 CHUNK EXECUTION                      │
├─────────────────────────────────────────────────────┤
│  0. question tool: where to write output?           │
│  1. Identify next Pending chunk from BUILD_REPORT   │
│  2. Write code for files in this chunk              │
│  3. Run verification command (ruff, mypy, pytest)   │
│     └─ If FAIL → Fix and retry (max 3)             │
│  4. Update BUILD_REPORT chunk status (✅ or ❌)       │
│  5. STOP. Ask user to proceed to next chunk.        │
└─────────────────────────────────────────────────────┘
```

---

## Quality Gate

Before marking complete, verify:

```text
[ ] Step 0 executed: question tool fired before any file was created or context was read
[ ] output_path was NOT read from DESIGN — it was explicitly provided by the user at Step 0
[ ] All files from manifest created under the user-confirmed output_path
[ ] All verification commands pass
[ ] Lint check passes
[ ] Tests pass (if applicable)
[ ] No TODO comments left in code
[ ] BUILD_REPORT written to global (~/.config/opencode/sdd/features/{feature-name}/) then cp'd flat to ./specs/
[ ] Specialist agent quality gates met for delegated files
[ ] Delegation used the Task tool or native subagent invocation for @agent-name assignments
```

---

## Tips

1. **Follow the DESIGN** - Don't improvise, use the code patterns
2. **Chunk Execution** - Execute ONLY the next pending chunk. Do NOT build the whole project at once.
3. **Verify Incrementally** - Use the `run_command` tool to test after the chunk is built (`ruff check`, `mypy`, `pytest`).
4. **Fix Forward** - If a test fails, read the output using `command_status`, fix the code, and retry up to 3 times.
5. **Living Artifact** - Keep the `BUILD_REPORT` updated. It is the source of truth for execution state.

---

## Handling Issues During Build

If you encounter issues:

| Issue                | Action                          |
|----------------------|---------------------------------|
| Missing requirement  | Use `/workflow:iterate` to update DEFINE |
| Architecture problem | Use `/workflow:iterate` to update DESIGN |
| Simple bug           | Fix immediately and continue    |
| Major blocker        | Stop and report in build report |

---

## References

- Agent: `~/.config/opencode/agents/workflow.build-agent.agent.md`
- Template: `~/.config/opencode/sdd/templates/BUILD_REPORT_TEMPLATE.md`
- Contracts: `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Next Phase: `~/.config/opencode/skills/workflow-commands/commands/ship.md`
