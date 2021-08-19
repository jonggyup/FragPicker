#!/bin/bash
workload=${1}_exp
req_size=128

printf "%-15s" "Value    "
printf "%-6s%2s  " $workload
printf "\n"
distance=1024

for frag_size in 4 8 16 32 64 128 256 512 1024 2048 4096
do
	base_dir=./results/${2}/$workload
	#			tmp=${distance}KB
	tmp=${frag_size}KB
	printf "%-15s " "$tmp"


	tmp1=$(echo $i | cut -d. -f 1)
	#echo $tmp1
	value=$(cat $base_dir/${frag_size}_${distance}.result | awk '{print $3}')
	printf "%-8.7s%7s" "$value" "  |  "


	printf "\n"
done
