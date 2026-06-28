# Agent Authority Matrix

Sources:

- `docs/tasks/phase-2.md`
- `docs/AGENTIC_GAP_DOSSIER.md`
- `https://opencode.ai/docs/agents/`

Enforcement path:

- `plugins/permission-hardening.ts`

## Profiles

| Class | Default posture |
| --- | --- |
| Altitude specs writer | Path-scoped `.specs` edits; no source edits |
| Altitude execution | Source edits only by active task allowed files; shell allowed for verification |
| Read-only | `edit: deny`, `bash: deny`, `task: deny`; web off unless the role depends on current vendor docs |
| Review-only | Same as read-only, kept for review and optimization roles that should never mutate the workspace |
| Orchestrator | `edit: deny`, `bash: deny`, scoped `permission.task`; hidden when the agent is an internal router |
| Builder | `edit: allow`; `bash` only when the workflow genuinely needs execution, tests, or deployment |
| Auditor | `edit: deny`, `bash: deny`, `task: deny`; evidence gathering only |
| Exception | Narrow non-standard authority for SDD artifact writers or shell-only security gates |

## Matrix

| Class | Agents |
| --- | --- |
| Altitude specs writer | `altitude-intent`, `altitude-structure`, `altitude-plan`, `altitude-validation`, `altitude-report`, `altitude-memory` |
| Altitude execution | `altitude-execution` |
| Orchestrator | `DEFAULT`, `graph-router`, `dev.agent-router`, `architect.the-planner` |
| Exception | `workflow.brainstorm-agent`, `workflow.define-agent`, `workflow.design-agent`, `workflow.build-agent`, `workflow.validate-agent`, `workflow.iterate-agent`, `workflow.ship-agent`, `dev.security-guardian` |
| Auditor | `dev.faithfulness-guard`, `dev.judge-agent`, `product.rules-qa-agent` |
| Review-only | `python.code-reviewer`, `data-engineering.sql-optimizer` |
| Read-only | `dev.codebase-explorer`, `dev.meeting-analyst`, `product.system-design-agent`, `product.ux-design-system-agent`, `architect.data-platform-engineer`, `architect.genai-architect`, `architect.lakehouse-architect`, `architect.medallion-architect`, `cloud.aws-data-architect`, `cloud.gcp-data-architect`, `platform.fabric-architect`, `data-engineering.spark-specialist`, `data-engineering.spark-performance-analyzer`, `data-engineering.spark-troubleshooter`, `data-engineering.lakeflow-architect`, `data-engineering.lakeflow-expert`, `data-engineering.lakeflow-specialist`, `data-engineering.spark-streaming-architect` |
| Builder | `dashboard-layout-specialist`, `test.test-generator`, `test.data-quality-analyst`, `test.data-contracts-engineer`, `product.supabase-backend-agent`, `python.code-documenter`, `python.python-developer`, `python.code-cleaner`, `platform.fabric-pipeline-developer`, `platform.fabric-security-specialist`, `product.frontend-react-agent`, `product.external-integration-agent`, `python.llm-specialist`, `python.ai-prompt-specialist`, `dev.shell-script-specialist`, `platform.fabric-ai-specialist`, `data-engineering.streaming-engineer`, `platform.fabric-logging-specialist`, `platform.fabric-cicd-specialist`, `dev.prompt-crafter`, `data-engineering.airflow-specialist`, `data-engineering.qdrant-specialist`, `data-engineering.spark-engineer`, `data-engineering.ai-data-engineer`, `data-engineering.lakeflow-pipeline-builder`, `data-engineering.dbt-specialist`, `cloud.ai-data-engineer-cloud`, `cloud.container-specialist`, `cloud.supabase-specialist`, `architect.schema-designer`, `architect.pipeline-architect`, `cloud.aws-lambda-architect`, `cloud.lambda-builder`, `cloud.ai-prompt-specialist-gcp`, `architect.kb-architect`, `cloud.ci-cd-specialist`, `cloud.ai-data-engineer-gcp`, `cloud.aws-deployer` |

## Intentional Deviations

| Agent | Reason |
| --- | --- |
| `altitude-intent` | May write only intent/state artifacts; no source edits |
| `altitude-structure` | May update structure and durable memory; source edits are outside altitude |
| `altitude-plan` | May create decomposition and tasks; implementation is explicitly deferred |
| `altitude-execution` | Keeps shell and edit authority, but execution is gated by one ready task and allowed files |
| `altitude-validation` | May run checks and write validation artifacts; source fixes require explicit return to execution |
| `altitude-report` | Writes reports from artifacts only |
| `altitude-memory` | Updates durable memory and archives only after validated learning |
| `graph-router`, `dev.agent-router` | Hidden because they are internal routing helpers rather than user-facing specialists |
| `workflow.brainstorm-agent`, `workflow.define-agent`, `workflow.design-agent`, `workflow.iterate-agent` | Keep `edit` only to write SDD artifacts; no shell access |
| `workflow.build-agent` | Keeps `edit` and `bash`, but delegation is now allowlisted by family |
| `workflow.validate-agent` | Keeps `edit` and `bash` to create reports and run validation gates; subagents are allowlisted to auditors/reviewers only |
| `workflow.ship-agent` | Keeps `edit` and `bash` for archive operations; delegation disabled |
| `dev.security-guardian` | Only non-builder with shell authority because its job is running security gates, not editing code |

## Validation Targets

One representative agent per class should resolve to the expected permissions after restart:

| Class | Representative |
| --- | --- |
| Altitude specs writer | `altitude-plan` |
| Altitude execution | `altitude-execution` |
| Orchestrator | `architect.the-planner` |
| Exception | `workflow.build-agent` |
| Auditor | `dev.faithfulness-guard` |
| Review-only | `python.code-reviewer` |
| Read-only | `dev.codebase-explorer` |
| Builder | `product.frontend-react-agent` |
