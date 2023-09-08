#!/usr/bin/env bash

# If it's macOS
if [[ "$OSTYPE" == "darwin"* ]]; then

    # Install Whisper, if need be
    if [ ! -f "whisper" ]; then

        # Download Whisper
        curl --output whisper.zip https://codeload.github.com/openai/whisper/zip/refs/heads/main
        unzip whisper.zip
        mv whisper-main whisper
        rm -f whisper.zip
        cd whisper || exit 1
        
        # Download a base model
        ./models/download-ggml-model.sh medium.en

        # Compile
        make || exit 1

        # Move binaries and libraries
        mkdir ../court-audio/models/
        cp main ../court-audio/whisper
        cp models/ggml-medium.en.bin ../court-audio/models/

        rm -Rf whisper/

    fi

    # Install dependencies
    brew install ffmpeg jq

# If it's Linux
else
    # Make sure the basic packages are installed
    sudo apt install -f python3-pip jq ffmpeg node

    # Download Whisper
    pip install -U openai-whisper

fi
