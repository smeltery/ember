# ember

[![CI](https://github.com/smeltery/ember/actions/workflows/ci.yml/badge.svg)](https://github.com/smeltery/ember/actions/workflows/ci.yml)
[![Release](https://github.com/smeltery/ember/actions/workflows/release.yml/badge.svg)](https://github.com/smeltery/ember/actions/workflows/release.yml)
[![License: PolyForm Shield 1.0.0](https://img.shields.io/badge/license-PolyForm%20Shield%201.0.0-blue.svg)](LICENSE)
[![Bun](https://img.shields.io/badge/bun-1.4-black?logo=bun&logoColor=white)](https://bun.sh/)
[![TypeScript](https://img.shields.io/badge/typescript-5+-3178c6?logo=typescript&logoColor=white)](packages/core)
[![Swift](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)](macos)
[![macOS 14+](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)](docs/getting-started.md)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](.pre-commit-config.yaml)
[![Flox](https://img.shields.io/badge/dev%20env-flox-7c3aed.svg)](https://flox.dev)

Open-source keep-awake for macOS that holds sleep only while your AI coding
agents are working — then lets the Mac rest again.

<p align="center">
  <img src="docs/assets/ember-menu.png" alt="ember menu bar: awake while agents work" width="720" />
</p>

## Quick start

```bash
flox activate   # optional
bun install
bun run dev     # marketing site
cd macos && swift build && open .build/debug/Ember   # menu bar app
```

Or download a build from [Releases](https://github.com/smeltery/ember/releases).

## Features

- Agent-driven wake lock (PreventUserIdleSystemSleep via `caffeinate` while mid-task)
- Lifecycle hooks for Claude Code, Codex, OpenCode, Gemini, Pi, Copilot CLI, Hermes
- Process detection for Cursor, Cline, Warp, Aider, Windsurf, Continue, Amp, Goose
- Pause 30 minutes or 1 hour from the menu bar
- Battery cut-off, optional plugged-in-only, Low Power Mode respect
- LOC and flat-directory budget gates in CI / pre-commit

## Docs

Full guides live in [`docs/`](docs/README.md).

## License

[PolyForm Shield 1.0.0](LICENSE)
