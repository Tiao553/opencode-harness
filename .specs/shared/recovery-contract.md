# Recovery Contract

Contract defining atomic state snapshots, rollback semantics, checkpoint policies, and restoration integrity.

**Version:** 1.0  
**Effective:** Wave 12  
**Updated:** 2026-06-29  

---

## 1. Snapshot Schema

Each snapshot captures a point-in-time state for recovery.

### snapshot_schema:

```yaml
snapshot_id: "snap-<timestamp>-<random>"
created_at: "<ISO8601 timestamp>"
state_hash: "sha256:<hex>"
components:
  altitude_phase: "<phase_name>"
  altitude_status: "<status>"
  active_change: "<change_id>"
  active_task: "<task_id>"
  user_id: "<user_id>"
  notes: "<optional reason>"
```

**Fields:**
- `snapshot_id`: Unique identifier (format: `snap-<ISO timestamp>-<6 char random>`)
- `created_at`: UTC timestamp of snapshot creation
- `state_hash`: SHA256 of entire state JSON before serialization (format: `sha256:<hash>`)
- `components`: Nested object containing altitude phase/status, change/task refs, user context
- `notes`: Optional reason for snapshot (e.g., "before_shell_ops", "before_phase_transition")

**Immutable after creation.** Snapshots are append-only; no modification.

---

## 2. Rollback Semantics

### 2.1 Atomicity

Rollback is atomic: either complete or not at all.

- Read snapshot from stable storage
- Validate checksum against state_hash
- Restore state in single atomic write (temp file + `mv`)
- On failure, rollback is incomplete; do not leave partial state

### 2.2 Idempotence

Multiple rollback calls to the same snapshot produce the same result.

```bash
rollback --to snap-001 > state.json  # result_1.json
rollback --to snap-001 > state.json  # result_2.json
# result_1 === result_2
```

Implementation: Read snapshot from immutable storage, write to temp, mv to target.

### 2.3 Transactional

Rollback must not partially restore. Either:
- Full rollback (all state restored)
- No rollback (error logged, original state unchanged)

---

## 3. Checkpoint Policies

### 3.1 When to Snapshot

Create snapshots at these critical points:

| Checkpoint | Reason | Trigger |
|-----------|--------|---------|
| Before Execution phase | Gate preservation | `altitude-execution` before entering phase |
| Before shell operations | Command safety | Before `bash`, `git`, destructive ops |
| Before file writes | Mutation safety | Before editing `.specs/shared/*`, agents/* |
| On phase transition | State boundary | Before `state.md` phase change |
| On error recovery | Audit trail | Before `rollback` is called |

### 3.2 Snapshot Retention

- **Keep all snapshots** — No automatic cleanup
- User must manually remove snapshots from `.specs/changes/.../snapshots/`
- Retention: Indefinite (audit trail)
- Frequency: Bounded by operation frequency (typically 5-20 per wave)

---

## 4. Validation Rules

### 4.1 Checksum Validation

Every rollback must verify `state_hash`:

```bash
# Read snapshot
state=$(cat .specs/changes/waves-7-17-implementation/snapshots/snap-001.json)

# Extract state_hash
expected_hash=$(echo "$state" | jq -r '.state_hash')

# Compute hash of state components
actual_hash=$(echo "$state" | jq '.components' | sha256sum | awk '{print "sha256:" $1}')

# Verify
if [ "$expected_hash" != "$actual_hash" ]; then
  echo "ERROR: Snapshot corruption detected"
  exit 1
fi
```

### 4.2 Timestamp Ordering

Snapshots must have monotonically increasing `created_at`:

```bash
# When creating new snapshot, verify:
new_timestamp > last_snapshot_timestamp
```

Prevents clock skew or out-of-order snapshots.

### 4.3 Cycle Detection

Prevent circular restore (rolling back to future snapshot):

```bash
# When rolling back to snap-A:
if snap_A.created_at > current_time:
  echo "ERROR: Cannot rollback to future snapshot"
  exit 1
fi
```

### 4.4 Component Consistency

Restored state must have valid phase/status:

- `altitude_phase` must be one of: `Intent`, `Structure`, `Design`, `Execution`, `Validate`, `Ship`
- `altitude_status` must be one of: `blocked`, `ready`, `in_progress`, `implemented`, `validated`
- `active_change` must match an existing change directory in `.specs/changes/`
- `active_task` must match task file in that change

---

## 5. Storage Model

### 5.1 Location

All snapshots stored in:
```
.specs/changes/<change_id>/snapshots/
```

For waves-7-17-implementation:
```
.specs/changes/waves-7-17-implementation/snapshots/
  snap-2026-06-29T23-30-00Z-abc123.json
  snap-2026-06-29T23-45-00Z-def456.json
  ...
```

### 5.2 Filename Format

```
snap-<ISO_TIMESTAMP>-<RANDOM_6>.json
```

Example:
- `snap-2026-06-29T23:30:00Z-a1b2c3.json`

### 5.3 Atomic Write

All writes use temp + move:

```bash
# Write
tmp=$(mktemp ".specs/changes/<change_id>/snapshots/.snap-XXXXXX.tmp")
echo "$snapshot_json" > "$tmp"
chmod 644 "$tmp"
mv "$tmp" ".specs/changes/<change_id>/snapshots/snap-<id>.json"

# Read
cat ".specs/changes/<change_id>/snapshots/snap-<id>.json"

# No append, no overwrite, no partial writes
```

---

## 6. Integration Points

### 6.1 Altitude Execution

- Create snapshot before entering Execution phase
- Create snapshot before shell operations
- Create snapshot before file writes
- Call `tools/recovery-manager.sh snapshot` with current state
- Store returned `snapshot_id` in execution ledger
- On error, call `tools/recovery-manager.sh rollback --to $snapshot_id`

### 6.2 State Validator

- Validate snapshot checksums on restore
- Validate timestamp ordering
- Detect cycles (prevent future rollbacks)
- Reject corrupted snapshots with clear error

### 6.3 Execution Ledger

Record all snapshot operations:

```markdown
## Snapshot Operations

| Timestamp | Operation | Snapshot ID | Reason | Result |
|-----------|-----------|-------------|--------|--------|
| 2026-06-29T23:30:00Z | snapshot | snap-001 | before_execution | SUCCESS |
| 2026-06-29T23:45:00Z | snapshot | snap-002 | before_shell_ops | SUCCESS |
| 2026-06-30T00:00:00Z | rollback | snap-002 | error_recovery | SUCCESS |
```

---

## 7. Error Handling

### 7.1 Snapshot Errors

| Error | Cause | Action |
|-------|-------|--------|
| `ERR_SNAPSHOT_DIR_MISSING` | No `.../snapshots/` dir | Create directory, retry |
| `ERR_STATE_HASH_MISMATCH` | Checksum validation failed | Reject snapshot, log error, escalate |
| `ERR_TIMESTAMP_INVALID` | Timestamp not ISO8601 | Reject snapshot, use current time |
| `ERR_COMPONENTS_INVALID` | Missing/invalid components | Reject snapshot, require all fields |

### 7.2 Rollback Errors

| Error | Cause | Action |
|-------|-------|--------|
| `ERR_SNAPSHOT_NOT_FOUND` | Snapshot file missing | List available, ask user to select |
| `ERR_STATE_HASH_MISMATCH` | Checksum corrupted | Reject rollback, preserve current state |
| `ERR_FUTURE_SNAPSHOT` | Attempting to restore future state | Reject rollback, cannot go forward |
| `ERR_ATOMIC_WRITE_FAILED` | Temp file or mv failed | Preserve both old and temp, manual intervention |

---

## 8. Verification Checklist

Before rollback, verify:

- [ ] Snapshot file exists and is readable
- [ ] JSON is valid (not corrupted)
- [ ] `snapshot_id` is present and unique
- [ ] `created_at` is ISO8601 and valid
- [ ] `state_hash` matches computed hash of components
- [ ] `altitude_phase` is valid (Intent|Structure|Design|Execution|Validate|Ship)
- [ ] `altitude_status` is valid (blocked|ready|in_progress|implemented|validated)
- [ ] `created_at` is <= current time (no future snapshots)
- [ ] Timestamp is > last snapshot timestamp (monotonic ordering)

---

## 9. Success Criteria

Recovery system is valid when:

✅ Snapshot schema documented with all required fields  
✅ Rollback is atomic (temp file + mv, no partial writes)  
✅ Checksums validate snapshot integrity  
✅ Idempotent: same rollback produces same result  
✅ Cycle detection prevents future rollbacks  
✅ Timestamp ordering enforced (monotonic)  
✅ Storage is immutable (snapshots never modified)  
✅ All 4 commands work (`snapshot`, `rollback`, `validate`, `list-snapshots`)  
✅ Fixtures verify snapshot → modify → rollback flow  
✅ Altitude execution integration captures snapshots in ledger  

---
