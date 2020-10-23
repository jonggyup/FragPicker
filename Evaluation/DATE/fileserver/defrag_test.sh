#!/bin/bash
#nvme1n1p1 sdc1 sde1 sdf1
startbase_dir=./defrag_results

for dev in sdf1 #nvme1n1p1 sdb1 sde1 sdf1 #ram0
do
	case $dev in
		nvme1n1p1)
			file=optane.f
			base_dir=$startbase_dir/NVMe
			;;
		nvme0n1p1)
			
			base_dir=$startbase_dir/NVMe2
			;;
		sdb1)
			file=ssd.f
			base_dir=$startbase_dir/SSD
			;;
		sde1)
			file=hdd.f
			base_dir=$startbase_dir/HDD
			;;
		sdf1)
			file=micro.f
			base_dir=$startbase_dir/SDcard
	esac
	mkdir $base_dir


	for filesystem in f2fs btrfs
	do
		result_path=$base_dir/$filesystem
		mkdir $result_path
		umount /mnt
		/home/jonggyu/mount.sh $dev /mnt $filesystem

		/home/jonggyu/Scripts/cacheflush.sh

		filebench -f $file

		/home/jonggyu/Scripts/cacheflush.sh

		du /mnt/ -h | tail >$result_path/size.txt

		(time grep -r "asdf" /mnt/) &> $result_path/ori.result

		/home/jonggyu/Scripts/measure_frag.pl /mnt > $result_path/file.frag

		/home/jonggyu/Scripts/cacheflush.sh

		btrace /dev/$dev -a issue &> $result_path/btrace.btrace &

		./defrag_dir.sh	 /mnt

		kill $(pgrep blktrace)

		/home/jonggyu/Scripts/cacheflush.sh

		(time grep -r "asdf" /mnt/) &> $result_path/after_defrag.result

		/home/jonggyu/Scripts/measure_frag.pl /mnt > $result_path/after_file.frag

		btrace /dev/$dev -a issue &> $result_path/max_btrace.btrace &

		./defrag_dir_all.sh /mnt

		kill $(pgrep blktrace)

		/home/jonggyu/Scripts/cacheflush.sh

		(time grep -r "asdf" /mnt/) &> $result_path/max_after_defrag.result

		/home/jonggyu/Scripts/measure_frag.pl /mnt > $result_path/max_after_file.frag

	done	
done
