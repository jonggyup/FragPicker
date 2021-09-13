#!/bin/bash
free
sync; sudo echo 3 > /proc/sys/vm/drop_caches
free
