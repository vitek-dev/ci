# Pushover

| Action | What it does |
|---|---|
| `vitek-dev/ci/pushover/deploy/success` | Notifies that the deploy succeeded: `🟢 <name> deployed (<branch>)` |
| `vitek-dev/ci/pushover/deploy/failed` | Notifies, with high priority, that the build or deploy failed: `🔴 <name> deploy FAILED (<branch>)` |

| Input | Default | |
|---|---|---|
| `api-key` | required | Pushover application API token; pass it from a secret |
| `user-key` | required | Pushover user or group key; pass it from a secret |
| `name` | `github.repository` | What was deployed; set it to tell apart projects deployed from one monorepo |

The message names `name`, the branch and the short commit SHA, and links to
the workflow run.

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
