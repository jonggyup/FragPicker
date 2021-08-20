#!/bin/bash
#$1 is the type of workload $2 device

array=(perf_before.result fragpicker_bypass_perf_after.result fragpicker_perf_after.result conv_perf_after.result fragpicker_bypass_btrace.trace fragpicker_btrace.trace conv_btrace.trace)
naming=(baseline_perf FragPicker-B_perf FragPicker_perf Conv_perf FragPicker-B_write FragPicker_write Conv_write Conv-T_perf Conv-T_write)
printf "%8s" $1 "    "
for i in "${naming[@]}"
do
	tmp=$(echo $i | cut -d. -f 1)
	printf "%10s" "$tmp     "
done
printf "\n"


frag_size=4
req_size=128
for filesystem in ext4 f2fs btrfs
do

	base_dir=./results/$1/$2/$filesystem
	printf "%-20s " "$filesystem"

	for i in "${array[@]}"
	do
		var1=$(echo $i | cut -d.  -f2)
		if [ "$var1" == "trace" ]; then
			file=$(echo $i | cut -d. -f 1)
			value=$(cat $base_dir/$file.trace | tail -14 | grep "Write Dispatches" | awk '{print $8}')
		else
			file=$(echo $i | cut -d. -f 1)
			value=$(cat $base_dir/$file.result | awk '{print $3}')

		fi
		printf "%-12.7s%7s" "$value" "  |  "

	done
	if [[ "$filesystem" == "btrfs" ]]; then
		for i in conv_t_perf_after.result conv_t_btrace.trace
		do
			var1=$(echo $i | cut -d.  -f2)
			if [ "$var1" == "trace" ]; then
				file=$(echo $i | cut -d. -f 1)
				value=$(cat $base_dir/$file.trace | tail -14 | grep "Write Dispatches" | awk '{print $8}')
			else
				file=$(echo $i | cut -d. -f 1)
				value=$(cat $base_dir/$file.result | awk '{print $3}')

			fi
			printf "%-8.7s%7s" "$value" "  |  "

		done

	fi

	printf "\n"
done
