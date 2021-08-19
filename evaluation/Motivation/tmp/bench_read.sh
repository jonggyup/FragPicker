#!/bin/bash
#nvme1n1p1 sdc1 sde1 sdf1
startbase_dir=./results_tmp

for dev in nvme1n1p1 nvme0n1p1 sdb1 sde1 sdf1 #ram0
do
	case $dev in
		nvme1n1p1)
			size=100
			base_dir=$startbase_dir/Optane
			;;
		nvme0n1p1)
			size=100
			base_dir=$startbase_dir/NVMe
			;;
		sdb1)
			size=50
			base_dir=$startbase_dir/SSD
			;;
		sde1)
			size=10
			base_dir=$startbase_dir/HDD
			;;
		sdf1)
			size=10
			base_dir=$startbase_dir/SDcard
			;;
		ram0)
			size=100
			base_dir=$startbase_dir/RamDisk
	esac
	mkdir $base_dir -p

	result_path=$base_dir
	mkdir $result_path
: <<'END'
	umount /mnt
	/home/jonggyu/mount.sh $dev /mnt f2fs

	dd if=/dev/zero of=/mnt/ori count=1 bs=${size}M oflag=direct,append conv=notrunc &> /dev/null
	for ra_size in 16384 8192 #4 8 16 32 64 128 256 512 1024 2048 4096
	do
			/home/jonggyu/Scripts/cacheflush.sh
			./read_file /mnt/ori $ra_size > $result_path/read_perf_0_0_${ra_size}.result
	done
END
	for frag_unit in 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384
	do
		for distance in 4 8 16 32 64 128 256 512 1024 2048 4096
		do
			let counts=$size*1024/$frag_unit
			umount /mnt
			/home/jonggyu/mount.sh $dev /mnt f2fs

			touch /mnt/1
			touch /mnt/dummy

			while (( --counts >= 0 )); do
				dd if=/dev/zero of=/mnt/1 count=1 bs=${frag_unit}K oflag=direct,append conv=notrunc &> /dev/null
				dd if=/dev/zero of=/mnt/dummy count=1 bs=${distance}K oflag=direct,append conv=notrunc &> /dev/null
			done

			ls -alh /mnt/ > $result_path/ls.result

			hdparm --fibmap /mnt/1 > $result_path/frag.frag
			hdparm --fibmap /mnt/dummy > $result_path/dummy.frag

			/home/jonggyu/Scripts/cacheflush.sh

			for ra_size in 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384
			do

				/home/jonggyu/Scripts/cacheflush.sh

				./read_file /mnt/1 $ra_size > $result_path/read_perf_${frag_unit}_${distance}_${ra_size}.result

			done
		done
	done
done
