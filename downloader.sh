#!/usr/bin/env bash

if [ ! -f arguments.json ]; then
    echo "arguments.json does not exist"
    exit 1
fi

if [ ! -d "audio/" ]; then
    mkdir audio
fi

cd audio/ || exit

# Get a list of all unfetched remote files
local_files=( $(find *.mp3 |sed -e 's/\.mp3$//') )
remote_files=( $(jq '.[].case_id' ../arguments.json |sed -e 's/"//g') )
missing_ids=( $(echo "${remote_files[@]}" "${local_files[@]}" | tr ' ' '\n' | sort | uniq -u) )

for case_id in "${missing_ids[@]}"; do
    url=$(jq ".[] | select (.case_id==\"${case_id}\") | .url" ../arguments.json |sed -e 's/"//g')
    curl "$url" --output "$case_id".mp3
done
