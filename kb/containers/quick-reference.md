# Containers Quick Reference

> Fast lookup tables. For code examples, see linked files.
> **MCP Validated**: 2026-04-29

## Artifact Ownership

| Artifact | Use For | Validate With |
|----------|---------|---------------|
| `Dockerfile` | Build one image reproducibly | `docker buildx build --load .` |
| `.dockerignore` | Keep build context small and stable | `docker buildx build --progress=plain .` |
| `docker-compose.yml` / `compose.yaml` | Local multi-service runtime | `docker compose config` |
| `k8s/*.yaml` | Cluster-native workload definitions | `kubectl apply --dry-run=client -f k8s/` |
| `charts/*` | Versioned Kubernetes package | `helm lint` + `helm template` |

## Docker Advanced Defaults

| Concern | Default | Why |
|---------|---------|-----|
| Build backend | BuildKit / `buildx` | Better cache model, parallel build graph, secret mounts |
| Image shape | Multi-stage | Keep compilers and build dependencies out of runtime |
| Build cache | Lockfiles before source | Avoid invalidating dependency layers on app-only changes |
| Secrets | `RUN --mount=type=secret` | Build args and env can persist in image metadata/layers |
| Runtime user | Non-root UID/GID | Reduces impact of container breakout or app compromise |

## Docker Compose Defaults

| Concern | Default | Notes |
|---------|---------|-------|
| File name | `compose.yaml` or `docker-compose.yml` | Support existing project convention |
| Images | Pinned tags | Check Docker Hub or vendor registry before choosing |
| Config check | `docker compose config` | Render and validate merged Compose config |
| Secrets | `.env.example` placeholders or external secrets | Do not commit real credentials |
| Resources | `deploy.resources` when target supports it | Document local Docker behavior and limits |

## Kubernetes Defaults

| Concern | Default | Notes |
|---------|---------|-------|
| Stateless app | Deployment | Manages Pods via ReplicaSets and rolling updates |
| Networking | Service | Stable virtual IP/DNS over changing Pods |
| Health | Readiness + liveness probes | Readiness gates traffic; liveness restarts stuck containers |
| Resources | Requests and limits | Requests affect scheduling; limits are enforced by kubelet/runtime |
| Secrets | Secret reference | Do not commit literal secret values |

## Helm Defaults

| Concern | Default | Notes |
|---------|---------|-------|
| Values naming | lower camelCase | Matches Helm best practices for user-defined values |
| String injection | `{{ .Values.x | quote }}` | Avoid YAML type surprises |
| Defaults | `values.yaml` | Use `default` in templates only for computed fallback values |
| Names | `_helpers.tpl` | Centralize full name, chart name, and labels |
| Validation | `helm lint`, `helm template` | Render before install or upgrade |

## Registry Search Links

| Need | Link | Required Action |
|------|------|-----------------|
| Find container images | https://hub.docker.com/search?q= | Open search or repository page before selecting image |
| Browse Docker Official Images | https://hub.docker.com/u/library | Prefer official images when suitable |
| Docker Hub search docs | https://docs.docker.com/docker-hub/image-library/search/ | Use filters for trusted content, publisher, architecture |
| Docker CLI image search | https://docs.docker.com/reference/cli/docker/search/ | Use `docker search <term>` only as a first pass |
| Find Helm charts | https://artifacthub.io/packages/search?kind=0 | Open chart page before selecting chart |
| Helm hub search command | https://helm.sh/docs/helm/helm_search_hub/ | Use `helm search hub <term>` and verify result in Artifact Hub |

## Decision Matrix

| Use Case | Choose |
|----------|--------|
| Local developer stack with databases and tools | Docker Compose |
| Single service image packaging | Dockerfile + `.dockerignore` |
| Cluster deployment without packaging needs | Kubernetes YAML |
| Repeatable install/upgrade across environments | Helm chart |
| Secrets needed during build | BuildKit secret mount |
| Secrets needed at runtime in cluster | Kubernetes Secret reference |
| Need an existing image | Search Docker Hub, then pin the chosen tag |
| Need an existing Helm chart | Search Artifact Hub, then pin chart version/app version |

## Common Pitfalls

| Don't | Do |
|-------|-----|
| Use `latest` tags for deployed workloads | Pin image tags or digests |
| Put credentials in Dockerfile, Compose, or `values.yaml` | Use secret references or external secret injection |
| Omit resource requests in Kubernetes | Set realistic CPU/memory requests and limits |
| Change Deployment selectors casually | Treat selectors as stable identity |
| Over-template Helm charts | Keep values explicit and templates readable |
| Choose images/charts from memory | Open Docker Hub or Artifact Hub and record the selected URL |

## Related Documentation

| Topic | Path |
|-------|------|
| Docker Advanced | `concepts/docker-advanced.md` |
| Kubernetes Workloads | `concepts/kubernetes-workloads.md` |
| Helm Charts | `concepts/helm-charts.md` |
| Full Index | `index.md` |
