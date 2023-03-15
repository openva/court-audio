#!/bin/bash

for file in transcripts/*
do
	repeats=( $(grep -E ".{31,}" "$file" |sort |uniq -c |sort -nr |head -1 |sed 's/\"//g' |sed "s/\'//g" |xargs |cut -d " " -f 1) )
	if [[ $repeats -gt 6 ]]; then
		echo "$file	$repeats duplicate lines"
	fi
done
