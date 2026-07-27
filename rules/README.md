# Rules

This directory contains lazy-loaded rule files for the OpenCode Harness V3 skill-based architecture.

**Loading policy (ADR-0006):** Rule files are never preloaded. They are loaded only when their trigger condition matches the current request. The compact AGENTS.md kernel references this registry to determine which file to load.

**Format:** Each file is a markdown document the model reads as part of its context. Keep each file under 150 lines so loading cost is bounded.

**Current status:** Staged — W3. Active in W4 when AGENTS.md kernel is rewritten.

---

## Files

See `_registry.md` for the full trigger-to-file mapping.
