# In-Flight Change Migration and Canonical Control Surface

**Purpose:** Define the policy for in-flight changes that existed before the skill-based migration started, resolve the canonical control surface, and document how each legacy change is handled.

**Source authority:** T-009 state repair, T-001 baseline, Roadmap V2 D-12, W0 bootstrap decisions.

**Last verified:** W0 baseline (2026-07-20).

---

## In-Flight Changes at W0 Baseline

The following changes were present in `.specs/changes/` when the migration started:

| Change ID | State at T-001 | Disposition |
|---|---|---|
| `harness-skill-based-migration` | New — created by T-000 | Active; this migration |
| `wave-25-allocation-consolidation` | Shipped (shipped commit message confirms it) | Retained as shipped evidence in both `changes/` and `archive/`; explicit lifecycle exception (T-009) |
| `harness-360-refactor` | Unknown — needs inspection | Classify in W1 T-019 |
| `harness-v3-artifact-allocation-hardening` | Unknown | Classify in W1 T-019 |
| `harness-v3-data-engineer-coordinator` | Unknown | Classify in W1 T-019 |
| `harness-v3-delegation-migration` | Unknown | Classify in W1 T-019 |
| `harness-v3-grounding-split` | Unknown | Classify in W1 T-019 |
| `harness-v3-ralph-loop-globalization` | Unknown | Classify in W1 T-019 |
| `harness-v3-safety-foundation` | Unknown | Classify in W1 T-019 |
| `harness-v3-strategic-coordinator` | Unknown | Classify in W1 T-019 |
| `harness-v3-task-spec-integration` | Unknown | Classify in W1 T-019 |
| `harness-v3-unified-phase-contract` | Unknown | Classify in W1 T-019 |
| `w9-security` | Unknown | Classify in W1 T-019 |
| `wave-24` | Unknown | Classify in W1 T-019 |
| `wave-3b-runtime-enforcement` | Unknown | Classify in W1 T-019 |
| `wave-4-artifact-versioning` | Unknown | Classify in W1 T-019 |
| `wave-5-allocation-enforcement` | Unknown | Classify in W1 T-019 |
| `wave-6-context-budget` | Unknown | Classify in W1 T-019 |
| `waves-18-23-implementation` | Unknown (active-state referenced it) | Classify in W1 T-019 |

---

## Disposition Options

Each unclassified change must be assigned exactly one disposition:

| Disposition | Meaning | Action |
|---|---|---|
| `shipped` | Change completed successfully before migration start | Retain in `changes/` as evidence; verify against archive |
| `archive` | Change completed or abandoned; move to `.specs/archive/` | Move and update `active-state.md` |
| `freeze` | Change was in progress; paused for migration duration | Mark state as frozen; no mutation until migration ships |
| `incompatible` | Change conflicts with migration targets | Document conflict; block cutover until resolved |

---

## Classification Rule

To classify an unknown change:

1. Read its `state.md` for declared status.
2. Check whether it appears in `.specs/archive/`.
3. Check the last commit message mentioning it.
4. If still ambiguous, apply the **conservative default: freeze** until W12 cleanup.

No unknown change may be silently deleted in W0–W11.

---

## Canonical Control Surface Decision (T-009)

| Surface | Status | Authority |
|---|---|---|
| `control/` | **Canonical active meta-governance** | Use for current strategic planning and roadmap tracking |
| `.specs/control/` | **Historical reference only** | Do not use as active governance authority; retained for audit trail |

This decision was applied by T-009 and is recorded in:
- `.specs/memory/harness-skill-based-migration/bootstrap-decisions.md`
- `.specs/memory/active-state.md`
- `control/README.md` and `.specs/control/README.md`

---

## Canonical Input File Storage

The three migration input files are currently gitignored (`*` rule in `.gitignore`):

- `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_ROADMAP_V2.md`
- `OPENCODE_HARNESS_SKILL_BASED_MIGRATION_BACKLOG_V2.csv`
- `OPENCODE_HARNESS_DETERMINISTIC_AUDIT.md`

**Decision:** These files must be preserved by the operator outside git tracking until W4 decides whether to add explicit `.gitignore` allowlist entries or move them to a tracked location. No migration task may proceed if these files are absent.

---

## Next Actions

| Action | Owner task |
|---|---|
| Classify all 17 unknown in-flight changes | W1 T-019 implementation |
| Decide canonical storage for migration input files | W4 T-059 activation manifest |
| Verify no incompatible change blocks cutover | W11 T-162 |
| Archive all shipped/frozen changes | W12 T-175 |
