# KB Quality & Indexing Contract

**Effective:** Wave 8
**Scope:** All KB domains under `kb/`
**Freshness Model:** Modification-time-based with decay
**Warning Policy:** Once per phase, non-blocking

---

## Domain Taxonomy {#domain_taxonomy}

```yaml
domain_taxonomy:

Expected KB domains under `kb/`:

| Domain ID | Name | Category | Required |
|-----------|------|----------|----------|
| ai-data-engineer | AI Data Engineering | Data Platform | ✅ |
| airflow | Apache Airflow | Orchestration | ✅ |
| aws | AWS | Cloud | ✅ |
| cloud-platforms | Cloud Platforms | Infrastructure | ✅ |
| containers | Containers | Infrastructure | ✅ |
| data-modeling | Data Modeling | Schema | ✅ |
| data-quality | Data Quality | Testing | ✅ |
| dataviz | Data Visualization | BI | ✅ |
| dbt | dbt | Transformation | ✅ |
| gcp | Google Cloud | Cloud | ✅ |
| genai | Generative AI | AI | ✅ |
| lakeflow | Lakeflow (DLT) | Transformation | ✅ |
| lakehouse | Lakehouse | Architecture | ✅ |
| medallion | Medallion Architecture | Architecture | ✅ |
| microsoft-fabric | Microsoft Fabric | Cloud | ✅ |
| modern-stack | Modern Data Stack | Architecture | ✅ |
| prompt-engineering | Prompt Engineering | AI | ✅ |
| pydantic | Pydantic | Python | ✅ |
| python | Python | Languages | ✅ |
| spark | Apache Spark | Processing | ✅ |
| sql-patterns | SQL Patterns | Query Language | ✅ |
| streaming | Stream Processing | Processing | ✅ |
| supabase | Supabase | Backend | ✅ |
| terraform | Terraform | Infrastructure | ✅ |
| testing | Testing | Quality | ✅ |
| shared | Shared Concepts | Shared | Optional |
| _templates | Templates | System | Optional |

---

## Freshness Schema

### Age Calculation

```yaml
freshness_schema:
freshness_model:
  unit: days
  measurement: file mtime (modification time of domain's index.md or latest file)
  reference: system current time (UTC)
  formula: current_timestamp - max(mtime in domain)
```

### Freshness Bands

| Band | Age Range | Status | Context Loading | Warning |
|------|-----------|--------|-----------------|---------|
| Fresh | 0–7 days | ✅ Preferred | Use first | None |
| Recent | 8–30 days | ⚠️ Usable | Use second | None |
| Stale | 31+ days | ⚠️ Degraded | Use last | Once per phase |
| Missing | N/A | 🚫 Error | Skip | Always |

### Decay Function (Optional)

For context loading prioritization, apply decay curve:

```
confidence = 1.0 - (age_in_days / 90) ^ 0.5

Fresh (0d):     confidence = 1.0
Recent (15d):   confidence ≈ 0.87
Stale (31d):    confidence ≈ 0.75
Very Stale (60d): confidence ≈ 0.58
Abandoned (90d+): confidence ≈ 0.0
```

This allows smart context loading to prefer fresh domains while still using stale ones if necessary.

---

## Quality Scoring (Optional for Wave 8)

### Dimensions

- **Freshness** (40%): Days since last update
- **Coverage** (30%): Files present (index.md, concepts/, patterns/, specs/)
- **Structure** (20%): Follows domain template
- **Metadata** (10%): _index.yaml entry completeness

### Scoring Formula

```
score = (freshness_score × 0.4) + (coverage_score × 0.3) + (structure_score × 0.2) + (metadata_score × 0.1)

Range: 0–100
- 90+: Excellent (safe to load)
- 75–89: Good (load with caution)
- 60–74: Fair (warn on load)
- <60: Poor (skip or audit)
```

For Wave 8, scoring is optional. Freshness tracking is mandatory.

---

## Indexer Output Format

### Index File (YAML)

```yaml
generated_at: "2026-06-29T22:50:00Z"
kb_root: "kb/"
scan_version: 1
domains:
  ai-data-engineer:
    path: kb/ai-data-engineer/
    last_updated: "2026-05-15T14:32:00Z"
    age_days: 45
    status: stale
    confidence: 0.74
    file_count: 12
    has_index: true
    mtime: 1717418520
  airflow:
    path: kb/airflow/
    last_updated: "2026-06-22T09:15:00Z"
    age_days: 7
    status: fresh
    confidence: 1.0
    file_count: 18
    has_index: true
    mtime: 1719055500
```

---

## Indexer Commands (Reference)

Implemented in `tools/kb-indexer.sh`:

### index

Scan KB directory and build index.

```bash
tools/kb-indexer.sh index [kb_dir]
```

**Output:** Writes index to `kb-index.yaml` in kb_dir; prints to stdout.

### list

Show all domains and freshness summary.

```bash
tools/kb-indexer.sh list [--format json|yaml|table]
```

**Output:** Table with domain_id, status, age_days, confidence.

### freshness

Check freshness of specific domain.

```bash
tools/kb-indexer.sh freshness --domain <domain_id> [--format json|text]
```

**Output:** age_days, status (fresh|recent|stale), confidence score.

---

## Integration Points

### altitude-structure Phase

When altitude-structure starts:

1. Call `tools/kb-indexer.sh index kb/`
2. Capture output
3. Log warnings for stale domains (>30 days)
4. Warning format: `[KB AUDIT] Domain '{domain_id}' is {age_days} days old (stale)`
5. Include in structure phase report

### Context Loading

When loading context bundles:

1. Prefer fresh domains (<7 days)
2. Use decay curve to weight domain selection
3. Skip very old domains (>90 days) unless explicitly requested

---

## Warning Policy

**Frequency:** Once per phase, not on every access.

**Format:**

```
[KB AUDIT] {domain_id}: {age_days} days old (STALE)
  Last updated: {date}
  Recommendation: Review and update
```

**Escalation:**

- Info: 8–30 days (recent)
- Warn: 31–60 days (stale)
- Alert: 60+ days (very stale, may need refresh)

---

## Non-Blocking Guarantee

KB audit warnings do NOT:
- Block phase progression
- Halt execution
- Require manual intervention
- Affect success criteria

They are informational only, intended to surface maintenance backlog.

---

## Validation

The indexer must pass:

1. ✅ Idempotent (run twice, same output)
2. ✅ Handles missing domains gracefully
3. ✅ Captures mtime correctly
4. ✅ Outputs valid YAML
5. ✅ No external dependencies (bash + coreutils only)

---

## Rollback

Remove kb-indexer calls from altitude-structure; tool remains in tools/ for future use.

---

**Contract Version:** 1.0
**Status:** Wave 8 Design
**Next Review:** After W8 implementation and fixtures
