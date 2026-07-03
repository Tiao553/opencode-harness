# Fixture: Data Quality Investigation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-05-data-quality-investigation |
| Title | Data quality issue requires diagnosis |
| Purpose | Preserve behavior: Data Engineer routes to tactical, data quality specialist allocated for diagnosis, evidence collected, may or may not result in durable task |
| Group | Tactical Data |

## Request

**User input:**
```
"Our orders table has 15% null values in the shipment_date column.
What's the root cause and should we address it?"
```

## Expected Behavior

### Route
- Coordinator: `Data Engineer` (tactical classifier)
- Mode: `tactical` (investigation mode)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| Investigation notes | created | diagnosis and findings recorded |
| Recommendation | created | actionable next step or decision |
| Durable task (maybe) | created if strategic | only if fixing requires architecture change |

### Allocation
- **Global scope:** data quality tools, schema, lineage, sample queries
- **Forbidden scope:** Don't assume the fix yet
- **Specialists:** Data quality specialist allocated (reason: requires data lineage knowledge, SQL query profiling)

### Context Loaded
- table schema
- data lineage if available
- recent load logs
- related pipelines

### Todos
- [ ] Query null distribution by source system — verify: results grouped by source
- [ ] Check recent load history for data quality issues — verify: timestamps and affected rows identified
- [ ] Determine if nulls are expected (valid business logic) or unexpected — verify: documented with source
- [ ] Recommend fix or closure — verify: written recommendation with rationale

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| root cause identified | diagnosis notes | Nulls traced to source (valid/invalid) |
| impact assessed | documentation | Business impact quantified |
| recommendation clear | next steps | Either: "document as valid", "create pipeline fix task", or "escalate" |

### State Update
- No `.specs` change unless user approves strategic fix task
- Investigation result logged to Data Engineer coordination log

## Must Not

- ❌ Assume the data is wrong without evidence
- ❌ Start writing a fix without diagnosing root cause first
- ❌ Create a durable task if finding is "this is valid business behavior"
- ❌ Proceed without consulting data quality specialist

## Notes

This fixture validates tactical investigation workflow. Data quality specialist is allocated early (before fix is designed).
Outcome may be "close as valid" (no durable work) or "create durable task" (promotion to strategic).
