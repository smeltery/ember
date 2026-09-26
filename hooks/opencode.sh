#!/usr/bin/env bash
# ember hook for OpenCode.
#
# Env:
#   EMBER_AGENT / EMBER_SESSION / EMBER_STATE – overrides
#   OPENCODE_SESSION_ID – session fallback
# Args: [working|idle] [session_id]
#
# Point OpenCode lifecycle hooks at this script.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "${ROOT}/lib.sh"

agent="${EMBER_AGENT:-opencode}"
session="${EMBER_SESSION:-${OPENCODE_SESSION_ID:-${2:-default}}}"
state="${EMBER_STATE:-${1:-working}}"

ember_write_session "$agent" "$session" "$state"
