# Definition of Done

## Task Done

A task is done when:

- status is `validated`
- allowed files were respected
- acceptance criteria are met
- verification ran or was justified
- evidence is saved
- execution ledger is updated
- validation is updated
- rollback note exists
- memory impact was evaluated

## Change Done

A change is done when:

- required tasks are `validated`, `skipped`, or `cancelled` with justification
- executive report exists
- ship note exists
- state is updated
- decisions are recorded
- final risks are recorded
- memory impact was evaluated

## Harness Done

The harness migration is done when:

- `altitude-intent` is the default agent
- all altitude agents exist
- execution refuses to run without a ready task
- validation rejects expanded scope
- reports do not depend on chat history
- memory updates `.specs/memory`
- commands are documented as compatibility surface
- RTK and Headroom are optional and safe-fallback
- MCPs are not exposed globally by default
