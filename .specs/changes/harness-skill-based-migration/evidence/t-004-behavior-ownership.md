# T-004 Behavior Ownership and Enforcement

- Commands inventoried: 35.
- Discoverable repository skills: 7.
- Configured plugins: 6.
- Root shared contracts: 39.
- Hard enforcement proven by this inventory: none.

## Command Ownership

| Command | Agent | Model | Subtask | Required skill |
|---|---|---|---|---|
| `context:create-context.md` | `none` | default | false | knowledge-context |
| `core:meeting.md` | `dev.meeting-analyst` | default | true | core-commands |
| `core:memory.md` | `none` | default | false | core-commands |
| `core:readme-maker.md` | `none` | default | false | core-commands |
| `core:status.md` | `none` | default | false | core-commands |
| `core:sync-context.md` | `none` | default | false | core-commands |
| `data:ai-pipeline.md` | `data-engineering.ai-data-engineer` | default | true | data-engineering |
| `data:data-contract.md` | `test.data-contracts-engineer` | default | true | data-engineering |
| `data:data-quality.md` | `test.data-quality-analyst` | default | true | data-engineering |
| `data:lakehouse.md` | `architect.lakehouse-architect` | default | true | data-engineering |
| `data:migrate.md` | `architect.the-planner` | default | true | data-engineering |
| `data:pipeline.md` | `architect.pipeline-architect` | default | true | data-engineering |
| `data:schema.md` | `architect.schema-designer` | default | true | data-engineering |
| `data:sql-review.md` | `data-engineering.sql-optimizer` | default | true | data-engineering |
| `knowledge:create-kb.md` | `architect.kb-architect` | default | true | knowledge |
| `knowledge:refresh-stale-kbs.md` | `architect.kb-architect` | default | true | knowledge |
| `knowledge:update-kb.md` | `architect.kb-architect` | default | true | knowledge |
| `review:diff-review.md` | `none` | default | false | visual-explainer |
| `review:fact-check.md` | `none` | default | false | visual-explainer |
| `review:judge.md` | `dev.judge-agent` | default | true | review |
| `review:plan-review.md` | `none` | default | false | visual-explainer |
| `review:review.md` | `python.code-reviewer` | default | true | review |
| `visual:generate-slides.md` | `none` | default | false | visual-explainer |
| `visual:generate-visual-plan.md` | `none` | default | false | visual-explainer |
| `visual:generate-web-diagram.md` | `none` | default | false | visual-explainer |
| `visual:project-recap.md` | `none` | default | false | visual-explainer |
| `visual:share.md` | `none` | default | false | visual-explainer |
| `workflow:brainstorm.md` | `workflow.brainstorm-agent` | default | true | workflow-commands |
| `workflow:build.md` | `workflow.build-agent` | default | true | workflow-commands |
| `workflow:create-pr.md` | `none` | default | false | workflow-commands |
| `workflow:define.md` | `workflow.define-agent` | default | true | workflow-commands, workflow-define |
| `workflow:design.md` | `workflow.design-agent` | default | true | workflow-commands, workflow-design |
| `workflow:iterate.md` | `workflow.iterate-agent` | default | true | workflow-commands |
| `workflow:ship.md` | `workflow.ship-agent` | default | true | workflow-commands |
| `workflow:validate.md` | `workflow.validate-agent` | default | true | workflow-commands |

## Skills

- `core-commands`: repository-discoverable skill.
- `data-engineering`: repository-discoverable skill.
- `performance-optimization`: repository-discoverable skill.
- `review`: repository-discoverable skill.
- `task-spec`: repository-discoverable skill.
- `visual-explainer`: repository-discoverable skill.
- `workflow-commands`: repository-discoverable skill.

## Configured Plugins

| Plugin | Exists | Enforcement classification |
|---|---|---|
| `./plugins/altitude-context.ts` | yes | runtime hook present; hard enforcement unproven |
| `./plugins/specs-state.ts` | yes | soft-enforced (plugin states no durable blocking hook) |
| `./plugins/rtk-native.ts` | yes | runtime hook present; hard enforcement unproven |
| `./plugins/headroom-guard.ts` | yes | runtime hook present; hard enforcement unproven |
| `./plugins/context-budget.ts` | yes | runtime hook present; hard enforcement unproven |
| `./plugins/altitude-filestore.ts` | yes | runtime hook present; hard enforcement unproven |

## Workflow Isolation

- `/workflow:*` commands currently reference `workflow-commands` and phase agents; this is AgentSpec-oriented behavior.
- Altitude behavior remains in custom agents and shared contracts.
- The target separation is not yet implemented; this report records source ownership only.

## Missing or Stale References

| Reference | State | Classification |
|---|---|---|
| `docs/HARNESS_V3_ARCHITECTURE.md` | missing | stale or unresolved reference |
| `docs/HARNESS_DATA_ENGINEERING_TACTICAL_MODEL.md` | missing | stale or unresolved reference |
| `docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md` | missing | stale or unresolved reference |
| `plugins/permission-hardening.ts` | missing | stale or unresolved reference |
| `skills/workflow-define/SKILL.md` | missing | stale or unresolved reference |
| `skills/workflow-design/SKILL.md` | missing | stale or unresolved reference |

## Enforcement Finding

The current plugins and agents include policy text and runtime hooks, but this inventory proves no default-deny Task/TODO gate. `plugins/specs-state.ts` explicitly documents that it is a no-op shim until a stable runtime hook exists. Target behavior must not describe this current state as hard enforcement.
