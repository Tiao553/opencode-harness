"""
render.py — Template renderer for /validate junta outputs.

Reads intermediate JSON files from _validate/ and renders final
markdown artifacts using SDD templates.

Usage:
  python ~/.copilot/skills/workflow-commands/scripts/render.py FEATURE_NAME

Reads from:
  ~/.copilot/sdd/features/{feature-name}/_validate/01_SPEC_REPORT_{FEATURE}.json
  ~/.copilot/sdd/features/{feature-name}/_validate/02_CODE_REPORT_{FEATURE}.json
  ~/.copilot/sdd/features/{feature-name}/_validate/03_DELIVERY_DELTA_{FEATURE}.json
  ~/.copilot/sdd/features/{feature-name}/_validate/04_COUNCIL_VERDICT_{FEATURE}.json
  ~/.copilot/sdd/features/{feature-name}/_validate/05_SCORING_{FEATURE}.json

Writes to:
  ~/.copilot/sdd/features/{feature-name}/VALIDATION_REPORT_{FEATURE}.md (always)
  ~/.copilot/sdd/features/{feature-name}/RUNBOOK_{FEATURE}.md (if eligible)
  ~/.copilot/sdd/features/{feature-name}/ROADMAP_{FEATURE}.md (if eligible)
"""

import json
import sys
from datetime import date
from pathlib import Path

SDD_ROOT = Path("~/.copilot/sdd")
TEMPLATES_DIR = SDD_ROOT / "templates"
FEATURES_DIR = SDD_ROOT / "features"


def _find_feature_dir(feature: str) -> Path:
    """Find feature directory. Tries kebab-case then UPPER_SNAKE_CASE."""
    kebab = feature.lower().replace("_", "-")
    for candidate in [
        FEATURES_DIR / kebab,
        FEATURES_DIR / feature,
        FEATURES_DIR / feature.upper(),
    ]:
        if candidate.is_dir():
            return candidate
    matches = list(FEATURES_DIR.glob(f"*{feature}*"))
    if len(matches) == 1:
        return matches[0]
    raise FileNotFoundError(f"Feature directory not found for '{feature}' in {FEATURES_DIR}")


def _load_template(name: str) -> str:
    return (TEMPLATES_DIR / name).read_text(encoding="utf-8")


def _load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _gate(score: float) -> str:
    if score >= 90.0:
        return "PASS"
    if score >= 70.0:
        return "WARNING"
    return "FAIL"


def _scoring_rows(scoring: dict) -> str:
    dims = scoring.get("dimensions", {})
    rows_data = [
        ("Spec Alignment", "30%", "DEFINE coverage and requirement traceability"),
        ("Code Quality", "25%", "Lint, type checks, tests, and maintainability"),
        ("Architecture Fidelity", "20%", "Conformance to DESIGN decisions and boundaries"),
        ("Security & DevOps", "15%", "Secrets, CI/CD, dependency, and operational controls"),
        ("Production Readiness", "10%", "Delivery completeness, rollback, and observability"),
    ]
    lines = []
    for dimension, weight, notes in rows_data:
        dim_data = dims.get(dimension, {})
        raw = dim_data.get("raw", 0.0) if isinstance(dim_data, dict) else float(dim_data)
        lines.append(f"| {dimension} | {weight} | {raw:.1f}/100 | {_gate(raw)} | {notes} |")
    return "\n".join(lines)


def _finding_rows(findings: list, prefix: str) -> str:
    if not findings:
        return "| - | None | - | - |"
    rows = []
    for i, f in enumerate(findings, 1):
        title = f.get("title", "Unknown").replace("|", "/")
        cat = f.get("category", "General").replace("|", "/")
        desc = f.get("description", "").replace("|", "/")
        rows.append(f"| {prefix}-{i:02d} | {title} | {cat} | {desc} |")
    return "\n".join(rows)


def _gap_rows(delivery: dict, spec: dict) -> str:
    gaps = []
    for gap in delivery.get("logic_gaps", []):
        gaps.append({"description": gap, "severity": "MEDIUM"})
    for f in delivery.get("missing_files", []):
        gaps.append({"description": f"Missing file: {f}", "severity": "HIGH"})
    for f in spec.get("findings", []):
        if f.get("severity") in ("CRITICAL", "HIGH"):
            gaps.append(f)
    if not gaps:
        return "| - | None | - |"
    return "\n".join(
        f"| GAP-{i:02d} | {g.get('description', '').replace('|', '/')} | {g.get('severity', 'MEDIUM')} |"
        for i, g in enumerate(gaps, 1)
    )


def _roadmap_rows(delivery: dict, spec: dict, code: dict) -> str:
    items = []
    for gap in delivery.get("logic_gaps", []):
        items.append(str(gap))
    for f in spec.get("findings", []):
        items.append(f.get("description", f.get("title", "")))
    for f in code.get("findings", []):
        items.append(f.get("description", f.get("title", "")))
    if not items:
        items = ["Re-run /validate after implementation changes."]
    return "\n".join(
        f"| P{min(i, 3)} | GAP-{i:02d} | {str(item).replace('|', '/')} | TBD | DataEng / SWE |"
        for i, item in enumerate(items[:10], 1)
    )


def _collect_critical(spec: dict, code: dict, delivery: dict) -> list:
    criticals = []
    for source in [spec, code]:
        for f in source.get("findings", []):
            if f.get("severity") == "CRITICAL":
                criticals.append(f)
    return criticals


def render_validation_report(feature: str, spec: dict, code: dict,
                              delivery: dict, scoring: dict, council: dict) -> str:
    template = _load_template("VALIDATION_REPORT_TEMPLATE.md")
    score = scoring.get("total_score", 0.0)
    critical_count = scoring.get("critical_count", 0)
    runbook_eligible = scoring.get("runbook_eligible", False)
    roadmap_eligible = scoring.get("roadmap_eligible", False)
    verdict = "Approved for Prod" if runbook_eligible else "Remediation Required"
    prod_decision = ("Approved for production runbook generation"
                     if runbook_eligible else "Requires remediation before production approval")
    criticals = _collect_critical(spec, code, delivery)

    replacements = {
        "{FEATURE_NAME}": feature,
        "{YYYY-MM-DD}": date.today().isoformat(),
        "{SCORE}": f"{score:.1f}",
        "{VERDICT}": verdict,
        "{RECOMMENDED_ARTIFACT}": scoring.get("artifact_decision", "VALIDATION_REPORT"),
        "{GATE_OWNER}": "Validation owner",
        "{DELIVERY_OWNER}": "Delivery owner",
        "{EXECUTIVE_SUMMARY}": council.get("executive_summary",
                                           "Validation completed. Review scoring and gaps."),
        "{PRODUCTION_READINESS_DECISION}": prod_decision,
        "{RUNBOOK_ELIGIBILITY}": "Eligible" if runbook_eligible else "Not eligible",
        "{ROADMAP_ELIGIBILITY}": "Eligible" if roadmap_eligible else "Not eligible",
        "{BLOCKING_ISSUE_COUNT}": str(critical_count),
        "{SPEC_GATE_RESULT}": _gate(spec.get("alignment_score", 0)),
        "{ARCH_GATE_RESULT}": _gate(spec.get("architecture_score", 0)),
        "{CODE_GATE_RESULT}": _gate(code.get("quality_score", 0)),
        "{DEVOPS_GATE_RESULT}": _gate(code.get("devops_score", 0)),
        "{READINESS_GATE_RESULT}": _gate(delivery.get("delta_score", 0)),
        "{SCORING_ROWS}": _scoring_rows(scoring),
        "{CRITICAL_ISSUE_ROWS}": _finding_rows(criticals, "CRIT"),
        "{GAP_ROWS}": _gap_rows(delivery, spec),
        "{DEFINE_EVIDENCE_STATUS}": "Required",
        "{DESIGN_EVIDENCE_STATUS}": "Required",
        "{BUILD_EVIDENCE_STATUS}": "Required",
        "{CODE_TREE_STATUS}": "Reviewed",
    }
    content = template
    for old, new in replacements.items():
        content = content.replace(old, new)
    return content


def render_runbook(feature: str, scoring: dict, council: dict) -> str:
    template = _load_template("RUNBOOK_TEMPLATE.md")
    notes = council.get("operational_notes", [])
    note_text = "; ".join(str(n) for n in notes) if isinstance(notes, list) else str(notes)
    replacements = {
        "{FEATURE_NAME}": feature,
        "{YYYY-MM-DD}": date.today().isoformat(),
        "{STATUS}": "Approved",
        "{RELEASE_OWNER}": "Release owner",
        "{OPERATIONS_OWNER}": "Operations owner",
        "{GATE_OWNER}": "Validation owner",
        "{DELIVERY_OWNER}": "Delivery owner",
        "{RELEASE_SUMMARY}": council.get("executive_summary",
                                         "Feature passed validation and is eligible for production."),
        "{VALIDATION_SCORE}": f"{scoring.get('total_score', 0):.1f}",
        "{CRITICAL_ISSUE_COUNT}": str(scoring.get("critical_count", 0)),
        "{RELEASE_VERIFICATION_COMMAND}": "git rev-parse HEAD",
        "{DEPLOY_COMMAND}": "TBD",
        "{SMOKE_TEST_COMMAND}": "TBD",
        "{HEALTH_CHECK_COMMAND}": "TBD",
        "{COMMUNICATION_CHANNEL}": "TBD",
        "{RUNTIME_ENVIRONMENT}": "TBD",
        "{ENV_CHECK_COMMAND}": "TBD",
        "{SECRET_REFERENCES}": "TBD",
        "{EXTERNAL_DEPENDENCIES}": "TBD",
        "{DATA_DEPENDENCIES}": "TBD",
        "{FEATURE_FLAGS}": "TBD",
        "{AVAILABILITY_SOURCE}": "Monitoring dashboard",
        "{AVAILABILITY_THRESHOLD}": "Project-defined SLA",
        "{ALERT_OWNER}": "On-call owner",
        "{ERROR_RATE_SOURCE}": "Runtime logs or metrics",
        "{ERROR_RATE_THRESHOLD}": "Project-defined threshold",
        "{LATENCY_SOURCE}": "Runtime metrics",
        "{LATENCY_THRESHOLD}": "Project-defined threshold",
        "{DATA_QUALITY_SOURCE}": "Quality checks or validation suite",
        "{DATA_QUALITY_THRESHOLD}": "No critical regressions",
        "{OPERATIONAL_NOTES}": note_text or "No additional operational notes.",
        "{ROLLBACK_TRIGGER}": "Critical smoke test failure, elevated error rate, or data quality regression",
        "{FREEZE_COMMAND}": "TBD",
        "{ROLLBACK_COMMAND}": "TBD",
        "{POST_ROLLBACK_CHECK}": "TBD",
        "{INCIDENT_DOC_LINK}": "TBD",
        "{MONITORING_DASHBOARD}": "TBD",
    }
    content = template
    for old, new in replacements.items():
        content = content.replace(old, new)
    return content


def render_roadmap(feature: str, spec: dict, code: dict,
                    delivery: dict, scoring: dict, council: dict) -> str:
    template = _load_template("ROADMAP_TEMPLATE.md")
    replacements = {
        "{FEATURE_NAME}": feature,
        "{YYYY-MM-DD}": date.today().isoformat(),
        "{CURRENT_SCORE}": f"{scoring.get('total_score', 0):.1f}",
        "{CURRENT_VERDICT}": scoring.get("status", "WARNING"),
        "{REMEDIATION_OWNER}": "Remediation owner",
        "{ARCHITECTURE_OWNER}": "Architecture owner",
        "{DELIVERY_OWNER}": "Delivery owner",
        "{OPERATIONS_OWNER}": "Operations owner",
        "{REMEDIATION_SUMMARY}": council.get("executive_summary",
                                             "Validation found gaps to remediate."),
        "{ROADMAP_ROWS}": _roadmap_rows(delivery, spec, code),
    }
    content = template
    for old, new in replacements.items():
        content = content.replace(old, new)
    return content


def main(feature_name: str) -> None:
    feature_dir = _find_feature_dir(feature_name)
    validate_dir = feature_dir / "_validate"

    if not validate_dir.is_dir():
        print(f"ERROR: _validate/ directory not found in {feature_dir}")
        sys.exit(1)

    feature_upper = feature_name.upper().replace("-", "_")

    required_files = {
        "spec": validate_dir / f"01_SPEC_REPORT_{feature_upper}.json",
        "code": validate_dir / f"02_CODE_REPORT_{feature_upper}.json",
        "delivery": validate_dir / f"03_DELIVERY_DELTA_{feature_upper}.json",
        "council": validate_dir / f"04_COUNCIL_VERDICT_{feature_upper}.json",
        "scoring": validate_dir / f"05_SCORING_{feature_upper}.json",
    }

    for name, path in required_files.items():
        if not path.exists():
            print(f"ERROR: Missing {name} file: {path}")
            sys.exit(1)

    spec = _load_json(required_files["spec"])
    code = _load_json(required_files["code"])
    delivery = _load_json(required_files["delivery"])
    council = _load_json(required_files["council"])
    scoring = _load_json(required_files["scoring"])

    # Always render validation report
    report_content = render_validation_report(feature_upper, spec, code, delivery, scoring, council)
    report_path = feature_dir / f"VALIDATION_REPORT_{feature_upper}.md"
    report_path.write_text(report_content, encoding="utf-8")
    print(f"✅ VALIDATION_REPORT: {report_path}")

    # Conditional artifacts
    if scoring.get("runbook_eligible"):
        runbook_content = render_runbook(feature_upper, scoring, council)
        runbook_path = feature_dir / f"RUNBOOK_{feature_upper}.md"
        runbook_path.write_text(runbook_content, encoding="utf-8")
        print(f"✅ RUNBOOK: {runbook_path}")
    elif scoring.get("roadmap_eligible"):
        roadmap_content = render_roadmap(feature_upper, spec, code, delivery, scoring, council)
        roadmap_path = feature_dir / f"ROADMAP_{feature_upper}.md"
        roadmap_path.write_text(roadmap_content, encoding="utf-8")
        print(f"✅ ROADMAP: {roadmap_path}")
    else:
        print("⚠️  Score too low or CRITICAL issues present — report only, no RUNBOOK/ROADMAP")

    print(f"\n📊 Score: {scoring.get('total_score', 0):.1f}/100 | Status: {scoring.get('status', 'UNKNOWN')}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python render.py FEATURE_NAME")
        sys.exit(1)
    main(sys.argv[1])
