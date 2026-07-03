# HARNESS_V3_MIGRATION_GUIDE.md

## Waves 18-23 Agent Consolidation

**Effective Date:** 2026-06-30  
**Change ID:** waves-18-23-implementation  
**Status:** LIVE (BLOCO 4 T-06)

---

## Overview

Waves 18-23 consolidate three altitude agents into one unified agent: **`altitude-maestro.agent.md`**

This provides:
- Single entry point for all strategic requests
- Unified decision map with 9 gates
- Integrated multi-wave orchestration
- Clearer request routing
- Stronger lessons application

---

## What Changed

### Consolidated Agents

| Old Agent | Status | Migrated To | Last Available |
|---|---|---|---|
| `altitude.agent.md` | ⚠️ DEPRECATED | `altitude-maestro.agent.md` | W17 final commit |
| `altitude-coordinator.agent.md` | ⚠️ DEPRECATED | `altitude-maestro.agent.md` (Sections 5) | W17 final commit |

### New Agent

| New Agent | Lines | First Commit | Phase |
|---|---|---|---|
| `altitude-maestro.agent.md` | ~670 | 2026-06-30 (BLOCO 1) | Execution |

### Phase Agents (Unchanged)

These remain in use and are **NOT deprecated**:

- `altitude-intent.agent.md` — Intent phase routing
- `altitude-structure.agent.md` — Structure phase routing
- `altitude-plan.agent.md` — Design/Plan phase routing (enhanced: +118 lines for 4-doc gate)
- `altitude-execution.agent.md` — Execution phase routing (enhanced: +88 lines for decision map)
- `altitude-validation.agent.md` — Validation phase routing
- `altitude-report.agent.md` — Reporting phase routing
- `altitude-memory.agent.md` — Memory/Ship phase routing (enhanced: +122 lines for lessons)

---

## Migration Path by Use Case

### Use Case 1: Direct Agent Reference

**Before (Waves 1-17):**
```bash
# Old way: direct reference
/altitude                  # routes to altitude.agent.md
/altitude-coordinator      # routes to altitude-coordinator.agent.md
```

**After (Waves 18+):**
```bash
# New way: automatic routing
# User commands route through altitude-maestro automatically
# No user action required if using OpenCode command interface
```

**Action Required:** None (automatic via command routing)

---

### Use Case 2: Phase-Specific Entry Point

**Before & After (Unchanged):**
```bash
# Direct phase entry still works
/workflow:define           # altitude-intent
/workflow:design           # altitude-plan
/workflow:build            # altitude-execution
/workflow:validate         # altitude-validation
/workflow:ship             # altitude-memory
```

**Action Required:** None

---

### Use Case 3: Existing Archived Changes (W7-17)

**Before (While in W7-17):**
- Changes referenced `altitude.agent.md` explicitly
- Some multi-wave tasks referenced `altitude-coordinator.agent.md`

**After (Archived):**
- Old files still exist (marked DEPRECATED) for reference
- Archived changes can still be referenced
- No action required on archived changes

**Action Required:** None (backward compatible)

---

### Use Case 4: New Changes (W18+)

**Before (W1-17):**
```
New request
  → classify
  → route to altitude.agent.md
  → altitude calls phase agents
```

**After (W18+):**
```
New request
  → classify
  → route to altitude-maestro.agent.md
  → maestro calls phase agents (same behavior)
  → multi-wave requests handled in Gate 5 (orchestration section)
```

**Action Required:** None (transparent routing via OpenCode)

---

## Technical Details

### Decision Map Consolidation

**Old Model (W1-17):**
- `altitude.agent.md`: Gates 1-3 (routing)
- `altitude-coordinator.agent.md`: Orchestration logic
- Phase agents: Gates 4-6 per-phase

**New Model (W18-23):**
- `altitude-maestro.agent.md`: Gates 1-6 + Gates 7-9 (bloco execution gates)
  - Gate 1-3: State resolution + request classification
  - Gate 4: Design 4-doc validation (new)
  - Gate 5: Multi-wave orchestration (from coordinator)
  - Gate 6: Execution readiness (new)
  - Gates 7-9: Bloco execution gates (new, for execution tracking)

---

### Lessons Application Integration

All five altitude phase agents updated with:
- `ask-user-policy.md` pre-call checklist (in Recovery Protocol)
- question() enforcement (GRILL ME pattern)
- Lessons loaded from `WAVES-7-17-LESSONS-LEARNED.md`

**Enhancement Distribution:**
- `altitude-plan.agent.md`: +118 lines (4-doc gate implementation)
- `altitude-execution.agent.md`: +88 lines (decision map + lessons)
- `altitude-memory.agent.md`: +122 lines (question() audit logging)

---

### File Deprecation Timeline

| Status | File | When |
|---|---|---|
| ✅ Active | `altitude-maestro.agent.md` | 2026-06-30 (W18+) |
| ⚠️ Deprecated | `altitude.agent.md` | 2026-06-30 (T-06) |
| ⚠️ Deprecated | `altitude-coordinator.agent.md` | 2026-06-30 (T-06) |
| ✅ Archived | Both above | Will move to `agents/archive/` in Ship phase |

---

## For Developers

### If you're modifying altitude agents:

1. **For routing logic:**  
   → Modify `agents/altitude-maestro.agent.md` (single source of truth)

2. **For phase-specific behavior:**  
   → Modify `agents/altitude-[phase].agent.md` (unchanged)

3. **For lesson integration:**  
   → Update `agents/altitude-[phase].agent.md` Recovery Protocols

4. **For orchestration:**  
   → Modify maestro's Section 5 (Orchestration Logic)

### If you're reviewing PRs:

1. Check that references to `altitude.agent.md` are marked as backward-compat only
2. New multi-wave work should reference `altitude-maestro.agent.md`
3. No modifications to deprecated agents (they're read-only for reference)

### If you're working on archived changes:

1. No action required
2. Old agents remain available for reference
3. If re-opening an archived change, consider migrating to new agent but not required

---

## Q&A

### Q: Do I need to update my existing code?

**A:** No. If you're using OpenCode's command interface, routing is automatic. If you have direct agent references in code/scripts, they still work (backward compatible).

### Q: What about the old altitude.agent.md file?

**A:** It remains in the repository (marked DEPRECATED). This preserves:
- Git history for reference
- Ability to revert if needed  
- Documentation for learning

To actually delete it, we'd need to:
1. Archive it to `.specs/archive/`
2. Confirm no references exist in active changes
3. Then delete from main tree

This happens in Ship phase (after validation).

### Q: Will my existing multi-wave orchestration still work?

**A:** Yes. All orchestration logic from `altitude-coordinator.agent.md` is now in `altitude-maestro.agent.md` Section 5. Behavior is identical.

### Q: Should I use altitude-maestro for new work?

**A:** Yes. For any new strategic work (W18+), use `altitude-maestro.agent.md`. It replaces both `altitude.agent.md` and `altitude-coordinator.agent.md`.

### Q: When do the old files disappear completely?

**A:** After Ship phase (W18-23 completion):
1. Both files moved to `.specs/archive/waves-18-23/agents/`
2. Removed from active `agents/` directory
3. Git history preserved via archive
4. Approximately 2026-07-01

### Q: Can I still reference the old agents?

**A:** Yes, even after Ship phase:
- For archived changes: old agents still available in archive/
- For learning: git history available (`git log --follow agents/altitude.agent.md`)
- If you need to revert: old agents can be restored from git

---

## Rollback Plan

If consolidation causes issues:

1. **Pre-Ship rollback (during W18-23):**
   ```bash
   git revert <consolidation-commit>
   # Restores old agents to working tree
   ```

2. **Post-Ship rollback:**
   ```bash
   git restore --source=HEAD~10 agents/altitude.agent.md agents/altitude-coordinator.agent.md
   # Recovers from archive
   ```

3. **Evidence:** All rollback decisions logged in change artifacts

---

## References

- **Change:** `.specs/changes/waves-18-23-implementation/`
- **PRD:** `.specs/changes/waves-18-23-implementation/PRD.md` (Requirement 1)
- **ADR:** `.specs/changes/waves-18-23-implementation/ADR.md` (Decision 1)
- **Lessons:** `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md`
- **Deprecated Files:** 
  - `agents/altitude.agent.md` (marked DEPRECATED)
  - `agents/altitude-coordinator.agent.md` (marked DEPRECATED)
- **Replacement:** `agents/altitude-maestro.agent.md`

---

## Status

✅ **COMPLETE** (Implemented in BLOCO 4, Task T-06)

Date: 2026-06-30  
Author: Altitude Coordinator (T-06 executor)  
Reviewed: altitude-validation (T-07)
