# Helm Charts

> **Purpose**: Package Kubernetes resources into reusable, versioned releases with environment-specific values.
> **Confidence**: 0.95
> **MCP Validated**: 2026-04-29

## Overview

Helm charts bundle Kubernetes manifests, values, and helper templates so the same workload can be rendered consistently across environments. Good charts keep values readable, quote string injections, and centralize naming and labels in helpers.

## The Concept

```text
charts/analytics-api/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml
    └── service.yaml
```

## Quick Reference

| Input | Output | Notes |
|-------|--------|-------|
| `values.yaml` | Static chart defaults | Keep user-facing configuration here |
| `_helpers.tpl` | Reusable template names | Use for labels and full names |
| `helm template` | Rendered YAML | Review before install/upgrade |
| `helm lint` | Chart validation | Run in CI |

## Common Mistakes

### Wrong

```yaml
image:
  tag: latest
env:
  API_KEY: real-secret-value
```

### Correct

```yaml
image:
  tag: "1.0.0"
envFromSecret: analytics-api-secret
```

## Related

- [Kubernetes Workloads](../concepts/kubernetes-workloads.md)
- [Helm Chart](../patterns/helm-chart.md)

## Official Sources

- Helm Docs: Chart Best Practices
- Helm Docs: Values
- Helm Docs: Template Functions and Pipelines
