# Docker Advanced

> **Purpose**: Build small, secure, reproducible images with BuildKit-aware Dockerfiles.
> **Confidence**: 0.95
> **MCP Validated**: 2026-04-29

## Overview

Advanced Docker work is mostly about reducing build context, controlling cache invalidation, keeping secrets out of images, and producing minimal runtime layers. BuildKit is the default builder for Docker Desktop and Docker Engine Linux containers and enables cache mounts, secret mounts, and better parallel build execution.

## The Concept

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /app

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/
USER app

CMD ["python", "-m", "src.app"]
```

## Quick Reference

| Input | Output | Notes |
|-------|--------|-------|
| `COPY . .` before install | Slow rebuilds | Copy lockfiles first, source later |
| `ARG TOKEN` for private packages | Secret leak risk | Use BuildKit `--secret` |
| `FROM ubuntu:latest` | Non-reproducible image | Pin runtime version or digest |

## Common Mistakes

### Wrong

```dockerfile
FROM python:latest
WORKDIR /app
ARG PIP_TOKEN
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

### Correct

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN --mount=type=secret,id=pip_token \
    --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
COPY src/ ./src/
USER 10001:10001
CMD ["python", "-m", "src.app"]
```

## Related

- [Kubernetes Workloads](../concepts/kubernetes-workloads.md)
- [Production Dockerfile](../patterns/production-dockerfile.md)

## Official Sources

- Docker Docs: Dockerfile best practices
- Docker Docs: BuildKit
- Docker Docs: Build secrets
