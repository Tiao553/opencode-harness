import type { Plugin } from "@opencode-ai/plugin"

type Rewrite = {
  from: RegExp
  to: string
}

export const SAFE_RTK_REWRITES: Rewrite[] = [
  { from: /^git status\b/, to: "rtk git status" },
  { from: /^git diff\b/, to: "rtk git diff" },
  { from: /^git log\b/, to: "rtk git log" },
  { from: /^ls\b/, to: "rtk ls" },
  { from: /^rg\b/, to: "rtk rg" },
  { from: /^grep\b/, to: "rtk grep" },
  { from: /^find\b/, to: "rtk find" },
]

export function suggestRtkRewrite(command: string): string | null {
  if (/\brm\b|\bsudo\b|\bgit reset\b|\bgit clean\b/.test(command)) {
    return null
  }

  const rewrite = SAFE_RTK_REWRITES.find((candidate) => candidate.from.test(command))
  if (!rewrite) return null
  return command.replace(rewrite.from, rewrite.to)
}

/**
 * The plugin records the rewrite policy as code. Actual command interception
 * requires a runtime shell hook; until then agents must apply RTK by policy.
 */
export default (async () => {
  return {
    config: async () => {
      // Intentionally no-op until shell interception is available.
    },
  }
}) satisfies Plugin
