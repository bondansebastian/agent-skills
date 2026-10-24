#!/usr/bin/env bash
# Checks a Coolify MCP token WITHOUT printing it.
# Usage: check-mcp-token.sh https://<coolify-host>/mcp   (or set COOLIFY_MCP_URL)
# The token is read from $COOLIFY_MCP_TOKEN, or loaded from ~/.config/coolify-mcp/env when unset.
# Only the HTTP status and the server name/version are printed.
set -u
URL="${1:-${COOLIFY_MCP_URL:-}}"
[ -n "$URL" ] || { echo "Usage: $0 https://<coolify-host>/mcp"; exit 2; }
case "$URL" in https://*) ;; *) echo "Refusing to send a token over a non-https URL: $URL"; exit 2;; esac

ENV_FILE="$HOME/.config/coolify-mcp/env"
if [ -z "${COOLIFY_MCP_TOKEN:-}" ] && [ -r "$ENV_FILE" ]; then . "$ENV_FILE"; fi
T="${COOLIFY_MCP_TOKEN:-}"
[ -n "$T" ] || { echo "COOLIFY_MCP_TOKEN is empty: edit $ENV_FILE and paste the token between the single quotes."; exit 2; }
case "$T" in *[[:space:]]*) echo "WARNING: token contains whitespace/newline (Claude Code will warn about it). Remove it.";; esac
case "$T" in *"|"*) ;; *) echo "NOTE: Coolify tokens normally look like '<id>|<secret>'; this one has no '|'.";; esac

# The header goes through a stdin curl config so the token never appears in the process list.
out=$(printf 'header = "Authorization: Bearer %s"\n' "$T" | curl -sS -m 20 -K - -X POST "$URL" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"check","version":"0"}}}' \
  -w '\n__HTTP__%{http_code}') || { echo "curl failed"; exit 3; }
code=${out##*__HTTP__}
echo "HTTP $code"
case "$code" in
  200) echo "OK: token accepted. $(printf '%s' "$out" | grep -o '"serverInfo":{[^}]*}' | head -1)";;
  401) echo "401: token rejected (wrong or expired token, or not a Coolify API token).";;
  403) echo "403: MCP is disabled for this token's team (enable it in the Coolify team settings).";;
  404) echo "404: MCP is disabled on the Coolify instance (enable it in the instance settings).";;
  *)   echo "Unexpected status; first 200 characters of the body:"; printf '%s' "${out%__HTTP__*}" | head -c 200; echo;;
esac
