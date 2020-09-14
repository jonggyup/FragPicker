#!/bin/bash
#nvme1n1p1 sdc1 sde1 sdf1
startbase_dir=./defrag_results
ra_size=128

for dev in nvme1n1p1 sdb1 sde1 sdf1 #ram0
do
	case $dev in
		nvme1n1p1)
			size=1024
			base_dir=$startbase_dir/NVMe
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
			base_dir=$startbase_dir/SDcard
			;;
		ram0)
			size=100
			base_dir=$startbase_dir/RamDisk
	esac
	mkdir $base_dir


	for filesystem in f2fs btrfs
	do
		result_path=$base_dir/$filesystem
		mkdir $result_path
		result_path=$base_dir/$filesystem/ori
		mkdir $result_path
		umount /mnt

		for frag_unit in 4
		do
			for distance in 4
			do
				let counts=$size*1024/256
				umount /mnt
				/home/jonggyu/mount.sh $dev /mnt/ $filesystem
				result_path=$base_dir/$filesystem/$frag_unit
				mkdir $result_path

				touch /mnt/dummy
				touch /mnt/2
				touch /mnt/1

				dd if=/dev/zero of=/mnt/ori count=1 bs=${size}M oflag=direct,append conv=notrunc &> /dev/null
				/home/jonggyu/Scripts/cacheflush.sh

				./read_file /mnt/ori $ra_size > $result_path/read_ori.result


				while (( --counts >= 0 )); do
					while (( --sub_counts >= 0 )); do
						dd if=/dev/zero of=/mnt/2 count=1 bs=${frag_unit}K oflag=direct,append conv=notrunc &> /dev/null
						dd if=/dev/zero of=/mnt/dummy count=1 bs=${distance}K oflag=direct,append conv=notrunc &> /dev/null
						dd if=/dev/zero of=/mnt/1 count=1 bs=${frag_unit}K oflag=direct,append conv=notrunc &> /dev/null
					done
					dd if=/dev/zero of=/mnt/2 count=1 bs=128K oflag=direct,append conv=notrunc &> /dev/null
					dd if=/dev/zero of=/mnt/1 count=1 bs=128K oflag=direct,append conv=notrunc &> /dev/null
					dd if=/dev/zero of=/mnt/dummy count=1 bs=${distance}K oflag=direct,append conv=notrunc &> /dev/null
					let sub_counts=32
				done

				ls -alh /mnt/ > $result_path/ls.result

				filefrag -v /mnt/1 > $result_path/frag_before.frag
				filefrag -v /mnt/2 > $result_path/max_frag_before.frag
				filefrag -v /mnt/dummy > $result_path/dummy.frag

				/home/jonggyu/Scripts/cacheflush.sh

				./read_file /mnt/1 $ra_size > $result_path/read_before.result

				btrace /dev/$dev -a issue &> $result_path/btrace.trace &
				python3.8 ./defrag.py /mnt/1 128
				kill $(pgrep blktrace)
				filefrag -v /mnt/1 > $result_path/frag_after.frag
				/home/jonggyu/Scripts/cacheflush.sh
				./read_file /mnt/1 $ra_size > $result_path/read_after.result

				btrace /dev/$dev -a issue &> $result_path/max_btrace.trace &
				python3.8 ./defrag.py /mnt/2 256
				kill $(pgrep blktrace)
				filefrag -v /mnt/2 > $result_path/max_frag_after.frag
				/home/jonggyu/Scripts/cacheflush.sh
				./read_file /mnt/2 $ra_size > $result_path/max_read_after.result

			done
		done
	done	
done
