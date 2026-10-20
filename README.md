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
| `vitek-dev/ci/pushover/deploy/success` | Notifies that the deploy succeeded: `🟢 <repo> deployed (<branch>)` |
| `vitek-dev/ci/pushover/deploy/failed` | Notifies, with high priority, that the build or deploy failed: `🔴 <repo> deploy FAILED (<branch>)` |

Each takes `api-key` (the Pushover application API token) and `user-key` (the
user or group key); pass both from secrets. The message names the repository,
branch and short commit SHA, and links to the workflow run.

A failed notification fails the step; add `continue-on-error: true` if it
should not fail the job.

```yaml
jobs:
  notify-failure:
    needs: [ci, build-image, deploy]
    if: failure()
    runs-on: ubuntu-latest
    steps:
      - uses: vitek-dev/ci/pushover/deploy/failed@v1
        continue-on-error: true
        with:
          api-key: ${{ secrets.PUSHOVER_API }}
          user-key: ${{ secrets.PUSHOVER_USER }}
```

## Healthchecks.io

| Action | What it does |
|---|---|
| `vitek-dev/ci/healthchecks/workflows/start` | Pings `<url>/start`, so Healthchecks.io measures how long the run takes |
| `vitek-dev/ci/healthchecks/workflows/success` | Pings `<url>` (success) |
| `vitek-dev/ci/healthchecks/workflows/failure` | Pings `<url>/fail` |

Each takes `url`, the check's ping URL such as `https://hc-ping.com/<uuid>`
(a self-hosted instance, or a slug URL with `?create=1`, works too); store it
as a secret. Every ping sends the workflow run link as its body, so it shows
up in the check's event log. A ping that fails (for example an unknown check)
fails the step.

Each ping appends `?rid=` with the workflow run ID, so Healthchecks.io pairs
the start and finish pings of the same run even when runs overlap. Healthchecks
requires a UUID there, so the run ID is zero-padded into one: run `18765432101`
becomes `00000000-0000-0000-0000-018765432101`.

Run `failure` with `if: failure()` so it reports a failed step; `success` runs
only when every earlier step passed.

```yaml
jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - uses: vitek-dev/ci/healthchecks/workflows/start@v1
        with:
          url: ${{ secrets.HEALTHCHECK_URL }}
      - run: ./backup.sh
      - uses: vitek-dev/ci/healthchecks/workflows/success@v1
        with:
          url: ${{ secrets.HEALTHCHECK_URL }}
      - uses: vitek-dev/ci/healthchecks/workflows/failure@v1
        if: failure()
        with:
          url: ${{ secrets.HEALTHCHECK_URL }}
```

## Versioning

Pin to the major tag `@v1`; it moves forward with backward-compatible changes.
Use `@main` to track the tip.
