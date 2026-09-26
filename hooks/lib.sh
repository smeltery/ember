#!/usr/bin/env bash
# Shared helpers for ember agent lifecycle hooks.
# Writes session JSON under:
#   ~/Library/Application Support/ember/sessions/<agent>/<session>.json
#
# Expected env (any hook may set these):
#   EMBER_AGENT   – agent id (e.g. claude-code)
#   EMBER_SESSION – session id (stable per conversation)
#   EMBER_STATE   – working | idle
# Optional agent-native fallbacks are documented in each wrapper script.

set -euo pipefail

ember_home="${HOME}/Library/Application Support/ember/sessions"

ember_sanitize() {
  printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '_'
}

ember_iso_now() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

ember_write_session() {
  local agent="${1:?agent id required}"
  local session="${2:?session id required}"
  local state="${3:?state required}"

  case "$(printf '%s' "$state" | tr '[:upper:]' '[:lower:]')" in
    working) state="working" ;;
    idle) state="idle" ;;
    *)
      echo "ember: state must be working or idle (got: $state)" >&2
      return 1
      ;;
  esac

  local dir
  dir="${ember_home}/$(ember_sanitize "$agent")"
  mkdir -p "$dir"
  local file
  file="${dir}/$(ember_sanitize "$session").json"
  cat >"$file" <<EOF
{"state":"${state}","agent":"${agent}","sessionId":"${session}","updatedAt":"$(ember_iso_now)"}
EOF
}
