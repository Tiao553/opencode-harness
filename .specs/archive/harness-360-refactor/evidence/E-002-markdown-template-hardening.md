# Evidence

evidence_id: E-002
change: harness-360-refactor
task: T-007A,T-007B,T-007C,T-007D
created: 2026-06-25
command: apply_patch
status: captured
captured_by: openai/gpt-5.4

## Summary

Captured the Markdown authoring standard, the `.specs` template hardening, the `sdd` template hardening, and the skill-level reinforcement for denser architecture-aware artifact generation.

## Evidence Context

- What claim or task this evidence supports: the harness now has materially stronger Markdown authoring defaults
- Where in the system or document this evidence applies: `.specs/shared/`, `.specs/templates/`, `sdd/templates/`, and Markdown-producing skill docs
- Why this evidence matters: future `.md` artifacts should now be structurally biased toward detail, architecture views, traceability, and KT

## Output

```text
Created:
- .specs/shared/markdown-authoring-standard.md
- .specs/changes/harness-360-refactor/tasks/T-007A-define-markdown-authoring-standard.md
- .specs/changes/harness-360-refactor/tasks/T-007B-upgrade-specs-templates-for-density.md
- .specs/changes/harness-360-refactor/tasks/T-007C-upgrade-sdd-templates-for-architecture-depth.md
- .specs/changes/harness-360-refactor/tasks/T-007D-upgrade-markdown-producing-skills.md

Updated:
- .specs/templates/*.md
- sdd/templates/*.md
- skills/create-skills/SKILL.md
- skills/workflow-commands/SKILL.md
- skills/workflow-define/SKILL.md
- skills/workflow-design/SKILL.md
```

## Interpretation

The harness now enforces the user's requested shift away from shallow Markdown by changing both the templates and the instructions that generate those templates.

## Confidence and Limitations

- Confidence: high for template and skill surfaces
- Limitation: existing historical artifacts will not automatically become denser; only future or revised artifacts benefit unless old docs are regenerated

## Follow-Up Notes

- `T-006A` remains the next ready task
- Fabric golden-domain cleanup should use the new standard immediately
