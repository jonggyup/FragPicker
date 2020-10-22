#!/bin/bash
#$1 is process name

percentage=5
division=10

while IFS= read -r line
do
	echo $path
	filename=$(echo $line | awk '{print $1}')
	targefile=$filename.merged
	count=$(wc -l ./$targetfile | awk '{print $1}')
	numLine=$(echo $((count * percentage / division)))
	sort -g -k3,3gr ./$targetfile | head -$numLine | sort -g > ./$filename.sorted
done < ./filelist.txt
