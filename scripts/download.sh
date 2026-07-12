#!/bin/zsh

source "$(dirname "$0")/config.sh"

echo "Checking latest Kansanradio episode..."

# Download metadata
"$YLE_DL" \
    "$YLE_URL" \
    --latestepisode \
    --showmetadata \
    > "$METADATA_FILE"

if [ $? -ne 0 ]; then
    echo "Failed to download metadata."
    exit 1
fi

# Read PROGRAM_ID, PUBLISHED and TITLE
eval "$(python3 "$SCRIPT_DIR/extract_episode_items.py" "$METADATA_FILE")"

LAST_ID=""
if [ -f "$DATA_DIR/last_episode_id.txt" ]; then
    LAST_ID=$(cat "$DATA_DIR/last_episode_id.txt")
fi

if [ "$PROGRAM_ID" = "$LAST_ID" ]; then
    echo "Episode already processed."
    exit 10
fi

echo "Downloading new episode..."

"$YLE_DL" \
    "$YLE_URL" \
    --latestepisode \
    -o "$AUDIO_FILE"

if [ $? -ne 0 ]; then
    echo "Download failed."
    exit 1
fi

echo "$PROGRAM_ID" > "$DATA_DIR/last_episode_id.txt"
echo "$PUBLISHED" > "$DATA_DIR/current_episode_date.txt"

echo "Downloaded new episode: $TITLE ($PUBLISHED)"

exit 0