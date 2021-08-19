#!/bin/bash
# $1: dev path, $2 mount point, $3 filesystem
umount /dev/$1
if [ "$3" == "ext4" ]; then
	yes | mkfs.$3 /dev/$1 -E lazy_itable_init=0,lazy_journal_init=0
else
	mkfs.$3 /dev/$1 -f
fi

if [ "$3" == "btrfs" ]; then
	mount -t $3 /dev/$1 $2 
else
	mount -t $3 /dev/$1 $2
fi
echo 4 > /sys/fs/f2fs/$1/ipu_policy
