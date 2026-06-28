# MCP Governance

MCPs are exceptions, not defaults.

## Default Matrix

| Agent | MCP posture |
| --- | --- |
| `altitude-intent` | deny |
| `altitude-structure` | ask for code graph or docs only |
| `altitude-plan` | ask for current docs only |
| `altitude-execution` | ask when framework/API recency matters |
| `altitude-validation` | deny or ask |
| `altitude-report` | deny external MCP |
| `altitude-memory` | deny |

## Rules

- No remote MCP with credentials without explicit approval.
- No write-capable MCP in intent or structure.
- Do not expose many MCPs globally.
- Prefer per-agent MCP availability.
- Record MCP use in evidence when it affects a decision.
