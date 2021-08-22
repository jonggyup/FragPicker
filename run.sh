#!/bin/bash

(time (cd ./evaluation/motivation && ./read_bench.sh)) 2> ./read_moti.time
(time (cd ./evaluation/motivation && ./read_bench_backup.sh)) 2> ./read_moti_bakcup.time
(time (cd ./evaluation/motivation && ./write_bench.sh)) 2> ./write_moti.time
(time (cd ./evaluation/motivation && ./write_bench_backup.sh)) 2> ./write_moti_backup.time

(time (cd ./evaluation/read_benchmark && ./run_benchmark.sh)) 2> ./read_exp.time
(time (cd ./evaluation/read_benchmark && ./run_benchmark_backup.sh)) 2> ./read_exp_backup.time
(time (cd ./evaluation/write_benchmark && ./run_benchmark.sh)) 2> ./write_exp.time
(time (cd ./evaluation/write_benchmark && ./run_benchmark_backup.sh)) 2> ./write_exp_backup.time


