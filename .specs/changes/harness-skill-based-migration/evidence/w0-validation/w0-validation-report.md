# W0 Validation Report

**Wave:** W0 — Baseline, freeze, and evidence
**Date:** 2026-07-20
**Validator:** Transitional adapter — parent session using `dev.faithfulness-guard` and `dev.judge-agent` equivalents.
**Independence note:** Target skills `dev-judge` and `dev-faithfulness-guard` are not yet created (W5 scope). This exception was explicitly approved in `bootstrap-decisions.md` and must be resolved by W5 T-068.

---

## Verdict

**PASS**

All 10 W0 tasks are done, evidence is complete, no scope violation was introduced by W0, no secret is present in evidence, and all open risks are tracked with explicit owners. W1 is unblocked.

---

## Task-by-Task Checklist

| Task | Status | Evidence | Acceptance criteria met | Rollback defined |
|---|---|---|---|---|
| T-000 | done | `t-000-package-creation.md` | ✅ Package exists; D-01–D-18 recorded; no runtime change | ✅ Delete migration directory |
| T-001 | done | `baseline.md`, `checksums.sha256` | ✅ 446 checksums pass; `.env` excluded; `docs/` explicit | ✅ Evidence-only removal |
| T-002 | done | `t-002-config-provenance.md` | ✅ Executable, env, MCP CLI, precedence documented; no secrets | ✅ Read-only |
| T-003 | done | `t-003-agent-capability.csv`, `t-003-agent-summary.md` | ✅ 75 agents, 2 primaries, 6 W5 targets recorded | ✅ Read-only |
| T-004 | done | `t-004-behavior-ownership.md` | ✅ 35 commands, 7 skills, 6 plugins, 6 missing refs, no hard-enforcement claim | ✅ Read-only |
| T-005 | done | `t-005-test-baseline.md` | ✅ CLI adapter selected; positive fixture PASS; negative defect recorded | ✅ Evidence-only removal |
| T-006 | done | `migration-scorecard.md` | ✅ 7 metrics with targets, methods, and baselines | ✅ Remove scorecard |
| T-007 | done | `t-007-runtime-baseline.md` | ✅ Version 1.18.3, executable SHA, schema SHA, update policy documented | ✅ Remove evidence |
| T-008 | done | `installation-topology.md` | ✅ All paths resolve from env-neutral root; no absolute `/home/ubuntu` dependency | ✅ Documentation-only |
| T-009 | done | `t-009-state-repair.md`, `active-state.md`, `kb-index.yaml` | ✅ One active change; Wave 25 lifecycle explicit; canonical control; index regenerated | ✅ Restore from T-001 checksums |

---

## Scope Audit

| Check | Result |
|---|---|
| `agents/` modified by W0 | PASS — 16 pre-existing changes; 0 introduced by W0 |
| `opencode.json` modified by W0 | PASS — pre-existing change; not touched by W0 |
| `plugins/` modified by W0 | PASS — pre-existing change; not touched by W0 |
| `commands/`, `skills/`, `tools/`, `test/` | PASS — untouched by W0 |
| `AGENTS.md` | PASS — untouched by W0 |
| W0 new files scope | PASS — all under `.specs/changes/harness-skill-based-migration/` and `.specs/memory/harness-skill-based-migration/` |
| W0 tracked modifications | PASS — `active-state.md`, `kb-index.yaml`, `control/README.md`, `.specs/control/README.md`, `control/INDEX.md`, and `control/` subdirectory files only |

---

## Evidence Integrity

| Check | Result |
|---|---|
| `sha256sum --check --status checksums.sha256` | PASS — all 446 entries verified |
| Secret scan on all evidence files | PASS — no API key, bearer token, authorization header, or credential value found |
| Whitespace check (`rtk git diff --check`) | PASS — no trailing whitespace errors |

---

## State Consistency

| Check | Result |
|---|---|
| `active-state.md` points to `harness-skill-based-migration` | PASS |
| No legacy active change declared alongside migration | PASS |
| Wave 25 lifecycle exception documented | PASS |
| `control/` declared canonical; `.specs/control/` historical | PASS |
| `kb-index.yaml` regenerated with current filesystem counts | PASS |
| `state.md` current task points to T-V00 | PASS |

---

## Faithfulness to Confirmed Decisions

| Decision | Respected by W0 |
|---|---|
| D-01: Built-in `build`/`plan` as only primary hosts | ✅ No custom primary was created or elevated |
| D-02: Parent is the only managed TODO/state writer | ✅ All W0 writes were parent-only |
| D-03: Leaf subagents deny Task and todowrite | Not applicable to W0 (discovery only) |
| D-04: Leaf write scope is allocation-bounded | Not applicable to W0 |
| D-05: Recursive delegation is forbidden | ✅ No delegation occurred |
| D-06: Every execution task belongs to a validation block | ✅ All W0 tasks in block W0 |
| D-07: Six dev agents become skills; legacy files deleted only after W11 | ✅ No agent was converted or deleted |
| D-08: Altitude and AgentSpec keep separate contracts | Not applicable to W0 |
| D-09: `/workflow:*` names remain compatible | Not applicable to W0 |
| D-10: All requested MCPs remain | ✅ No MCP was removed |
| D-11: `.specs` is authoritative operational state | ✅ All evidence is in `.specs/changes/` |
| D-12: Runtime changes through one atomic cutover bundle | Not applicable to W0 |
| D-13: Parent Task permissions default-deny with allowlist | Not applicable to W0 |
| D-14: Managed delegation sequential by default | ✅ No parallel delegation occurred |
| D-15: Writer lease prevents concurrent parent mutation | Not applicable to W0 |
| D-16: Runtime, schema, MCPs, plugins pinned | ✅ T-007 recorded the runtime pin |
| D-17: Only compact kernel always loaded; rules/skills lazy | Not applicable to W0 |
| D-18: MCP output is untrusted data | Not applicable to W0 |

---

## Non-Negotiable Invariants

| Invariant | Status |
|---|---|
| No custom agent is primary (target) | Not yet met — 2 custom primaries exist; W6 is the resolution wave |
| No managed leaf calls Task or reads/writes global TODO | ✅ No leaf was invoked |
| No leaf broadens write scope | ✅ No leaf was invoked |
| No managed delegation without parent TODO ID and allocation | ✅ No delegation occurred |
| No wave advances without T-Vxx PASS | ✅ This report is T-V00; W1 blocked until this PASS |
| No active AGENTS/config replaced before W12 | ✅ No runtime surface was replaced |
| No legacy agent deleted before W11 and W12 | ✅ No agent was deleted |
| No complex Altitude change skips Intent/Structure/Design | Not applicable to W0 |
| No AgentSpec command mutates Altitude state | Not applicable to W0 |
| No MCP result changes workflow authority | Not applicable to W0 |

---

## Open Risks Carried Forward

| Risk | Severity | Owner | Resolution |
|---|---|---|---|
| Legacy `.specs` state active/archive conflict (Wave 25) | Medium | W12 T-175 | Documented as retained evidence; not two active changes |
| Two custom primary agents exist | Critical | W6 T-081 | Tracked; no cutover blocker for W0–W5 |
| Global Task/TODO allow on all 75 subagents | Critical | W6 T-085 | Tracked; no cutover blocker for W0–W5 |
| T-V00 uses transitional validator, not target W5 skills | Medium | W5 T-068 | Documented exception; must be re-validated at W5 |
| Unknown-agent fallback produces warning not failure | Medium | W11 T-146 | Recorded in T-005 as baseline defect |
| `opencode debug config` emits non-JSON output | Low | T-159 | Recorded in T-002; no diagnostic value lost |

---

## Defect Summary

| Severity | Open | Accepted with owner |
|---|---|---|
| Critical | 0 unresolved for W0 | 2 tracked with W6 owners |
| High | 0 | 0 |
| Medium | 0 unresolved for W0 | 3 tracked with future wave owners |
| Low | 0 unresolved for W0 | 1 tracked |

No critical or high defect is unresolved for W0. W1 is unblocked.

---

## Memory Event

- Trigger: wave_validation
- Change: harness-skill-based-migration
- Wave: W0
- Result: PASS
- Next action: advance to W1 after parent accepts this verdict.
