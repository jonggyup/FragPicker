#!/bin/bash

(time (cd ./evaluation/motivation && ./read_bench.sh)) 2> ./read_moti_time.result
(time (cd ./evaluation/motivation && ./write_bench.sh)) 2> ./write_moti_time.result

(time (cd ./evaluation/read_benchmark && ./run_benchmark.sh)) 2> ./read_exp_time.result
(time (cd ./evaluation/update_benchmark && ./run_benchmark.sh)) 2> ./update_exp_time.result


