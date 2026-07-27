# T-002 OpenCode Configuration Provenance

## Runtime

- OpenCode executable: `/home/ubuntu/.nvm/versions/node/v24.16.0/bin/opencode`
- Resolved executable: `/home/ubuntu/.nvm/versions/node/v24.16.0/lib/node_modules/opencode-ai/bin/opencode.exe`
- Version: `1.18.3`
- Config root from `opencode debug paths`: `/home/ubuntu/.config/opencode`
- Current repository root: `/home/ubuntu/.config/opencode`

## Sanitized Environment

| Variable | Value |
|---|---|
| `HOME` | `~` |
| `XDG_CONFIG_HOME` | unset |
| `OPENCODE_CONFIG` | unset |
| `OPENCODE_CONFIG_DIR` | unset |

## Configuration Sources and Precedence

1. No explicit config path or config directory override is active.
2. No project-local `.opencode/opencode.json` or `.opencode/opencode.jsonc` exists.
3. `opencode.json` and `opencode.jsonc` exist at the current repository root.
4. That root is also the OpenCode global config root, so the project and global locations collapse to one physical directory.
5. `opencode.json` contains the active runtime behavior; `opencode.jsonc` contains only the schema declaration and adds no behavioral key.
6. With `OPENCODE_DISABLE_PROJECT_CONFIG=1`, `opencode debug agent altitude-maestro` still resolves `altitude-maestro` as a custom primary agent. This confirms the global configuration source remains active.

The documented general precedence is explicit environment configuration, then project configuration over global configuration. In this installation, no separate project-local source or environment override is active, so there is no cross-file behavioral conflict to resolve.

## MCP CLI Result

Both official commands reported no MCP servers configured:

```text
opencode mcp list: No MCP servers configured
rtk opencode mcp list: No MCP servers configured
```

No MCP-specific tool namespace is visible in the current Plan session. Therefore no UI/CLI discrepancy is present in the current runtime observation.

## Diagnostic Limitation

`opencode debug config` exits with status 0 but emits 146176 bytes that are not valid JSON. Its raw output was not persisted because it is not machine-parseable and may contain more configuration detail than this sanitized evidence requires. T-007 records this as a runtime-baseline diagnostic limitation; T-159 later tests configuration precedence in isolated fixtures.

## Security

This report records only executable/config paths, variable names with sanitized values, and command outcomes. It contains no credential, token, or secret value.
