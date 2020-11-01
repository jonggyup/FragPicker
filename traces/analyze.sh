#!/bin/bash
#$1 is process name

#script -c "./trace.sh iozone" ./trace.result 2>&1 &

#/usr/share/bcc/tools/trace 'vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos) "ino = %llu | size = %llu | pos = %u", file->f_inode->i_ino, count, *pos' -n iozone &> ./trace.result 2>&1 &
./remove.sh
./trace.sh java &
sleep 5
#sh -c './trace.sh iozone | tee trace.result' &
id=$!
#run benchmark here
#iozone -i 1 -r 128k -f /mnt/2 -w -I -s 10m -+n
#iozone -i 5 -r 128k -j 4 -f /mnt/2 -w -I -s 100m -+n
#grep -r "asdf" /mnt/2
#fio --directory=/mnt --name fio_test_file --direct=1 --rw=randread --bs=128k --size=1G --numjobs=1 --time_based --runtime=30 --group_reporting --norandommap 

#YCSB benchmark
#path=/home/jonggyu/Research/ATC2021/Evaluation/ATC/YCSB
#(cd $path && ./bin/ycsb run rocksdb -s -P workloads/workloadc -p rocksdb.dir=/mnt/ycsb-rocksdb-data) &> /dev/null
#(cd $path && ./bin/ycsb run mongodb -s -P workloads/workloadc)

#Running $1 benchmark
$1 $2
#MongoDB
#path=/home/jonggyu/Research/ATC2021/Evaluation/mongodb
#(cd $path && ./replay.sh)

sleep 100
kill -INT $id
sleep 5
kill $(pgrep trace)

./parse.sh

python3 ./processing.py
python3 ./merge.py
