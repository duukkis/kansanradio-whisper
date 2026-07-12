#!/usr/bin/env python3

import json
import os
import sys
from datetime import datetime, timezone


def main() -> None:
    if len(sys.argv) != 7:
        print(
            "Usage: write_transcript_metadata.py "
            "<source-metadata.json> <program-id> <output.json> "
            "<model-path> <audio-path> <transcript-path>",
            file=sys.stderr,
        )
        sys.exit(1)

    source_path, program_id, output_path, model_path, audio_path, transcript_path = (
        sys.argv[1:]
    )

    with open(source_path, encoding="utf-8") as source:
        episodes = json.load(source)

    episode = next(
        (item for item in episodes if item.get("program_id") == program_id), None
    )
    if episode is None:
        print(
            f"Episode {program_id} was not found in {source_path}", file=sys.stderr
        )
        sys.exit(1)

    metadata = {
        "program_id": episode["program_id"],
        "title": episode.get("episode_title"),
        "description": episode.get("description"),
        "published_at": episode.get("publish_timestamp"),
        "source_url": episode.get("webpage"),
        "duration_seconds": episode.get("duration_seconds"),
        "transcription": {
            "engine": "whisper-cli",
            "model": os.path.basename(model_path),
            "language": "fi",
            "audio_file": os.path.basename(audio_path),
            "transcript_file": os.path.basename(transcript_path),
            "created_at": datetime.now(timezone.utc)
            .isoformat()
            .replace("+00:00", "Z"),
        },
    }

    with open(output_path, "w", encoding="utf-8") as output:
        json.dump(metadata, output, ensure_ascii=False, indent=2)
        output.write("\n")


if __name__ == "__main__":
    main()
