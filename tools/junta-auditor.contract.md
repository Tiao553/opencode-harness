# Junta Auditor Contract

## Purpose

Define the command interface and behavior of `tools/junta-auditor.sh` for meta-validation audits.

---

## Tool Specification

**Name:** junta-auditor.sh  
**Type:** Bash executable  
**Location:** `tools/junta-auditor.sh`  
**Depends On:** `.specs/shared/meta-validation-contract.md`  
**Used By:** `agents/altitude-validation.agent.md` (W15 integration)

---

## Commands

### Command 1: `audit <junta-name>`

**Purpose:** Audit a specific junta (validator) from W7-W14.

**Syntax:**
```bash
tools/junta-auditor.sh audit <junta-name>
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `junta-name` | String | Yes | Name of junta to audit (see Known Juntas) |

**Known Juntas:**
- `ralph-loop` — W7 Ralph Loop Validator
- `kb-quality` — W8 KB Quality Validator
- `security` — W9 Security Scanner Validator
- `metrics` — W10 Metrics Collector Validator
- `state-machine` — W11 State Machine Validator
- `recovery` — W12 Recovery Validator
- `orchestration` — W13 Orchestration Validator
- `protocols` — W14 Protocol Validator

**Output Format:** JSON (see Output Schema)

**Exit Codes:**
| Code | Meaning |
|------|---------|
| 0 | Audit completed successfully |
| 1 | Unknown junta name or missing parameter |

**Example:**
```bash
# Audit the Ralph Loop validator
$ tools/junta-auditor.sh audit ralph-loop

# Output:
# ✓ Audit complete: .specs/changes/waves-7-17-implementation/validation/junta-audits/audit-ralph-loop.json
# { "audit": {...}, "quality_assessment": {...}, ... }
```

**Output Schema:**
```json
{
  "audit": {
    "junta_name": "string",
    "wave_info": "string",
    "audit_timestamp": "ISO8601",
    "audit_version": 1
  },
  "quality_assessment": {
    "clarity": 0-100,
    "consistency": 0-100,
    "completeness": 0-100,
    "calibration": 0-100,
    "documentation": 0-100,
    "overall_quality_score": 0-100,
    "quality_status": "EXCELLENT|ACCEPTABLE|POOR"
  },
  "bias_detection": [
    {
      "bias_name": "string",
      "detected": boolean,
      "severity": "CRITICAL|HIGH|MEDIUM|LOW|NONE",
      "evidence": "string",
      "remediation": "string"
    }
  ],
  "critical_biases_found": integer,
  "high_biases_found": integer,
  "medium_biases_found": integer,
  "production_readiness": "EXCELLENT|ACCEPTABLE|POOR",
  "recommendations": "string",
  "audit_status": "COMPLETE"
}
```

---

### Command 2: `audit-all`

**Purpose:** Audit all 8 juntas from W7-W14 in batch.

**Syntax:**
```bash
tools/junta-auditor.sh audit-all
```

**Parameters:** None

**Output Format:** Summary + individual JSON files

**Exit Codes:**
| Code | Meaning |
|------|---------|
| 0 | All audits completed |
| 1 | Critical error (e.g., audit directory not writable) |

**Example:**
```bash
# Audit all juntas
$ tools/junta-auditor.sh audit-all

# Output:
# Auditing all juntas from W7-W14...
# ✓ Audit complete: .../audit-ralph-loop.json
# ✓ Audit complete: .../audit-kb-quality.json
# ... (6 more)
#
# Audit Summary:
#   Total juntas: 8
#   Excellent: 2
#   Acceptable: 5
#   Poor: 1
#
# Summary saved to: .../audit-summary-2026-06-30T12:00:00Z.json
```

**Behavior:**
1. Iterate over all 8 known juntas
2. Call `audit <junta-name>` for each
3. Aggregate results
4. Output summary statistics

---

### Command 3: `bias-report`

**Purpose:** Generate a summary report of all detected biases across all juntas.

**Syntax:**
```bash
tools/junta-auditor.sh bias-report
```

**Parameters:** None

**Output Format:** Markdown-formatted report

**Exit Codes:**
| Code | Meaning |
|------|---------|
| 0 | Report generated successfully |
| 1 | No audits found |

**Example:**
```bash
# Generate bias report
$ tools/junta-auditor.sh bias-report

# Output:
# Junta Bias Report
# =================
#
# Junta: ralph-loop
#   Critical: 0
#   High: 1
#   Medium: 2
#
# Junta: kb-quality
#   Critical: 0
#   High: 0
#   Medium: 0
#
# Overall Bias Statistics:
#   Total Critical Biases: 0
#   Total High Biases: 1
#   Total Medium Biases: 5
```

**Report Sections:**
1. Per-junta bias summary (critical/high/medium counts)
2. Overall statistics
3. Recommendations (if any CRITICAL or HIGH biases)

---

### Command 4: `list`

**Purpose:** List all previously generated audit files.

**Syntax:**
```bash
tools/junta-auditor.sh list
```

**Parameters:** None

**Output Format:** Plain text list

**Exit Codes:**
| Code | Meaning |
|------|---------|
| 0 | List generated (even if empty) |
| 1 | Error reading audit directory |

**Example:**
```bash
# List all audit files
$ tools/junta-auditor.sh list

# Output:
# Available audits:
#   - audit-ralph-loop.json
#   - audit-kb-quality.json
#   - audit-security.json
#   - audit-metrics.json
#   - audit-state-machine.json
#   - audit-recovery.json
#   - audit-orchestration.json
#   - audit-protocols.json
```

---

## Storage

### Audit Directory Structure

```
.specs/changes/waves-7-17-implementation/
└── validation/
    └── junta-audits/
        ├── audit-ralph-loop.json
        ├── audit-kb-quality.json
        ├── audit-security.json
        ├── audit-metrics.json
        ├── audit-state-machine.json
        ├── audit-recovery.json
        ├── audit-orchestration.json
        ├── audit-protocols.json
        └── audit-summary-2026-06-30T12:00:00Z.json
```

### File Naming Convention

- Individual audits: `audit-<junta-name>.json`
- Summary: `audit-summary-<ISO8601-timestamp>.json`

### Persistence

- Audit files are persistent (not deleted between runs)
- Old audits are kept for historical comparison
- Summary files are timestamped to distinguish multiple runs

---

## Integration

### Usage in Altitude Validation

**Location:** `agents/altitude-validation.agent.md` (Wave 15)

**Pattern:**
```bash
# Before running standard juntas, audit validators themselves
echo "Meta-validating validators..."

# Audit all juntas
tools/junta-auditor.sh audit-all

# Generate bias report
tools/junta-auditor.sh bias-report > /tmp/junta-bias-report.txt

# Check for CRITICAL biases
if grep -q "Critical:" /tmp/junta-bias-report.txt; then
    echo "⚠️ CRITICAL biases detected in juntas"
    # Alert validation council
fi
```

### Usage in Validation Reports

Junta audit results are included in validation reports:

```markdown
## Junta Quality Assessment (Meta-Validation)

[Include audit summary from tools/junta-auditor.sh audit-all]

### Quality Scores by Junta
[Table of quality_status for each junta]

### Detected Biases
[Summary of biases found, if any]

### Recommendations
[Based on audit results]
```

---

## Error Handling

### Error Cases

| Error | Cause | Action |
|-------|-------|--------|
| Unknown junta name | User provided invalid junta name | Print error + list known juntas; exit 1 |
| Audit directory not writable | Permission issue | Print error with path; exit 1 |
| Malformed audit file | Previous audit corrupted | Delete and re-run audit; exit 0 |

### Recovery

- All errors are logged to stderr
- Audit directory is created automatically if missing
- Script is idempotent (safe to re-run)

---

## Performance

| Operation | Typical Time | Notes |
|-----------|--------------|-------|
| `audit <junta>` | <1 second | Single junta analysis |
| `audit-all` | 5-10 seconds | All 8 juntas in sequence |
| `bias-report` | <1 second | Reads existing audit files |
| `list` | <1 second | Directory listing |

---

## Constraints

- **Read-only for juntas:** Audit does NOT modify validators
- **Advisory only:** Audit results do not block execution
- **Local data only:** No network calls
- **Deterministic:** Same input always produces same output

---

## Examples

### Example 1: Quick audit of one junta

```bash
$ tools/junta-auditor.sh audit kb-quality
# Output: JSON report with quality_status and bias_detection
```

### Example 2: Full audit suite before validation

```bash
$ tools/junta-auditor.sh audit-all
$ tools/junta-auditor.sh bias-report
# Outputs: Summary + per-junta reports + bias summary
```

### Example 3: Checking for specific bias in validation

```bash
$ tools/junta-auditor.sh audit ralph-loop | jq '.bias_detection[] | select(.severity == "CRITICAL")'
# Outputs: Only CRITICAL-severity biases found in ralph-loop junta
```

### Example 4: Audit results in validation workflow

```bash
# In altitude-validation.agent.md:
audit_status=$(tools/junta-auditor.sh audit-all 2>&1)

if echo "$audit_status" | grep -q "Poor"; then
    echo "⚠️ Some juntas have poor quality. Documenting in validation report."
fi
```

---

## Related Documents

- `.specs/shared/meta-validation-contract.md` — Audit rules and bias definitions
- `.specs/shared/altitude-validation-juntas-contract.md` — Junta architecture
- `agents/altitude-validation.agent.md` — Integration point (W15)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-30 | Initial contract; 4 commands (audit, audit-all, bias-report, list) |

---

## Acceptance Criteria

This contract is complete when:

- ✅ All 4 commands are documented with examples
- ✅ Output schemas are clear and parseable
- ✅ Error handling is defined
- ✅ Integration point with altitude-validation is specified
- ✅ Tool produces JSON output that matches schema
