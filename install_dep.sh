#!/bin/bash

#This works with Ubuntu 18.04 LTS
sudo apt-get update -y
sudo apt-get -y install f2fs-tools btrfs-progs blktrace \
	python3 python3-pip python3-distutils bc

sudo pip3 install fallocate

			
