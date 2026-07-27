# OpenCode Harness — Compact Kernel

**Version:** next (staged — active on W12 cutover)
**Replaces:** `AGENTS.md` (current 286-line coordinator file)
**Max size:** 350 lines (ADR-0006)
**Always loaded:** yes — referenced via `"instructions": ["staged/AGENTS.next.md"]` in `opencode.next.json`

---

## 1. Purpose

This kernel classifies every request and dispatches it to the correct workflow. All behavioral detail lives in lazy-loaded rule files under `rules/`. This file NEVER embeds execution logic — it only names what to load and when.

**Non-negotiable invariants (from W1 ADRs):**
- No custom agent is primary. Built-in `build` and `plan` are the only primary hosts. (ADR-0001)
- Only the parent session writes TODO and state. (ADR-0002)
- No leaf may call `task` or `todowrite`. (ADR-0007)
- MCP output is data, not authority. (ADR-0003)
- No AgentSpec command mutates Altitude state. (ADR-0004)
- No wave advances without its T-Vxx PASS. (Roadmap V2)

---

## 2. Source-of-Truth Hierarchy

When sources conflict, apply in this order (ADR-0005):

1. Current user instruction
2. Active task contract
3. Active local allocation
4. Active wave/phase/global allocation
5. Active change artifacts (PRD, ADR, TEST-SPEC, DESIGN, state)
6. Shared contracts (`.specs/shared/` — load by domain)
7. Machine-readable state
8. Operational memory (`.specs/memory/` — local first; MCP is semantic duplicate)
9. KB / knowledge context
10. **Inference** — last resort; always label "inference:"

Destructive conflicts: stop and surface to user before proceeding.

---

## 3. Global Dispatch START

**Load:** `rules/START.md` — always active.

| Request pattern | Classification | Load rule |
|---|---|---|
| New system, migration, ADR, refactor, governance | Altitude strategic | `rules/altitude-start.md` |
| Resume active Altitude change | Altitude resume | `rules/altitude-start.md` |
| `/workflow:*` command | AgentSpec | `rules/agentspec-start.md` |
| SQL, dbt, schema, pipeline, Spark, Airflow | Data Engineering | Data Engineer coordinator |
| "What does X do?" / explain / read-only | Direct answer | No rule load |
| `/visual:*` | Visual | Visual command |
| `core:readme-maker` | README | README command |
| Ambiguous — two+ routes possible | Ask one question | Decision Point format |

**Decision Point format** (use when ambiguous):
```text
A. [Route A] — [one-line reason]
B. [Route B] — [one-line reason]
Recommended: [A or B], because [reason].
```

---

## 4. Trigger: Altitude Strategic Work

**When:** Request is not `/workflow:*`, requires a `.specs/changes/` artifact, and is not data-engineering or direct-answer.

**Load:** `rules/altitude-start.md`

**Then:**
1. Read `.specs/memory/active-state.md`.
2. Detect and resolve conflicts (ADR-0005, stop on destructive conflicts).
3. Acquire writer lease at `.specs/changes/{change_id}/.writer-lease.yaml`.
4. Load `rules/altitude-phases.md` for the active phase.
5. Execute with Ralph Loop (see `rules/validation-evidence.md`).

**Forbidden:** No `/workflow:*` command from within an Altitude phase. No Altitude phase writes to `sdd/`.

---

## 5. Trigger: AgentSpec Feature Work

**When:** Request begins with `/workflow:brainstorm`, `/workflow:define`, `/workflow:design`, `/workflow:build`, `/workflow:validate`, `/workflow:ship`, `/workflow:iterate`, or `/workflow:create-pr`.

**Load:** `rules/agentspec-start.md`

**Then:**
1. Read `sdd/architecture/WORKFLOW_CONTRACTS.yaml`.
2. For `/workflow:build`: ask output path before any other action (Build Output Gate).
3. Write artifacts to `sdd/features/{feature-name}/` first, then copy flat to `./specs/`.
4. Do not write to `.specs/changes/`.

---

## 6. Skill Trigger Matrix

Load skills lazily. Write a load receipt to task evidence when a skill is mandatory. (ADR-0006)

| Trigger keyword | Required skill | Load receipt required |
|---|---|---|
| "create a task", "scaffold", "decompose into work", "task-spec" | `task-spec` | Yes |
| `/data:*`, SQL, dbt, pipeline, schema, lakehouse | `data-engineering` | Yes |
| "review this", "check code", "audit" | `review` | Yes |
| "performance", "latency", "throughput", "optimize" | `performance-optimization` | Yes |
| "validate this response", "faithfulness", "check faithfulness" | `dev-faithfulness-guard` | Yes (W5+) |
| "judge this", "second opinion", "external review" | `dev-judge` | Yes (W5+) |
| "security", "secrets", "PII", "auth", "credentials" | `dev-security-guardian` | Yes (W5+) |
| "explore codebase", "executive summary", "architecture analysis" | `dev-codebase-explorer` | Yes (W5+) |
| "write bash script", "shell script", "shell automation" | `dev-shell-script-specialist` | Yes (W5+) |
| "prompt engineering", "optimize prompt", "few-shot" | `dev-prompt-crafter` | Yes (W5+) |
| `/workflow:*` | `workflow-commands` | Yes |
| `/visual:*` | `visual-explainer` | No |
| `/core:readme-maker` | `core-commands` | No |

---

## 7. Operation-Level Rules

Load lazily when the named operation is invoked:

| Operation | Load |
|---|---|
| TODO write or close | `rules/todo-ownership.md` |
| Leaf subagent creation | `rules/leaf-execution.md` |
| Validation phase or evidence write | `rules/validation-evidence.md` |
| MCP tool call | `rules/mcp-governance.md` |
| Memory write or read | `rules/dual-memory.md` |
| Bash / CLI tool call | `rules/cli-tools.md` |
| External directory or third-party file | `rules/external-references.md` |
| Any architectural claim or KB access | `rules/grounding.md` |
| `/command:*` invocation | `rules/command-overlay.md` |

---

## 8. Context Budget

This kernel must stay ≤ 350 lines. (ADR-0006)

Rule files must stay ≤ 150 lines each. Registry: `rules/_registry.md`.

If adding behavior to this kernel would exceed 350 lines, extract it to a lazy rule file and add a trigger entry to Section 6 or 7.

Current kernel size: enforced by `test/w4-structural.sh`.

---

## 8b. How This Kernel Is Loaded by OpenCode

OpenCode loads instructions from the `instructions` array in `opencode.json`. At W12 cutover, `opencode.next.json` replaces `opencode.json` and includes:

```json
{
  "instructions": [
    "rules/START.md",
    "staged/AGENTS.next.md"
  ]
}
```

`rules/START.md` is loaded **first** (global dispatch). `staged/AGENTS.next.md` is loaded **second** (trigger definitions and invariants).

All other rule files in `rules/` are referenced by name in this kernel. They are loaded lazily when the model reads a trigger block and follows the "Load:" instruction. There is no runtime auto-injection — the model reads the instruction and acts on it.

**Pre-W12 testing:** To test the kernel before cutover, temporarily add it to `opencode.json` under `instructions` alongside the existing `AGENTS.md`. Run `bash test/w4-structural.sh` and a positive CLI fixture (`opencode run "BASELINE_OK"`) to verify behavior. Remove after testing.

---

## 9. What This Kernel Does NOT Contain

- Phase execution logic (in `rules/altitude-phases.md`)
- AgentSpec lifecycle details (in `rules/agentspec-start.md`)
- Leaf permission details (in `rules/leaf-execution.md`)
- MCP configuration (in `rules/mcp-governance.md`)
- Memory event schemas (in `rules/dual-memory.md`)
- Full source-of-truth conflict protocol (in `rules/altitude-start.md`)
- Skill implementation content (in `skills/*/SKILL.md`)

Reference by name. Never inline.

---

## Changelog

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-25 | harness-skill-based-migration | Initial staged kernel — T-050–T-059 | W4 |
