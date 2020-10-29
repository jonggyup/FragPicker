#!/bin/bash

walk_dir () {
	shopt -s nullglob dotglob

	for pathname in "$1"/*; do
		if [ -d "$pathname" ]; then
			walk_dir "$pathname"
		else
#			echo "$pathname"
#			python3.8 /home/jonggyu/Research/Benchmarks/HotStorage/defrag.py $pathname 128
			python3.8 ./defrag_all.py $pathname 128

		fi
	done
}


walk_dir "/mnt"
