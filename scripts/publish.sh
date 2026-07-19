#!/bin/zsh

set -euo pipefail

source "$(dirname "$0")/config.sh"

eval "$(python3 "$SCRIPT_DIR/extract_episode_items.py" "$METADATA_FILE")"

cd "$ROOT_DIR"

git add data/transcripts data/metadata data/last_episode_id.txt

if git diff --cached --quiet; then
    echo "Nothing to publish."
    exit 0
fi

git commit -m "$TITLE ($PUBLISHED)"

git push
