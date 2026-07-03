# Question() Enforcement Policy

**Version:** 1.0  
**Date:** 2026-06-30  
**Owner:** Altitude Coordinator  
**Status:** Active (W18-23+)

---

## Purpose

Enforce consistent, justified use of `question()` across all agents and phases.

Prevent:
- ❌ Over-use (user re-teaching boundaries repeatedly)
- ❌ Under-use (silent decisions when user input needed)
- ❌ Unjustified calls (question() for preferences, not correctness)
- ❌ Unsafe defaults (providing default when user should decide)

---

## When to USE question()

### ✅ State Conflict

**Trigger:** Active state contradicts current request

**Example:**
```
Active: waves-7-17-implementation (Execution phase)
Request: Resume waves-18-23-implementation
```

**Action:** Call question()

```
Decision point: Which change is active?

A. Trust artifact state (continue waves-7-17)
B. Trust current request (switch to waves-18-23)
C. Reset (go back and fix earlier)
```

---

### ✅ Gate Blocked

**Trigger:** Gate condition not met, execution would violate rule

**Example:**
```
Gate 4 (Design 4-Doc): ADR.md missing
Cannot decompose without all 4 docs
```

**Action:** Call question()

```
Decision point: How to proceed?

A. Remediate (user creates ADR.md, retry gate)
B. Accept risk (document caveat, skip gate)
C. Escalate (stop, ask stakeholders)

Recommended: A
```

---

### ✅ Ambiguity Blocks Correctness

**Trigger:** Multiple valid interpretations, correctness depends on which one

**Example:**
```
Request: "Design a new feature"
Ambiguous: Strategic work? Tactical? Exploratory?
Each maps to different coordinator
```

**Action:** Call question()

```
Decision point: What type of work is this?

A. New durable work (route to Altitude Intent)
B. Tactical data engineering (route to Data Engineer)
C. Exploratory spike (research first)
```

---

### ✅ Destructive Operation Proposed

**Trigger:** Change would delete/overwrite/materially alter behavior

**Example:**
```
Proposed: Mark altitude.agent.md as DEPRECATED
Impact: Existing workflows might break
```

**Action:** Call question()

```
Decision point: OK to deprecate altitude.agent.md?

A. Yes, migrate all to altitude-maestro
B. No, keep parallel for 1 more wave
C. Review migration plan first
```

---

### ✅ Scope Expansion Requested

**Trigger:** Task scope grows beyond original allocation

**Example:**
```
Original T-02: Add gate (30 lines)
Request now: Add gate + context loading + traceability (60-80 lines)
```

**Action:** Call question()

```
Decision point: Accept scope expansion?

A. Yes, expand time estimate + complexity (Recommended)
B. No, revert to original 30-line spec
C. Split into T-02a + T-02b
```

---

### ✅ Phase Transition Needs Confirmation

**Trigger:** Advancing from one phase to next

**Example:**
```
Design phase complete, ready for Execution?
```

**Action:** Call question()

```
Decision point: Ready to advance to Execution?

A. Yes (all 4 docs complete, gates pass)
B. No (need more design work)
C. Conditional (yes but with known gap)
```

---

### ✅ GRILL ME Pattern Applies

**Trigger:** Multi-scenario decision where you need user validation

**All** GRILL ME patterns (see altitude-maestro) trigger question()

---

## When to NOT Use question()

### ❌ User Already Specified Preference

**Trigger:** User explicitly said "do X, not Y"

**Example:**
```
User: "I want todowrite at EVERY bloco"
Agent: [Would be wrong to ask again]
```

**Action:** DO NOT call question() — user already decided

---

### ❌ Safe Best-Effort Default Exists

**Trigger:** You can provide a reasonable default

**Example:**
```
User: "Refactor this code"
Two possible approaches
But Approach A is simpler + safer
```

**Action:** DO NOT call question() — provide Approach A with rationale

**Later:** User can override if they want Approach B

---

### ❌ Task is Analysis-Only (Non-Mutating)

**Trigger:** No files will change, just exploration

**Example:**
```
User: "Explain this architecture"
```

**Action:** DO NOT call question() — just explain

If user wants to **act** on explanation → then question() is appropriate

---

### ❌ Confidence > 80% for Low-Risk Choice

**Trigger:** You're confident in choice AND risk is low

**Example:**
```
Confidence: 92% (high)
Risk: Low (can always revert)
Choice: Add line 50 to altitude-plan
```

**Action:** DO NOT call question() — just do it

**Caveat:** If risk is high OR confidence < 80%, ask first

---

### ❌ Question is Preference, Not Correctness

**Trigger:** Multiple options all equally correct

**Example:**
```
Task T-02 could be 30 min or 45 min
Both estimates are reasonable
No single "correct" answer
```

**Action:** DO NOT call question() — pick one + document

**Later:** If user wants different estimate, they can request change

---

## Pre-Call Checklist

Before EVERY call to `question()`:

```yaml
Pre-Call Checklist:
  1. Read .specs/shared/ask-user-policy.md? ✅
  2. Is this a justified use case?
     ✅ State conflict?
     ✅ Gate blocked?
     ✅ Ambiguity blocking correctness?
     ✅ Destructive?
     ✅ Scope expansion?
     ✅ Phase transition?
     ✅ GRILL ME pattern?
  3. Is there NO safe default I could provide? ✅
  4. Did user NOT already specify preference? ✅
  5. Is this correctness-critical, not just preference? ✅
  6. Is confidence NOT > 80% for low-risk choice? ✅

If ALL YES: ✅ OK to call question()
If ANY NO: ❌ DO NOT call question() — provide default or analyze further
```

---

## GRILL ME Pattern (Template)

Every question() should follow this pattern:

```yaml
Decision point: [Title]

Scenario A: [If A true]
  - What happens: [consequence]
  - Question: [key question to ask]
  - Cost: [effort/time]
  - Evidence: [what would prove A is right]

Scenario B: [If B true]
  - What happens: [consequence]
  - Question: [key question to ask]
  - Cost: [effort/time]
  - Evidence: [what would prove B is right]

Scenario C: [If C true]
  - What happens: [consequence]
  - Question: [key question to ask]
  - Cost: [effort/time]
  - Evidence: [what would prove C is right]

VALIDATION: Which scenario is TRUE?
  - Check evidence for A: [specific check]
  - Check evidence for B: [specific check]
  - Check evidence for C: [specific check]

DECISION: Call question() with A/B/C
  Recommended: [A | B | C] because [rationale]
```

**Example (State Conflict):**

```yaml
Decision point: Which change is active?

Scenario A: Trust artifact state (waves-7-17)
  - Happens: Continue current wave, waves-18-23 waits
  - Question: Is waves-7-17 still in progress?
  - Cost: Switch may be delayed
  - Evidence: Check state.md timestamps

Scenario B: Trust current request (waves-18-23)
  - Happens: Switch immediately, waves-7-17 archived
  - Question: Should we switch now or finish waves-7-17?
  - Cost: May interrupt work
  - Evidence: Check if waves-7-17 is truly complete

Scenario C: Reset to earlier phase
  - Happens: Go back, fix root cause, retry
  - Question: Is there an underlying issue?
  - Cost: Additional work
  - Evidence: Check phase history

VALIDATION: 
  - Is waves-7-17 in Execution phase? YES (A supports)
  - Is waves-18-23 explicitly requested NOW? YES (B supports)
  - Is there root cause to fix? NO (C unsupported)
  → A and B both valid, need user decision

DECISION: Call question() with A/B/C
  Recommended: A (finish current wave first) because it's safer
```

---

## Evidence Tracking

Every question() call must be logged:

```yaml
# In evidence/BLOCO-N.md or 04-validation.md

## Question() Calls

| Decision | Gate | Scenario | User Choice | Result |
|----------|------|----------|-------------|--------|
| State conflict (W18-23 active?) | Gate 1 | A/B/C | B | Switched to waves-18-23 |
| Ambiguity (is this new work?) | Gate 2 | A/B/C | A | Routed to Altitude Intent |
| Gate blocked (ADR missing?) | Gate 4 | A/B/C | A | User created ADR, gate passed |
| Scope expansion (T-02 30→80 lines?) | — | A/B/C | A | Expanded time estimate |

**Note:** Each row shows:
- What decision needed
- Which gate/phase
- What scenarios were presented
- Which option user chose
- What happened as result
```

---

## Violations & Corrections

### Violation 1: Called question() without checking policy

**Bad:**
```python
if ambiguous:
  question()  # ❌ Didn't check if truly ambiguous
```

**Good:**
```python
if ambiguous:
  if is_correctness_critical():  # ✅ Checked criteria
    load_ask_user_policy()
    question()
  else:
    provide_default()
```

### Violation 2: Called question() when safe default exists

**Bad:**
```
User: "What should we name this file?"
Agent: Asks user for file name
```

**Good:**
```
User: "What should we name this file?"
Agent: Uses sensible default (auto_generated_TIMESTAMP), logs decision
User: Can request rename if needed
```

### Violation 3: Didn't call question() when should have

**Bad:**
```
Gate blocked (4-doc missing)
Agent: Silently skips gate
User: Surprised later
```

**Good:**
```
Gate blocked (4-doc missing)
Agent: Calls question() with GRILL ME pattern
User: Consciously chooses to remediate or accept risk
```

---

## References

- `.specs/shared/ask-user-policy.md` — Base policy
- `.specs/memory/active-state.md` (Policy 2) — Quick reference
- `agents/altitude-maestro.agent.md` — GRILL ME patterns
- `agents/altitude-plan.agent.md` — Recovery protocol (enforcer)
- `agents/altitude-execution.agent.md` — Recovery protocol (enforcer)
- `agents/altitude-validation.agent.md` — Recovery protocol (enforcer)
- `.specs/memory/WAVES-7-17-LESSONS-LEARNED.md` — W18-23 update (enforcement)

---

