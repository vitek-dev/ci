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
      - uses: vitek-dev/ci/node/setup@main
      - uses: vitek-dev/ci/node/lint@main
      - uses: vitek-dev/ci/node/format@main
```

`npm run format` should check formatting without writing changes (for example `prettier --check .`).
Otherwise the step passes even when files are badly formatted.
