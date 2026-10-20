# Healthchecks.io

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

See the [root README](../README.md#versioning) for versioning.
