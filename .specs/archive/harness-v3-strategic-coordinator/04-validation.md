# Harness V3 Strategic Coordinator - Validation

## Validation V-001

- Task: SC-001
- Verdict: validated
- Validation method: JSON parser check, config mode assertion, phase-agent frontmatter check, and coordinator prompt contract grep
- Scope check: passed
- Evidence check: passed
- Notes: `opencode.json` contains exactly one primary `altitude` coordinator; all phase-specific `altitude-*` config entries are `subagent` and `hidden`; phase-agent frontmatter now uses `mode: subagent`; the coordinator prompt references state, phase, allocation, internal phase agents, execution gates, and output contract
