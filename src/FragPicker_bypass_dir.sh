#!/bin/bash

walk_dir () {
	shopt -s nullglob dotglob

	for pathname in "$1"/*; do
		if [ -d "$pathname" ]; then
			walk_dir "$pathname"
		else
			python3 ./FragPicker_bypass.py $pathname 128

		fi
	done
}


walk_dir "/mnt"
