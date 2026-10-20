# ci

Shared GitHub Actions for vitek-dev projects.

## Node.js

| Action | What it does |
|---|---|
| `vitek-dev/ci/node/setup` | Sets up Node.js using the version from `package.json` (with npm cache) and runs `npm ci` |
| `vitek-dev/ci/node/lint` | Runs `npm run lint` |
| `vitek-dev/ci/node/format` | Runs `npm run format` |

These are composite actions: they run inside the caller's job, so the caller
chooses the runner and checks out the code. Run `node/setup` before `lint` or
`format`.

`node/setup` reads the Node.js version from `package.json`: `volta.node`,
then `devEngines.runtime` (entry named `node`), then `engines.node`. One of these must be set.

```yaml
jobs:
  qa:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: vitek-dev/ci/node/setup@v1
      - uses: vitek-dev/ci/node/lint@v1
      - uses: vitek-dev/ci/node/format@v1
```

`npm run format` should check formatting without writing changes (for example `prettier --check .`).
Otherwise the step passes even when files are badly formatted.

### Subdirectories (monorepos)

Each action takes an optional `working-directory` input (default `.`) — the
directory holding `package.json`. Point it at a project living in a
subdirectory; `node/setup` resolves the Node version, npm cache and `npm ci`
there, and `lint`/`format` run their scripts there too.

```yaml
jobs:
  qa:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: vitek-dev/ci/node/setup@v1
        with:
          working-directory: projects/app
      - uses: vitek-dev/ci/node/lint@v1
        with:
          working-directory: projects/app
      - uses: vitek-dev/ci/node/format@v1
        with:
          working-directory: projects/app
```

## Docker

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

## Pushover

| Action | What it does |
|---|---|
| `vitek-dev/ci/pushover/send` | Sends a push notification through the [Pushover API](https://pushover.net/api) |

| Input | Default | |
|---|---|---|
| `token` | — | Application API token (required; pass a secret) |
| `user` | — | User or group key (required; pass a secret) |
| `message` | — | Notification body (required) |
| `title` | `github.repository` | Notification title |
| `url` | link to the workflow run | Link attached to the notification |
| `url-title` | | Text shown for the link |
| `priority` | | `-2` (lowest) to `1` (high); empty uses Pushover's default `0` |
| `sound` | | Pushover sound name |
| `device` | | Send to this device only |

```yaml
      - uses: vitek-dev/ci/pushover/send@v1
        if: failure()
        with:
          token: ${{ secrets.PUSHOVER_TOKEN }}
          user: ${{ secrets.PUSHOVER_USER }}
          message: Nightly build failed
          priority: 1
```

## Healthchecks.io

| Action | What it does |
|---|---|
| `vitek-dev/ci/healthchecks/start` | Pings `<url>/start`, so Healthchecks.io measures how long the run takes |
| `vitek-dev/ci/healthchecks/stop` | Pings success or `/fail` depending on the job status |
| `vitek-dev/ci/healthchecks/success` | Pings `<url>` (success) |
| `vitek-dev/ci/healthchecks/fail` | Pings `<url>/fail` |

Each takes `url`, the check's ping URL such as `https://hc-ping.com/<uuid>`
(a self-hosted instance works too); store it as a secret. Every ping sends the
workflow run link as its body, so it shows up in the check's event log. A ping
that fails (for example an unknown check) fails the step.

`stop` reports success only when the job status is `success`; `failure` and
`cancelled` are reported as failures. It reads `job.status` unless you pass a
`status` input. Run it with `if: always()` so it also runs after a failed step.

```yaml
jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - uses: vitek-dev/ci/healthchecks/start@v1
        with:
          url: ${{ secrets.HEALTHCHECK_URL }}
      - run: ./backup.sh
      - uses: vitek-dev/ci/healthchecks/stop@v1
        if: always()
        with:
          url: ${{ secrets.HEALTHCHECK_URL }}
```

Use `success` and `fail` instead of `stop` to report each outcome yourself,
e.g. `fail` with `if: failure()`.

## Versioning

Pin to the major tag `@v1`; it moves forward with backward-compatible changes.
Use `@main` to track the tip.
