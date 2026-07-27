# Plugin Disposition Matrix — W10

**T-141: Classify plugins as keep, refactor, replace, or remove**
**Date:** 2026-07-25

| Plugin | Current file | Disposition | Target | Wave owner |
|---|---|---|---|---|
| `altitude-context.ts` | `plugins/altitude-context.ts` | **Retire** — injects phase-agent descriptions that won't exist post-W6 | Remove from activation bundle | W10 |
| `altitude-filestore.ts` | `plugins/altitude-filestore.ts` | **Keep** — file/allocation behavior is neutral and useful | Retain; update contract refs | W10 |
| `specs-state.ts` | `plugins/specs-state.ts` | **Keep as policy doc** — no durable hook exists; explicitly a no-op shim | Retain with honest documentation | W10 |
| `rtk-native.ts` | `plugins/rtk-native.ts` | **Keep** — RTK command rewriting is useful | Retain; align with `rules/cli-tools.md` | W10 |
| `headroom-guard.ts` | `plugins/headroom-guard.ts` | **Merge** with `context-budget.ts` | One canonical plugin | W10 |
| `context-budget.ts` | `plugins/context-budget.ts` | **Merge** with `headroom-guard.ts` | One canonical plugin | W10 |
