# Production Code Mode Policy

## Purpose

Define simple-first production code posture for Harness V3.

## Rule

Start with correct, maintainable, production-safe code. Escalate complexity only when justified.

## Required Posture

- small surface area
- readable names
- explicit error handling where relevant
- secure defaults
- minimal abstraction
- tests or verification path
- no speculative frameworking
- no hidden state mutation

## Complexity Justification

Extra abstraction or infrastructure must be justified by at least one:

- scale
- reliability
- safety
- maintainability
- performance
- integration constraint

