# Migration Success Scorecard

## Metadata

- Source: T-002 through T-005 evidence and Roadmap V2 confirmed decisions.
- Verification: rerun each named measurement during T-V00 and final validation.
- Rollback: remove this scorecard; it changes no runtime behavior.
- Limitation: context/tool exposure has no baseline until W11 measurement.

## Metrics

| Metric | Target | Measurement | Baseline |
|---|---|---|---|
| Custom primary agents | 0 at cutover | `opencode agent list` and static config scan | 2 |
| Recursive delegation | 0 | static permission and leaf-profile checks | 75 Task-capable custom agents |
| Parent TODO ownership | 100% | traceability fixtures | Not implemented |
| Validation coverage | Every wave has T-Vxx PASS | backlog and evidence scan | 13 validation tasks planned |
| MCP handling | Explicit healthy/degraded state | `opencode mcp list` and health checks | No servers configured |
| Command compatibility | Preserved `/workflow:*` commands pass | W7 compatibility suite | 35 commands inventoried |
| Context/tool exposure | Meets final approved baseline | W11 measurement suite | Not yet measured |

## Measurement Rule

Each final value must cite command output or validation evidence. A missing measurement is a failed metric, not an assumed pass.

## Fallback Rule

An unavailable MCP must produce an explicit degraded result and documented fallback. It must not fabricate output or alter workflow authority.
