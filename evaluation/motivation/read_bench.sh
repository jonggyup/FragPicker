#!/bin/bash

startbase_dir=./results #The results will be stored here.
req_size=128 #Default read-ahead size.

#The target mount point will be /mnt.
#If you want to change this, please replace "/mnt" with what you want.
mount_point=/mnt

#dev is the device name (/dev/sdx or /dev/nvmex)
#Insert the correct device name here and in each device entry below
for dev in nvme1n1p1 sde1 sdb1 sdf1
do
	case $dev in
		nvme1n1p1) #Optane SSD
			size=100  #file size in MB
			base_dir=$startbase_dir/Optane
			;;
		sdb1) #SATA Flash SSD
			size=50
			base_dir=$startbase_dir/SSD
			;;
		sde1) #HDD
			size=10
			base_dir=$startbase_dir/HDD
			;;
		sdf1) #MicroSD or USB
			size=10
			base_dir=$startbase_dir/MicroSD
			;;
	esac

	#$base_dir will contain the performance results of each device.
	mkdir $base_dir -p
	
	#$base_dir/read_exp contains the sequential read peformance
	result_path=$base_dir/read_exp
	mkdir $result_path

	#performs operations while vayring frag_size.
	for frag_size in 4 8 16 32 64 128 256 512 1024 2048 4096
	do
		for frag_distance in 1024
		do
			let counts=$size*1024/$frag_size
			umount $mount_point
			#The motivational experiment is performed with F2FS since we can easily manipulate the layout as we want, due to its log-sturcturing feature.
			../tools/mount.sh $dev $mount_point f2fs

			touch $mount_point/target_file
			touch $mount_point/dummy
			
			#This generates a fragmented file (target_file).
			while (( --counts >= 0 )); do
				dd if=/dev/zero of=$mount_point/target_file count=1 bs=${frag_size}K oflag=direct,append conv=notrunc &> /dev/null
				dd if=/dev/zero of=$mount_point/dummy count=1 bs=${frag_distance}K oflag=direct,append conv=notrunc &> /dev/null
			done

			#Store fragmentaiton information of the target file.
			#hdparm --fibmap $mount_point/target_file > $result_path/file_frag_${frag_size}_${frag_distance}.result
			
			../tools/cacheflush.sh
			#Performs sequential reads with O_DIRECT and measure the throughput.
			val=$(./read_seq /mnt/target_file $req_size | awk '{print $3}')
			printf "Throughput = %f\n" $val > $result_path/${frag_size}_${frag_distance}.result
		done
	done

	#performs operations while vayring frag_distance.
	for frag_size in 4
	do
		for frag_distance in 4 8 16 32 64 128 256 512 1024 2048 4096
		do
			let counts=$size*1024/$frag_size
			umount $mount_point
			#The motivational experiment is performed with F2FS since we can easily manipulate the layout as we want, due to its log-sturcturing feature.
			../tools/mount.sh $dev $mount_point f2fs

			touch $mount_point/target_file
			touch $mount_point/dummy
			
			#This generates a fragmented file (target_file).
			while (( --counts >= 0 )); do
				dd if=/dev/zero of=$mount_point/target_file count=1 bs=${frag_size}K oflag=direct,append conv=notrunc &> /dev/null
				dd if=/dev/zero of=$mount_point/dummy count=1 bs=${frag_distance}K oflag=direct,append conv=notrunc &> /dev/null
			done

			#Store fragmentaiton information of the target file.
			#hdparm --fibmap $mount_point/target_file > $result_path/file_frag_${frag_size}_${frag_distance}.result
			
			../tools/cacheflush.sh
			#Performs sequential reads with O_DIRECT and measure the throughput.
			val=$(./read_seq /mnt/target_file $req_size | awk '{print $3}')
			printf "Throughput = %f\n" $val > $result_path/${frag_size}_${frag_distance}.result

		done
	done
done
