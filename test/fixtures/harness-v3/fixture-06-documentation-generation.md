# Fixture: Documentation Generation

## Metadata

| Field | Value |
|-------|-------|
| ID | fixture-06-documentation-generation |
| Title | Dense architecture documentation needed |
| Purpose | Preserve behavior: Altitude routes to artifact creation, documentation specialist allocated, text-architecture and tables generated, maximum useful detail applied |
| Group | Artifact Generation |

## Request

**User input:**
```
"Document our new medallion architecture with Bronze/Silver/Gold layers. 
Be detailed. Include patterns, partition strategy, data quality progression."
```

## Expected Behavior

### Route
- Coordinator: `Altitude` (durable documentation)
- Mode: `artifact` (not a change phase, but artifact creation)

### Artifacts
| Artifact | Expected | Rationale |
|----------|----------|-----------|
| docs/{name}.md | created | Architecture doc with text-as-architecture, tables, Mermaid |

### Allocation
- **Global scope:** docs/
- **Forbidden scope:** code, configs, .specs changes
- **Specialists:** Documentation specialist (reason: must write with maximum useful detail posture)

### Context Loaded
- existing medallion architecture docs if any
- data platform KB
- team conventions

### Todos
- [ ] Define Bronze layer storage and retention strategy — verify: sections for raw data ingestion, partitioning, compaction
- [ ] Define Silver layer cleansing and conforming rules — verify: sections for deduplication, type casting, quality gates
- [ ] Define Gold layer business logic and SLA — verify: sections for aggregations, refresh cadence, SLA targets
- [ ] Create text-architecture flow diagram — verify: ASCII or Mermaid showing data flow
- [ ] Document edge cases and known limitations — verify: explicit edge case section

### Validation
| Check | Method | Expected Signal |
|-------|--------|-----------------|
| structure complete | doc review | Purpose, why it matters, how it works, where it applies, edge cases, examples present |
| tables present | markdown check | Decision tables for partitioning, compaction, quality gates |
| Mermaid/text arch | visual check | Flow diagram showing Bronze→Silver→Gold |
| maximum detail | section depth check | Each section answers: what, why, how, where, edge cases, example |

### State Update
- No phase change (artifact-only)
- active_change stays same if this is supporting doc for existing change

## Must Not

- ❌ Create shallow bullet-point-only documentation
- ❌ Skip examples or edge cases to save space
- ❌ Use Mermaid alone without text architecture
- ❌ Avoid stating assumptions or limitations

## Notes

This fixture validates documentation mode = maximum useful detail (not bloat, but not shallow).
Text-architecture and tables are required for system documentation.
