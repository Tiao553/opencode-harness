import type { Plugin } from "@opencode-ai/plugin"

const CONTEXT_BUDGET_MEMORY_PATH = ".specs/memory/context-budget.md"

const ALTITUDE_CONTEXT_LIMITS = {
  intent: ["active-state", "00-intent"],
  structure: ["active-state", "00-intent", "memory-index", "targeted-search"],
  plan: ["00-intent", "01-structure", "shared-contracts"],
  execution: ["active-state", "state", "active-task", "referenced-files"],
  validation: ["active-task", "diff", "evidence", "acceptance-criteria"],
  report: ["state", "ledger", "validation", "evidence-summaries", "decisions"],
  memory: ["report", "ship-note", "lessons-candidates", "memory-index"],
} as const

const ContextBudgetPlugin: Plugin = async (_input, _options) => {
  return {
    config: async () => {
      if (typeof global !== 'undefined') {
        ;(global as any).CONTEXT_BUDGET_MEMORY_PATH = CONTEXT_BUDGET_MEMORY_PATH
        ;(global as any).ALTITUDE_CONTEXT_LIMITS = ALTITUDE_CONTEXT_LIMITS
      }

      // Budget accounting is policy-only until token/read telemetry is exposed.
    },
  }
}

export default ContextBudgetPlugin
