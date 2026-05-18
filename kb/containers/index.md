# Containers Knowledge Base

> **Purpose**: Advanced Docker, Docker Compose, Kubernetes, and Helm guidance for container packaging and deployment.
> **MCP Validated**: 2026-04-29

## Quick Navigation

### Concepts (< 150 lines each)

| File | Purpose |
|------|---------|
| [concepts/docker-advanced.md](concepts/docker-advanced.md) | BuildKit, cache, multi-stage images, secrets, and runtime hardening |
| [concepts/kubernetes-workloads.md](concepts/kubernetes-workloads.md) | Deployments, Services, probes, resources, and rollout behavior |
| [concepts/helm-charts.md](concepts/helm-charts.md) | Helm chart structure, values design, templates, and release workflow |

### Patterns (< 200 lines each)

| File | Purpose |
|------|---------|
| [patterns/production-dockerfile.md](patterns/production-dockerfile.md) | Cache-aware, non-root, multi-stage Dockerfile pattern |
| [patterns/kubernetes-deployment.md](patterns/kubernetes-deployment.md) | Production-ready Deployment and Service baseline |
| [patterns/helm-chart.md](patterns/helm-chart.md) | Minimal chart with helpers, values, and workload templates |

### Specs (Machine-Readable)

| File | Purpose |
|------|---------|
| [specs/container-platforms.yaml](specs/container-platforms.yaml) | Validation matrix for Docker, Kubernetes, and Helm artifacts |

---

## Quick Reference

- [quick-reference.md](quick-reference.md) - Fast lookup tables for common decisions

---

## Key Concepts

| Concept | Description |
|---------|-------------|
| **BuildKit-first Docker** | Use multi-stage builds, cache mounts, secret mounts, and small runtime images for repeatable builds. |
| **Docker Compose runtime** | Compose defines local multi-service stacks; validate with `docker compose config` and pin external images. |
| **Kubernetes desired state** | Deployments reconcile Pods through ReplicaSets; Services provide stable networking. |
| **Helm as package boundary** | Charts package Kubernetes manifests and expose environment-specific settings through values. |
| **Registry-backed discovery** | Search Docker Hub for images and Artifact Hub for Helm charts, then record exact source links. |

---

## Learning Path

| Level | Files |
|-------|-------|
| **Beginner** | concepts/kubernetes-workloads.md |
| **Intermediate** | patterns/production-dockerfile.md |
| **Advanced** | patterns/helm-chart.md |

---

## Agent Usage

| Agent | Primary Files | Use Case |
|-------|---------------|----------|
| container-specialist | quick-reference.md, patterns/* | Dockerfiles, Compose files, Kubernetes manifests, Helm charts |

---

## Official Sources

| Source | Scope |
|--------|-------|
| Docker Docs: Dockerfile best practices, BuildKit, build secrets, Compose deploy resources | Docker image and local runtime patterns |
| Docker Hub: search and official images | Image discovery and trust signals |
| Kubernetes Docs: Deployments, resource management, Services | Workload and cluster manifest patterns |
| Helm Docs: chart best practices, values, template functions and pipelines | Chart authoring and templating patterns |
| Artifact Hub: Helm chart search | Chart discovery and package metadata |
