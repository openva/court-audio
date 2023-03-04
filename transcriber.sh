#!/usr/bin/env bash

if [ ! -d "transcripts/" ]; then
    mkdir transcripts
fi

# Get a list of all untranscribed files
audio_files=( $(find audio/ -name "*.mp3" -exec basename {} .mp3 \;) )
transcript_files=( $(find transcripts/ -name "*.srt" -exec basename {} .srt \;) )
untranscribed_files=( $(echo "${audio_files[@]}" "${transcript_files[@]}" | tr ' ' '\n' | sort | uniq -u) )

for filename in "${untranscribed_files[@]}"; do

    # Convert the MP3 to a WAV
    ffmpeg -y -i audio/"$filename".mp3 -ar 16000 audio/"$filename".wav || exit 1

    # Generate the transcript
    ./whisper -m models/ggml-base.en.bin -f audio/"$filename".wav --output-srt --output-file transcripts/"$filename"

    # Delete the WAV
    rm -f audio/"$filename".wav

done
