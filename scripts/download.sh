#!/bin/zsh

source "$(dirname "$0")/config.sh"

# Local weekly publication guard: if the latest known episode was published
# less than a week ago, avoid calling YLE DL again before the next episode
# is expected to appear.
if [ -f "$METADATA_FILE" ]; then
    NEXT_PUBLISH_AT=$(zsh "$SCRIPT_DIR/check_next_publish.sh" "$METADATA_FILE" 2>/dev/null || true)

    if [ -n "$NEXT_PUBLISH_AT" ]; then
        echo "No new episode yet. Next expected publish time: $NEXT_PUBLISH_AT"
        exit 10
    fi
fi

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
if [ -f "$LAST_EPISODE_FILE" ]; then
    LAST_ID=$(cat "$LAST_EPISODE_FILE")
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

echo "$PROGRAM_ID" > "$LAST_EPISODE_FILE"

echo "Downloaded new episode: $TITLE ($PUBLISHED)"

exit 0
