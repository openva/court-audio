#!/bin/bash

# Define the source directory containing SRT files
src_dir="transcripts/"

# Define the target directory for HTML files
target_dir="cases/"

# Ensure the target directory exists
mkdir -p "$target_dir"

# Iterate over all SRT files in the source directory
for srt_file in "$src_dir"*.srt; do

  # Check if the file exists and is a regular file
  if [ -f "$srt_file" ]; then

    # Extract the file name without extension
    base_name=$(basename -- "$srt_file")
    file_name_no_ext="${base_name%.*}"

    # Generate the corresponding HTML file path
    html_file="$target_dir$file_name_no_ext.html"

    # Run the Node script to convert SRT to HTML
    node srt2hypertranscript.js "$srt_file" "$html_file"

    echo "Converted $srt_file to $html_file"
  fi
done

echo "All SRT files converted to Hypertranscript HTML"
