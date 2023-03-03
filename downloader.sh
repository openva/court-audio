#!/usr/bin/env bash

if [ ! -f arguments.json ]; then
    echo "arguments.json does not exist"
    exit 1
fi

if [ ! -d "audio/" ]; then
    mkdir audio
fi

cd audio/ || exit

# Download every file from arguments.json and save it, using the remote filename
jq '.[].url' ../arguments.json |xargs curl -O -J -S -s -o /dev/null
