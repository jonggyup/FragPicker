#!/bin/bash

array=(read_perf)
#trim_time.result


printf "%-15s" "SSD    "
for i in "${array[@]}"
do
	tmp=$(echo $i | cut -d. -f 1)
	printf "%-6s%2s  " "$tmp"
done
printf "\n"


printf "%-15s " "ori"
var1=$(echo $i | cut -d. -f2)
if [ "$var1" == "frag" ]; then	
	value=$(wc -l $base_dir/$i | awk '{print $1}')
else
	tmp1=$(echo $i | cut -d. -f 1)
	#echo $tmp1
	value=$(cat ./results_tmp/$1/ori/read_perf_128_0.result | awk '{print $3}')

fi
printf "%-8.7s%7s" "$value" "  |  " 
printf "\n"


for frag_size in 4 8 16 32 64 128 256 512 1024 2048 4096 #8096 16192
do
	for req_size in 128 #4 8 16 32 64 128 256 512 1024
	do
		for distance in 8 #8 12 16 20 #8 16 32 64 128 256 512 1024 2048 4096
		do
			
			base_dir=./results_tmp/$1
			#			tmp=${distance}KB
			tmp=${frag_size}KB
			printf "%-15s " "$tmp"


			for i in "${array[@]}"
			do
				var1=$(echo $i | cut -d. -f2)
				if [ "$var1" == "frag" ]; then	
					value=$(wc -l $base_dir/$i | awk '{print $1}')
				else
					tmp1=$(echo $i | cut -d. -f 1)
					#echo $tmp1
					value=$(cat $base_dir/${i}_${frag_size}_${2}_$3.result | awk '{print $3}')

				fi
				printf "%-8.7s%7s" "$value" "  |  "

			done

			printf "\n"
		done
	done
done
