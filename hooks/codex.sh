#!/usr/bin/env bash
# ember hook for ChatGPT / Codex CLI.
#
# Env:
#   EMBER_AGENT / EMBER_SESSION / EMBER_STATE – overrides
#   CODEX_SESSION_ID / OPENAI_SESSION_ID – session fallback
# Args: [working|idle] [session_id]
#
# Wire into Codex session start / end hooks.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "${ROOT}/lib.sh"

agent="${EMBER_AGENT:-chatgpt-codex}"
session="${EMBER_SESSION:-${CODEX_SESSION_ID:-${OPENAI_SESSION_ID:-${2:-default}}}}"
state="${EMBER_STATE:-${1:-working}}"

ember_write_session "$agent" "$session" "$state"
