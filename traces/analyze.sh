#!/bin/bash
#$1 is process name

./trace.sh &

#run benchmark here

kill $!

python3 ./processing.py
python3 ./mergy.py

