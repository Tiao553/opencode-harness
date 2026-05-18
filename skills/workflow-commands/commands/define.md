---
name: define
description: Capture and validate requirements in one pass (Phase 1)
---

# Define Command

> Capture requirements and validate them in one pass (Phase 1)

## Usage

```bash
/workflow:define <input>
```

## Examples

```bash
# From a BRAINSTORM document (recommended after /workflow:brainstorm)
/workflow:define ~/.config/opencode/sdd/features/notification-system/BRAINSTORM_NOTIFICATION_SYSTEM.md

# From meeting notes or raw input
/workflow:define notes/meeting-notes.md
/workflow:define "Build an API gateway for user management"
/workflow:define docs/stakeholder-email.txt
```

---

## Overview

This is **Phase 1** of the 5-phase AgentSpec workflow:

```text
Phase 0: /workflow:brainstorm → ~/.config/opencode/sdd/features/{feature-name}/BRAINSTORM_{FEATURE}.md (optional)
Phase 1: /workflow:define     → ~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md (THIS COMMAND)
Phase 2: /workflow:design     → ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md
Phase 3: /workflow:build      → Code in {output_path}/ + ~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md
Phase 3.5: /workflow:validate → ~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md
Phase 4: /workflow:ship       → ~/.config/opencode/sdd/archive/{feature-name}/SHIPPED_{DATE}.md
```

The `/workflow:define` command combines what used to be Intake + PRD + Refine into a single, iterative phase. When fed a BRAINSTORM document, it extracts pre-validated requirements with minimal clarification needed.

---

## What This Command Does

1. **Extract** - Pull requirements from any input (notes, emails, conversations)
2. **Structure** - Organize into problem, users, goals, success criteria
3. **Validate** - Built-in clarity scoring (must reach 12/15 to proceed)
4. **Clarify** - Ask targeted questions for any gaps

---

## Process

### Step 1: Load Context

```markdown
Read(~/.config/opencode/sdd/templates/DEFINE_TEMPLATE.md)
Read(~/.config/opencode/AGENTS.md)

# If file provided:
Read(<input-file>)
```

### Step 2: Classify Input

Identify the input type to guide extraction:

| Input Type | Pattern | Focus |
|------------|---------|-------|
| `brainstorm_document` | BRAINSTORM_*.md from /workflow:brainstorm | Pre-validated, extract directly |
| `meeting_notes` | Bullet points, action items | Decisions, requirements |
| `email_thread` | Re:, Fwd:, signatures | Requests, constraints |
| `conversation` | Informal language | Core problem, users |
| `direct_requirement` | Structured request | All elements present |
| `mixed_sources` | Multiple formats | Consolidate, deduplicate |

**Note:** When input is a BRAINSTORM document, extraction is streamlined because:
- Discovery questions are already answered
- Approaches have been evaluated
- YAGNI has been applied
- User has validated the direction

### Step 3: Extract Entities

Extract these elements from input:

| Element | Extraction Patterns |
|---------|---------------------|
| **Problem** | "We're struggling with...", "The issue is...", "Pain point:" |
| **Users** | "For the team...", "Customers want...", "Users need..." |
| **Goals** | "We need to...", "Goal is to...", "Success looks like..." |
| **Success Criteria** | "Success means...", "We'll know when...", "Measured by..." |
| **Acceptance Tests** | "Given/When/Then", "Test case:", "Scenario:" |
| **Constraints** | "Must work with...", "Can't change...", "Limited by..." |
| **Out of Scope** | "Not including...", "Deferred to...", "Excluded:" |

### Step 4: Calculate Clarity Score

Score each element (0-3 points):

| Element | Score | Meaning |
|---------|-------|---------|
| Problem | 0-3 | Clear, specific, actionable |
| Users | 0-3 | Identified with pain points |
| Goals | 0-3 | Measurable outcomes |
| Success | 0-3 | Testable criteria |
| Scope | 0-3 | Explicit boundaries |

**Scoring Guide:**
- 0 = Missing entirely
- 1 = Vague or incomplete
- 2 = Clear but missing details
- 3 = Crystal clear, actionable

**Minimum to proceed:** 12/15 (80%)

### Step 5: Fill Gaps (if needed)

If score < 12, use `AskUserQuestion` with specific options:

```markdown
Example questions:
- "Who is the primary user: (a) internal team, (b) customers, (c) both?"
- "What's the timeline: (a) this sprint, (b) this quarter, (c) no deadline?"
```

### Step 6: Generate Document (Write Global → Copy Flat — MANDATORY)

Write the artifact to the global store, then copy it flat to the local mirror:

```bash
# 1. Global store (system of record)
Write(~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE_NAME}.md)

# 2. Flat local mirror (copy — do not write separately)
mkdir -p ./specs/
cp ~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE_NAME}.md ./specs/DEFINE_{FEATURE_NAME}.md
```

> Write globally once, then `cp` flat to `./specs/`. Never write to only one location.

---

## Output

| Artifact   | Global Path                                                       | Local Path                         |
|------------|-------------------------------------------------------------------|------------------------------------|
| **DEFINE** | `~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE_NAME}.md` | `./specs/DEFINE_{FEATURE_NAME}.md` |

**Next Step:** `/workflow:design ~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE_NAME}.md`

---

## Quality Gate

Before saving, verify:

```text
[ ] Problem statement is clear and specific
[ ] At least one user persona identified
[ ] Success criteria are measurable
[ ] Acceptance tests are testable
[ ] Out of scope is explicit
[ ] Clarity Score >= 12/15
[ ] Artifact written to global (~/.config/opencode/sdd/) then cp'd flat to ./specs/
```

---

## Tips

1. **Be Specific** - "Improve performance" → "Reduce API latency to <200ms"
2. **Use Numbers** - "Handle many users" → "Support 1000 concurrent users"
3. **Test Criteria** - If you can't test it, it's not clear enough
4. **Scope Ruthlessly** - What's OUT is as important as what's IN

---

## References

- Agent: `~/.config/opencode/agents/workflow.define-agent.agent.md`
- Template: `~/.config/opencode/sdd/templates/DEFINE_TEMPLATE.md`
- Contracts: `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Previous Phase: `~/.config/opencode/skills/workflow-commands/commands/brainstorm.md` (optional)
- Next Phase: `~/.config/opencode/skills/workflow-commands/commands/design.md`
