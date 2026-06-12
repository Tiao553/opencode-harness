---
name: define
description: Capture and validate requirements in one pass (Phase 1)
---

# Define Command

Phase 1 wrapper. The reusable process now lives in `~/.config/opencode/skills/workflow-define/SKILL.md`.

## Workflow

1. Load `~/.config/opencode/skills/workflow-commands/SKILL.md` for cross-phase rules.
2. Load `~/.config/opencode/skills/workflow-define/SKILL.md` for the Phase 1 workflow.
3. Pass `$ARGUMENTS` as the define input source.
4. Load supporting files lazily from `~/.config/opencode/` only when the phase workflow requires them.

## Output

- Global artifact: `~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE_NAME}.md`
- Local mirror: `./specs/DEFINE_{FEATURE_NAME}.md`
- Next step: `/workflow:design ~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE_NAME}.md`
