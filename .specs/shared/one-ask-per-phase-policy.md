# One-Ask-Per-Phase Policy

## Overview

Permission approval should happen **once per phase transition**, not for every individual command.

When a user approves a task during the Design/Plan phase, all downstream execution commands (edits, bash operations, task delegation) should execute without repeated permission prompts.

This policy eliminates user friction and respects the approval decision already made during phase transitions.

## Problem Statement

Before this policy, `altitude-execution` and `data-engineer` agents were configured with:

```yaml
permission:
  edit: ask
  bash: ask
  task: ask
```

This caused agents to repeatedly ask for permission before each command, even though:

1. The user already approved the task in the **Design/Plan phase**
2. The task has explicit `allowed_files` scope defined
3. The allocation contract already bounds the execution surface
4. Ralph Loop verification happens at each step

Result: **User friction + redundant permission checks**

## Solution

Changed permission model to:

```yaml
permission:
  edit: allow      # Trust the allocation, not the command
  bash: allow      # Trust the allocation, not the command
  task: allow      # Trust the phase approval, not individual delegation
```

## Scope of Approval

### Design/Plan Phase

The user approves:

- What work will be done
- Which files can be modified (`allowed_files`)
- Which files are forbidden (`forbidden_files`)
- What evidence is required
- What constitutes success

### Execution Phase

Given that approval, agents:

- Execute edits to allowed files only
- Run bash commands only within scope
- Delegate to specialists only if pre-authorized
- Record evidence and state
- Verify at each step (via Ralph Loop, not permission gates)

## Safety Guarantees

This policy does **not** eliminate safety checks. It separates them from permission gates:

| Safety Layer | Mechanism | Enforced By |
|---|---|---|
| **Scope enforcement** | `allocation-check.sh` validates file paths | altitude-execution (pre-write) |
| **Context budget** | `headroom-validator.sh` checks token usage | altitude-execution (pre-task) |
| **Evidence collection** | Ralph Loop verification steps | altitude-execution + specialists |
| **Validation gate** | altitude-validation audits implementation | Phase transition (Execution → Validate) |
| **Shipping gate** | acceptance-checker final-gate | Phase transition (Validate → Ship) |

## Files Changed

### 1. `plugins/permission-hardening.ts` (lines 429-440)

Changed `altitudeExecutionPermission()`:

```diff
  edit: "ask"  →  edit: "allow"
  bash: "allow" (unchanged)
  task: "ask"  →  task: "allow"
  websearch: "ask"  →  websearch: "allow"
  webfetch: "ask"  →  webfetch: "allow"
```

### 2. `agents/data-engineer.agent.md` (lines 5-16)

Changed YAML permission header:

```diff
  bash: ask  →  bash: allow
  task: ask  →  task: allow
  websearch: ask  →  websearch: allow
  webfetch: ask  →  webfetch: allow
```

### 3. `agents/altitude-execution.agent.md` (lines 5-16)

Changed YAML permission header:

```diff
  task: ask  →  task: allow
  websearch: ask  →  websearch: allow
  webfetch: ask  →  webfetch: allow
```

## Ralph Loop Integration

The Ralph Loop now replaces permission gates as the verification mechanism:

```text
1. [Restate task] → verify: task matches active task
2. [Identify constraints] → verify: allocation scope
3. [Plan minimal change] → verify: only allowed files
4. [Execute] → verify: (allocation-check.sh)
5. [Verify] → verify: expected behavior
6. [Evaluate acceptance criteria] → verify: matches TEST-SPEC
7. [Repair if needed] → verify: fix valid
8. [Record evidence] → verify: evidence in ledger
9. [Update state] → verify: state consistency
```

Each step has an explicit verify gate; permission gates are not needed.

## When This Policy Does NOT Apply

This policy applies to **approved execution tasks only**.

Permission gates remain for:

- **Read-only agents** (`dev.codebase-explorer`, etc.): No approval needed, read access granted
- **Auditors** (`dev.faithfulness-guard`, `dev.judge-agent`): No modifications, read-only + analysis
- **Security specialists** (`dev.security-guardian`): Pre-commit checks, permission controlled
- **External data agents**: May have `websearch: ask` or `webfetch: ask` for audit trails

## Escalation

If during execution an agent detects a **violation** (e.g., attempt to write to a forbidden file):

1. **allocation-check.sh** returns exit code 1
2. altitude-execution logs `violation_blocked` event
3. altitude-execution asks user:
   - A. Approve scope expansion
   - B. Abort task
   - C. Escalate to security specialist

This is **allocation enforcement**, not permission enforcement. It's a safety check, not a gate.

## Future Extensions

This policy is compatible with:

- **Wave 5 Allocation Enforcement** (`allocation-check.sh`): Validates file scope boundaries
- **Wave 6 Context Budget** (`headroom-validator.sh`): Checks token usage before heavy work
- **Audit trails**: All decisions logged in execution-ledger.md with timestamps and rationale
- **Replay and recovery**: Full execution trace enables deterministic replay

## References

- `.specs/shared/execution-loop-contract.md` — Ralph Loop specification
- `.specs/shared/allocation-enforcement-contract.md` — File-level scope boundaries
- `.specs/shared/context-budget-contract.md` — Token budget enforcement
- `agents/altitude-execution.agent.md` — Execution agent behavior
- `agents/data-engineer.agent.md` — Data engineer tactical coordinator
- `plugins/permission-hardening.ts` — Permission configuration
