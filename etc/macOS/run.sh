#!/bin/bash

mount_point=./

for frag_size in 4 8 16 32 64 128 256 512 1024 2048 4096
do
	let size=$frag_size*1024
	./gen_file f1 f2 f3 $size
	sync & purge
	./read_file f1 > ./results/${frag_size}_seqRead.result
	./filefrag f1 > ./results/${frag_size}_filefrag.result

	./read_file f3 > ./results/ori_seqRead.result
	./filefrag f3 > ./results/ori_filefrag.result

	./read_file f2 > ./results2/${frag_size}_seqRead.result
	./filefrag f2 > ./results2/${frag_size}_filefrag.result


	rm f1 f2 f3

done
