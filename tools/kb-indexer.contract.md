# kb-indexer Tool Contract

**Version:** 1.0  
**Status:** Wave 8  
**Format:** Bash v4+  

---

## Purpose

Scan KB domain directories, track freshness (mtime-based), and enable smart context loading with one-time warnings per phase.

---

## Installation

```bash
# Make executable
chmod +x tools/kb-indexer.sh

# Verify
tools/kb-indexer.sh
```

---

## Commands

### `index [kb_dir]`

**Purpose:** Build or rebuild KB domain index.

**Usage:**
```bash
tools/kb-indexer.sh index kb/
tools/kb-indexer.sh index /absolute/path/to/kb
```

**Behavior:**
- Scans all directories in kb_dir/
- Ignores directories starting with `_` or `.`
- Finds latest mtime (most recent .md file) in each domain
- Generates `kb-index.yaml` in kb_dir/
- Outputs index to stdout and file

**Output:**
```yaml
generated_at: "2026-06-29T23:20:00Z"
kb_root: "kb//"
scan_version: 1
domains:
  airflow:
    path: "kb//airflow/"
    last_updated: "2026-06-22T09:15:00Z"
    age_days: 7
    status: fresh
    confidence: 100
    file_count: 10
    has_index: true
    mtime: 1719055500
```

**Exit Code:** 0 on success, 1 on error (missing kb_dir)

---

### `list [--format table|json]`

**Purpose:** List all KB domains with freshness summary.

**Usage:**
```bash
tools/kb-indexer.sh list
tools/kb-indexer.sh list --format json
tools/kb-indexer.sh list --format table
```

**Default Format:** `table`

**Table Output:**
```
domain_id               Status     Age (days) Confidence Files
======================================================================
ai-data-engineering    recent       26        85%
airflow                fresh         7       100%
aws                    recent       26        85%
```

**JSON Output:**
```json
[
  {
    "domain_id": "airflow",
    "status": "fresh",
    "age_days": 7,
    "confidence": 100,
    "last_updated": "2026-06-22T09:15:00Z"
  }
]
```

**Exit Code:** 0 on success, 1 on error

---

### `freshness --domain <id> [--format text|json]`

**Purpose:** Check freshness of a specific KB domain.

**Usage:**
```bash
tools/kb-indexer.sh freshness --domain airflow
tools/kb-indexer.sh freshness --domain airflow --format json
```

**Required Arguments:**
- `--domain <id>` — Domain identifier (e.g., `airflow`, `aws`)

**Optional Arguments:**
- `--format text|json` — Output format (default: `text`)

**Text Output:**
```
Domain: airflow
Status: fresh
Age: 7 days
Confidence: 100%
Last updated: 2026-06-22T09:15:00Z
```

**JSON Output:**
```json
{
  "domain_id": "airflow",
  "status": "fresh",
  "age_days": 7,
  "confidence": 100,
  "last_updated": "2026-06-22T09:15:00Z"
}
```

**Exit Code:** 0 on success, 1 on error (domain not found)

---

## Freshness Status

| Status | Age Range | Meaning | Action |
|--------|-----------|---------|--------|
| `fresh` | 0–7 days | Domain recently updated | ✅ Preferred for context loading |
| `recent` | 8–30 days | Domain usable | ⚠️ Secondary choice |
| `stale` | 31+ days | Domain needs review | ⚠️ Warn once per phase |

---

## Confidence Scoring

Confidence represents the reliability/applicability of KB content, based on age:

```
confidence = 100 - sqrt(age_days / 90) * 100

fresh (0d):     100%
recent (15d):   87%
stale (31d):    75%
very stale (60d): 58%
abandoned (90d+): 0%
```

---

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `KB_DIR` | (none) | Override default kb/ path |
| `KB_ROOT` | `kb/` (if exists), else `.` | KB root directory |

**Example:**
```bash
export KB_DIR=/path/to/custom/kb
tools/kb-indexer.sh list
```

---

## Integration: altitude-structure Phase

The altitude-structure agent calls kb-indexer at phase start:

```bash
# In altitude-structure.agent.md:
tools/kb-indexer.sh index kb/
if [ $? -eq 0 ]; then
  # Log stale domains
  tools/kb-indexer.sh list | grep "stale" | while read line; do
    domain=$(echo "$line" | awk '{print $1}')
    age=$(echo "$line" | awk '{print $3}')
    echo "[KB AUDIT] Domain '$domain' is $age days old (STALE)" >> structure-phase.log
  done
fi
```

---

## Error Handling

| Error | Exit Code | Cause | Resolution |
|-------|-----------|-------|-----------|
| `Error: KB directory not found` | 1 | kb_dir does not exist | Verify path or create kb/ |
| `Error: Domain not found: <id>` | 1 | Domain not in index | Check domain spelling, run `index` first |
| `Error: --domain is required` | 1 | Missing `--domain` in `freshness` | Add `--domain <id>` |
| `Unknown command` | 1 | Invalid command | Use `index`, `list`, or `freshness` |
| `Unknown format` | 1 | Invalid format | Use `table`, `json`, or `text` |

---

## Caching & Idempotency

- Index is written to `kb/kb-index.yaml`
- Subsequent `list` and `freshness` calls reuse cached index
- To refresh index: run `index` command again
- Index is idempotent (same input → same output)

---

## Performance

- **Index build:** ~0.5s per 100 domains (scanning all .md files)
- **List:** Instant (reads cached yaml)
- **Freshness:** Instant (reads cached yaml)

---

## Non-Blocking Warning Policy

KB audit warnings do NOT:
- Block phase progression ✅
- Halt execution ✅
- Require manual intervention ✅
- Affect success criteria ✅

Warnings are informational only; stale KBs trigger once-per-phase notice in logs.

---

## Testing

See `test/fixtures/harness-v3/wave-8-kb-quality-smoke.fixture.md` for smoke test scenarios.

---

## Rollback

Remove calls to kb-indexer from altitude-structure; tool remains in tools/ for future use.

---

**Contract Version:** 1.0  
**Last Updated:** 2026-06-29
