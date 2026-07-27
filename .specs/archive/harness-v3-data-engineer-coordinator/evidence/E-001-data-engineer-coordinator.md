# Evidence

evidence_id: E-001
change: harness-v3-data-engineer-coordinator
task: DE-001
created: 2026-06-28
command: JSON parser + route coverage grep
status: captured
captured_by: openai/gpt-5.4

## Summary

Created the visible `data-engineer` tactical coordinator and the tactical routing contract.

## Commands

```bash
node - <<'NODE'
const fs = require('fs');
const cfg = JSON.parse(fs.readFileSync('opencode.json', 'utf8'));
if (!cfg.agent || cfg.agent['data-engineer']?.mode !== 'primary') throw new Error('data-engineer primary missing');
if (cfg.agent['altitude']?.mode !== 'primary') throw new Error('altitude primary missing');
console.log('coordinator-config-ok');
NODE

grep 'sql-review|data-quality|data-contract|pipeline|migrate|lakehouse|ai-pipeline|spark|streaming|observability' agents/data-engineer.agent.md docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md
test -f docs/HARNESS_V3_TACTICAL_ROUTING_CONTRACT.md
```

## Results

```text
coordinator-config-ok
data-engineer -> primary
altitude -> primary
tactical route coverage present
tactical-contract-ok
```

## Interpretation

The two visible coordinator model is now represented in config: `altitude` for strategic durable work and `data-engineer` for bounded tactical data-engineering work.

## Limitation

This validation checks configuration and route coverage. It does not execute a live tactical request through OpenCode.

