---
name: ship
description: Archive completed feature with lessons learned (Phase 4)
---

# Ship Command

> Archive completed feature with lessons learned (Phase 4)

## Usage

```bash
/workflow:ship <define-file>
```

## Examples

```bash
/workflow:ship ~/.config/opencode/sdd/features/notification-system/DEFINE_NOTIFICATION_SYSTEM.md
/workflow:ship DEFINE_USER_AUTH.md
```

---

## Overview

This is **Phase 4** of the 5-phase AgentSpec workflow:

```text
Phase 0: /workflow:brainstorm → ~/.config/opencode/sdd/features/{feature-name}/BRAINSTORM_{FEATURE}.md (optional)
Phase 1: /workflow:define     → ~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md
Phase 2: /workflow:design     → ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md
Phase 3: /workflow:build      → Code in {output_path}/ + ~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md
Phase 3.5: /workflow:validate → ~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md
Phase 4: /workflow:ship       → ~/.config/opencode/sdd/archive/{feature-name}/SHIPPED_{DATE}.md (THIS COMMAND)
```

---

## What This Command Does

1. **Verify** - Confirm all artifacts exist and validation passed
2. **Archive** - Copy feature documents to both global and local archive folders
3. **Document** - Create SHIPPED summary with lessons learned (dual-write)
4. **Update statuses** - Mark all documents as Shipped
5. **Clean** - Remove working files from both global features/ and local specs/ directories

---

## Process

### Step 1: Verify Completion

```markdown
Read(~/.config/opencode/AGENTS.md)
Read(~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md)
Read(~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md)
Read(~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md)
Read(~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md)
Read(~/.config/opencode/sdd/features/{feature-name}/RUNBOOK_{FEATURE}.md)
```

Verify build report shows success and validation score >= 90 with 0 CRITICAL issues.

### Step 2: Create Archive Folders (Dual)

```bash
mkdir -p ~/.config/opencode/sdd/archive/{feature-name}/
mkdir -p ./specs/archive/{feature-name}/
```

### Step 3: Copy Artifacts to Both Archives

```bash
# Global archive
cp ~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md             ~/.config/opencode/sdd/archive/{feature-name}/
cp ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md             ~/.config/opencode/sdd/archive/{feature-name}/
cp ~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md       ~/.config/opencode/sdd/archive/{feature-name}/
cp ~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md  ~/.config/opencode/sdd/archive/{feature-name}/
cp ~/.config/opencode/sdd/features/{feature-name}/RUNBOOK_{FEATURE}.md            ~/.config/opencode/sdd/archive/{feature-name}/

# Local archive (mirror from global)
cp ~/.config/opencode/sdd/archive/{feature-name}/*.md ./specs/archive/{feature-name}/
```

### Step 4: Generate SHIPPED Document (Dual-Write — MANDATORY)

Create summary with:

| Section             | Content                         |
|---------------------|---------------------------------|
| **Summary**         | What was built                  |
| **Timeline**        | Start to Ship dates             |
| **Metrics**         | Lines of code, files created    |
| **Lessons Learned** | What went well, what to improve |
| **Artifacts**       | List of all archived documents  |

Write to both locations:

```bash
Write(~/.config/opencode/sdd/archive/{feature-name}/SHIPPED_{DATE}.md)
Write(./specs/archive/{feature-name}/SHIPPED_{DATE}.md)
```

### Step 5: Update Document Statuses

Update archived documents to Shipped status in both archive locations:

```markdown
Edit: ~/.config/opencode/sdd/archive/{feature-name}/DEFINE_{FEATURE}.md  → Status: "✅ Shipped"
Edit: ~/.config/opencode/sdd/archive/{feature-name}/DESIGN_{FEATURE}.md  → Status: "✅ Shipped"
Edit: ./specs/archive/{feature-name}/DEFINE_{FEATURE}.md         → Status: "✅ Shipped"
Edit: ./specs/archive/{feature-name}/DESIGN_{FEATURE}.md         → Status: "✅ Shipped"
```

### Step 6: Clean Up Working Files

Remove the active global feature directory and the flat local specs files:

```bash
rm -rf ~/.config/opencode/sdd/features/{feature-name}/

# Remove flat local spec files for this feature
rm -f ./specs/BRAINSTORM_{FEATURE}.md
rm -f ./specs/DEFINE_{FEATURE}.md
rm -f ./specs/DESIGN_{FEATURE}.md
rm -f ./specs/BUILD_REPORT_{FEATURE}.md
rm -f ./specs/VALIDATION_REPORT_{FEATURE}.md
rm -f ./specs/RUNBOOK_{FEATURE}.md
rm -f ./specs/ROADMAP_{FEATURE}.md
rm -f ./specs/BUILD_OUTPUT_PATH.txt
rm -rf ./specs/_validate/
```

---

## Output

| Artifact              | Global Archive                                                         | Local Archive                                                   |
|-----------------------|------------------------------------------------------------------------|-----------------------------------------------------------------|
| **SHIPPED**           | `~/.config/opencode/sdd/archive/{feature-name}/SHIPPED_{DATE}.md`              | `./specs/archive/{feature-name}/SHIPPED_{DATE}.md`              |
| **DEFINE**            | `~/.config/opencode/sdd/archive/{feature-name}/DEFINE_{FEATURE}.md`            | `./specs/archive/{feature-name}/DEFINE_{FEATURE}.md`            |
| **DESIGN**            | `~/.config/opencode/sdd/archive/{feature-name}/DESIGN_{FEATURE}.md`            | `./specs/archive/{feature-name}/DESIGN_{FEATURE}.md`            |
| **BUILD_REPORT**      | `~/.config/opencode/sdd/archive/{feature-name}/BUILD_REPORT_{FEATURE}.md`      | `./specs/archive/{feature-name}/BUILD_REPORT_{FEATURE}.md`      |
| **VALIDATION_REPORT** | `~/.config/opencode/sdd/archive/{feature-name}/VALIDATION_REPORT_{FEATURE}.md` | `./specs/archive/{feature-name}/VALIDATION_REPORT_{FEATURE}.md` |
| **RUNBOOK**           | `~/.config/opencode/sdd/archive/{feature-name}/RUNBOOK_{FEATURE}.md`           | `./specs/archive/{feature-name}/RUNBOOK_{FEATURE}.md`           |

**Next Step:** Start new feature with `/workflow:define`

---

## Quality Gate

Before shipping, verify:

```text
[ ] BUILD_REPORT shows all tasks completed
[ ] VALIDATION_REPORT exists with score >= 90 and 0 CRITICAL issues
[ ] RUNBOOK_{FEATURE}.md exists
[ ] All tests passing
[ ] Global archive created at ~/.config/opencode/sdd/archive/{feature-name}/
[ ] Local archive created at ./specs/archive/{feature-name}/
[ ] SHIPPED document written to BOTH archive locations
[ ] Working dirs cleaned: features/{feature-name}/ AND flat ./specs/ files for this feature
```

---

## Lessons Learned Categories

Document lessons in these areas:

| Category          | Example                                     |
|-------------------|---------------------------------------------|
| **Process**       | "Breaking tasks into smaller chunks helped" |
| **Technical**     | "Config files work better than env vars"    |
| **Communication** | "Early clarification saved rework"          |
| **Tools**         | "Using X library simplified Y"              |

---

## Tips

1. **Don't Skip This** - Lessons learned prevent future mistakes
2. **Be Honest** - Document what didn't work too
3. **Be Specific** - "Better planning" → "Create architecture diagram before coding"
4. **Archive Everything** - Future you will thank present you

---

## References

- Agent: `~/.config/opencode/agents/workflow.ship-agent.agent.md`
- Template: `~/.config/opencode/sdd/templates/SHIPPED_TEMPLATE.md`
- Contracts: `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Previous Phase: `~/.config/opencode/skills/workflow-commands/commands/build.md`
