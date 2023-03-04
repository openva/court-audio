#!/usr/bin/env bash

# Make sure that an input filename has been provided
if [ "$1" == '' ]; then
    echo "No filename provided"
    exit 1
fi

# Use a better variable name
MP3="$1"

# Make sure the file exists
if [ ! -f audio/"$MP3" ]; then
    echo "File does not exist"
    exit 1
fi

if [ ! -d "transcripts/" ]; then
    mkdir transcripts
fi

# Save the root filename
FILENAME=${MP3/.mp3/}

# Convert the MP3 to a WAV
ffmpeg -i audio/"$FILENAME".mp3 -ar 16000 audio/"$FILENAME".wav || exit 1

# Generate the transcript
./whisper -m models/ggml-base.en.bin -f audio/"$FILENAME".wav --output-srt --output-file transcripts/"$FILENAME"

# Delete the WAV
rm -f audio/"$FILENAME".wav
