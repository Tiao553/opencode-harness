# Agentic Gap Dossier for OpenCode vs `addyosmani/agent-skills`

## Summary

This dossier audits the local OpenCode system under [`agents/`](/home/ubuntu/.config/opencode/agents), plus the cross-layer files that directly affect agent behavior in [`commands/`](/home/ubuntu/.config/opencode/commands), [`skills/`](/home/ubuntu/.config/opencode/skills), and [`config/`](/home/ubuntu/.config/opencode/config). It explicitly excludes a methodology comparison of this repo's SDD framework; SDD is mentioned only where it leaks into non-SDD execution or breaks agent behavior.

### Baseline sources

- Local system: [AGENTS.md](/home/ubuntu/.config/opencode/AGENTS.md), [README.md](/home/ubuntu/.config/opencode/README.md), [config/routing.json](/home/ubuntu/.config/opencode/config/routing.json), [config/grounding.md](/home/ubuntu/.config/opencode/config/grounding.md), [opencode.jsonc](/home/ubuntu/.config/opencode/opencode.jsonc)
- OpenCode docs: [Agents](https://opencode.ai/docs/agents/), [Skills](https://opencode.ai/docs/skills/), [Commands](https://opencode.ai/docs/commands/), [Rules](https://opencode.ai/docs/rules/), [Config](https://opencode.ai/docs/config/), [Custom Tools](https://opencode.ai/docs/custom-tools/)
- `agent-skills`: [README](https://github.com/addyosmani/agent-skills/blob/main/README.md), [OpenCode setup](https://github.com/addyosmani/agent-skills/blob/main/docs/opencode-setup.md), [Skill anatomy](https://github.com/addyosmani/agent-skills/blob/main/docs/skill-anatomy.md), [AGENTS.md](https://github.com/addyosmani/agent-skills/blob/main/AGENTS.md)

### Evaluation criteria

- OpenCode compliance
- skill-first orchestration quality
- execution safety and permission design
- lifecycle completeness
- verification rigor
- routing integrity
- duplication / overlap / dead config
- practical upgrade value

## Executive Verdict

### Overall maturity

**6.2/10**. This system is rich in domain coverage and better documented than most personal agent harnesses, but it is over-indexed on prompt surface area and under-indexed on actual OpenCode-native control points. It behaves more like a large prompt library with a routing manifest than a cohesive skill-driven operating system.

### Top structural weaknesses

- **Router-heavy instead of skill-first.** Local behavior is centered on [`config/routing.json`](/home/ubuntu/.config/opencode/config/routing.json), command wrappers, and long agent prompts, while `agent-skills` is explicitly built around automatic `skill` invocation and lifecycle skills rather than command routing. Source: [config/routing.json](/home/ubuntu/.config/opencode/config/routing.json), [workflow-commands/SKILL.md](/home/ubuntu/.config/opencode/skills/workflow-commands/SKILL.md), [`agent-skills` OpenCode setup](https://github.com/addyosmani/agent-skills/blob/main/docs/opencode-setup.md).
- **Permissions are effectively blanket allow.** 72/72 agents allow `bash`, 70/72 allow `edit`, and 70/72 allow `websearch`, even for review-only, audit-only, or architecture-only roles. This ignores the stronger least-privilege posture shown in OpenCode docs for agent permissions and built-in agent modes. Source: local agent frontmatter under [`agents/`](/home/ubuntu/.config/opencode/agents), [OpenCode Agents](https://opencode.ai/docs/agents/), [OpenCode Config](https://opencode.ai/docs/config/).
- **Most local skills are command routers, not actual skills.** They route to commands and agents, but they rarely encode the anti-rationalization, red flags, verification checklists, and workflow rigor that `agent-skills` standardizes. Source: local [`skills/`](/home/ubuntu/.config/opencode/skills), [`agent-skills` README](https://github.com/addyosmani/agent-skills/blob/main/README.md), [`agent-skills` skill anatomy](https://github.com/addyosmani/agent-skills/blob/main/docs/skill-anatomy.md).
- **Large agent sprawl with weak discoverability.** The repo has 72 agents but only 33 routes in [`config/routing.json`](/home/ubuntu/.config/opencode/config/routing.json). Many agents are command-only or effectively dormant under natural-language routing. Source: [`agents/`](/home/ubuntu/.config/opencode/agents), [config/routing.json](/home/ubuntu/.config/opencode/config/routing.json).
- **Trust is weakened by broken references and false guarantees.** Missing files and unverified runtime hooks create "documented behavior" that cannot be relied on. Source: local broken paths and missing files enumerated below.

### Top missing skill capabilities

- `using-agent-skills`
- `test-driven-development`
- `doubt-driven-development`
- `browser-testing-with-devtools`
- `debugging-and-error-recovery`
- `git-workflow-and-versioning`
- `documentation-and-adrs` as a real skill rather than scattered prompt prose

### Highest-risk broken links or false guarantees

- Missing [`agents/graph-router.agent.md`](/home/ubuntu/.config/opencode/agents/graph-router.agent.md), while it is referenced by [AGENTS.md](/home/ubuntu/.config/opencode/AGENTS.md), [agents/DEFAULT.AGENT.agent.md](/home/ubuntu/.config/opencode/agents/DEFAULT.AGENT.agent.md), and [agents/dev.agent-router.agent.md](/home/ubuntu/.config/opencode/agents/dev.agent-router.agent.md).
- Missing [`skills/visual-explainer/SKILL.md`](/home/ubuntu/.config/opencode/skills/visual-explainer/SKILL.md), while eight `visual:*` and review commands require it, including [commands/visual:generate-web-diagram.md](/home/ubuntu/.config/opencode/commands/visual:generate-web-diagram.md).
- `faithfulness_gate` is documented as mandatory in [AGENTS.md](/home/ubuntu/.config/opencode/AGENTS.md) and [agents/dev.faithfulness-guard.agent.md](/home/ubuntu/.config/opencode/agents/dev.faithfulness-guard.agent.md), but there is no verified OpenCode runtime integration path shown in [opencode.jsonc](/home/ubuntu/.config/opencode/opencode.jsonc) for exposing it.
- `verify_step` is documented as mandatory in [AGENTS.md](/home/ubuntu/.config/opencode/AGENTS.md). A local implementation exists at [tools/verify_step.ts](/home/ubuntu/.config/opencode/tools/verify_step.ts), but OpenCode's current custom tool docs expect tools under `.opencode/tools/` or `~/.config/opencode/tools/`; this repo stores them in `tools/` and does not document the bridge. Source: [OpenCode Custom Tools](https://opencode.ai/docs/custom-tools/), [tools/verify_step.ts](/home/ubuntu/.config/opencode/tools/verify_step.ts), [tools/faithfulness_gate.ts](/home/ubuntu/.config/opencode/tools/faithfulness_gate.ts).
- Missing [`docs/getting-started/judge-setup.md`](/home/ubuntu/.config/opencode/docs/getting-started/judge-setup.md) referenced by [agents/dev.judge-agent.agent.md](/home/ubuntu/.config/opencode/agents/dev.judge-agent.agent.md).

### Best next 5 upgrades

1. Replace the missing / false reference layer.
   Benefit: restores trust in the harness.
   Effort: low.
2. Add a real `using-agent-skills` meta-skill and make skill detection mandatory before command routing.
   Benefit: biggest architecture correction with low model-complexity cost.
   Effort: medium.
3. Harden agent permissions by role.
   Benefit: reduces accidental writes, shell misuse, and prompt drift.
   Effort: medium.
4. Collapse overlapping Spark, Lakeflow, AWS, GCP, and LLM specialist clusters.
   Benefit: better routing precision, lower maintenance, less contradictory guidance.
   Effort: medium-high.
5. Convert the current command-router skills into workflow skills with verification, rationalization counters, and exit evidence.
   Benefit: moves the system closer to `agent-skills` operating quality without abandoning OpenCode-native commands.
   Effort: high.

## Cross-System Findings

### 1. Routing model

**Finding:** the system is router-first, not skill-first.

- Local behavior is built around [`config/routing.json`](/home/ubuntu/.config/opencode/config/routing.json), a large prompt in [AGENTS.md](/home/ubuntu/.config/opencode/AGENTS.md), and command wrappers in [`commands/`](/home/ubuntu/.config/opencode/commands).
- `agent-skills` for OpenCode explicitly recommends automatic skill selection via `AGENTS.md` plus the built-in `skill` tool, with no manual command requirement for standard lifecycle tasks. Source: [`agent-skills` OpenCode setup](https://github.com/addyosmani/agent-skills/blob/main/docs/opencode-setup.md), [`agent-skills` AGENTS.md](https://github.com/addyosmani/agent-skills/blob/main/AGENTS.md).
- OpenCode supports skills as first-class reusable instruction units and allows per-agent skill permissions. Source: [OpenCode Skills](https://opencode.ai/docs/skills/).

**Gap:** your current routing approach makes commands and agents the primary orchestration surface; skills mostly sit underneath as indirection.

**Why it matters:** long prompts are harder to maintain than reusable lifecycle skills, and routing logic becomes duplicated across `AGENTS.md`, `config/routing.json`, command frontmatter, and skill wrapper prose.

### 2. Skill model

**Finding:** most local skills are not "skills" in the `agent-skills` sense.

- Local skills such as [skills/workflow-commands/SKILL.md](/home/ubuntu/.config/opencode/skills/workflow-commands/SKILL.md), [skills/core-commands/SKILL.md](/home/ubuntu/.config/opencode/skills/core-commands/SKILL.md), [skills/data-engineering/SKILL.md](/home/ubuntu/.config/opencode/skills/data-engineering/SKILL.md), and [skills/review/SKILL.md](/home/ubuntu/.config/opencode/skills/review/SKILL.md) mainly route commands to agents and canonical files.
- `agent-skills` defines skills as workflows with explicit "when to use", core process, common rationalizations, red flags, and verification. Source: [`agent-skills` README](https://github.com/addyosmani/agent-skills/blob/main/README.md), [`agent-skills` skill anatomy](https://github.com/addyosmani/agent-skills/blob/main/docs/skill-anatomy.md).

**Gap:** the local skill layer is thin orchestration metadata; the real behavior remains in giant agent prompts.

**Why it matters:** the system cannot easily reuse verification discipline across agents, and improvements require editing many prompts instead of one skill.

### 3. Permission model

**Finding:** local permissions are far more permissive than the current OpenCode model encourages.

- OpenCode docs show restrictive examples for review-only or doc-only agents and support disabling tools and narrowing permissions per agent. Source: [OpenCode Agents](https://opencode.ai/docs/agents/), [OpenCode Skills](https://opencode.ai/docs/skills/), [OpenCode Config](https://opencode.ai/docs/config/).
- The local agent set uses near-universal `allow` on `bash`, `edit`, `task`, `skill`, `websearch`, and `webfetch`.
- There is no use of `hidden`, and no local use of scoped `permission.task` rules despite OpenCode's task-permission model. Source: [OpenCode Agents](https://opencode.ai/docs/agents/).

**Gap:** the harness assumes prompt discipline will prevent misuse instead of using OpenCode's control surface.

**Why it matters:** architecture agents can write files, security agents can edit code, review agents can mutate state, and read-only roles are not actually read-only.

### 4. Context model

**Finding:** local context loading is disciplined in prose but not fully reflected in config-native features.

- [AGENTS.md](/home/ubuntu/.config/opencode/AGENTS.md) and [config/grounding.md](/home/ubuntu/.config/opencode/config/grounding.md) push progressive disclosure and lazy loading.
- [opencode.jsonc](/home/ubuntu/.config/opencode/opencode.jsonc) is effectively empty, so it does not use OpenCode's `instructions`, `agent`, `permission`, `command`, `references`, `mcp`, or `plugin` config surfaces. Source: [opencode.jsonc](/home/ubuntu/.config/opencode/opencode.jsonc), [OpenCode Config](https://opencode.ai/docs/config/), [OpenCode Rules](https://opencode.ai/docs/rules/).
- `agent-skills` expects the skills directory and `AGENTS.md` to do most of the orchestration work; your system still needs multiple parallel registries and manifests to behave. Source: [`agent-skills` OpenCode setup](https://github.com/addyosmani/agent-skills/blob/main/docs/opencode-setup.md).

**Gap:** the system's context discipline is mostly advisory text, not configuration.

**Why it matters:** behavior depends too much on prompt compliance and too little on platform features.

### 5. Integrity check

**Confirmed breakage**

- Missing [`agents/graph-router.agent.md`](/home/ubuntu/.config/opencode/agents/graph-router.agent.md) but referenced in [AGENTS.md](/home/ubuntu/.config/opencode/AGENTS.md), [agents/DEFAULT.AGENT.agent.md](/home/ubuntu/.config/opencode/agents/DEFAULT.AGENT.agent.md), [agents/dev.agent-router.agent.md](/home/ubuntu/.config/opencode/agents/dev.agent-router.agent.md).
- Missing [`skills/visual-explainer/SKILL.md`](/home/ubuntu/.config/opencode/skills/visual-explainer/SKILL.md) but required by [commands/visual:generate-web-diagram.md](/home/ubuntu/.config/opencode/commands/visual:generate-web-diagram.md) and seven sibling commands.
- Missing [`docs/getting-started/judge-setup.md`](/home/ubuntu/.config/opencode/docs/getting-started/judge-setup.md) referenced by [agents/dev.judge-agent.agent.md](/home/ubuntu/.config/opencode/agents/dev.judge-agent.agent.md).
- Tools live under [`tools/`](/home/ubuntu/.config/opencode/tools) instead of the documented `.opencode/tools/` or `~/.config/opencode/tools/` locations. Source: [OpenCode Custom Tools](https://opencode.ai/docs/custom-tools/).

**Design weakness**

- 39 of 72 agents are not represented in [`config/routing.json`](/home/ubuntu/.config/opencode/config/routing.json), so they are not natural-language discoverable through the fallback router. Some are still reachable via explicit commands.
- 70/72 agents include a `## Grounding` section, but only 38/72 include a `## Quality Gate` and 21/72 include explicit stop conditions. Verification rigor is inconsistent.
- Nearly every agent includes an extra `---` separator after the grounding block, which is harmless in markdown but signals template-cloning without cleanup. Example: [agents/architect.the-planner.agent.md](/home/ubuntu/.config/opencode/agents/architect.the-planner.agent.md).

**Optional improvement**

- The global [opencode.jsonc](/home/ubuntu/.config/opencode/opencode.jsonc) could lift some rules out of prompts into actual platform config.
- Some command-only agents could be replaced with built-in OpenCode agent modes plus a smaller skill layer.

## Full Agent-by-Agent Dossier

### Reading guide

Each line below covers one local agent exactly once and includes:

- what it currently does well
- exact gaps
- why the gap matters
- which `agent-skills` pattern would improve it
- where the fix belongs
- recommended action

Family judgments are based on the local agent file plus the baseline docs linked above.

## `workflow.*`

- [`workflow.brainstorm-agent.agent.md`](/home/ubuntu/.config/opencode/agents/workflow.brainstorm-agent.agent.md): Strong structure for ambiguity reduction and context loading. Gaps: command-first, SDD-coupled, full-write permissions for a discovery role, no mandatory skill invocation, and no reusable `idea-refine` style workflow. Why it matters: ideation quality depends on one agent prompt instead of a reusable skill. Improve with `idea-refine`, `interview-me`, and `planning-and-task-breakdown`. Fix layer: `skill`, `permissions`. Action: keep, but rewrite as a read-mostly ideation agent backed by a real idea-refinement skill.
- [`workflow.define-agent.agent.md`](/home/ubuntu/.config/opencode/agents/workflow.define-agent.agent.md): Good requirements extraction and clarity scoring. Gaps: bound to local workflow phase semantics, broad tool permissions, and no `source-driven-development` or doubt-check discipline. Why it matters: requirement quality depends on prompt compliance instead of evidence gates. Improve with `spec-driven-development`, `source-driven-development`, `doubt-driven-development`. Fix layer: `skill`, `permissions`. Action: keep, but narrow permissions and move the workflow into a skill.
- [`workflow.design-agent.agent.md`](/home/ubuntu/.config/opencode/agents/workflow.design-agent.agent.md): Good architecture and agent-matching intent. Gaps: overlaps `architect.the-planner`, `product.system-design-agent`, and `architect.*`; no agent task scoping; no skill-first design workflow. Why it matters: design authority is split across too many prompts. Improve with `planning-and-task-breakdown`, `api-and-interface-design`, `documentation-and-adrs`. Fix layer: `routing`, `skill`. Action: merge design logic with planner/system-design patterns or sharply reduce scope.
- [`workflow.build-agent.agent.md`](/home/ubuntu/.config/opencode/agents/workflow.build-agent.agent.md): Best orchestration intent in the local system; it extracts tasks and delegates specialists. Gaps: no actual `verify_step` integration, full mutable permissions, and relies on specialist prompts instead of reusable implementation/test/debug skills. Why it matters: the build loop is documented as stricter than it really is. Improve with `incremental-implementation`, `test-driven-development`, `debugging-and-error-recovery`. Fix layer: `skill`, `tool`, `permissions`. Action: keep, but rebuild around real implementation and verification skills.
- [`workflow.validate-agent.agent.md`](/home/ubuntu/.config/opencode/agents/workflow.validate-agent.agent.md): Strongest local quality-gate ambition; clear artifact gating and scoring logic. Gaps: relies on generic background task behavior, mixes orchestration and policy in one prompt, and is not aligned with OpenCode's simpler agent/tool idioms. Why it matters: it is hard to trust or evolve. Improve with `code-review-and-quality`, `shipping-and-launch`, `debugging-and-error-recovery`. Fix layer: `skill`, `tool`, `command`. Action: keep conceptually, but split execution logic into tools/skills and shrink prompt surface.
- [`workflow.ship-agent.agent.md`](/home/ubuntu/.config/opencode/agents/workflow.ship-agent.agent.md): Good completion/archive focus. Gaps: depends on upstream workflow artifacts, broad permissions, and no real `git-workflow-and-versioning` or launch checklist skill. Why it matters: shipping remains prompt-defined instead of operationally enforced. Improve with `shipping-and-launch`, `git-workflow-and-versioning`, `documentation-and-adrs`. Fix layer: `skill`, `permissions`. Action: keep, but turn it into a narrow release coordinator with explicit immutable checks.
- [`workflow.iterate-agent.agent.md`](/home/ubuntu/.config/opencode/agents/workflow.iterate-agent.agent.md): Useful cascade-awareness concept. Gaps: not represented in [`config/routing.json`](/home/ubuntu/.config/opencode/config/routing.json), phase-specific, broad permissions, and likely over-specialized relative to general change-planning skills. Why it matters: maintenance overhead is high for a narrow behavior. Improve with `planning-and-task-breakdown` and `documentation-and-adrs`. Fix layer: `routing`, `skill`. Action: keep only if the local workflow truly depends on it; otherwise fold into planner/design flows.

## `dev.*`

- [`dev.agent-router.agent.md`](/home/ubuntu/.config/opencode/agents/dev.agent-router.agent.md): Clear intent to keep routing explainable and lightweight. Gaps: references missing `graph-router`, duplicates [config/routing.json](/home/ubuntu/.config/opencode/config/routing.json), and is itself not in that routing fallback. Why it matters: the router layer is self-inconsistent. Improve with `using-agent-skills`. Fix layer: `agent`, `routing`. Action: rewrite or deprecate; a missing router cannot be the canonical router.
- [`dev.codebase-explorer.agent.md`](/home/ubuntu/.config/opencode/agents/dev.codebase-explorer.agent.md): Useful repo-inspection stance. Gaps: overlaps OpenCode's built-in read-only/explore mode, still has mutable permissions, and carries prompt bulk for a problem the platform already solves. Why it matters: unnecessary custom agent surface. Improve with `context-engineering` and built-in explore mode. Fix layer: `agent`, `config`. Action: replace with built-in explore where possible; keep only truly repo-specific behavior.
- [`dev.faithfulness-guard.agent.md`](/home/ubuntu/.config/opencode/agents/dev.faithfulness-guard.agent.md): Strong auditing idea and one of the few role-specific governance agents. Gaps: depends on `faithfulness_gate`, which is documented but not proven integrated at runtime; broad permissions are unnecessary. Why it matters: governance without enforceable hooks becomes ceremonial. Improve with `doubt-driven-development` and `source-driven-development`. Fix layer: `tool`, `permissions`, `config`. Action: keep, but make it read-only and wire the tool path correctly or remove the false guarantee.
- [`dev.judge-agent.agent.md`](/home/ubuntu/.config/opencode/agents/dev.judge-agent.agent.md): Useful second-opinion pattern for high-stakes outputs. Gaps: missing setup doc, external-runtime dependency, broad write permissions, and roadmap prose that belongs elsewhere. Why it matters: advisory tooling should be crisp and auditable. Improve with `code-review-and-quality` and `security-and-hardening`. Fix layer: `agent`, `command`, `docs`, `permissions`. Action: keep, but trim to a strict read-only review runtime wrapper.
- [`dev.meeting-analyst.agent.md`](/home/ubuntu/.config/opencode/agents/dev.meeting-analyst.agent.md): Clear niche utility and command fit. Gaps: not routed naturally, broad permissions, and no reusable documentation/decision-capture skill. Why it matters: useful but under-integrated. Improve with `documentation-and-adrs`. Fix layer: `skill`, `permissions`. Action: keep as command-only, but reduce privileges and back it with a documentation skill.
- [`dev.prompt-crafter.agent.md`](/home/ubuntu/.config/opencode/agents/dev.prompt-crafter.agent.md): Useful prompt-engineering niche. Gaps: overlaps `python.ai-prompt-specialist`, `python.llm-specialist`, and `cloud.ai-prompt-specialist-gcp`; not routed naturally. Why it matters: prompt expertise is fragmented three ways. Improve with `api-and-interface-design`, `source-driven-development`, `doubt-driven-development`. Fix layer: `routing`, `agent`. Action: merge with the Python LLM/prompt cluster.
- [`dev.security-guardian.agent.md`](/home/ubuntu/.config/opencode/agents/dev.security-guardian.agent.md): Strongest concrete security protocol in the repo; clear pre-commit, secrets, and commit gating behavior. Gaps: policy is local and prompt-enforced rather than OpenCode-permission-enforced, and it assumes tools/config that are not wired via [opencode.jsonc](/home/ubuntu/.config/opencode/opencode.jsonc). Why it matters: this is high-value, but the current integration is softer than the prompt implies. Improve with `security-and-hardening` and `git-workflow-and-versioning`. Fix layer: `skill`, `config`, `permissions`. Action: keep and elevate; this should become a real cross-cutting skill, not just an agent.
- [`dev.shell-script-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/dev.shell-script-specialist.agent.md): Practical utility and strong template orientation. Gaps: not routed naturally, very broad permissions, and the prompt includes scaffold/template material that should live in a skill or template file. Why it matters: prompt noise and maintenance drift. Improve with `incremental-implementation` and `documentation-and-adrs`. Fix layer: `skill`, `agent`. Action: keep only if shell work is common; otherwise fold into a smaller implementation skill.

## `architect.*`

- [`architect.data-platform-engineer.agent.md`](/home/ubuntu/.config/opencode/agents/architect.data-platform-engineer.agent.md): Good coverage of platform comparison and cost concerns. Gaps: not in natural-language routing, overlaps `architect.lakehouse-architect` and cloud data architects, and has write permissions despite being architecture-first. Why it matters: routing ambiguity and unnecessary mutability. Improve with `planning-and-task-breakdown`, `api-and-interface-design`, `performance-optimization`. Fix layer: `routing`, `permissions`. Action: merge into a smaller data-platform architecture tier.
- [`architect.genai-architect.agent.md`](/home/ubuntu/.config/opencode/agents/architect.genai-architect.agent.md): Strong domain alignment for agentic systems, RAG, and guardrails. Gaps: no real skill consumption, overlaps prompt/LLM specialists, and architecture advice is not grounded in reusable workflows. Why it matters: AI architecture is one of the fastest-changing parts of the stack. Improve with `source-driven-development`, `api-and-interface-design`, `context-engineering`. Fix layer: `skill`, `routing`. Action: keep, but make it a strict architect role backed by smaller GenAI skills.
- [`architect.kb-architect.agent.md`](/home/ubuntu/.config/opencode/agents/architect.kb-architect.agent.md): One of the cleanest local agents; clear artifact ownership and anti-patterns. Gaps: still over-prompted compared with what a true knowledge-maintenance skill could do; write permissions are fine but broader shell/web rights should be narrower. Why it matters: this is a good candidate for a platform-native skill-first rewrite. Improve with `documentation-and-adrs`, `source-driven-development`. Fix layer: `skill`, `permissions`. Action: keep and elevate into a canonical knowledge skill owner.
- [`architect.lakehouse-architect.agent.md`](/home/ubuntu/.config/opencode/agents/architect.lakehouse-architect.agent.md): Good domain specificity and concrete capabilities. Gaps: natural-language unrouted, overlaps `architect.data-platform-engineer`, `architect.medallion-architect`, `data-engineering.lakeflow-*`, and cloud data architects. Why it matters: domain precision is lost in cluster sprawl. Improve with `api-and-interface-design`, `performance-optimization`, `deprecation-and-migration`. Fix layer: `routing`, `agent`. Action: keep but narrow; this should own format/catalog architecture only.
- [`architect.medallion-architect.agent.md`](/home/ubuntu/.config/opencode/agents/architect.medallion-architect.agent.md): Clear medallion focus. Gaps: thinner than neighboring architect agents, no quality gate, and likely too narrow to justify a separate always-loaded persona. Why it matters: one more routing branch for a pattern that could be a section in lakehouse/lakeflow skills. Improve with `spec-driven-development` and `source-driven-development`. Fix layer: `skill`, `routing`. Action: deprecate as a standalone agent and move guidance into lakehouse/lakeflow skills.
- [`architect.pipeline-architect.agent.md`](/home/ubuntu/.config/opencode/agents/architect.pipeline-architect.agent.md): Useful orchestration and DAG-design depth. Gaps: natural-language unrouted, overlaps Airflow and workflow build/design agents, and has too much mutable power for an architect. Why it matters: increases planner/design duplication. Improve with `planning-and-task-breakdown`, `ci-cd-and-automation`, `observability-and-instrumentation`. Fix layer: `routing`, `permissions`. Action: keep only if you want a pipeline-specific architect distinct from Airflow/Spark operators; otherwise merge.
- [`architect.schema-designer.agent.md`](/home/ubuntu/.config/opencode/agents/architect.schema-designer.agent.md): Strong domain clarity and useful capability coverage. Gaps: relies on prompt-only method, broad permissions, and overlaps `product.system-design-agent` for interface boundaries. Why it matters: schema design advice should be evidence-driven and test-coupled. Improve with `api-and-interface-design`, `source-driven-development`, `test-driven-development`. Fix layer: `skill`, `permissions`. Action: keep, but pair with a real schema-design skill and test/contract companion.
- [`architect.the-planner.agent.md`](/home/ubuntu/.config/opencode/agents/architect.the-planner.agent.md): Best default agent choice among the local set; clear planning role and strong templates. Gaps: full mutable permissions conflict with its planning identity, it overlaps workflow define/design, and it still treats MCP and KB usage as prose rather than platform control. Why it matters: the default planner should be the strictest agent, not a general mutator. Improve with `using-agent-skills`, `planning-and-task-breakdown`, `doubt-driven-development`. Fix layer: `permissions`, `agent`, `config`. Action: keep as default, but redesign it to behave more like OpenCode's restrictive plan agent.

## `product.*`

- [`product.external-integration-agent.agent.md`](/home/ubuntu/.config/opencode/agents/product.external-integration-agent.agent.md): Good operational framing around syncs, idempotency, and reconciliation. Gaps: no dedicated integration skill, prompt overlap with system-design and backend agents, and broad permissions. Why it matters: integration work benefits from repeatable workflows more than persona variety. Improve with `api-and-interface-design`, `debugging-and-error-recovery`, `observability-and-instrumentation`. Fix layer: `skill`, `permissions`. Action: keep, but back it with a true integration workflow skill.
- [`product.frontend-react-agent.agent.md`](/home/ubuntu/.config/opencode/agents/product.frontend-react-agent.agent.md): Clear product-facing React guidance and one of the better anti-pattern sections. Gaps: no browser-testing skill, no component QA workflow, and too much of the real workflow lives in prose. Why it matters: frontend quality needs actual verification loops, not just good advice. Improve with `frontend-ui-engineering`, `browser-testing-with-devtools`, `test-driven-development`. Fix layer: `skill`. Action: keep and turn it into the consumer of frontend/browser skills.
- [`product.rules-qa-agent.agent.md`](/home/ubuntu/.config/opencode/agents/product.rules-qa-agent.agent.md): Good focus on edge cases and rule drift. Gaps: narrow routing, broad permissions, and no reusable rules-validation skill. Why it matters: rules QA is valuable but should be portable across domains. Improve with `doubt-driven-development`, `test-driven-development`, `source-driven-development`. Fix layer: `skill`, `permissions`. Action: keep as a specialist, but shrink to a read-mostly auditor role.
- [`product.supabase-backend-agent.agent.md`](/home/ubuntu/.config/opencode/agents/product.supabase-backend-agent.agent.md): Strong practical product/backend framing and useful RLS emphasis. Gaps: overlaps `cloud.supabase-specialist`, broad permissions, and no complementary security-hardening or migration skills. Why it matters: Supabase is one of the few places where strict least privilege matters a lot. Improve with `security-and-hardening`, `api-and-interface-design`, `deprecation-and-migration`. Fix layer: `routing`, `permissions`, `skill`. Action: keep as the canonical Supabase app/backend agent; merge the cloud Supabase specialist into it.
- [`product.system-design-agent.agent.md`](/home/ubuntu/.config/opencode/agents/product.system-design-agent.agent.md): Good product-architecture bridge and useful module/interface emphasis. Gaps: overlaps planner and several architect agents; broad permissions; no real ADR/documentation workflow. Why it matters: system design should be a high-trust, low-mutation activity. Improve with `planning-and-task-breakdown`, `documentation-and-adrs`, `api-and-interface-design`. Fix layer: `routing`, `permissions`, `skill`. Action: keep, but reduce overlap and turn it into the product-facing architecture front door.
- [`product.ux-design-system-agent.agent.md`](/home/ubuntu/.config/opencode/agents/product.ux-design-system-agent.agent.md): Good UI-kit and IA awareness. Gaps: no design review/browser verification skill, broad permissions, and overlap with standalone dashboard layout specialization. Why it matters: design-system advice without actual UI review workflows stays theoretical. Improve with `frontend-ui-engineering`, `browser-testing-with-devtools`, `documentation-and-adrs`. Fix layer: `skill`, `routing`. Action: keep and make it the consumer of frontend/design skills rather than a giant standalone prompt.

## `python.*`

- [`python.ai-prompt-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/python.ai-prompt-specialist.agent.md): Useful prompt-specific capability set. Gaps: heavy overlap with `python.llm-specialist`, `dev.prompt-crafter`, and `cloud.ai-prompt-specialist-gcp`; broad permissions. Why it matters: one conceptual domain is fragmented across four agents. Improve with `context-engineering`, `source-driven-development`, `doubt-driven-development`. Fix layer: `routing`, `agent`. Action: merge into a single prompt/LLM design cluster.
- [`python.code-cleaner.agent.md`](/home/ubuntu/.config/opencode/agents/python.code-cleaner.agent.md): Good simplification intent and practical cleanup capabilities. Gaps: no explicit evidence checks, broad permissions, and prompt overlap with `python.python-developer`. Why it matters: simplification should be a reusable workflow with red flags and fences. Improve with `code-simplification`. Fix layer: `skill`, `permissions`. Action: keep only if it becomes the consumer of a true simplification skill.
- [`python.code-documenter.agent.md`](/home/ubuntu/.config/opencode/agents/python.code-documenter.agent.md): Useful doc generation scope. Gaps: broad permissions, duplicate documentation guidance across repo, and no ADR/documentation skill. Why it matters: documentation should be standardized once. Improve with `documentation-and-adrs`. Fix layer: `skill`, `permissions`. Action: keep as a thin specialist or fold into a documentation skill.
- [`python.code-reviewer.agent.md`](/home/ubuntu/.config/opencode/agents/python.code-reviewer.agent.md): High practical value; one of the best local specialists. Gaps: review-only role still has write/bash/web permissions, and it is not as workflow-rich as `code-review-and-quality`. Why it matters: this is the clearest candidate for a locked-down, high-trust review agent. Improve with `code-review-and-quality`, `security-and-hardening`, `performance-optimization`. Fix layer: `permissions`, `skill`. Action: keep and harden.
- [`python.llm-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/python.llm-specialist.agent.md): Good coverage of structured outputs and prompt patterns. Gaps: substantial overlap with prompt-crafter and AI prompt specialists; broad permissions; lacks explicit "when not to use". Why it matters: routing becomes fuzzy and agent behavior becomes inconsistent. Improve with `context-engineering`, `api-and-interface-design`, `source-driven-development`. Fix layer: `routing`, `agent`. Action: merge with prompt-crafter / AI prompt agents.
- [`python.python-developer.agent.md`](/home/ubuntu/.config/opencode/agents/python.python-developer.agent.md): Useful general implementation fallback. Gaps: weak verification and anti-pattern rigor compared with other agents, broad permissions, and overlap with build agent. Why it matters: fallback implementers should be simple and safe. Improve with `incremental-implementation`, `test-driven-development`, `debugging-and-error-recovery`. Fix layer: `skill`, `permissions`. Action: keep as a general builder, but slim the prompt and let skills carry the process.

## `test.*`

- [`test.data-contracts-engineer.agent.md`](/home/ubuntu/.config/opencode/agents/test.data-contracts-engineer.agent.md): Strong ownership of contracts, SLAs, and breaking-change detection. Gaps: natural-language unrouted, broad permissions, and could be a powerful skill rather than a rarely discovered persona. Why it matters: contract discipline should be easier to invoke. Improve with `test-driven-development`, `source-driven-development`, `documentation-and-adrs`. Fix layer: `skill`, `routing`, `permissions`. Action: keep, but promote into a first-class contract skill.
- [`test.data-quality-analyst.agent.md`](/home/ubuntu/.config/opencode/agents/test.data-quality-analyst.agent.md): Good quality/observability framing and useful capability set. Gaps: mutable permissions and no generalized debugging/verification skill around failures. Why it matters: data-quality is a repeated workflow domain. Improve with `test-driven-development`, `debugging-and-error-recovery`, `observability-and-instrumentation`. Fix layer: `skill`, `permissions`. Action: keep and pair with a data-quality workflow skill.
- [`test.test-generator.agent.md`](/home/ubuntu/.config/opencode/agents/test.test-generator.agent.md): Useful generation breadth and one of the stronger test-oriented prompts. Gaps: not actually TDD, too broad across unit/integration/data tests, and still overly permissive. Why it matters: "generate tests" is not the same as "enforce test-first workflow". Improve with `test-driven-development`. Fix layer: `skill`, `permissions`. Action: keep as a helper, but do not treat it as TDD coverage.

## `data-engineering.*`

- [`data-engineering.ai-data-engineer.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.ai-data-engineer.agent.md): Useful AI-data pipeline scope. Gaps: not in routing fallback, overlaps cloud AI data engineer variants, and could be expressed as a skill. Why it matters: AI data engineering is split across too many personas. Improve with `context-engineering`, `source-driven-development`, `observability-and-instrumentation`. Fix layer: `routing`, `agent`. Action: merge with the cloud AI data engineer cluster or make this the single canonical AI data agent.
- [`data-engineering.airflow-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.airflow-specialist.agent.md): Good Airflow-specific depth. Gaps: overlaps `architect.pipeline-architect`, broad permissions, and lacks a smaller orchestration skill. Why it matters: users need workflow reuse more than persona branching. Improve with `ci-cd-and-automation`, `debugging-and-error-recovery`, `observability-and-instrumentation`. Fix layer: `skill`, `permissions`. Action: keep, but reduce overlap with pipeline architect.
- [`data-engineering.dbt-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.dbt-specialist.agent.md): Strong domain fit and concrete dbt capabilities. Gaps: still prompt-heavy, broad permissions, and not paired with a real test-first analytics-engineering skill. Why it matters: dbt is one of the cleanest candidates for workflow skills. Improve with `test-driven-development`, `source-driven-development`, `deprecation-and-migration`. Fix layer: `skill`, `permissions`. Action: keep and back it with dbt workflow skills.
- [`data-engineering.lakeflow-architect.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.lakeflow-architect.agent.md): Clear architecture role. Gaps: one of four Lakeflow agents; natural-language unrouted; broad permissions. Why it matters: this cluster is over-segmented. Improve with `planning-and-task-breakdown`, `observability-and-instrumentation`. Fix layer: `routing`, `agent`. Action: merge into a two-agent Lakeflow model at most.
- [`data-engineering.lakeflow-expert.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.lakeflow-expert.agent.md): Good production-operations emphasis. Gaps: overlaps architect, builder, and specialist agents. Why it matters: duplicate guidance increases drift. Improve with `debugging-and-error-recovery`, `observability-and-instrumentation`. Fix layer: `agent`, `skill`. Action: fold its operational guidance into a single Lakeflow skill and keep one specialist agent.
- [`data-engineering.lakeflow-pipeline-builder.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.lakeflow-pipeline-builder.agent.md): Practical builder niche. Gaps: cluster overlap and broad permissions. Why it matters: builder vs expert vs architect boundaries are too fine. Improve with `incremental-implementation`, `test-driven-development`. Fix layer: `skill`, `agent`. Action: keep only if you collapse the other Lakeflow agents.
- [`data-engineering.lakeflow-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.lakeflow-specialist.agent.md): Good general entry point. Gaps: cluster overlap and no strong reason to coexist with architect/expert/builder. Why it matters: too many similar entry points. Improve with `using-agent-skills` and `source-driven-development`. Fix layer: `routing`. Action: keep as the single Lakeflow front door if the cluster is consolidated.
- [`data-engineering.qdrant-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.qdrant-specialist.agent.md): Helpful vendor-specific niche. Gaps: natural-language unrouted, broad permissions, and likely low-frequency compared with generic vector/RAG patterns. Why it matters: niche agents should earn their maintenance cost. Improve with `context-engineering`, `api-and-interface-design`. Fix layer: `routing`, `skill`. Action: keep only if Qdrant is a regular target; otherwise fold into GenAI/vector skills.
- [`data-engineering.spark-engineer.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.spark-engineer.agent.md): Practical implementation role. Gaps: overlaps Spark specialist/troubleshooter/perf/streaming architect. Why it matters: the Spark cluster is too fragmented. Improve with `incremental-implementation`, `performance-optimization`, `debugging-and-error-recovery`. Fix layer: `agent`, `routing`. Action: merge the Spark cluster into two roles: builder and diagnostician.
- [`data-engineering.spark-performance-analyzer.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.spark-performance-analyzer.agent.md): Valuable optimization lens. Gaps: narrow and unrouted; likely better as a skill/checklist than a standalone agent. Why it matters: performance advice should be callable inside broader Spark work. Improve with `performance-optimization`. Fix layer: `skill`. Action: deprecate as a standalone agent; turn it into a performance skill.
- [`data-engineering.spark-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.spark-specialist.agent.md): Good general Spark entry point. Gaps: too much overlap with other Spark agents and broad permissions. Why it matters: users should not need five Spark personas. Improve with `incremental-implementation`, `debugging-and-error-recovery`, `performance-optimization`. Fix layer: `routing`, `permissions`. Action: keep as the canonical Spark front door if the cluster is collapsed.
- [`data-engineering.spark-streaming-architect.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.spark-streaming-architect.agent.md): Good specialized architecture scope. Gaps: overlaps `data-engineering.streaming-engineer` and Spark specialist; likely too narrow for a separate agent. Why it matters: cluster sprawl. Improve with `planning-and-task-breakdown`, `observability-and-instrumentation`. Fix layer: `agent`, `skill`. Action: merge into streaming engineer or Spark front door.
- [`data-engineering.spark-troubleshooter.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.spark-troubleshooter.agent.md): Helpful failure-centric stance. Gaps: narrow, unrouted, broad permissions, and should really be a debugging skill. Why it matters: debugging is a reusable workflow, not just a persona. Improve with `debugging-and-error-recovery`. Fix layer: `skill`. Action: deprecate as standalone and keep its logic as a Spark debugging skill.
- [`data-engineering.sql-optimizer.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.sql-optimizer.agent.md): High practical value and clear optimization focus. Gaps: overlaps code-reviewer for SQL review, broad permissions, and no explicit evidence loop. Why it matters: optimization advice should be reproducible and benchmark-aware. Improve with `performance-optimization`, `code-review-and-quality`. Fix layer: `skill`, `permissions`. Action: keep as a specialized optimizer but make it read-mostly.
- [`data-engineering.streaming-engineer.agent.md`](/home/ubuntu/.config/opencode/agents/data-engineering.streaming-engineer.agent.md): Good general streaming/C DC scope. Gaps: overlaps Spark streaming architect and AI pipeline concerns. Why it matters: streaming should be the front door, with subskills for platform specifics. Improve with `debugging-and-error-recovery`, `observability-and-instrumentation`, `performance-optimization`. Fix layer: `routing`, `skill`. Action: keep as the canonical streaming agent and absorb narrower streaming personas.

## `cloud.*`

- [`cloud.ai-data-engineer-cloud.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.ai-data-engineer-cloud.agent.md): Broad, useful cloud data + observability framing. Gaps: overlaps GCP-specific and generic AI data agents; very large prompt; unrouted. Why it matters: high maintenance for ambiguous scope. Improve with `observability-and-instrumentation`, `ci-cd-and-automation`, `source-driven-development`. Fix layer: `agent`, `routing`. Action: merge with the AI data engineer cluster.
- [`cloud.ai-data-engineer-gcp.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.ai-data-engineer-gcp.agent.md): Good GCP service specificity. Gaps: overlaps `cloud.gcp-data-architect` and generic AI data agents; broad permissions. Why it matters: service/vendor split is too fine. Improve with `api-and-interface-design`, `performance-optimization`, `observability-and-instrumentation`. Fix layer: `routing`, `agent`. Action: merge into a single GCP data/AI architect agent.
- [`cloud.ai-prompt-specialist-gcp.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.ai-prompt-specialist-gcp.agent.md): Strong vendor-specific prompt depth. Gaps: heavy overlap with other prompt/LLM agents; large prompt surface; broad permissions. Why it matters: prompt expertise is fragmented. Improve with `context-engineering`, `source-driven-development`. Fix layer: `agent`. Action: merge into a unified prompt/LLM specialization layer.
- [`cloud.aws-data-architect.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.aws-data-architect.agent.md): Clear AWS architecture fit and good boundaries. Gaps: overlaps deployer/lambda/builder roles and broad permissions for an architect. Why it matters: separation of design vs implementation is weak. Improve with `planning-and-task-breakdown`, `ci-cd-and-automation`. Fix layer: `permissions`, `routing`. Action: keep as the AWS architecture front door.
- [`cloud.aws-deployer.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.aws-deployer.agent.md): Practical deployment/runbook focus. Gaps: unrouted, large prompt, and overlaps lambda builder/architect. Why it matters: deployment can be a skill with an AWS executor agent. Improve with `ci-cd-and-automation`, `shipping-and-launch`, `git-workflow-and-versioning`. Fix layer: `skill`, `agent`. Action: fold into AWS implementation/release workflows.
- [`cloud.aws-lambda-architect.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.aws-lambda-architect.agent.md): Useful least-privilege/IAM emphasis. Gaps: overlaps AWS data architect and lambda builder; broad permissions. Why it matters: three Lambda/AWS roles are too many. Improve with `security-and-hardening`, `api-and-interface-design`. Fix layer: `routing`, `agent`. Action: keep only if you collapse builder/deployer into it or under it.
- [`cloud.ci-cd-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.ci-cd-specialist.agent.md): Important lifecycle domain. Gaps: unrouted, broad permissions, and could be a reusable skill rather than cloud-only prompt. Why it matters: CI/CD is a cross-cutting workflow, not a cloud silo. Improve with `ci-cd-and-automation`, `shipping-and-launch`, `git-workflow-and-versioning`. Fix layer: `skill`. Action: keep domain knowledge, but migrate the workflow into a first-class skill.
- [`cloud.container-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.container-specialist.agent.md): One of the stronger cloud agents; concrete scope and good stop conditions. Gaps: write/web perms are still too open, and container workflows are not skillized. Why it matters: container work is repeatable and safety-sensitive. Improve with `ci-cd-and-automation`, `security-and-hardening`, `performance-optimization`. Fix layer: `skill`, `permissions`. Action: keep as a high-value specialist with tighter permissions.
- [`cloud.gcp-data-architect.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.gcp-data-architect.agent.md): Good architectural scope. Gaps: overlaps GCP AI data engineer and generic cloud AI data engineer. Why it matters: same vendor/domain split repeated. Improve with `planning-and-task-breakdown`, `api-and-interface-design`. Fix layer: `routing`, `agent`. Action: merge with the GCP AI/data variant.
- [`cloud.lambda-builder.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.lambda-builder.agent.md): Useful implementation helper. Gaps: overlaps AWS deployer and lambda architect; large mutable surface. Why it matters: builder logic should be a skill or a subordinate implementation agent, not a peer to architects. Improve with `incremental-implementation`, `test-driven-development`. Fix layer: `skill`, `agent`. Action: collapse into the AWS/Lambda cluster.
- [`cloud.supabase-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/cloud.supabase-specialist.agent.md): Useful Supabase + AI data crossover. Gaps: overlaps `product.supabase-backend-agent`, is unrouted, and has ambiguous scope. Why it matters: two Supabase front doors fragment guidance. Improve with `security-and-hardening`, `api-and-interface-design`, `context-engineering`. Fix layer: `routing`, `agent`. Action: merge into `product.supabase-backend-agent`.

## `platform.*`

- [`platform.fabric-ai-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/platform.fabric-ai-specialist.agent.md): Clear vendor/AI niche. Gaps: unrouted and overlaps Fabric architect plus generic GenAI agents. Why it matters: platform-specific AI should be a sub-skill, not always a full agent. Improve with `context-engineering`, `api-and-interface-design`. Fix layer: `skill`, `routing`. Action: fold into Fabric architect or a Fabric-specific AI skill.
- [`platform.fabric-architect.agent.md`](/home/ubuntu/.config/opencode/agents/platform.fabric-architect.agent.md): Best Fabric front door; clear natural-language routing and solid domain fit. Gaps: full mutable perms and too much platform breadth inside one prompt. Why it matters: Fabric work would benefit from smaller composable skills. Improve with `planning-and-task-breakdown`, `observability-and-instrumentation`, `security-and-hardening`. Fix layer: `skill`, `permissions`. Action: keep as canonical Fabric front door.
- [`platform.fabric-cicd-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/platform.fabric-cicd-specialist.agent.md): Useful niche. Gaps: overlaps general CI/CD specialist and Fabric architect; unrouted. Why it matters: repeated CI/CD specialization. Improve with `ci-cd-and-automation`. Fix layer: `skill`, `agent`. Action: deprecate or fold into Fabric architect + CI/CD skill.
- [`platform.fabric-logging-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/platform.fabric-logging-specialist.agent.md): Good observability niche. Gaps: unrouted and better expressed as an observability skill/checklist. Why it matters: logging/instrumentation is a cross-cutting process. Improve with `observability-and-instrumentation`, `debugging-and-error-recovery`. Fix layer: `skill`. Action: deprecate as a standalone agent and preserve as a Fabric observability skill.
- [`platform.fabric-pipeline-developer.agent.md`](/home/ubuntu/.config/opencode/agents/platform.fabric-pipeline-developer.agent.md): Practical builder role. Gaps: overlaps Fabric architect and CI/CD/security variants; unrouted. Why it matters: Fabric cluster is over-segmented. Improve with `incremental-implementation`, `test-driven-development`. Fix layer: `skill`, `routing`. Action: keep only if the Fabric cluster is simplified to architect + builder.
- [`platform.fabric-security-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/platform.fabric-security-specialist.agent.md): Valuable security specialization. Gaps: unrouted and broad permissions for a security review role. Why it matters: security specialists should be tight, not general mutators. Improve with `security-and-hardening`, `code-review-and-quality`. Fix layer: `permissions`, `skill`. Action: keep as a constrained auditor or fold into Fabric architect with a security skill.

## Standalone

- [`dashboard-layout-specialist.agent.md`](/home/ubuntu/.config/opencode/agents/dashboard-layout-specialist.agent.md): Strong niche and useful composition/design perspective. Gaps: no `## Grounding` block, no routing entry, broad permissions, and no link to a real visual/design skill layer. Why it matters: this is useful but structurally inconsistent with the rest of the repo. Improve with `frontend-ui-engineering` and `documentation-and-adrs`. Fix layer: `agent`, `routing`, `permissions`. Action: keep if dashboards matter, but normalize structure and route it explicitly.
- [`DEFAULT.AGENT.agent.md`](/home/ubuntu/.config/opencode/agents/DEFAULT.AGENT.agent.md): Useful as a compatibility shim in theory. Gaps: references missing `graph-router`, duplicates router intent, `mode: all` is a legacy-looking outlier, and it carries full permissions despite being just a dispatcher. Why it matters: defaults must be trustworthy. Improve with `using-agent-skills`. Fix layer: `agent`, `routing`. Action: deprecate after routing is repaired or replace with a functioning minimal compatibility shim.

## Missing Skill Map

Local skills count: **18**. `agent-skills` pack: **24** skills. Source: local [`skills/`](/home/ubuntu/.config/opencode/skills), [`agent-skills` README](https://github.com/addyosmani/agent-skills/blob/main/README.md).

| Reference skill | Local status | What exists locally | What is missing | Should be a true OpenCode skill? | Existing consumers | Duplication replaced | Priority |
|---|---|---|---|---|---|---|---|
| `using-agent-skills` | materially missing | `dev.agent-router`, `AGENTS.md`, `config/routing.json` | mandatory skill detection and invocation before acting | yes | default planner, router, all workflow agents | routing prose in `AGENTS.md` and command-router skills | high |
| `interview-me` | materially missing | pieces of `workflow.brainstorm-agent` | targeted question workflow for ambiguous work | yes | planner, brainstorm | ambiguity-handling prose | medium |
| `idea-refine` | partially covered | `workflow.brainstorm-agent` | reusable ideation workflow independent of local workflow command | yes | brainstorm, planner | brainstorm prompt bulk | medium |
| `spec-driven-development` | present in spirit | workflow define/design phases | reusable spec workflow outside command-specific phase handling | yes | define/design/planner | phase prose across workflow agents | medium |
| `planning-and-task-breakdown` | present in spirit | `architect.the-planner`, `workflow.design-agent` | a single task-breakdown skill with evidence and exit checks | yes | planner, design, build | duplicated planning templates | high |
| `incremental-implementation` | partially covered | `workflow.build-agent`, `python.python-developer` | reusable implementation loop | yes | build agent, language/platform builders | build prompt bulk | high |
| `test-driven-development` | implemented | `skills/test-driven-development`, `test.test-generator`, `workflow.build-agent`, `python.python-developer`, `product.frontend-react-agent` | broader rollout to more builders if needed | yes | build, python, frontend, dbt, test agents | scattered test advice | closed |
| `context-engineering` | partially covered | `knowledge-context` skill, `grounding.md` | light, reusable context-shaping workflow for ordinary tasks | yes | planner, codebase explorer, prompt/LLM agents | context-loading prose | medium |
| `source-driven-development` | partially covered | KB-first rhetoric, source discipline in `AGENTS.md` | explicit evidence workflow | yes | planner, reviewer, KB architect, data/platform architects | source-discipline prose | high |
| `doubt-driven-development` | materially missing | confidence thresholds in `AGENTS.md` | workflow for uncertainty, caveats, and escalation | yes | planner, reviewer, rules QA, faithfulness guard | confidence prose | high |
| `frontend-ui-engineering` | partially covered | frontend React + UX agents | reusable screen/build/QA flow | yes | product.frontend-react-agent, product.ux-design-system-agent | frontend prompt bulk | high |
| `api-and-interface-design` | partially covered | system-design, schema, Supabase backend | reusable API/interface contract workflow | yes | system-design, supabase backend, schema, integration agents | interface prose across agents | high |
| `browser-testing-with-devtools` | implemented | `skills/browser-testing-with-devtools`, `product.frontend-react-agent` | link into UX/dashboard agents if browser QA becomes routine | yes | frontend, UX, dashboard layout | no replacement exists | closed |
| `debugging-and-error-recovery` | implemented | `skills/debugging-and-error-recovery`, `workflow.build-agent`, `python.python-developer` | broader rollout to more specialists if needed | yes | build, data/cloud/platform specialists, reviewer | ad hoc troubleshooting prose | closed |
| `code-review-and-quality` | partially covered | `python.code-reviewer`, review skill | richer workflow with review gates and evidence | yes | reviewer, judge, security, Fabric security | review prompt bulk | high |
| `code-simplification` | partially covered | `python.code-cleaner` | reusable simplification workflow and rationalization counters | yes | code-cleaner, planner, reviewer | cleanup prose | medium |
| `security-and-hardening` | implemented | `skills/security-and-hardening`, `dev.security-guardian`, `product.supabase-backend-agent`, `workflow.ship-agent` | broader rollout to more security-sensitive agents if needed | yes | security guardian, backend/security agents | scattered security advice | closed |
| `performance-optimization` | implemented | `skills/performance-optimization`, `data-engineering.spark-specialist`, `data-engineering.sql-optimizer` | broader rollout to other runtime-heavy agents if needed | yes | optimizer, Spark agents, reviewer | platform-specific perf prose | closed |
| `git-workflow-and-versioning` | implemented | `skills/git-workflow-and-versioning`, `dev.security-guardian`, `workflow.ship-agent` | broaden to CI/CD-oriented agents if they return as front doors | yes | security guardian, ship, judge, CI/CD | commit/release prose | closed |
| `ci-cd-and-automation` | partially covered | cloud/platform CI/CD specialists | reusable CI/CD workflow | yes | CI/CD specialists, ship, build | pipeline/deploy prose | medium |
| `deprecation-and-migration` | partially covered | `data:migrate`, some migration notes | systematic deprecation workflow | yes | dbt/lakehouse/schema/cloud agents | migration prose | medium |
| `documentation-and-adrs` | implemented | `skills/documentation-and-adrs`, `python.code-documenter`, `workflow.ship-agent`, `product.supabase-backend-agent` | broader rollout to planner/meeting agents if needed | yes | documenter, planner, meeting, KB architect | doc prose across multiple agents | closed |
| `observability-and-instrumentation` | partially covered | Fabric logging, cloud AI data engineer, data-quality | cross-domain instrumentation workflow | yes | platform/cloud/data agents | logging/monitoring prose | medium |
| `shipping-and-launch` | partially covered | `workflow.ship-agent` | reusable release/launch skill independent of local phase system | yes | ship, security guardian, CI/CD | ship prompt bulk | medium |

## Upgrade Roadmap

### Phase 1: integrity fixes

| Upgrade | Target layer | Benefit | Difficulty | Migration risk | Dependency order |
|---|---|---|---|---|---|
| Add or remove the missing `graph-router` references | `agent`, `routing`, `config` | restores routing credibility | low | low | 1 |
| Add the missing `visual-explainer` skill or delete the dead visual/review commands | `skill`, `command` | restores command trust | low-medium | low | 1 |
| Add the missing `judge-setup.md` or remove the reference | `command`, `docs` | restores judge usability | low | low | 1 |
| Move custom tools to the documented location or document the loader bridge explicitly | `config`, `tool` | makes governance hooks real | medium | low-medium | 1 |
| Normalize agent file structure, especially the dashboard outlier and redundant separators | `agent` | lowers maintenance noise | low | low | 2 |

### Phase 2: permission hardening

| Upgrade | Target layer | Benefit | Difficulty | Migration risk | Dependency order |
|---|---|---|---|---|---|
| Make planner/reviewer/security/audit agents deny writes by default | `agent`, `config` | least-privilege alignment with OpenCode | medium | low-medium | 3 |
| Use per-agent `tools` / `permission` controls instead of prose-only restrictions | `agent`, `config` | operational enforcement | medium | low-medium | 3 |
| Add skill permissions and deny hidden/internal skills by default | `config`, `agent` | safer skill discovery | medium | low | 4 |
| Introduce `hidden` or equivalent de-emphasis for legacy/compatibility agents | `agent` | lowers accidental invocation | low | low | 4 |

### Phase 3: convert command-router skills into real workflow skills

| Upgrade | Target layer | Benefit | Difficulty | Migration risk | Dependency order |
|---|---|---|---|---|---|
| Create `using-agent-skills` and make it mandatory in global rules | `skill`, `AGENTS.md` | corrects the orchestration model | medium | medium | 5 |
| Convert `workflow-commands`, `review`, `core-commands`, and `data-engineering` from router docs into process skills | `skill` | reusable verification and less prompt duplication | high | medium | 6 |
| Add explicit rationalizations, red flags, and verification sections to all high-value skills | `skill` | closer to `agent-skills` rigor | medium | low-medium | 6 |

### Phase 4: reduce agent sprawl and overlap

| Upgrade | Target layer | Benefit | Difficulty | Migration risk | Dependency order |
|---|---|---|---|---|---|
| Collapse the Spark cluster into `spark-frontdoor` + `spark-diagnostics` | `agent`, `routing` | clearer routing, lower drift | medium | medium | 7 |
| Collapse the Lakeflow cluster into one front door plus one builder if needed | `agent`, `routing` | lower maintenance | medium | medium | 7 |
| Merge prompt/LLM specialists into one coherent cluster | `agent`, `routing` | routing clarity | medium | low-medium | 7 |
| Merge cloud Supabase into product Supabase backend | `agent`, `routing` | single source of truth | low-medium | low | 7 |
| Simplify Fabric and AWS/GCP role splits where specialists are mostly template variants | `agent`, `routing` | less duplication | medium-high | medium | 8 |

### Phase 5: add missing high-value lifecycle skills

| Upgrade | Target layer | Benefit | Difficulty | Migration risk | Dependency order |
|---|---|---|---|---|---|
| Add `test-driven-development` | `skill` | closes one of the biggest lifecycle gaps | medium | medium | 9 |
| Add `debugging-and-error-recovery` | `skill` | gives the harness a reusable failure workflow | medium | low-medium | 9 |
| Add `browser-testing-with-devtools` | `skill` | upgrades frontend QA materially | medium | low | 9 |
| Add `security-and-hardening` | `skill` | unifies security behaviors now scattered across prompts | medium | low-medium | 10 |
| Add `documentation-and-adrs` and `git-workflow-and-versioning` | `skill` | reduces repeated release/documentation prose | medium | low | 10 |

## Step-by-Step Checklist

Use this as the execution order. Do not start a later phase until the current phase meets its exit criteria.

Detailed execution documents:

- [docs/tasks/README.md](/home/ubuntu/.config/opencode/docs/tasks/README.md)
- [docs/tasks/phase-1.md](/home/ubuntu/.config/opencode/docs/tasks/phase-1.md)
- [docs/tasks/phase-2.md](/home/ubuntu/.config/opencode/docs/tasks/phase-2.md)
- [docs/tasks/phase-3.md](/home/ubuntu/.config/opencode/docs/tasks/phase-3.md)
- [docs/tasks/phase-4.md](/home/ubuntu/.config/opencode/docs/tasks/phase-4.md)
- [docs/tasks/phase-5.md](/home/ubuntu/.config/opencode/docs/tasks/phase-5.md)

### Phase 1: Integrity fixes

| Done | Task | Subtasks | Exit criteria |
|---|---|---|---|
| [x] | Resolve the missing `graph-router` references | Decide whether the router should exist; if yes, add `agents/graph-router.agent.md`; if no, remove the references from `AGENTS.md`, `DEFAULT.AGENT.agent.md`, and `dev.agent-router.agent.md` | no stale `graph-router` references remain |
| [x] | Fix the `visual-explainer` gap | Enumerate every command that references `skills/visual-explainer/SKILL.md`; create the skill or rewrite/remove the commands; keep the command set internally consistent | every visual/review command resolves to a real skill or a deliberate alternative |
| [x] | Fix the missing judge setup reference | Decide whether `docs/getting-started/judge-setup.md` should exist; if yes, add it; if no, remove the judge-agent and skill references that depend on it | `dev.judge-agent` no longer points at a dead setup path |
| [x] | Make the tool bridge explicit | Move `tools/faithfulness_gate.ts` and `tools/verify_step.ts` into the documented OpenCode tool location or document the loader bridge in config | the runtime path for both tools is documented and discoverable |
| [x] | Normalize agent file structure | Fix the dashboard outlier structure; remove redundant separators where they add noise; align headings across the template family | agent markdown shape is consistent enough to maintain safely |

### Phase 2: Permission hardening

| Done | Task | Subtasks | Exit criteria |
|---|---|---|---|
| [x] | Classify agents by authority level | Split agents into read-only, review-only, builder, auditor, and full-execution classes; record the classification in one place before editing permissions | every agent has an explicit authority class |
| [x] | Remove blanket write access from non-build roles | Strip `bash`, `edit`, and `websearch` from planner, reviewer, audit, and security roles unless a task truly needs them | read-only roles cannot mutate code or browse unnecessarily |
| [x] | Replace prose restrictions with platform permissions | Use OpenCode-native per-agent `permission` and `tools` controls instead of relying on prompt warnings alone | permission intent is enforced by config, not only by text |
| [x] | Add de-emphasis for compatibility-only agents | Mark legacy or shim agents as hidden or otherwise low-priority where OpenCode supports it | accidental invocation of obsolete agents drops materially |
| [x] | Re-run a least-privilege sanity pass | Test one representative task per role class and confirm blocked actions fail for the right reasons | permissions match intended behavior in practice |

### Phase 3: Convert command-router skills into real workflow skills

| Done | Task | Subtasks | Exit criteria |
|---|---|---|---|
| [x] | Add a real `using-agent-skills` skill | Define the detection step, selection step, and handoff rules; make it the canonical first step for ambiguous work | the system has one explicit skill-selection entry point |
| [x] | Rewrite router-like skills into workflow skills | Convert `workflow-commands`, `review`, `core-commands`, and `data-engineering` from routing prose into reusable process skills | skills contain steps, anti-patterns, and exit checks |
| [x] | Standardize verification structure | Add `when to use`, `workflow`, `rationalizations`, `red flags`, and `verification` sections to high-value skills | skill anatomy matches the lifecycle pattern consistently |
| [x] | Remove duplicated process prose from agents | Delete repeated workflow instructions from agents after the corresponding skill exists | process guidance lives in one skill instead of many prompts |
| [x] | Wire agents to consume the new skills | Update the most important agents first: planner, build, reviewer, security, and frontend roles | core agents defer to skills instead of re-stating the process |

### Phase 4: Reduce agent sprawl and overlap

| Done | Task | Subtasks | Exit criteria |
|---|---|---|---|
| [x] | Collapse the Spark cluster | Reduce the Spark set to a front door and a diagnostics path; move perf and troubleshooting details into skills | Spark routing is simpler and less contradictory |
| [x] | Collapse the Lakeflow cluster | Keep one primary Lakeflow front door and one builder or operations specialist if needed | Lakeflow roles no longer overlap heavily |
| [x] | Merge prompt and LLM specialists | Consolidate `python.*` and cloud prompt/LLM agents into a smaller set with clear boundaries | prompt expertise has one obvious home |
| [x] | Merge duplicated Supabase coverage | Choose one canonical Supabase backend path and fold the cloud variant into it | Supabase guidance has one authoritative route |
| [x] | Simplify Fabric and AWS/GCP splits | Remove template-variant agents that differ only by vendor naming or surface area | routing is driven by problem type, not repeated vendor clones |

### Phase 5: Add missing high-value lifecycle skills

| Done | Task | Subtasks | Exit criteria |
|---|---|---|---|
| [x] | Add `test-driven-development` | Define the red-green-refactor loop; add test-first checkpoints; route build and language agents through it | testing becomes a workflow, not just a helper |
| [x] | Add `debugging-and-error-recovery` | Define failure triage, reproduction, isolation, and rollback steps | debugging follows one reusable recovery pattern |
| [x] | Add `browser-testing-with-devtools` | Define browser inspection, interaction, and visual verification steps for UI work | frontend QA has a browser-native skill |
| [x] | Add `security-and-hardening` | Define threat review, least privilege, secret handling, and hardening checks | security behavior is centralized and reusable |
| [x] | Add `documentation-and-adrs` | Define doc update, decision capture, and architecture note steps | documentation and ADRs stop living as scattered prose |
| [x] | Add `git-workflow-and-versioning` | Define branch, commit, diff, and release hygiene steps | Git and release behavior is explicit and repeatable |
| [x] | Backfill remaining lifecycle gaps where needed | Add `observability-and-instrumentation`, `ci-cd-and-automation`, or `performance-optimization` only if the cluster reductions did not absorb them | lifecycle coverage is complete enough for daily use |

## Recommended target state

- Keep commands for explicit workflow entry points where they matter locally.
- Make skills the primary process surface.
- Make agents smaller, narrower, and more permission-specific.
- Use `opencode.jsonc` for actual OpenCode-native behavior where possible.
- Use custom tools only from documented locations and with visible integration.
- Reserve large prompt agents for true specialist judgment, not for carrying workflow logic that should live in skills.

## Validation Checklist

- All 72 agent files under [`agents/`](/home/ubuntu/.config/opencode/agents) are covered exactly once in the dossier.
- Confirmed local breakages are limited to items verified in this workspace.
- OpenCode claims are tied to current official docs.
- `agent-skills` recommendations are tied to named skills or documented operating patterns.
- SDD methodology itself is not critiqued; only its spillover into agent behavior is noted.
