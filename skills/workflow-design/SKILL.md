---
name: workflow-design
description: /workflow:design, DESIGN artifact, architecture decisions, file manifest, and validation contract. Use ONLY when executing Phase 2 or updating the DESIGN workflow logic.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: workflow
---

# Workflow Design

## When to Use

- Use for `/workflow:design`.
- Use when a valid `DEFINE_{FEATURE}.md` exists and the next output is `DESIGN_{FEATURE}.md`.
- Do not use for requirement extraction or low-clarity discovery. That belongs to `workflow-define`.

## Workflow

1. Read `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml`, `DEFINE_{FEATURE}.md`, and `~/.config/opencode/sdd/templates/DESIGN_TEMPLATE.md`.
2. Load only the KB domains named in DEFINE, starting with `quick-reference.md`.
3. Design the architecture in a form the build phase can execute:
   - system overview
   - major components
   - data flow or execution flow
   - external integration points
4. Record key decisions with rationale and rejected alternatives.
5. Create a complete file manifest with action, purpose, dependencies, and agent assignment.
6. Add code patterns only where they reduce ambiguity for build.
7. Fill the validation contract so `/workflow:validate` can check facts instead of guessing intent.
8. Write the global artifact first, then copy it flat to `./specs/DESIGN_{FEATURE}.md`.
9. End with a handoff to `/workflow:build`.

## Design Rules

- DEFINE is mandatory. No DESIGN from raw notes.
- Every file in the manifest needs either a specialist assignment or an explicit general fallback.
- Rationale matters more than decorative diagrams.
- Validation contract must be filled with concrete implementation targets.
- Keep the build output root out of DESIGN; `/workflow:build` asks for it at runtime.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "The build phase can infer the missing files." | Missing manifest detail makes build non-deterministic. |
| "We can leave validation placeholders for later." | Placeholder validation contracts turn validate into guesswork. |
| "A code pattern for every file is safer." | Only add patterns where they reduce ambiguity; noise is not design. |

## Red Flags

- No DEFINE artifact is loaded.
- KB domains from DEFINE are ignored.
- The file manifest is incomplete or has no dependency information.
- Agent assignments are arbitrary instead of purpose-based.
- The validation contract is left as placeholders.

## Verification

- [ ] `WORKFLOW_CONTRACTS.yaml`, DEFINE, and `DESIGN_TEMPLATE.md` were read.
- [ ] KB loading started from DEFINE domains and stayed lazy.
- [ ] Architecture, decisions, manifest, and validation contract are all present.
- [ ] File manifest entries include purpose, action, dependencies, and agent/general assignment.
- [ ] Artifact was written globally first and copied flat to `./specs/`.
- [ ] Next step points to `/workflow:build`.
