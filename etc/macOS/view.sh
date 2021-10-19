#!/bin/bash

path=./results

for frag_size in 4 8 16 32 64 128 256 512 1024 2048 4096
do
	value=$(cat $path/${frag_size}_seqRead.result | awk '{print $3}')
	echo $frag_size $value
done
