# Evidence

evidence_id: E-001
change: harness-v3-grounding-split
task: GS-001
created: 2026-06-28
command: link check + grounding section grep
status: captured
captured_by: openai/gpt-5.4

## Summary

Replaced `config/grounding.md` with a thin index that points to `.specs/shared` policy contracts.

## Commands

```bash
for path in $(grep -oE '\.specs/shared/[A-Za-z0-9._/-]+\.md' config/grounding.md | sort -u); do test -f "$path"; done
grep -E "Permissions Policy|Agent Execution Loop|Token Budget Strategy|Response Compression Policy|SDD Workflow Initialization|Skill Priority" config/grounding.md
grep -E "runtime-policy|context-loading-policy|state-resolution-contract|phase-engine-contract|documentation-mode-policy|production-code-mode-policy|specialist-allocation-contract" config/grounding.md
```

## Results

```text
grounding-links-ok
0 matches for old monolithic section headings
policy contract links present in config/grounding.md
```

## Interpretation

Grounding now acts as an index rather than a mixed policy file. Runtime, context loading, state, phase, execution loop, documentation mode, code mode, compatibility, Ask-User, todo projection, allocation, specialist allocation, MCP, security, rollback, definition of done, and Markdown authoring concerns all point to owning contracts.

## Limitation

This wave changes the policy/documentation surface only. Runtime plugins were not rewired.

