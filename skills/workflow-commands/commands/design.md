---
name: design
description: Create architecture and technical specification (Phase 2)
---

# Design Command

> Create architecture and technical specification in one pass (Phase 2)

## Usage

```bash
/workflow:design <define-file>
```

## Examples

```bash
/workflow:design ~/.config/opencode/sdd/features/notification-system/DEFINE_NOTIFICATION_SYSTEM.md
/workflow:design DEFINE_USER_AUTH.md
/workflow:design ~/.config/opencode/sdd/features/search-api/DEFINE_SEARCH_API.md
```

---

## Overview

This is **Phase 2** of the 5-phase AgentSpec workflow:

```text
Phase 0: /workflow:brainstorm → ~/.config/opencode/sdd/features/{feature-name}/BRAINSTORM_{FEATURE}.md (optional)
Phase 1: /workflow:define     → ~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md
Phase 2: /workflow:design     → ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md (THIS COMMAND)
Phase 3: /workflow:build      → Code in {output_path}/ + ~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md
Phase 3.5: /workflow:validate → ~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md
Phase 4: /workflow:ship       → ~/.config/opencode/sdd/archive/{feature-name}/SHIPPED_{DATE}.md
```

The `/workflow:design` command combines what used to be Plan + Spec + ADRs into a single document with architecture decisions inline.

---

## What This Command Does

1. **Analyze** - Understand requirements from DEFINE
2. **Architect** - Design high-level solution with diagrams
3. **Decide** - Document key decisions with rationale (inline ADRs)
4. **Specify** - Create file manifest and code patterns
5. **Plan Testing** - Define testing strategy

---

## Process

### Step 1: Load Context

```markdown
Read(~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md)
Read(~/.config/opencode/sdd/templates/DESIGN_TEMPLATE.md)
Read(~/.config/opencode/AGENTS.md)

# Explore codebase for patterns:
Glob(**/*.py) | head -20
Grep("class |def ") | sample
```

### Step 2: Create Architecture

Design the solution:

| Component              | Content                        |
|------------------------|--------------------------------|
| **Overview**           | ASCII diagram of system        |
| **Components**         | List of modules/services       |
| **Data Flow**          | How data moves through system  |
| **Integration Points** | External dependencies          |

### Step 3: Document Decisions (Inline ADRs)

For each significant choice:

```markdown
### Decision: {Name}

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | YYYY-MM-DD |

**Context:** Why this decision was needed

**Choice:** What we're doing

**Rationale:** Why this approach

**Alternatives Rejected:**
1. Option A - rejected because X
2. Option B - rejected because Y

**Consequences:**
- Trade-off we accept
- Benefit we gain
```

### Step 4: Create File Manifest

List all files to create/modify:

| # | File                    | Action | Purpose         | Dependencies |
|---|-------------------------|--------|-----------------|--------------|
| 1 | `path/to/file.py`       | Create | Main handler    | None         |
| 2 | `path/to/config.yaml`   | Create | Configuration   | None         |
| 3 | `path/to/handler.py`    | Create | Request handler | 1, 2         |

> Note: `/workflow:build` always asks the user where to write generated code before starting. No `output_path` metadata is needed in DESIGN.

### Step 5: Define Code Patterns

Provide copy-paste ready code snippets for key patterns.

### Step 6: Plan Testing Strategy

| Test Type   | Scope     | Tools              |
|-------------|-----------|--------------------|
| Unit        | Functions | pytest             |
| Integration | API       | pytest + requests  |
| E2E         | Full flow | Manual/automated   |

### Step 6.5: Fill Validation Contract (MANDATORY)

Before saving, populate the `## Validation Contract` section of the DESIGN document. This section is read directly by `/workflow:validate` at Phase 3.5 — leaving it as placeholders forces the validate agent to guess instead of check.

For each sub-section:

| Sub-section                              | What to fill                                                                                     |
|------------------------------------------|--------------------------------------------------------------------------------------------------|
| **Spec Junta — Requirements**            | Copy each requirement ID + description from DEFINE; add the file/function that will implement it |
| **Spec Junta — Architecture decisions**  | For each Key Decision above, state the concrete code pattern the validator should find           |
| **Code Junta — Quality targets**         | Fill error handling strategy, test coverage goal, DevOps artifacts expected, security boundaries |
| **Delivery Junta — File manifest**       | Copy all files from the File Manifest above; status = Planned for all                           |
| **Delivery Junta — Acceptance criteria** | Map each Given/When/Then from DEFINE to the test file that will verify it                        |
| **Score Targets**                        | Keep defaults unless the feature has specific relaxed/stricter thresholds                        |

> A DESIGN with an empty or placeholder-only Validation Contract will be flagged as incomplete by the quality gate.

### Step 7: Save (Write Global → Copy Flat — MANDATORY)

Write the artifact to the global store, then copy it flat to the local mirror:

```bash
# 1. Global store (system of record)
Write(~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE_NAME}.md)

# 2. Flat local mirror (copy — do not write separately)
mkdir -p ./specs/
cp ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE_NAME}.md ./specs/DESIGN_{FEATURE_NAME}.md
```

> Write globally once, then `cp` flat to `./specs/`. Never write to only one location.

---

## Output

| Artifact   | Global Path                                                       | Local Path                         |
|------------|-------------------------------------------------------------------|------------------------------------|
| **DESIGN** | `~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE_NAME}.md` | `./specs/DESIGN_{FEATURE_NAME}.md` |

**Next Step:** `/workflow:build ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE_NAME}.md`

---

## Quality Gate

Before saving, verify:

```text
[ ] Architecture diagram is clear
[ ] All major decisions documented with rationale
[ ] File manifest is complete (all files listed)
[ ] Code patterns are copy-paste ready
[ ] Testing strategy covers requirements
[ ] No circular dependencies in architecture
[ ] Agent assignments in file manifest validated against ~/.config/opencode/config/routing.json
```

---

## Tips

1. **Diagram First** - ASCII art clarifies thinking
2. **Decisions Are Permanent** - Document the "why" not just "what"
3. **Self-Contained Files** - Each file should work independently
4. **Config Over Code** - Use YAML for tunables, not hardcoded values
5. **Test Early** - Design for testability from the start

---

## References

- Agent: `~/.config/opencode/agents/workflow.design-agent.agent.md`
- Template: `~/.config/opencode/sdd/templates/DESIGN_TEMPLATE.md`
- Contracts: `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Next Phase: `~/.config/opencode/skills/workflow-commands/commands/build.md`
