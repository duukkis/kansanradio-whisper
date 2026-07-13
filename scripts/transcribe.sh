#!/bin/zsh

set -euo pipefail

source "$(dirname "$0")/config.sh"

if [[ ! -f "$AUDIO_FILE" ]]; then
    echo "Audio file not found: $AUDIO_FILE" >&2
    exit 1
fi

if [[ ! -s "$METADATA_FILE" ]]; then
    echo "Episode metadata is missing: $METADATA_FILE" >&2
    exit 1
fi

eval "$(python3 "$SCRIPT_DIR/extract_episode_items.py" "$METADATA_FILE")"

if [[ ! "$PROGRAM_ID" =~ '^[A-Za-z0-9._-]+$' || ! "$PUBLISHED" =~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' ]]; then
    echo "Invalid episode ID or publication date." >&2
    exit 1
fi

OUTPUT_BASENAME="${PUBLISHED}-${PROGRAM_ID}"
OUTPUT_BASE="$TRANSCRIPT_DIR/$OUTPUT_BASENAME"
TRANSCRIPT_FILE="${OUTPUT_BASE}.srt"
TRANSCRIPT_METADATA_FILE="$TRANSCRIPT_METADATA_DIR/${OUTPUT_BASENAME}.json"
LOCK_DIR="$DATA_DIR/transcribe.lock"

mkdir -p "$TRANSCRIPT_DIR" "$TRANSCRIPT_METADATA_DIR"

release_lock() {
    rm -f -- "$LOCK_DIR/pid"
    rmdir "$LOCK_DIR" 2>/dev/null || true
}

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    LOCK_PID=""
    if [[ -f "$LOCK_DIR/pid" ]]; then
        read -r LOCK_PID < "$LOCK_DIR/pid"
    fi

    if [[ "$LOCK_PID" == <-> ]] && ! kill -0 "$LOCK_PID" 2>/dev/null; then
        echo "Removing stale transcription lock from process $LOCK_PID."
        release_lock
        mkdir "$LOCK_DIR"
    else
        echo "A transcription is already running; skipping this invocation."
        exit 10
    fi
fi

print -r -- "$$" > "$LOCK_DIR/pid"
trap release_lock EXIT

echo "Transcribing $PROGRAM_ID ($PUBLISHED)..."
"$WHISPER" \
    -m "$WHISPER_MODEL" \
    -l fi \
    -f "$AUDIO_FILE" \
    -osrt \
    -of "$OUTPUT_BASE"

if [[ ! -s "$TRANSCRIPT_FILE" ]]; then
    echo "Whisper completed without creating a transcript: $TRANSCRIPT_FILE" >&2
    exit 1
fi

cp "$METADATA_FILE" "$TRANSCRIPT_METADATA_FILE"

echo "Transcript written to: $TRANSCRIPT_FILE"
echo "Metadata written to: $TRANSCRIPT_METADATA_FILE"
