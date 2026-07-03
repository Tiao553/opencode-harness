import type { Plugin } from "@opencode-ai/plugin"

type FileReadOptions = {
  force_no_compress?: boolean
  defer_if_expensive?: boolean
  tracking?: boolean
  context?: string
}

type FileReadResult = {
  content: string | null
  bytes_used: number
  bytes_original: number
  compressed: boolean
  compression_ratio?: number
  logged: boolean
  timestamp: string
  error?: string
  deferred?: boolean
  skipped?: boolean
}

type GlobOptions = {
  limit?: number
  raise_on_ambiguous?: boolean
}

type GlobResult = {
  matches: string[]
  count: number
  ambiguous: boolean
  filtered_by_user?: boolean
  question_raised?: boolean
}

type FileOp = {
  operation: 'FILE_READ' | 'FILE_SKIP' | 'FILE_DEFER' | 'FILE_FAILED'
  file: string
  size_bytes?: number
  compressed?: boolean
  compression_ratio?: number
  reason?: string
  context?: string
}

/**
 * Altitude FileStore Plugin
 * 
 * Central file reading system for all altitude agents.
 * - Wraps file operations with RTK compression + Headroom budgeting
 * - Logs ALL operations to TODOWRITE
 * - Raises QUESTION only when decisions are blocking
 * - Provides complete audit trail
 */

// Global state
let headroom_state = {
  budget_total: 100 * 1024, // 100KB default
  budget_used: 0,
  compression_active: false,
  phase: 'unknown',
}

let allowed_files: string[] = []
let rtk_available = true
let headroom_guard_available = true

/**
 * Main file reading function
 */
async function altitude_read(
  file: string,
  options: FileReadOptions = {}
): Promise<FileReadResult> {
  const timestamp = new Date().toISOString()
  
  try {
    // 1. Check allocation
    if (!check_allocation(file)) {
      altitude_log_file_operation({
        operation: 'FILE_SKIP',
        file,
        reason: 'outside allowed_files allocation',
        context: options.context,
      })
      
      return {
        content: null,
        bytes_used: 0,
        bytes_original: 0,
        compressed: false,
        logged: true,
        timestamp,
        skipped: true,
      }
    }

    // 2. Get file size (estimated)
    const estimated_size = estimate_file_size(file)

    // 3. Check Headroom budget
    const headroom_status = check_headroom()
    const budget_remaining = headroom_state.budget_total - headroom_state.budget_used

    let content: string
    let actual_size = estimated_size
    let compressed = false
    let compression_ratio = 1.0

    if (budget_remaining < estimated_size && !options.force_no_compress) {
      // Try RTK compression
      if (options.defer_if_expensive && budget_remaining < estimated_size * 0.5) {
        // Defer large files when budget very low
        altitude_log_file_operation({
          operation: 'FILE_DEFER',
          file,
          size_bytes: estimated_size,
          reason: 'defer_if_expensive option + budget pressure',
          context: options.context,
        })

        return {
          content: null,
          bytes_used: 0,
          bytes_original: estimated_size,
          compressed: false,
          logged: true,
          timestamp,
          deferred: true,
        }
      }

      // Apply RTK compression
      if (rtk_available && headroom_status.status === 'WARN') {
        const rtk_result = apply_rtk_compression(file, budget_remaining)
        content = rtk_result.content
        actual_size = rtk_result.size
        compressed = true
        compression_ratio = estimated_size / actual_size
      } else if (headroom_status.status === 'CRITICAL') {
        // Budget critical - raise QUESTION
        const user_choice = await raise_headroom_question(file, estimated_size, budget_remaining)
        
        altitude_log_file_operation({
          operation: user_choice.action === 'defer' ? 'FILE_DEFER' : 'FILE_SKIP',
          file,
          size_bytes: estimated_size,
          reason: `user choice: ${user_choice.label}`,
          context: options.context,
        })

        if (user_choice.action === 'defer') {
          return {
            content: null,
            bytes_used: 0,
            bytes_original: estimated_size,
            compressed: false,
            logged: true,
            timestamp,
            deferred: true,
          }
        } else {
          return {
            content: null,
            bytes_used: 0,
            bytes_original: estimated_size,
            compressed: false,
            logged: true,
            timestamp,
            skipped: true,
          }
        }
      } else {
        content = ''
      }
    } else {
      // Load without compression
      content = await load_file_content(file)
      actual_size = content.length
    }

    // 4. Update budget
    headroom_state.budget_used += actual_size

    // 5. Log operation
    if (options.tracking !== false) {
      altitude_log_file_operation({
        operation: 'FILE_READ',
        file,
        size_bytes: estimated_size,
        compressed,
        compression_ratio: compressed ? compression_ratio : undefined,
        context: options.context,
      })
    }

    return {
      content,
      bytes_used: actual_size,
      bytes_original: estimated_size,
      compressed,
      compression_ratio: compressed ? compression_ratio : undefined,
      logged: options.tracking !== false,
      timestamp,
    }
  } catch (error) {
    altitude_log_file_operation({
      operation: 'FILE_FAILED',
      file,
      reason: `error: ${error}`,
      context: options.context,
    })

    return {
      content: null,
      bytes_used: 0,
      bytes_original: 0,
      compressed: false,
      logged: true,
      timestamp,
      error: String(error),
    }
  }
}

/**
 * File globbing with ambiguity detection
 */
async function altitude_glob(
  pattern: string,
  options: GlobOptions = {}
): Promise<GlobResult> {
  const limit = options.limit || 100
  
  try {
    const matches = glob_pattern(pattern, limit)
    const ambiguous = (options.raise_on_ambiguous !== false) && matches.length > 5

    if (ambiguous) {
      // Raise QUESTION for user to specify
      const user_choice = await raise_glob_question(pattern, matches)
      
      altitude_log_file_operation({
        operation: 'FILE_READ',
        file: `glob:${pattern}`,
        size_bytes: matches.length,
        reason: `user filtered from ${matches.length} to ${user_choice.count} matches`,
        context: `User selected: ${user_choice.label}`,
      })

      return {
        matches: user_choice.matches,
        count: user_choice.count,
        ambiguous: false,
        filtered_by_user: true,
        question_raised: true,
      }
    }

    return {
      matches,
      count: matches.length,
      ambiguous: false,
      question_raised: false,
    }
  } catch (error) {
    return {
      matches: [],
      count: 0,
      ambiguous: false,
      question_raised: false,
    }
  }
}

/**
 * File searching (lazy logging)
 */
async function altitude_grep(pattern: string, file: string): Promise<any> {
  try {
    const content = await load_file_content(file)
    const regex = new RegExp(pattern, 'gm')
    const matches = content.match(regex) || []

    // Only log if used for decision (caller responsibility)
    return {
      matches,
      count: matches.length,
      logged: false,
    }
  } catch (error) {
    return {
      matches: [],
      count: 0,
      logged: false,
      error: String(error),
    }
  }
}

/**
 * Check headroom budget status
 */
function altitude_check_headroom() {
  const budget_remaining = headroom_state.budget_total - headroom_state.budget_used
  const percent_remaining = (budget_remaining / headroom_state.budget_total) * 100

  let status: 'OK' | 'WARN' | 'CRITICAL'
  if (percent_remaining > 30) {
    status = 'OK'
  } else if (percent_remaining > 10) {
    status = 'WARN'
  } else {
    status = 'CRITICAL'
  }

  return {
    budget_total: headroom_state.budget_total,
    budget_used: headroom_state.budget_used,
    budget_remaining,
    compression_active: headroom_state.compression_active,
    phase: headroom_state.phase,
    status,
  }
}

/**
 * Manual logging for edge cases
 */
function altitude_log_file_operation(op: FileOp) {
  // Format TODOWRITE entry
  const label = format_todowrite_entry(op)
  
  // In real implementation, this would call TODOWRITE API
  // For now, we log to console
  console.debug(`[FileStore] ${label}`)
  
  // Could also store in ledger file if needed
  return {
    logged: true,
    entry: label,
  }
}

// ============ HELPER FUNCTIONS ============

function check_allocation(file: string): boolean {
  if (allowed_files.length === 0) {
    return true // No restrictions if not set
  }

  return allowed_files.some(pattern => {
    if (pattern.includes('*')) {
      // Simple glob-like matching
      const regex = new RegExp(`^${pattern.replace(/\*/g, '.*')}$`)
      return regex.test(file)
    }
    return file.startsWith(pattern) || file === pattern
  })
}

function estimate_file_size(file: string): number {
  // Rough estimation; actual implementation would stat the file
  // This is placeholder for demo
  const size_map: Record<string, number> = {
    'PRD.md': 216 * 70, // ~216 lines * ~70 chars/line
    'ADR.md': 220 * 70,
    'TEST-SPEC.md': 343 * 70,
    'DESIGN.md': 684 * 70,
    'state.md': 111 * 70,
  }

  return size_map[file] || 5000 // Default 5KB
}

function apply_rtk_compression(file: string, budget: number): { content: string; size: number } {
  // Simple lossy compression: keep first 70% of lines
  const target_size = Math.min(budget * 0.9, 10000)
  const reduction_ratio = target_size / estimate_file_size(file)

  // Placeholder: would call actual RTK compression
  return {
    content: `[RTK Compressed: ${file}]`,
    size: Math.floor(estimate_file_size(file) * reduction_ratio),
  }
}

async function load_file_content(file: string): Promise<string> {
  // Placeholder: would actually read file via MCP or fs
  return `[Content of ${file}]`
}

function glob_pattern(pattern: string, limit: number): string[] {
  // Placeholder: would actually glob files
  // For testing, return mock results
  if (pattern.includes('**/*.md')) {
    return Array.from({ length: Math.min(500, limit) }, (_, i) => `file_${i}.md`)
  }
  return []
}

function format_todowrite_entry(op: FileOp): string {
  const size_str = op.size_bytes ? `(${Math.round(op.size_bytes / 1024)}KB)` : ''
  const compressed_str = op.compressed ? ` → ${Math.round(op.size_bytes! * (1 - (op.compression_ratio || 0.8)) / 1024)}KB` : ''
  const context_str = op.context ? ` | ${op.context}` : ''

  return `${op.operation} | ${op.file} ${size_str}${compressed_str}${context_str} | ${op.reason || 'ok'}`
}

async function raise_headroom_question(
  file: string,
  file_size: number,
  budget_remaining: number
): Promise<{ action: string; label: string }> {
  // In real implementation, would call question() function
  // Placeholder: default to defer
  console.warn(`[FileStore QUESTION] Headroom exhausted (${budget_remaining / 1024}KB remaining, need ${Math.round(file_size / 1024)}KB)`)
  return { action: 'defer', label: 'Defer to next phase' }
}

async function raise_glob_question(
  pattern: string,
  matches: string[]
): Promise<{ matches: string[]; count: number; label: string }> {
  // In real implementation, would call question() function
  // Placeholder: return first 5 matches
  console.warn(`[FileStore QUESTION] Pattern matched ${matches.length} files. Selecting subset...`)
  return {
    matches: matches.slice(0, 5),
    count: 5,
    label: 'First 5 matches (user can refine)',
  }
}

function set_headroom_budget(budget_kb: number) {
  headroom_state.budget_total = budget_kb * 1024
}

function set_allowed_files(files: string[]) {
  allowed_files = files
}

function set_phase(phase: string) {
  headroom_state.phase = phase
}

function reset_headroom_budget() {
  headroom_state.budget_used = 0
  headroom_state.compression_active = false
}

// ============ PLUGIN EXPORT ============

const AltitudeFileStorePlugin: Plugin = async (_input, _options) => {
  return {
    config: async (cfg) => {
      // Load budget config from opencode.json
      const budget_config = (cfg as any).headroom || {}
      set_headroom_budget(budget_config.budget_total_kb || 100)

      // Make plugin functions available globally
      if (typeof global !== 'undefined') {
        ;(global as any).altitude_read = altitude_read
        ;(global as any).altitude_glob = altitude_glob
        ;(global as any).altitude_grep = altitude_grep
        ;(global as any).altitude_check_headroom = altitude_check_headroom
        ;(global as any).altitude_log_file_operation = altitude_log_file_operation
        ;(global as any).set_headroom_budget = set_headroom_budget
        ;(global as any).set_allowed_files = set_allowed_files
        ;(global as any).set_phase = set_phase
        ;(global as any).reset_headroom_budget = reset_headroom_budget
      }
    },
  }
}

export default AltitudeFileStorePlugin
