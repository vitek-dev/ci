# Docker

| Action | What it does |
|---|---|
| `vitek-dev/ci/docker/ghcr-build-push` | Builds an image with Buildx and pushes it to `ghcr.io/<image>:<tag>` |

| Input | Default | |
|---|---|---|
| `image` | `github.repository` | Image name under `ghcr.io`; lowercased, as registries require |
| `tag` | `latest` | Image tag |
| `context` | `.` | Build context directory |
| `file` | `<context>/Dockerfile` | Path to the Dockerfile |

The caller checks out the code, and the job needs `packages: write` permission.
Logging in uses the workflow's `GITHUB_TOKEN` as `github.actor`.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v7
      - uses: vitek-dev/ci/docker/ghcr-build-push@v1
        with:
          image: ${{ github.repository }}-ardea-nuxt
          context: projects/ardea-nuxt
```

See the [root README](../README.md#versioning) for versioning.
