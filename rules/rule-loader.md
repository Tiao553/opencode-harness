# Rule-Loader Contract

**Trigger:** W4 AGENTS.md kernel author reference — meta-rule for implementation.
**Load scope:** Read by the W4 kernel author, not loaded at runtime.
**Governing ADR:** ADR-0006.

---

## Core rule

Rules are discovered from `rules/` and loaded by name from AGENTS.md trigger blocks. Only `rules/START.md` loads unconditionally; all others are lazy.

## AGENTS.md trigger block format

```markdown
## Trigger: {Condition}
When: {precise condition}
Load: `rules/{filename}.md`
Then: {what to do after loading}
```

Example:
```markdown
## Trigger: Altitude Strategic Work
When: not /workflow:*, requires .specs/changes/ artifact, not data-engineering
Load: `rules/altitude-start.md`
Then: follow state-resolution steps
```

## Discovery

OpenCode loads `rules/START.md` via `"instructions": ["rules/START.md"]` in `opencode.json`.
All other rule files are lazy — loaded only when the kernel instruction references them.

## Load budget constraint

- Compact kernel ≤ 350 lines (W4 target).
- Each rule file ≤ 150 lines (W3 target).
- If a rule file grows beyond 150 lines: split into base rule + detail appendix.

## Stop conditions

- STOP if a trigger block references a file not in `rules/`.
- STOP if the kernel grows beyond 350 lines — move content to lazy rule files.
- STOP if a new rule file is added without a `_registry.md` entry.

---

*Governing: ADR-0006.*
