---
name: iterate
description: Update any phase document when requirements or design change (Cross-Phase)
---

# Iterate Command

> Update any phase document when requirements or design changes (Cross-Phase)

## Usage

```bash
/workflow:iterate <file> "<change-description>"
```

## Examples

```bash
/workflow:iterate BRAINSTORM_SEARCH_API.md "Consider ElasticSearch instead of PostgreSQL full-text search"
/workflow:iterate DEFINE_SEARCH_API.md "Add support for fuzzy matching, not just exact search"
/workflow:iterate DESIGN_SEARCH_API.md "Services need to be self-contained, no shared common/"
/workflow:iterate ~/.config/opencode/sdd/features/auth/DEFINE_AUTH.md "Change from JWT to session-based auth"
```

---

## Overview

The `/workflow:iterate` command works with **document phases** of the AgentSpec workflow:

```text
Phase 0: /workflow:brainstorm → BRAINSTORM_{FEATURE}.md ← /workflow:iterate can update
Phase 1: /workflow:define     → DEFINE_{FEATURE}.md     ← /workflow:iterate can update
Phase 2: /workflow:design     → DESIGN_{FEATURE}.md     ← /workflow:iterate can update
Phase 3: /workflow:build      → (code)                  ← Update DESIGN, then /workflow:build
Phase 4: /workflow:ship       → (archive)               ← N/A
```

Use `/workflow:iterate` when you discover something that needs to change mid-stream.

**Important:** To change code during Phase 3, update the DESIGN document first. The cascade to code triggers a rebuild via `/workflow:build`. This ensures traceability.

---

## What This Command Does

1. **Detect Phase** - Identify which phase document is being updated
2. **Analyze Impact** - Determine downstream effects
3. **Update Document** - Apply changes with version tracking in **both** global and local paths
4. **Cascade** - Propagate changes to downstream documents (also double-updated) if needed

---

## Process

### Step 1: Load Target Document

```markdown
Read(<target-file>)

# Identify document type:
# - BRAINSTORM_*.md → Phase 0
# - DEFINE_*.md     → Phase 1
# - DESIGN_*.md     → Phase 2
```

Resolve both paths for the document:

- Global: `~/.config/opencode/sdd/features/{feature-name}/{DOCUMENT}.md`
- Local:  `./specs/{DOCUMENT}.md`

Read from global first; if missing, read from local flat path.

### Step 2: Analyze Change

Determine the change type:

| Change Type       | Example                 | Impact                      |
|-------------------|-------------------------|-----------------------------|
| **Additive**      | "Also support PDF"      | Low - adds to existing      |
| **Modifying**     | "Change from X to Y"    | Medium - updates existing   |
| **Removing**      | "Remove feature Z"      | Medium - simplifies         |
| **Architectural** | "Use different pattern" | High - may require redesign |

### Step 3: Apply Changes

Update the document with:

1. **Change Applied** - The actual modification
2. **Version Bump** - Increment version in revision history
3. **Change Note** - What changed and why

### Step 4: Double-Update (MANDATORY)

Write the updated document to the global store, then copy flat to local before proceeding to cascade:

```bash
# Global (system of record)
Write(~/.config/opencode/sdd/features/{feature-name}/{DOCUMENT}.md)

# Flat local mirror (copy — do not write separately)
mkdir -p ./specs/
cp ~/.config/opencode/sdd/features/{feature-name}/{DOCUMENT}.md ./specs/{DOCUMENT}.md
```

> Write globally once, then `cp` flat to `./specs/`. Never update only one location.

### Step 5: Assess Cascade Need

| Source        | Cascades To            |
|---------------|------------------------|
| DEFINE change | May need DESIGN update |
| DESIGN change | May need code update   |

Determine if downstream documents need updates based on cascade rules.

### Step 6: Execute Cascade (if needed)

If cascade needed, prompt user:

```markdown
"This DEFINE change affects the DESIGN. Options:
(a) Update DESIGN automatically to match
(b) Just update DEFINE, I'll handle DESIGN manually
(c) Show me what would change first"
```

If the user confirms cascade, apply changes to the downstream document and double-update it too:

```bash
Write(~/.config/opencode/sdd/features/{feature-name}/{DOWNSTREAM}.md)
cp ~/.config/opencode/sdd/features/{feature-name}/{DOWNSTREAM}.md ./specs/{DOWNSTREAM}.md
```

---

## Output

| Artifact             | Global Path                                        | Local Path            |
|----------------------|----------------------------------------------------|-----------------------|
| **Updated Document** | `~/.config/opencode/sdd/features/{feature-name}/{DOC}.md`  | `./specs/{DOC}.md`    |
| **Cascade Updates**  | `~/.config/opencode/sdd/features/{feature-name}/{DOWN}.md` | `./specs/{DOWN}.md`   |

---

## Cascade Rules

### DEFINE Changes → DESIGN Impact

| DEFINE Change            | DESIGN Impact               |
|--------------------------|-----------------------------|
| New requirement          | May need new component      |
| Changed success criteria | May need different approach |
| Scope expansion          | Needs new sections          |
| Scope reduction          | Can simplify                |
| New constraint           | Must be accommodated        |

### DESIGN Changes → Code Impact

| DESIGN Change        | Code Impact                |
|----------------------|----------------------------|
| New file in manifest | Create file                |
| Removed file         | Delete file                |
| Changed pattern      | Update affected files      |
| New decision         | May need refactor          |
| Architecture change  | Significant updates needed |

---

## Version Tracking

Each document maintains revision history:

```markdown
## Revision History

| Version | Date       | Author        | Changes                                   |
|---------|------------|---------------|-------------------------------------------|
| 1.0     | 2026-01-25 | define-agent  | Initial version                           |
| 1.1     | 2026-01-25 | iterate-agent | Added PDF support per user request        |
```

---

## Quality Gate

```text
[ ] Change applied to document content
[ ] Version bumped in revision history
[ ] Updated document written to BOTH global and local paths
[ ] Cascade documents (if any) also written to BOTH paths
[ ] No stale copy left in either location
```

---

## Tips

1. **Iterate Early** - Catch changes before coding starts
2. **Be Specific** - "Add X" is better than "make it better"
3. **Check Cascade** - Changes ripple downstream
4. **Keep History** - Version tracking shows evolution
5. **Always Update Revision History** - Bump the version number on every iteration
6. **Double-update always** - Global and local must stay in sync after every iterate

---

## When to Use /workflow:iterate vs Starting Over

| Situation                  | Action        |
|----------------------------|---------------|
| < 30% change               | `/workflow:iterate`    |
| Add/modify features        | `/workflow:iterate`    |
| Change constraints         | `/workflow:iterate`    |
| > 50% different            | New `/workflow:define` |
| Different problem entirely | New `/workflow:define` |
| Different target users     | New `/workflow:define` |

---

## References

- Agent: `~/.config/opencode/agents/workflow.iterate-agent.agent.md`
- Contracts: `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
