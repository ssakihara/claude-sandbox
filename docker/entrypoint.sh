#!/bin/bash
set -e

CLAUDE_HOME="/home/node/.claude"
HOST_CONFIG="/tmp/claude-host"

if [ -d "$HOST_CONFIG" ]; then
  mkdir -p "$CLAUDE_HOME"

  # CLAUDE.md
  [ -f "$HOST_CONFIG/CLAUDE.md" ] && cp "$HOST_CONFIG/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

  # ディレクトリ系（agents, rules, references, scripts）
  # ホストの設定を正とし、毎回上書きする
  for dir in agents rules references scripts; do
    if [ -d "$HOST_CONFIG/$dir" ]; then
      rm -rf "$CLAUDE_HOME/$dir"
      cp -r "$HOST_CONFIG/$dir" "$CLAUDE_HOME/$dir"
    fi
  done

  # settings.json: hooks, statusLine, voiceEnabled はDocker非対応のため除外
  if [ -f "$HOST_CONFIG/settings.json" ]; then
    if jq 'del(.hooks) | del(.statusLine) | del(.voiceEnabled)' \
      "$HOST_CONFIG/settings.json" > "$CLAUDE_HOME/settings.json"; then
      chmod 600 "$CLAUDE_HOME/settings.json"
    else
      echo "ERROR: Failed to process settings.json" >&2
      exit 1
    fi
  fi
fi

# .gitconfig をホストから引き継ぎ
for gitconf in .gitconfig .gitconfig_company .gitconfig_private; do
  if [ -f "$HOST_CONFIG/$gitconf" ]; then
    cp "$HOST_CONFIG/$gitconf" "/home/node/$gitconf"
    chmod 600 "/home/node/$gitconf"
  fi
done

exec "$@"
