#!/bin/bash

array=(ori.result after_defrag.result max_after_defrag.result btrace.btrace max_btrace.btrace)
#trim_time.result


printf "%8s" $1 "    "
for i in "${array[@]}"
do
	tmp=$(echo $i | cut -d. -f 1)
	printf "%10s" "$tmp     "
done
printf "\n"

#printf "%-15s " "ori"
#printf "%-8.7s%7s" "$value" "  |  " 
#printf "\n"


frag_size=4
req_size=128
for filesystem in f2fs btrfs
do

	base_dir=./defrag_results/$1/$filesystem
	#			tmp=${distance}KB
	tmp=${frag_size}KB
	printf "%-15s " "$filesystem"


	for i in "${array[@]}"
	do
		#var1=$(echo $i | cut -d. -f1 | cut -d_ -f2)
		var1=$(echo $i | cut -d.  -f2)
		if [ "$var1" == "btrace" ]; then
			file=$(echo $i | cut -d. -f 1)
			value=$(cat $base_dir/$i | tail -9 | head -1 | awk '{print $8}')
		else
			file=$(echo $i | cut -d. -f 1)
			#echo $tmp1
			value=$(cat $base_dir/$i |head -2 | tail -1 | awk '{print $2}') # | cut -dm -f2)

		fi
		printf "%-8.7s%7s" "$value" "  |  "

	done

	printf "\n"
done
