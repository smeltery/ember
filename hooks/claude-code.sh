#!/usr/bin/env bash
# ember hook for Claude Code.
#
# Env:
#   EMBER_AGENT / EMBER_SESSION / EMBER_STATE – overrides
#   CLAUDE_SESSION_ID – session fallback
#   CLAUDE_HOOK_EVENT – SessionStart|Stop|SubagentStart|… (maps to working/idle)
# Args: [working|idle] [session_id]
#
# Install as a Claude Code lifecycle hook pointing at this script.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "${ROOT}/lib.sh"

agent="${EMBER_AGENT:-claude-code}"
session="${EMBER_SESSION:-${CLAUDE_SESSION_ID:-${2:-default}}}"
state="${EMBER_STATE:-${1:-}}"

if [[ -z "$state" ]]; then
  event="$(printf '%s' "${CLAUDE_HOOK_EVENT:-}" | tr '[:upper:]' '[:lower:]')"
  case "$event" in
    *stop*|*end*|*idle*|*complete*) state="idle" ;;
    *) state="working" ;;
  esac
fi

ember_write_session "$agent" "$session" "$state"
