#!/bin/zsh

YLE_URL="https://areena.yle.fi/audio/1-2143312"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="$ROOT_DIR/scripts"

DATA_DIR="$ROOT_DIR/data"
AUDIO_FILE="$DATA_DIR/episode.mp3"
METADATA_FILE="$DATA_DIR/latest.json"
TRANSCRIPT_DIR="$DATA_DIR/transcripts"
TRANSCRIPT_METADATA_DIR="$DATA_DIR/metadata"
LOG_DIR="$DATA_DIR/logs"

WHISPER_MODEL="$ROOT_DIR/models/ggml-large-v3-turbo-fi-q5_0.bin"

YLE_DL="$HOME/Library/Python/3.9/bin/yle-dl"
WHISPER="/opt/homebrew/bin/whisper-cli"

LAST_EPISODE_FILE="$DATA_DIR/last_episode_id.txt"
