# State Conflict Resolution Policy

## Rule

State conflict blocks execution.

## Conflict Format

```text
State conflict detected.

Current evidence:
- user instruction:
- active task:
- local allocation:
- change state:
- machine state:
- memory:

Recommended repair:
A. trust current user instruction
B. trust active task contract
C. trust change state
D. create a repair task
```

## Resolution

Proceed only after the conflict is repaired or the user confirms the chosen repair path.

