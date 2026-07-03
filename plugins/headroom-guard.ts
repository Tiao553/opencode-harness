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

/**
 * Wave 24: Headroom integration with altitude-filestore
 * 
 * Provides budget validation and escalation policies
 */
export function get_budget_config(): {
  total_kb: number
  warn_percent: number
  critical_percent: number
  block_percent: number
} {
  return {
    total_kb: parseInt(process.env.HEADROOM_BUDGET_KB || "100", 10),
    warn_percent: parseInt(process.env.HEADROOM_WARN_PERCENT || "20", 10),
    critical_percent: parseInt(process.env.HEADROOM_CRITICAL_PERCENT || "10", 10),
    block_percent: parseInt(process.env.HEADROOM_BLOCK_PERCENT || "5", 10),
  }
}

export function calculate_budget_status(used: number, total: number): {
  percent_remaining: number
  status: 'OK' | 'WARN' | 'CRITICAL' | 'BLOCK'
  action: 'proceed' | 'compress' | 'ask' | 'block'
} {
  const percent_remaining = ((total - used) / total) * 100

  let status: 'OK' | 'WARN' | 'CRITICAL' | 'BLOCK'
  let action: 'proceed' | 'compress' | 'ask' | 'block'

  if (percent_remaining > 30) {
    status = 'OK'
    action = 'proceed'
  } else if (percent_remaining > 10) {
    status = 'WARN'
    action = 'compress'
  } else if (percent_remaining > 5) {
    status = 'CRITICAL'
    action = 'ask'
  } else {
    status = 'BLOCK'
    action = 'block'
  }

  return { percent_remaining, status, action }
}

export function validate_safe_context_patterns(patterns: string[]): {
  valid: boolean
  unsafe_patterns: string[]
  recommendation: string
} {
  const unsafe_patterns = patterns.filter(p => {
    // Patterns that might load entire KB or archive
    return /\*\*\/\*|\barchive\b|\ball\b/.test(p)
  })

  return {
    valid: unsafe_patterns.length === 0,
    unsafe_patterns,
    recommendation: unsafe_patterns.length > 0
      ? `Remove unsafe patterns: ${unsafe_patterns.join(', ')}`
      : 'All patterns are safe',
  }
}

export function escalation_flow(status: string, file: string, budget_remaining: number): {
  level: number
  action: string
  message: string
} {
  const level_map: Record<string, number> = {
    'OK': 1,
    'WARN': 2,
    'CRITICAL': 3,
    'BLOCK': 4,
  }

  const level = level_map[status] || 1

  if (level === 1) {
    return {
      level,
      action: 'proceed',
      message: `Budget OK: ${budget_remaining / 1024}KB remaining. Loading ${file}...`,
    }
  } else if (level === 2) {
    return {
      level,
      action: 'compress',
      message: `Budget low (${budget_remaining / 1024}KB remaining). Applying RTK compression for ${file}...`,
    }
  } else if (level === 3) {
    return {
      level,
      action: 'ask',
      message: `Budget critical (${budget_remaining / 1024}KB remaining). User must decide: load, defer, or truncate ${file}`,
    }
  } else {
    return {
      level,
      action: 'block',
      message: `Budget exhausted (${budget_remaining / 1024}KB remaining). Cannot load ${file}. Please increase budget or defer files.`,
    }
  }
}

export default (async () => {
  if (compressedModeEnabled() && !headroomConfigured()) {
    console.warn("[headroom-guard] compressed mode requested but Headroom is not configured; use normal provider fallback.")
  }

  return {
    config: async (cfg: any) => {
      // Load budget config
      const budget_config = get_budget_config()

      // Make validation functions available for altitude-filestore
      if (typeof global !== 'undefined') {
        ;(global as any).get_budget_config = get_budget_config
        ;(global as any).calculate_budget_status = calculate_budget_status
        ;(global as any).validate_safe_context_patterns = validate_safe_context_patterns
        ;(global as any).escalation_flow = escalation_flow
      }

      // Headroom is optional. Do not mutate provider config from this shim.
    },
  }
}) satisfies Plugin

