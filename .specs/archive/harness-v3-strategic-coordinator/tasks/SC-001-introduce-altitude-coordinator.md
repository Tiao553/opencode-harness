# SC-001 - Introduce Altitude Coordinator

task_id: SC-001
status: validated
change: harness-v3-strategic-coordinator
owner_agent: altitude-execution
slice_type: coordinator-introduction
effort_class: M

## Objective

Introduce one visible `altitude` coordinator and demote phase-specific `altitude-*` agents to hidden subagents.

## Source References

- `docs/HARNESS_V3_REFACTOR_ROADMAP.md`
- `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`
- `.specs/shared/state-resolution-contract.md`
- `.specs/shared/phase-engine-contract.md`
- `.specs/shared/allocation-contract.md`

## Allowed Files

- `agents/altitude.agent.md`
- `agents/altitude-intent.agent.md`
- `agents/altitude-structure.agent.md`
- `agents/altitude-plan.agent.md`
- `agents/altitude-execution.agent.md`
- `agents/altitude-validation.agent.md`
- `agents/altitude-report.agent.md`
- `agents/altitude-memory.agent.md`
- `opencode.json`
- `.specs/changes/harness-v3-strategic-coordinator/03-execution-ledger.md`
- `.specs/changes/harness-v3-strategic-coordinator/04-validation.md`
- `.specs/changes/harness-v3-strategic-coordinator/state.md`
- `.specs/changes/harness-v3-strategic-coordinator/tasks/SC-001-introduce-altitude-coordinator.md`
- `.specs/changes/harness-v3-strategic-coordinator/evidence/E-001-altitude-coordinator.md`
- `.specs/memory/active-state.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `docs/HARNESS_V3_COORDINATOR_CONTRACT.md`

## Forbidden Scope

- deleting phase agents
- command removal
- Data Engineer coordinator
- runtime plugin rewiring

## Acceptance Criteria

| ID | Criterion | Verification |
| --- | --- | --- |
| AC-001 | `altitude` is configured as the single visible strategic coordinator | JSON/config check |
| AC-002 | phase-specific `altitude-*` agents are subagents, not primary user entrypoints | JSON/frontmatter check |
| AC-003 | coordinator prompt describes classification, state resolution, phase routing, allocation, and action types | manual grep/review |
| AC-004 | config remains valid JSON | parser check |

## Verification Commands

```bash
node -e 'JSON.parse(require("fs").readFileSync("opencode.json", "utf8")); console.log("opencode-json-ok")'
grep -n '"altitude"' opencode.json
grep -n '"mode": "primary"' opencode.json
grep -n '^mode: subagent' agents/altitude-*.agent.md
```

## Rollback

Restore prior `opencode.json` altitude entries and change phase-agent frontmatter `mode` values back to `primary`.

## Completion Checklist

- [x] Scope confirmed
- [x] Coordinator agent created
- [x] Phase agents demoted
- [x] Config validated
- [x] Evidence recorded
- [x] Validation recorded
