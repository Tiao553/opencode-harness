# Recovery Manager Contract

Command-line interface for atomic state snapshots, rollback, and validation.

**Tool:** `tools/recovery-manager.sh`  
**Version:** 1.0  
**Effective:** Wave 12  

---

## 1. Command: snapshot

Create a point-in-time snapshot of system state.

### 1.1 Syntax

```bash
recovery-manager.sh snapshot --state <json> [--note <text>]
```

### 1.2 Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `--state` | JSON string | Yes | State object to snapshot (must be valid JSON) |
| `--note` | Text | No | Reason for snapshot (default: "manual_snapshot") |

### 1.3 Returns

**Stdout:** `snapshot_id` (format: `snap-<timestamp>-<random>`)

**Stderr:** Info/error messages

**Exit Code:** 0 on success, 1 on error

### 1.4 Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| `snapshot: --state is required` | Missing `--state` argument | Provide `--state` with valid JSON |
| `snapshot: --state is not valid JSON` | JSON is malformed | Fix JSON syntax |
| `snapshot: cannot create $SNAPSHOTS_DIR` | Directory creation failed | Check filesystem permissions |
| `snapshot: cannot create temp file` | Temp file creation failed | Check `/tmp` or `.specs` permissions |
| `snapshot: cannot format snapshot JSON` | JSON serialization failed | Verify state JSON is valid |
| `snapshot: cannot move temp to snapshot file` | Atomic write failed | Check filesystem permissions |

### 1.5 Examples

#### Create snapshot with empty state

```bash
$ tools/recovery-manager.sh snapshot --state '{}'
snap-2026-06-29T23:30:00Z-a1b2c3
```

#### Create snapshot with altitude state

```bash
$ tools/recovery-manager.sh snapshot --state '{
  "altitude_phase": "Execution",
  "altitude_status": "in_progress",
  "active_change": "waves-7-17-implementation",
  "active_task": "W12-RECOVERY"
}' --note "before_execution"
snap-2026-06-29T23:30:05Z-d4e5f6
```

#### Capture snapshot_id for later rollback

```bash
SNAP=$(tools/recovery-manager.sh snapshot --state '{"phase":"Execution"}')
echo "Created snapshot: $SNAP"
# Use $SNAP in rollback command later
```

---

## 2. Command: rollback

Restore system state from a snapshot.

### 2.1 Syntax

```bash
recovery-manager.sh rollback --to <snapshot_id> [--output <file>]
```

### 2.2 Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `--to` | snapshot_id | Yes | Snapshot ID to restore (format: `snap-*`) |
| `--output` | filepath | No | Output file for restored state (default: stdout) |

### 2.3 Returns

**Stdout/File:** Restored state JSON (components from snapshot)

**Stderr:** Info/error messages

**Exit Code:** 0 on success, 1 on error

### 2.4 Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| `rollback: --to is required` | Missing `--to` argument | Provide `--to` with snapshot_id |
| `rollback: snapshot not found: <id>` | Snapshot file doesn't exist | Use `list-snapshots` to find valid IDs |
| `rollback: snapshot validation failed: <id>` | Snapshot is corrupted | Use `validate` command to diagnose |
| `rollback: cannot read snapshot file` | Filesystem error | Check file permissions |
| `rollback: cannot extract components from snapshot` | JSON parsing failed | Snapshot may be corrupted |
| `rollback: snapshot is in future: <timestamp> > <now>` | Snapshot has future timestamp | Snapshot is invalid; create new one |
| `rollback: cannot create temp file` | Temp file creation failed | Check `/tmp` or output dir permissions |
| `rollback: cannot move temp to output file` | Atomic write failed | Check output file permissions |

### 2.5 Examples

#### Rollback to snapshot, output to stdout

```bash
$ tools/recovery-manager.sh rollback --to snap-2026-06-29T23:30:00Z-a1b2c3
{
  "altitude_phase": "Execution",
  "altitude_status": "in_progress",
  ...
}
```

#### Rollback to snapshot, save to file

```bash
$ tools/recovery-manager.sh rollback --to snap-2026-06-29T23:30:00Z-a1b2c3 \
    --output restored-state.json
$ cat restored-state.json
```

#### Rollback and pipe to jq

```bash
$ tools/recovery-manager.sh rollback --to snap-2026-06-29T23:30:00Z-a1b2c3 | \
    jq '.altitude_phase'
"Execution"
```

#### Idempotent rollback

```bash
$ tools/recovery-manager.sh rollback --to snap-001 > result1.json
$ tools/recovery-manager.sh rollback --to snap-001 > result2.json
$ diff result1.json result2.json  # Should be empty (identical)
```

---

## 3. Command: validate

Verify snapshot integrity and consistency.

### 3.1 Syntax

```bash
recovery-manager.sh validate --snapshot <snapshot_id>
```

### 3.2 Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `--snapshot` | snapshot_id | Yes | Snapshot ID to validate |

### 3.3 Returns

**Stdout:** `OK` if valid

**Stderr:** Info/error messages

**Exit Code:** 0 if valid, 1 if invalid

### 3.4 Validation Checks

| Check | Condition | Error Message |
|-------|-----------|---------------|
| File exists | Snapshot file present in storage | `snapshot not found: <id>` |
| JSON valid | JSON parses without error | `snapshot JSON is corrupted` |
| Required fields | All of: `snapshot_id`, `created_at`, `state_hash`, `components` | `missing required field: <field>` |
| Snapshot ID match | Stored `snapshot_id` matches filename | `snapshot_id mismatch` |
| Timestamp valid | `created_at` is ISO8601 | `invalid ISO8601 timestamp` |
| Hash format | `state_hash` matches `sha256:<64-char-hex>` | `invalid state_hash format` |
| Phase valid | `altitude_phase` is one of: Intent, Structure, Design, Execution, Validate, Ship | `invalid altitude_phase` |
| Status valid | `altitude_status` is one of: blocked, ready, in_progress, implemented, validated | `invalid altitude_status` |
| Checksum match | Recomputed hash = stored hash | `checksum mismatch` |
| Not in future | `created_at` <= current time | (checked in rollback, not here) |

### 3.5 Examples

#### Validate snapshot

```bash
$ tools/recovery-manager.sh validate --snapshot snap-2026-06-29T23:30:00Z-a1b2c3
OK
```

#### Validate and check exit code

```bash
$ tools/recovery-manager.sh validate --snapshot snap-001
$ echo "Exit code: $?"
# 0 = valid, 1 = invalid
```

#### Validate all snapshots

```bash
$ for snap in .specs/changes/waves-7-17-implementation/snapshots/snap-*.json; do
    id=$(basename "$snap" .json)
    tools/recovery-manager.sh validate --snapshot "$id" || echo "INVALID: $id"
  done
```

---

## 4. Command: list-snapshots

List all snapshots for a change.

### 4.1 Syntax

```bash
recovery-manager.sh list-snapshots [--change <change_id>]
```

### 4.2 Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `--change` | change_id | No | Change ID (default: from env or `waves-7-17-implementation`) |

### 4.3 Returns

**Stdout:** Table of snapshots with metadata

**Stderr:** Info messages

**Exit Code:** 0

### 4.4 Output Format

```
Snapshots in .specs/changes/<change_id>/snapshots/:

  snap-2026-06-29T23:30:00Z-a1b2c3                  | 2026-06-29T23:30:00Z | Execution | before_execution
  snap-2026-06-29T23:45:00Z-d4e5f6                  | 2026-06-29T23:45:00Z | Execution | before_shell_ops
```

Columns:
- `snapshot_id` — Full snapshot identifier
- `created_at` — ISO8601 timestamp
- `altitude_phase` — Current phase or `-` if not set
- `notes` — Reason for snapshot

### 4.5 Examples

#### List snapshots for current change

```bash
$ tools/recovery-manager.sh list-snapshots
Snapshots in .specs/changes/waves-7-17-implementation/snapshots/:

  snap-2026-06-29T23:30:00Z-a1b2c3                  | 2026-06-29T23:30:00Z | Execution | before_execution
  snap-2026-06-29T23:45:00Z-d4e5f6                  | 2026-06-29T23:45:00Z | Execution | before_shell_ops
```

#### List snapshots for specific change

```bash
$ tools/recovery-manager.sh list-snapshots --change other-wave
Snapshots in .specs/changes/other-wave/snapshots/:
  ...
```

---

## 5. Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (snapshot created, rollback completed, validation passed, list returned) |
| 1 | Error (invalid arguments, file not found, JSON error, validation failed) |

---

## 6. Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `CHANGE_ID` | `waves-7-17-implementation` | Change directory for snapshot storage |
| `JQ_CMD` | `jq` | JSON processor command (e.g., for testing with mock) |

### 6.1 Override Examples

```bash
# Use different change
CHANGE_ID=other-wave tools/recovery-manager.sh list-snapshots

# Use custom jq (for testing)
JQ_CMD=/usr/bin/jq tools/recovery-manager.sh snapshot --state '{}'
```

---

## 7. Storage and Atomicity

### 7.1 Storage Location

All snapshots stored in:
```
.specs/changes/<CHANGE_ID>/snapshots/snap-*.json
```

### 7.2 Atomic Writes

All write operations use temp + move pattern:

```bash
tmp=$(mktemp "$SNAPSHOTS_DIR/.snap-XXXXXX.tmp")
echo "$data" > "$tmp"
mv "$tmp" "$SNAPSHOTS_DIR/snap-<id>.json"
```

This ensures:
- No partial writes
- No data corruption
- Atomic from reader perspective

### 7.3 File Permissions

- Snapshots created with mode `644` (user: rw, group: r, other: r)
- Snapshots are immutable after creation (no modification)
- Snapshots are never deleted by tool (manual cleanup only)

---

## 8. Integration with Altitude Execution

### 8.1 Before Phase Transition

```bash
# In altitude-execution before changing phase
STATE=$(current_state_json)
SNAP=$(tools/recovery-manager.sh snapshot --state "$STATE" --note "before_phase_transition")
echo "Snapshot: $SNAP" >> 03-execution-ledger.md
```

### 8.2 Before Shell Operations

```bash
# Before destructive operations
SNAP=$(tools/recovery-manager.sh snapshot --state "$STATE" --note "before_shell_ops")

# Run operation
if ! some_shell_operation; then
  # On failure, rollback
  tools/recovery-manager.sh rollback --to "$SNAP" --output restored-state.json
  echo "Rolled back to $SNAP" >> 03-execution-ledger.md
fi
```

### 8.3 Error Recovery

```bash
# On error, attempt recovery
if error_detected; then
  tools/recovery-manager.sh rollback --to "$last_good_snapshot" --output state.json || true
fi
```

---

## 9. Performance Characteristics

| Operation | Complexity | Time | Notes |
|-----------|-----------|------|-------|
| `snapshot` | O(n) | ~100ms | n = state size; limited by JSON serialization + SHA256 |
| `rollback` | O(n) | ~100ms | n = state size; limited by file I/O + JSON parsing |
| `validate` | O(n) | ~100ms | n = state size; recomputes checksum |
| `list-snapshots` | O(m) | ~50ms | m = number of snapshots (typically 5-20) |

Snapshots are typically <10KB, so all operations should complete in <200ms.

---

## 10. Troubleshooting

### Problem: Snapshot command returns no output

**Cause:** Stderr being captured or piped  
**Solution:** Redirect stdout to see snapshot_id:
```bash
SNAP=$(tools/recovery-manager.sh snapshot --state '{}' 2>/dev/null)
echo "$SNAP"
```

### Problem: Rollback fails with "checksum mismatch"

**Cause:** Snapshot file was corrupted or modified  
**Solution:** Use `validate` to diagnose, then create new snapshot or choose different snapshot

### Problem: Permission denied on snapshot directory

**Cause:** Directory lacks write permissions  
**Solution:** `chmod 755 .specs/changes/waves-7-17-implementation/snapshots`

### Problem: Cannot find jq command

**Cause:** jq not installed  
**Solution:** Install jq: `sudo apt-get install jq` or override `JQ_CMD`

---
