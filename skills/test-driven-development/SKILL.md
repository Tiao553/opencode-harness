---
name: test-driven-development
description: Red-green-refactor workflow, test-first implementation, and acceptance-to-unit test breakdown. Use when building or changing behavior that should be verified before implementation.
license: MIT
compatibility: OpenCode
metadata:
  version: 1.0.0
  category: lifecycle
---

# Test-Driven Development

## When to Use

- Use when implementing new behavior, fixing a bug, or locking down an edge case.
- Use when a build agent, language builder, or test specialist needs a test-first loop.
- Do not use for pure documentation or no-code analysis tasks.

## Workflow

1. State the behavior to prove in one sentence.
2. Start from the smallest failing acceptance or unit test that captures that behavior.
3. Run or reason about the failing test first.
4. Implement only enough code to make the test pass.
5. Refactor after green while keeping tests green.
6. Add edge-case coverage only after the happy path is stable.

## Common Rationalizations

| Rationalization | Reality |
| --- | --- |
| "I'll add tests after the implementation settles." | Post-hoc tests often mirror the code instead of verifying the behavior. |
| "This change is too small for TDD." | Small changes are where a fast red-green loop is cheapest and most useful. |
| "One integration test is enough." | Broad tests alone make failures harder to localize. |

## Red Flags

- Implementation starts before any explicit failing test exists.
- Tests assert internals instead of observable behavior.
- Refactor happens before the first green result.
- Edge cases are added without a passing happy path first.

## Verification

- [ ] The target behavior was stated before coding.
- [ ] A failing test existed before the implementation change.
- [ ] The first implementation was the minimum needed for green.
- [ ] Refactor happened only after green.
- [ ] Final tests cover both happy path and important edge cases.
