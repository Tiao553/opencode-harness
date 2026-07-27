# Evidence

evidence_id: E-005
change: harness-360-refactor
task: T-009A
created: 2026-06-28
command: source-backed manual review + local parity grep
status: captured
captured_by: openai/gpt-5.4

## Summary

Repaired the remaining Fabric `Eventhouse for Warehouse` parity gap by narrowing the claim to the current Microsoft Learn model: an Eventhouse endpoint can be enabled for Lakehouse and Warehouse data, but Warehouse remains the owning workload for T-SQL modeling, DML, stored procedures, and security controls.

## Source Review

Primary sources checked:

- Microsoft Learn, `Enable Eventhouse endpoint for lakehouse and warehouse`
  - URL: `https://learn.microsoft.com/en-us/fabric/real-time-intelligence/eventhouse-as-endpoint`
  - Relevant interpretation: Eventhouse endpoint lets users query Lakehouse or Warehouse data, syncs source tables and schemas, uses OneLake shortcuts and query acceleration, and exposes a read-only endpoint-managed KQL database.
- Microsoft Learn, `What is Fabric Data Warehouse?`
  - URL: `https://learn.microsoft.com/en-us/fabric/data-warehouse/data-warehousing`
  - Relevant interpretation: Warehouse remains the T-SQL/DML-oriented warehousing item, and the unified `Analyze data with` menu includes Eventhouse endpoint from Lakehouse or Warehouse.

## Files Updated

- `kb/microsoft-fabric/01-logging-monitoring/concepts/eventhouse-basics.md`
- `kb/microsoft-fabric/04-data-warehouse/concepts/warehouse-basics.md`
- `kb/microsoft-fabric/index.md`
- `kb/microsoft-fabric/quick-reference.md`
- `kb/microsoft-fabric/specs/fabric-config.yaml`

## Parity Result

```text
FABRIC-CC-004 before:
  Eventhouse for Warehouse endpoint posture -> deeper parity gap / follow-up required

FABRIC-CC-004 after:
  Eventhouse endpoint for Warehouse posture -> aligned
```

The deeper Eventhouse concept now explains the Eventhouse endpoint as a query acceleration and Real-Time Intelligence access pattern over existing Lakehouse or Warehouse tables. The Warehouse concept now explains when to use the endpoint while preserving Warehouse as the T-SQL/DML owner.

## Local Checks

```text
rtk grep "FABRIC-CC-004|follow-up required|deeper parity gap" kb/microsoft-fabric
rtk grep "Eventhouse endpoint" kb/microsoft-fabric/01-logging-monitoring/concepts/eventhouse-basics.md kb/microsoft-fabric/04-data-warehouse/concepts/warehouse-basics.md kb/microsoft-fabric/index.md kb/microsoft-fabric/quick-reference.md
```

Result:

- Entry files now show `FABRIC-CC-004` as aligned.
- Deeper Eventhouse and Warehouse concept files both contain the supporting endpoint explanation.
- The machine-readable Fabric critical claim register now matches the entry surfaces.

## Confidence and Limitations

- Confidence: high for the narrowed endpoint posture.
- Limitation: this repair did not audit unrelated Fabric claims or other workload domains.
