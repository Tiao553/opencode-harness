---
id: W8-KB-QUALITY
title: "Wave 8: KB Quality & Indexing — Domain Catalog and Freshness Tracking"
status: implemented
format_version: 2.1
effort: M
budget: 48000
agent: altitude-structure
severity: feature
execution_backend: any

touches_paths:
  - .specs/shared/kb-quality-contract.md
  - tools/kb-indexer.sh
  - tools/kb-indexer.contract.md
  - agents/altitude-structure.agent.md
  - test/fixtures/harness-v3/wave-8-kb-quality-smoke.fixture.md
  - .specs/changes/waves-7-17-implementation/wave-8/

source_note: waves-7-17-implementation/DESIGN.md
depends_on: [W7-RALPH-LOOP]
blocks: []
---

# Wave 8: KB Quality & Indexing

## Why

Harness V3 context loading is intelligent only if KB quality is known. Wave 8 makes KB audit automatic:
- Index all KB domains
- Track freshness (age, decay curves)
- Enable smart context loading (prefer fresh domains)
- Warn on stale KBs (>30 days)

## Goal

Implement KB indexer and integrate into altitude-structure:
- ✅ Scan all KB domains and build index
- ✅ Track freshness metadata (last-update, age)
- ✅ Detect stale domains (>30 days)
- ✅ Emit freshness warnings during structure phase
- ✅ 2 smoke test scenarios (fresh KB, stale KB)

## Success Criteria

### Eval 1: KB quality contract complete

```bash
eval_1() {
  test -f .specs/shared/kb-quality-contract.md || return 1
  grep -q "domain_taxonomy:" .specs/shared/kb-quality-contract.md || return 1
  grep -q "freshness_schema:" .specs/shared/kb-quality-contract.md || return 1
  [ $(wc -l < .specs/shared/kb-quality-contract.md) -ge 80 ] || return 1
}
```

### Eval 2: kb-indexer tool works

```bash
eval_2() {
  test -x tools/kb-indexer.sh || return 1
  tools/kb-indexer.sh index kb/ > /dev/null 2>&1 || return 1
  tools/kb-indexer.sh list | grep -q "domain_id" || return 1
  tools/kb-indexer.sh freshness --domain ai-data-engineer > /dev/null 2>&1 || return 1
  bash -n tools/kb-indexer.sh || return 1
}
```

### Eval 3: altitude-structure integrated

```bash
eval_3() {
  grep -q "kb-indexer" agents/altitude-structure.agent.md || return 1
  grep -q "freshness" agents/altitude-structure.agent.md || return 1
}
```

### Eval 4: Fixtures pass

```bash
eval_4() {
  bash test/fixtures/harness-v3/wave-8-kb-quality-smoke.fixture.md > /dev/null 2>&1 || return 1
}
```

### Exit Check
```bash
eval_1 && eval_2 && eval_3 && eval_4
```

---

## Rollback Plan

Remove kb-indexer calls from altitude-structure; leave tool in place.

---

## Anti-Patterns

❌ **Don't** hardcode KB paths (use configurable path)  
❌ **Don't** count lines as freshness metric (use mtime)  
❌ **Don't** warn on every KB access (warn once per phase)  

---

## Do-Not-Touch

🚫 Waves 0-6, 7  
🚫 Source code  
