---
name: visual-explainer
description: Guides agents through generating standalone visual explainers, HTML diagrams, review boards, slide-like recaps, and visual planning artifacts. Use when a /visual:* command or visual review needs a portable visual output.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: visual
---

# Visual Explainer

## Overview

This skill standardizes how visual deliverables are produced so the result is portable, self-explanatory, and grounded in the input rather than improvised decoration.

## When to Use

- Use for `/visual:*` commands that generate diagrams, recap pages, slide-like outputs, or shareable visual plans.
- Use for review commands that need a visual comparison or fact-check board.
- Use when the output should be understandable without the surrounding chat context.
- Do not use when a plain text answer is enough.
- Do not use when the task is to edit an existing code UI instead of producing a standalone artifact.

## Workflow

1. Read the command-specific file under `~/.config/opencode/skills/visual-explainer/commands/`.
2. Inspect every referenced file, argument, and requested audience before choosing a layout.
3. Decide the artifact shape first:
   - diagram
   - recap page
   - slide deck
   - review board
   - share page
4. Prefer self-contained HTML when the output needs layout, contrast, annotations, or side-by-side comparison.
5. Keep the structure explicit:
   - title
   - context
   - main visual area
   - notes, findings, or next steps
6. Preserve technical accuracy over aesthetics.
7. Before finishing, verify that the artifact can be opened or read without hidden runtime dependencies.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The command only needs a placeholder file." | A missing or empty workflow file leaves the command broken. |
| "A pretty layout matters more than exact content." | The artifact is only useful if it faithfully represents the source material. |
| "I can skip reading the inputs because this is just a visual." | Visual summaries that are not source-grounded create false confidence. |

## Red Flags

- The visual artifact introduces claims that are not present in the source files.
- The output depends on undocumented assets or frameworks.
- The command-specific file is missing or too vague to execute.
- The artifact cannot stand alone outside the current chat.

## Verification

- [ ] The command-specific workflow file was read.
- [ ] All referenced inputs were inspected before generating the visual.
- [ ] The artifact format matches the command goal.
- [ ] The result is self-contained and understandable without extra chat context.
- [ ] Findings or annotations stay grounded in the source material.
