# Runtime Policy

## Purpose

Define the minimum runtime posture for Harness V3.

## Rule

Runtime-critical behavior must be one of:

- enforced by a loaded runtime/plugin/tool
- explicitly advisory
- intentionally removed

No policy may be described as runtime-critical when it is only documented and not enforced.

## Required Runtime Checks

| Surface | Required posture |
| --- | --- |
| permissions | enforced or documented as unavailable |
| specs state | blocks unsafe phase/action transitions or remains advisory |
| RTK | active and measurable or removed/advisory |
| Headroom | active and measurable or removed/advisory |
| security gates | enforced for secrets/auth/admin/high-risk operations |

## Failure Mode

If enforcement cannot be proven, the agent must say so and use the manual policy path instead of claiming runtime enforcement.

