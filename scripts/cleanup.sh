#!/bin/zsh

set -euo pipefail

source "$(dirname "$0")/config.sh"

for file in "$AUDIO_FILE" "$METADATA_FILE"; do
    if [[ -e "$file" ]]; then
        rm "$file"
        echo "Removed: $file"
    fi
done
