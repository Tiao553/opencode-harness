import type { Plugin } from "@opencode-ai/plugin"

declare const process: {
  env: Record<string, string | undefined>
}

function compressedModeEnabled(): boolean {
  return process.env.OPENCODE_COMPRESSED_MODE === "1" || process.env.HEADROOM_MODE === "compressed"
}

function headroomConfigured(): boolean {
  return Boolean(process.env.HEADROOM_BASE_URL || process.env.HEADROOM_API_KEY)
}

export default (async () => {
  if (compressedModeEnabled() && !headroomConfigured()) {
    console.warn("[headroom-guard] compressed mode requested but Headroom is not configured; use normal provider fallback.")
  }

  return {
    config: async () => {
      // Headroom is optional. Do not mutate provider config from this shim.
    },
  }
}) satisfies Plugin
