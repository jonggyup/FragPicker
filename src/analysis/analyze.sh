#!/bin/bash
#$1 is process name

./remove.sh
./trace.sh $1 &
sleep 5
id=$!

sleep 3
kill -INT $id
sleep 5
kill $(pgrep trace)

./parse.sh #parsing the traced info.
python3 ./processing.py #per-file processing
python3 ./merge.py #merging overlapped I/Os
./hotness.sh $2 # hotness filtering
