---
id: W17-FINAL-VALIDATION
title: "Wave 17: Final Validation & Documentation"
status: implemented
effort: M
budget: 72000
agent: altitude-report
severity: feature
depends_on: [W15-META-VALIDATION, W16-HARDENING]
touches_paths:
  - .specs/shared/final-validation-contract.md
  - tools/acceptance-checker.sh
  - tools/acceptance-checker.contract.md
  - agents/altitude-report.agent.md
  - agents/altitude-memory.agent.md
  - AGENTS.md
  - README.md
  - docs/HARNESS_V3_WAVES_7-17_ROADMAP.md
  - test/fixtures/harness-v3/wave-17-final-validation-smoke.fixture.md
---

# Wave 17: Final Validation & Documentation

## Goal

Final gate, complete documentation, and SHIP:
- ✅ Final gate checks (all 16 prior waves)
- ✅ Update AGENTS.md (sections 21.7–21.17)
- ✅ Update README.md (Wave 7-17 summary)
- ✅ Create roadmap doc
- ✅ Mark ready to ship
- ✅ 2 smoke scenarios

## Success Criteria

```bash
eval_1() { grep -q "acceptance_schema:" .specs/shared/final-validation-contract.md; }
eval_2() { tools/acceptance-checker.sh final-gate > /dev/null 2>&1 && tools/acceptance-checker.sh ready-to-ship > /dev/null 2>&1; }
eval_3() { grep -q "21.7\|Wave 7" AGENTS.md && grep -q "Waves 7-17" README.md && test -f docs/HARNESS_V3_WAVES_7-17_ROADMAP.md; }
eval_4() { bash test/fixtures/harness-v3/wave-17-final-validation-smoke.fixture.md > /dev/null 2>&1; }
eval_1 && eval_2 && eval_3 && eval_4
```
