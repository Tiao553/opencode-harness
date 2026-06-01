import { tool } from "@opencode-ai/plugin"
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs"
import { dirname, join } from "path"

const STATE_PATH = join(
  process.env.HOME!,
  ".config/opencode/state/verify_loop.json",
)

interface StepRecord {
  step: string
  verdict: "PASS" | "FAIL" | "BLOCKED"
  retry: number
  at: string
}

interface LoopState {
  session: string | null
  steps: StepRecord[]
}

function loadState(): LoopState {
  if (!existsSync(STATE_PATH)) return { session: null, steps: [] }
  return JSON.parse(readFileSync(STATE_PATH, "utf8")) as LoopState
}

function saveState(state: LoopState): void {
  mkdirSync(dirname(STATE_PATH), { recursive: true })
  writeFileSync(STATE_PATH, JSON.stringify(state, null, 2))
}

export default tool({
  description:
    "Track step completion in a multi-step verification loop. " +
    "Call after each step with its result. " +
    "Returns next action: PASS (advance), FAIL (retry), BLOCKED (halt).",
  args: {
    session_id: tool.schema
      .string()
      .describe("Unique ID for this task session — use a short slug"),
    step: tool.schema.string().describe("Step description"),
    verdict: tool.schema
      .enum(["PASS", "FAIL", "BLOCKED"])
      .describe("Step result"),
    total_steps: tool.schema
      .number()
      .optional()
      .describe("Total steps in the plan (for progress reporting)"),
  },
  async execute(args) {
    const state = loadState()

    if (state.session !== args.session_id) {
      state.session = args.session_id
      state.steps = []
    }

    const retries = state.steps.filter((s) => s.step === args.step).length

    state.steps.push({
      step: args.step,
      verdict: args.verdict as "PASS" | "FAIL" | "BLOCKED",
      retry: retries,
      at: new Date().toISOString(),
    })
    saveState(state)

    if (args.verdict === "BLOCKED") {
      return "BLOCKED: surface to user and halt loop — do not continue"
    }

    if (args.verdict === "FAIL") {
      if (retries >= 2) return "FAIL: max retries (2) reached — escalate to user"
      return `FAIL: retry step (attempt ${retries + 1} of 2)`
    }

    const passed = state.steps.filter((s) => s.verdict === "PASS").length
    const total = args.total_steps ?? "?"
    return `PASS: step recorded (${passed}/${total} complete) — advance to next step`
  },
})
