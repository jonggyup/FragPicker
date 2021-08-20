#!/bin/bash
path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
filesystem=$(findmnt | grep "/mnt" | awk '{print $3}')
if [[ "$filesystem" == "ext4" ]]; then
	(cd $path && python3 ./FragPicker_IP.py)
else
	(cd $path && python3 ./FragPicker_OP.py)
fi
