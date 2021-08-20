#!/bin/bash
#$1: Filename $2: defrag_size

path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
filesystem=$(findmnt | grep "/mnt" | awk '{print $3}')
if [[ "$filesystem" == "ext4" ]]; then
	(cd $path && python3 ./FragPicker_IP.sh $1 $2)
else
	(cd $path && python3 ./FragPicker_OP.sh $1 $2)
fi
