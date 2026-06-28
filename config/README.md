# config/ — Runtime Configuration

This directory contains **runtime configuration files** for OpenCode Harness V3.

## Configuration Files

### Routing
- **routing.json** — Agent routing table: meta-routes (altitude, data-engineer), phase subagents, specialists, priorities

### Grounding & Reference
- **grounding.md** — Thin index to 23 `.specs/shared/` contracts; maps high-level concepts to detailed policies

### Security & Permissions
- **security-settings.json** — Runtime security configuration
- **opencode.example.jsonc** — Template for OpenCode configuration

---

## Purpose

Operational **runtime configuration** that the system reads at execution time.

**Use case**: When configuring OpenCode behavior, adding routes, or understanding how the system is configured at runtime.

**Do NOT use** for: Explaining how Harness V3 works (see `docs/` instead) or planning/control (see `.specs/control/` instead)

---

## Navigation

- **Routing**: See `routing.json` for agent routing configuration
- **Policies**: See `grounding.md` for index to `.specs/shared/` contracts
- **Security**: See `security-settings.json` for security configuration
