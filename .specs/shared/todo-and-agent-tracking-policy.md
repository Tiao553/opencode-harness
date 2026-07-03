# TODO and Agent Tracking Policy

**Version:** 1.0  
**Date:** 2026-06-30  
**Owner:** Altitude Coordinator  
**Status:** Active

---

## Purpose

Every phase and every bloco must maintain **structured TODO tracking** with **assigned agents visible** at all times.

This ensures:
- ✅ Clear ownership (who executes what?)
- ✅ Parallel execution visibility (which tasks can run in parallel?)
- ✅ Progress tracking (what's done, pending, blocked?)
- ✅ Gate validation (when to pause and validate?)
- ✅ Evidence collection (what gets recorded?)

---

## TODO Taxonomy

Every TODO entry follows this format:

```
BLOCO N (Phase: X) | T-YY | [Task Description] | Agent: [agent-name]
```

### Structure Breakdown

| Component | Meaning | Example |
|-----------|---------|---------|
| **BLOCO N** | Execution block (1, 2, 3, 4) | BLOCO 2 |
| **Phase: X** | Current phase (Execution, Validation, Ship) | Phase: Execution |
| **T-YY** | Task ID | T-02 |
| **Task Description** | What the task does | Enhance altitude-plan.agent.md |
| **Agent: name** | Which agent executes | Agent: altitude-plan |

---

## Gates Per Bloco

Every bloco follows this pattern:

```
BLOCO N:
  ├─ Pre-Execution (Gate 7: Pre-Viability)
  │  └─ "Validate context scope + dependencies"
  ├─ [T-YY | Agent: X] (Execute 1+ tasks)
  ├─ [T-ZZ | Agent: Y]
  ├─ Post-Execution (Gate 8: Post-Validation)
  │  └─ "Verify acceptance criteria"
  └─ Close (Gate 9: Memory Closure)
     └─ "Generate evidence + update state"
```

### Gate Status

| Gate | When | Action | Output |
|------|------|--------|--------|
| **Gate 7** | Before task execution | Validate scope + dependencies | PASS/BLOCK |
| **[Task Execution]** | During bloco | Execute T-XX via assigned agent | evidence |
| **Gate 8** | After task execution | Verify acceptance criteria | PASS/FAIL |
| **Gate 9** | After validation | Record state + evidence + approval for next | evidence/BLOCO-N.md |

---

## Agent Assignment Rules

### Primary Agents (Who executes what)

| Agent | Typical Tasks |
|-------|---|
| `altitude-maestro` | Coordinator logic, routing decisions |
| `altitude-intent` | Problem definition, scope clarification |
| `altitude-structure` | Surface mapping, impact analysis |
| `altitude-plan` | Task decomposition, requirements mapping |
| `altitude-execution` | Code/config edits, implementation |
| `altitude-memory` | State updates, recovery protocols |
| `altitude-validation` | Acceptance criteria verification, junta review |
| `altitude-report` | Shipping summaries, archival |

### Assignment Best Practices

1. **Task → Agent:** Each task maps to ONE primary agent
2. **Gate validation:** Same agent that executed the task should validate (unless Gate 8 is junta-based)
3. **Cross-Agent work:** If task spans multiple agents, primary agent is the "owner"
4. **Parallel execution:** Multiple tasks can have different agents in same BLOCO

---

## TODO Entry Format

### Standard Entry (Single Task)

```
BLOCO 2 | T-02 | Enhance altitude-plan.agent.md (context loading) | Agent: altitude-plan
```

**Status options:** `pending` | `in_progress` | `completed` | `blocked`  
**Priority:** `high` | `medium` | `low`

### Gate Entry

```
BLOCO 2 | Gate 7 (Pre-Viability) | Validate scope + dependencies for T-02/T-03/T-04
```

**Status:** `pending` → `in_progress` → `completed` (or `blocked`)

---

## Phase-Level TODOs

Beyond BLOCOs, track phases:

```
Phase: Validation | Multi-Junta Review | Altitude-validation runs 5-junta validation
Phase: Ship | Archive + Merge | Archive to .specs/archive/ + merge PRs
```

---

## Example: BLOCO 2 Tracking

```
┌─ BLOCO 2 (Phase: Execution)
│
├─ BLOCO 2 | Gate 7 (Pre-Viability) | Validate scope + dependencies
│  Status: in_progress → completed
│
├─ BLOCO 2 | T-02 | Enhance altitude-plan.agent.md | Agent: altitude-plan
│  Status: pending → in_progress → completed
│  Evidence: agents/altitude-plan.agent.md (updated +60-80 lines)
│
├─ BLOCO 2 | T-03 | Restructure altitude-execution.agent.md | Agent: altitude-execution
│  Status: pending → in_progress → completed
│  Evidence: agents/altitude-execution.agent.md (decision map moved to top)
│
├─ BLOCO 2 | T-04 | Update altitude-memory.agent.md | Agent: altitude-memory
│  Status: pending → in_progress → completed
│  Evidence: agents/altitude-memory.agent.md (lessons loading added)
│
├─ BLOCO 2 | Gate 8 (Post-Validation) | Verify acceptance criteria
│  Status: pending → in_progress → completed
│  Evidence: validation report (all 8 acceptance criteria pass)
│
└─ BLOCO 2 | Gate 9 (Memory Closure) | Generate evidence + state update
   Status: pending → in_progress → completed
   Evidence: evidence/BLOCO-2.md (242 lines) + state.md updated
```

---

## When to Use todowrite

### ✅ USE todowrite when:

- Starting a new BLOCO (create all TODO entries at start)
- Updating task status (in_progress, completed, blocked)
- Adding new tasks mid-execution
- Closing a BLOCO (all TODOs to completed)
- Starting a new phase (gate review, final validation)

### ❌ DO NOT use todowrite for:

- Temporary notes (use state.md instead)
- Sub-task tracking (use 02-decomposition.md instead)
- Evidence collection (use evidence/ folder instead)
- Design notes (use DESIGN.md, PRD.md, etc.)

---

## Evidence Naming Convention

Each BLOCO produces an evidence file:

```
evidence/BLOCO-N.md

BLOCO-1.md
BLOCO-2.md
BLOCO-3.md
BLOCO-4.md
```

Each file contains:
- Gate 7 validation results (pre-viability)
- Task execution results (what agent did)
- Gate 8 validation results (post-validation)
- Gate 9 closure (state updates + next approval)

---

## State Update Pattern (state.md)

When a BLOCO completes, update state.md:

```yaml
## Execution Blocklist

| Bloco | Tasks | Status | Start | End |
|-------|-------|--------|-------|-----|
| BLOCO 1 | T-01 | ✅ COMPLETE | 2026-06-30 | 2026-06-30 |
| BLOCO 2 | T-02, T-03, T-04 | 🔄 IN_PROGRESS | 2026-06-30 | — |
| BLOCO 3 | T-05 | ⏳ Pending | — | — |
| BLOCO 4 | T-06, T-07 | ⏳ Pending | — | — |
```

Also update `.specs/memory/active-state.md`:

```yaml
active_task: T-02 (IN_PROGRESS) → T-03 (NEXT)
current_altitude: Execution (BLOCO 2)
current_agent: altitude-plan
```

---

## Summary

| Element | Purpose | Tool | Output |
|---------|---------|------|--------|
| **TODO** | Track work progress | `todowrite` | Todo list |
| **Agent** | Show ownership | DESIGN.md | Allocation map |
| **Gate 7-9** | Validate quality | Manual + evidence | Evidence file |
| **State** | Track phase | state.md | Ledger |
| **Evidence** | Prove completion | evidence/BLOCO-N.md | Archive |

---

## References

- `.specs/shared/allocation-contract.md` — Allocation rules
- `.specs/changes/waves-18-23-implementation/DESIGN.md` — Task allocation map
- `.specs/changes/waves-18-23-implementation/state.md` — Active execution state
- `.specs/memory/active-state.md` — Current agent context

---

