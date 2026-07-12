#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

zsh ./download.sh
STATUS=$?

case $STATUS in
    0)
        zsh ./transcribe.sh
        STATUS=$?
        case $STATUS in
            0)
                zsh ./publish.sh || exit 1
                zsh ./cleanup.sh || exit 1
                ;;
            10)
                echo "Transcription is already running."
                ;;
            *)
                echo "Transcription failed (exit code $STATUS)."
                exit 1
                ;;
        esac
        ;;
    10)
        echo "No new episode."
        ;;
    *)
        echo "Download failed (exit code $STATUS)."
        exit 1
        ;;
esac
