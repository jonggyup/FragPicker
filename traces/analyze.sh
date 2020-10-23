#!/bin/bash
#$1 is process name

#script -c "./trace.sh iozone" ./trace.result 2>&1 &

#/usr/share/bcc/tools/trace 'vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) "ino = %llu | size = %llu | pos = %u", file->f_inode->i_ino, count, *pos' -n iozone &> ./trace.result 2>&1 &
./remove.sh
./trace.sh grep &
sleep 5
#sh -c './trace.sh iozone | tee trace.result' &
id=$!
#run benchmark here
#iozone -i 5 -r 128k -j 4 -f /mnt/2 -w -I -s 100m -+n
grep -r "asdf" /mnt/2
#fio --directory=/mnt --name fio_test_file --direct=1 --rw=randread --bs=128k --size=1G --numjobs=1 --time_based --runtime=30 --group_reporting --norandommap 

kill -INT $id
sleep 5
kill $(pgrep trace)

./parse.sh

python3 ./processing.py
python3 ./merge.py
