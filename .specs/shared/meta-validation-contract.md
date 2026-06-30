# Meta-Validation Contract: Junta Audit

## Purpose

Define how to audit the validators (juntas) themselves from Waves 7-14 for quality, bias detection, and remediation paths.

This is the "validator of validators" — ensures that the junta scoring system is itself fair, unbiased, and of high quality.

---

## Audit Scope

Meta-validation audits 8 validators created in Waves 7-14:

| Wave | Junta Name | Purpose | Role |
|------|-----------|---------|------|
| W7 | Ralph Loop Validator | Decision trace quality | Foundational verification |
| W8 | KB Quality Validator | KB domain rating fairness | Knowledge base governance |
| W9 | Security Scanner Validator | Secrets/vulnerability severity | Security assessment |
| W10 | Metrics Collector Validator | Metric usefulness assessment | Observability |
| W11 | State Machine Validator | State transition correctness | Runtime behavior |
| W12 | Recovery Validator | Rollback atomicity and safety | Fault tolerance |
| W13 | Orchestration Validator | DAG order and scheduling | Pipeline orchestration |
| W14 | Protocol Validator | Message arrival and protocol | System integration |

---

## Junta Audit Rules

### Schema

```yaml
junta_audit_rules:
  version: 1.0
  audit_scope:
    - wave: W7
      junta: ralph-loop
    - wave: W8
      junta: kb-quality
    - wave: W9
      junta: security
    - wave: W10
      junta: metrics
    - wave: W11
      junta: state-machine
    - wave: W12
      junta: recovery
    - wave: W13
      junta: orchestration
    - wave: W14
      junta: protocols
  quality_dimensions:
    - name: clarity
      range: [0, 100]
      description: "Scoring criteria are explicit and unambiguous"
    - name: consistency
      range: [0, 100]
      description: "Junta applies same rules to similar inputs"
    - name: completeness
      range: [0, 100]
      description: "Junta covers all expected scenarios"
    - name: calibration
      range: [0, 100]
      description: "Scores are well-distributed"
    - name: documentation
      range: [0, 100]
      description: "Junta logic is documented and traceable"
  bias_types:
    - name: over-scoring
    - name: under-scoring
    - name: volatility
    - name: recency
    - name: confirmation
    - name: anchoring
```

### Quality Rubric

Every junta is scored on 5 dimensions:

| Dimension | Range | Measures |
|-----------|-------|----------|
| **Rubric Clarity** | 0-100 | Are scoring criteria explicit and unambiguous? |
| **Consistency** | 0-100 | Does the junta apply the same rules to similar inputs? |
| **Completeness** | 0-100 | Does the junta cover all expected scenarios? |
| **Calibration** | 0-100 | Are scores well-distributed (not all high or all low)? |
| **Documentation** | 0-100 | Is the junta's logic documented and traceable? |

**Quality Score Formula:**
```
quality_score = (clarity + consistency + completeness + calibration + documentation) / 5
```

**Quality Thresholds:**
- ✅ EXCELLENT: >= 85 (production-ready validator)
- ⚠️ ACCEPTABLE: 70-84 (usable but needs improvement)
- ❌ POOR: < 70 (requires remediation before use)

### Bias Detection Metrics

Detect systematic scoring biases:

| Bias Type | Definition | Threshold | Detection Method |
|-----------|-----------|-----------|------------------|
| **Over-scoring Bias** | Junta consistently gives high scores | avg_score > 80 for uniform inputs | Compare actual vs. expected distribution |
| **Under-scoring Bias** | Junta consistently gives low scores | avg_score < 40 for good inputs | Compare actual vs. expected distribution |
| **Volatility Bias** | Junta scores vary wildly for similar inputs | stddev > 25 | Calculate standard deviation across similar cases |
| **Recency Bias** | Junta weights recent results too heavily | correlation > 0.7 with chronology | Score similar inputs from different time periods |
| **Confirmation Bias** | Junta over-weights evidence that confirms initial assessment | ratio of supporting/challenging > 3:1 | Audit finding selectivity |
| **Anchoring Bias** | Junta's scores cluster around initial reference points | multi-modal score distribution | Analyze score frequency patterns |

### Audit Scoring

For each bias metric, record:
```yaml
bias_name: "Over-scoring Bias"
detected: true | false
severity: "CRITICAL" | "HIGH" | "MEDIUM" | "LOW" | "NONE"
evidence: "explanation with data"
affected_scores: [list of scores]
remediation: "suggested fix"
```

---

## Remediation Paths

When biases are detected, document remediation:

### Severity Levels

- **CRITICAL:** Junta is unreliable; exclude from scoring until fixed
- **HIGH:** Junta has systematic issues; flag findings in validation reports
- **MEDIUM:** Junta has minor biases; document in metadata; proceed with caution
- **LOW:** Junta has cosmetic biases; note for future improvement
- **NONE:** Junta is unbiased

### Remediation Templates

#### Template 1: Rubric Refinement
```yaml
remediation_type: "Rubric Refinement"
issue: "Scoring criteria are ambiguous; results vary"
fix:
  - Add explicit scoring examples
  - Break rubric into smaller, measurable criteria
  - Create decision tree for borderline cases
effort: "Low (1-2 hours)"
```

#### Template 2: Validator Retraining
```yaml
remediation_type: "Validator Retraining"
issue: "Junta applies rules inconsistently"
fix:
  - Collect sample inputs with expected outputs
  - Show junta examples of consistent scoring
  - Re-run audit to verify consistency
effort: "Medium (2-4 hours)"
```

#### Template 3: Scope Adjustment
```yaml
remediation_type: "Scope Adjustment"
issue: "Junta scores inputs outside intended scope"
fix:
  - Document intended scope explicitly
  - Add pre-screening to reject out-of-scope inputs
  - Calibrate thresholds for in-scope inputs only
effort: "Low (1-2 hours)"
```

#### Template 4: Weighting Recalibration
```yaml
remediation_type: "Weighting Recalibration"
issue: "Junta over/under-weights specific dimensions"
fix:
  - Audit dimension weighting formulas
  - Adjust weights to match desired distribution
  - Re-validate on representative sample
effort: "Medium (2-4 hours)"
```

#### Template 5: Human Expert Review
```yaml
remediation_type: "Human Expert Review"
issue: "Junta reasoning is unpredictable or biased"
fix:
  - Assign domain expert to audit junta outputs
  - Document patterns in junta's thinking
  - Provide feedback to refine junta's approach
effort: "High (4+ hours)"
```

---

## Audit Report Schema

Every junta audit produces a JSON report:

```json
{
  "audit": {
    "junta_name": "Ralph Loop Validator",
    "wave": "W7",
    "audit_timestamp": "2026-06-30T12:00:00Z",
    "audit_version": 1
  },
  "quality_assessment": {
    "clarity": 85,
    "consistency": 80,
    "completeness": 90,
    "calibration": 75,
    "documentation": 88,
    "overall_quality_score": 83.6,
    "quality_status": "ACCEPTABLE"
  },
  "bias_detection": [
    {
      "bias_name": "Over-scoring Bias",
      "detected": true,
      "severity": "MEDIUM",
      "evidence": "Avg score 82 across diverse input quality",
      "affected_scores": [80, 85, 78, 82, 79],
      "remediation": "Recalibrate threshold from 70 to 60"
    }
  ],
  "critical_biases_found": 0,
  "high_biases_found": 1,
  "medium_biases_found": 1,
  "remediation_tasks": [
    {
      "task_id": "FIX-W7-CLARITY",
      "task_name": "Improve Ralph Loop Rubric Clarity",
      "type": "Rubric Refinement",
      "priority": 2,
      "estimated_effort": "Low (1-2 hours)",
      "blocked_by": [],
      "blocks": []
    }
  ],
  "production_readiness": "ACCEPTABLE_WITH_CAVEATS",
  "recommendations": "Junta is acceptable for use. Document over-scoring tendency in reports. Recommend Rubric Refinement in next wave.",
  "next_audit_trigger": "After any changes to junta logic or scoring formulas"
}
```

---

## Audit Execution Protocol

### Phase 1: Preparation

1. Load list of 8 juntas from W7-W14
2. For each junta, collect:
   - Junta definition / prompt
   - Sample inputs and outputs (if available)
   - Historical scores (if available)
   - Documentation

### Phase 2: Quality Assessment

For each junta:
1. Review rubric clarity (is it explicit?)
2. Check consistency rules (does junta apply them uniformly?)
3. Validate completeness (does junta cover all scenarios?)
4. Measure calibration (are scores well-distributed?)
5. Audit documentation (is reasoning traceable?)

Score each dimension 0-100.

### Phase 3: Bias Detection

For each detected bias:
1. Collect evidence (specific scores, inputs)
2. Calculate severity level
3. Document remediation path

### Phase 4: Report Generation

Generate audit report JSON + summary markdown.

---

## Integration Points

### Where Meta-Audit is Triggered

1. **Altitude Validation Agent** — Before running standard juntas
   - Call: `tools/junta-auditor.sh audit-all`
   - Record: Audit results in validation report
   - Action: Alert if CRITICAL biases found

2. **Validation Report** — Include junta audit results
   - Section: "Junta Quality Assessment"
   - Content: Quality scores + bias summary

3. **Wave 17 (Final Validation)** — Use audit to contextualize junta scores
   - If junta has HIGH bias: discount score by 10-15%
   - If junta has CRITICAL bias: exclude from scoring (use council override)

### Audit Result Actions

| Status | Action |
|--------|--------|
| EXCELLENT (all >= 85) | Proceed normally; no alerts |
| ACCEPTABLE (70-84) | Proceed with caution; document tendencies |
| POOR (< 70) | Alert user; recommend remediation; can still proceed if user accepts risk |
| CRITICAL BIAS | Block validation until reviewed; escalate to validation council |

---

## Constraints

- **Read-only:** Meta-audit does NOT modify validators (juntas)
- **Advisory:** Audit results are advisory (do NOT block W16, W17)
- **Remediation:** Remediation paths are documented but not implemented (user decides)
- **Scope:** Audit only focuses on junta quality and bias (not task implementation quality)

---

## Success Criteria

Meta-validation is complete when:

- ✅ Contract defines junta audit rules and bias detection metrics
- ✅ Quality rubric has 5 dimensions with scoring ranges
- ✅ 6+ bias types defined with detection methods
- ✅ Remediation paths documented with effort estimates
- ✅ Audit report schema is clear and parseable
- ✅ Integration points specified (when audit is triggered)
- ✅ Tool implements all audit commands
- ✅ Audit results inform W17 final validation

---

## Source Authority

- **Pattern:** Grounded in quality assurance and validator verification
- **Extended:** Validates altitude-validation-juntas-contract.md
- **Tools:** Implements tools/junta-auditor.sh
- **Integration:** Used by agents/altitude-validation.agent.md in W15

---

## Related Documents

- `.specs/shared/altitude-validation-juntas-contract.md` — Junta architecture
- `.specs/shared/task-contract.md` — Task quality rubric
- `tools/junta-auditor.sh` — Audit implementation
- `agents/altitude-validation.agent.md` — Integration point
