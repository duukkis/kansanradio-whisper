#!/bin/zsh

set -euo pipefail

metadata_file="${1:-}"
if [[ -z "$metadata_file" || ! -f "$metadata_file" ]]; then
    exit 1
fi

publish_timestamp=$(sed -n 's/.*"publish_timestamp": "\([^"]*\)".*/\1/p' "$metadata_file" | head -n 1)
if [[ -z "$publish_timestamp" ]]; then
    exit 1
fi

publish_timestamp=$(echo "$publish_timestamp" | sed -E 's/([+-][0-9]{2}):([0-9]{2})$/\1\2/')

publish_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$publish_timestamp" +"%s" 2>/dev/null || true)
if [[ -z "$publish_epoch" ]]; then
    exit 1
fi

now_epoch=$(date +"%s")
next_publish_epoch=$((publish_epoch + 604800))

if (( now_epoch < next_publish_epoch )); then
    date -r "$next_publish_epoch" "+%Y-%m-%dT%H:%M:%S%z"
    exit 0
fi

exit 1
