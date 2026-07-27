# OpenCode Harness — Skill-Based Migration Roadmap v2

**Status:** Revised execution baseline — pending wave-by-wave approval

## 1. Target outcome

```text
OpenCode built-in build/plan
  -> compact AGENTS kernel
  -> global dispatch START
      -> Altitude START + Altitude workflow contract
      -> AgentSpec START + AgentSpec workflow contract
  -> parent-owned TODO/state/lease
  -> mandatory skills by trigger
  -> explicit Task allowlist
  -> atomic leaf subagents
  -> independent block validation
  -> local authoritative memory + semantic MCP duplicate
```

## 2. Confirmed decisions

- **D-01:** Only built-in `build` and `plan` are primary hosts.
- **D-02:** The parent session is the only managed TODO and state writer.
- **D-03:** Leaf subagents have `task: deny` and `todowrite: deny`; they receive complete envelopes.
- **D-04:** Leaf read scope is worktree-wide by default; write scope is allocation-bounded.
- **D-05:** Recursive delegation is forbidden.
- **D-06:** Every execution task belongs to a predeclared validation block.
- **D-07:** The six dev agents become skills; legacy files are deleted only after consumer migration and cutover validation.
- **D-08:** Altitude and AgentSpec keep separate workflow contracts and START rules.
- **D-09:** Explicit `/workflow:*` names remain compatible.
- **D-10:** All requested MCPs remain in the target architecture.
- **D-11:** `.specs` is authoritative operational state; memory MCP is semantic duplication.
- **D-12:** All active runtime changes are staged and applied through one atomic cutover bundle.
- **D-13:** Parent Task permissions are default-deny with an explicit leaf allowlist.
- **D-14:** Managed delegation is sequential by default; parallelism requires independent pre-registered tasks.
- **D-15:** A writer lease prevents concurrent parent mutation of the same change.
- **D-16:** OpenCode runtime, schema, MCP packages, and plugin compatibility are pinned for migration.
- **D-17:** Only the compact kernel/global dispatch is always loaded; activity/phase rules and skills are lazy.
- **D-18:** MCP output is untrusted data unless its source is explicitly an instruction authority.

## 3. Non-negotiable invariants

1. No custom agent may be primary.
2. No managed leaf may call Task or read/write the global TODO.
3. No leaf may broaden write scope.
4. No managed delegation exists without a parent TODO ID and allocation.
5. No wave advances without its `T-Vxx` PASS.
6. No active AGENTS/config file is replaced before W12.
7. No legacy agent is deleted before all consumers are migrated and W11 passes.
8. No complex Altitude change skips Intent, Structure, or Design/Plan.
9. No AgentSpec command mutates Altitude state.
10. No MCP result may change workflow authority, permissions, TODO, scope, or state.

## 4. Revised critical path

```text
W0 -> V00 -> W1 -> V01 -> W2 -> V02 -> W3 -> V03
    -> W4 -> V04 -> W5 -> V05 -> W6 -> V06 -> W7 -> V07
    -> W8 -> V08 -> W9 -> V09 -> W10 -> V10 -> W11 -> V11
    -> W12 -> V12 -> Ship
```

## 5. Definition of Ready for any execution task

Before a roadmap item mutates files, the parent must compile it into a Task-Spec containing exact inputs, allowed/forbidden paths, required rules, required skills, allowed tools/MCPs, model/profile, verification commands, evidence, rollback, block ID, and stop conditions.

## 6. Master TODO

Only the parent may change status. Validation tasks are explicit TODO items.

### W0 — Baseline, freeze, and evidence

**Entry gate:** `None`

- [ ] **W0 | T-000 | Create migration change package | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-001 | Snapshot repository and active branch | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-002 | Resolve effective OpenCode configuration precedence | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-003 | Inventory all agent metadata | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-004 | Inventory commands, skills, contracts, and plugin enforcement | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-005 | Run and preserve baseline tests | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-006 | Define migration success metrics | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-007 | Pin OpenCode runtime, schema, and update policy | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-008 | Define global installation and path topology | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-009 | Repair existing state, archive, control, and index drift | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W0 | T-V00 | Independently validate W0 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W1 — Canonical architecture and source-of-truth decisions

**Entry gate:** `T-V00`

- [ ] **W1 | T-010 | Create ADR for built-in primary hosts | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-011 | Create ADR for single-writer TODO | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-012 | Create ADR for dual memory | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-013 | Create ADR separating AgentSpec and Altitude workflows | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-014 | Define canonical source-of-truth hierarchy | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-015 | Create file ownership and migration matrix | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-016 | Create ADR for staged activation and rule loading | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-017 | Create ADR for delegation allowlist, concurrency, and manual invocation | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-018 | Create schema and compatibility-versioning policy | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-019 | Define in-flight change migration and canonical control surface | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W1 | T-V01 | Independently validate W1 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W2 — Altitude workflow contract

**Entry gate:** `T-V01`

- [ ] **W2 | T-020 | Create Altitude workflow contract skeleton | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-021 | Define START and state-resolution contract | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-022 | Define Intent phase | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-023 | Define Structure phase | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-024 | Define Design/Plan phase | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-025 | Define Execution phase | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-026 | Define Validation phase | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-027 | Define Ship phase and archive | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-028 | Implement Altitude contract validator | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-029 | Define overrides, emergency classification, and workflow bridge prohibition | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W2 | T-V02 | Independently validate W2 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W3 — Rules layer and deterministic START

**Entry gate:** `T-V02`

- [ ] **W3 | T-030 | Create rules directory and registry | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-031 | Create START rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-032 | Create TODO ownership rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-033 | Create leaf subagent execution rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-034 | Create validation and evidence rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-035 | Create grounding rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-036 | Create CLI and tool routing rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-037 | Create MCP governance rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-038 | Create dual-memory rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-039 | Create phase rules for Altitude | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-040 | Create Altitude-specific START rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-041 | Create AgentSpec-specific START rule | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-042 | Create deterministic rule-loader contract | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-043 | Create external reference and third-party file policy | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-044 | Create required-skill activation evidence contract | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-045 | Define command overlay and gate precedence | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W3 | T-V03 | Independently validate W3 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W4 — AGENTS.md kernel rewrite

**Entry gate:** `T-V03`

- [ ] **W4 | T-050 | Design the new AGENTS.md outline | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-051 | Implement mandatory START activation | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-052 | Implement Altitude workflow activation | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-053 | Preserve AgentSpec command routing | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-054 | Implement skill trigger matrix in AGENTS.md | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-055 | Implement tool and MCP routing invariants | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-056 | Remove obsolete agent-centric references | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-057 | Add AGENTS.md structural tests | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-058 | Enforce staged kernel context budget | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-059 | Create activation manifest for staged kernel | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W4 | T-V04 | Independently validate W4 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W5 — Convert six dev agents into skills

**Entry gate:** `T-V04`

- [ ] **W5 | T-060 | Create migration parity sheets for six dev agents | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-061 | Create dev-codebase-explorer skill | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-062 | Create dev-faithfulness-guard skill | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-063 | Create dev-judge skill | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-064 | Create dev-prompt-crafter skill | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-065 | Create dev-security-guardian skill | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-066 | Create dev-shell-script-specialist skill | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-067 | Configure skill permissions and discoverability | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-068 | Validate skill parity and freeze legacy dev agents for final removal | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-069 | Resolve overlap with existing review skills and validation tools | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-070 | Define model, steps, and provider policy after agent-to-skill conversion | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-071 | Validate skill discovery in the real installation topology | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W5 | T-V05 | Independently validate W5 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W6 — Subagent-only runtime and leaf protocol

**Entry gate:** `T-V05`

- [ ] **W6 | T-080 | Classify remaining agents by role | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-081 | Stage removal of custom primary agent configuration | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-082 | Retire Altitude phase agents | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-083 | Retire Data Engineer coordinator ownership | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-084 | Create canonical leaf profiles | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-085 | Enforce leaf permissions | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-086 | Define and implement leaf result envelope | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-087 | Add recursive-delegation and scope tests | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-088 | Implement parent task allowlist and built-in subagent policy | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-089 | Implement concurrency and manual-invocation protocol | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W6 | T-V06 | Independently validate W6 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W7 — Preserve and refactor AgentSpec workflow commands

**Entry gate:** `T-V06`

- [ ] **W7 | T-090 | Create command compatibility inventory | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-091 | Create shared AgentSpec command preamble | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-092 | Refactor brainstorm, define, and design commands | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-093 | Refactor build and iterate commands | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-094 | Refactor validate and ship commands | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-095 | Refactor create-pr command and GitHub routing | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-096 | Add command compatibility test suite | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-097 | Add exact Build Output Gate regression suite | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-098 | Make Write-then-Copy atomic and recoverable | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-099 | Preserve command model and parent-session parity | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W7 | T-V07 | Independently validate W7 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W8 — MCP registry, configuration, and deterministic tool use

**Entry gate:** `T-V07`

- [ ] **W8 | T-110 | Create canonical MCP registry | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-111 | Configure Context7 | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-112 | Configure and govern CodeGraph | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-113 | Configure and govern codex-agent-mem | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-114 | Configure and govern fs-read | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-115 | Configure and govern headroom | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-116 | Configure and govern sequential-thinking | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-117 | Create MCP preflight and health-check tool | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-118 | Add MCP activation and fallback tests | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-119 | Pin MCP server provenance, versions, and licenses | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-120 | Define MCP namespaces, permissions, and tool-collision policy | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-121 | Define MCP timeout, retry, output, and concurrency budgets | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-122 | Add MCP content-trust and prompt-injection policy | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-123 | Define MCP authentication, redaction, and secret handling | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-124 | Build one staged MCP configuration fragment | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W8 | T-V08 | Independently validate W8 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W9 — TODO, state, validation, and memory integration

**Entry gate:** `T-V08`

- [ ] **W9 | T-130 | Implement parent TODO protocol | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-131 | Implement block validation scheduling | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-132 | Implement dual-write memory events | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-133 | Implement state and memory reconciliation | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-134 | Implement resume protocol | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-135 | Create audit and trace report | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-136 | Implement single-active-writer lease | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-137 | Define memory namespace, retention, redaction, and deletion | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-138 | Predeclare validation blocks and boundaries | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-139 | Map native TODO capability to harness ledger semantics | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W9 | T-V09 | Independently validate W9 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W10 — Runtime configuration and plugin refactor

**Entry gate:** `T-V09`

- [ ] **W10 | T-140 | Assemble staged opencode.next.json | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-141 | Classify plugins as keep, refactor, replace, or remove | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-142 | Refactor or remove altitude-specific plugins | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-143 | Harden specs-state and TODO enforcement | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-144 | Consolidate RTK behavior | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-145 | Consolidate headroom and context budget | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-146 | Add runtime configuration integration tests | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-147 | Consolidate existing tools with new skills and validators | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-148 | Normalize contracts, paths, and stale references | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-149 | Assemble atomic activation and rollback bundle | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W10 | T-V10 | Independently validate W10 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W11 — Regression, security, traceability, and performance validation

**Entry gate:** `T-V10`

- [ ] **W11 | T-150 | Create static architecture checks | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-151 | Test Altitude full lifecycle | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-152 | Test AgentSpec workflow compatibility | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-153 | Test TODO traceability and delegation boundaries | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-154 | Test MCP routing and degraded operation | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-155 | Perform security review | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-156 | Measure context and performance impact | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-157 | Run independent judge and faithfulness review | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-158 | Test manual subagent invocation as an out-of-band path | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-159 | Test configuration precedence and project-local overrides | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-160 | Test rule loading, receipts, and context budget | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-161 | Test pinned-version compatibility and upgrade detection | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-162 | Test in-flight change migration and resume | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-163 | Test MCP prompt injection and data-exfiltration boundaries | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-164 | Test concurrent parent sessions and writer-lease recovery | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-165 | Audit required-skill activation evidence | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W11 | T-V11 | Independently validate W11 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

### W12 — Documentation, rollout, cutover, cleanup, and ship

**Entry gate:** `T-V11`

- [ ] **W12 | T-170 | Update architecture documentation | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-171 | Create operator runbook | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-172 | Create migration and rollback guide | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-173 | Run shadow-mode pilot | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-174 | Perform controlled cutover | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-175 | Remove or archive legacy surfaces | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-176 | Finalize validation and migration scorecard | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-177 | Ship, archive, and write memory | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-178 | Execute deterministic user-acceptance scenario pack | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-179 | Run post-cutover smoke, resume, and rollback checkpoint | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-180 | Regenerate repository indexes and authority maps after cleanup | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-181 | Run final documentation-to-runtime drift scan | owner: parent-or-allocated-leaf | validator: independent-leaf-validator | status: pending**
- [ ] **W12 | T-V12 | Independently validate W12 exit gate | owner: independent-leaf-validator | validator: parent-accepts-verdict | status: pending**

## 7. Detailed tasks

### W0 — Baseline, freeze, and evidence

**Entry gate:** `None`

**Exit gate:** `T-V00` must return PASS.

#### T-000 — Create migration change package

- **Type:** discovery
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** -
- **Scope:** `.specs/changes/harness-skill-based-migration/{state.md,allocation.yaml,evidence/,tasks/}`

**Actions**

- Create a durable change package dedicated to this migration.
- Record the approved decisions D-01 through D-14.
- Set the active phase to `STRUCTURE` until the baseline is complete.
- Define allowed, forbidden, and review-only paths.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The change has a unique ID and canonical directory.
- State, allocation, evidence, and task directories exist.
- No implementation file is modified by this task.

**Evidence:** Directory tree, initial state file, allocation file, checksum of the baseline commit.

**Rollback:** Delete only the newly created change directory.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-001 — Snapshot repository and active branch

- **Type:** discovery
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-000
- **Scope:** `Repository root; .specs/changes/.../evidence/baseline/`

**Actions**

- Record current commit SHA, branch, dirty state, file inventory, and counts by surface.
- Capture `AGENTS.md`, `opencode.json`, agents, skills, commands, plugins, tools, docs, `.specs/shared`, and tests.
- Generate checksums for files that will be changed or removed.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every migration-sensitive file has a checksum.
- The baseline can identify unexpected edits during later waves.
- The snapshot contains no credentials or token values.

**Evidence:** git status/log output, inventory manifest, checksum manifest.

**Rollback:** Evidence-only task; remove generated evidence if needed.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-002 — Resolve effective OpenCode configuration precedence

- **Type:** discovery
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-001
- **Scope:** `opencode.json, opencode.jsonc, environment/config provenance report`

**Actions**

- Identify the OpenCode binary used by the TUI and CLI.
- Record HOME, XDG_CONFIG_HOME, OPENCODE_CONFIG, OPENCODE_CONFIG_DIR, working directory, and project-local config locations without exposing secret values.
- Determine which configuration files are merged and which source wins per key.
- Explain why the UI shows MCP tools while `opencode mcp list` reports none.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- One effective-config report names every active source and precedence level.
- The MCP discrepancy has a verified cause or is explicitly marked unresolved with next diagnostic commands.
- The migration does not proceed to W8 while provenance remains unknown.

**Evidence:** Sanitized environment report, binary paths/versions, effective-config diff, MCP CLI output.

**Rollback:** Read-only task.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-003 — Inventory all agent metadata

- **Type:** discovery
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-001
- **Scope:** `agents/*.agent.md; opencode.json`

**Actions**

- Extract name, description, mode, model, temperature, steps, tools, permissions, and task delegation rules.
- Flag every custom `mode: primary` declaration.
- Flag every subagent that can call `task` or `todowrite`.
- Create a specific parity record for the six `dev.*` agents being converted.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every agent is represented once in the inventory.
- Primary agents, recursive delegators, and TODO writers are explicitly listed.
- Model and permission differences are known before deletion.

**Evidence:** CSV/Markdown agent capability matrix.

**Rollback:** Read-only task.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-004 — Inventory commands, skills, contracts, and plugin enforcement

- **Type:** discovery
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-001
- **Scope:** `commands/, skills/, .specs/shared/, sdd/architecture/, plugins/, tools/`

**Actions**

- Map each workflow command to its current agent, skill, contract, model override, and subtask behavior.
- Separate AgentSpec lifecycle behavior from Altitude lifecycle behavior.
- Classify every runtime rule as hard-enforced, soft-enforced, documentation-only, or stale.
- Identify duplicate definitions and missing referenced files.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The map shows where each behavior currently lives.
- No proposed target behavior lacks an identified source or explicit new decision.
- Plugin limitations are not described as hard gates.

**Evidence:** Behavior ownership matrix and enforcement classification.

**Rollback:** Read-only task.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-005 — Run and preserve baseline tests

- **Type:** discovery
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-001
- **Scope:** `test/, .pre-commit-config.yaml, package scripts, evidence/baseline-tests/`

**Actions**

- Select one runtime-test adapter after capability discovery: CLI `opencode run`, server API, or a documented manual TUI harness.
- Run existing integration, edge-case, load, pre-commit, lint, and contract checks through the selected adapter.
- Record skipped or broken suites as explicit baseline defects.
- Capture duration and failure signatures for post-migration comparison.

**Verification**

- Run the chosen adapter against one positive and one negative fixture; preserve logs.

**Acceptance criteria**

- Exactly one primary runtime-test adapter and one fallback are recorded.
- Baseline pass/fail/skip status is reproducible.
- Known failures are distinguished from migration regressions.

**Evidence:** Test logs and summary matrix.

**Rollback:** Evidence-only task.

**v2 revision:** Removed the nondeterministic later clause `if supported` by requiring adapter selection in W0.

#### T-006 — Define migration success metrics

- **Type:** discovery
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-002,T-003,T-004,T-005
- **Scope:** `.specs/changes/.../state.md; docs migration scorecard`

**Actions**

- Define measurable outcomes for TODO traceability, subagent fan-out, context usage, validation coverage, MCP usage, and command compatibility.
- Set a zero-tolerance target for custom primary agents and recursive delegation.
- Define acceptable fallback behavior when an MCP is unavailable.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Each target has a measurement method.
- Targets include correctness, traceability, context cost, and operability.
- The scorecard can be rerun at final validation.

**Evidence:** Approved scorecard.

**Rollback:** Revert scorecard file.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-007 — Pin OpenCode runtime, schema, and update policy

- **Type:** runtime-baseline
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-002
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/runtime-version.md; staged config metadata`

**Actions**

- Record the exact OpenCode binary version, installation method, schema URL/hash, plugin API version, Node/Bun runtime, and OS.
- Select the target version used for migration validation.
- Set autoupdate to a non-mutating policy during migration, or document why the installation method controls updates externally.
- Define the compatibility window for future upgrades.

**Verification**

- Run version and config-schema checks twice from the same binary path.

**Acceptance criteria**

- One exact runtime version is the migration baseline.
- The schema snapshot/hash is recorded.
- Unexpected auto-upgrade cannot occur during cutover validation.

**Evidence:** Version command output, installation provenance, schema hash, update-policy decision.

**Rollback:** Restore the previous update policy.

**v2 revision:** Added by deterministic v2 audit.

#### T-008 — Define global installation and path topology

- **Type:** deployment-topology
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-002,T-007
- **Scope:** `.specs/changes/harness-skill-based-migration/installation-topology.md`

**Actions**

- Confirm whether the repository itself is mounted or cloned at `~/.config/opencode`.
- Resolve global versus project-local locations for AGENTS, agents, commands, skills, plugins, tools, rules, and config.
- Document symlinks, install/copy steps, working-directory assumptions, and external-directory boundaries.
- Define how a project-local AGENTS.md combines with the global harness.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every target path in the roadmap resolves from one documented root.
- Skill, command, agent, plugin, and tool discovery paths match the runtime.
- No absolute `/home/ubuntu` dependency remains without an environment-neutral replacement.

**Evidence:** Path-resolution table and discovery smoke results.

**Rollback:** Documentation-only.

**v2 revision:** Added by deterministic v2 audit.

#### T-009 — Repair existing state, archive, control, and index drift

- **Type:** state-repair
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-001,T-004
- **Scope:** `.specs/memory/active-state.md; .specs/changes/; .specs/archive/; control/; .specs/control/; kb-index.yaml`

**Actions**

- Reconcile active-state content with the real active change and phase.
- Resolve changes duplicated between active and archive storage.
- Mark one canonical control surface or record a blocking decision for W1.
- Regenerate or quarantine stale repository/KB indexes before grounding rules use them.
- Preserve evidence of every repair.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- There is one unambiguous active change state.
- No change is simultaneously active and archived without an explicit lifecycle reason.
- Stale indexes are not treated as current authority.

**Evidence:** Before/after state report, checksums, index validation, repair decisions.

**Rollback:** Restore files from T-001 checksums.

**v2 revision:** Added by deterministic v2 audit.

#### T-V00 — Independently validate W0 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-000,T-001,T-002,T-003,T-004,T-005,T-006,T-007,T-008,T-009
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w0-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W0 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W0 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W1 — Canonical architecture and source-of-truth decisions

**Entry gate:** `T-V00`

**Exit gate:** `T-V01` must return PASS.

#### T-010 — Create ADR for built-in primary hosts

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-003,T-V00
- **Scope:** `.specs/changes/.../adr/ADR-primary-hosts.md`

**Actions**

- Document why only built-in `build` and `plan` remain primary.
- Define the role of each built-in host.
- Define the rule that every custom agent must be a subagent.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- ADR is accepted and contains consequences and rollback.
- No custom primary exception remains implicit.

**Evidence:** Accepted ADR.

**Rollback:** Revert ADR status.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-011 — Create ADR for single-writer TODO

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-003,T-004,T-V00
- **Scope:** `.specs/changes/.../adr/ADR-single-writer-todo.md`

**Actions**

- Define the parent as the only TODO writer.
- Define the leaf `todo_projection` response envelope.
- Define status transition rules and blocked-task handling.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Ownership and allowed transitions are unambiguous.
- No leaf writes directly to TODO.

**Evidence:** Accepted ADR and transition table.

**Rollback:** Revert ADR status.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-012 — Create ADR for dual memory

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-002,T-004,T-V00
- **Scope:** `.specs/changes/.../adr/ADR-dual-memory.md`

**Actions**

- Define `.specs` as authoritative operational state.
- Define the memory MCP as semantic duplication and retrieval.
- Define event IDs, idempotency, retry, pending-sync state, and conflict resolution.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Authority and conflict rules are explicit.
- MCP failure cannot corrupt or block local authoritative state unless a gate explicitly requires it.

**Evidence:** Accepted ADR and event schema draft.

**Rollback:** Revert ADR status.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-013 — Create ADR separating AgentSpec and Altitude workflows

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-004,T-V00
- **Scope:** `.specs/changes/.../adr/ADR-workflow-separation.md`

**Actions**

- Keep `sdd/architecture/WORKFLOW_CONTRACTS.yaml` authoritative only for AgentSpec `/workflow:*` commands.
- Define a separate Altitude contract and activation route.
- Prohibit cross-workflow phase inference unless an explicit bridge is defined.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Each workflow has a unique contract, phase model, artifacts, gates, and entrypoints.
- The same state file cannot silently represent both lifecycles.

**Evidence:** Accepted ADR and workflow comparison matrix.

**Rollback:** Revert ADR status.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-014 — Define canonical source-of-truth hierarchy

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-010,T-011,T-012,T-013,T-V00
- **Scope:** `.specs/shared/source-of-truth-contract.md`

**Actions**

- Define precedence among user instruction, active task, allocation, Altitude contract, AgentSpec contract, artifacts, state, rules, skills, memory, MCP results, and inference.
- Define stop behavior for conflicts.
- Classify each source as current-authoritative, verification-required, historical-only, or inference-only.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every migration surface has one owning source.
- Conflict behavior is deterministic.

**Evidence:** Contract and conflict examples.

**Rollback:** Revert contract.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-015 — Create file ownership and migration matrix

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-014,T-V00
- **Scope:** `.specs/changes/.../file-migration-matrix.md`

**Actions**

- Classify files as keep, modify, create, delete, archive, or review.
- Name the target owner for every behavior moved out of an agent.
- Identify temporary compatibility states and their removal condition.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No file deletion is proposed without a target owner and parity test.
- All new files have a clear purpose and authority.

**Evidence:** Approved matrix.

**Rollback:** Revert matrix.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-016 — Create ADR for staged activation and rule loading

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-014,T-008,T-V00
- **Scope:** `.specs/changes/harness-skill-based-migration/adr/ADR-staged-activation-and-rule-loading.md`

**Actions**

- Define which instructions are always loaded and which are lazy.
- Use the OpenCode `instructions` field only for the compact kernel/global dispatch layer.
- Require explicit read of phase/activity rules because AGENTS references are not automatically expanded.
- Define staged AGENTS/config files and atomic cutover.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No glob loads all rule files permanently.
- The active runtime is unchanged until W12 cutover.
- Rule-loading failures have a deterministic stop condition.

**Evidence:** Accepted ADR and load-order diagram.

**Rollback:** Revert ADR status.

**v2 revision:** Added by deterministic v2 audit.

#### T-017 — Create ADR for delegation allowlist, concurrency, and manual invocation

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-010,T-011,T-V00
- **Scope:** `.specs/changes/harness-skill-based-migration/adr/ADR-delegation-control.md`

**Actions**

- Set parent `permission.task` to default deny with an explicit allowlist.
- Define built-in General, Explore, and Scout disposition.
- Set default concurrency to one active leaf; allow parallelism only for pre-registered independent tasks.
- Define manual `@subagent` invocation as out-of-band and unable to close managed tasks.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The parent cannot invoke an unregistered subagent.
- Every Task call references an existing parent TODO ID.
- Manual invocation cannot mutate managed state or claim validation.

**Evidence:** Accepted ADR and permission examples.

**Rollback:** Revert ADR status.

**v2 revision:** Added by deterministic v2 audit.

#### T-018 — Create schema and compatibility-versioning policy

- **Type:** architecture-decision
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-014,T-V00
- **Scope:** `.specs/shared/schema-versioning-contract.md; schemas/`

**Actions**

- Define versions and compatibility rules for workflow, state, task, allocation, leaf result, memory event, MCP registry, and validation verdict.
- Define additive, breaking, migration-required, and unsupported changes.
- Require schema validation in pre-commit and runtime tests.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every machine-readable artifact has a schema ID and version.
- Breaking changes require an explicit migration.
- Unknown versions stop mutation.

**Evidence:** Contract, schema registry, compatibility fixtures.

**Rollback:** Remove new contract/schemas.

**v2 revision:** Added by deterministic v2 audit.

#### T-019 — Define in-flight change migration and canonical control surface

- **Type:** migration-policy
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-009,T-013,T-015,T-V00
- **Scope:** `.specs/changes/harness-skill-based-migration/in-flight-migration-policy.md; control ownership decision`

**Actions**

- Classify every active change as finish-on-v1, migrate-to-v2, freeze, or archive.
- Define the migration mapping for old agent/phase references.
- Choose the canonical responsibility of root `control/` and `.specs/control/`.
- Prevent the cutover while an unmanaged active change remains.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every in-flight change has one disposition.
- Control surfaces no longer compete for the same authority.
- Cutover preflight can detect an incompatible active change.

**Evidence:** Migration matrix and control-surface decision.

**Rollback:** Restore pre-migration state from T-001.

**v2 revision:** Added by deterministic v2 audit.

#### T-V01 — Independently validate W1 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-010,T-011,T-012,T-013,T-014,T-015,T-016,T-017,T-018,T-019
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w1-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W1 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W1 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W2 — Altitude workflow contract

**Entry gate:** `T-V01`

**Exit gate:** `T-V02` must return PASS.

#### T-020 — Create Altitude workflow contract skeleton

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-013,T-014,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml`

**Actions**

- Define version, authority, ownership, lifecycle ID, state location, and invariants.
- Declare phases: intent, structure, design_plan, execution, validation, ship.
- Declare parent-only TODO/state write and forbidden recursive delegation.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- YAML parses and passes schema validation.
- The contract contains no agent identity dependency.

**Evidence:** Contract file and parser output.

**Rollback:** Remove the new contract.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-021 — Define START and state-resolution contract

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-020,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml; .specs/shared/state-resolution-contract.md`

**Actions**

- Define repository/config/state discovery before planning or execution.
- Define active change and active phase resolution.
- Define conflict stop conditions across TODO, artifacts, `.specs`, and memory MCP.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- A new session can deterministically restore or create a change.
- No phase is inferred silently when sources conflict.

**Evidence:** State-resolution scenarios.

**Rollback:** Revert contract sections.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-022 — Define Intent phase

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-021,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml; .specs/templates/intent-template.md`

**Actions**

- Define purpose, inputs, mandatory questions, outputs, non-goals, and approval gate.
- Require problem, stakeholders, constraints, success criteria, and scope confirmation.
- Define when an intent summary is sufficient versus a durable artifact.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Intent cannot exit with a critical ambiguity open.
- User confirmation evidence is required.

**Evidence:** Validated fixture for a completed Intent phase.

**Rollback:** Revert phase definition/template.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-023 — Define Structure phase

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-021,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml; .specs/templates/structure-template.md`

**Actions**

- Require on-disk structure inspection, dependency mapping, affected surfaces, source-of-truth resolution, risks, and forbidden boundaries.
- Require CodeGraph-first behavior when `.codegraph/` exists.
- Define the evidence required to confirm scope.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Structure is evidence-based rather than inferred from stale docs.
- Affected and unaffected surfaces are explicit.

**Evidence:** Structure fixture and evidence checklist.

**Rollback:** Revert phase definition/template.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-024 — Define Design/Plan phase

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-022,T-023,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml; templates for PRD/ADR/TEST-SPEC/Task-Spec`

**Actions**

- Define conditional artifact rules for PRD, ADR, TEST-SPEC, task pack, and allocation.
- Require atomic leaf tasks, acceptance criteria, verification, evidence, do-not-touch boundaries, and rollback.
- Require user approval for the task or batch selected for execution.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No generic execution task is considered ready.
- A task needing another specialist is rejected as non-atomic.

**Evidence:** Ready-task fixture and rejection fixtures.

**Rollback:** Revert phase definition.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-025 — Define Execution phase

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-024,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml; execution-loop and allocation contracts`

**Actions**

- Define parent orchestration and leaf execution envelopes.
- Require broad-read/bounded-write, no recursive task, no leaf TODO, no silent scope expansion.
- Define local checks, evidence, and result envelope.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Leaf behavior is bounded and deterministic.
- The parent can update TODO from a structured result without reading a child session's private state.

**Evidence:** Execution contract fixtures.

**Rollback:** Revert phase definition.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-026 — Define Validation phase

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-025,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml; validation contract/template`

**Actions**

- Define executor local checks and independent block validation.
- Require acceptance, scope, faithfulness, security-when-triggered, evidence, and rollback review.
- Define pass, fail, blocked, and accepted-gap outcomes.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- A block cannot close without independent validation.
- Validation failure routes back to execution with a remediation task.

**Evidence:** Pass/fail/block fixtures.

**Rollback:** Revert phase definition.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-027 — Define Ship phase and archive

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-026,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml; ship-summary template; archive rules`

**Actions**

- Define final report, residual risks, decisions, lessons, rollback reference, memory checkpoint, and archive movement.
- Require state reconciliation before archive.
- Define when follow-up changes are created rather than hidden in the shipped change.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Shipped state is internally consistent and recoverable.
- No active and archived duplicate remains without an explicit reason.

**Evidence:** Ship fixture and archive check.

**Rollback:** Restore change from archive using documented procedure.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-028 — Implement Altitude contract validator

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-020,T-021,T-022,T-023,T-024,T-025,T-026,T-027,T-V01
- **Scope:** `tools/altitude-workflow-check.sh; tools/altitude-workflow-check.contract.md; test/contracts/altitude-workflow/`

**Actions**

- Validate required contract fields, phase IDs, transitions, gates, and referenced files.
- Detect missing templates, invalid transitions, duplicate authority, and nonexistent rules.
- Add a pre-commit or CI-compatible check.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Invalid contract fixtures fail with actionable messages.
- The canonical contract passes.

**Evidence:** Tool output and test results.

**Rollback:** Remove validator and hook.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-029 — Define overrides, emergency classification, and workflow bridge prohibition

- **Type:** workflow-contract
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-021,T-024,T-013,T-V01
- **Scope:** `.specs/shared/altitude-workflow-contract.yaml; .specs/shared/workflow-bridge-policy.md`

**Actions**

- Prohibit phase skipping for complex work.
- Classify truly tactical work before Altitude rather than treating it as an emergency phase override.
- Define the only allowed repair transitions.
- Prohibit automatic phase/state mapping between AgentSpec and Altitude.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every legal transition is enumerated.
- Complex execution cannot bypass Intent, Structure, or Design/Plan.
- AgentSpec commands cannot advance Altitude state.

**Evidence:** Transition table and negative fixtures.

**Rollback:** Revert contract/policy changes.

**v2 revision:** Added by deterministic v2 audit.

#### T-V02 — Independently validate W2 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-020,T-021,T-022,T-023,T-024,T-025,T-026,T-027,T-028,T-029
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w2-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W2 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W2 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W3 — Rules layer and deterministic START

**Entry gate:** `T-V02`

**Exit gate:** `T-V03` must return PASS.

#### T-030 — Create rules directory and registry

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-028,T-V02
- **Scope:** `rules/README.md; rules/ACTIVITY_RULE_INDEX.md`

**Actions**

- Create a canonical registry listing each rule, trigger, owner, required skills, required MCPs, and fallback.
- Prohibit duplicate canonical behavior across rules.
- Mark always-required versus on-demand rules.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every rule has one trigger and one owner.
- The index can be statically checked against real files.

**Evidence:** Rule registry.

**Rollback:** Remove new rule files.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-031 — Create START rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-021,T-030,T-V02
- **Scope:** `rules/START.md`

**Actions**

- Define root/config discovery, request classification, state resolution, active workflow, active phase, rule selection, skill selection, MCP preflight, TODO restoration, and conflict handling.
- Require the parent to run START before any non-trivial planning, file mutation, or delegation.
- Define a lightweight path for small direct answers.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- START is deterministic and does not preload the entire harness.
- All stop conditions are explicit.

**Evidence:** START scenario tests.

**Rollback:** Remove rule.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-032 — Create TODO ownership rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-011,T-030,T-V02
- **Scope:** `rules/TODO_OWNERSHIP.md`

**Actions**

- Define parent-only creation, update, close, reopen, and block operations.
- Define stable IDs for blocks, tasks, and validation tasks.
- Define `todo_projection` acceptance and rejection.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- There is no legal leaf path to direct TODO mutation.
- Status transitions are auditable.

**Evidence:** Rule plus transition tests.

**Rollback:** Remove rule.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-033 — Create leaf subagent execution rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-025,T-032,T-V02
- **Scope:** `rules/SUBAGENT_EXECUTION.md`

**Actions**

- Define atomic-task eligibility and the exact prompt envelope.
- Require task ID, goal, inputs, allowed writes, forbidden paths, required skills, required tools, verification, evidence, and stop conditions.
- Require immediate return to the parent if a second specialty or write expansion is needed.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- A leaf receives one verifiable unit of work.
- Nested delegation is explicitly forbidden and tested.

**Evidence:** Prompt template and fixtures.

**Rollback:** Remove rule.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-034 — Create validation and evidence rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-026,T-032,T-033,T-V02
- **Scope:** `rules/VALIDATION_EVIDENCE.md`

**Actions**

- Define local checks, independent block validation, evidence quality, and accepted-gap rules.
- Require a separate validation TODO item for each block.
- Define judge, faithfulness, and security skill triggers.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Evidence required for each verdict is explicit.
- The validator cannot validate its own implementation output.

**Evidence:** Validation templates and tests.

**Rollback:** Remove rule.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-035 — Create grounding rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-014,T-030,T-V02
- **Scope:** `rules/GROUNDING.md`

**Actions**

- Define current on-disk files as primary implementation evidence.
- Require CodeGraph when available for structural code questions.
- Require Context7 or official docs for unstable library/API claims.
- Require citations or explicit `source not found` for architectural claims.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Grounding order is deterministic.
- Stale indexes and prose cannot override current files.

**Evidence:** Grounding decision fixtures.

**Rollback:** Remove rule.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-036 — Create CLI and tool routing rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-030,T-V02
- **Scope:** `rules/TOOL_ROUTING.md; rules/RTK_AND_SHELL.md`

**Actions**

- Require `gh` for GitHub operations and `git` for local repository operations.
- Require `gcloud` for Google Cloud, `aws` for AWS, `kubectl` for Kubernetes, and `docker` for Docker when applicable.
- Prefix shell commands with `rtk` by default; allow raw commands for debugging or unsupported output.
- Define preferred search/read order and safe command chains.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Tool choice is based on target system, not model improvisation.
- RTK exceptions are documented and bounded.

**Evidence:** Routing fixtures and command examples.

**Rollback:** Remove rules.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-037 — Create MCP governance rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-002,T-030,T-035,T-036,T-V02
- **Scope:** `rules/MCP_GOVERNANCE.md; .specs/shared/mcp-governance.md`

**Actions**

- Define required registry fields, activation triggers, health check, context cost, authority, fallback, and forbidden uses.
- Include Context7, CodeGraph, codex-agent-mem, fs-read, headroom, and sequential-thinking.
- Define behavior when the UI and CLI disagree about availability.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Each MCP has a deterministic trigger and fallback.
- Unavailable MCPs do not cause fabricated results.

**Evidence:** MCP decision matrix.

**Rollback:** Remove/revert rule.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-038 — Create dual-memory rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-012,T-030,T-037,T-V02
- **Scope:** `rules/MEMORY_DUAL_WRITE.md`

**Actions**

- Define local write first, MCP duplicate second.
- Define event IDs, pending sync, retry, deduplication, reconciliation, and read authority.
- Define what must never be stored in semantic memory.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Local state remains authoritative.
- A failed MCP write is visible and retryable rather than silent.

**Evidence:** Memory event fixtures.

**Rollback:** Remove rule.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-039 — Create phase rules for Altitude

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-028,T-030,T-031,T-032,T-033,T-034,T-035,T-036,T-037,T-038,T-V02
- **Scope:** `rules/altitude/{INTENT,STRUCTURE,DESIGN_PLAN,EXECUTION,VALIDATION,SHIP,TRANSITIONS}.md`

**Actions**

- Create one operational rule per contract phase.
- Reference the canonical YAML contract rather than duplicating it.
- Define minimum reads, required skills, tools, outputs, evidence, and gates for each phase.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Each rule matches the contract.
- Phase behavior can be loaded independently.

**Evidence:** Rule-contract consistency check.

**Rollback:** Remove phase rules.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-040 — Create Altitude-specific START rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-031,T-029,T-V02
- **Scope:** `rules/altitude/START.md`

**Actions**

- Resolve active Altitude change, phase, artifacts, allocation, TODO projection, writer lease, and phase rule.
- Stop on state conflict or incompatible in-flight change.
- Load only the rule and skills required by the resolved phase.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Altitude START cannot run for an explicit AgentSpec command.
- A new and a resumed Altitude change produce deterministic state.

**Evidence:** New/resume/conflict fixtures.

**Rollback:** Remove rule.

**v2 revision:** Added by deterministic v2 audit.

#### T-041 — Create AgentSpec-specific START rule

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-031,T-013,T-V02
- **Scope:** `rules/agentspec/START.md`

**Actions**

- Resolve the explicit `/workflow:*` command and AgentSpec contract only.
- Preserve Write-then-Copy and phase artifact prerequisites.
- For `/workflow:build`, ask the output path before loading DESIGN or other design context.
- Do not read or mutate Altitude state.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- AgentSpec START preserves command-specific Step 0 ordering.
- No Altitude contract or phase file is loaded.

**Evidence:** Command-start ordering fixtures.

**Rollback:** Remove rule.

**v2 revision:** Added by deterministic v2 audit.

#### T-042 — Create deterministic rule-loader contract

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-016,T-030,T-031,T-V02
- **Scope:** `.specs/shared/rule-loading-contract.md; rules/RULE_LOADING.md`

**Actions**

- Define always-loaded kernel files, lazy rule references, recursion limits, missing-file behavior, and precedence.
- Require a load receipt listing rule IDs and versions.
- Reject broad preloading and stale references.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every non-trivial task has a rule-load receipt.
- Missing mandatory rule stops execution.
- Context loading remains within the configured budget.

**Evidence:** Rule-loader contract and load-receipt fixtures.

**Rollback:** Remove contract/rule.

**v2 revision:** Added by deterministic v2 audit.

#### T-043 — Create external reference and third-party file policy

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-008,T-035,T-036,T-V02
- **Scope:** `rules/EXTERNAL_REFERENCES.md; rules/RTK_AND_SHELL.md`

**Actions**

- Vendor or normalize the required RTK instructions into the harness rules with source provenance.
- Define when external-directory permission is allowed.
- Require checksums or version references for third-party instruction files.
- Prohibit hard-coded home-directory paths in canonical rules.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The harness works for a different Linux username/home path.
- External files cannot silently override higher-priority contracts.
- RTK behavior has one canonical local rule.

**Evidence:** Portability fixture and provenance record.

**Rollback:** Restore previous rule references.

**v2 revision:** Added by deterministic v2 audit.

#### T-044 — Create required-skill activation evidence contract

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-030,T-033,T-034,T-V02
- **Scope:** `.specs/shared/required-skills-contract.md; leaf result schema`

**Actions**

- Add `required_skills` and `loaded_skills` to task and leaf-result envelopes.
- Define missing-skill behavior.
- Require validator checks for trigger-mandatory skills.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- A task requiring a skill cannot be marked complete without a matching load receipt.
- Non-trigger tasks are not forced to load unrelated skills.

**Evidence:** Schema and positive/negative fixtures.

**Rollback:** Remove fields and fixtures.

**v2 revision:** Added by deterministic v2 audit.

#### T-045 — Define command overlay and gate precedence

- **Type:** rule
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-041,T-042,T-V02
- **Scope:** `.specs/shared/command-overlay-contract.md`

**Actions**

- Define precedence between global kernel, workflow START, command frontmatter/template, AgentSpec contract, activity rules, and skills.
- Make the `/workflow:build` output gate the first command-specific action.
- Prevent commands from weakening parent-only TODO or leaf delegation restrictions.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Command-specific rules can become stricter but not bypass global safety/ownership rules.
- Build output gate ordering is explicit and testable.

**Evidence:** Precedence table and conflict fixtures.

**Rollback:** Remove contract.

**v2 revision:** Added by deterministic v2 audit.

#### T-V03 — Independently validate W3 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-030,T-031,T-032,T-033,T-034,T-035,T-036,T-037,T-038,T-039,T-040,T-041,T-042,T-043,T-044,T-045
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w3-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W3 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W3 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W4 — AGENTS.md kernel rewrite

**Entry gate:** `T-V03`

**Exit gate:** `T-V04` must return PASS.

#### T-050 — Design the new AGENTS.md outline

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-039,T-V03
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/AGENTS.next.md`

**Actions**

- Define sections for START, workflow selection, source hierarchy, TODO ownership, delegation, validation, skills, tools/MCPs, context loading, conflicts, and references.
- Keep detailed procedures in rules and contracts.
- Set a size target and remove stale path assumptions.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The outline covers all invariants without becoming an encyclopedia.
- Every detailed rule has a canonical reference.

**Evidence:** Reviewed outline.

**Rollback:** Discard draft.

**v2 revision:** Changed from an active AGENTS.md edit to a staged draft. Active cutover occurs only in W12.

#### T-051 — Implement mandatory START activation

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-050,T-V03
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/AGENTS.next.md; related staged rule index`

**Actions**

- Require START for non-trivial work and `/workflow:*` commands.
- Require reading `rules/START.md` and the activity index.
- Define the small direct-answer exception.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- A fixture shows START occurs before planning, mutation, or delegation.
- The exception cannot be used for multi-step mutation.

**Evidence:** AGENTS fixture test.

**Rollback:** Restore baseline AGENTS.md.

**v2 revision:** All W4 AGENTS work is staged. It must not alter the active global kernel before skills, commands, permissions, and MCP configuration are ready.

#### T-052 — Implement Altitude workflow activation

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-051,T-V03
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/AGENTS.next.md; related staged rule index`

**Actions**

- Classify durable, architectural, multi-step, migration, governance, cross-file, and high-risk work as Altitude.
- Require the Altitude contract and current phase rule.
- Do not mention Altitude as an agent invocation.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Natural-language strategic work enters Altitude without a custom primary agent.
- The lifecycle gate is not bypassed silently.

**Evidence:** Routing fixtures.

**Rollback:** Restore baseline AGENTS.md.

**v2 revision:** All W4 AGENTS work is staged. It must not alter the active global kernel before skills, commands, permissions, and MCP configuration are ready.

#### T-053 — Preserve AgentSpec command routing

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-013,T-051,T-V03
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/AGENTS.next.md; related staged rule index`

**Actions**

- Route explicit `/workflow:*` commands to AgentSpec command behavior.
- Reference `sdd/architecture/WORKFLOW_CONTRACTS.yaml` only for AgentSpec.
- Define no automatic mapping from AgentSpec phases to Altitude phases.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- AgentSpec commands remain callable and distinct.
- A command does not mutate Altitude state unless an explicit bridge task is approved.

**Evidence:** Dual-workflow routing tests.

**Rollback:** Restore baseline AGENTS.md.

**v2 revision:** All W4 AGENTS work is staged. It must not alter the active global kernel before skills, commands, permissions, and MCP configuration are ready.

#### T-054 — Implement skill trigger matrix in AGENTS.md

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-030,T-035,T-036,T-V03
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/AGENTS.next.md; related staged rule index`

**Actions**

- Require codebase-explorer for repository/architecture discovery.
- Require faithfulness-guard for grounded claims and final factual checks.
- Require judge for block/final validation.
- Require prompt-crafter for prompt/agent/skill/command instruction changes.
- Require security-guardian for auth, secrets, PII, permissions, shell risk, and supply chain changes.
- Require shell-script-specialist for shell, CI, hooks, and operational script changes.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All six skills have explicit use and non-use triggers.
- Commands can add stricter requirements.

**Evidence:** Trigger matrix tests.

**Rollback:** Restore baseline AGENTS.md.

**v2 revision:** All W4 AGENTS work is staged. It must not alter the active global kernel before skills, commands, permissions, and MCP configuration are ready.

#### T-055 — Implement tool and MCP routing invariants

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-036,T-037,T-V03
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/AGENTS.next.md; related staged rule index`

**Actions**

- Require rule loading before external tool use.
- Require `gh`, `git`, `gcloud`, Context7, CodeGraph, memory, headroom, and RTK according to triggers.
- Define fallback and explicit disclosure when a required MCP is unavailable.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Tool choice is observable in test transcripts.
- No MCP availability is assumed without preflight.

**Evidence:** Tool-routing fixtures.

**Rollback:** Restore baseline AGENTS.md.

**v2 revision:** All W4 AGENTS work is staged. It must not alter the active global kernel before skills, commands, permissions, and MCP configuration are ready.

#### T-056 — Remove obsolete agent-centric references

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-052,T-053,T-054,T-055,T-V03
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/AGENTS.next.md; related staged rule index`

**Actions**

- Remove direct routing to the six converted `dev.*` agents.
- Remove coordinator-owned lifecycle wording for Altitude and Data Engineer.
- Replace stale tool/agent references with rules, skills, contracts, or verified runtime tools.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No removed agent is referenced.
- No documented hard gate points to a no-op runtime surface without disclosure.

**Evidence:** Reference scan.

**Rollback:** Restore baseline AGENTS.md.

**v2 revision:** All W4 AGENTS work is staged. It must not alter the active global kernel before skills, commands, permissions, and MCP configuration are ready.

#### T-057 — Add AGENTS.md structural tests

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-056,T-V03
- **Scope:** `test/fixtures/harness-v3/staging-agents/; test/static/`

**Actions**

- Validate required sections and canonical references in `AGENTS.next.md`.
- Check that every referenced artifact is either present or declared in the activation manifest.
- Reject removed agent names, custom-primary wording, and broad instructions globs.
- Do not activate the staged file.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The staged kernel passes structural checks.
- Planned-but-not-yet-created references are tracked in the activation manifest, not silently ignored.
- The active AGENTS.md remains unchanged in W4.

**Evidence:** Test output.

**Rollback:** Remove tests.

**v2 revision:** Prevents W4 from breaking the current runtime before W5-W10 complete.

#### T-058 — Enforce staged kernel context budget

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-057,T-042,T-V03
- **Scope:** `test/static/agents-context-budget.*; staged AGENTS.next.md`

**Actions**

- Measure the always-loaded kernel and instruction payload.
- Set a maximum size and fail the staged kernel when exceeded.
- Confirm phase, skill, and MCP details remain lazy.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The staged kernel remains under the approved context budget.
- No complete skill or phase contract is duplicated in AGENTS.next.md.

**Evidence:** Context-size report and static check.

**Rollback:** Remove test or restore draft.

**v2 revision:** Added by deterministic v2 audit.

#### T-059 — Create activation manifest for staged kernel

- **Type:** staged-kernel
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** S
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-057,T-058,T-V03
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/activation-manifest.yaml`

**Actions**

- List every staged file, expected final path, checksum, dependency, and activation order.
- Record expected deleted/disabled legacy files.
- Require manifest validation before cutover.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every staged file has one final path and checksum.
- No activation step relies on an implicit file.

**Evidence:** Validated activation manifest.

**Rollback:** Remove manifest.

**v2 revision:** Added by deterministic v2 audit.

#### T-V04 — Independently validate W4 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-050,T-051,T-052,T-053,T-054,T-055,T-056,T-057,T-058,T-059
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w4-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W4 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W4 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W5 — Convert six dev agents into skills

**Entry gate:** `T-V04`

**Exit gate:** `T-V05` must return PASS.

#### T-060 — Create migration parity sheets for six dev agents

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-003,T-054,T-V04
- **Scope:** `agents/dev.*.agent.md; .specs/changes/.../evidence/dev-skill-parity/`

**Actions**

- Extract prompt behavior, model, permissions, tools, stop conditions, output formats, and quality gates.
- Separate reusable procedural knowledge from agent-runtime configuration.
- Record behavior that must move to rules, skills, leaf profiles, or tests.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Each source line of meaningful behavior has a target owner or explicit removal decision.
- No model/permission difference is lost silently.

**Evidence:** Six parity sheets.

**Rollback:** Evidence-only.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-061 — Create dev-codebase-explorer skill

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-060,T-V04
- **Scope:** `skills/dev-codebase-explorer/SKILL.md; skills/dev-codebase-explorer/references/`

**Actions**

- Convert exploration protocol, evidence discipline, output contract, and quality gate.
- Replace generic glob-first behavior with CodeGraph-first when indexed.
- Remove agent permissions, recursive task ability, and autonomous edits.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Skill frontmatter is valid and name matches directory.
- Skill can be loaded by build, plan, and leaf profiles.
- Exploration cites real files and does not edit by default.

**Evidence:** Skill validation and exploration fixture.

**Rollback:** Remove new skill.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-062 — Create dev-faithfulness-guard skill

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-060,T-V04
- **Scope:** `skills/dev-faithfulness-guard/SKILL.md`

**Actions**

- Convert evidence comparison, contradiction detection, confidence, and source reporting.
- Define use before architecture claims, block validation, and final reports.
- Define clear pass/warn/fail outputs.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Skill distinguishes verified fact, inference, and unsupported claim.
- It cannot mutate implementation files.

**Evidence:** Faithfulness fixtures.

**Rollback:** Remove new skill.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-063 — Create dev-judge skill

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-060,T-V04
- **Scope:** `skills/dev-judge/SKILL.md`

**Actions**

- Convert scoring, acceptance evaluation, evidence sufficiency, and verdict format.
- Make the skill mandatory for independent block validation and final validation.
- Prohibit self-validation by the executor.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Verdict is deterministic and evidence-linked.
- Fail and blocked outcomes produce remediation guidance, not silent acceptance.

**Evidence:** Judge fixtures.

**Rollback:** Remove new skill.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-064 — Create dev-prompt-crafter skill

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-060,T-V04
- **Scope:** `skills/dev-prompt-crafter/SKILL.md`

**Actions**

- Convert prompt analysis, instruction hierarchy, ambiguity checks, examples, and test design.
- Add specific coverage for AGENTS, commands, skills, agents, and workflow rules.
- Require prompt regression fixtures.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Prompt changes have explicit intent, constraints, anti-patterns, and tests.
- The skill does not override higher-priority contracts.

**Evidence:** Prompt fixtures.

**Rollback:** Remove new skill.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-065 — Create dev-security-guardian skill

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-060,T-V04
- **Scope:** `skills/dev-security-guardian/SKILL.md; security references`

**Actions**

- Convert threat checks, secret handling, auth/permission review, command safety, and supply-chain checks.
- Define advisory versus blocking conditions.
- Integrate with shell/CLI and MCP configuration changes.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Security triggers are explicit and testable.
- Secrets are never copied into evidence or memory.
- Critical findings block the gate.

**Evidence:** Security fixtures.

**Rollback:** Remove new skill.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-066 — Create dev-shell-script-specialist skill

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-060,T-V04
- **Scope:** `skills/dev-shell-script-specialist/SKILL.md`

**Actions**

- Convert safe shell authoring, strict mode, quoting, portability, linting, error handling, and test rules.
- Integrate RTK use while preserving raw-command debugging exceptions.
- Require shellcheck or documented fallback.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Shell changes have lint/test evidence.
- Dangerous or destructive commands require explicit scope and confirmation.

**Evidence:** Shell fixtures.

**Rollback:** Remove new skill.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-067 — Configure skill permissions and discoverability

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-061,T-062,T-063,T-064,T-065,T-066,T-V04
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.skills.fragment.json; skill registry tests`

**Actions**

- Allow the six skills for built-in hosts and permitted leaf profiles.
- Ensure names are unique and valid.
- Hide or deny skills from profiles that should not use them.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All six appear in the skill tool where expected.
- No duplicate or invalid name exists.
- Permission-denied profiles cannot load them.

**Evidence:** Skill listing and permission tests.

**Rollback:** Revert config changes.

**v2 revision:** Skill permissions are staged rather than written to active opencode.json.

#### T-068 — Validate skill parity and freeze legacy dev agents for final removal

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-067,T-V04
- **Scope:** `agents/dev.codebase-explorer.agent.md; dev.faithfulness-guard; dev.judge-agent; dev.prompt-crafter; dev.security-guardian; dev.shell-script-specialist`

**Actions**

- Run source-agent versus skill behavior fixtures with fixed inputs and scoring.
- Confirm model, steps, temperature, tool, and permission behavior has an explicit target owner.
- Mark the six legacy agent files as `frozen` in the migration manifest.
- Do not delete them until every consumer has been migrated and W11 validation passes.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Six parity reports pass or have an explicit blocking defect.
- No new reference to the legacy agents is allowed.
- The legacy files still exist only as rollback assets until W12 cleanup.

**Evidence:** Parity report, reference scan, git diff.

**Rollback:** Remove the freeze marker; no runtime file is deleted in this task.

**v2 revision:** Fixes premature deletion before command and consumer migration.

#### T-069 — Resolve overlap with existing review skills and validation tools

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-060,T-004,T-V04
- **Scope:** `skills/review/; tools/faithfulness_gate.ts; tools/verify_step.ts; tools/security-scan.*; tools/junta-auditor.*`

**Actions**

- Compare existing review/verification/security behavior with the six new skills.
- Assign one canonical owner per behavior.
- Merge, reference, or deprecate duplicates without losing fixtures.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No two skills/tools claim the same canonical gate.
- Existing useful tool logic is retained behind a clear contract.

**Evidence:** Behavior overlap matrix and disposition decisions.

**Rollback:** Revert consolidation decisions.

**v2 revision:** Added by deterministic v2 audit.

#### T-070 — Define model, steps, and provider policy after agent-to-skill conversion

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-003,T-060,T-069,T-V04
- **Scope:** `.specs/shared/model-execution-policy.md; leaf profile manifest`

**Actions**

- Map every removed agent model, temperature, steps, provider options, and tool permission to a retained profile or parent host.
- Define deterministic settings for validators and security-sensitive work.
- Define inheritance when no override is needed.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No removed agent runtime setting is lost silently.
- Each leaf profile has a model/steps policy or explicit parent inheritance.

**Evidence:** Model parity matrix and approved policy.

**Rollback:** Revert policy.

**v2 revision:** Added by deterministic v2 audit.

#### T-071 — Validate skill discovery in the real installation topology

- **Type:** skill-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-061,T-062,T-063,T-064,T-065,T-066,T-008,T-V04
- **Scope:** `skills/*/SKILL.md; installation fixture`

**Actions**

- Validate directory/name/frontmatter rules.
- Start OpenCode from representative working directories.
- Confirm all six skills are visible to build, plan, and approved leaf profiles.
- Confirm denied profiles cannot see restricted skills.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All six skills appear from the real global config root.
- Skill names are unique across all discovered locations.
- Permission behavior matches the staged matrix.

**Evidence:** Skill tool listings and permission logs.

**Rollback:** Restore prior skill locations/config.

**v2 revision:** Added by deterministic v2 audit.

#### T-V05 — Independently validate W5 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-060,T-061,T-062,T-063,T-064,T-065,T-066,T-067,T-068,T-069,T-070,T-071
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w5-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W5 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W5 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W6 — Subagent-only runtime and leaf protocol

**Entry gate:** `T-V05`

**Exit gate:** `T-V06` must return PASS.

#### T-080 — Classify remaining agents by role

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-003,T-068,T-V05
- **Scope:** `agents/*.agent.md; opencode.json`

**Actions**

- Classify each agent as domain specialist, validator, obsolete coordinator, obsolete phase agent, duplicate, or unrelated keep.
- Identify agents that contain reusable skill knowledge rather than runtime specialization.
- Create a staged delete/convert/keep list.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every agent has a disposition.
- No coordinator is retained accidentally.

**Evidence:** Agent disposition matrix.

**Rollback:** Read-only.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-081 — Stage removal of custom primary agent configuration

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-080,T-V05
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.agents.fragment.json; coordinator agent manifest`

**Actions**

- Remove custom primary coordinators from the staged configuration only.
- Set built-in `build` and `plan` as the only selectable primary hosts in the staged configuration.
- Keep the active configuration unchanged until controlled cutover.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Static scan of the staged configuration finds zero custom `mode: primary` entries.
- The active configuration remains available for rollback.

**Evidence:** Config diff and runtime agent list.

**Rollback:** Restore baseline agent config.

**v2 revision:** Converted live mutation into staged mutation.

#### T-082 — Retire Altitude phase agents

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-039,T-081,T-V05
- **Scope:** `agents/altitude-*.agent.md; rules/altitude/; contracts`

**Actions**

- Move unique phase behavior into the Altitude contract/rules/skills.
- Run reference and behavior coverage checks.
- Delete or archive phase-agent files according to the migration matrix.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Altitude lifecycle works without invoking an altitude agent.
- No unique rule is lost.

**Evidence:** Parity map and lifecycle fixtures.

**Rollback:** Restore phase-agent files.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-083 — Retire Data Engineer coordinator ownership

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** no
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-081,T-V05
- **Scope:** `agents/data-engineer.agent.md; data skills/rules/commands`

**Actions**

- Move tactical classification and workflow rules into data-engineering skills/rules.
- Keep domain specialists as subagents where model isolation or tool permissions add value.
- Remove coordinator state/TODO ownership.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Tactical data tasks use the built-in parent plus skills and leaf specialists.
- No second TODO owner remains.

**Evidence:** Tactical routing fixtures.

**Rollback:** Restore coordinator file/config.

**v2 revision:** Raised to P0 because D-01 forbids all custom primary coordinators, including Data Engineer.

#### T-084 — Create canonical leaf profiles

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-060,T-080,T-V05
- **Scope:** `agents/leaf-readonly.agent.md; agents/leaf-executor.agent.md; agents/leaf-validator.agent.md`

**Actions**

- Create exactly three hidden internal subagent profiles: read-only discovery, bounded-write execution, and independent validation.
- Keep domain specialists as subagents only when W6 inventory proves unique model/tool value.
- Keep procedural behavior in skills rather than duplicating it in profile prompts.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Exactly three generic permission profiles exist.
- Every retained domain specialist maps to one permission archetype.
- No profile duplicates a complete skill procedure.

**Evidence:** Agent definitions and tests.

**Rollback:** Remove profiles.

**v2 revision:** Removed `or equivalent` ambiguity and fixed the profile strategy.

#### T-085 — Enforce leaf permissions

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-084,T-V05
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.permissions.fragment.json; leaf agent frontmatter`

**Actions**

- Set `task: deny` and `todowrite: deny` for every leaf executor and validator.
- Treat `todowrite: deny` as denial of both TODO write and TODO read; provide all task context in the leaf envelope.
- Deny publication and uncontrolled scope changes.
- Apply least privilege to edit, bash, external directories, skills, and MCP tools.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Leaf task invocation fails.
- Leaf TODO write and TODO read fail.
- Leaf can complete an allocated task from its explicit envelope.
- Forbidden Git publication and scope expansion are blocked or returned to the parent.

**Evidence:** Negative permission tests.

**Rollback:** Restore previous permissions.

**v2 revision:** Adds the missing `todoread` consequence and stages the configuration.

#### T-086 — Define and implement leaf result envelope

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-033,T-085,T-V05
- **Scope:** `.specs/shared/leaf-result-contract.md; rules/SUBAGENT_EXECUTION.md; templates`

**Actions**

- Define task ID, status projection, summary, files read/changed, commands, tests, evidence, risks, blockers, and scope-expansion request.
- Require machine-checkable mandatory fields.
- Define parent acceptance and rejection logic.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Parent can update TODO and evidence from the envelope.
- Missing evidence prevents done status.

**Evidence:** Schema and fixture tests.

**Rollback:** Remove contract/template.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-087 — Add recursive-delegation and scope tests

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-085,T-086,T-V05
- **Scope:** `test/integration/; test/edge-cases/`

**Actions**

- Test that a leaf cannot invoke task.
- Test that a leaf cannot write TODO.
- Test that a non-atomic task returns to the parent.
- Test that write scope expansion is requested rather than executed.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All negative tests pass.
- Failure messages are actionable.

**Evidence:** Integration logs.

**Rollback:** Remove tests.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-088 — Implement parent task allowlist and built-in subagent policy

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-017,T-084,T-085,T-V05
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.permissions.fragment.json`

**Actions**

- Set parent task permission to `* = deny` followed by explicit allowed leaf patterns.
- Decide General, Explore, and Scout use individually.
- Remove denied subagents from the Task tool description.
- Require an existing TODO/task ID in every managed delegation prompt.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Unknown and denied subagents are absent from the parent Task tool.
- Only approved leaf profiles and retained specialists can be invoked.
- Delegation without a registered task ID is rejected by policy/test.

**Evidence:** Task-tool listing and negative permission tests.

**Rollback:** Restore staged permission fragment.

**v2 revision:** Added by deterministic v2 audit.

#### T-089 — Implement concurrency and manual-invocation protocol

- **Type:** runtime-permission
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-017,T-086,T-088,T-V05
- **Scope:** `rules/SUBAGENT_EXECUTION.md; .specs/shared/delegation-runtime-contract.md; tests`

**Actions**

- Allow one active managed leaf by default.
- Allow parallel leaves only when the parent pre-registers independent TODOs, allocations, and merge order.
- Require the parent to update TODO immediately after each leaf returns and before the next sequential delegation.
- Treat direct manual `@subagent` work as read-only/out-of-band for managed changes.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Sequential mode never has two active leaves.
- Parallel mode has explicit independent task IDs and no shared write scope.
- Manual invocation cannot close or validate a managed task.

**Evidence:** Concurrency and manual-invocation fixtures.

**Rollback:** Revert contract/rule changes.

**v2 revision:** Added by deterministic v2 audit.

#### T-V06 — Independently validate W6 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-080,T-081,T-082,T-083,T-084,T-085,T-086,T-087,T-088,T-089
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w6-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W6 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W6 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W7 — Preserve and refactor AgentSpec workflow commands

**Entry gate:** `T-V06`

**Exit gate:** `T-V07` must return PASS.

#### T-090 — Create command compatibility inventory

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-004,T-013,T-V06
- **Scope:** `commands/workflow:*.md; skills/workflow-commands/; sdd/architecture/WORKFLOW_CONTRACTS.yaml`

**Actions**

- Record current frontmatter, agent, model, subtask behavior, inputs, outputs, and artifact paths.
- Define compatibility expectations for brainstorm, define, design, build, iterate, validate, ship, and create-pr.
- Identify command behavior currently hidden in workflow agents.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every command has a compatibility contract.
- No command behavior is assumed from name alone.

**Evidence:** Command matrix.

**Rollback:** Read-only.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-091 — Create shared AgentSpec command preamble

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-031,T-090,T-V06
- **Scope:** `skills/workflow-commands/SKILL.md or shared reference`

**Actions**

- Require START, AgentSpec contract loading, TODO parent ownership, tool routing, and evidence.
- Define `subtask: false` for parent-session execution unless a specific command intentionally isolates context.
- Remove dependencies on deleted workflow agents.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Shared behavior is referenced rather than copied.
- Command invocation does not silently spawn a coordinator child session.

**Evidence:** Command-session test.

**Rollback:** Revert shared preamble.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-092 — Refactor brainstorm, define, and design commands

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-091,T-V06
- **Scope:** `commands/workflow:brainstorm.md; workflow:define.md; workflow:design.md`

**Actions**

- Preserve AgentSpec artifacts and phase gates.
- Use skills/rules rather than workflow agents.
- Keep Write-then-Copy behavior only where the AgentSpec contract requires it.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Artifacts match current AgentSpec contract.
- Commands remain separate from Altitude state.

**Evidence:** Golden command fixtures.

**Rollback:** Restore baseline command files.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-093 — Refactor build and iterate commands

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-086,T-091,T-V06
- **Scope:** `commands/workflow:build.md; workflow:iterate.md`

**Actions**

- Preserve the build output gate.
- Use parent TODO and atomic leaf execution for implementation work.
- Apply block validation and AgentSpec artifact updates.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Build asks for output location before creating code when required.
- Leaf execution does not own TODO or delegate.

**Evidence:** Build/iterate integration fixtures.

**Rollback:** Restore baseline command files.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-094 — Refactor validate and ship commands

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-091,T-092,T-093,T-V06
- **Scope:** `commands/workflow:validate.md; workflow:ship.md`

**Actions**

- Use independent validator profiles and judge/faithfulness skills.
- Preserve AgentSpec validation and shipping artifacts.
- Prevent AgentSpec ship from archiving or advancing Altitude state.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Validation evidence is independent and complete.
- Workflow state remains isolated.

**Evidence:** Validate/ship fixtures.

**Rollback:** Restore baseline command files.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-095 — Refactor create-pr command and GitHub routing

- **Type:** command-migration
- **Priority:** P1
- **Cutover blocker:** no
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-036,T-091,T-V06
- **Scope:** `commands/workflow:create-pr.md; rules/TOOL_ROUTING.md`

**Actions**

- Require `gh` for GitHub operations and `git` for local Git state.
- Require preflight, clean diff review, validation status, and explicit user approval for publication.
- Apply RTK prefixes by default.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No ad hoc GitHub API or browser workflow is used when `gh` is available.
- Push/PR actions remain explicitly gated.

**Evidence:** Dry-run fixture.

**Rollback:** Restore command file.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-096 — Add command compatibility test suite

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-092,T-093,T-094,T-095,T-V06
- **Scope:** `test/integration/commands/; fixtures`

**Actions**

- Test command names, artifacts, gates, session behavior, TODO ownership, and workflow isolation.
- Test missing output path, missing prior artifact, validation fail, and ship with open gaps.
- Compare against baseline compatibility expectations.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All preserved commands pass positive and negative fixtures.
- No command references deleted agents.

**Evidence:** Command compatibility report.

**Rollback:** Remove tests.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-097 — Add exact Build Output Gate regression suite

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-093,T-045,T-V06
- **Scope:** `test/integration/commands/workflow-build-output-gate/`

**Actions**

- Assert the output-path question is the first command-specific tool action.
- Assert DESIGN is not read before the answer.
- Assert no default or inferred output path is used.
- Assert cancellation causes zero implementation writes.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All four ordering/negative scenarios pass.
- The test records tool-call order, not only final text.

**Evidence:** Ordered tool trace and file-write audit.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-098 — Make Write-then-Copy atomic and recoverable

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-092,T-094,T-V06
- **Scope:** `skills/workflow-commands/; AgentSpec artifact helper; tests`

**Actions**

- Write and validate the global artifact first.
- Copy to a temporary local file, verify checksum, then atomically rename.
- Record partial-copy recovery and retry behavior.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Global and local artifacts have matching checksums.
- A failed copy does not leave a misleading completed local artifact.

**Evidence:** Failure-injection and checksum tests.

**Rollback:** Restore prior copy logic.

**v2 revision:** Added by deterministic v2 audit.

#### T-099 — Preserve command model and parent-session parity

- **Type:** command-migration
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-090,T-091,T-070,T-V06
- **Scope:** `commands/workflow:*.md; command compatibility matrix`

**Actions**

- Record and preserve intentional command model overrides.
- Set `subtask: false` for commands that must remain in the parent session.
- Remove deleted agent names from command frontmatter.
- Verify each command's actual executing agent and session.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every command has an explicit parent/subtask decision.
- No command silently starts a retired coordinator child session.
- Intentional model behavior is preserved or explicitly changed by decision.

**Evidence:** Command frontmatter audit and session traces.

**Rollback:** Restore baseline command files.

**v2 revision:** Added by deterministic v2 audit.

#### T-V07 — Independently validate W7 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-090,T-091,T-092,T-093,T-094,T-095,T-096,T-097,T-098,T-099
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w7-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W7 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W7 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W8 — MCP registry, configuration, and deterministic tool use

**Entry gate:** `T-V07`

**Exit gate:** `T-V08` must return PASS.

#### T-110 — Create canonical MCP registry

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-002,T-037,T-V07
- **Scope:** `.specs/shared/mcp-registry.yaml`

**Actions**

- Register Context7, CodeGraph, codex-agent-mem, fs-read, headroom, and sequential-thinking.
- Record type, command/URL source, auth variables by name only, tool prefixes, trigger, authority, context cost, health check, fallback, and owner.
- Prohibit unregistered MCPs from being treated as mandatory.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Each required MCP has complete metadata.
- No secret value is committed.

**Evidence:** Validated registry.

**Rollback:** Remove registry.

**v2 revision:** Selected one canonical registry path. The repository does not need a second root `config/` authority.

#### T-111 — Configure Context7

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-110,T-V07
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.mcp.fragment.json; .specs/shared/mcp-registry.yaml; governing rules`

**Actions**

- Add verified Context7 configuration with its documented authentication mode; use environment-backed credentials when the selected server requires them.
- Define use for current library/framework/API documentation.
- Define official-doc/web fallback and citation expectations.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Context7 appears in the effective MCP list and returns a health response.
- A docs fixture invokes it when required.

**Evidence:** Sanitized config diff and health log.

**Rollback:** Remove MCP entry.

**v2 revision:** MCP configuration is staged in W8 and merged once in W10; active opencode.json is not edited here.

#### T-112 — Configure and govern CodeGraph

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-110,T-V07
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.mcp.fragment.json; .specs/shared/mcp-registry.yaml; governing rules`

**Actions**

- Verify server source and tool names.
- Use CodeGraph first only when `.codegraph/` exists.
- Define shell fallback `codegraph explore` and search/read fallback when absent.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Indexed-repository fixture uses CodeGraph.
- Non-indexed fixture skips it without error.

**Evidence:** Two-path integration logs.

**Rollback:** Remove MCP entry.

**v2 revision:** MCP configuration is staged in W8 and merged once in W10; active opencode.json is not edited here.

#### T-113 — Configure and govern codex-agent-mem

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-038,T-110,T-V07
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.mcp.fragment.json; .specs/shared/mcp-registry.yaml; governing rules`

**Actions**

- Verify read/write capabilities and exact tool names.
- Implement semantic duplication with stable event IDs.
- Prevent memory MCP content from overriding current `.specs` state.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Write/read/dedup fixtures pass.
- Conflict fixture selects `.specs` as authority.

**Evidence:** Memory MCP health and reconciliation logs.

**Rollback:** Disable MCP entry; local state continues.

**v2 revision:** MCP configuration is staged in W8 and merged once in W10; active opencode.json is not edited here.

#### T-114 — Configure and govern fs-read

- **Type:** mcp-governance
- **Priority:** P1
- **Cutover blocker:** no
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-110,T-V07
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.mcp.fragment.json; .specs/shared/mcp-registry.yaml; governing rules`

**Actions**

- Keep fs-read registered and enabled as requested.
- Document the exact capability boundary between fs-read, native read, and altitude-filestore.
- Restrict activation to its unique capability and keep native read as the normal default.
- Define degraded behavior when fs-read is unhealthy without removing it from the target architecture.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- fs-read remains in the canonical MCP registry.
- Its trigger and non-trigger are testable.
- Duplicate routine reads do not invoke it.

**Evidence:** Capability comparison.

**Rollback:** Disable temporarily in degraded mode; do not remove it from the approved target architecture.

**v2 revision:** Removed the v1 option to delete fs-read, which contradicted the user's keep-all-MCP decision.

#### T-115 — Configure and govern headroom

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-110,T-V07
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.mcp.fragment.json; .specs/shared/mcp-registry.yaml; governing rules`

**Actions**

- Define whether MCP headroom, headroom-guard plugin, and context-budget plugin are complementary or duplicative.
- Choose one authority for thresholds and one telemetry source.
- Require preflight before large reads, broad MCP activation, or large fan-out.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Thresholds have one canonical source.
- Warning/critical/block behaviors are testable.
- No false claim of telemetry enforcement remains.

**Evidence:** Headroom architecture decision and tests.

**Rollback:** Restore baseline plugin/MCP configuration.

**v2 revision:** MCP configuration is staged in W8 and merged once in W10; active opencode.json is not edited here.

#### T-116 — Configure and govern sequential-thinking

- **Type:** mcp-governance
- **Priority:** P1
- **Cutover blocker:** no
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-110,T-V07
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.mcp.fragment.json; .specs/shared/mcp-registry.yaml; governing rules`

**Actions**

- Limit activation to high-complexity decomposition, conflict analysis, or multi-option architecture decisions.
- Prohibit routine use in atomic execution.
- Define a no-MCP fallback using the normal planning process.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Routine leaf fixtures do not invoke sequential-thinking.
- A qualifying complex fixture invokes it through an explicit trigger.
- The MCP remains registered even when a task uses the no-MCP fallback.

**Evidence:** Activation tests.

**Rollback:** Disable temporarily in degraded mode; preserve the canonical registry entry.

**v2 revision:** Changed permissive `may invoke` into a deterministic trigger and preserved the MCP.

#### T-117 — Create MCP preflight and health-check tool

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-111,T-112,T-113,T-114,T-115,T-116,T-V07
- **Scope:** `tools/mcp-health-check.{sh,contract.md}; tests`

**Actions**

- Compare expected registry with effective `opencode mcp list` output.
- Check required environment variable names are present without printing values.
- Run bounded server/tool health checks and produce available/degraded/unavailable status.
- Detect UI/CLI disagreement.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Tool identifies missing, unhealthy, and unconfigured servers.
- Output is safe to store as evidence.

**Evidence:** Health-check logs.

**Rollback:** Remove tool.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-118 — Add MCP activation and fallback tests

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-117,T-V07
- **Scope:** `test/integration/mcp/; fixtures`

**Actions**

- Test each trigger and non-trigger.
- Test unavailable server, timeout, auth missing, excessive context, and fallback.
- Test that no result is fabricated when a required MCP fails.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All MCPs have positive, negative, and fallback coverage.
- Context budget rules are respected.

**Evidence:** MCP test report.

**Rollback:** Remove tests.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-119 — Pin MCP server provenance, versions, and licenses

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** dev-security-guardian
- **Dependencies:** T-110,T-007,T-V07
- **Scope:** `.specs/shared/mcp-registry.yaml; MCP provenance evidence`

**Actions**

- Record official source, package/image/URL, exact version or immutable reference, license, maintainer, and install method for every MCP.
- Reject floating `latest` references for local packages.
- Define update and rollback procedures.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every MCP has a reproducible source and version.
- No unreviewed install command remains.

**Evidence:** Provenance manifest and package/version outputs.

**Rollback:** Restore previous pinned references.

**v2 revision:** Added by deterministic v2 audit.

#### T-120 — Define MCP namespaces, permissions, and tool-collision policy

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-110,T-088,T-V07
- **Scope:** `.specs/shared/mcp-registry.yaml; staged permission fragment`

**Actions**

- Record exact tool names exposed by each MCP.
- Detect collisions with built-in, plugin, and custom tools.
- Apply per-host/per-leaf permission patterns.
- Hide unrelated MCP tools from leaf profiles.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No ambiguous tool name exists.
- Each profile sees only the MCP tools required by its role.

**Evidence:** Tool inventory and permission listing.

**Rollback:** Restore prior staged permissions.

**v2 revision:** Added by deterministic v2 audit.

#### T-121 — Define MCP timeout, retry, output, and concurrency budgets

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-110,T-115,T-V07
- **Scope:** `.specs/shared/mcp-registry.yaml; rules/MCP_GOVERNANCE.md`

**Actions**

- Set connection/tool-discovery timeout per server.
- Define retry count, backoff, circuit-breaker/degraded state, maximum output size, and concurrent calls.
- Integrate limits with headroom.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every MCP has explicit limits.
- Timeout or excessive output produces a bounded failure and fallback.

**Evidence:** Timeout/output failure fixtures.

**Rollback:** Restore prior limits.

**v2 revision:** Added by deterministic v2 audit.

#### T-122 — Add MCP content-trust and prompt-injection policy

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** dev-security-guardian,dev-faithfulness-guard
- **Dependencies:** T-037,T-119,T-120,T-V07
- **Scope:** `rules/MCP_CONTENT_TRUST.md; .specs/shared/mcp-governance.md`

**Actions**

- Treat MCP-returned content as data, not instructions, unless the source is an approved instruction authority.
- Require provenance and sanitization for external docs and memory.
- Block MCP content from changing scope, permissions, TODO, or workflow phase.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Prompt-injection fixtures cannot change higher-priority behavior.
- External content is labeled with source and trust level.

**Evidence:** Injection fixtures and security review.

**Rollback:** Remove policy and tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-123 — Define MCP authentication, redaction, and secret handling

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** dev-security-guardian
- **Dependencies:** T-119,T-V07
- **Scope:** `.specs/shared/mcp-registry.yaml; rules/MCP_GOVERNANCE.md; health-check redaction tests`

**Actions**

- Record environment variable names or OAuth flow without storing values.
- Define secure credential location and logout/recovery procedures.
- Redact tokens, headers, PII, and sensitive paths from health logs and memory.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No credential value enters Git, evidence, TODO, or memory.
- Missing auth produces an actionable degraded status.

**Evidence:** Secret scan and sanitized health logs.

**Rollback:** Remove staged auth references and revoke test credentials if created.

**v2 revision:** Added by deterministic v2 audit.

#### T-124 — Build one staged MCP configuration fragment

- **Type:** mcp-governance
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-111,T-112,T-113,T-114,T-115,T-116,T-119,T-120,T-121,T-122,T-123,T-V07
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.mcp.fragment.json`

**Actions**

- Merge all approved MCP entries exactly once.
- Validate names, types, commands/URLs, environment references, enabled flags, and timeouts.
- Compare the fragment with the canonical registry.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The staged fragment contains all six required MCPs.
- The fragment and registry agree exactly.
- No active config is modified.

**Evidence:** Schema validation and registry diff.

**Rollback:** Delete the staged fragment.

**v2 revision:** Added by deterministic v2 audit.

#### T-V08 — Independently validate W8 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-110,T-111,T-112,T-113,T-114,T-115,T-116,T-117,T-118,T-119,T-120,T-121,T-122,T-123,T-124
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w8-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W8 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W8 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W9 — TODO, state, validation, and memory integration

**Entry gate:** `T-V08`

**Exit gate:** `T-V09` must return PASS.

#### T-130 — Implement parent TODO protocol

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-032,T-086,T-V08
- **Scope:** `rules/TODO_OWNERSHIP.md; state plugin/helper; tests`

**Actions**

- Create stable block/task/validation IDs.
- Implement allowed status transitions and evidence links.
- Reject parallel untracked lists and leaf-originated direct mutations.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All action items appear in one parent ledger.
- Closed items point to evidence and validator result.

**Evidence:** Ledger fixtures.

**Rollback:** Revert protocol/plugin changes.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-131 — Implement block validation scheduling

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-034,T-084,T-130,T-V08
- **Scope:** `rules/VALIDATION_EVIDENCE.md; task templates; scheduler/helper`

**Actions**

- Create a validation task when all execution tasks in a block reach locally complete.
- Assign an independent validator profile.
- Reopen or create remediation tasks on failure.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No block closes before validator PASS or approved-gap decision.
- Validator is not the executor.

**Evidence:** Block lifecycle tests.

**Rollback:** Revert scheduler/helper.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-132 — Implement dual-write memory events

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-113,T-130,T-V08
- **Scope:** `.specs/shared/memory-event-schema.yaml; memory helper/tool; rules`

**Actions**

- Write authoritative event to `.specs/memory` first.
- Duplicate to MCP with stable event ID and content hash.
- Record pending/failed/synced status without blocking unrelated work.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Duplicate writes are idempotent.
- MCP outage leaves a visible pending sync.
- No secrets are stored.

**Evidence:** Dual-write tests.

**Rollback:** Disable MCP duplication; preserve local events.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-133 — Implement state and memory reconciliation

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-014,T-132,T-V08
- **Scope:** `tools/state-memory-reconcile.{sh,contract.md}; tests`

**Actions**

- Compare active task/phase, artifacts, archive state, local memory, and MCP memory.
- Apply source-of-truth hierarchy.
- Produce repair options rather than silently rewriting conflicts.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Conflicts stop execution and show repair choices.
- A stale MCP record cannot advance state.

**Evidence:** Conflict fixtures.

**Rollback:** Remove tool.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-134 — Implement resume protocol

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-130,T-131,T-132,T-133,T-V08
- **Scope:** `rules/START.md; resume helper; tests`

**Actions**

- Restore active change, phase, block, task, evidence, and pending memory sync.
- Re-run health and conflict checks.
- Require user confirmation when state is ambiguous.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- A fresh session resumes the same canonical task.
- No closed task is re-executed without an explicit reopen.

**Evidence:** Cross-session fixtures.

**Rollback:** Revert resume helper/rule.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-135 — Create audit and trace report

- **Type:** state-runtime
- **Priority:** P1
- **Cutover blocker:** no
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-134,T-V08
- **Scope:** `tools/harness-trace-report.{sh,contract.md}; templates`

**Actions**

- Render request → workflow → phase → block → task → leaf → evidence → validation → memory → ship trace.
- Include tool/MCP usage and fallback events.
- Exclude secret values and excessive raw output.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- A reviewer can trace every closed task.
- The report detects missing evidence or orphan tasks.

**Evidence:** Trace report fixture.

**Rollback:** Remove tool.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-136 — Implement single-active-writer lease

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-011,T-021,T-130,T-V08
- **Scope:** `.specs/shared/writer-lease-contract.md; state helper/tool; tests`

**Actions**

- Create a lease containing change ID, session ID, owner, acquired time, heartbeat, and expiry.
- Block a second parent session from mutating the same active change.
- Define stale-lease recovery with evidence and user confirmation.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Two concurrent parents cannot both write the same change.
- A crashed session can be recovered without silent takeover.

**Evidence:** Concurrent-session and stale-lease tests.

**Rollback:** Disable lease enforcement and restore prior state helper.

**v2 revision:** Added by deterministic v2 audit.

#### T-137 — Define memory namespace, retention, redaction, and deletion

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-012,T-132,T-V08
- **Scope:** `.specs/shared/memory-governance-contract.md; memory event schema; MCP rules`

**Actions**

- Namespace memory by harness version, repository identity, change ID, and event ID.
- Define retention, deletion, redaction, payload limits, and cross-repository isolation.
- Define schema migration and a separately approved backfill task when historical records require migration.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Memory from one repository cannot contaminate another.
- Sensitive content is excluded or redacted.
- Deletion and schema migration are testable.

**Evidence:** Governance contract and isolation/redaction fixtures.

**Rollback:** Revert governance/schema changes.

**v2 revision:** Added by deterministic v2 audit.

#### T-138 — Predeclare validation blocks and boundaries

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-024,T-034,T-131,T-V08
- **Scope:** `.specs/shared/validation-block-contract.md; task pack templates`

**Actions**

- Require every Design/Plan task pack to assign execution tasks to a validation block.
- Prohibit changing block boundaries during execution without parent/user approval.
- Require immediate independent validation for security, permissions, MCP auth, and active config changes.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No execution task exists outside a validation block.
- A block cannot hide unrelated subsystems or risk classes.
- High-risk tasks are validated immediately.

**Evidence:** Task-pack and block-boundary fixtures.

**Rollback:** Remove contract/template changes.

**v2 revision:** Added by deterministic v2 audit.

#### T-139 — Map native TODO capability to harness ledger semantics

- **Type:** state-runtime
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-002,T-130,T-V08
- **Scope:** `.specs/shared/todo-projection-contract.md; TODO fixtures`

**Actions**

- Record the actual native TODO fields and statuses exposed by the pinned OpenCode version.
- Map harness block/task/validation semantics without inventing unsupported native statuses.
- Use separate validation TODO items and durable `.specs` fields where native TODO is insufficient.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every harness state has an explicit native-TODO and durable-state representation.
- Resume does not depend on an unsupported TODO field.

**Evidence:** Capability report and projection fixtures.

**Rollback:** Revert mapping contract.

**v2 revision:** Added by deterministic v2 audit.

#### T-V09 — Independently validate W9 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-130,T-131,T-132,T-133,T-134,T-135,T-136,T-137,T-138,T-139
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w9-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W9 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W9 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W10 — Runtime configuration and plugin refactor

**Entry gate:** `T-V09`

**Exit gate:** `T-V10` must return PASS.

#### T-140 — Assemble staged opencode.next.json

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-067,T-081,T-085,T-117,T-V09
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/opencode.next.json`

**Actions**

- Merge staged host, agent, permission, skill, MCP, plugin, and instruction fragments.
- Set `default_agent` to an approved built-in primary.
- Load only the compact kernel and global dispatch rule permanently; phase/activity rules remain lazy.
- Validate against the pinned OpenCode schema and runtime version.
- Do not replace active opencode.json in W10.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The staged configuration parses and starts in the isolated runtime test adapter.
- No custom primary remains.
- Expected skills, MCPs, agents, plugins, and permission allowlists are visible.
- The active configuration remains untouched.

**Evidence:** Schema validation, runtime listing, sanitized diff.

**Rollback:** Delete the staged configuration and preserve active opencode.json.

**v2 revision:** Eliminates multiple live opencode.json mutations and creates one atomic cutover artifact.

#### T-141 — Classify plugins as keep, refactor, replace, or remove

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-004,T-140,T-V09
- **Scope:** `plugins/*.ts; plugin contracts`

**Actions**

- Evaluate altitude-context, altitude-filestore, specs-state, rtk-native, headroom-guard, context-budget, and any additional current plugin.
- Map each plugin to a target contract/rule.
- Identify policy-only behavior and unsupported runtime hooks.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every plugin has an explicit disposition.
- Documentation states actual enforcement strength.

**Evidence:** Plugin disposition matrix.

**Rollback:** Read-only.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-142 — Refactor or remove altitude-specific plugins

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-082,T-141,T-V09
- **Scope:** `plugins/altitude-context.ts; altitude-filestore.ts; related tests`

**Actions**

- Remove phase-agent description injection that no longer has a runtime target.
- Apply the approved plugin disposition matrix without conditional wording.
- Rename retained neutral file/allocation behavior and update contracts/tests.
- Remove duplicated or stale path logic.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No plugin depends on retired Altitude agents.
- Each retained behavior has one canonical contract and passing tests.
- Each removed behavior has a recorded replacement or explicit deprecation.

**Evidence:** Plugin tests and reference scan.

**Rollback:** Restore baseline plugins.

**v2 revision:** Removed `if valuable`; the W10 disposition matrix is authoritative.

#### T-143 — Harden specs-state and TODO enforcement

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-130,T-141,T-V09
- **Scope:** `plugins/specs-state.ts; state tools; tests`

**Actions**

- Implement enforceable checks where runtime hooks allow them.
- Use static/config permission enforcement for leaf task/TODO restrictions.
- Clearly label remaining policy-only controls.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Hard checks fail deterministically.
- Soft checks are not marketed as blockers.

**Evidence:** Positive/negative plugin tests.

**Rollback:** Restore baseline plugin.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-144 — Consolidate RTK behavior

- **Type:** runtime-assembly
- **Priority:** P1
- **Cutover blocker:** no
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-036,T-141,T-V09
- **Scope:** `plugins/rtk-native.ts; rules/RTK_AND_SHELL.md; tests`

**Actions**

- Align rewrite suggestions with the mandatory RTK rule.
- Support command chains and raw-debug exceptions.
- Avoid rewriting commands where output filtering would hide required debugging evidence.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Common git/gh/test/build commands use RTK.
- Debug fixtures can use raw commands explicitly.

**Evidence:** Rewrite tests.

**Rollback:** Restore baseline plugin.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-145 — Consolidate headroom and context budget

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-115,T-141,T-V09
- **Scope:** `plugins/headroom-guard.ts; context-budget.ts; MCP registry/rules; tests`

**Actions**

- Select canonical thresholds and telemetry authority.
- Define warning, critical, block, and override behavior.
- Prevent broad MCP/tool exposure and excessive preloading.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- One source controls thresholds.
- Budget tests cover large reads and MCP fan-out.
- Unsupported telemetry claims are removed.

**Evidence:** Context-budget test report.

**Rollback:** Restore baseline plugins/config.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-146 — Add runtime configuration integration tests

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-140,T-142,T-143,T-144,T-145,T-V09
- **Scope:** `test/integration/runtime/`

**Actions**

- Start the staged configuration through the runtime-test adapter selected in W0.
- Verify primary hosts, subagents, permissions, skills, MCPs, plugins, commands, and instruction loading.
- Run the documented fallback adapter only if the primary adapter fails for an environmental reason.
- Test degraded mode with MCPs disabled or unhealthy.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Runtime state matches the static design.
- The primary adapter result is recorded.
- Degraded mode is explicit and safe.

**Evidence:** Runtime integration report.

**Rollback:** Remove tests.

**v2 revision:** Removed `if supported`; W0 selects the supported adapter.

#### T-147 — Consolidate existing tools with new skills and validators

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-069,T-141,T-V09
- **Scope:** `tools/faithfulness_gate.ts; tools/verify_step.ts; tools/security-scan.*; tools/junta-auditor.*; skills/`

**Actions**

- Apply the W5 overlap matrix.
- Keep executable checks in tools and procedural selection in skills/rules.
- Remove duplicate scoring and contradictory verdict formats.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Each gate has one executable implementation and one canonical contract.
- Skills do not claim runtime enforcement they cannot provide.

**Evidence:** Tool/skill ownership matrix and regression tests.

**Rollback:** Restore prior tools/skills.

**v2 revision:** Added by deterministic v2 audit.

#### T-148 — Normalize contracts, paths, and stale references

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-015,T-019,T-141,T-147,T-V09
- **Scope:** `.specs/shared/; .specs/templates/; docs/; kb-index.yaml; control surfaces`

**Actions**

- Merge or retire duplicate contracts and templates.
- Normalize file naming and canonical paths.
- Update all references to current files.
- Regenerate indexes after the final staged tree is known.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every canonical reference resolves.
- No duplicate contract has equal authority.
- Stale generated inventory is replaced.

**Evidence:** Reference graph, duplicate scan, regenerated index.

**Rollback:** Restore baseline files/checksums.

**v2 revision:** Added by deterministic v2 audit.

#### T-149 — Assemble atomic activation and rollback bundle

- **Type:** runtime-assembly
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** dev-shell-script-specialist,dev-security-guardian
- **Dependencies:** T-059,T-124,T-140,T-142,T-143,T-144,T-145,T-148,T-V09
- **Scope:** `.specs/changes/harness-skill-based-migration/staging/activation-bundle/`

**Actions**

- Package staged AGENTS, opencode config, rules, skills, agents, plugins, commands, contracts, tools, and manifests.
- Create atomic install and rollback scripts or exact command sequence.
- Verify checksums before and after installation.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- One activation bundle can install or restore the harness without partial state.
- Rollback restores the exact T-001 baseline.

**Evidence:** Bundle manifest, checksum verification, rollback rehearsal.

**Rollback:** Delete the staged bundle.

**v2 revision:** Added by deterministic v2 audit.

#### T-V10 — Independently validate W10 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-140,T-141,T-142,T-143,T-144,T-145,T-146,T-147,T-148,T-149
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w10-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W10 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W10 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W11 — Regression, security, traceability, and performance validation

**Entry gate:** `T-V10`

**Exit gate:** `T-V11` must return PASS.

#### T-150 — Create static architecture checks

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-068,T-081,T-140,T-V10
- **Scope:** `test/static/; pre-commit configuration`

**Actions**

- Fail on custom `mode: primary`.
- Fail on leaf `task` or `todowrite` access.
- Fail on invalid skill names/frontmatter, missing referenced rules/contracts, and removed agent references.
- Fail on AgentSpec/Altitude contract authority overlap.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All forbidden structures are detected.
- Checks run locally and in CI-compatible mode.

**Evidence:** Static check output.

**Rollback:** Remove checks.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-151 — Test Altitude full lifecycle

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-028,T-039,T-134,T-146,T-V10
- **Scope:** `test/integration/altitude/`

**Actions**

- Test START → Intent → Structure → Design/Plan → Execution → Validation → Ship.
- Test required user gates, task approval, block validation, memory writes, and archive.
- Test failure return from validation to execution.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No phase advances without its gate.
- Trace report is complete.
- No custom Altitude agent is invoked.

**Evidence:** Lifecycle test report.

**Rollback:** Remove tests.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-152 — Test AgentSpec workflow compatibility

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-096,T-146,T-V10
- **Scope:** `test/integration/agentspec/`

**Actions**

- Test each preserved `/workflow:*` command.
- Verify AgentSpec artifact storage and build output gate.
- Verify no Altitude state mutation.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Compatibility matrix passes.
- Workflow isolation is proven.

**Evidence:** AgentSpec test report.

**Rollback:** Remove tests.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-153 — Test TODO traceability and delegation boundaries

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-087,T-130,T-131,T-135,T-V10
- **Scope:** `test/integration/traceability/`

**Actions**

- Test multiple leaves completing tasks in one block.
- Verify only parent updates TODO.
- Verify leaf results, evidence, validator task, reopen, and resume.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No task status is lost or duplicated.
- Every update has an actor and evidence link.

**Evidence:** Traceability report.

**Rollback:** Remove tests.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-154 — Test MCP routing and degraded operation

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-118,T-146,T-V10
- **Scope:** `test/integration/mcp/`

**Actions**

- Test Context7, CodeGraph, memory, fs-read, headroom, and sequential-thinking triggers.
- Test absent config, auth failure, timeout, and excessive context.
- Verify documented fallback and no fabricated results.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All required failure paths are safe.
- Health state is surfaced before use.

**Evidence:** MCP report.

**Rollback:** Remove tests.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-155 — Perform security review

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-065,T-150,T-154,T-V10
- **Scope:** `Full migration diff; security report`

**Actions**

- Use security-guardian skill on config, MCP commands, environment variables, shell, permissions, plugins, and memory.
- Run secret scanning and dependency checks.
- Validate least privilege and publication gates.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No critical/high unresolved issue remains.
- Secrets are absent from repo and evidence.

**Evidence:** Security report and scanner logs.

**Rollback:** Block cutover and revert affected changes.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-156 — Measure context and performance impact

- **Type:** validation
- **Priority:** P1
- **Cutover blocker:** no
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-006,T-145,T-154,T-V10
- **Scope:** `test/load/; migration scorecard`

**Actions**

- Compare baseline and migrated context size, MCP tool exposure, command latency, and subagent fan-out.
- Measure RTK savings where observable.
- Identify regressions caused by always-loaded instructions or excessive MCPs.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- The migrated harness meets approved context/fan-out targets.
- Any accepted regression has a written rationale.

**Evidence:** Performance comparison.

**Rollback:** Adjust rules/MCP activation or revert cutover.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-157 — Run independent judge and faithfulness review

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-151,T-152,T-153,T-154,T-155,T-156,T-V10
- **Scope:** `Migration artifacts and evidence`

**Actions**

- Use an independent validator with judge and faithfulness skills.
- Compare implementation to decisions D-01 through D-14 and acceptance criteria.
- List unsupported claims, missing evidence, and residual risks.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Verdict is PASS, or every gap has an explicit ID, owner, severity, expiry, and user approval.
- Reviewer is independent from implementation tasks.
- No critical or high gap can be accepted for cutover.

**Evidence:** Final validation report.

**Rollback:** Return failed blocks to execution.

**v2 revision:** Replaced vague `approved gaps` with a controlled accepted-gap record.

#### T-158 — Test manual subagent invocation as an out-of-band path

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-089,T-146,T-V10
- **Scope:** `test/edge-cases/manual-subagent-invocation/`

**Actions**

- Invoke a hidden/internal or retained subagent manually.
- Verify it cannot read/write managed TODO, mutate active state, or claim block validation.
- Verify the parent detects no managed completion from the out-of-band session.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Manual invocation cannot close a managed task.
- Any attempted mutation is denied or clearly outside the managed change.

**Evidence:** Permission and state audit logs.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-159 — Test configuration precedence and project-local overrides

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-002,T-140,T-146,T-V10
- **Scope:** `test/integration/config-precedence/`

**Actions**

- Run global-only, project-local override, environment override, and alternate config-directory fixtures.
- Verify no override silently re-enables custom primary agents or broad permissions.
- Verify MCP list and skill discovery match the effective configuration report.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Effective precedence is deterministic in every fixture.
- Unsafe overrides fail preflight or are surfaced before mutation.

**Evidence:** Effective-config diffs and runtime listings.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-160 — Test rule loading, receipts, and context budget

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-042,T-058,T-146,T-V10
- **Scope:** `test/integration/rule-loading/`

**Actions**

- Test global dispatch, Altitude START, AgentSpec START, phase rules, missing rules, recursive references, and context limits.
- Verify load receipts and lazy behavior.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Mandatory rules load exactly once.
- Unrelated phase/skill rules are not preloaded.
- Missing mandatory rules stop execution.

**Evidence:** Rule-load traces and context report.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-161 — Test pinned-version compatibility and upgrade detection

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-007,T-146,T-V10
- **Scope:** `test/integration/runtime-version/`

**Actions**

- Run against the pinned version.
- Simulate a version/schema mismatch.
- Verify preflight blocks unsupported runtime versions.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Pinned version passes.
- Unsupported version fails before mutation with an actionable message.

**Evidence:** Version compatibility report.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-162 — Test in-flight change migration and resume

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-019,T-134,T-146,T-V10
- **Scope:** `test/integration/in-flight-migration/`

**Actions**

- Test finish-on-v1, migrate-to-v2, freeze, and incompatible-state cases.
- Resume after migration and verify task/evidence continuity.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every supported disposition is recoverable.
- Incompatible active changes block cutover.

**Evidence:** Migration/resume report.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-163 — Test MCP prompt injection and data-exfiltration boundaries

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** dev-security-guardian,dev-faithfulness-guard
- **Dependencies:** T-122,T-123,T-154,T-V10
- **Scope:** `test/integration/mcp-security/`

**Actions**

- Inject malicious instructions through docs, memory, and file-reading MCP outputs.
- Attempt scope, permission, TODO, state, and secret exfiltration changes.
- Verify trust labels, redaction, and higher-priority instructions hold.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No injected MCP content changes managed authority or exposes a secret.
- The security skill produces a blocking verdict for critical attempts.

**Evidence:** Security fixture report.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-164 — Test concurrent parent sessions and writer-lease recovery

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-136,T-153,T-V10
- **Scope:** `test/integration/concurrent-sessions/`

**Actions**

- Start two parent sessions against one active change.
- Verify one writer and one blocked reader.
- Simulate crash, stale lease, user-confirmed takeover, and audit trail.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No conflicting state or TODO write occurs.
- Takeover is explicit and traceable.

**Evidence:** Concurrent-session logs.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-165 — Audit required-skill activation evidence

- **Type:** validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-044,T-071,T-153,T-V10
- **Scope:** `test/integration/skill-activation/`

**Actions**

- Run trigger and non-trigger fixtures for all six skills.
- Verify `required_skills` and `loaded_skills` receipts.
- Verify a missing mandatory skill prevents completion.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Every trigger-mandatory skill is loaded and evidenced.
- Unrelated skills are not loaded.

**Evidence:** Skill activation audit.

**Rollback:** Remove tests.

**v2 revision:** Added by deterministic v2 audit.

#### T-V11 — Independently validate W11 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-150,T-151,T-152,T-153,T-154,T-155,T-156,T-157,T-158,T-159,T-160,T-161,T-162,T-163,T-164,T-165
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w11-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W11 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W11 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

### W12 — Documentation, rollout, cutover, cleanup, and ship

**Entry gate:** `T-V11`

**Exit gate:** `T-V12` must return PASS.

#### T-170 — Update architecture documentation

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-157,T-V11
- **Scope:** `README.md; docs/HARNESS_*; .specs/README.md`

**Actions**

- Document built-in primary hosts, rules, skills, leaf subagents, dual workflows, Altitude contract, MCP registry, TODO ownership, validation, and memory.
- Remove obsolete two-coordinator and phase-agent descriptions.
- Mark AgentSpec SDD assets as a separate compatibility workflow.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Docs match actual files and runtime behavior.
- No stale primary/coordinator claim remains.

**Evidence:** Documentation reference scan.

**Rollback:** Restore baseline docs.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-171 — Create operator runbook

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-117,T-134,T-170,T-V11
- **Scope:** `docs/SKILL_BASED_HARNESS_RUNBOOK.md`

**Actions**

- Document START, choosing workflows, reading state, TODO behavior, leaf delegation, validation, MCP health, memory reconciliation, degraded operation, and recovery.
- Include exact diagnostic commands and expected outputs.
- Include common failure scenarios.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- A new operator can diagnose configuration and resume a change.
- Commands do not expose secrets.

**Evidence:** Runbook walkthrough.

**Rollback:** Remove runbook.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-172 — Create migration and rollback guide

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-001,T-140,T-170,T-V11
- **Scope:** `docs/SKILL_BASED_MIGRATION_GUIDE.md; rollback manifest`

**Actions**

- Document prerequisites, backup, config swap, health checks, pilot, cutover, and rollback.
- List files added, changed, deleted, and archived.
- Define recovery if OpenCode cannot start.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Rollback can restore the baseline config and agents.
- Guide covers partial-wave failure.

**Evidence:** Rollback rehearsal.

**Rollback:** Guide is non-runtime.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-173 — Run shadow-mode pilot

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-171,T-172,T-V11
- **Scope:** `Pilot evidence and scorecard`

**Actions**

- Run representative read-only, tactical, strategic Altitude, AgentSpec command, prompt, shell, security, and MCP tasks.
- Compare route, TODO, evidence, context, and output with the baseline.
- Do not delete rollback assets during pilot.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No critical traceability or routing defect occurs.
- Scorecard meets cutover threshold.

**Evidence:** Pilot report.

**Rollback:** Restore baseline config immediately.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-174 — Perform controlled cutover

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-173,T-V11,T-178
- **Scope:** `Active global OpenCode configuration`

**Actions**

- Activate the migrated config.
- Run startup, agent, skill, MCP, command, and health checks.
- Record the exact active commit and effective configuration.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- OpenCode starts and all P0 smoke checks pass.
- Effective config matches the intended source.

**Evidence:** Cutover checklist and health logs.

**Rollback:** Restore baseline snapshot and restart OpenCode.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-175 — Remove or archive legacy surfaces

- **Type:** cutover-ship
- **Priority:** P1
- **Cutover blocker:** no
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-174,T-V11,T-179
- **Scope:** `Six frozen dev agents; retired coordinator/phase-agent files listed in the activation manifest; stale docs/contracts/config; superseded control-surface files`

**Actions**

- After successful cutover validation, delete the six frozen legacy dev agents.
- Delete or archive retired coordinators and phase agents according to the approved migration manifest.
- Archive historical material that remains useful.
- Regenerate indexes and remove every stale reference.
- Preserve AgentSpec commands and its workflow contract.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No active reference points to a deleted file.
- AgentSpec compatibility assets remain intact.
- The active runtime contains no custom primary coordinator.
- Archive and active-state records are consistent.

**Evidence:** Reference scan and final tree diff.

**Rollback:** Restore deleted files from baseline.

**v2 revision:** This is now the only task that deletes legacy agents, after consumers and runtime are validated.

#### T-176 — Finalize validation and migration scorecard

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-175,T-V11,T-181
- **Scope:** `Final validation report; migration scorecard`

**Actions**

- Re-run static, integration, security, load, MCP, traceability, and command compatibility tests.
- Compare final metrics to T-006 targets.
- Document residual risks and follow-up changes.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All P0 criteria pass.
- Any accepted P1 gap has owner and follow-up task.

**Evidence:** Signed final report.

**Rollback:** Reopen failed wave or roll back cutover.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-177 — Ship, archive, and write memory

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-176,T-V11
- **Scope:** `.specs/archive/; .specs/memory/; memory MCP; ship summary`

**Actions**

- Create ship summary with delivered boundary, decisions, evidence, residual risks, and rollback reference.
- Reconcile and archive the change.
- Write authoritative local memory and duplicate semantic memory.
- Create follow-up changes rather than hiding future work.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Change is archived once, state is consistent, and memory sync status is known.
- Trace report is complete.

**Evidence:** Ship summary, archive path, memory events.

**Rollback:** Use documented unarchive/rollback procedure.

**v2 revision:** Carried from v1; enriched with deterministic gates in v2.

#### T-178 — Execute deterministic user-acceptance scenario pack

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** L
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-173,T-V11
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/user-acceptance/`

**Actions**

- Run fixed scenarios for direct answer, Altitude planning, Altitude execution, AgentSpec build, data task, prompt change, shell change, security-sensitive change, MCP outage, and resume.
- Record route, rules, skills, tools, TODO, leaves, validation, memory, and result.
- Require explicit user acceptance for the scenario pack.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All critical scenarios pass.
- The user accepts the observed routing and traceability.

**Evidence:** Scenario transcripts and acceptance record.

**Rollback:** Keep active v1 configuration; do not cut over.

**v2 revision:** Added by deterministic v2 audit.

#### T-179 — Run post-cutover smoke, resume, and rollback checkpoint

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-174,T-V11
- **Scope:** `Active runtime; cutover evidence`

**Actions**

- Run startup, direct answer, Altitude START, AgentSpec build gate, one leaf task, one validation block, MCP preflight, memory write, and resume.
- Stop and roll back immediately on a critical failure.
- Preserve both pre- and post-cutover effective-config reports.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- All smoke scenarios pass on the active runtime.
- Rollback remains executable until T-176 final validation passes.

**Evidence:** Post-cutover smoke report.

**Rollback:** Execute T-172 rollback guide and restore the T-001 baseline.

**v2 revision:** Added by deterministic v2 audit.

#### T-180 — Regenerate repository indexes and authority maps after cleanup

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-175,T-V11
- **Scope:** `kb-index.yaml; KB indexes; file/reference maps`

**Actions**

- Regenerate indexes from the final active tree.
- Validate every referenced path.
- Mark generated files with source commit and generation timestamp.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- No deleted or nonexistent path appears as current.
- Generated indexes match the active commit.

**Evidence:** Index diff and reference validator output.

**Rollback:** Restore previous generated indexes.

**v2 revision:** Added by deterministic v2 audit.

#### T-181 — Run final documentation-to-runtime drift scan

- **Type:** cutover-ship
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** parent-or-allocated-leaf
- **Validator:** independent-leaf-validator
- **Required skills:** resolved-by-activity-rule
- **Dependencies:** T-170,T-175,T-180,T-V11
- **Scope:** `README.md; docs/; AGENTS.md; opencode.json; rules/; contracts/`

**Actions**

- Compare documented agents, workflows, paths, tools, MCPs, permissions, and enforcement levels with the active runtime.
- Fail on coordinator-primary language, stale paths, or policy described as hard enforcement.

**Verification**

- Task-Spec must define exact commands before execution.

**Acceptance criteria**

- Documentation and runtime inventories match.
- No stale removed-agent or duplicate-authority reference remains.

**Evidence:** Final drift report.

**Rollback:** Correct docs/runtime before ship.

**v2 revision:** Added by deterministic v2 audit.

#### T-V12 — Independently validate W12 exit gate

- **Type:** wave-validation
- **Priority:** P0
- **Cutover blocker:** yes
- **Complexity:** M
- **Execution owner:** independent-leaf-validator
- **Validator:** parent-accepts-verdict
- **Required skills:** dev-judge,dev-faithfulness-guard; dev-security-guardian when triggered
- **Dependencies:** T-170,T-171,T-172,T-173,T-174,T-175,T-176,T-177,T-178,T-179,T-180,T-181
- **Scope:** `.specs/changes/harness-skill-based-migration/evidence/w12-validation/`

**Actions**

- Review every task outcome, changed scope, evidence, acceptance criterion, and rollback readiness.
- Run the wave-specific static/integration/security checks.
- Use an independent validator that did not implement the wave tasks.
- Issue PASS, FAIL, or BLOCKED; FAIL creates remediation tasks in the same wave.
- Write local memory first and duplicate the validation event to the memory MCP.

**Verification**

- Run the wave exit checklist and all wave-specific checks defined in Task-Specs.

**Acceptance criteria**

- Every wave task is done, explicitly skipped with approval, or blocked with a remediation task.
- No critical or high unresolved defect remains.
- Evidence paths and checksums are complete.
- The next wave remains blocked until PASS.

**Evidence:** W12 validation report, command/test logs, scope audit, memory event status.

**Rollback:** Reopen the failed W12 tasks; do not advance to the next wave.

**v2 revision:** Added because v1 required wave validation but omitted validation tasks from the master backlog and CSV.

## 8. Global ship criteria

- [ ] `T-V00` through `T-V12` passed.
- [ ] Zero custom primary agents.
- [ ] Parent Task permission is default-deny with an explicit allowlist.
- [ ] All managed leaves deny Task and TODO read/write.
- [ ] Writer lease and concurrent-session tests pass.
- [ ] Altitude and AgentSpec START/contract/state remain separate.
- [ ] Six dev skills are discoverable and their load receipts are verified.
- [ ] All requested MCPs are registered, pinned, healthy or explicitly degraded, permission-scoped, and injection-tested.
- [ ] Active AGENTS/opencode configuration was applied through the validated activation bundle.
- [ ] Legacy agents were deleted only after successful cutover.
- [ ] Final indexes and documentation match the active runtime.
- [ ] Rollback was rehearsed and remains available until final validation.

## 9. Source references

- Repository: https://github.com/Tiao553/opencode-harness
- OpenCode agents: https://opencode.ai/docs/agents
- OpenCode skills: https://opencode.ai/docs/skills
- OpenCode commands: https://opencode.ai/docs/commands
- OpenCode config: https://opencode.ai/docs/config
- OpenCode rules: https://opencode.ai/docs/rules
- OpenCode MCP servers: https://opencode.ai/docs/mcp-servers
- OpenCode tools: https://opencode.ai/docs/tools