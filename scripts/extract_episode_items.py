#!/usr/bin/env python3

import json
import shlex
import sys

if len(sys.argv) != 2:
    print("Usage: extract_episode_items.py <metadata.json>", file=sys.stderr)
    sys.exit(1)

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

if not data:
    print("Metadata file contains no episodes.", file=sys.stderr)
    sys.exit(1)

episode = data[0]

program_id = episode["program_id"]
published = episode["publish_timestamp"][:10]
title = episode["episode_title"]

print(f"PROGRAM_ID={shlex.quote(program_id)}")
print(f"PUBLISHED={shlex.quote(published)}")
print(f"TITLE={shlex.quote(title)}")