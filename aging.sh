#!/bin/bash

filemode=$(stat -c %a $1)
fileowner=$(ls -l $1 | awk '{print $3}')
groupname=$(ls -l $1 | awk '{print $4}')

./fragmentor $1

echo "Access mode change"
chmod $filemode $1
chown $fileowner:$groupname $1
echo "File ownership change"

