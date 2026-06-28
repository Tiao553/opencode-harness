---
name: design
description: Create architecture and technical specification (Phase 2)
---

# Design Command

Phase 2 wrapper. The reusable process now lives in `~/.config/opencode/skills/workflow-design/SKILL.md`.

## Workflow

1. Load `~/.config/opencode/skills/workflow-commands/SKILL.md` for cross-phase rules.
2. Load `~/.config/opencode/skills/workflow-design/SKILL.md` for the Phase 2 workflow.
3. Pass `$ARGUMENTS` as the define artifact or define reference.
4. Load supporting files lazily from `~/.config/opencode/` only when the phase workflow requires them.

## Output

- Global artifact: `~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE_NAME}.md`
- Local mirror: `./specs/DESIGN_{FEATURE_NAME}.md`
- Next step: `/workflow:build ~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE_NAME}.md`
