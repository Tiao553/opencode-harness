---
name: browser-testing-with-devtools
description: Browser-based UI verification, state inspection, and devtools-driven debugging. Use when validating frontend behavior, layout, or client-side errors.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: lifecycle
---

# Browser Testing With Devtools

## When to Use

- Use when validating screens, flows, responsive layout, or frontend regressions.
- Use when a frontend or UX agent needs evidence from the running UI rather than static code only.
- Do not use when the task is backend-only or there is no browser surface involved.

## Workflow

1. Define the user flow and the expected visible outcome.
2. Check the core states in browser context: loading, empty, error, locked, and success when applicable.
3. Inspect network, console, and DOM state only around the failing or validated flow.
4. Confirm the outcome on the target viewport classes that matter, usually desktop and mobile.
5. Record concrete evidence: failing request, console error, missing element, or successful interaction.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "The code looks right, so the UI is probably fine." | Frontend regressions often appear only at runtime. |
| "One viewport is enough." | Responsive issues hide in untested breakpoints. |
| "No console errors means no problem." | A broken UX can exist without runtime exceptions. |

## Red Flags

- No explicit user flow is being validated.
- The check ignores loading/error/empty states.
- Only static code review is used for a runtime UI problem.
- Evidence is vague instead of tied to a concrete DOM, network, or console observation.

## Verification

- [ ] A concrete user flow was defined.
- [ ] Runtime evidence was checked, not just source code.
- [ ] Important UI states were validated.
- [ ] Desktop and mobile behavior were considered where relevant.
- [ ] Findings reference a concrete browser observation.
