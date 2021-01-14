#!/bin/bash
#$1 is process name

percentage=10 #$1
division=10

while IFS= read -r line
do
	filename=$(echo $line | awk '{print $1}')
	targetfile=${filename}.merged
	count=$(wc -l ./${targetfile} | awk '{print $1}')
	numLine=$(echo $((count * percentage / division)))
	sort -g -k3,3gr ./$targetfile | head -$numLine | sort -g > ./$filename.sorted
done < ./filelist.txt
