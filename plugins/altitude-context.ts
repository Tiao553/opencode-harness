import type { Plugin } from "@opencode-ai/plugin"

type AgentConfig = {
  description?: string
}

const ALTITUDE_AGENT_SUMMARIES: Record<string, string> = {
  "altitude-intent": "High-altitude intent capture. Load active state and intent only.",
  "altitude-structure": "System-altitude structure mapping. Load memory indexes and targeted repo context.",
  "altitude-plan": "Planning-altitude decomposition. Load intent, structure, and shared task contracts.",
  "altitude-execution": "Low-altitude execution. Load active state, state.md, active task, and referenced files only.",
  "altitude-validation": "Validation altitude. Load task, diff, ledger, evidence, and validation policy.",
  "altitude-report": "Report altitude. Load change artifacts and summarize from files, not chat.",
  "altitude-memory": "Memory altitude. Load report, ship note, lessons candidates, and memory index.",
}

function annotateAltitudeAgents(cfg: { agent?: Record<string, AgentConfig | undefined> }): void {
  if (!cfg.agent) return

  for (const [name, summary] of Object.entries(ALTITUDE_AGENT_SUMMARIES)) {
    const agent = cfg.agent[name]
    if (!agent) continue
    agent.description = agent.description ? `${agent.description} ${summary}` : summary
  }
}

export default (async () => {
  return {
    config: async (cfg) => {
      annotateAltitudeAgents(cfg as { agent?: Record<string, AgentConfig | undefined> })
    },
  }
}) satisfies Plugin
