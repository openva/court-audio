#!/usr/bin/env bash

# Delete temporary files on exit
trap 'rm -f "$tmp" "$tmp2"' EXIT

# Rearrange the JSON to use case IDs as keys
tmp=$(mktemp)
jq 'reduce .[] as $item ({}; .[$item.case_id] = $item)' arguments.json > "$tmp"
tmp2=$(mktemp)
jq 'with_entries(.value |= del(.case_id))' "$tmp" > "$tmp2"

# Copy the file
aws s3 cp --no-progress "$tmp2" s3://courtaudio/arguments.json
aws s3 sync --no-progress transcripts/ s3://courtaudio/transcripts/
aws s3 sync --no-progress audio/ s3://courtaudio/audio/ --exclude "*" --include "*.mp3"

# Invalidate the cached JSON
aws cloudfront create-invalidation --distribution-id EM9XCQXYT1OYQ  --paths "/arguments.json"
