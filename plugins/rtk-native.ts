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
 * Wave 24: RTK integration with altitude-filestore
 * 
 * Provides compression algorithms for file content
 */
export function compress_content_lossy(content: string, target_ratio: number = 0.8): string {
  if (!content) return content

  // Simple lossy compression: keep first N lines based on target ratio
  const lines = content.split('\n')
  const keep_lines = Math.ceil(lines.length * target_ratio)
  
  return lines.slice(0, keep_lines).join('\n') + '\n[... lossy compression applied ...]'
}

export function compress_content_lossless(content: string): string {
  // Could use actual compression library like zlib
  // For now, simple approach: encode + size metric
  return Buffer.from(content).toString('base64')
}

export function is_rtk_command(command: string): boolean {
  return command.startsWith('rtk ')
}

/**
 * The plugin records the rewrite policy as code. Actual command interception
 * requires a runtime shell hook; until then agents must apply RTK by policy.
 */
export default (async () => {
  return {
    config: async (cfg: any) => {
      // Make compression functions available for altitude-filestore
      if (typeof global !== 'undefined') {
        ;(global as any).compress_content_lossy = compress_content_lossy
        ;(global as any).compress_content_lossless = compress_content_lossless
        ;(global as any).suggestRtkRewrite = suggestRtkRewrite
        ;(global as any).is_rtk_command = is_rtk_command
      }
    },
  }
}) satisfies Plugin

