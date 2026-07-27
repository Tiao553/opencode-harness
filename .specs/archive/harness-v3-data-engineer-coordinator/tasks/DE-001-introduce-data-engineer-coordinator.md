# DE-001 - Introduce Data Engineer Coordinator

task_id: DE-001
status: validated
change: harness-v3-data-engineer-coordinator
owner_agent: altitude-execution
slice_type: tactical-coordinator-introduction
effort_class: M

## Objective

Create the visible `data-engineer` tactical coordinator and preserve old `/data:*` behavior as internal routes.

## Source References

- `docs/HARNESS_V3_REFACTOR_ROADMAP.md`
- `docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md`
- `skills/data-engineering/SKILL.md`
- `skills/data-engineering/routing_skill.json`

## Allowed Files

- `agents/data-engineer.agent.md`
- `opencode.json`
- `docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md`
- `.specs/changes/harness-v3-data-engineer-coordinator/03-execution-ledger.md`
- `.specs/changes/harness-v3-data-engineer-coordinator/04-validation.md`
- `.specs/changes/harness-v3-data-engineer-coordinator/state.md`
- `.specs/changes/harness-v3-data-engineer-coordinator/tasks/DE-001-introduce-data-engineer-coordinator.md`
- `.specs/changes/harness-v3-data-engineer-coordinator/evidence/E-001-data-engineer-coordinator.md`
- `.specs/memory/active-state.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`

## Forbidden Scope

- deleting `/data:*` command compatibility
- broad data-specialist prompt rewrites
- strategic Altitude changes
- runtime plugin rewiring

## Acceptance Criteria

| ID | Criterion | Verification |
| --- | --- | --- |
| AC-001 | `data-engineer` primary agent exists | config/file check |
| AC-002 | tactical route contract exists | file check |
| AC-003 | old `/data:*` mappings are preserved as internal route equivalents | prompt/contract grep |
| AC-004 | config remains valid JSON | parser check |

## Verification Commands

```bash
node -e 'JSON.parse(require("fs").readFileSync("opencode.json", "utf8")); console.log("opencode-json-ok")'
grep -n '"data-engineer"' opencode.json
grep -n 'sql-review\|data-quality\|data-contract\|pipeline\|migrate\|lakehouse\|ai-pipeline' agents/data-engineer.agent.md docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md
```

## Rollback

Remove `agents/data-engineer.agent.md`, remove the `data-engineer` config entry, and keep old `/data:*` command behavior unchanged.

## Completion Checklist

- [x] Scope confirmed
- [x] Coordinator agent created
- [x] Tactical route contract created
- [x] Config validated
- [x] Evidence recorded
- [x] Validation recorded
