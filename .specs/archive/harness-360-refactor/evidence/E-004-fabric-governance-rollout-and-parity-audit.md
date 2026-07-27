# Evidence

evidence_id: E-004
change: harness-360-refactor
task: T-006B2,T-006B3
created: 2026-06-28
command: apply_patch
status: captured
captured_by: openai/gpt-5.4

## Summary

Captured the Fabric entry-surface governance rollout and the first high-impact parity audit after resolving the Copilot capacity contradiction.

## Evidence Context

- What claim or task this evidence supports: completion of T-006B2 and T-006B3
- Where in the system or document this evidence applies: Fabric domain entry surfaces and the Fabric golden-domain rollout plan
- Why this evidence matters: it proves the domain now carries governance metadata and that remaining high-impact claim gaps are triaged into focused next tasks

## Output

```text
Governance metadata added to:
- kb/microsoft-fabric/index.md
- kb/microsoft-fabric/quick-reference.md
- kb/microsoft-fabric/specs/fabric-config.yaml

Parity audit result:
- FABRIC-CC-001 Copilot capacity prerequisites -> aligned
- FABRIC-CC-002 AI Functions in Warehouse preview -> aligned
- FABRIC-CC-003 fabric-cicd GA posture -> aligned
- FABRIC-CC-004 Eventhouse for Warehouse endpoint posture -> parity gap remains
- FABRIC-CC-005 COPY INTO from OneLake preview -> aligned

Next focused task created:
- T-009A-repair-fabric-eventhouse-warehouse-parity.md
```

## Interpretation

The Fabric domain has crossed from ad hoc documentation into a governed entry-surface model. The remaining high-impact gap is now isolated into one specific contradiction cluster instead of being hidden inside a broad Fabric cleanup bucket.

## Confidence and Limitations

- Confidence: high for entry-surface governance and the parity triage performed
- Limitation: T-009A still needs source-backed execution to fully close the next parity gap

## Follow-Up Notes

- T-006B2 is complete
- T-006B3 is complete
- T-009A is the next focused Fabric repair slice
