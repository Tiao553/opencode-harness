# Context Budget Policy

Context should be loaded by altitude.

## Policy

- Load the smallest useful context for the current altitude.
- Prefer indexes and summaries before full files.
- Do not load old changes unless they are referenced by the active task.
- Use RTK for verbose shell output when safe.
- Use Headroom only as optional compression, not workflow control.
- Record excessive reads in `.specs/memory/context-budget.md`.

## Warning Signs

- Reading all tasks for one active task.
- Loading all memory files by default.
- Loading full logs when a failure summary is enough.
- Loading source code before intent and structure are ready.
