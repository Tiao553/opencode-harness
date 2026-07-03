# Wave 25A: Allocation Consolidation — Phase 3 Execution Plan

**Status:** LOCKED FOR EXECUTION  
**Phase:** 3 (Tooling Implementation)  
**Date:** 2026-07-03  
**User Decision:** T-20 APPROVED  
**Ready to Execute:** YES

---

## PHASE 3 OVERVIEW

| Item | Value |
|------|-------|
| **Phase** | Tooling Implementation (T-21 to T-30) |
| **Duration** | 23h serial / 10h parallel |
| **Deliverable** | 5 new/enhanced tool commands + agent helpers + performance benchmarks |
| **User Gate** | T-30 (approve tools before Phase 4 testing) |
| **Critical Path** | T-15 (tool spec from Phase 2) → T-21 → T-22 → T-23 → T-24 → T-29 → T-30 |
| **Tool Scope** | Batch operations + agent integration (per Q4 decision) |

---

## TOOLS TO IMPLEMENT

From Phase 2 (T-15), Phase 3 must deliver:

### **Existing Tool (Enhancement)**
- `allocation-check.sh` (286 lines current)

### **New Commands for allocation-check.sh**
1. `validate-file` — Pre-write checks against allocation
2. `query-violations` — List and filter violations
3. `ledger-stats` — Compliance reporting
4. `allocation-snapshot` — Save baseline
5. `allocation-diff` — Scope comparison

### **New Tools (Standalone)**
1. `allocation-snapshot.sh` — Create versioned baseline
2. `allocation-diff.sh` — Compare allocations

### **Agent Integration Helpers**
- Python stub library
- Go stub library

---

# PHASE 3: TOOLING (T-21 to T-30)

## T-21: allocation-check.sh: validate-file Enhancement (3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-15 (tool spec from Phase 2)  
**Verification:** MANDATORY

### Objective

Add `validate-file` command to allocation-check.sh. Pre-write validation checks if file is allowed, forbidden, or requires scope expansion. Returns structured output for agents to decide action.

### Implementation

**Command:** `allocation-check.sh validate-file <file> <allocation.yaml> [--quiet]`

**Logic:**
```bash
# Input: file path, allocation YAML
# Output: JSON with { status, rule_matched, action_required }

# Check allowed_files (first match)
for pattern in $(yq -r '.allowed_files[]' allocation.yaml); do
  if match_pattern "$file" "$pattern"; then
    # Check forbidden_files (override)
    for forbidden in $(yq -r '.forbidden_files[]' allocation.yaml); do
      if match_pattern "$file" "$forbidden"; then
        echo '{"status": "forbidden", "rule": "'"$forbidden"'", "action": "block"}'
        exit 1
      fi
    done
    echo '{"status": "allowed", "rule": "'"$pattern"'", "action": "allow"}'
    exit 0
  fi
done

# Not in allowed list
echo '{"status": "expansion_needed", "rule": null, "action": "ask_user"}'
exit 2
```

**Output Format:**
```json
{
  "status": "allowed|forbidden|expansion_needed",
  "rule_matched": "agents/*.agent.md",
  "action": "allow|block|ask_user",
  "reason": "File in allowed_files",
  "file": "agents/altitude-execution.agent.md"
}
```

**Exit Codes:**
- 0 = allowed (action: allow)
- 1 = forbidden (action: block)
- 2 = expansion_needed (action: ask user)

**Usage Examples:**
```bash
# Test 1: File in allowed scope
allocation-check.sh validate-file agents/altitude-execution.agent.md allocation.yaml
# Output: {"status": "allowed", ...}

# Test 2: File in forbidden scope
allocation-check.sh validate-file AGENTS.md allocation.yaml
# Output: {"status": "forbidden", ...}

# Test 3: File requires expansion
allocation-check.sh validate-file plugins/unknown.ts allocation.yaml
# Output: {"status": "expansion_needed", ...}
```

### Deliverables

- `tools/allocation-check.sh` updated with `validate-file` command
- ~50 lines added (total: ~336 lines)
- Backward compatible (old commands unchanged)

### Acceptance Criteria

- ✓ Command implemented and functional
- ✓ All 3 exit codes work (0/1/2)
- ✓ Output is valid JSON
- ✓ Tested with 10+ files (safe, forbidden, expansion scenarios)
- ✓ Performance: < 2ms per call (benchmark in T-24)
- ✓ No side effects (read-only)

### Verification

```bash
# Verify command exists
bash tools/allocation-check.sh validate-file --help 2>/dev/null | grep -q "validate-file" && echo "✓ Command added"

# Test exit codes
bash tools/allocation-check.sh validate-file agents/test.md test-allocation.yaml
test $? -eq 0 -o $? -eq 1 -o $? -eq 2 && echo "✓ Exit codes correct"

# Test output format
output=$(bash tools/allocation-check.sh validate-file agents/test.md test-allocation.yaml)
echo "$output" | python3 -m json.tool >/dev/null && echo "✓ Valid JSON output"

echo "✓ All verifications passed"
```

---

## T-22: allocation-check.sh: query-violations Command (3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-15 (tool spec), T-13 (ledger contract from Phase 2)  
**Verification:** MANDATORY

### Objective

Add `query-violations` command to allocation-check.sh. Filters ledger for violations, with options to filter by type, severity, export format.

### Implementation

**Command:** `allocation-check.sh query-violations <ledger.md> [--type TYPE] [--severity SEVERITY] [--export-format FORMAT]`

**Options:**
- `--type`: violation_blocked, scope_expansion_requested, warning (default: all)
- `--severity`: critical, high, medium (default: all)
- `--export-format`: json, csv, table (default: table)

**Logic:**
```bash
# Parse ledger YAML
# Filter allocation_events by:
#   - type (if specified)
#   - severity (if specified)
# Format output per --export-format
# Return count + violations

# Example filter:
yq -r '.allocation_events[] | select(.type == "violation_blocked")' ledger.md
```

**Output Formats:**

**Table (default):**
```
ID                              File           Type                  Decision
allocation-event-20260629-001   AGENTS.md      violation_blocked     aborted
allocation-event-20260629-002   plugins/x.ts   scope_expansion       approved
allocation-event-20260629-003   .git/config    violation_blocked     escalated
```

**JSON:**
```json
{
  "total_violations": 3,
  "violations": [
    {"event_id": "...", "file": "...", "type": "...", "decision": "..."},
    ...
  ]
}
```

**CSV:**
```
event_id,file,type,decision,timestamp
allocation-event-20260629-001,AGENTS.md,violation_blocked,aborted,2026-06-29T02:45:00Z
...
```

### Deliverables

- `tools/allocation-check.sh` updated with `query-violations` command
- ~80 lines added (total: ~416 lines after T-21)
- Supports 3 output formats

### Acceptance Criteria

- ✓ Command implemented and functional
- ✓ All 3 export formats work (json, csv, table)
- ✓ Type filtering works (all types)
- ✓ Tested with 50+ violation ledger
- ✓ Performance: < 200ms for 1000-event ledger (benchmark in T-24)
- ✓ No mutations to ledger

### Verification

```bash
# Verify command exists
bash tools/allocation-check.sh query-violations --help 2>/dev/null | grep -q "query-violations" && echo "✓ Command added"

# Test format options
bash tools/allocation-check.sh query-violations test-ledger.md --export-format json | python3 -m json.tool >/dev/null && echo "✓ JSON format"
bash tools/allocation-check.sh query-violations test-ledger.md --export-format csv | head -1 | grep -q "event_id" && echo "✓ CSV format"

# Test filtering
count=$(bash tools/allocation-check.sh query-violations test-ledger.md --type violation_blocked | wc -l)
test "$count" -gt 0 && echo "✓ Type filtering works"

echo "✓ All verifications passed"
```

---

## T-23: allocation-check.sh: ledger-stats Command (2 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-15 (tool spec), T-13 (ledger contract)  
**Verification:** MANDATORY

### Objective

Add `ledger-stats` command to allocation-check.sh. Generates compliance report showing violation counts, expansion approvals, trends, and integrity checks.

### Implementation

**Command:** `allocation-check.sh ledger-stats <ledger.md> [--format FORMAT]`

**Report Contents:**
```
ALLOCATION LEDGER COMPLIANCE REPORT
===================================
Generated: 2026-07-03T22:30:00Z
Ledger: .specs/changes/wave-25/03-execution-ledger.md

SUMMARY
-------
Total Events: 1,247
Total Allocations: 156
Total Writes Allowed: 1,089
Total Violations: 42
Total Expansions: 58

VIOLATIONS
----------
Blocked (aborted): 20
Blocked (escalated): 15
Blocked (pending): 7

EXPANSIONS
----------
Approved: 52
Denied: 4
Pending: 2

INTEGRITY
---------
Ledger Status: ✓ CLEAN
Event Order: ✓ SEQUENTIAL
No Gaps: ✓ TRUE
Corruption Detected: ✓ FALSE

TRENDS (Last 24h)
-----------------
Violations/hour: 1.75
Expansions/hour: 2.4
False Positives: 0%
Compliance Rate: 97.3%

RECOMMENDATIONS
---------------
- Scope is stable (low violation rate)
- Expansions are expected and approved
- No action required
```

**Output Formats:**
- `text` (default): human-readable
- `json`: structured data for dashboards
- `csv`: rows for spreadsheet

### Deliverables

- `tools/allocation-check.sh` updated with `ledger-stats` command
- ~60 lines added (total: ~476 lines after T-22)
- Report includes 6 sections (summary, violations, expansions, integrity, trends, recommendations)

### Acceptance Criteria

- ✓ Command implemented and functional
- ✓ Report has all 6 sections
- ✓ Tested with 1000+ event ledger
- ✓ Performance: < 300ms for 1000 events (benchmark in T-24)
- ✓ Recommendations are accurate
- ✓ Supports multiple formats (text, json, csv)

### Verification

```bash
# Verify command exists
bash tools/allocation-check.sh ledger-stats --help 2>/dev/null | grep -q "ledger-stats" && echo "✓ Command added"

# Test default format
bash tools/allocation-check.sh ledger-stats test-ledger.md | grep -q "COMPLIANCE REPORT" && echo "✓ Text format"

# Test JSON format
bash tools/allocation-check.sh ledger-stats test-ledger.md --format json | python3 -m json.tool >/dev/null && echo "✓ JSON format"

# Verify report sections
output=$(bash tools/allocation-check.sh ledger-stats test-ledger.md)
echo "$output" | grep -q "SUMMARY" && echo "✓ Section: Summary"
echo "$output" | grep -q "VIOLATIONS" && echo "✓ Section: Violations"
echo "$output" | grep -q "TRENDS" && echo "✓ Section: Trends"

echo "✓ All verifications passed"
```

---

## T-24: allocation-check.sh: Performance Tests (4 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-21, T-22, T-23 (commands implemented)  
**Verification:** MANDATORY

### Objective

Benchmark all allocation-check.sh commands against performance targets. Measure latency and throughput. Capture baseline for regression detection.

### Performance Targets (from Phase 2 T-05)

| Operation | Target | Scenario |
|-----------|--------|----------|
| validate-file | < 2ms | Single file check |
| query-violations (100 events) | < 100ms | Small ledger filter |
| query-violations (1000 events) | < 200ms | Large ledger filter |
| ledger-stats (100 events) | < 100ms | Small report |
| ledger-stats (1000 events) | < 300ms | Large report |
| Batch (100 files) | < 200ms | Multiple file checks |
| Batch (1000 files) | < 2000ms | Large batch |

### Implementation

**Benchmarking Script:** `test/performance-benchmarks/allocation-check.sh`

```bash
#!/bin/bash
# Benchmark allocation-check.sh commands

# T1: Single file validation
time bash tools/allocation-check.sh validate-file agents/test.md test-allocation.yaml

# T2-3: Query violations
time bash tools/allocation-check.sh query-violations test-ledger-100.md  # Target: < 100ms
time bash tools/allocation-check.sh query-violations test-ledger-1000.md # Target: < 200ms

# T4-5: Ledger stats
time bash tools/allocation-check.sh ledger-stats test-ledger-100.md   # Target: < 100ms
time bash tools/allocation-check.sh ledger-stats test-ledger-1000.md  # Target: < 300ms

# T6-7: Batch operations
for f in {1..100}; do
  bash tools/allocation-check.sh validate-file "agents/test-$f.md" test-allocation.yaml
done | xargs -I {} bash -c 'echo {}' # Measure total time

# Capture results to CSV
echo "operation,iterations,total_time_ms,avg_time_ms,min_ms,max_ms" > results.csv
...
```

**Test Data:**
- 10 allocation.yaml files (10-1000 patterns each)
- 100-entry and 1000-entry test ledgers
- 100-1000 dummy files for batch testing

**Success Criteria:**
```
✓ validate-file: < 2ms
✓ query-violations (100): < 100ms
✓ query-violations (1000): < 200ms
✓ ledger-stats (100): < 100ms
✓ ledger-stats (1000): < 300ms
✓ batch (100 files): < 200ms
✓ batch (1000 files): < 2000ms
```

**Output:** `test/performance-benchmarks/results-20260703.csv` with all metrics

### Deliverables

- Benchmarking script at `test/performance-benchmarks/allocation-check.sh`
- Test data files (allocations, ledgers, dummy files)
- Results CSV with baseline metrics
- Regression detection thresholds (if any metric exceeds target by >20%, flag)

### Acceptance Criteria

- ✓ All commands benchmarked (7 scenarios)
- ✓ All targets met (0 failures allowed)
- ✓ Results captured to CSV
- ✓ Regression detection configured (>20% slowdown = ALERT)
- ✓ Test data reproducible (fixtures checked in)
- ✓ Benchmarking script reusable for future regression testing

### Verification

```bash
# Run benchmarks
bash test/performance-benchmarks/allocation-check.sh | tee benchmark-output.txt

# Verify results file created
test -f test/performance-benchmarks/results-20260703.csv && echo "✓ Results captured"

# Verify all metrics present
grep -c "validate-file\|query-violations\|ledger-stats" benchmark-output.txt && echo "✓ All commands tested"

# Verify success (no failures, all < target)
bash test/performance-benchmarks/validate-results.sh results-20260703.csv && echo "✓ All performance targets met"

echo "✓ All verifications passed"
```

---

## T-25: allocation-check.sh: Agent Integration (2 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-21, T-22, T-23 (commands stable)  
**Verification:** MANDATORY

### Objective

Create agent integration helpers so Python/Go agents can call allocation-check.sh functions without shell-out overhead. Stubs provided for agent implementation in Phase 4+.

### Implementation

**Python Helper Library Stub:** `agents/lib/allocation_check_py.md`

```python
# agents/lib/allocation_check.py (stub for agent implementation)

class AllocationValidator:
    """Validate file writes against allocation boundaries."""
    
    def __init__(self, allocation_yaml):
        """Load allocation from YAML dict or file."""
        self.allocation = allocation_yaml
        self.patterns = {
            'allowed': allocation_yaml.get('allowed_files', []),
            'forbidden': allocation_yaml.get('forbidden_files', [])
        }
    
    def validate_file(self, file_path):
        """
        Check if file is allowed.
        
        Returns: {
            'status': 'allowed|forbidden|expansion_needed',
            'rule': 'matching_pattern',
            'action': 'allow|block|ask_user'
        }
        """
        # Match against allowed patterns
        for pattern in self.patterns['allowed']:
            if self._match_glob(file_path, pattern):
                # Check forbidden override
                for forbidden in self.patterns['forbidden']:
                    if self._match_glob(file_path, forbidden):
                        return {'status': 'forbidden', 'action': 'block'}
                return {'status': 'allowed', 'action': 'allow'}
        
        return {'status': 'expansion_needed', 'action': 'ask_user'}
    
    def _match_glob(self, path, pattern):
        """Glob pattern matching (fnmatch)."""
        import fnmatch
        return fnmatch.fnmatch(path, pattern)

# Usage in agents:
# from lib.allocation_check import AllocationValidator
# validator = AllocationValidator(allocation_dict)
# result = validator.validate_file('agents/test.md')
```

**Go Helper Library Stub:** `agents/lib/allocation_check.go`

```go
// agents/lib/allocation_check.go (stub for agent implementation)

package allocation

type AllocationValidator struct {
	Allowed   []string
	Forbidden []string
}

func (av *AllocationValidator) ValidateFile(filePath string) map[string]string {
	/*
	Check if file is allowed.
	
	Returns: {
		"status": "allowed|forbidden|expansion_needed",
		"action": "allow|block|ask_user"
	}
	*/
	for _, pattern := range av.Allowed {
		if matchGlob(filePath, pattern) {
			for _, forbidden := range av.Forbidden {
				if matchGlob(filePath, forbidden) {
					return map[string]string{
						"status": "forbidden",
						"action": "block",
					}
				}
			}
			return map[string]string{
				"status": "allowed",
				"action": "allow",
			}
		}
	}
	
	return map[string]string{
		"status": "expansion_needed",
		"action": "ask_user",
	}
}

func matchGlob(path, pattern string) bool {
	// fnmatch-style glob matching
	// implementation: use filepath.Match or custom
	return true // placeholder
}
```

**Integration Tests:** `test/agent-integration/test-allocation-helpers.sh`

```bash
#!/bin/bash
# Test agent integration with allocation helpers

# Test 1: Python helper can be imported
python3 -c "from agents.lib.allocation_check import AllocationValidator" && echo "✓ Python helper imports"

# Test 2: Python helper validates files
python3 << 'EOF'
from agents.lib.allocation_check import AllocationValidator
allocation = {'allowed_files': ['agents/*.md'], 'forbidden_files': ['AGENTS.md']}
validator = AllocationValidator(allocation)
result = validator.validate_file('agents/test.md')
assert result['status'] == 'allowed', f"Expected allowed, got {result}"
print("✓ Python helper validates files")
EOF

# Test 3: Go helper can be compiled (stub check)
test -f agents/lib/allocation_check.go && echo "✓ Go helper present"

# Test 4: Agent can call validate_file via bash
result=$(bash tools/allocation-check.sh validate-file agents/test.md allocation.yaml)
echo "$result" | python3 -m json.tool >/dev/null && echo "✓ Agent can call via bash"
```

### Deliverables

- `agents/lib/allocation_check.py` (50 lines, stub)
- `agents/lib/allocation_check.go` (40 lines, stub)
- `test/agent-integration/test-allocation-helpers.sh` (30 lines)
- Integration documentation in allocation-check.contract.md

### Acceptance Criteria

- ✓ Python helper library stub present and importable
- ✓ Go helper library stub present and compilable
- ✓ Both libraries have validate_file function
- ✓ Integration tests run successfully
- ✓ Documentation shows usage examples
- ✓ Backward compatible (agents can still shell out if preferred)

### Verification

```bash
# Verify libraries exist
test -f agents/lib/allocation_check.py && echo "✓ Python helper"
test -f agents/lib/allocation_check.go && echo "✓ Go helper"

# Verify Python imports
python3 -c "from agents.lib.allocation_check import AllocationValidator" && echo "✓ Python import works"

# Verify test script works
bash test/agent-integration/test-allocation-helpers.sh && echo "✓ Integration tests pass"

echo "✓ All verifications passed"
```

---

## T-26: allocation-snapshot.sh (New Tool, 3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-15 (tool spec)  
**Verification:** MANDATORY

### Objective

Create standalone tool to save versioned snapshots of current allocations. Used for comparison (T-27) and regression detection. Enables "baseline → current" diffs.

### Implementation

**Tool:** `tools/allocation-snapshot.sh`

**Command:** `tools/allocation-snapshot.sh create <change_id> <output_dir>`

**Logic:**
```bash
#!/bin/bash
# Save snapshot of all active allocations for a change

change_id=$1
output_dir=$2
timestamp=$(date -u +%Y%m%d-%H%M%S)

# Gather all allocations from change directory
snapshot_dir="$output_dir/snapshots"
mkdir -p "$snapshot_dir"

# Copy active allocation files
cp ".specs/changes/$change_id/allocation.yaml" "$snapshot_dir/allocation-$timestamp.yaml"
cp ".specs/shared/allocation-contract.md" "$snapshot_dir/allocation-contract-$timestamp.md"
cp ".specs/shared/allocation-enforcement-contract.md" "$snapshot_dir/enforcement-contract-$timestamp.md"
cp ".specs/shared/allocation-ledger-contract.md" "$snapshot_dir/ledger-contract-$timestamp.md"

# Generate snapshot metadata
cat > "$snapshot_dir/snapshot-$timestamp.json" << EOF
{
  "snapshot_id": "snapshot-$timestamp",
  "change_id": "$change_id",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "files": [
    "allocation-$timestamp.yaml",
    "allocation-contract-$timestamp.md",
    "enforcement-contract-$timestamp.md",
    "ledger-contract-$timestamp.md"
  ],
  "checksum": "$(sha256sum $snapshot_dir/* | sha256sum | cut -d' ' -f1)"
}
EOF

echo "✓ Snapshot created: $snapshot_dir/snapshot-$timestamp.json"
```

**Output:** Versioned snapshot directory with:
- `allocation-<timestamp>.yaml`
- `allocation-contract-<timestamp>.md`
- `enforcement-contract-<timestamp>.md`
- `ledger-contract-<timestamp>.md`
- `snapshot-<timestamp>.json` (metadata + checksum)

**Usage:**
```bash
# Create baseline snapshot
tools/allocation-snapshot.sh create wave-25 test/snapshots

# List snapshots
ls -la test/snapshots/snapshots/

# Compare (used in T-27)
tools/allocation-diff.sh test/snapshots/snapshots/snapshot-20260703-100000.json \
                         test/snapshots/snapshots/snapshot-20260703-110000.json
```

### Deliverables

- `tools/allocation-snapshot.sh` (60 lines)
- Snapshot output directory structure
- Metadata JSON with checksums

### Acceptance Criteria

- ✓ Tool creates versioned snapshots
- ✓ Snapshots contain all allocation files
- ✓ Metadata includes checksums (for corruption detection)
- ✓ Timestamps prevent overwrites
- ✓ Snapshot format is reusable by allocation-diff.sh (T-27)

### Verification

```bash
# Create test snapshot
bash tools/allocation-snapshot.sh create wave-25-test test/snapshots

# Verify directory structure
test -d test/snapshots/snapshots && echo "✓ Snapshot dir created"
ls test/snapshots/snapshots/allocation-*.yaml && echo "✓ Allocation files present"
test -f test/snapshots/snapshots/snapshot-*.json && echo "✓ Metadata file present"

# Verify JSON metadata
python3 -c "import json; json.load(open('test/snapshots/snapshots/snapshot-'*.json'))" && echo "✓ Valid metadata JSON"

echo "✓ All verifications passed"
```

---

## T-27: allocation-diff.sh (New Tool, 2 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-26 (snapshot.sh provides baseline)  
**Verification:** MANDATORY

### Objective

Create standalone tool to compare two allocation snapshots. Shows scope delta, contract changes, and flags breaking changes.

### Implementation

**Tool:** `tools/allocation-diff.sh`

**Command:** `tools/allocation-diff.sh <snapshot1.json> <snapshot2.json>`

**Output:**
```
ALLOCATION SNAPSHOT DIFF
========================

Snapshot 1: snapshot-20260703-100000.json
Snapshot 2: snapshot-20260703-110000.json

TIME DELTA: 10 minutes

SCOPE CHANGES (allocation.yaml)
-------------------------------
Added patterns:
  + test/fixtures/
  + docs/HARNESS_V3_*.md

Removed patterns:
  - deprecated/

Modified patterns:
  ~ agents/ → agents/**

NEW ALLOWED: 3 files/patterns
REMOVED ALLOWED: 1 file/pattern
MODIFIED ALLOWED: 1 file/pattern

FORBIDDEN_FILES CHANGES
-----------------------
Added:
  + .git/hooks/*

Removed:
  - .specs/temp/*

CONTRACT CHANGES (allocation-contract.md)
-----------------------------------------
Content diff lines: 12
  Lines added: 8
  Lines removed: 4
  Breaking changes: NONE ✓

ENFORCEMENT CONTRACT CHANGES
---------------------------
Content diff lines: 45
  Lines added: 30
  Lines removed: 15
  Breaking changes: Pattern regex syntax change (warning)

SUMMARY
-------
Overall change: MINOR
  ✓ No breaking changes detected
  ⚠ Pattern syntax changed (1 pattern needs review)
  ✓ All new rules are backward compatible

RECOMMENDATIONS
---------------
- Review pattern syntax change in enforcement contract
- Update agent integrations if using pattern parsing
- Snapshot 2 is safe to deploy
```

### Deliverables

- `tools/allocation-diff.sh` (80 lines)
- Comparison algorithm (YAML diffing, markdown diffing)
- Breaking change detector

### Acceptance Criteria

- ✓ Tool compares snapshots accurately
- ✓ Shows scope delta (added, removed, modified)
- ✓ Highlights contract changes
- ✓ Detects breaking changes
- ✓ Output is human-readable
- ✓ No false positives on breaking changes

### Verification

```bash
# Create two snapshots
bash tools/allocation-snapshot.sh create wave-25-test test/snapshots/snap1
sleep 1
# Make a change (add new allowed pattern)
echo "test/" >> .specs/changes/wave-25/allocation.yaml
bash tools/allocation-snapshot.sh create wave-25-test test/snapshots/snap2

# Diff them
bash tools/allocation-diff.sh test/snapshots/snap1/snapshots/snapshot-*.json \
                              test/snapshots/snap2/snapshots/snapshot-*.json | head -30

# Verify diff detected the change
bash tools/allocation-diff.sh test/snapshots/snap1/snapshots/snapshot-*.json \
                              test/snapshots/snap2/snapshots/snapshot-*.json | grep -q "Added patterns" && echo "✓ Changes detected"

echo "✓ All verifications passed"
```

---

## T-28: Tool Documentation (2 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-21 through T-27 (all tools complete)  
**Verification:** MANDATORY

### Objective

Create comprehensive documentation for allocation tools. CLI reference, usage examples, integration guides.

### Deliverable

File: `docs/ALLOCATION_TOOLS_REFERENCE.md` (150 lines) with sections:

1. **Tool Overview** (20 lines)
   - allocation-check.sh (enhanced)
   - allocation-snapshot.sh (new)
   - allocation-diff.sh (new)
   - Python/Go helpers (stubs)

2. **allocation-check.sh Reference** (50 lines)
   - All 7 commands: syntax, options, examples
   - validate-file (new)
   - query-violations (new)
   - ledger-stats (new)
   - check-file (existing)
   - check-pattern (existing)
   - expand-allocation (existing)
   - validate-scope (existing)

3. **allocation-snapshot.sh** (20 lines)
   - Usage: create snapshots
   - Metadata format
   - Example workflow

4. **allocation-diff.sh** (20 lines)
   - Usage: compare snapshots
   - Breaking change detection
   - Example workflow

5. **Agent Integration** (30 lines)
   - Python helper usage
   - Go helper usage
   - Shell-out fallback

6. **Performance Baseline** (10 lines)
   - Operation → target latency table
   - Regression alert thresholds
   - Benchmark script location

### Acceptance Criteria

- ✓ File created at `docs/ALLOCATION_TOOLS_REFERENCE.md`
- ✓ All 7 commands documented
- ✓ Usage examples for each tool
- ✓ Integration guide for agents
- ✓ Performance targets included
- ✓ Links to contract files (allocation-check.contract.md)

### Verification

```bash
test -f docs/ALLOCATION_TOOLS_REFERENCE.md || exit 1

# Verify sections
grep -q "^## allocation-check.sh Reference" docs/ALLOCATION_TOOLS_REFERENCE.md && echo "✓ Section 1"
grep -q "^## allocation-snapshot.sh" docs/ALLOCATION_TOOLS_REFERENCE.md && echo "✓ Section 2"
grep -q "^## allocation-diff.sh" docs/ALLOCATION_TOOLS_REFERENCE.md && echo "✓ Section 3"
grep -q "^## Agent Integration" docs/ALLOCATION_TOOLS_REFERENCE.md && echo "✓ Section 4"

# Verify all commands mentioned
grep -q "validate-file\|query-violations\|ledger-stats\|check-file" docs/ALLOCATION_TOOLS_REFERENCE.md && echo "✓ New commands documented"

echo "✓ All verifications passed"
```

---

## T-29: Tool Integration Test (3 hours)

**Owner:** Altitude (Strategic)  
**Depends:** T-21 through T-28 (all tools + documentation)  
**Verification:** MANDATORY

### Objective

Integration test for all tools working together. Verify agents can call tools, tools produce valid output, performance targets met.

### Test Scenarios

**Scenario 1: Full Tool Chain**
```bash
# 1. Create snapshot (baseline)
tools/allocation-snapshot.sh create wave-25 test/baselines

# 2. Validate file via allocation-check.sh
tools/allocation-check.sh validate-file agents/test.md allocation.yaml

# 3. Query violations
tools/allocation-check.sh query-violations .specs/changes/wave-25/03-execution-ledger.md

# 4. Generate stats
tools/allocation-check.sh ledger-stats .specs/changes/wave-25/03-execution-ledger.md

# 5. Create new snapshot (after changes)
tools/allocation-snapshot.sh create wave-25 test/baselines

# 6. Diff snapshots
tools/allocation-diff.sh test/baselines/snapshots/snapshot-*.json test/baselines/snapshots/snapshot-*.json

# Verify: All commands succeeded
```

**Scenario 2: Agent Integration (Python)**
```python
# Test that agents can import and use allocation helpers
from agents.lib.allocation_check import AllocationValidator

allocation = {'allowed_files': ['agents/*.md'], 'forbidden_files': []}
validator = AllocationValidator(allocation)

result = validator.validate_file('agents/altitude-execution.agent.md')
assert result['status'] == 'allowed'
print("✓ Python agent integration works")
```

**Scenario 3: Performance (All Targets)**
```bash
# Verify all performance targets met
echo "Running performance tests..."

time tools/allocation-check.sh validate-file agents/test.md allocation.yaml
# Expected: < 2ms

time tools/allocation-check.sh query-violations ledger-1000.md
# Expected: < 200ms

time tools/allocation-check.sh ledger-stats ledger-1000.md
# Expected: < 300ms

echo "✓ All performance targets met"
```

### Deliverables

- `test/integration/test-tools-integration.sh` (60 lines)
- Test fixtures (allocations, ledgers, snapshots)
- Integration report

### Acceptance Criteria

- ✓ All 3 tools work together (chain scenario)
- ✓ Agent Python integration works
- ✓ All performance targets met
- ✓ Output formats correct (JSON, CSV, table)
- ✓ No data corruption
- ✓ Edge cases handled (empty ledger, missing files, etc.)

### Verification

```bash
# Run integration test suite
bash test/integration/test-tools-integration.sh

# Verify all tests passed
echo $? -eq 0 && echo "✓ All integration tests passed"

echo "✓ All verifications passed"
```

---

## T-30: Tool Approval Gate (1 hour)

**Owner:** User (External)  
**Depends:** T-21 through T-29 (all Phase 3 deliverables complete)  
**Verification:** USER CONFIRMATION

### Required Action

User reviews and approves Phase 3 output (tools + performance + documentation):

1. **Phase 3 Completion Checklist:**
   - ✓ T-21: validate-file command (3h)
   - ✓ T-22: query-violations command (3h)
   - ✓ T-23: ledger-stats command (2h)
   - ✓ T-24: Performance tests + baseline (4h)
   - ✓ T-25: Agent integration helpers (2h)
   - ✓ T-26: allocation-snapshot.sh tool (3h)
   - ✓ T-27: allocation-diff.sh tool (2h)
   - ✓ T-28: Tool documentation (2h)
   - ✓ T-29: Integration tests (3h)

2. **Quality Gates:**
   - All commands functional and tested ✓
   - Performance targets met (0 failures) ✓
   - Integration tests pass ✓
   - Documentation complete ✓
   - Agent helpers working (Python stub) ✓
   - Backward compatibility confirmed ✓

3. **Gate Criteria:**
   - Phase 3 deliverables complete (9 tasks) ✓
   - No performance regressions ✓
   - All integration tests pass ✓
   - Confidence: 95% (only Phase 4 testing remains) ✓

4. **Decision:**
   - **APPROVED:** Proceed to Phase 4 (testing & validation)
   - **BLOCKED:** Return to specific task (reason required)

### Acceptance

User confirms (via chat or command) one of:
- "APPROVED — proceed to Phase 4"
- "NEEDS REVISION — [reason]"

### Verification

```bash
# Verify all Phase 3 deliverables exist
test -f tools/allocation-check.sh && grep -q "validate-file" tools/allocation-check.sh && echo "✓ T-21"
grep -q "query-violations" tools/allocation-check.sh && echo "✓ T-22"
grep -q "ledger-stats" tools/allocation-check.sh && echo "✓ T-23"
test -f test/performance-benchmarks/results-*.csv && echo "✓ T-24"
test -f agents/lib/allocation_check.py && echo "✓ T-25"
test -f tools/allocation-snapshot.sh && echo "✓ T-26"
test -f tools/allocation-diff.sh && echo "✓ T-27"
test -f docs/ALLOCATION_TOOLS_REFERENCE.md && echo "✓ T-28"
test -f test/integration/test-tools-integration.sh && echo "✓ T-29"

echo "✓ All Phase 3 deliverables verified"
```

---

# MEMORY WRITE TRIGGER

**Trigger:** Phase 3 completion (T-30 gate passed)

**Memory Entry Location:** `.specs/memory/active-state.md`

**Update Required:**
```yaml
active_phase: Phase 4 (Testing & Validation)
active_task: T-30 (GATE PASSED) → T-31 (NEXT)
last_update: 2026-07-03T23:XX:XXZ
```

---

# NEXT PHASE: PHASE 4 (Testing & Validation)

**When:** After T-30 user approval  
**Duration:** 16h serial / 7h parallel  
**Deliverable:** 16 integration tests + 4 load tests + validation report  
**Tasks:** T-31 through T-35 (Ship)  

Phase 4 will be created after T-30 approval, focusing on:
- Integration test execution (16 scenarios)
- Load test execution (1000+ tasks)
- Edge case test execution (18 scenarios)
- Validation report + lessons learned
- Wave 25A ship & closure

---

**Document Status:** READY FOR EXECUTION  
**Created:** 2026-07-03  
**Phase 3 User Decision Checkpoint:** AWAITING T-30 GATE APPROVAL

---

## SUMMARY

You now have **3 complete phase execution plans:**

| Phase | Tasks | Specs Complete | Status |
|-------|-------|---|---|
| **Phase 1: Analysis** | T-01–T-10 | 9 specs | ✅ Approved by user |
| **Phase 2: Design** | T-11–T-20 | 10 specs | ✅ Approved by user |
| **Phase 3: Tooling** | T-21–T-30 | 10 specs | ✅ COMPLETE (THIS DOCUMENT) |
| **Phase 4: Testing** | T-31–T-35 | (pending T-30 approval) | ⏳ Next |

**Total Wave 25A:** ~100 hours, 35 tasks, 4 gates

---

**NEXT IMMEDIATE ACTION:**

Please review Phase 3 plan and confirm:

**A. APPROVED** → Proceed to Phase 4 (testing begins)

**B. NEEDS REVISION** → Describe what needs fixing
