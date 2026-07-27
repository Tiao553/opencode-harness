# Evidence

evidence_id: E-001
change: harness-v3-strategic-coordinator
task: SC-001
created: 2026-06-28
command: JSON parser + mode/frontmatter checks
status: captured
captured_by: openai/gpt-5.4

## Summary

Introduced one visible `altitude` strategic coordinator and demoted the phase-specific `altitude-*` agents to hidden subagents.

## Commands

```bash
node - <<'NODE'
const fs = require('fs');
const cfg = JSON.parse(fs.readFileSync('opencode.json', 'utf8'));
const agents = cfg.agent || {};
const altitudeEntries = Object.entries(agents).filter(([name]) => name === 'altitude' || name.startsWith('altitude-'));
console.log('opencode-json-ok');
console.log(JSON.stringify(altitudeEntries.map(([name, value]) => ({ name, mode: value.mode, hidden: value.hidden === true })), null, 2));
const visibleAltitude = altitudeEntries.filter(([name, value]) => name === 'altitude' && value.mode === 'primary');
const primaryPhase = altitudeEntries.filter(([name, value]) => name.startsWith('altitude-') && value.mode === 'primary');
if (visibleAltitude.length !== 1) throw new Error('expected exactly one primary altitude coordinator');
if (primaryPhase.length !== 0) throw new Error('phase agents still primary: ' + primaryPhase.map(([name]) => name).join(','));
NODE

grep '^mode: primary\|^mode: subagent' agents/altitude*.agent.md
grep 'state-resolution-contract\|phase-engine-contract\|allocation-contract\|altitude-execution\|Output Contract' agents/altitude.agent.md
```

## Results

```text
opencode-json-ok
altitude -> primary
altitude-intent -> subagent hidden
altitude-structure -> subagent hidden
altitude-plan -> subagent hidden
altitude-execution -> subagent hidden
altitude-validation -> subagent hidden
altitude-report -> subagent hidden
altitude-memory -> subagent hidden
```

## Interpretation

The strategic coordinator wave now has one visible `altitude` primary agent while preserving phase-specific behavior as internal subagents.

## Limitation

This validation checks configuration and prompt state. It does not execute an OpenCode runtime session through the new coordinator.

