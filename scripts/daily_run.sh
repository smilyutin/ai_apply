#!/bin/zsh
# Unattended morning run of /daily. Invoked by launchd (see
# ~/Library/LaunchAgents/com.aiapply.dailyscrape.plist) — no one is
# available to answer permission prompts, so this runs with prompts
# skipped, scoped to this repo directory only.

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
    --dangerously-skip-permissions \
    --model claude-sonnet-5
  echo "=== /daily run finished $(date) with exit code $? ==="
} >> "$LOG_FILE" 2>&1
