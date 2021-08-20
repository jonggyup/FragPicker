#!/bin/bash
path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
filesystem=$(findmnt | grep "/mnt" | awk '{print $3}') #obtain the mounted filesystem name of /mnt
#Currently, we tested three filesystems, ext4, F2FS, and btrfs.

#If ext4, conduct FragPicker_IP.py, which additionally perform block allocation.
if [[ "$filesystem" == "ext4" ]]; then 
	(cd $path && python3 ./FragPicker_IP.py)
else
	(cd $path && python3 ./FragPicker_OP.py) #out-place update filesystems do not need block allocaiton.
fi

(cd $path && cd ../analysis && ./remove.sh) #On successful defragmentaiton, remove the profiled data.
#The profiled data is acculmalted. Make sure deletion of the data before beginning a new experiment.
