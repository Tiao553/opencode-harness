---
name: validate
description: Multi-agent quality gate via Copilot-native juntas (Phase 3.5)
---

# /workflow:validate — Quality Gate (Phase 3.5)

> Orchestrates 4 hierarchical juntas to validate an implemented feature before shipping.

## Usage

```bash
/workflow:validate <BUILD_REPORT_path_or_FEATURE_NAME>
```

**Examples:**

```bash
/workflow:validate ~/.config/opencode/sdd/features/BRONZE_SILVER/BUILD_REPORT_BRONZE_SILVER.md
/workflow:validate BRONZE_SILVER
```

## SDD Phase Flow

```text
/workflow:brainstorm → /workflow:define → /workflow:design → /workflow:build → [/workflow:validate] → /workflow:ship
                                               ↑ you are here
```

## Prerequisites

| Prerequisite         | Path                                                               |
|----------------------|--------------------------------------------------------------------|
| DEFINE document      | `~/.config/opencode/sdd/features/{feature-name}/DEFINE_{FEATURE}.md`       |
| DESIGN document      | `~/.config/opencode/sdd/features/{feature-name}/DESIGN_{FEATURE}.md`       |
| BUILD_REPORT         | `~/.config/opencode/sdd/features/{feature-name}/BUILD_REPORT_{FEATURE}.md` |
| Implementation files | `{output_path}/`                                         |

If any prerequisite is missing, **STOP** and tell the user exactly what is missing.

## Process

### Step 1: Load Contracts

1. Read `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
2. Read `~/.config/opencode/sdd/architecture/VALIDATE_JUNTAS_CONTRACT.yaml`

### Step 2: Activate Agent

Read and activate `~/.config/opencode/agents/workflow.validate-agent.agent.md`.
The agent contains the full orchestration protocol.

### Step 3: Build Frozen Evidence Pack

1. Read DEFINE, DESIGN, BUILD_REPORT from the **global** feature directory (`~/.config/opencode/sdd/features/{feature-name}/`)
2. If any artifact is missing globally, check local mirror (`./specs/`) before failing
3. Scan `{output_path}/` to build code_tree
4. Create `_validate/` directories in both global and local paths:

```bash
mkdir -p ~/.config/opencode/sdd/features/{feature-name}/_validate/
mkdir -p ./specs/_validate/
```

### Step 4: Launch Parallel Juntas (Spec + Code)

Launch TWO `general-purpose` sub-agents in **background** mode.

**Spec Junta:**

- Read prompt: `~/.config/opencode/skills/workflow-commands/references/spec-junta.md`
- Pass frozen evidence pack
- Expected output: `01_SPEC_REPORT_{FEATURE}.json`

**Code Junta:**

- Read prompt: `~/.config/opencode/skills/workflow-commands/references/code-junta.md`
- Pass frozen evidence pack
- Expected output: `02_CODE_REPORT_{FEATURE}.json`

### Step 5: Launch Delivery Junta (Sequential)

After both parallel juntas complete:

- Read prompt: `~/.config/opencode/skills/workflow-commands/references/delivery-junta.md`
- Pass evidence pack + SpecReport + CodeReport
- Expected output: `03_DELIVERY_DELTA_{FEATURE}.json`

### Step 6: Deterministic Scoring

Compute score **without LLM** — pure arithmetic:

```text
score = alignment × 0.30 + quality × 0.25 + architecture × 0.20
      + devops × 0.15 + delta × 0.10

critical_count = count(findings where severity == "CRITICAL")
```

Save: `05_SCORING_{FEATURE}.json`

### Step 7: Launch Council (Narrative Only)

- Read prompt: `~/.config/opencode/skills/workflow-commands/references/council-junta.md`
- Pass all reports + scoring
- Council MUST NOT change scores or eligibility
- Expected output: `04_COUNCIL_VERDICT_{FEATURE}.json`

### Step 8: Render Artifacts (Write Global → Copy Flat — MANDATORY)

Use templates from `~/.config/opencode/sdd/templates/` to generate final artifacts.
Write to global first, then `cp` flat to `./specs/` before marking complete.

| Score | CRITICAL | Artifacts to write              |
|-------|----------|---------------------------------|
| ≥ 90  | 0        | `VALIDATION_REPORT` + `RUNBOOK` |
| 70-89 | 0        | `VALIDATION_REPORT` + `ROADMAP` |
| < 70  | Any      | `VALIDATION_REPORT` only        |

```bash
# Global (system of record)
Write(~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md)
Write(~/.config/opencode/sdd/features/{feature-name}/RUNBOOK_{FEATURE}.md)   # if approved
Write(~/.config/opencode/sdd/features/{feature-name}/ROADMAP_{FEATURE}.md)   # if remediation

# Flat local mirror (cp — do not write separately)
mkdir -p ./specs/
cp ~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md ./specs/VALIDATION_REPORT_{FEATURE}.md
cp ~/.config/opencode/sdd/features/{feature-name}/RUNBOOK_{FEATURE}.md        ./specs/RUNBOOK_{FEATURE}.md         # if approved
cp ~/.config/opencode/sdd/features/{feature-name}/ROADMAP_{FEATURE}.md        ./specs/ROADMAP_{FEATURE}.md         # if remediation
```

Also copy the intermediate JSON reports to the flat local `_validate/`:

```bash
mkdir -p ./specs/_validate/
cp ~/.config/opencode/sdd/features/{feature-name}/_validate/01_SPEC_REPORT_{FEATURE}.json     ./specs/_validate/
cp ~/.config/opencode/sdd/features/{feature-name}/_validate/02_CODE_REPORT_{FEATURE}.json     ./specs/_validate/
cp ~/.config/opencode/sdd/features/{feature-name}/_validate/03_DELIVERY_DELTA_{FEATURE}.json  ./specs/_validate/
cp ~/.config/opencode/sdd/features/{feature-name}/_validate/04_COUNCIL_VERDICT_{FEATURE}.json ./specs/_validate/
cp ~/.config/opencode/sdd/features/{feature-name}/_validate/05_SCORING_{FEATURE}.json         ./specs/_validate/
```

## Quality Gates

```text
VALIDATE QUALITY CHECK
├─ [ ] All prerequisites exist (checked in global; fallback to local)
├─ [ ] Frozen evidence pack built (identical for all juntas)
├─ [ ] Spec Junta returned valid JSON
├─ [ ] Code Junta returned valid JSON
├─ [ ] Delivery Junta returned valid JSON
├─ [ ] Deterministic scoring computed (no LLM)
├─ [ ] Council verdict received (narrative only)
├─ [ ] All 5 intermediate JSONs saved to global _validate/ AND local _validate/
├─ [ ] VALIDATION_REPORT written to BOTH global and local paths
├─ [ ] RUNBOOK or ROADMAP written to BOTH global and local paths (based on eligibility)
└─ [ ] Score and verdict reported to user
```

## Output

### Intermediate (saved to both `_validate/` directories)

```text
~/.config/opencode/sdd/features/{feature-name}/_validate/   ← global
./specs/_validate/                                  ← flat local mirror
├── 01_SPEC_REPORT_{FEATURE}.json
├── 02_CODE_REPORT_{FEATURE}.json
├── 03_DELIVERY_DELTA_{FEATURE}.json
├── 04_COUNCIL_VERDICT_{FEATURE}.json
└── 05_SCORING_{FEATURE}.json
```

### Final

| Artifact              | Global Path                                                             | Local Path                               |
|-----------------------|-------------------------------------------------------------------------|------------------------------------------|
| **VALIDATION_REPORT** | `~/.config/opencode/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md` | `./specs/VALIDATION_REPORT_{FEATURE}.md` |
| **RUNBOOK**           | `~/.config/opencode/sdd/features/{feature-name}/RUNBOOK_{FEATURE}.md`           | `./specs/RUNBOOK_{FEATURE}.md`           |
| **ROADMAP**           | `~/.config/opencode/sdd/features/{feature-name}/ROADMAP_{FEATURE}.md`           | `./specs/ROADMAP_{FEATURE}.md`           |

## Next Step

- If PASSED (score ≥ 90, 0 CRITICAL): `/workflow:ship`
- If WARNING or FAILED: Remediate issues, then `/workflow:validate` again

## References

- Agent: `~/.config/opencode/agents/workflow.validate-agent.agent.md`
- Junta Contract: `~/.config/opencode/sdd/architecture/VALIDATE_JUNTAS_CONTRACT.yaml`
- Workflow Contract: `~/.config/opencode/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Templates: `~/.config/opencode/sdd/templates/VALIDATION_REPORT_TEMPLATE.md`
- Next: `~/.config/opencode/skills/workflow-commands/commands/ship.md`
