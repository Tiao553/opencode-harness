# Deterministic Audit — OpenCode Harness Skill-Based Migration Roadmap

## Verdict

**The architectural direction is sound, but Roadmap v1 was not safe to execute unchanged.**

Its strongest parts were the parent-owned TODO decision, separate Altitude/AgentSpec workflows, atomic leaf intent, evidence/rollback fields, and a dependency graph without cycles. The principal defects were migration sequencing, missing validation tasks, multiple live configuration mutations, incomplete runtime permission controls, and incomplete state/MCP operational guarantees.

## Method

The audit used fixed checks rather than free-form review:

1. Task-ID uniqueness.
2. Dependency referential integrity.
3. Dependency-cycle detection.
4. Markdown/backlog consistency.
5. Wave validation representation.
6. Source-of-truth and path uniqueness.
7. Mutation ordering and rollback safety.
8. OpenCode runtime compatibility.
9. Parent/leaf permission completeness.
10. Workflow isolation.
11. MCP configuration and trust boundaries.
12. State, memory, concurrency, and resume behavior.
13. Test determinism.
14. Cutover and cleanup completeness.

## Measured results from v1

- Waves: **13**.
- Tasks in CSV: **102**.
- Unique task IDs: **102**.
- Duplicate task IDs: **0**.
- Missing dependency references: **0**.
- Dependency cycles: **0**.
- Explicit wave-validation tasks in CSV: **0**.
- `T-V00` mentioned in Markdown but missing from CSV: **yes**.
- Priority distribution: **P0=94**, **P1=8**.
- Ambiguous conditional phrases detected: **11**.
- Tasks targeting `opencode.json` outside pure inventory/discovery: **10**.

## Gap register

| ID | Severity | Gap | Required correction |
|---|---|---|---|
| G-01 | CRITICAL | Wave validation was declared but not represented in the backlog. | Add T-V00 through T-V12 and block each next wave on the prior PASS. |
| G-02 | CRITICAL | AGENTS.md was scheduled for live rewrite before skills, commands, permissions, and MCP configuration were ready. | Stage AGENTS.next.md and activate only during W12. |
| G-03 | CRITICAL | Legacy dev agents could be deleted before command and consumer migration. | Freeze after parity; delete only after W11 validation and W12 cutover. |
| G-04 | CRITICAL | opencode.json was mutated across W5, W6, W8, and W10. | Build fragments and one opencode.next.json; perform one atomic cutover. |
| G-05 | HIGH | The roadmap allowed fs-read removal despite the approved keep-all-MCP decision. | Keep it registered; restrict triggers and support degraded mode. |
| G-06 | HIGH | MCP registry path was ambiguous between root config/ and .specs/shared/. | Use .specs/shared/mcp-registry.yaml only. |
| G-07 | CRITICAL | Global versus project-local installation topology was not fixed. | Add an installation topology task before creating skills/rules/config. |
| G-08 | CRITICAL | OpenCode version/schema was observed but not pinned for migration. | Pin runtime, schema, plugin API, and update policy. |
| G-09 | CRITICAL | Rule references in AGENTS.md had no deterministic loader contract. | Split always-loaded instructions from lazy explicit reads and record load receipts. |
| G-10 | CRITICAL | A single START risked mixing AgentSpec and Altitude semantics. | Use global dispatch START plus separate Altitude and AgentSpec START rules. |
| G-11 | HIGH | The AgentSpec Build Output Gate could be preceded by design/context reads. | Make the output-path question the first command-specific action and test tool order. |
| G-12 | CRITICAL | Parent task permissions lacked default-deny allowlisting. | Set permission.task `*` deny, then allow only approved leaves. |
| G-13 | HIGH | Built-in subagents and manual @ invocation were not governed. | Define dispositions and make manual invocation out-of-band for managed state. |
| G-14 | CRITICAL | Single-writer applied only conceptually, not across concurrent parent sessions. | Add a writer lease with stale-session recovery. |
| G-15 | HIGH | No default leaf concurrency limit existed. | Default to one active leaf; parallel work requires pre-registered independent tasks. |
| G-16 | HIGH | Leaf todowrite denial did not state that todoread is also denied. | Put complete task context in the leaf envelope and test both operations. |
| G-17 | HIGH | Skill trigger rules lacked proof that mandatory skills were loaded. | Add required_skills/loaded_skills receipts and validator checks. |
| G-18 | HIGH | Agent-to-skill conversion could lose model, steps, temperature, and provider options. | Create a model-execution parity policy. |
| G-19 | HIGH | New skills overlapped existing review/security/verification skills and tools. | Create a canonical ownership and consolidation task. |
| G-20 | CRITICAL | Existing .specs active/archive/control/index drift was deferred too late. | Repair or quarantine drift in W0 before using it as authority. |
| G-21 | HIGH | In-flight changes had no migration policy. | Classify finish-on-v1, migrate, freeze, or archive before cutover. |
| G-22 | HIGH | Machine-readable artifacts lacked a unified schema compatibility policy. | Version and validate workflow, state, task, result, memory, MCP, and verdict schemas. |
| G-23 | HIGH | Validation block size and boundaries were not predeclared. | Assign blocks in Design/Plan and immediately validate high-risk changes. |
| G-24 | HIGH | Native TODO capability and harness ledger semantics were not mapped. | Discover actual fields/statuses and use durable state for unsupported semantics. |
| G-25 | HIGH | MCP supply-chain, version, license, and immutable-source controls were absent. | Pin every server and record provenance/update/rollback. |
| G-26 | CRITICAL | MCP content could carry prompt injection or authority-changing instructions. | Treat MCP output as data, apply trust labels, redaction, and injection tests. |
| G-27 | HIGH | MCP timeouts, retries, output limits, and concurrency were not complete. | Add per-server budgets integrated with headroom. |
| G-28 | HIGH | Memory duplication lacked namespace, retention, deletion, and cross-repo isolation. | Add memory governance and isolation tests. |
| G-29 | HIGH | Runtime tests contained `if supported` and did not select an adapter. | Select one primary and one fallback adapter in W0. |
| G-30 | MEDIUM | 94 of 102 tasks were P0, so priority did not discriminate execution order. | Use explicit cutover_blocker and wave gates; retain priority only as secondary metadata. |
| G-31 | MEDIUM | Eleven task texts contained ambiguous conditional wording. | Replace each with a decision owner, trigger, or authoritative manifest. |
| G-32 | HIGH | Write-then-Copy was not atomic or failure-safe. | Add checksum, temp copy, atomic rename, and partial-copy recovery. |
| G-33 | HIGH | External absolute instruction paths reduced portability. | Vendor/normalize RTK rules and govern external-directory access. |
| G-34 | HIGH | Project-local config overrides could reintroduce unsafe agents or permissions. | Add precedence and override regression fixtures. |
| G-35 | HIGH | Cleanup and index regeneration were vague and late. | Make legacy deletion, index regeneration, and final drift scan explicit tasks. |

## Severity summary

- Critical: **12**
- High: **21**
- Medium: **2**

## Structural corrections applied in v2

- Added one independent validation task to every wave: `T-V00` through `T-V12`.
- Added prior-wave validation as an entry dependency for every subsequent wave task.
- Converted early AGENTS and configuration edits into staged artifacts.
- Moved legacy-agent deletion to post-cutover cleanup.
- Kept all requested MCPs and removed removal language.
- Selected `.specs/shared/mcp-registry.yaml` as the only MCP registry.
- Added runtime version pinning, installation topology, state-drift repair, and in-flight-change migration.
- Split global dispatch START from Altitude START and AgentSpec START.
- Added task allowlisting, built-in subagent policy, manual invocation policy, sequential default, and writer lease.
- Added skill-load receipts and model/permission parity.
- Added MCP provenance, limits, trust, authentication, and injection controls.
- Added memory namespace/retention/redaction and native TODO projection.
- Added atomic Write-then-Copy, atomic cutover bundle, config precedence tests, and final drift/index tasks.

## Revised backlog integrity

- Tasks in v2: **164**.
- Validation tasks in v2: **13**.
- Missing dependency references in v2: **0**.
- Dependency cycles in v2: **0**.

## Deterministic conclusion

Roadmap v1 should be treated as a strong architecture draft. Roadmap v2 is the execution baseline. No implementation should begin from v1 because its early live edits and premature deletions can leave the harness in a partially migrated state.