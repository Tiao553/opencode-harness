# Migration Scorecard — Final State of Confirmed Decisions

**T-176 | Date:** 2026-07-25
**Scope:** Current state after W0–W12 implementation (W12 cutover pending).

---

## D-01 to D-18 — Implementation Status

| Decision | Statement | Implemented by | Current state | Verified by |
|---|---|---|---|---|
| D-01 | Only built-in `build` and `plan` are primary hosts | W4 AGENTS.next.md, W10 opencode.next.json | Staged: 0 custom primaries in opencode.next.json | `test/w11-static-checks.sh` check 8 |
| D-02 | Parent session is the only managed TODO/state writer | W6 task: deny on 73 agents, W9 writer lease schema | Enforced: 73/73 agents deny task; lease schema documented | `test/w6-static-check.sh` |
| D-03 | Leaf subagents deny task and todowrite | W6 batch edit of 73 agents | Active: task: deny + todowrite: deny on 73 agents | `test/w6-static-check.sh` |
| D-04 | Leaf read scope is worktree-wide; write is allocation-bounded | W6 `rules/leaf-execution.md` | Documented in leaf-execution.md and W9 protocols | `rules/leaf-execution.md` |
| D-05 | Recursive delegation is forbidden | W6 rules, W7 static check | Static check catches task: allow on non-primaries | `test/w6-static-check.sh` |
| D-06 | Every execution task belongs to a predeclared validation block | W2 workflow contract sec. 6, W9 T-138 | Protocol documented; required in DESIGN.md template | `rules/altitude-phases.md` |
| D-07 | Six dev agents become skills; legacy deleted after W11+W12 | W5 skills created, agents frozen | 6 skills active in `skills/`; agents have FROZEN notice | `test/w11-static-checks.sh` check 7 |
| D-08 | Altitude and AgentSpec keep separate contracts and START rules | W2 contract, W3 rules, W7 commands | Separate contracts exist; command isolation enforced | `test/w7-compatibility.sh` |
| D-09 | Explicit `/workflow:*` names remain compatible | W7 command refactor | 8 commands preserved with preamble | `test/w7-compatibility.sh` check 1 |
| D-10 | All requested MCPs remain in target architecture | W8 MCP registry | 6 MCPs registered; 2 connected; 4 disabled pending config | `test/w8-mcp-health.sh` |
| D-11 | `.specs` is authoritative; memory MCP is semantic duplicate | W9 T-132 dual-write protocol | Local-first protocol documented; MCP is async non-blocking | `rules/dual-memory.md` |
| D-12 | Runtime changes through one atomic cutover bundle | W10 opencode.next.json + activation manifest | Staged bundle exists; cutover awaits W12 approval | `staged/activation-manifest.md` |
| D-13 | Parent Task permissions default-deny with explicit allowlist | W10 opencode.next.json (`"*": "deny"`) | Staged: opencode.next.json has `"*": "deny"` at root permission | `staged/opencode.next.json` |
| D-14 | Managed delegation sequential by default | W9 T-130 TODO protocol, `rules/todo-ownership.md` | One in_progress at a time enforced by TODO rule | `rules/todo-ownership.md` |
| D-15 | Writer lease prevents concurrent parent mutation | W9 T-136 lease schema | Schema defined; implementation pending W12 (Node script in W9 protocols) | `evidence/w9-validation/w9-protocols.md` |
| D-16 | Runtime, schema, MCPs, plugins pinned for migration | W7 T-007 runtime baseline, W8 registry | OpenCode 1.18.3 pinned; executable SHA recorded; MCP packages listed | `evidence/t-007-runtime-baseline.md` |
| D-17 | Only compact kernel always loaded; rules and skills lazy | W4 AGENTS.next.md, W3 rules | 168-line kernel; 15 lazy rule files; skill trigger matrix in Section 6 | `test/w4-structural.sh` |
| D-18 | MCP output is data, not authority | W8 mcp-governance.md, ADR-0003 | Stated in `rules/mcp-governance.md` core rule; opencode.next.json has no MCP trust escalation | `rules/mcp-governance.md` |

---

## Global Ship Criteria (from Roadmap V2 sec. 8)

| Criterion | Status |
|---|---|
| T-V00 through T-V12 passed | T-V00 through T-V07 PASS (static); T-V08–T-V12 pending cutover |
| Zero custom primary agents | Staged: 0 in opencode.next.json; live: 1 (altitude-maestro, removed at W12) |
| Parent Task permission default-deny | Staged in opencode.next.json |
| All managed leaves deny Task and TODO | Active: 73/73 agents |
| Writer lease and concurrent-session tests pass | Schema complete; tests pending runtime activation |
| Altitude and AgentSpec START/contract/state remain separate | Active: separate contracts and test |
| Six dev skills discoverable with load receipts | Active: 6 skills in skills/ |
| All requested MCPs registered, pinned, healthy or degraded | Active: 6 registered; 2 connected |
| Active AGENTS/config through validated activation bundle | Staged bundle exists; awaits W12 |
| Legacy agents deleted only after successful cutover | Frozen, not deleted; W12 T-175 will delete |
| Final indexes and documentation match active runtime | Pending W12 T-180, T-181 |
| Rollback rehearsed and remains available | `docs/MIGRATION_GUIDE.md` rollback section exists |
