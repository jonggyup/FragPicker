#!/bin/bash
#The target mount point will be /mnt.
#If one want to chagne this, please replace it with what you want.

startbase_dir=./results #The results will be stored here.
ra_size=128 #Default read-ahead size.

#dev is the device name (/dev/sdx or /dev/nvmex)
for dev in nvme1n1p1 sde1 sdb1 sdf1
do
	case $dev in
		nvme1n1p1)
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
	esac
	
	#$base_dir will contain the performance results of each device.
	mkdir $base_dir -p

	result_path=$base_dir/ori
	mkdir $result_path
	umount /mnt
	#The motivational experiment is performed with F2FS since we can easily manipule the layous as we want, due to its log-sturcturing feature.
	./mount.sh $dev /mnt f2fs
	
	#Generates non-fragmented file, named ori.
	dd if=/dev/zero of=/mnt/ori count=1 bs=${size}M oflag=direct,append conv=notrunc &> /dev/null
	/home/jonggyu/Scripts/cacheflush.sh
	

	./write_seq /mnt/ori $ra_size > $result_path/write_perf_${ra_size}_0.result


	fstrim /mnt

	rm /mnt/ori

	(perf stat fstrim /mnt) &> $result_path/trim_time_0.result

	result_path=$base_dir/write_exp
	mkdir $result_path
	for frag_unit in 4 8 16 32 64 128 256 512 1024 2048 4096 #8096 16192
	do
		for distance in 1024 #4 #8 16 32 64 128 256 512 1024 2048 4096
		do
			let counts=$size*1024/$frag_unit
			umount /mnt
			/home/jonggyu/mount.sh $dev /mnt f2fs

			touch /mnt/1
			touch /mnt/dummy


#				dd if=/dev/zero of=/mnt/dummy count=1 bs=64K oflag=direct,append conv=notrunc &> /dev/null
			while (( --counts >= 0 )); do
				dd if=/dev/zero of=/mnt/1 count=1 bs=${frag_unit}K oflag=direct,append conv=notrunc &> /dev/null
				dd if=/dev/zero of=/mnt/dummy count=1 bs=${distance}K oflag=direct,append conv=notrunc &> /dev/null
			done

			ls -alh /mnt/ > $result_path/ls.result

			hdparm --fibmap /mnt/1 > $result_path/frag.frag
			hdparm --fibmap /mnt/dummy > $result_path/dummy.frag

			/home/jonggyu/Scripts/cacheflush.sh

			for ra_size in 128 #4 8 16 32 64 128 256 512 1024 
			do

				/home/jonggyu/Scripts/cacheflush.sh

				./write_seq /mnt/1 $ra_size > $result_path/write_perf_${frag_unit}_${distance}.result

			done

#			fstrim /mnt

#			rm /mnt/1

#			(perf stat fstrim /mnt) &> $result_path/trim_time_${distance}.result
		done
	done
done
