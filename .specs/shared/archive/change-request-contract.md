# Change Request Contract

Each folder under `.specs/changes/` is one self-contained change request.

## Required Structure

```text
.specs/changes/<id-slug>/
  00-intent.md
  01-structure.md
  02-decomposition.md
  03-execution-ledger.md
  04-validation.md
  05-executive-report.md
  06-ship-note.md
  state.md
  CHANGELOG.md
  tasks/
  decisions/
  evidence/
  reviews/
```

## Statuses

```text
draft
intent_ready
structure_ready
decomposed
ready_for_execution
in_execution
in_validation
validated
reported
ready_to_ship
shipped
archived
blocked
cancelled
```

## Transitions

```text
draft -> intent_ready
intent_ready -> structure_ready
structure_ready -> decomposed
decomposed -> ready_for_execution
ready_for_execution -> in_execution
in_execution -> in_validation
in_validation -> validated
validated -> reported
reported -> ready_to_ship
ready_to_ship -> shipped
shipped -> archived
any -> blocked
blocked -> previous_state
draft -> cancelled
```
