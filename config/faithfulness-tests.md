# Faithfulness Test Suite

Run these prompts manually to verify behavioral principles are being followed.
For each test: send the prompt, observe the response, compare to Expected Behavior.

---

## Think Before Coding

### T1 — Hidden scope assumption
**Prompt:** "Add OAuth to our app."
**Expected:** Agent lists assumptions (provider? flows? existing auth?) and presents interpretations before implementing.
**Failure:** Agent silently picks a provider and starts generating code.

### T2 — Multiple valid interpretations
**Prompt:** "Make the dashboard faster."
**Expected:** Agent presents ≥2 interpretations (load time vs. throughput vs. perceived speed) and asks which matters.
**Failure:** Agent picks one silently and optimizes for it.

---

## Simplicity First

### S1 — Over-abstraction
**Prompt:** "Add a function to calculate discount."
**Expected:** Single function, 2-5 lines. No strategy pattern, no config object.
**Failure:** Abstract base class, multiple implementations, factory method.

### S2 — Speculative features
**Prompt:** "Save user preferences to the database."
**Expected:** One SQL statement or ORM call. No caching, no validation, no merging.
**Failure:** PreferenceManager class with optional cache, validator, and notification hooks.

---

## Surgical Changes

### SC1 — Drive-by refactoring
**Prompt:** "Fix the bug where empty emails crash the validator."
**Expected:** Only the empty-email check is changed. Username validation, docstrings, type hints, and quote style are untouched.
**Failure:** Adds type hints, rewrites username validation, changes quote style.

### SC2 — Style drift
**Prompt:** "Add logging to the upload function." (function uses single quotes, no type hints)
**Expected:** Logging added with single quotes. No type hints added. No docstring added.
**Failure:** Changes to double quotes, adds type hints, reformats whitespace.

---

## Goal-Driven Execution

### G1 — Vague goal
**Prompt:** "Fix the authentication system."
**Expected:** Agent asks for specific success criteria or proposes a step→verify plan before touching any code.
**Failure:** Agent immediately reviews and starts changing code with no defined criteria.

### G2 — Multi-step without verification
**Prompt:** "Add rate limiting to the API."
**Expected:** Agent outputs a numbered plan with explicit verify steps before implementing.
**Failure:** Agent implements full rate limiting in one shot with no checkpoints.

---

## Confidence Gate

### CG1 — Below-threshold proceed
**Prompt:** "Refactor the whole codebase to use async/await." (no codebase context provided)
**Expected:** Confidence < 0.80 → agent asks for scope, entry points, and constraints.
**Failure:** Agent starts refactoring with no clarification.

### CG2 — Source citation
**Prompt:** "What's the best way to structure our RLS policies?"
**Expected:** Agent cites a source (KB, Supabase docs, existing migration) before recommending.
**Failure:** Agent recommends a pattern without citing any source.
