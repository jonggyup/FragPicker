#!/bin/bash
path=$( cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)
filesystem=$(findmnt | grep "/mnt" | awk '{print $3}')

walk_dir () {
	shopt -s nullglob dotglob

	for pathname in "$1"/*; do
		if [ -d "$pathname" ]; then
			walk_dir "$pathname"
		else
			if [[ "$filesystem" == "ext4" ]]; then
				(cd $path && python3 ./FragPicker_bypass_IP.py $pathname 128)
			else
				(cd $path && python3 ./FragPicker_bypass_OP.py $pathname 128)
			fi
		fi
	done
}


walk_dir "/mnt" #recursively performs defragmentation.
