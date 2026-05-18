# Kubernetes Workloads

> **Purpose**: Model applications as desired state with safe rollout, scheduling, and networking defaults.
> **Confidence**: 0.95
> **MCP Validated**: 2026-04-29

## Overview

For stateless workloads, a Deployment manages Pods through ReplicaSets and reconciles actual state to the desired state. Services provide stable networking, while probes and resource requests make rollouts and scheduling predictable.

## The Concept

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: analytics-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: analytics-api
  template:
    metadata:
      labels:
        app.kubernetes.io/name: analytics-api
    spec:
      containers:
        - name: app
          image: ghcr.io/example/analytics-api:1.0.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
```

## Quick Reference

| Input | Output | Notes |
|-------|--------|-------|
| Deployment | ReplicaSets and Pods | Use for stateless apps |
| Service | Stable DNS/VIP | Selects Pods via labels |
| Requests | Scheduler placement | Sum across containers |
| Limits | Runtime enforcement | CPU throttles; memory can OOM kill |

## Common Mistakes

### Wrong

```yaml
spec:
  selector:
    matchLabels:
      app: old-name
  template:
    metadata:
      labels:
        app: new-name
```

### Correct

```yaml
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: analytics-api
  template:
    metadata:
      labels:
        app.kubernetes.io/name: analytics-api
```

## Related

- [Docker Advanced](../concepts/docker-advanced.md)
- [Kubernetes Deployment](../patterns/kubernetes-deployment.md)

## Official Sources

- Kubernetes Docs: Deployments
- Kubernetes Docs: Resource Management for Pods and Containers
- Kubernetes Docs: Services
