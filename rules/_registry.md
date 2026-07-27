# Rules Registry

**Purpose:** Map every rule file to its trigger condition, loading scope, and governing ADR/contract.

**Version:** 1.0 (W3 staged)
**Active from:** W4 (AGENTS.md kernel rewrite)

| File | Trigger condition | Scope | Governing authority |
|---|---|---|---|
| `START.md` | Every new session — global dispatch | Always loaded via AGENTS.md | ADR-0004, ADR-0001 |
| `altitude-start.md` | Request classified as Altitude strategic work | Lazy, on Altitude START | ADR-0004, W2 `altitude-start.md` |
| `agentspec-start.md` | `/workflow:*` command invoked | Lazy, on AgentSpec START | ADR-0004, `WORKFLOW_CONTRACTS.yaml` |
| `altitude-phases.md` | Altitude phase transition or phase-specific action | Lazy, per phase | W2 `altitude-workflow-contract.md` |
| `todo-ownership.md` | Any TODO write operation attempted | Lazy, on write attempt | ADR-0002 |
| `leaf-execution.md` | Leaf subagent session created | Lazy, on leaf creation | ADR-0007 |
| `validation-evidence.md` | Validation phase or evidence review | Lazy, on validation | W2 contract sec. 8 |
| `grounding.md` | Any KB, MCP, or external document access | Lazy, on access | ADR-0005, ADR-0003 |
| `mcp-governance.md` | Any MCP tool invocation | Lazy, on MCP call | ADR-0003, `.specs/shared/mcp-governance.md` |
| `dual-memory.md` | Any memory write or read operation | Lazy, on memory event | ADR-0003 |
| `cli-tools.md` | Bash or CLI tool call | Lazy, on tool call | ADR-0006 |
| `external-references.md` | Access to external directory or third-party file | Lazy, on access | ADR-0005 |
| `skill-activation.md` | Skill triggered by name | Lazy, on skill load | ADR-0006 |
| `command-overlay.md` | Any `/command:*` invocation | Lazy, on command | ADR-0004, ADR-0006 |
| `rule-loader.md` | Rule file loading itself | Meta — read by W4 AGENTS.md author | ADR-0006 |

---

## Load Order

When multiple triggers fire simultaneously:

1. `START.md` always fires first.
2. Workflow-specific START (`altitude-start.md` or `agentspec-start.md`) fires second.
3. Phase-specific rules fire third.
4. Operation-specific rules (TODO, MCP, memory, tool) fire when their operation is invoked.

---

## Status Tracking

| File | Created | Last validated | Status |
|---|---|---|---|
| `README.md` | W3 T-030 | W3 T-V03 | staged |
| `_registry.md` | W3 T-030 | W3 T-V03 | staged |
| `START.md` | W3 T-031 | W3 T-V03 | staged |
| `todo-ownership.md` | W3 T-032 | W3 T-V03 | staged |
| `leaf-execution.md` | W3 T-033 | W3 T-V03 | staged |
| `validation-evidence.md` | W3 T-034 | W3 T-V03 | staged |
| `grounding.md` | W3 T-035 | W3 T-V03 | staged |
| `cli-tools.md` | W3 T-036 | W3 T-V03 | staged |
| `mcp-governance.md` | W3 T-037 | W3 T-V03 | staged |
| `dual-memory.md` | W3 T-038 | W3 T-V03 | staged |
| `altitude-phases.md` | W3 T-039 | W3 T-V03 | staged |
| `altitude-start.md` | W3 T-040 | W3 T-V03 | staged |
| `agentspec-start.md` | W3 T-041 | W3 T-V03 | staged |
| `rule-loader.md` | W3 T-042 | W3 T-V03 | staged |
| `external-references.md` | W3 T-043 | W3 T-V03 | staged |
| `skill-activation.md` | W3 T-044 | W3 T-V03 | staged |
| `command-overlay.md` | W3 T-045 | W3 T-V03 | staged |
