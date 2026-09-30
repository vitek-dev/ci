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

## Versioning

Pin to the major tag `@v1`; it moves forward with backward-compatible changes.
Use `@main` to track the tip.
