# Command Overlay and Gate Precedence

**Trigger:** Any `/command:*` invocation or command-level gate check.
**Load scope:** Lazy — loaded on command invocation.
**Governing ADRs:** ADR-0004, ADR-0006.

---

## Core rule

Commands are dispatch overlays, not execution owners. A command file sets the agent, skill, and context; the agent and skill execute. Gates in the command take precedence over ad-hoc agent decisions.

---

## Command types and their routing

| Command prefix | Routing | Gate |
|---|---|---|
| `/workflow:*` | AgentSpec START → `agentspec-start.md` | Build Output Gate for `/workflow:build` |
| `/data:*` | Data Engineer coordinator → specialist agent | None beyond allocation |
| `/review:*` | `review` skill → `dev-judge` or `dev-faithfulness-guard` | Target skill must be available |
| `/core:*` | Core utility agent | Storage path check |
| `/visual:*` | Visual explainer skill | Artifact output path confirmed |
| `/knowledge:*` | KB architect | KB domain check |
| `/context:*` | Context utility | Source file check |

## Gate precedence order

When multiple gates are active simultaneously, resolve in this order:

1. **Security gate** — if the change touches auth, permissions, secrets, or PII, route through `dev-security-guardian` first. No other gate may be bypassed.
2. **Build Output Gate** — for `/workflow:build`, ask the output path before any other action.
3. **4-Doc Gate** — for Altitude Execution start, all four docs must exist.
4. **Wave validation gate** — T-Vxx must PASS before the next wave starts.
5. **Writer lease gate** — lease must be held before any state write.
6. **Allocation gate** — file must be in `allowed_paths` before any edit.

## Command file format (reference)

A command file in `commands/` must have:

```markdown
---
description: "{one-sentence description}"
agent: "{agent name}"
subtask: true | false
---

{command body — what the agent should do}
```

`$ARGUMENTS` is replaced with user input after the command name.

## What commands must NOT do

- Commands must not bypass the Build Output Gate for `/workflow:build`.
- Commands must not assume an output path or a default directory.
- Commands must not invoke Altitude phase agents from an AgentSpec command file.
- Commands must not include hardcoded secrets or tokens.

## Stop conditions

- STOP if a security-gate trigger is detected and `dev-security-guardian` skill (or its transitional equivalent) is not available.
- STOP if `/workflow:build` is invoked without an explicit user-confirmed output path.
- STOP if a command references an agent that does not exist in `agents/` or `opencode.json`.

---

*Governing: ADR-0004, ADR-0006, `sdd/architecture/WORKFLOW_CONTRACTS.yaml`.*
