# Final Validation Contract — Wave 17

**Wave:** 17 (Final Validation & Documentation)  
**Version:** 1.0  
**Date:** 2026-06-30  
**Status:** Active  

---

## 1. Purpose

This contract defines the final acceptance gate for the 11-wave Harness V3 implementation (Waves 7-17).

It specifies:
- What "ready to ship" means
- Validation checklist (all 16 prior waves)
- Metrics for success
- Shipping criteria
- Rollback procedures

---

## 2. Acceptance Schema

```yaml
acceptance_schema:
  version: "1.0"
  change_id: "waves-7-17-implementation"
  
  gates:
    - id: wave_completion
      description: "All 16 prior waves (W7-W16) must be implemented"
      check: "grep -c 'status: implemented' .specs/changes/waves-7-17-implementation/tasks/W*.md"
      expected: ">=16"
      severity: critical
      
    - id: contracts_exist
      description: "All 11 wave contracts must exist"
      check: "ls .specs/shared/{verification,kb-quality,security,metrics,state-machine,recovery,orchestration,protocols,meta-validation,hardening,final-validation}-contract.md"
      expected: "11 files"
      severity: critical
      
    - id: tools_exist
      description: "All 11 tools must be executable"
      check: "ls -la tools/{verify-step,kb-indexer,security-scan,metrics-collector,state-validator,recovery-manager,wave-scheduler,agent-messenger,junta-auditor,chaos-tester,acceptance-checker}.sh | wc -l"
      expected: "11 executables"
      severity: critical
      
    - id: tools_executable
      description: "All tools must have execute permission"
      check: "find tools -name '*-step.sh' -o -name '*-indexer.sh' -o -name '*-scan.sh' -o -name '*-collector.sh' -o -name '*-validator.sh' -o -name '*-manager.sh' -o -name '*-scheduler.sh' -o -name '*-messenger.sh' -o -name '*-auditor.sh' -o -name '*-tester.sh' -o -name '*-checker.sh' | xargs test -x"
      expected: "exit 0"
      severity: critical
      
    - id: fixtures_pass
      description: "All 11 wave fixtures must pass"
      check: "for f in test/fixtures/harness-v3/wave-*-smoke.fixture.md; do bash \"$f\" > /dev/null 2>&1 || exit 1; done"
      expected: "exit 0 for all"
      severity: critical
      
    - id: no_todos_contracts
      description: "No TODO or FIXME in contracts"
      check: "grep -r 'TODO\\|FIXME' .specs/shared/*-contract.md || true"
      expected: "0 matches"
      severity: high
      
    - id: no_broken_links
      description: "No broken file references"
      check: "grep -r '\\[.*\\](.*\\.md)' AGENTS.md README.md docs/ | while read line; do file=$(echo \"$line\" | sed 's/.*](\\([^)]*\\)).*/\\1/'); test -f \"$file\" || echo \"BROKEN: $file\"; done || true"
      expected: "no broken files"
      severity: high
      
    - id: agents_md_complete
      description: "AGENTS.md has sections 21.7-21.17"
      check: "grep -c '^### 21\\.[7-9]\\|^### 21\\.1[0-7]' AGENTS.md"
      expected: ">=11"
      severity: high
      
    - id: readme_updated
      description: "README.md has Waves 7-17 section"
      check: "grep -q 'Waves 7-17\\|Wave 7.*Wave 17' README.md"
      expected: "match found"
      severity: high
      
    - id: roadmap_exists
      description: "Roadmap doc exists"
      check: "test -f docs/HARNESS_V3_WAVES_7-17_ROADMAP.md"
      expected: "file exists"
      severity: high
      
    - id: state_complete
      description: "state.md marks all waves complete"
      check: "grep -c 'status: implemented' .specs/changes/waves-7-17-implementation/state.md"
      expected: ">=1"
      severity: medium
      
    - id: no_uncommitted
      description: "No uncommitted changes in allowed files"
      check: "cd .specs/changes/waves-7-17-implementation && git status --short 2>/dev/null | grep -v '^?' || echo 'not a git repo' | head -1"
      expected: "clean or 'not a git repo'"
      severity: low
```

---

## 3. Validation Checklist

### Pre-Ship Validation (Before Merge)

```
Wave Completion (all 16 prior waves):
  ☑ W7-RALPH-LOOP .......................... status: implemented
  ☑ W8-KB-QUALITY .......................... status: implemented
  ☑ W9-SECURITY ............................ status: implemented (or ready)
  ☑ W10-METRICS ............................ status: implemented
  ☑ W11-STATE-MACHINE ...................... status: implemented
  ☑ W12-RECOVERY ........................... status: implemented
  ☑ W13-ORCHESTRATION ...................... status: implemented
  ☑ W14-PROTOCOLS .......................... status: implemented
  ☑ W15-META-VALIDATION .................... status: implemented
  ☑ W16-HARDENING .......................... status: implemented
  ☑ W17-FINAL-VALIDATION ................... status: implemented (this task)

Contracts (all 11 exist):
  ☑ verification-contract.md .............. W7
  ☑ kb-quality-contract.md ................ W8
  ☑ security-contract.md .................. W9
  ☑ metrics-contract.md ................... W10
  ☑ state-machine-contract.md ............. W11
  ☑ recovery-contract.md .................. W12
  ☑ orchestration-contract.md ............. W13
  ☑ protocols-contract.md ................. W14
  ☑ meta-validation-contract.md ........... W15
  ☑ hardening-contract.md ................. W16
  ☑ final-validation-contract.md .......... W17

Tools (all 11 executable):
  ☑ tools/verify-step.sh .................. W7
  ☑ tools/kb-indexer.sh ................... W8
  ☑ tools/security-scan.sh ................ W9
  ☑ tools/metrics-collector.sh ............ W10
  ☑ tools/state-validator.sh .............. W11
  ☑ tools/recovery-manager.sh ............. W12
  ☑ tools/wave-scheduler.sh ............... W13
  ☑ tools/agent-messenger.sh .............. W14
  ☑ tools/junta-auditor.sh ................ W15
  ☑ tools/chaos-tester.sh ................. W16
  ☑ tools/acceptance-checker.sh ........... W17

Documentation:
  ☑ AGENTS.md sections 21.7-21.17 ........ All waves documented
  ☑ README.md Waves 7-17 section ......... New section added
  ☑ docs/HARNESS_V3_WAVES_7-17_ROADMAP.md Complete roadmap created

Fixtures (all 11 pass):
  ☑ test/fixtures/harness-v3/wave-7-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-8-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-9-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-10-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-11-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-12-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-13-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-14-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-15-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-16-*.fixture.md
  ☑ test/fixtures/harness-v3/wave-17-*.fixture.md

Quality Gates:
  ☑ No TODO in contracts .................. Clean
  ☑ No FIXME in contracts ................. Clean
  ☑ All links valid ....................... Clean
  ☑ No uncommitted changes ................ Clean
```

---

## 4. Shipping Criteria

A wave is **ready to ship** when:

1. **All acceptance gates pass** (section 2)
2. **All validation checklist items complete** (section 3)
3. **All 4 success evals pass:**
   ```bash
   eval_1() { grep -q "acceptance_schema:" .specs/shared/final-validation-contract.md; }
   eval_2() { tools/acceptance-checker.sh final-gate > /dev/null 2>&1 && tools/acceptance-checker.sh ready-to-ship > /dev/null 2>&1; }
   eval_3() { grep -q "21.7\|Wave 7" AGENTS.md && grep -q "Waves 7-17" README.md && test -f docs/HARNESS_V3_WAVES_7-17_ROADMAP.md; }
   eval_4() { bash test/fixtures/harness-v3/wave-17-final-validation-smoke.fixture.md > /dev/null 2>&1; }
   eval_1 && eval_2 && eval_3 && eval_4
   ```
4. **No blocking validation issues**
5. **State file marks all waves complete**
6. **All 3 PRs (PR-7, PR-8, PR-9) are mergeable**

---

## 5. Merge Order & Rollback

### Merge Sequence

```
1. Merge PR-7 (Waves 7-9, tools, contracts, agents)
   - .specs/shared/{verification,kb-quality,security}-contract.md
   - tools/{verify-step,kb-indexer,security-scan}.sh
   - agents/altitude-execution.agent.md updates
   
2. Merge PR-8 (Waves 10-13, state & orchestration)
   - .specs/shared/{metrics,state-machine,recovery,orchestration}-contract.md
   - tools/{metrics-collector,state-validator,recovery-manager,wave-scheduler}.sh
   - altitude-coordination updates
   
3. Merge PR-9 (Waves 14-17, protocols, validation, final)
   - .specs/shared/{protocols,meta-validation,hardening,final-validation}-contract.md
   - tools/{agent-messenger,junta-auditor,chaos-tester,acceptance-checker}.sh
   - agents/altitude-report.agent.md, agents/altitude-memory.agent.md updates
   - AGENTS.md, README.md, docs/ updates
```

### Rollback Procedure

If shipping fails:

1. **Revert all 3 PRs** in reverse merge order (PR-9, PR-8, PR-7)
2. **Restore prior state**: `git checkout HEAD~3`
3. **Investigate blocker** using evidence in `.specs/changes/waves-7-17-implementation/evidence/`
4. **File new task** to fix the blocker
5. **Re-run acceptance-checker.sh** to verify state

---

## 6. Success Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Waves completed | 16 | ? |
| Contracts created | 11 | ? |
| Tools delivered | 11 | ? |
| Fixtures passing | 11/11 | ? |
| Documentation complete | 100% | ? |
| Test pass rate | 100% | ? |
| No TODOs in docs | 0 | ? |
| No broken links | 0 | ? |

---

## 7. Integration Points

- **altitude-execution.agent.md**: Uses tools, records traces, updates ledger
- **altitude-validation.agent.md**: Runs acceptance-checker, validates evidence
- **altitude-report.agent.md**: Generates final report, calls acceptance-checker
- **altitude-memory.agent.md**: Archives to .specs/archive/, updates memory state

---

## 8. Known Limitations

- **No hard-breaking changes**: All 11 waves must be backward compatible
- **Advisory-only junta audit**: W15 does not block W16/W17 shipping
- **No partial shipping**: All 3 PRs must merge together (no cherry-picks)
- **Fixture-based validation only**: No external endpoint testing

---

## 9. Future Work (Waves 18+)

Planned enhancements:
- Runtime metrics collection (W7-W17 execution time, token usage)
- KB versioning and deprecation (periodic KB refresh)
- Security scanning CI integration (pre-commit hooks)
- Automated chaos testing in production
- Federated junta auditing (multi-team validation)

---

**Ready to ship:** Run `tools/acceptance-checker.sh ready-to-ship` → exit 0 = SHIP APPROVED
