import { tool } from "@opencode-ai/plugin"

export default tool({
  description:
    "Evaluate faithfulness activation gates before proceeding with a task. " +
    "Returns PASS or a list of active gates that must be resolved first.",
  args: {
    confidence: tool.schema
      .number()
      .describe("Current confidence level 0.0–1.0"),
    task_description: tool.schema
      .string()
      .describe("What the agent is about to do"),
    files_affected: tool.schema
      .number()
      .optional()
      .describe("Number of files to be modified"),
    involves_sensitive: tool.schema
      .boolean()
      .optional()
      .describe("Does task touch auth, RLS, secrets, or PII?"),
    routes_matched: tool.schema
      .number()
      .optional()
      .describe("Number of routes matched for this request"),
  },
  async execute(args) {
    const gates: string[] = []

    if (args.confidence < 0.8) {
      gates.push("STOP: confidence < 0.80 — ask one clarifying question before routing")
    }
    if ((args.routes_matched ?? 0) >= 2 && args.confidence < 0.85) {
      gates.push("STOP: request maps to multiple routes — ask user to confirm domain")
    }
    if ((args.files_affected ?? 0) > 3) {
      gates.push("GATE: > 3 files affected — confirm scope with user before proceeding")
    }
    if (args.involves_sensitive === true) {
      gates.push("GATE: sensitive context detected — route through dev.security-guardian first")
    }

    return gates.length === 0
      ? "PASS: all gates clear — proceed"
      : "GATES ACTIVE:\n" + gates.join("\n")
  },
})
