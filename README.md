# FragPicker
This repository contains scripts and source codes of FragPicker, which will appear at SOSP 2021.

## Overview
FragPicker is a defragmentatool for modern storage devices (Flash, Optane devices)
The conventional fragmentors mostly migrate the entire contents of files into a new contiguous area, which (i) cause defragmentation to be time-consuming, (ii) significantly degrade the performance of co-running applications, and (iii) even curtail the lifetime of modern storage devices.

To address this, FragPicker analyzes the I/O activities of applications and migrates only those pieces of data that are crucial to the I/O performance, in order to mitigate the aforementioned problems of existing tools.

## Contents
* Source Code
	- src/analysis: the analysis phase that analyzes the application I/O behaviors
	- src/analysis/trace.sh: I/O system call monitoring
	- src/analysis/parse.sh: Parsing the traced data
	- src/analysis/processing.py: per-file analysis
	- src/analysis/merge.py: the overlap I/O merging in the per-file analysis
	- src/analysis/hotness.sh: hotness filtering
	- src/migration/FragPicker.py: the migration phase of FragPicker for out-place update filesystems (e.g., F2FS, Btrfs)
	- src/migration/FragPicker\_IP.py: the migration phase of FragPicker for in-place update filesystems (e.g., Ext4)
	- src/migration/FragPicker\_bypass.py: the bypass version of FragPicker for out-place update filesystems
	- src/migration/FragPicker\_bypass\_IP.py: the bypass version of FragPicker for in-plcae update filesystems
	- src/migration/defrag\_all.py: migration of the entire contents like conventional tools

* Evaluation
	- evaluation/motivation: the motivational evaluation
	- evaluation/synthetic: the synthetic evaluation

## Experiments
### Tested Environment
We use Ubuntu 18.04 LTS with Linux Kernel 5.7.0
Storage
1) HDD: Samsung HDD 7200RPM 1TB
2) MicroSD: Samsung MicroSD EVO type A1 128GB
3) SATA SSD: Samsung SATA FLash SSD 850 PRO 256GB
4) NVMe SSD: Intel NVME Optane SSD 905P 960GB

### Setup
#### 1. Install dependencies
'''
./dep.sh
'''

### 2. Motivation Experiments
Enter the motivation experiment directory.
'''
cd evaluation/motivation
'''

For read
'''
./read\_bench.sh
'''

For write
'''
./write\_bench.sh
'''

Note that, in the paper, we present only the results of the read benchmark as a form of figures.
By default, the device name is configured as follows.
Optane SSD --> nvme1n1p1
SATA Flash SSD --> sdb1
HDD --> sde1
MicroSD --> sdf1
In each benchmark file (read\_bench.sh write\_bench.sh), the device name and base\_dir should be modified.

To view the result of the experiments, conduct the following commands
./view\_exp\_type.sh I/O type dev\_type
By default, the directory name for each dev is as follows.
Optane SSD --> Optane
SATA Flash SSD --> SSD
HDD --> HDD
MicroSD --> MicroSD

1. read with varying frag\_size
'''
./view\_frag\_size.sh read dev\_type (directory name)
'''
e.g., ./view\_frag\_size.sh read Optane
'''

2. read with varying frag\_distance
'''
./view\_distance.sh read dev\_type
'''
e.g., ./view\_distance.sh read Optane
'''

3. write with varying frag\_size
'''
./view\_frag\_size.sh write dev\_type
'''
e.g., ./view\_frag\_size.sh write Optane
'''

4. write with varying frag\_distance
'''
./view\_distance.sh write dev\_type
'''
e.g., ./view\_distance.sh write Optane
'''

### 3. Synthetic Evaluation
'''
evaluation/syntehtic/run.sh
'''


*Supported by SWStarlab
