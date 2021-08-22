#!/bin/bash
# $1: dev path, $2 mount point, $3 filesystem
umount /dev/$1
if [ "$3" == "ext4" ]; then
	yes | mkfs.$3 /dev/$1 -E lazy_itable_init=0,lazy_journal_init=0
else
	mkfs.$3 /dev/$1 -f
fi

if [ "$3" == "f2fs" ]; then
	mount -t $3 /dev/$1 $2 
	echo 4 > /sys/fs/f2fs/$1/ipu_policy #Disables IPU. We can disable IPU right before migration but we disable here for better readability of source codes.
else
	mount -t $3 /dev/$1 $2
fi
