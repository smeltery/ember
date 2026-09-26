# Development

Local setup for the TypeScript core, Vite site, hooks, and macOS Swift package.

## Flox

Activate the project environment from the repo root:

```bash
flox activate
```

The `.flox` env pins bun, pre-commit, actionlint, shellcheck, gh, and related
tools so local checks match CI.

## Bun workspace

```bash
bun install --frozen-lockfile
bun run ci
```

- Core logic: `packages/core`
- Marketing site: `apps/web` (`bun run dev`)

## pre-commit (mirrors CI)

```bash
pre-commit install
# or: git config core.hooksPath .githooks
```

Hooks run the same entrypoints as CI:

| Hook / script | CI job |
| --- | --- |
| `scripts/check-docs.sh` | docs (markdown + mermaid + links) |
| `scripts/check-hygiene.sh` | loc budget, shellcheck, actionlint |
| `scripts/check-node.sh` | tests + web build |
| `.githooks/pre-push` | all of the above (+ Swift smoke when available) |

## Swift (macOS)

```bash
cd macos
swift build --product EmberCore
swift run EmberCoreSmoke
swift build --product Ember
swift test   # needs full Xcode
```

## Hooks

```bash
chmod +x hooks/*.sh
./hooks/generic-working.sh demo local-1
```

## Related

- [CI](ci.md)
- [Releasing](releasing.md)
