#!/usr/bin/env bash
# Build macOS release artifacts into dist-release/.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
version="${RELEASE_TAG#v}"
mkdir -p dist-release
(
  cd macos
  swift build -c release --product Ember
)
bin="$(find macos/.build -type f -name Ember -perm -111 | head -1)"
test -n "$bin"
test -f "$bin"
cp "$bin" "dist-release/ember-macos-arm64"
(
  cd apps/web
  bun run build
)
tar -C apps/web/dist -czf "dist-release/ember-web-${version}.tar.gz" .
(
  cd dist-release
  shasum -a 256 ember-macos-arm64 "ember-web-${version}.tar.gz" > SHA256SUMS
)
ls -la dist-release
