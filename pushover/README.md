# Pushover

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

See the [root README](../README.md#versioning) for versioning.
