# Task

task_id: T-002
title: Define MCP governance matrix
status: validated
change: harness-360-refactor
owner_agent: altitude-execution

## Objective

Define the central MCP governance matrix so future agent and KB refactors use a shared phase-aware and risk-aware MCP policy.

## Context

The current harness mixes MCP policy across prompts, shared docs, and examples, while `opencode.json` does not actually wire live MCP servers.

## Source References

- `.specs/shared/mcp-governance.md`
- `docs/ALTITUDE_SPECS_HARNESS.md`
- `AGENTS.md`
- `opencode.json`
- `config/opencode.example.jsonc`

## Allowed Files

- `docs/HARNESS_MCP_GOVERNANCE_MATRIX.md`
- `docs/HARNESS_REFACTOR_MASTER_PLAN.md`
- `.specs/changes/harness-360-refactor/03-execution-ledger.md`
- `.specs/changes/harness-360-refactor/04-validation.md`
- `.specs/changes/harness-360-refactor/state.md`

## Forbidden Scope

- `agents/*.agent.md`
- `config/routing.json`
- `plugins/*.ts`
- `kb/**`

## Dependencies

- T-001

## Implementation Steps

1. Freeze the central matrix by altitude.
2. Add domain hard-stop rules.
3. Record runtime expectations and evidence requirements.
4. Update the plan and ledger.

## Acceptance Criteria

- the matrix defines default posture per altitude
- the matrix defines hard-stop rules for Fabric, security, and Supabase
- the matrix distinguishes designed posture from live runtime availability

## Verification Commands

- manual cross-check against the listed source references

## Evidence Required

- `docs/HARNESS_MCP_GOVERNANCE_MATRIX.md`
- `.specs/changes/harness-360-refactor/03-execution-ledger.md`
- `.specs/changes/harness-360-refactor/04-validation.md`

## Rollback

Remove the matrix doc and restore the task state if the policy freeze is directionally wrong.

## Completion Checklist

- [x] Scope confirmed
- [x] Allowed files respected
- [x] Verification completed or justified
- [x] Evidence saved
- [x] Execution ledger updated
- [x] Ready for validation
