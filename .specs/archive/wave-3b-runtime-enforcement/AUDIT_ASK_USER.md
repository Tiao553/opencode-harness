# Wave 3B Audit Report — Ask-User Compliance

**Date:** 2026-06-29  
**Scope:** 80+ agents + 10+ skills  
**Phase:** In-Progress (agents done, skills pending)

---

## Agent Audit Results

### Summary

| Category | Count | Status | Action |
|----------|-------|--------|--------|
| Agents with ask-user | 17 | ✅ PASS | Keep, deepen |
| Agents without ask-user | 63 | ❌ FAIL | Review for need |
| **Critical missing** | **8** | 🚨 URGENT | Must fix before Wave 3B commit |

---

## Critical Missing (Coordinators + Key Phases)

### Tier 1: MUST FIX (Coordinators)

These coordinators NEED ask-user for decision gates:

```
❌ altitude.agent.md                    — Main orchestrator, routes to phases
❌ altitude-execution.agent.md          — Blocks execution if validation < 90
❌ altitude-report.agent.md             — Blocks ship if validation ≠ PASSED
❌ altitude-plan.agent.md               — Selects tasks for explicit execution
❌ data-engineer.agent.md               — Routes tactical work
```

### Tier 2: SHOULD FIX (Phase-critical)

```
❌ altitude-intent.agent.md             — Clarify ambiguous intent
❌ altitude-structure.agent.md          — Confirm surface mapping
❌ workflow.validate-agent.agent.md     — Validation results → remediate or ship?
```

---

## Agents WITH Ask-User (17 Total)

✅ **Architect group (4):**
- architect.data-platform-engineer
- architect.lakehouse-architect
- architect.schema-designer

✅ **Cloud group (1):**
- cloud.container-specialist

✅ **Data Engineering group (5):**
- data-engineering.ai-data-engineer
- data-engineering.dbt-specialist
- data-engineering.spark-engineer
- data-engineering.sql-optimizer
- data-engineering.streaming-engineer

✅ **Platform group (1):**
- platform.fabric-security-specialist

✅ **Product group (3):**
- product.frontend-react-agent
- product.rules-qa-agent
- product.system-design-agent

✅ **Test group (2):**
- test.data-contracts-engineer
- test.data-quality-analyst

✅ **Workflow group (2):**
- workflow.brainstorm-agent
- workflow.iterate-agent

---

## Agents WITHOUT Ask-User (63 Total)

### Coordinators (8 — CRITICAL)
- altitude.agent.md
- altitude-execution.agent.md
- altitude-intent.agent.md
- altitude-memory.agent.md
- altitude-plan.agent.md
- altitude-report.agent.md
- altitude-structure.agent.md
- altitude-validation.agent.md
- data-engineer.agent.md

### Architects (4)
- architect.genai-architect
- architect.kb-architect
- architect.medallion-architect
- architect.pipeline-architect
- architect.the-planner

### Cloud (7)
- cloud.ai-data-engineer-cloud
- cloud.ai-data-engineer-gcp
- cloud.ai-prompt-specialist-gcp
- cloud.aws-data-architect
- cloud.aws-deployer
- cloud.aws-lambda-architect
- cloud.ci-cd-specialist
- cloud.gcp-data-architect
- cloud.lambda-builder
- cloud.supabase-specialist

### Data Engineering (9)
- data-engineering.airflow-specialist
- data-engineering.lakeflow-architect
- data-engineering.lakeflow-expert
- data-engineering.lakeflow-pipeline-builder
- data-engineering.lakeflow-specialist
- data-engineering.qdrant-specialist
- data-engineering.spark-performance-analyzer
- data-engineering.spark-specialist
- data-engineering.spark-streaming-architect
- data-engineering.spark-troubleshooter

### Dev (8)
- dev.agent-router
- dev.codebase-explorer
- dev.faithfulness-guard
- dev.judge-agent
- dev.meeting-analyst
- dev.prompt-crafter
- dev.security-guardian
- dev.shell-script-specialist

### Platform (5)
- platform.fabric-ai-specialist
- platform.fabric-architect
- platform.fabric-cicd-specialist
- platform.fabric-logging-specialist
- platform.fabric-pipeline-developer

### Product (4)
- product.external-integration-agent
- product.ux-design-system-agent
- product.supabase-backend-agent

### Python (5)
- python.ai-prompt-specialist
- python.code-cleaner
- python.code-documenter
- python.code-reviewer
- python.llm-specialist
- python.python-developer

### Test (1)
- test.test-generator

### Workflow (5)
- workflow.build-agent
- workflow.define-agent
- workflow.design-agent
- workflow.ship-agent
- workflow.validate-agent

### Other (1)
- DEFAULT.AGENT
- dashboard-layout-specialist
- dev.agent-router
- graph-router

---

## Analysis

### Why Coordinators Don't Have Ask-User

Hypothesis: They were written before ask-user policy was finalized (Wave 0).

The agents mention `ask-user` in docs/AGENTS.md but don't **implement** it in their own `.agent.md` files.

### Why Some Specialists Have Ask-User

Pattern: Agents that make **architectural or design decisions** tend to have ask-user:
- architect.* (select architecture)
- data-engineering.* (select approach)
- product.* (select UX/system design)
- workflow.* (select phase/scope)
- test.* (select test strategy)

Agents that **execute tasks** without decisions tend to NOT have ask-user:
- data-engineering.spark-specialist (executes Spark fixes)
- cloud.* (executes deployment)
- python.* (executes code changes)

### Wave 3B Priority

**MUST fix (Tier 1):** 8 coordinators
**SHOULD fix (Tier 2):** 3 phase agents
**NICE-TO-FIX (Tier 3):** 20+ specialists
**SKIP:** Pure execution agents (not applicable)

---

## Recommendation for Wave 3B

### Phased Approach

**Phase 1 (Days 1–2): FIX COORDINATORS**
```
altitude.agent.md                    → add ask-user routing
altitude-execution.agent.md          → add ask-user for blocked execution
altitude-report.agent.md             → add ask-user for blocked ship
altitude-plan.agent.md               → add ask-user for task selection
data-engineer.agent.md               → add ask-user for tactical routing
```

**Phase 2 (Day 3): FIX PHASE AGENTS**
```
altitude-intent.agent.md             → add ask-user for ambiguity
altitude-structure.agent.md          → add ask-user for confirmation
workflow.validate-agent.agent.md     → add ask-user for remediate/escalate
```

**Phase 3 (Days 4+): REVIEW SPECIALISTS**
```
Sample 10 specialist agents
Verify: Does this agent make decisions?
  YES → should have ask-user (add if missing)
  NO  → pure execution, OK to skip
```

---

## Skills Audit Status

**Pending:** 10+ skills to audit
- data-engineering/
- workflow-commands/
- visual-explainer/
- core-commands/
- task-spec/
- review/
- customize-opencode/
- performance-optimization/

**TBD after agent audit completes**

---

## Success Criteria for Wave 3B

- [ ] All 8 coordinators have ask-user documented + working
- [ ] All 3 phase agents (Tier 2) have ask-user documented + working
- [ ] 15+ agent fixtures (5 coordinator + 5 phase + 5 specialist)
- [ ] Skills audit complete
- [ ] End-to-end test: blocked execution → ask-user → recovery works
- [ ] Validation gates + ask-user integration verified
- [ ] TodoWrite enforcement audit started (separate)

---

## Next Step

Start **Phase 1: Fix Coordinators** immediately.

Expected: 4-6 hours, 8 files, clear patterns emerge.
