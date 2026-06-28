import type { Plugin } from "@opencode-ai/plugin"

/**
 * Specs state policy shim.
 *
 * Current OpenCode config plugins can shape config, but this harness does not
 * yet expose a stable pre-tool hook that can synchronously block edits based on
 * `.specs/memory/active-state.md`. The hard gate therefore lives in the
 * altitude agents and shared contracts until a runtime hook is available.
 */

export const REQUIRED_EXECUTION_FIELDS = [
  "active_change",
  "active_task",
  "allowed_files",
  "forbidden_scope",
  "acceptance_criteria",
  "verification_commands",
  "evidence_required",
] as const

export default (async () => {
  return {
    config: async () => {
      // Intentionally no-op until the runtime exposes a durable state hook.
    },
  }
}) satisfies Plugin
