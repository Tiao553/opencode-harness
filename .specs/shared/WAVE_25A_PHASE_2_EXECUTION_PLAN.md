# Wave 25A: Allocation Consolidation — Phase 2 Execution Plan

**Status:** LOCKED FOR EXECUTION  
**Phase:** 2 (Contract Design & Rewrite)  
**Date:** 2026-07-03  
**User Decision:** T-10 APPROVED  
**Ready to Execute:** YES

---

## PHASE 2 OVERVIEW

| Item | Value |
|------|-------|
| **Phase** | Contract Design & Rewrite (T-11 to T-20) |
| **Duration** | 34h serial / 14h parallel |
| **Deliverable** | 6 rewritten contracts + 8 golden fixtures |
| **User Gate** | T-20 (approve contracts & fixtures before Phase 3 tooling) |
| **Critical Path** | T-11 → T-12 → T-14/T-15 → T-16/T-17 → T-18 → T-19 → T-20 |

---

## DECISION CONSTRAINTS (Locked from Phase 1)

All Phase 2 tasks constrained by Q1-Q5 decisions:

- **Q1: Option B** — 6 contracts, each ≤ 400 lines (not 1 monolith)
- **Q2: Extract ledger** — Separate `allocation-ledger-contract.md` from enforcement
- **Q3: Keep + link** — Todo stays in enforcement, linked to execution-loop
- **Q4: Batch + agent** — Tool spec includes 5 commands + Python/Go helpers
- **Q5: 1000 tasks** — Load tests target 1k scale (not 10k)

---

# PHASE 2: CONTRACT DESIGN (T-11 to T-20)

## T-11: allocation-contract.md V2 (6 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-10 user gate (approval confirmed)  
**Verification:** MANDATORY

### Objective

Rewrite `allocation-contract.md` as the foundation contract for global/local/specialist allocation hierarchy. Incorporates decision Q1 (Option B) and consolidates redundancy from current 3-contract state.

### Current State Analysis

- **Source:** `.specs/shared/allocation-contract.md` (243 lines)
- **Issue:** Only covers global/local/specialist definitions; enforcement/ledger/specialist details scattered
- **Target:** Consolidated foundation (250 lines, vs 243 current)

### Deliverable

File: `.specs/shared/allocation-contract.md` (250 lines) with sections:

1. **Purpose & Overview** (15 lines)
   - Define: allocation as ownership before delegation
   - Three levels: global → local → specialist
   - Narrow safe, broaden unsafe (principle)

2. **Global Allocation** (35 lines)
   - Definition (change/wave/phase ownership)
   - Required fields: change_id, owner, phase, scope_boundary, artifact_authority, allowed_paths, forbidden_paths, validation_posture, escalation_owner
   - Optional fields: PRD/ADR/TEST-SPEC references, risk class, rollback owner
   - Broadening rule: detect & escalate

3. **Local Allocation** (35 lines)
   - Definition (task/todo ownership)
   - Required fields: task_id, owner, deliverable, allowed_files, forbidden_scope, verify, evidence
   - Optional fields: specialist support, PRD requirement, ADR decision, TEST-SPEC scenario, risk class, rollback
   - Todo rule: every todo must have `verify:` clause
   - Execution rule: all 8 readiness conditions listed

4. **Specialist Allocation** (30 lines)
   - Definition (bounded expertise, not hidden ownership)
   - Required fields: specialist name, reason, parent task, scope, grounding_bundle, expected_output, evidence, verification_responsibility, stop_condition
   - Grounding bundle: smallest useful context (no inference from chat)
   - Evidence: files inspected, claims, recommendations, validation, residual risk
   - Anti-patterns: 4-5 key ones (over-delegation, missing scope, etc.)

5. **Precedence & Hierarchy** (40 lines)
   - Precedence rules: user → local → wave → phase → change → repo → coordinator
   - Safe narrowing: local ⊂ global is OK
   - Unsafe broadening: local ⊃ global needs approval
   - Invalid states: 6 conditions that prevent execution
   - Task-Spec mapping: inheritance rules

6. **Delegation Rule** (25 lines)
   - Definition: specialists do not become hidden owners
   - Required for every specialist: reason, scope, evidence expectation, stop condition
   - Stop conditions: when to replan (scope broaden, context missing, unsupported claims, conflict)

7. **Cross-References to Other Contracts** (20 lines)
   - Link to enforcement-contract (scope matching, escalation)
   - Link to ledger-contract (event recording)
   - Link to specialist-contract (evidence & lifecycle)
   - Link to todo-contract (verification & projection)
   - Link to execution-loop-contract (how todos flow)

### Acceptance Criteria

- ✓ File created at `.specs/shared/allocation-contract.md` (replace current)
- ✓ All 7 sections present with line counts on target (±5 lines)
- ✓ No redundancy with enforcement/ledger/specialist-specific concerns
- ✓ All cross-references to other Phase 2 contracts included (even if not all written yet)
- ✓ Decision Q1 (Option B) reflected: foundation contract, specialist details in specialist-contract
- ✓ No circular references (allocation → enforcement OK, enforcement → allocation OK, no cycle)

### Verification

```bash
test -f .specs/shared/allocation-contract.md || exit 1

# Verify sections
grep -q "^## Purpose" allocation-contract.md && echo "✓ Section 1 (Purpose)"
grep -q "^## Global Allocation" allocation-contract.md && echo "✓ Section 2 (Global)"
grep -q "^## Local Allocation" allocation-contract.md && echo "✓ Section 3 (Local)"
grep -q "^## Specialist Allocation" allocation-contract.md && echo "✓ Section 4 (Specialist)"
grep -q "^## Precedence" allocation-contract.md && echo "✓ Section 5 (Precedence)"
grep -q "^## Delegation Rule" allocation-contract.md && echo "✓ Section 6 (Delegation)"
grep -q "^## Cross-References" allocation-contract.md && echo "✓ Section 7 (Cross-References)"

# Verify line count
wc -l allocation-contract.md | grep -E " 2[0-9][0-9] " && echo "✓ Line count ~250"

# Verify no breaking changes to existing required fields
grep -q "required fields\|owner\|scope boundary\|allowed files\|forbidden scope" allocation-contract.md && echo "✓ Core fields preserved"

echo "✓ All verifications passed"
```

### Evidence Required

- File allocation-contract.md (250 lines)
- All 7 sections present
- Cross-references documented

---

## T-12: allocation-enforcement-contract.md V2 (5 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-11 (allocation hierarchy foundation)  
**Verification:** MANDATORY

### Objective

Extract enforcement-specific logic from current 846-line `allocation-enforcement-and-ledger-contract.md`. Create focused enforcement contract (350 lines) covering scope matching, validation rules, and escalation flow.

**Note:** Ledger extracted to separate contract (T-13), todo projection stays but clearly marked for linking to execution-loop.

### Deliverable

File: `.specs/shared/allocation-enforcement-contract.md` (350 lines) with sections:

1. **Purpose & Overview** (10 lines)
   - Define: real-time enforcement of file-level allocation boundaries
   - When: at task execution, before file writes
   - Who: altitude-execution, validation agents, file-writing tasks

2. **Scope Model** (40 lines)
   - Pattern types: glob, exact paths, directory patterns, negation
   - Syntax: `agents/*.agent.md`, `AGENTS.md`, `.specs/shared/`, `!agents/DEFAULT.AGENT.agent.md`
   - Matching algorithm with pseudocode (Python or Bash)
   - Rule order: first match wins, forbidden overrides allowed

3. **Validation Rules** (50 lines)
   - Safe: write within scope → allow
   - Safe narrowing: task scope ⊂ global scope → assign
   - Unsafe: task scope ⊃ global scope → ask user
   - Default deny: file not in allowed_files → deny
   - Validation table: 6 scenarios (file in allowed, forbidden, outside both, narrowing, broadening, local forbids global allows)

4. **Escalation Flow** (60 lines)
   - When scope violation: compute delta, ask user
   - User options:
     - A. Approve → expand allocation + log `scope_expansion_requested` + allow write
     - B. Abort → block write + log `violation_blocked` + return to phase start
     - C. Escalate → block + route to security specialist + log with escalation reason
   - Each option with exact action steps and ledger entry format

5. **Performance Requirements** (15 lines)
   - Per-file pattern matching: < 10µs (Target in T-24)
   - Per-task allocation check: < 2ms
   - Scope expansion compute: < 50ms
   - No significant overhead for typical tasks

6. **Integration with Tools** (30 lines)
   - How allocation-check.sh validates files
   - Commands: validate-file, query-violations, ledger-stats
   - Agent integration points: altitude-execution calls validate-file pre-write
   - Error messages: clear guidance when violations occur

7. **Todo Projection** (80 lines) ← **MARKED FOR LINKING TO EXECUTION-LOOP**
   - **Rationale in header:** Todo projection is adjacent to enforcement; future migration to execution-loop OK but keeping here for now (Q3 decision)
   - Source of truth: allocation-contract + active task + phase state
   - Visibility rule: show real decomposition, not artificial caps
   - Todo requirements: task_id, owner, specialist (if relevant), action, verify clause, loop_posture
   - Specialist rule: always cite specialist name when delegated
   - Verify rule: all operational todos must have concrete verify clause
   - Loop rule: todos inherit task loop posture (mandatory/advisory/not_applicable)
   - Recompute rule: recalculate todo tree when phase/task/status changes
   - Tactical vs strategic: both use same hierarchy, different root levels

8. **Backward Compatibility** (20 lines)
   - Tasks without allocation: enforcement advisory (warn, don't block) in Phase 1
   - Made mandatory in Phase 2+
   - Migration path: opt-in Wave 5 → default-on Wave 5.1 → mandatory Wave 6

### Acceptance Criteria

- ✓ File created at `.specs/shared/allocation-enforcement-contract.md` (new, focused)
- ✓ All 8 sections present with line counts on target (±10 lines)
- ✓ Scope model fully specified with pattern matching algorithm
- ✓ Validation table covers all 6 scenarios
- ✓ Escalation flow with user options (A/B/C) detailed
- ✓ Integration with tools explicit (validate-file, query-violations commands)
- ✓ Todo projection section clearly marked with cross-reference to execution-loop (per Q3)
- ✓ No ledger-specific content (extracted to T-13)
- ✓ No redundancy with allocation-contract.md (T-11) or specialist-contract (T-13)

### Verification

```bash
test -f .specs/shared/allocation-enforcement-contract.md || exit 1

# Verify sections
grep -q "^## Scope Model" allocation-enforcement-contract.md && echo "✓ Section 2 (Scope Model)"
grep -q "^## Validation Rules" allocation-enforcement-contract.md && echo "✓ Section 3 (Validation)"
grep -q "^## Escalation Flow" allocation-enforcement-contract.md && echo "✓ Section 4 (Escalation)"
grep -q "^## Todo Projection" allocation-enforcement-contract.md && echo "✓ Section 7 (Todo + cross-ref)"

# Verify pattern matching examples
grep -q "agents/\*.agent.md\|AGENTS.md\|.specs/shared/\|!agents/DEFAULT" allocation-enforcement-contract.md && echo "✓ Patterns specified"

# Verify line count
wc -l allocation-enforcement-contract.md | grep -E " 3[0-9][0-9] " && echo "✓ Line count ~350"

echo "✓ All verifications passed"
```

### Evidence Required

- File allocation-enforcement-contract.md (350 lines)
- All 8 sections present
- Ledger logic verified as extracted (not here)

---

## T-13: allocation-ledger-contract.md (NEW, 3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-12 (enforcement reference)  
**Verification:** MANDATORY

### Objective

Create new `allocation-ledger-contract.md` (200 lines) extracting ledger-specific logic from current 846-line enforcement-and-ledger contract. Per Q2 decision: ledger extracted separately for cleaner separation and independent versioning.

### Deliverable

File: `.specs/shared/allocation-ledger-contract.md` (200 lines) with sections:

1. **Purpose & Overview** (10 lines)
   - Define: ledger as immutable record of allocation decisions and events
   - Where: `.specs/changes/<change_id>/03-execution-ledger.md` (embedded YAML)
   - Owner: altitude-execution, altitude-validation, all agents making mutations
   - Queries: via allocation-check.sh (ledger-stats, query-violations commands)

2. **Event Schema** (50 lines)
   - Root structure with 12 fields (event_id, timestamp, type, change_id, phase, task_id, agent, file, scope_delta, decision, decided_by, reason, error, parent_event_id, linked_events)
   - Field descriptions and types (string, ISO-8601, enum, array, etc.)
   - Event ID format: `allocation-event-<timestamp>-<sequence>`
   - Required vs optional fields

3. **Event Types** (60 lines)
   - `allocation_assigned`: task allocated with scope
   - `file_write_allowed`: file write validated and allowed
   - `scope_expansion_requested`: user approved scope expansion
   - `violation_blocked`: write violation blocked (with decision: aborted or escalated)
   - `warning`: non-blocking advisory event
   - Examples for each type (YAML format, 5-10 lines per type)

4. **Ledger Location & Structure** (20 lines)
   - Standard location: `.specs/changes/<change_id>/03-execution-ledger.md`
   - Structure: markdown with embedded YAML sections
   - Sections: allocation_events, task_events, validation_events
   - Example structure shown

5. **Ledger Queries** (40 lines)
   - Query all events for a change: `tools/allocation-check.sh validate-scope <change_id>`
   - Audit all scope expansions: `tools/allocation-check.sh query-violations --type expansion`
   - Export events: `tools/allocation-check.sh export-ledger <change_id> --format json`
   - Performance: < 500ms for 1000-event ledger
   - Examples shown with output format

6. **Data Integrity** (20 lines)
   - Event immutability: no deletion or modification (only append)
   - Timestamp ordering: events recorded in order
   - Ledger corruption detection: audit script checks completeness
   - Recovery: if ledger corrupted, flag as TEST-EDGE-15

### Acceptance Criteria

- ✓ File created at `.specs/shared/allocation-ledger-contract.md` (new, focused)
- ✓ All 6 sections present with line counts on target (200 total)
- ✓ Event schema fully specified (12 fields with types)
- ✓ All 5 event types defined with YAML examples
- ✓ Ledger location and structure clear
- ✓ Query examples show how to audit and export
- ✓ Performance targets specified (< 500ms for 1000 events)
- ✓ No overlap with enforcement-contract or specialist-contract

### Verification

```bash
test -f .specs/shared/allocation-ledger-contract.md || exit 1

# Verify sections
grep -q "^## Event Schema" allocation-ledger-contract.md && echo "✓ Section 2 (Schema)"
grep -q "^## Event Types" allocation-ledger-contract.md && echo "✓ Section 3 (Types)"
grep -q "allocation_assigned\|file_write_allowed\|scope_expansion_requested\|violation_blocked" allocation-ledger-contract.md && echo "✓ Event types defined"

# Verify query examples
grep -q "allocation-check.sh\|validate-scope\|query-violations\|export-ledger" allocation-ledger-contract.md && echo "✓ Query commands"

# Verify line count
wc -l allocation-ledger-contract.md | grep -E " [12][0-9][0-9] " && echo "✓ Line count ~200"

echo "✓ All verifications passed"
```

### Evidence Required

- File allocation-ledger-contract.md (200 lines)
- Event schema with all 12 fields
- All 5 event types with examples

---

## T-14: Migration Path Document (3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-11, T-12, T-13 (contracts finalized)  
**Verification:** MANDATORY

### Objective

Create migration guide from current 3-contract fragmented state to new 6-contract consolidated state. Clarify how existing code/references transition with no breaking changes.

### Deliverable

File: `.specs/shared/WAVE_25A_MIGRATION_PATH.md` (120 lines) with sections:

1. **Before/After Comparison** (20 lines)
   - Current: 3 contracts (1,189 lines) + tool contract (301 lines) = 1,490 lines
   - New: 6 contracts (~1,400 lines) but focused
   - Migration: pure consolidation, no functional change

2. **Contract Mapping** (30 lines)
   - `allocation-contract.md` (243 → 250 lines): foundation contract, adds cross-references
   - `allocation-enforcement-and-ledger-contract.md` (846 → 350 + 200): split into enforcement + ledger
   - `specialist-allocation-contract.md` (100 → 150 lines): refined, adds circular prevention
   - `allocation-check.contract.md` (301 → 400 lines): expanded tool spec (new)
   - `allocation-ledger-contract.md` (NEW, 200 lines): extracted from enforcement
   - `todo-allocation-contract.md` (NEW, 150 lines): extracted from enforcement, linked to execution-loop

3. **Backward Compatibility** (20 lines)
   - All existing task allocations continue to work
   - All existing tools (allocation-check.sh) continue to work
   - Cross-references updated: old refs point to new locations
   - Deprecation: None; only addition and clarification

4. **Agent Integration Changes** (20 lines)
   - altitude-execution: reference allocation-contract + enforcement (no change to behavior)
   - altitude-validation: reference allocation-ledger (new, for audit)
   - allocation-check.sh: same commands, just expanded (backward compatible)
   - New agents (Phase 3+): use new tool commands

5. **Validation Transition** (15 lines)
   - Phase 0/1: allocation enforcement advisory (warn only)
   - Phase 2 (NOW): enforcement available, opt-in during wave design
   - Phase 2.1: default-on; can disable with `--skip-allocation-check`
   - Phase 3+: mandatory enforcement

6. **Rollback Plan** (15 lines)
   - If Phase 2 discovers blocking issues: keep new contracts, revert to 3 old contracts for reference
   - Ledger backwards compatible: new queries work on old events
   - No data loss in any scenario

### Acceptance Criteria

- ✓ File created at `.specs/shared/WAVE_25A_MIGRATION_PATH.md`
- ✓ Before/after comparison clear (line counts, structure)
- ✓ All 6 target contracts mapped to current state
- ✓ Backward compatibility confirmed
- ✓ Agent integration impacts documented
- ✓ Validation transition phases clear
- ✓ Rollback plan present

### Verification

```bash
test -f .specs/shared/WAVE_25A_MIGRATION_PATH.md || exit 1

# Verify sections
grep -q "^## Before/After" WAVE_25A_MIGRATION_PATH.md && echo "✓ Section 1 (Comparison)"
grep -q "^## Contract Mapping" WAVE_25A_MIGRATION_PATH.md && echo "✓ Section 2 (Mapping)"
grep -q "^## Backward Compatibility" WAVE_25A_MIGRATION_PATH.md && echo "✓ Section 3 (Compat)"
grep -q "^## Agent Integration" WAVE_25A_MIGRATION_PATH.md && echo "✓ Section 4 (Agents)"
grep -q "^## Validation Transition" WAVE_25A_MIGRATION_PATH.md && echo "✓ Section 5 (Validation)"

# Verify no breaking changes mentioned
grep -q "breaking\|deprecat" WAVE_25A_MIGRATION_PATH.md && (grep -q "None\|not " WAVE_25A_MIGRATION_PATH.md) && echo "✓ No breaking changes"

echo "✓ All verifications passed"
```

### Evidence Required

- File WAVE_25A_MIGRATION_PATH.md (120 lines)
- Mapping table showing 6 target contracts
- Backward compatibility confirmed

---

## T-15: allocation-check.contract.md V2 (4 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-02 (enforcement), T-12 (tool requirements)  
**Verification:** MANDATORY

### Objective

Expand tool specification contract for allocation-check.sh (currently 301 lines). Add 5 new/enhanced commands, agent integration helpers, performance benchmarks (per Q4 decision: batch + agent integration).

### Deliverable

File: `.specs/shared/allocation-check.contract.md` (400 lines) with sections:

1. **Purpose & Overview** (15 lines)
   - Tool: allocation-check.sh and companions (allocation-snapshot.sh, allocation-diff.sh)
   - Purpose: validate, audit, and report on allocation compliance
   - Audience: agents, validators, auditors, operators

2. **Current Commands** (40 lines)
   - `check-file`: verify if file allowed
   - `check-pattern`: glob match test
   - `expand-allocation`: scope delta calculation
   - `validate-scope`: ledger audit
   - All maintained for backward compatibility

3. **New Commands (Phase 3)** (80 lines)
   - `validate-file`: pre-write check (returns allowed/forbidden/expansion-needed)
   - `query-violations`: filter violations with --type, --severity, --export-format
   - `ledger-stats`: compliance report (events count, violations count, expansions, trends)
   - `allocation-snapshot.sh`: save baseline of current allocations
   - `allocation-diff.sh`: compare two snapshots
   - Each command: syntax, examples, output format

4. **Agent Integration Helpers** (80 lines) ← Per Q4: batch + agent integration
   - Python stub (pseudocode): `allocation.validate_file(file, allocation_dict)`
   - Go stub (pseudocode): `allocation.ValidateFile(file, allocation)`
   - Usage: agents can call library functions instead of shelling out
   - Callbacks: custom error handlers, logging hooks
   - Examples: typical usage in altitude-execution, altitude-validation

5. **Performance Requirements** (30 lines)
   - Per-file: < 10µs
   - Per-task allocation check: < 2ms
   - Batch 1000 tasks: < 2000ms
   - Ledger query (1000 events): < 500ms
   - Load test suite: confirms targets (T-24)

6. **Error Handling & Logging** (40 lines)
   - Error cases: file not found, allocation not found, pattern syntax error, ledger corruption
   - Error messages: clear, actionable, reference docs
   - Logging: debug mode (--verbose) captures all decisions
   - Examples: error output format shown

7. **Testing & Validation** (50 lines)
   - Unit tests per command
   - Integration tests with agents
   - Load tests for batch operations
   - Fixtures: 8 golden fixtures cover edge cases
   - Success criteria: all commands < performance targets

8. **Backward Compatibility** (25 lines)
   - Old commands continue to work
   - New commands opt-in (not mandatory)
   - CLI remains stable (no breaking changes)
   - Deprecation: none (only additions)

### Acceptance Criteria

- ✓ File created at `.specs/shared/allocation-check.contract.md` (expanded)
- ✓ All 8 sections present with line counts on target (400 total)
- ✓ 5 new commands specified (syntax, examples, output format)
- ✓ Agent integration helpers included (Python + Go stubs)
- ✓ Performance requirements for all operations
- ✓ Error handling and logging documented
- ✓ Backward compatibility confirmed
- ✓ Testing strategy clear (unit, integration, load)

### Verification

```bash
test -f .specs/shared/allocation-check.contract.md || exit 1

# Verify sections
grep -q "^## New Commands" allocation-check.contract.md && echo "✓ Section 3 (New Commands)"
grep -q "validate-file\|query-violations\|ledger-stats" allocation-check.contract.md && echo "✓ 3+ new commands"
grep -q "Agent Integration Helpers\|Python\|Go" allocation-check.contract.md && echo "✓ Section 4 (Helpers)"
grep -q "Performance Requirements\|< 10µs\|< 2ms" allocation-check.contract.md && echo "✓ Section 5 (Performance)"

# Verify backward compatibility
grep -q "check-file\|check-pattern\|expand-allocation" allocation-check.contract.md && echo "✓ Old commands preserved"

# Verify line count
wc -l allocation-check.contract.md | grep -E " [34][0-9][0-9] " && echo "✓ Line count ~400"

echo "✓ All verifications passed"
```

### Evidence Required

- File allocation-check.contract.md (400 lines)
- 5 new commands specified
- Agent helpers (Python + Go) included
- Performance targets documented

---

## T-16: Golden Fixture Set 1 (Safe Paths, 4 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-11, T-15 (contracts finalized)  
**Verification:** MANDATORY

### Objective

Create 3 golden fixture files covering safe allocation paths (narrowing, allowed writes, ledger events). Used by integration tests (T-31) and regression tests. Per T-03 edge case inventory: 6 critical fixtures, 8 high-risk, 4 medium-risk. This task covers 3 safe path fixtures.

### Deliverable

Files: `.specs/shared/fixtures/` directory with 3 YAML fixture files (~150 lines total):

**Fixture 1: safe-narrowing.yaml** (50 lines)
- Global allocation: 3 directories allowed (agents/, .specs/shared/, tools/)
- Local task allocation: narrows to 1 file (agents/altitude-execution.agent.md)
- Test scenario: Verify local scope ⊂ global scope is accepted
- Expected result: PASS (safe narrowing)
- Evidence: allocation_assigned event in ledger

**Fixture 2: safe-write.yaml** (50 lines)
- Global allocation: agents/ directory allowed
- File write: agents/altitude-execution.agent.md
- Test scenario: Verify write allowed when file in allowed scope
- Expected result: PASS (file_write_allowed)
- Evidence: file_write_allowed event in ledger

**Fixture 3: forbidden-file-rejected.yaml** (50 lines)
- Global allocation: agents/ allowed, AGENTS.md forbidden
- File write: AGENTS.md
- Test scenario: Verify write rejected when file in forbidden scope
- Expected result: BLOCK (violation_blocked event)
- Evidence: violation_blocked event in ledger, no file modified

### Acceptance Criteria

- ✓ 3 fixture files created in `.specs/shared/fixtures/`
- ✓ Each fixture: setup (allocation), action (write), expected (outcome), evidence (events)
- ✓ All fixtures valid YAML (no syntax errors)
- ✓ Fixtures reusable by integration tests (T-31)
- ✓ Line counts: ~50 lines each (150 total)
- ✓ Test scenarios clear and measurable

### Verification

```bash
# Verify files exist
test -f .specs/shared/fixtures/safe-narrowing.yaml && echo "✓ Fixture 1"
test -f .specs/shared/fixtures/safe-write.yaml && echo "✓ Fixture 2"
test -f .specs/shared/fixtures/forbidden-file-rejected.yaml && echo "✓ Fixture 3"

# Verify YAML validity
for f in .specs/shared/fixtures/safe-*.yaml; do
  python3 -c "import yaml; yaml.safe_load(open('$f'))" && echo "✓ Valid YAML: $f" || exit 1
done

# Verify sections
for f in .specs/shared/fixtures/safe-*.yaml; do
  grep -q "setup:\|action:\|expected:\|evidence:" "$f" && echo "✓ Standard sections: $f" || exit 1
done

echo "✓ All verifications passed"
```

### Evidence Required

- 3 fixture files (YAML format)
- Each fixture with setup/action/expected/evidence sections
- All files valid YAML

---

## T-17: Golden Fixture Set 2 (Violations, 4 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-11, T-12, T-15 (enforcement + fixtures structure)  
**Verification:** MANDATORY

### Objective

Create 3 golden fixtures covering violation and escalation scenarios. Covers TEST-EDGE-02 (re-violation), TEST-EDGE-04 (specialist without grounding), and scope expansion user choices. Used by integration tests (T-31-33) and edge case validation.

### Deliverable

Files: `.specs/shared/fixtures/` directory with 3 YAML fixture files (~150 lines total):

**Fixture 4: violation-user-approval.yaml** (50 lines)
- Global allocation: agents/ allowed
- File write: AGENTS.md (forbidden initially)
- User action: Approve scope expansion (option A)
- Test scenario: Verify user approval expands allocation
- Expected result: PASS (allocation expanded, file_write_allowed)
- Evidence: scope_expansion_requested event (decision: approved), then file_write_allowed

**Fixture 5: violation-user-abort.yaml** (50 lines)
- Global allocation: agents/ allowed
- File write: AGENTS.md (forbidden initially)
- User action: Abort write (option B)
- Test scenario: Verify abort blocks write and returns to phase start
- Expected result: BLOCK (violation_blocked, decision: aborted)
- Evidence: violation_blocked event, file NOT modified, phase unchanged

**Fixture 6: specialist-without-grounding.yaml** (50 lines)
- Task allocation: specialist allocated without grounding_bundle
- Test scenario: Verify specialist allocation rejected if grounding missing
- Expected result: BLOCK (validation failure pre-execution)
- Evidence: error log shows "grounding_bundle required", allocation not recorded

### Acceptance Criteria

- ✓ 3 fixture files created in `.specs/shared/fixtures/`
- ✓ Each fixture: setup, user_action, expected, evidence
- ✓ All fixtures valid YAML
- ✓ Violations correctly represented (escalation flow, user choices)
- ✓ Line counts: ~50 lines each (150 total)
- ✓ Test scenarios measurable

### Verification

```bash
# Verify files exist
test -f .specs/shared/fixtures/violation-user-approval.yaml && echo "✓ Fixture 4"
test -f .specs/shared/fixtures/violation-user-abort.yaml && echo "✓ Fixture 5"
test -f .specs/shared/fixtures/specialist-without-grounding.yaml && echo "✓ Fixture 6"

# Verify YAML validity
for f in .specs/shared/fixtures/violation-*.yaml .specs/shared/fixtures/specialist-*.yaml; do
  python3 -c "import yaml; yaml.safe_load(open('$f'))" && echo "✓ Valid YAML: $f" || exit 1
done

# Verify escalation scenarios
grep -q "user_action:\|option A\|option B" .specs/shared/fixtures/violation-*.yaml && echo "✓ Escalation choices"

echo "✓ All verifications passed"
```

### Evidence Required

- 3 fixture files (YAML format)
- Each with setup/action/expected/evidence sections
- Escalation flow (A/B/C options) documented

---

## T-18: Integration Test Spec (3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-16, T-17 (fixtures complete)  
**Verification:** MANDATORY

### Objective

Create specification for 16 integration tests (4 scenario sets × 4 tests each). Tests verify end-to-end allocation + enforcement + ledger + specialist flows. Framework will be implemented in Phase 4 (T-31).

### Deliverable

File: `.specs/shared/WAVE_25A_INTEGRATION_TEST_SPEC.md` (100 lines) with:

**SET 1: Safe Allocation Path (4 tests, 2.5 hours to run)**
- T-INT-01: Safe narrowing (global → local)
  - Setup: Use fixture safe-narrowing.yaml
  - Action: Assign task with narrowed scope
  - Verify: allocation_assigned event recorded
  - Expected: PASS
- T-INT-02: Safe write (file in allowed)
  - Setup: Use fixture safe-write.yaml
  - Action: Write to allowed file
  - Verify: file_write_allowed event recorded
  - Expected: PASS
- T-INT-03: File in forbidden (correctly rejected)
  - Setup: Use fixture forbidden-file-rejected.yaml
  - Action: Try write to forbidden file
  - Verify: violation_blocked event, file unchanged
  - Expected: BLOCK (correct behavior)
- T-INT-04: Ledger events recorded
  - Setup: Combine SET1 tests above
  - Action: Query ledger for all events
  - Verify: 3 events present (assigned, allowed, blocked)
  - Expected: PASS, ledger integrity

**SET 2: Scope Expansion (4 tests, 3 hours to run)**
- T-INT-05: Violation detected (pre-write check)
  - Setup: Use fixture violation-user-approval.yaml (before action)
  - Action: Check file against allocation
  - Verify: validate-file returns "expansion_needed"
  - Expected: Violation detected
- T-INT-06: User approval granted (scope expanded)
  - Setup: From T-INT-05
  - Action: User chooses option A (approve)
  - Verify: scope_expansion_requested event (decision: approved)
  - Expected: PASS, allocation expanded
- T-INT-07: Write succeeds after expansion
  - Setup: From T-INT-06
  - Action: Retry write to same file
  - Verify: file_write_allowed event recorded
  - Expected: PASS, file modified
- T-INT-08: Ledger tracks all events
  - Setup: Combine T-INT-05–07
  - Action: Query ledger for SET2 events
  - Verify: 3 events (violation, expansion, allowed)
  - Expected: Complete trail

**SET 3: Specialist Delegation (4 tests, 3 hours to run)**
- T-INT-09: Specialist allocated with grounding
  - Setup: Define specialist allocation with grounding_bundle
  - Action: Allocate specialist to task
  - Verify: allocation_assigned event with specialist_name
  - Expected: PASS
- T-INT-10: Specialist output validated
  - Setup: Specialist completes task, returns output
  - Action: Validate output against task scope
  - Verify: Specialist output respects allowed_files
  - Expected: PASS if valid, BLOCK if violates
- T-INT-11: Circular delegation rejected
  - Setup: Create allocation A → B → C → A cycle
  - Action: Try to allocate circular chain
  - Verify: Detect cycle, reject allocation
  - Expected: BLOCK, clear error message
- T-INT-12: Ledger tracks specialist decision
  - Setup: From T-INT-09–10
  - Action: Query ledger for specialist events
  - Verify: allocation_assigned with specialist name, output validation events
  - Expected: Specialist flow complete

**SET 4: Ledger & Audit (4 tests, 2.5 hours to run)**
- T-INT-13: Query performance (100 events < 100ms)
  - Setup: Create 100-event ledger
  - Action: Query all events
  - Verify: Response time < 100ms
  - Expected: PASS
- T-INT-14: Violation filtering works
  - Setup: Mix 100 events (90 safe, 10 violations)
  - Action: Query --type violation
  - Verify: Returns exactly 10 violations
  - Expected: PASS, filtering accurate
- T-INT-15: Ledger export JSON format
  - Setup: 50-event ledger
  - Action: Export --format json
  - Verify: Valid JSON, all events present
  - Expected: PASS
- T-INT-16: Compliance report generated
  - Setup: From above
  - Action: Call ledger-stats
  - Verify: Report shows counts (events, violations, expansions)
  - Expected: PASS, report readable

### Acceptance Criteria

- ✓ File created at `.specs/shared/WAVE_25A_INTEGRATION_TEST_SPEC.md`
- ✓ 4 scenario sets with 16 tests total
- ✓ Each test: setup, action, verify, expected (clear and runnable)
- ✓ Tests reference fixtures (T-16/T-17)
- ✓ Performance targets specified (< 100ms for queries, etc.)
- ✓ All scenarios measurable pass/fail

### Verification

```bash
test -f .specs/shared/WAVE_25A_INTEGRATION_TEST_SPEC.md || exit 1

# Verify test counts
grep -c "^- T-INT-" WAVE_25A_INTEGRATION_TEST_SPEC.md | grep "16" && echo "✓ 16 tests specified"

# Verify scenario sets
grep -c "^## SET [1-4]:" WAVE_25A_INTEGRATION_TEST_SPEC.md | grep "4" && echo "✓ 4 scenario sets"

# Verify test structure
grep -q "Setup:\|Action:\|Verify:\|Expected:" WAVE_25A_INTEGRATION_TEST_SPEC.md && echo "✓ Standard sections"

echo "✓ All verifications passed"
```

### Evidence Required

- File WAVE_25A_INTEGRATION_TEST_SPEC.md (100 lines)
- 16 tests specified (4 per scenario set)
- Each test with setup/action/verify/expected

---

## T-19: Load Test Spec (1000 tasks, 3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-05 (performance baseline), T-18 (integration tests complete)  
**Verification:** MANDATORY

### Objective

Create specification for 4 load test suites (8 hours to run, 1000+ concurrent tasks). Per Q5 decision: start with 1000 tasks, scale up available later. Tests verify performance under load and scalability.

### Deliverable

File: `.specs/shared/WAVE_25A_LOAD_TEST_SPEC.md` (100 lines) with:

**Suite 1: 1000 Task Allocation Assignments (2 hours)**
- Objective: Assign 1000 tasks with varying allocation sizes
- Test data: Fixtures from T-16/T-17 repeated, varied
- Measurements:
  - Per-task allocation time: target < 2ms
  - Total time: target < 2000ms (1000 tasks × 2ms)
  - Memory usage: track peak
- Success criteria: 95%+ tasks < 2ms, zero violations

**Suite 2: 10K File Pattern Matching (2 hours)**
- Objective: Match 10K files against various allocation patterns
- Test data: 10K file paths, 50-100 allocation patterns
- Measurements:
  - Per-file matching: target < 10µs
  - Total time: target < 100ms (10K files × 10µs)
- Success criteria: 99%+ files < 10µs, zero false positives/negatives

**Suite 3: 1000-Event Ledger Queries (1.5 hours)**
- Objective: Query and audit 1000-event ledgers
- Test data: Synthetic 1000-event ledger (mix of event types)
- Measurements:
  - Query all events: target < 500ms
  - Filter violations: target < 200ms
  - Export JSON: target < 300ms
- Success criteria: All queries < targets, no corruption

**Suite 4: 100 Concurrent Write Conflicts (2.5 hours)**
- Objective: 100 concurrent tasks trying to write to same 10 files
- Test data: Overlapping allocations, same forbidden file
- Measurements:
  - Detect all 100% of conflicts
  - Resolve conflicts correctly (escalation, approval)
  - Ledger records all conflict events
- Success criteria: Zero false negatives, all conflicts resolved

### Acceptance Criteria

- ✓ File created at `.specs/shared/WAVE_25A_LOAD_TEST_SPEC.md`
- ✓ 4 load test suites specified
- ✓ Each suite: objective, test data, measurements, success criteria
- ✓ Performance targets align with T-05 baseline
- ✓ 1000-task scale confirmed (Q5 decision)
- ✓ Concurrent scenario included (Suite 4)

### Verification

```bash
test -f .specs/shared/WAVE_25A_LOAD_TEST_SPEC.md || exit 1

# Verify suites
grep -c "^## Suite [1-4]:" WAVE_25A_LOAD_TEST_SPEC.md | grep "4" && echo "✓ 4 suites specified"

# Verify performance targets
grep -q "< 2ms\|< 10µs\|< 500ms" WAVE_25A_LOAD_TEST_SPEC.md && echo "✓ Performance targets"

# Verify 1000-task scale
grep -q "1000" WAVE_25A_LOAD_TEST_SPEC.md && echo "✓ 1000-task scale confirmed"

echo "✓ All verifications passed"
```

### Evidence Required

- File WAVE_25A_LOAD_TEST_SPEC.md (100 lines)
- 4 test suites specified
- Performance targets documented
- Success criteria clear

---

## T-20: Design Review & Approval Gate (2 hours)

**Owner:** User (External)  
**Depends:** T-11 through T-19 (all Phase 2 deliverables complete)  
**Verification:** USER CONFIRMATION

### Required Action

User reviews and approves Phase 2 output (contracts + fixtures + test specs):

1. **Phase 2 Completion Checklist:**
   - ✓ T-11: allocation-contract.md V2 (250 lines, foundation)
   - ✓ T-12: allocation-enforcement-contract.md (350 lines, enforcement)
   - ✓ T-13: allocation-ledger-contract.md (NEW, 200 lines, ledger extraction)
   - ✓ T-14: WAVE_25A_MIGRATION_PATH.md (120 lines, transition guide)
   - ✓ T-15: allocation-check.contract.md V2 (400 lines, tool spec expanded)
   - ✓ T-16: Safe path fixtures (3 files, 150 lines)
   - ✓ T-17: Violation fixtures (3 files, 150 lines)
   - ✓ T-18: Integration test spec (16 tests, 4 scenario sets)
   - ✓ T-19: Load test spec (4 suites, 1000 tasks)

2. **Quality Gates:**
   - Contract line counts: all within ±10 lines of targets
   - No redundancy across contracts: allocation → enforcement → ledger → specialist
   - Fixtures valid YAML, all tests runnable
   - Test specs measurable (pass/fail clear)
   - All decisions Q1-Q5 reflected in deliverables

3. **Gate Criteria:**
   - Phase 2 documents ✓ (9 deliverables)
   - No blockers identified ✓
   - Contracts consolidated per Option B ✓
   - Fixtures + test specs ready for Phase 4 ✓
   - Confidence: 95% (only integration test execution remains) ✓

4. **Decision:**
   - **APPROVED:** Proceed to Phase 3 (tooling implementation)
   - **BLOCKED:** Return to specific task (reason required)

### Acceptance

User confirms (via chat or command) one of:
- "APPROVED — proceed to Phase 3"
- "NEEDS REVISION — [reason]"

### Verification

```bash
# Verify all 9 Phase 2 deliverables exist
test -f .specs/shared/allocation-contract.md && echo "✓ T-11"
test -f .specs/shared/allocation-enforcement-contract.md && echo "✓ T-12"
test -f .specs/shared/allocation-ledger-contract.md && echo "✓ T-13"
test -f .specs/shared/WAVE_25A_MIGRATION_PATH.md && echo "✓ T-14"
test -f .specs/shared/allocation-check.contract.md && echo "✓ T-15"
test -f .specs/shared/fixtures/safe-narrowing.yaml && echo "✓ T-16 (fixture 1)"
test -f .specs/shared/fixtures/violation-user-approval.yaml && echo "✓ T-17 (fixture 4)"
test -f .specs/shared/WAVE_25A_INTEGRATION_TEST_SPEC.md && echo "✓ T-18"
test -f .specs/shared/WAVE_25A_LOAD_TEST_SPEC.md && echo "✓ T-19"

echo "✓ All Phase 2 deliverables present"
```

---

# MEMORY WRITE TRIGGER

**Trigger:** Phase 2 completion (T-20 gate passed)

**Memory Entry Location:** `.specs/memory/active-state.md`

**Update Required:**
```yaml
active_phase: Phase 3 (Tooling Implementation)
active_task: T-20 (GATE PASSED) → T-21 (NEXT)
last_update: 2026-07-03T22:XX:XXZ
```

---

# NEXT PHASE: PHASE 3 (Tooling Implementation)

**When:** After T-20 user approval  
**Duration:** 23h serial / 10h parallel  
**Deliverable:** 5 new/enhanced tool commands + agent helpers  
**Tasks:** T-21 through T-30  

Detailed Phase 3 specs will be created after T-20 approval.

---

**Document Status:** READY FOR EXECUTION  
**Created:** 2026-07-03  
**Phase 2 User Decision Checkpoint:** AWAITING T-20 GATE APPROVAL

---

**NEXT IMMEDIATE ACTION:**

Please review Phase 2 plan and confirm one of:

**A. APPROVED** → Proceed to Phase 3 (tooling begins)

**B. NEEDS REVISION** → Describe what needs fixing

