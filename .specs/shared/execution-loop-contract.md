# Execution Loop Contract

## Purpose

Make Ralph Loop the standard executable-work protocol for Harness V3.

The loop prevents implementation, validation, and repair from becoming untracked side activities. Each executable step must name the expected result, perform the work, verify it, repair bounded failures, and record evidence.

## Loop Postures

| Posture | Applies when | Requirement |
| --- | --- | --- |
| `mandatory` | work mutates files, state, config, runtime, production data, commands, plugins, or critical durable artifacts | run Ralph Loop and record evidence |
| `advisory` | discovery, planning, non-critical artifact drafting, or exploratory analysis | use loop discipline when useful, but do not force ceremony |
| `not_applicable` | answer-only, trivial read-only, or direct command-output requests | no loop required |

## Mandatory Work Classes

Ralph Loop is mandatory for:

- code generation
- code edits
- config edits
- plugin changes
- command removal
- Task-Spec integration
- execution of `.specs` tasks
- critical artifact generation
- validation work
- security-sensitive changes
- production-data-affecting changes

## Advisory Work Classes

Ralph Loop is advisory for:

- pure discovery
- initial ideation
- non-mutating explanation
- route classification
- lightweight status reporting

## Loop Shape

```text
1. restate task and loop posture
2. identify constraints and allowed scope
3. plan the smallest valid step
4. execute the step
5. verify the step
6. compare against acceptance criteria
7. repair within scope if needed
8. record evidence
9. update task/state/todo projection
```

## Step Boundary Rule

Each operational step must have:

- step name
- success criterion
- verification command or manual check
- evidence location or evidence summary
- pass/fail/blocked verdict

## Runtime Tool Rule

When the active runtime exposes `verify_step`, call it after each multi-step executable boundary:

```text
verify_step(step, verdict: PASS | FAIL | BLOCKED)
```

If the runtime does not expose `verify_step`, do not claim it ran. Keep the same loop manually and record the manual verdict in the execution ledger, validation report, or final response.

## Failure Handling

If validation fails:

1. diagnose the failure
2. repair within the active allowed scope
3. rerun the same validation
4. retry at most twice for the same step
5. escalate if the same failure repeats or scope must broaden

## Verdict Semantics

| Verdict | Meaning | Next action |
| --- | --- | --- |
| `PASS` | success criterion met | advance |
| `FAIL` | criterion not met but repair is within scope | repair and retry |
| `BLOCKED` | cannot proceed without user input, external state, or broader allocation | halt and surface blocker |

## Evidence Requirements

Evidence can be:

- command output
- test result
- linter/typecheck result
- rendered screenshot or browser check
- inspected file reference
- validation artifact
- manual check with explicit observed signal

Evidence cannot be only:

- intent
- unverifiable memory
- "looks fine" without inspected source
- a passing check that does not cover the changed behavior

## Coordinator Responsibilities

The coordinator must:

- decide loop posture before execution
- ensure task contracts include loop posture for executable work
- project todos with `verify:` clauses
- record failed validation and bounded repair attempts
- prevent scope broadening without allocation repair or user confirmation
- update state when validation or ship decisions change the active phase

## Stop Conditions

Stop and ask, replan, or create a repair task when:

- task lacks allowed files, forbidden scope, acceptance criteria, or verification
- validation cannot be run and no manual check is available
- repair would touch files outside allocation
- the same step fails three times total
- user instruction conflicts with current task contract
- runtime tool enforcement is claimed but unavailable
