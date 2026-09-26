#!/usr/bin/env bash
# Mark an ember session as working (generic / any agent).
#
# Env:
#   EMBER_AGENT   – agent id (default: generic)
#   EMBER_SESSION – session id (default: $$)
# Args: [agent_id] [session_id]

set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "${ROOT}/lib.sh"

agent="${EMBER_AGENT:-${1:-generic}}"
session="${EMBER_SESSION:-${2:-$$}}"

ember_write_session "$agent" "$session" "working"
