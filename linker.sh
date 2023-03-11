#!/usr/bin/env bash

# Ensure that the JSON exists
if [ ! -f "arguments.json" ]; then
    echo "arguments.json not found"
    exit 1
fi

# Get a list of every case ID that has no transcript
cases=( $(jq '.[] | select(has("transcript") | not) | .case_id' arguments.json | sed -e 's/"//g') )

# Get a list of all transcript files
transcripts=( $(ls transcripts/*.srt | xargs -n 1 basename | sed -e 's/\.srt$//') )

# Iterate through a list of all cases without transcripts
for case in "${cases[@]}"; do
    
    # See if we have a transcript for that case
    for transcript in "${transcripts[@]}"; do
        
        if [ "$transcript" == "$case" ]; then
            # Update this stanza to include the URL for the transcript
            tmp=$(mktemp)
            jq "map(if .case_id == \"$case\" then . + {\"transcript\": \"/transcripts/$case.srt\"} else . end)" arguments.json > "$tmp" && mv "$tmp" arguments.json
            echo "Added $case transcript URL to arguments.json"
            break
        fi

    done

done


