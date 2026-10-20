# ci

Shared GitHub Actions for vitek-dev projects.

| Group | Actions | What they do |
|---|---|---|
| [Node.js](node/README.md) | `node/setup`, `node/lint`, `node/format` | Set up Node.js from `package.json`, install dependencies, lint and check formatting |
| [Docker](docker/README.md) | `docker/ghcr-build-push` | Build an image with Buildx and push it to GHCR |
| [Pushover](pushover/README.md) | `pushover/deploy/success`, `pushover/deploy/failed` | Send deploy success or failure notifications |
| [Healthchecks.io](healthchecks/README.md) | `healthchecks/workflows/start`, `healthchecks/workflows/success`, `healthchecks/workflows/failure` | Report workflow runs to a Healthchecks.io check |

Use each one as `vitek-dev/ci/<action>@v1`. Each group's README covers its
inputs and has an example workflow.

## Versioning

Pin to the major tag `@v1`; it moves forward with backward-compatible changes.
Use `@main` to track the tip.
