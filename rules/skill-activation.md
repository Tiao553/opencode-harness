# Skill Activation Evidence Contract

**Trigger:** A skill is triggered by a condition in AGENTS.md.
**Load scope:** Lazy — loaded when a skill fires.
**Governing ADR:** ADR-0006.

---

## Core rule

Every mandatory skill load produces a load receipt in the task evidence.

## Load receipt format

```yaml
required_skills:
  - skill_name: "{name}"
    trigger_condition: "{what caused it}"
    loaded: true | false
    reason_if_false: "{why not loaded}"
loaded_skills:
  - skill_name: "{name}"
    confirmed_by: "{evidence of correct behavior}"
```

`loaded: false` on a mandatory skill = FAIL verdict for the task.

## Current skills (W3 baseline)

| Skill | Status |
|---|---|
| `core-commands`, `data-engineering`, `performance-optimization`, `review`, `task-spec`, `visual-explainer`, `workflow-commands` | Active |
| `dev-codebase-explorer`, `dev-faithfulness-guard`, `dev-judge`, `dev-prompt-crafter`, `dev-security-guardian`, `dev-shell-script-specialist` | Absent — W5 target |
| `workflow-define`, `workflow-design` | Absent — missing reference from `workflow-commands` |

## Mandatory skill assignments

| Context | Required skill |
|---|---|
| Task decomposition | `task-spec` |
| SQL / data-engineering | `data-engineering` |
| Security review | `dev-security-guardian` (W5+) |
| Faithfulness validation | `dev-faithfulness-guard` (W5+) |
| External judge | `dev-judge` (W5+) |

## Stop conditions

- STOP if a mandatory skill is `loaded: false` with no approved exception.
- STOP if `dev-faithfulness-guard` or `dev-judge` is required and neither skill nor approved transitional exists.

---

*Governing: ADR-0006, W5 T-044, T-067, T-071.*
