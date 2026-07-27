# Harness 360 Refactor - Intent

## Problem

The harness currently loses coherence because it operates through two overlapping control planes, relies heavily on prompt-only governance, decomposes work too late, leaves MCP activation too discretionary, and has uneven KB quality with known contradictions in critical domains such as Microsoft Fabric.

## Objective

Refactor the harness into a single coordinated operating model where `Altitude` owns durable work, `workflow:*` commands act as compatibility wrappers, decomposition is smaller and stricter, MCP usage is explicitly governed, KB quality is measurable, and the overall system becomes easier to maintain and hand off.

## Impact

- lower routing drift
- stronger execution gates
- clearer decomposition for smaller models and delegated agents
- better grounding quality
- easier KT and future maintenance

## Constraints

- this repo is the harness home itself, so global and local concerns coexist in one workspace
- `opencode.json` is schema-validated and must remain coherent
- some runtime hooks are not yet available, so certain controls may remain policy-backed for now
- changes must remain surgical and should not collapse working surfaces without replacement

## Non-Goals

- redesign every specialist agent in one pass
- fully rewire all MCP servers immediately
- refresh every KB domain before the governance standard exists

## Success Criteria

- `Altitude` is the primary durable coordinator
- `workflow:*` no longer acts as a competing operational state machine
- decomposition happens before execution and produces smaller ready tasks
- MCP posture is explicit and auditable
- `knowledge_context/` is no longer a live dependency
- Fabric becomes the golden KB domain

## Known Risks

- runtime enforcement may lag behind desired policy in a few areas
- doc/config drift can recur unless updated in lockstep
- Fabric remediation may reveal a broader KB governance gap across other domains
