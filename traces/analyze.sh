#!/bin/bash
#$1 is process name

#script -c "./trace.sh iozone" ./trace.result 2>&1 &

#/usr/share/bcc/tools/trace 'vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) "ino = %llu | size = %llu | pos = %u", file->f_inode->i_ino, count, *pos' -n iozone &> ./trace.result 2>&1 &

./trace.sh iozone &
sleep 5
#sh -c './trace.sh iozone | tee trace.result' &
id=$!
#run benchmark here
iozone -i 1 -r 128k -f /mnt/1 -w -I -s 100m -+n >/dev/null


kill -INT $id
sleep 5
kill $(pgrep trace)

./parse.sh

python3 ./processing.py
python3 ./merge.py
