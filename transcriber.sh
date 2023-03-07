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

    # Generate the transcript differently in macOS and Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ./whisper -m models/ggml-medium.en.bin --output-srt --output-file transcripts/"$filename" audio/"$filename".wav
    else
        whisper audio/"$filename".wav --output_format=srt --output_dir=transcripts --model=small --language=English --fp16=False
    fi
    

    # Delete the WAV
    rm -f audio/"$filename".wav

done
