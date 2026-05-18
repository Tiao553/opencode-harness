# Helm Chart

> **Purpose**: Package a Kubernetes Deployment and Service with environment-specific values.
> **MCP Validated**: 2026-04-29

## When to Use

- The same workload must be installed across multiple environments.
- Operators need `helm upgrade`, rollback, and release history.
- Kubernetes YAML needs controlled configuration without duplicating manifests.

## Implementation

```yaml
# Chart.yaml
apiVersion: v2
name: analytics-api
description: Analytics API service
type: application
version: 0.1.0
appVersion: "1.0.0"
```

```yaml
# values.yaml
replicaCount: 2
image:
  repository: ghcr.io/example/analytics-api
  tag: "1.0.0"
  pullPolicy: IfNotPresent
service:
  port: 80
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

```gotemplate
{{/* templates/_helpers.tpl */}}
{{- define "analytics-api.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
```

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `image.tag` | app version | Pin release image |
| `replicaCount` | `2` | Availability baseline |
| `resources` | explicit | Scheduler and runtime guardrails |
| `service.port` | `80` | Stable service port |

## Example Usage

```bash
helm lint charts/analytics-api
helm template analytics-api charts/analytics-api
helm upgrade --install analytics-api charts/analytics-api --namespace analytics --create-namespace
```

## See Also

- [Production Dockerfile](../patterns/production-dockerfile.md)
- [Helm Charts](../concepts/helm-charts.md)
