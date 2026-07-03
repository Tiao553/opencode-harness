# Acceptance Checker Tool Contract — Wave 17

**Tool:** `tools/acceptance-checker.sh`
**Version:** 1.0
**Wave:** 17 (Final Validation)
**Status:** Active

---

## 1. Overview

`acceptance-checker.sh` is the **final validation gate** for the 11-wave Harness V3 implementation (Waves 7-17).

It validates:
- All 16 prior waves are implemented
- All 11 contracts exist
- All 11 tools are executable
- All 11 fixtures pass
- Documentation is complete
- Quality gates are met

Exit code semantics:
- **0** = Ready to ship
- **1** = Blocked (cannot ship)

---

## 2. Commands

### `acceptance-checker.sh final-gate`

**Purpose:** Run all gate checks and show detailed report
**Output:** Human-readable report with colors and status
**Exit Code:** 0 (pass) or 1 (fail)

**Example:**
```bash
$ tools/acceptance-checker.sh final-gate
=============================================================================
WAVE 17 ACCEPTANCE GATE — Final Validation
=============================================================================

ℹ️  Checking wave completion (need 16 implemented)...
✅ PASS: Wave Completion Gate (found 16 implemented waves)

ℹ️  Checking contracts (need 11)...
✅ PASS: Contracts Gate (11/11 found)

ℹ️  Checking tools (need 11 executable)...
✅ PASS: Tools Gate (11/11 executable)

ℹ️  Checking fixtures (need 11)...
✅ PASS: Fixtures Gate (11 fixtures found)
✅ PASS: Fixture smoke test passed: wave-17-final-validation-smoke.fixture.md

ℹ️  Checking documentation...
✅ PASS: AGENTS.md has sections 21.7-21.17
✅ PASS: README.md has Waves 7-17 section
✅ PASS: Roadmap doc exists: docs/HARNESS_V3_WAVES_7-17_ROADMAP.md

ℹ️  Checking quality (no TODOs/FIXMEs)...
✅ PASS: No TODOs or FIXMEs in contracts

=============================================================================
RESULTS
=============================================================================
Passed: 13
Failed: 0
Warnings: 0

✅ ALL GATES PASSED — READY TO SHIP
```

### `acceptance-checker.sh checklist`

**Purpose:** Print the validation checklist (reference only)
**Output:** Formatted checklist of all items to verify
**Exit Code:** Always 0

**Example:**
```bash
$ tools/acceptance-checker.sh checklist
=============================================================================
WAVE 17 VALIDATION CHECKLIST
=============================================================================

Wave Completion (all 16 prior waves):
  ☐ W7-RALPH-LOOP .......................... status: implemented
  ☐ W8-KB-QUALITY .......................... status: implemented
  ...
  ☐ W17-FINAL-VALIDATION ................... status: implemented

Contracts (11 required):
  ☐ verification-contract.md
  ...

Tools (11 required, must be executable):
  ☐ tools/verify-step.sh
  ...
```

### `acceptance-checker.sh ready-to-ship`

**Purpose:** Binary check: are we ready to ship? (silent mode)
**Output:** None (exit code only)
**Exit Code:** 0 (ready) or 1 (not ready)

**Example (shell scripting):**
```bash
$ tools/acceptance-checker.sh ready-to-ship && echo "SHIP APPROVED" || echo "SHIP BLOCKED"
SHIP APPROVED

# Or in a CI pipeline:
if tools/acceptance-checker.sh ready-to-ship; then
  git merge --no-ff release/waves-7-17
  git push origin main
else
  echo "Ship gate failed. Check final-gate output."
  exit 1
fi
```

---

## 3. Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Ready to ship | Proceed with merge (PR-7, PR-8, PR-9) |
| 1 | Blocked | Fix failures, re-run final-gate |

---

## 4. Validation Gates

The tool checks these gates in order:

#### Gate 1: Wave Completion
- **Check:** Count implemented waves (need ≥16)
- **Severity:** Critical
- **Failure:** Not all prior waves complete

#### Gate 2: Contracts
- **Check:** All 11 contracts exist in `.specs/shared/`
- **Severity:** Critical
- **Failure:** Missing contract files

#### Gate 3: Tools
- **Check:** All 11 tools exist and are executable
- **Severity:** Critical
- **Failure:** Tool missing or not executable

#### Gate 4: Fixtures
- **Check:** All 11 fixtures exist (smoke test W17)
- **Severity:** Critical
- **Failure:** Fixture missing or fails smoke test

#### Gate 5: Documentation
- **Check:** AGENTS.md (21.7-21.17), README.md (Waves 7-17), Roadmap doc
- **Severity:** High
- **Failure:** Documentation incomplete

#### Gate 6: Quality
- **Check:** No TODOs/FIXMEs in contracts
- **Severity:** High
- **Failure:** Quality issues remain

---

## 5. Usage Examples

### CI/CD Pipeline Integration

```bash
#!/bin/bash
# Pre-merge-gate.sh

set -e

echo "Running Wave 17 acceptance checks..."
tools/acceptance-checker.sh final-gate

if tools/acceptance-checker.sh ready-to-ship; then
  echo "✅ Ready to ship!"

  # Merge all 3 PRs in order
  gh pr merge PR-7 --squash --auto
  sleep 2
  gh pr merge PR-8 --squash --auto
  sleep 2
  gh pr merge PR-9 --squash --auto

  echo "✅ All PRs merged. Waves 7-17 shipped!"
else
  echo "❌ Ship gate failed."
  exit 1
fi
```

### Manual Pre-Ship Verification

```bash
# 1. Run full gate check
./tools/acceptance-checker.sh final-gate

# 2. Review checklist
./tools/acceptance-checker.sh checklist

# 3. If all pass, run binary check
if ./tools/acceptance-checker.sh ready-to-ship; then
  echo "Ready for production merge"
else
  echo "Review final-gate output for failures"
fi
```

### Scripting Integration

```bash
#!/bin/bash
# ship-waves-7-17.sh — Automated shipping script

CHANGE_PATH=".specs/changes/waves-7-17-implementation"

# Pre-checks
if ! tools/acceptance-checker.sh ready-to-ship; then
  echo "ERROR: Acceptance gate failed."
  tools/acceptance-checker.sh final-gate
  exit 1
fi

# Archive change
mkdir -p .specs/archive/
cp -r "$CHANGE_PATH" ".specs/archive/waves-7-17-$(date +%Y%m%d-%H%M%S)/"

# Update memory
cat > .specs/memory/active-state.md << 'EOF'
# Active State

active_change: null
active_task: null
current_phase: Ship (Complete)
status: Waves 7-17 shipped to main
completed_at: 2026-06-30T13:00:00Z

## Last Shipped Wave

waves-7-17-implementation: All 11 waves (W7-W17) merged to main
EOF

# Mark complete
echo "✅ Waves 7-17 shipped and archived"
```

---

## 6. Error Handling

### Common Failures & Fixes

| Failure | Cause | Fix |
|---------|-------|-----|
| "Wave Completion Gate failed" | Some waves not marked implemented | Run prior wave tasks, update task status |
| "Contracts Gate failed" | Missing .specs/shared/*-contract.md | Create missing contract files |
| "Tools Gate failed" | Tool missing or not executable | Create tool, run `chmod +x tools/*.sh` |
| "Fixtures Gate failed" | Fixture doesn't exist or fails | Create/fix fixture, ensure it runs cleanly |
| "Documentation Gate failed" | Missing AGENTS.md sections or roadmap | Update AGENTS.md, create roadmap doc |
| "Quality Gate failed" | TODOs/FIXMEs in contracts | Remove all TODO/FIXME comments |

### Diagnostic Commands

```bash
# Debug which waves are missing
grep "^status:" .specs/changes/waves-7-17-implementation/tasks/W*.md | grep -v "implemented"

# Check which contracts exist
ls .specs/shared/*-contract.md

# Check which tools are executable
find tools -name "*.sh" -type f ! -executable

# Run one fixture manually (verbose)
bash test/fixtures/harness-v3/wave-17-final-validation-smoke.fixture.md

# Check for TODOs
grep -r "TODO\|FIXME" .specs/shared/*-contract.md
```

---

## 7. Integration Points

### altitude-execution.agent.md
- Calls `acceptance-checker.sh final-gate` at task start to verify gate status
- Records results in evidence

### altitude-validation.agent.md
- Runs `acceptance-checker.sh final-gate` as part of validation junta
- Uses exit code to determine pass/fail

### altitude-report.agent.md
- Calls `acceptance-checker.sh ready-to-ship` before generating final ship summary
- Documents gate status in report

### CI/CD Pipeline
- Runs `acceptance-checker.sh ready-to-ship` as pre-merge check
- Blocks merge if exit code is 1

---

## 8. Test Scenarios

### Scenario 1: Happy Path (All Gates Pass)

**Setup:**
- All 16 prior waves marked implemented
- All 11 contracts exist
- All 11 tools executable
- All 11 fixtures pass
- Documentation complete
- No TODOs/FIXMEs

**Expected:**
```bash
$ tools/acceptance-checker.sh ready-to-ship
$ echo $?
0
```

**Report:**
```bash
$ tools/acceptance-checker.sh final-gate
✅ ALL GATES PASSED — READY TO SHIP
```

### Scenario 2: Missing Contracts

**Setup:**
- Missing `orchestration-contract.md`

**Expected:**
```bash
$ tools/acceptance-checker.sh ready-to-ship
$ echo $?
1
```

**Report shows:**
```
⚠️  WARN: Missing contract: .specs/shared/orchestration-contract.md
❌ FAIL: Contracts Gate (only 10/11 found)
```

### Scenario 3: Tool Not Executable

**Setup:**
- `tools/chaos-tester.sh` exists but not executable

**Expected:**
```bash
$ tools/acceptance-checker.sh ready-to-ship
$ echo $?
1
```

**Report shows:**
```
⚠️  WARN: Missing or not executable: tools/chaos-tester.sh
❌ FAIL: Tools Gate (only 10/11 executable)
```

---

## 9. Performance

- **Runtime:** ~5-10 seconds (includes fixture smoke test)
- **No external dependencies** (pure bash)
- **No network calls**
- **Safe to run in CI** (no mutation)

---

## 10. Output Format

### Log Level: INFO
```
ℹ️  Checking wave completion (need 16 implemented)...
```

### Log Level: PASS
```
✅ PASS: Wave Completion Gate (found 16 implemented waves)
```

### Log Level: FAIL
```
❌ FAIL: Contracts Gate (only 10/11 found)
```

### Log Level: WARN
```
⚠️  WARN: Missing contract: .specs/shared/orchestration-contract.md
```

---

## 11. References

- **Contract:** `.specs/shared/final-validation-contract.md`
- **Task Spec:** `.specs/changes/waves-7-17-implementation/tasks/W17-FINAL-VALIDATION.md`
- **Execution Guide:** `AGENTS.md` Section 21.17
- **Fixtures:** `test/fixtures/harness-v3/wave-*-smoke.fixture.md`

---

**Next Step:** After `acceptance-checker.sh ready-to-ship` returns 0, proceed with PR merges in order: PR-7, PR-8, PR-9.
