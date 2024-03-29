#!/bin/bash
#$1 is process name

#Parse the system call trace
sed 1d ./trace.result | awk '{print $7, $11, $15, $19, $23}' > ./tmp.txt
mv ./tmp.txt ./trace.result

sort -n -s -k1,1 ./trace.result | awk '/[0-9]/' > ./tmp.txt
mv ./tmp.txt ./trace.result


