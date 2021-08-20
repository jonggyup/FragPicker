#!/bin/bash
free
sudo echo 3 > /proc/sys/vm/drop_caches
free
