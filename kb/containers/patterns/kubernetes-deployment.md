# Kubernetes Deployment

> **Purpose**: Deploy a stateless container with stable labels, probes, resources, and a Service.
> **MCP Validated**: 2026-04-29

## When to Use

- Deploying a stateless HTTP service to Kubernetes.
- You need rolling updates and rollback history.
- The workload needs stable in-cluster DNS through a Service.

## Implementation

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: analytics-api
  labels:
    app.kubernetes.io/name: analytics-api
spec:
  replicas: 2
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 25%
      maxSurge: 25%
  selector:
    matchLabels:
      app.kubernetes.io/name: analytics-api
  template:
    metadata:
      labels:
        app.kubernetes.io/name: analytics-api
    spec:
      securityContext:
        runAsNonRoot: true
      containers:
        - name: app
          image: ghcr.io/example/analytics-api:1.0.0
          ports:
            - name: http
              containerPort: 8080
          readinessProbe:
            httpGet:
              path: /healthz
              port: http
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: analytics-api
spec:
  selector:
    app.kubernetes.io/name: analytics-api
  ports:
    - name: http
      port: 80
      targetPort: http
```

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `revisionHistoryLimit` | `5` | Keeps rollback history without unbounded ReplicaSets |
| `maxUnavailable` | `25%` | Default-compatible rolling update safety |
| `requests` | workload-specific | Guides scheduler placement |
| `limits` | workload-specific | Enforces upper runtime use |

## Example Usage

```bash
kubectl apply --dry-run=client -f k8s/
kubectl apply -f k8s/
kubectl rollout status deployment/analytics-api
```

## See Also

- [Helm Chart](../patterns/helm-chart.md)
- [Kubernetes Workloads](../concepts/kubernetes-workloads.md)
