# Harness MCP Governance Matrix

## Purpose

Define the central MCP governance model for the OpenCode harness so that MCP activation is explicit, phase-aware, risk-aware, and evidenced.

This document is the central default. Agent-specific MCP rules may refine it but must not contradict its hard stops.

## Grounding

This matrix is grounded in:

- `.specs/shared/mcp-governance.md`
- `docs/ALTITUDE_SPECS_HARNESS.md`
- `AGENTS.md`
- `opencode.json`
- `config/opencode.example.jsonc`
- `agents/platform.fabric-architect.agent.md`
- `agents/platform.fabric-security-specialist.agent.md`
- `agents/product.supabase-backend-agent.agent.md`

## Principles

- MCPs are exceptions, not defaults.
- Central matrix first, agent override second.
- No remote MCP with credentials without explicit approval.
- Critical domains do not proceed on stale or contradictory grounding.
- Every MCP-influenced decision must leave evidence.

## Server Classes

| Class | Examples | Risk profile | Typical posture |
| --- | --- | --- | --- |
| Local read-only | filesystem, git, code graph | low | allow or ask by phase |
| Remote documentation | Context7, fetch, vendor docs proxies | medium | ask or require by domain |
| Remote search/example | Exa, web-search MCPs | medium | ask, bounded |
| Stateful or write-capable | SQL execution, deployment, live platform mutation | high | deny by default |

## Altitude Matrix

| Altitude | Default posture | Allowed MCP categories | Notes |
| --- | --- | --- | --- |
| Intent | deny | none | do not widen context with external systems |
| Structure | ask | local read-only, code graph, docs | only when repo structure or official docs matter |
| Plan | ask | official docs, code graph | use only when current facts are needed to plan safely |
| Execution | ask | official docs, bounded search, local read-only | only when KB is insufficient, stale, or version-sensitive |
| Validation | deny or ask | local read-only, official docs | validation should prefer local evidence and reproducibility |
| Report | deny | none | reporting comes from artifacts, not new discovery |
| Memory | deny | none | memory writes should be artifact-backed |

## Domain Hard Stops

### Fabric

Stop if either condition is true:

- the Fabric KB is internally conflicting on a critical claim
- required validation MCP is unavailable for high-risk or recency-sensitive advice

### Security

Stop if either condition is true:

- the security KB or local policy is conflicting or stale on the critical claim
- required validation MCP is unavailable for production-impacting security guidance

### Supabase

Stop if either condition is true:

- auth, RLS, or migration guidance depends on stale or conflicting local knowledge
- the required validation path is unavailable for production-impacting changes

## Activation Rules

Use MCP when one of the following is true:

- the relevant KB is stale for the claim being made
- the relevant KB is silent on a critical implementation detail
- the platform or framework is known to change quickly
- the task explicitly needs official-current API or platform guidance
- the agent encounters conflicting internal KB statements

Do not use MCP when one of the following is true:

- the phase is `Intent`, `Report`, or `Memory`
- the answer can be supported by local artifacts and current KB alone
- the MCP would introduce credentialed external side effects
- the task is low-risk and not recency-sensitive

## Evidence Contract

If MCP affects a decision, record:

- MCP server used
- query topic or request summary
- result type: agrees, disagrees, silent, or MCP-only
- impacted decision
- residual uncertainty

Acceptable evidence locations:

- task evidence under `.specs/changes/<change>/evidence/`
- validation notes under `04-validation.md`
- KB refresh evidence when updating a domain

## Agent Override Rules

Agent overrides may:

- narrow the default posture
- require MCP for a stricter domain path
- add domain-specific evidence requirements

Agent overrides may not:

- allow write-capable remote MCP by default in low altitudes
- bypass the hard-stop rules for Fabric, security, or Supabase
- turn a deny posture into an allow posture without an explicit documented reason

## Runtime Expectation

Current repo state:

- `opencode.json` does not currently define live MCP servers
- `config/opencode.example.jsonc` provides the example wiring surface

Implication:

- prompts must not imply that MCP is available when it is not wired
- policy docs should distinguish between designed posture and live runtime availability

## Rollout Notes

This matrix is the first governance freeze, not the final runtime implementation.

Later work should:

1. wire actual MCP availability in config where desired
2. align agent prompts to this matrix
3. remove false guarantees from prompts that assume MCP exists
4. add KB refresh workflows that explicitly invoke MCP when domain repair is needed
