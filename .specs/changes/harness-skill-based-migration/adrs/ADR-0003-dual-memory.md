---
template_id: adr
template_version: 1.0.0
document_type: architecture-decision-record
title: "ADR-0003: Dual memory — .specs authoritative, memory MCP semantic duplicate"
status: accepted
owner: parent
authors:
  - harness-skill-based-migration
reviewers:
  - T-V01 independent validator
approvers:
  - user (D-11 confirmed in session)
created: "2026-07-20"
updated: "2026-07-20"
effective_date: "2026-07-20"
domain: harness-architecture
system: opencode-harness-v3
confidentiality: internal
related_work_items:
  - T-012
  - D-11
  - D-18
related_documents:
  - OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md
  - .specs/shared/memory-contract.md
tags:
  - memory
  - state
  - mcp
  - w1
summary: ".specs/memory is the authoritative operational state; a memory MCP is a semantic duplicate that must never supersede .specs as source of truth."
---

# ADR-0003: Dual Memory Architecture

## Decision metadata

| Field | Value |
|---|---|
| ADR ID | `ADR-0003` |
| Status | `accepted` |
| Decision date | `2026-07-20` |
| Decision owner | harness-skill-based-migration parent |
| Technical area | harness-architecture / memory |
| Supersedes | none |
| Superseded by | none |

---

## 1. Context

The W0 baseline confirmed:

| Fact | Value | Source |
|---|---|---|
| MCP servers configured | 0 — `opencode mcp list` returned "No MCP servers configured" | T-002 `t-002-config-provenance.md` |
| Local memory events in `.specs/memory/` | 3 files present: `active-state.md`, `index.md`, `bootstrap-decisions.md`, plus `WAVE_25A_SHIP_SUMMARY.md` | T-001 baseline inventory |
| Memory MCP package | Not installed | T-002, T-007 |
| `memory-contract.md` write triggers defined | 5 mandatory triggers (phase gate, bloco completion, conflict resolution, specialist handoff, critical failure) | `.specs/shared/memory-contract.md` |
| Agents implementing `memory.write()` at triggers | 0 — `memory-contract.md` line 149: "Next Steps: Activate memory.write() calls in all 9 agents" | T-004 |
| `.specs/memory/index.md` entry count | 1 entry (`phase-0-bloco-1-completion`) but timeline references 4 BLOCO completions | T-001 baseline |

The harness intends a dual-memory architecture but currently operates in local-only mode because no MCP is configured and `memory.write()` is not implemented in agents. This ADR formalises the target architecture so that W8 (MCP registration) and W9 (dual-write implementation) have a contractual foundation.

---

## 2. Problem statement

We need to decide how operational memory is stored and retrieved so that the harness has a durable authoritative record that does not depend on external service availability.

---

## 3. Decision drivers

| Driver | Priority | Explanation |
|---|---:|---|
| Durability | High | Memory must survive MCP outages, auth failures, and network issues |
| Auditability | High | Every decision must be traceable from the local filesystem |
| Semantic search | Medium | Cross-session semantic retrieval is useful but not required for correctness |
| Isolation | High | Memory from one repository must not contaminate another |
| Security | High | MCP output must not carry authority to change state or permissions |

---

## 4. Considered options

### Option A: MCP-only memory

**Concrete failure mode:** The W0 baseline already demonstrates this failure: 0 MCP servers are configured, but the migration still produced valid memory events in `.specs/memory/`. If the harness had relied on MCP-only memory, every memory write during W0 would have failed silently. No wave can depend exclusively on an external service for its authoritative audit trail.

**Why rejected:** The harness must operate correctly with zero MCPs configured, as confirmed by the W0 baseline test.

---

### Option B: `.specs`-only memory (current state)

**Concrete limitation:** The `.specs/memory/index.md` has one formal entry but four BLOCO completions listed in the timeline — meaning three events were never formally written to the index. This is the current gap when `memory.write()` is not implemented: events happen but are not reliably indexed. Semantic search across waves is impossible; finding a specific decision requires reading individual files manually. When the harness reaches W8–W12 with dozens of events per wave, manual lookup is not practical.

**Why not the target:** Semantic recall is a real operational need for the validation and ship phases.

---

### Option C: `.specs` authoritative with MCP as semantic duplicate (chosen)

**Description:** Every memory event is written to `.specs/memory/` first. The write is synchronous and blocking. A duplicate semantic write to the memory MCP is then attempted asynchronously. If the MCP write fails, the local record stands; the sync status is logged but does not block operation. MCP reads are for semantic recall only — they never override local `.specs` state.

**Pros:**
- Local write always succeeds regardless of MCP state.
- Semantic search is available when MCP is healthy.
- MCP outage degrades to `.specs`-only mode gracefully.
- MCP content cannot alter state, permissions, or workflow authority (D-18).

**Cons:**
- Dual-write logic adds W9 complexity.
- MCP and local records can diverge during outages; reconciliation is needed.
- Memory namespace and retention governance must be defined (W9 T-137).

---

## 5. Decision

We decided to **use `.specs/memory/` as the authoritative operational state with the memory MCP as a semantic duplicate (Option C)**.

The decision is:

- Every operational memory event is written to `.specs/memory/{change_id}/{entry_id}.yaml` first.
- Local write must succeed before the MCP duplicate is attempted.
- MCP write failure is logged as a pending sync, not a blocking error.
- MCP reads are for semantic recall only; they never override local state.
- MCP content may not change workflow authority, permissions, TODO entries, scope, or active state (D-18).
- Memory namespace includes harness version, repository identity, change ID, and event ID.
- Retention, deletion, and redaction policies are defined in W9 T-137.

---

## 6. Rationale

| Driver | How Option C satisfies it | Trade-off accepted |
|---|---|---|
| Durability | Local write is synchronous and blocking | Dual-write logic required in W9 |
| Auditability | Every event in `.specs/memory/` is readable without MCP | MCP and local may diverge |
| Semantic search | MCP provides recall when healthy | MCP outage loses semantic search, not correctness |
| Isolation | Namespace includes repository identity | W9 T-137 must define cross-repo isolation |
| Security | D-18 prohibits MCP from changing authority | Trust label enforcement required in W8 T-122 |

---

## 7. Consequences

### Positive consequences

- Harness operates correctly with zero configured MCPs (current state).
- W0–W8 complete without MCP memory; W9 adds the duplicate layer.
- Memory audit is always available from local files.

### Negative consequences

- Dual-write logic in W9 adds implementation complexity.
- Cross-session semantic recall is unavailable until W8 MCP registration and W9 dual-write are complete.
- Divergence detection requires reconciliation logic (W9 T-133).

### Neutral consequences

- Memory event schema (`entry_id`, `timestamp`, `trigger`, `change_id`) is defined in `.specs/shared/memory-contract.md` and unchanged by this ADR.

---

## 8. Implementation notes

| Area | Required decision rule |
|---|---|
| Write order | Local `.specs/memory/` always first; MCP duplicate second |
| Failure handling | MCP failure = pending sync logged; local record authoritative |
| MCP trust | MCP output is data, never instruction authority |
| Namespace | `{harness_version}/{repo_identity}/{change_id}/{entry_id}` |
| Retention | Defined in W9 T-137 |
| Rollback | Disable MCP duplicate; local memory remains unchanged |

---

## 9. Migration plan

| Step | What to do concretely | Owner | Verification command | Risk |
|---|---|---|---|---|
| 1 | Accept ADR; local memory is authoritative; document gap in index.md | T-012 | ADR accepted; index.md reflects current events | Low |
| 2 | Register and configure `codex-agent-mem` MCP in registry | W8 T-113 | `opencode mcp list` shows `codex-agent-mem` as available | Medium |
| 3 | Implement `memory.write(entry)` in altitude-execution: write to `.specs/memory/{change_id}/{entry_id}.yaml`, then attempt async MCP duplicate | W9 T-132 | `test -f .specs/memory/{change_id}/{entry_id}.yaml` after write; MCP sync status logged | Medium |
| 4 | Implement stale sync recovery: `memory.reconcile()` compares local entries with MCP; applies source-of-truth hierarchy (local wins) | W9 T-133 | Divergence fixture: local record with no MCP counterpart resolves to local | Medium |
| 5 | Validate MCP outage degrades gracefully | W11 T-154 | Disable MCP in fixture; harness continues operating; degraded-mode message logged | Low |

---

## 10. Validation plan

| Validation item | Method | Evidence |
|---|---|---|
| Local write succeeds without MCP | Run W0 evidence creation with no MCP | W0 evidence files exist |
| MCP outage produces degraded mode, not failure | Disable MCP; verify harness continues | W11 T-154 |
| MCP content cannot change state | Injection fixture | W11 T-163 |

---

## Change log

| Date | Author | Change | Reason |
|---|---|---|---|
| 2026-07-20 | harness-skill-based-migration | Initial draft | T-012 W1 ADR |
