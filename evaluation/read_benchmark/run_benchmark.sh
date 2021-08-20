#!/bin/bash
#nvme1n1p1 sdc1 sde1 sdf1
base_startbase_dir=./results
ra_size=128
path=../../src

for workloads in read_seq read_stride
do
	case $workloads in
		read_seq)
			startbase_dir=$base_startbase_dir/sequential
			mkdir $startbase_dir -p
			command="./read_seq"
			;;
		read_stride)
			startbase_dir=$base_startbase_dir/stride
			mkdir $startbase_dir -p
			command="./read_stride"
			;;
	esac
	#Similar to the motivational experiments, needs to change the device name and the path to the corresponding ones
	for dev in sdb1 #nvme1n1p1 #sdb1 #sde1 sdf1 #sdg1
	do
		case $dev in
			nvme1n1p1)
				size=1024 #in MB
				base_dir=$startbase_dir/Optane
				;;
			sdb1)
				size=400
				base_dir=$startbase_dir/SSD
				;;
			sde1)
				size=100
				base_dir=$startbase_dir/HDD
				;;
			sdf1)
				size=50
				base_dir=$startbase_dir/MicroSD
				;;
		esac
		mkdir $base_dir

		for filesystem in ext4 f2fs btrfs
		do
			result_path=$base_dir/$filesystem
			mkdir $result_path
			frag_unit=4
			distance=4
			let counts=$size*1024/256
			umount /mnt
			../tools/mount.sh $dev /mnt/ $filesystem #mount point is /mnt

			touch /mnt/1 #for baseline and FragPicker with bypass
			touch /mnt/2 #for FragPicker
			touch /mnt/3 #for conventional tools
			touch /mnt/4 #for btrfs with optimization (target) conv-T

			#This performs 32 4k writes and 128 writes to each file
			while (( --counts >= 0 )); do
				while (( --sub_counts >= 0 )); do
					dd if=/dev/zero of=/mnt/1 count=1 bs=${frag_unit}K oflag=direct,append conv=notrunc &> /dev/null
					dd if=/dev/zero of=/mnt/2 count=1 bs=${frag_unit}K oflag=direct,append conv=notrunc &> /dev/null
					dd if=/dev/zero of=/mnt/3 count=1 bs=${frag_unit}K oflag=direct,append conv=notrunc &> /dev/null
					dd if=/dev/zero of=/mnt/4 count=1 bs=${frag_unit}K oflag=direct,append conv=notrunc &> /dev/null

				done
				dd if=/dev/zero of=/mnt/1 count=1 bs=128K oflag=direct,append conv=notrunc &> /dev/null
				dd if=/dev/zero of=/mnt/2 count=1 bs=128K oflag=direct,append conv=notrunc &> /dev/null
				dd if=/dev/zero of=/mnt/3 count=1 bs=128K oflag=direct,append conv=notrunc &> /dev/null
				dd if=/dev/zero of=/mnt/4 count=1 bs=128K oflag=direct,append conv=notrunc &> /dev/null
				let sub_counts=32
			done
			#########

			ls -alh /mnt/ > $result_path/ls.result #To check the size of files

			#With ext4, additional fragmentor needed
			if [[ "$filesystem" == "ext4" ]]; then
				python3 ../tools/fragmentor_ext4.py /mnt/1
				python3 ../tools/fragmentor_ext4.py /mnt/2
				python3 ../tools/fragmentor_ext4.py /mnt/3
			fi

			../tools/cacheflush.sh

			#Fragmentation info. before defrag.
			filefrag -v /mnt/1 > $result_path/frag_before1.frag
			filefrag -v /mnt/2 > $result_path/frag_before2.frag
			filefrag -v /mnt/3 > $result_path/frag_before3.frag
			filefrag -v /mnt/4 > $result_path/frag_before3.frag

			../tools/cacheflush.sh

			#Measure the performance
			$command /mnt/1 $ra_size > $result_path/perf_before.result

			#Begin the experiments with FragPicker_bypass
			#measure the write amount in the block layer
			btrace /dev/$dev -a issue &> $result_path/fragpicker_bypass_btrace.trace &

			#Perform FragPicker with the bypass option
			(cd $path/migration && ./FragPicker_bypass.sh /mnt/1 128)
			sleep 10
			kill $(pgrep blktrace)

			filefrag -v /mnt/1 > $result_path/fragpicker_bypass_frag_after.frag
			../tools/cacheflush.sh
			sleep 4
			$command /mnt/1 $ra_size > $result_path/fragpicker_bypass_perf_after.result

			#begin the experiments with FragPicker
			#Analysis phase begins
			(cd $path/analysis && ./trace.sh $workloads &) #System call monitoring
			trace_id=$!
			sleep 5

			#Workloads
			$command /mnt/2 $ra_size > /dev/null

#			sleep 5
#			kill -INT $trace_id
			sleep 10
			kill $(pgrep trace)
			(cd $path/analysis && ./parse.sh) #Parsing monitored I/Os
			(cd $path/analysis && python3 ./processing.py) #per-file Analysis
			(cd $path/analysis && python3 ./merge.py) #merging overlapped I/os
			(cd $path/analysis && ./hotness.sh 100) #hotness filetering. Here, Hotness is 100%
			#Analysis completed.

			#measure the write amount in the block layer
			btrace /dev/$dev -a issue &> $result_path/fragpicker_btrace.trace &

			(cd $path/migration && ./FragPicker.sh)
			
			sleep 10
			kill $(pgrep blktrace)

			filefrag -v /mnt/2 > $result_path/fragpicker_frag_after.frag

			../tools/cacheflush.sh
			sleep 4

			#measure the performance
			$command /mnt/2 $ra_size > $result_path/fragpicker_perf_after.result


			#begin the experiments with conventional tools 
			btrace /dev/$dev -a issue &> $result_path/conv_btrace.trace &

			case $filesystem in
				ext4)
					e4defrag /mnt/3
					;;
				f2fs)
					(cd $path/migration && python3 ./migrate_all.py /mnt/3 1024) #F2FS doesn't have user-friendly defragmenter. So, we just migrate the entire contents into a new area, similarly to other defragmenters
					;;
				btrfs)
					btrfs filesystem defragment -f /mnt/3
					;;
			esac

			sleep 10
			kill $(pgrep blktrace)

			filefrag -v /mnt/3 > $result_path/conv_frag_after.frag
			../tools/cacheflush.sh
			sleep 4

			#measure the performance
			$command /mnt/3 $ra_size > $result_path/conv_perf_after.result


			#In the case of btrfs, performs one more with the optimization
			if [[ "$filesystem" == "btrfs" ]]; then
				btrace /dev/$dev -a issue &> $result_path/conv_t_btrace.trace &
				btrfs filesystem defragment -t 128K -f /mnt/4
				sleep 10
				kill $(pgrep blktrace)

				filefrag -v /mnt/4 > $result_path/conv_t_frag_after.frag
				../tools/cacheflush.sh
				sleep 4

				$command /mnt/4 $ra_size > $result_path/conv_t_perf_after.result
			fi
		done
	done
done	
