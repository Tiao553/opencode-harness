# Production Dockerfile

> **Purpose**: Build a cache-efficient, non-root image without leaking build secrets.
> **MCP Validated**: 2026-04-29

## When to Use

- Packaging Python, Node, Go, or JVM services for local and cluster runtime.
- Build dependencies are larger than runtime dependencies.
- CI build speed and image attack surface matter.

## Implementation

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

FROM base AS deps
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip wheel --wheel-dir /wheels -r requirements.txt

FROM base AS runtime
RUN addgroup --system app && adduser --system --ingroup app app
COPY --from=deps /wheels /wheels
RUN pip install --no-cache-dir /wheels/*
COPY src/ ./src/
USER app
EXPOSE 8080
CMD ["python", "-m", "src.app"]
```

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `# syntax` | `docker/dockerfile:1` | Enables current Dockerfile frontend features |
| `USER` | non-root user | Reduces runtime privilege |
| cache mount | package-manager cache path | Speeds rebuilds without copying cache into image |
| image tag | pinned version | Avoids mutable production base images |

## Example Usage

```bash
docker buildx build --load -t analytics-api:dev .
docker run --rm -p 8080:8080 analytics-api:dev
```

## See Also

- [Kubernetes Deployment](../patterns/kubernetes-deployment.md)
- [Docker Advanced](../concepts/docker-advanced.md)
