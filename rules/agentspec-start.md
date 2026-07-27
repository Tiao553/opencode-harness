# AgentSpec-Specific START

**Trigger:** `/workflow:*` command invoked.
**Load scope:** Lazy — loaded immediately after `START.md` routes to AgentSpec.
**Governing authority:** ADR-0004, `sdd/architecture/WORKFLOW_CONTRACTS.yaml`.

---

## What activates AgentSpec START

Request begins with one of:
`/workflow:brainstorm`, `/workflow:define`, `/workflow:design`, `/workflow:build`,
`/workflow:validate`, `/workflow:ship`, `/workflow:iterate`, `/workflow:create-pr`.

---

## Core rule

AgentSpec manages feature-level SDD work. It writes to `sdd/features/`, reads `WORKFLOW_CONTRACTS.yaml` before each phase, and never touches `.specs/changes/` or the Altitude writer lease.

---

## AgentSpec workflow rules

1. **Use the workflow commands.** All AgentSpec phases are started by native `/workflow:*` commands. Do not start an SDD phase from a general conversation.
2. **Read `WORKFLOW_CONTRACTS.yaml`.** Before executing any phase, read `sdd/architecture/WORKFLOW_CONTRACTS.yaml` for the phase inputs, outputs, and gate rules.
3. **Artifacts go to `sdd/features/{feature-name}/`.** Write to the global store first, then copy flat to `./specs/`. Never write to `.specs/changes/`.
4. **Build Output Gate.** `/workflow:build` must ask the user for the output path before reading DESIGN or creating any file. No default. No guessing.
5. **Validate before ship.** `/workflow:validate` must pass before `/workflow:ship` is accepted.

## Separation from Altitude

| Aspect | AgentSpec | Altitude |
|---|---|---|
| State storage | `sdd/features/` | `.specs/changes/` |
| Memory | Not in `.specs/memory/` | `.specs/memory/` with dual-write |
| TODO ledger | Not managed | Managed by parent |
| Phase trigger | `/workflow:*` commands | Altitude START classification |
| Validation gate | Score ≥ 90, zero CRITICAL | T-Vxx PASS, zero critical/high defects |

## AgentSpec does NOT:

- Write to `.specs/changes/` or `.specs/memory/`.
- Advance Altitude wave state.
- Invoke Altitude phase agents.
- Use the Altitude writer lease.

## Stop conditions

- STOP if the request is not a `/workflow:*` command and you are in AgentSpec START.
- STOP if `WORKFLOW_CONTRACTS.yaml` cannot be read (file does not exist or is malformed).
- STOP if `/workflow:build` is invoked and the output path has not been confirmed by the user.

---

*Governing: ADR-0004, `sdd/architecture/WORKFLOW_CONTRACTS.yaml`.*
