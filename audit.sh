#!/usr/bin/env bash

# Create (or zero out) a file listing problematic transcripts
true > problems.txt

# Check every transcript
for file in transcripts/*
do
	# Find which line repeats the most times and return the number of times that it repeats
	repeats=( $(grep -E ".{31,}" "$file" |sort |uniq -c |sort -nr |head -1 |sed 's/\"//g' |sed "s/\'//g" |xargs |cut -d " " -f 1) )

	if [[ $repeats -gt 6 ]]; then
		echo "$file	$repeats duplicate lines"
		echo "$file" >> problems.txt
	fi
done
