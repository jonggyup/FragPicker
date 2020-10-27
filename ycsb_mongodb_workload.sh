#!/bin/bash

path1=/home/jonggyu/Research/ATC2021/Evaluation/ATC/YCSB
path2=/home/jonggyu/Research/ATC2021/Evaluation/mongodb

(cd $path2 && ./mongodb-ycsb_setup.sh)
(cd $path1 && ./bin/ycsb load mongodb -s -P workloads/workloadc)

(cd $path2 && ./record.sh &)
pid=$!

(cd $path1 && ./bin/ycsb run mongodb -s -P workloads/workloadc)

kill -INT $pid

/home/jonggyu/Scripts/cache_flush.sh
(cd $path2 && ./replay.sh)

