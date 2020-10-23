#!/bin/bash
#$1 is process name

sed 1d ./trace.result | awk '{print $7, $11, $15, $19}' > ./tmp.txt
mv ./tmp.txt ./trace.result

sort -n -s -k1,1 ./trace.result > ./tmp.txt
mv ./tmp.txt ./trace.result


