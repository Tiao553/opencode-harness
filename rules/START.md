# Global Dispatch START

**Trigger:** Every session start. This rule fires before any other rule.
**Load scope:** Always — referenced directly by the compact AGENTS.md kernel.
**Governing ADRs:** ADR-0001, ADR-0004.

---

## What this rule does

Classifies every incoming request and routes it to exactly one workflow or response mode. No request is processed without classification.

---

## Classification Table

| Request pattern | Classification | Route to |
|---|---|---|
| New system, migration, ADR, refactor, governance | Altitude strategic work | `altitude-start.md` |
| Resume active Altitude change | Altitude resume | `altitude-start.md` → active phase |
| `/workflow:*` command | AgentSpec feature work | `agentspec-start.md` |
| SQL fix, dbt, schema, pipeline, Spark, Airflow | Tactical data-engineering | Data Engineer coordinator |
| "What does X do?", "Explain Y" | Direct answer | No workflow, respond directly |
| `/visual:*` | Visual artifact | Visual command |
| `core:readme-maker` | Documentation | README command |
| Ambiguous — could be two or more routes | Ambiguous | Ask one focused clarification question |

## Mandatory classification steps

1. Read the first sentence of the request.
2. Apply the classification table above.
3. If ambiguous: ask ONE focused question using the Decision Point format (see below) before proceeding.
4. Do not assume Altitude for every large or complex request.
5. Do not route to AgentSpec for requests that do not start with `/workflow:`.

## Decision Point format (for ambiguous requests)

```text
Decision point:

A. [Route A] — [reason this could apply]
B. [Route B] — [reason this could apply]

Recommended: [A or B], because [one-line reason].
```

## Concrete ambiguity example

**User says:** "Help me redesign the altitude-maestro routing to support skill-based dispatch"

| Check | Result |
|---|---|
| Starts with `/workflow:`? | No |
| Requires `.specs/changes/` artifact? | Yes — this is a migration wave task |
| Is it tactical data-engineering? | No |
| Is it a direct answer? | No — requires design and possibly task creation |

**Classification: Altitude strategic work.**

Decision Point (only if still ambiguous):
```text
A. Altitude — create a new change or advance existing migration wave.
B. Direct answer — explain the current routing without creating artifacts.

Recommended: A, because the user said "redesign" not "explain."
```

---

- Do not proceed if the classification is ambiguous and no clarification question has been asked.
- Do not route to Altitude for tactical data-engineering work.

## Stop conditions

- STOP if the classification is ambiguous and no clarification question has been asked.
- STOP if the request matches two routes simultaneously — ask before routing.

---

*Governing: ADR-0004, ADR-0001.*
