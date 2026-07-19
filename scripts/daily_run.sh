#!/bin/zsh
# Unattended morning run of /daily. Invoked by launchd (see
# ~/Library/LaunchAgents/com.aiapply.dailyscrape.plist) — no one is
# available to answer permission prompts, so everything /daily needs
# (WebSearch, WebFetch, and the exact docx-render Bash command) is
# pre-approved in .claude/settings.json. Anything not on that allow-list
# is denied automatically rather than hanging on a prompt nobody can
# answer — deliberately NOT running with --dangerously-skip-permissions.

set -uo pipefail

REPO_DIR="/Users/minime/Projects/ai_apply"
CLAUDE_BIN="/Users/minime/.local/bin/claude"
LOG_DIR="$REPO_DIR/logs"
LOG_FILE="$LOG_DIR/daily_$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"
cd "$REPO_DIR" || exit 1

{
  echo "=== /daily run started $(date) ==="
  "$CLAUDE_BIN" -p "/daily" \
    --model claude-sonnet-5
  echo "=== /daily run finished $(date) with exit code $? ==="
} >> "$LOG_FILE" 2>&1
