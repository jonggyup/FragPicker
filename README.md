

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
	- src/migration/FragPicker_OP.py: the migration phase of FragPicker for out-place update filesystems (e.g., F2FS, Btrfs)
	- src/migration/FragPicker_IP.py: the migration phase of FragPicker for in-place update filesystems (e.g., Ext4)
	- src/migration/FragPicker_bypass_OP.py: the bypass version of FragPicker for out-place update filesystems
	- src/migration/FragPicker_bypass_IP.py: the bypass version of FragPicker for in-plcae update filesystems
	- src/migration/FragPicker.sh: the execution file of FragPicker migration
	- src/migration/FragPicker_bypass.sh: the execution file of FragPicker migration with bypass
	- src/migration/defrag_all.py: migration of the entire contents like conventional tools

* Evaluation
	- evaluation/motivation: the motivational evaluation
	- evaluation/read_benchmark: the read evaluation
	- evaluation/write_benchmark: the write evaluation
	- evaluation/tools: tools for evaluation

## Experiments
### Tested Environment
We use Ubuntu 18.04 LTS with Linux Kernel 5.7.0

+ **Storage devices**
>1) HDD: Samsung HDD 7200RPM 1TB
>2) MicroSD: Samsung MicroSD EVO type A1 128GB
>3) SATA SSD: Samsung SATA FLash SSD 850 PRO 256GB
>4) NVMe SSD: Intel NVMe Optane SSD 905P 960GB

### 1. Evaluation Setup
***Warning***
The evaluation source codes are written under an assumption that the mount point is /mnt without interference with other application. Therefore, the evaluation codes will continuously umount and mount /mnt. Therefore, we hope you make sure nothing important in /mnt. Also, the experiments should be performed with sudo.

The basic mechanism of these experiments is 1) mount a device in /mnt, 2) perform experiments, and 3) unmount the device.

Since we assume the mount point is /mnt (not /home/user/mnt), we hardcoded that in some parts of source codes.
Therefore, we recommend that ppl use /mnt as the mount point and change the corresponding device name inside running scripts.

As a example of motivational experiment, if your optane SSD is at /dev/nvme0n1p1, you need to change "for dev in nvme1n1p1" to "for dev in nvme0n1p1" in the 12nd line of evaluation/motivation/read_bench.c (or write_bench.c)

Additionally, you need to change "nvme1n1p1)" to "nvme0n1p1" inside the case statement in the 15th line of the same file.

This rule is also applied to the read/write benchmarks (./run_benchmark.sh)


#### 1-1. Install dependencies
```
./dep.sh
```

#### 1-2. Install bcc tracer
The bcc trace should be installed via manual compiling instead of packages. We leave its brief installation here, and the detailed installation is explained in https://github.com/iovisor/bcc/blob/master/INSTALL.md

#### Install build dependencies
```
## For Bionic (18.04 LTS)
sudo apt-get -y install bison build-essential cmake flex git libedit-dev \
  libllvm6.0 llvm-6.0-dev libclang-6.0-dev python zlib1g-dev libelf-dev libfl-dev python3-distutils
```
### Install and compile BCC
```
git clone https://github.com/iovisor/bcc.git
mkdir bcc/build; cd bcc/build
cmake ..
make
sudo make install
cmake -DPYTHON_CMD=python3 .. # build python3 binding
pushd src/python/
make
sudo make install
popd
```




### 2. Motivation Experiments
Enter the motivation experiment directory.
```
cd evaluation/motivation
make
```

For read (takes around 133 minutes) ---> Figure 4. (a) -- (d) and Table 1
```
./read_bench.sh
```

For write (takes 136 minutes)
```
./write_bench.sh
```

Note that, in the paper, we present only the results of the read benchmark as a form of figures.

By default, the device name is configured as follows.
>- Optane SSD -> nvme1n1p1
>- SATA Flash SSD -> sdb1
>- HDD -> sde1
>- MicroSD -> sdf1

The benchmark maybe needs the following storage free space
>- Optane -> around 210GB
>- SSD -> around 110GB
>- HDD and MircoSD -> around 35GB

If your devices have insufficient free space, you can decrease the size of target files via the size variable.

In each benchmark file (read_bench.sh, write_bench.sh), **the device name and base_dir should be modified.**


To view the result of the experiments, conduct the following commands
```
./view_experiment_type.sh I/O type dev_type
```
By default, the directory name for each dev is as follows.
>- Optane SSD -> Optane
>- SATA Flash SSD -> SSD
>- HDD -> HDD
>- MicroSD -> MicroSD

1. read with varying frag_size
```
./view_frag_size.sh read dev_type (directory name)
```
> e.g., ./view_frag_size.sh read Optane

2. read with varying frag_distance
```
./view_distance.sh read dev_type
```
> e.g., ./view_distance.sh read Optane

3. write with varying frag_size
```
./view_frag_size.sh write dev_type
```
> e.g., ./view_frag_size.sh write Optane

4. write with varying frag_distance
```
./view_distance.sh write dev_type
```
> e.g., ./view_distance.sh write Optane
 
The results consist of value and the performance (MB/s)

> e.g., Read benchmark with varying frag_size on Optane SSD
```
Value          read_exp
4KB             723.864     |
8KB             894.021     |
16KB            1171.88     |
32KB            1395.86     |
64KB            1527.07     |
128KB           1727.98     |
256KB           1725.85     |
512KB           1725.07     |
1024KB          1727.06     |
2048KB          1729.13     |
4096KB          1725.82     |
```
We utilize CORREL and SLOPE function in Excel after normalization, in order to obtain CC and NLRS. 

### 3. Evaluation
#### 3-1. Read benchmark
The read workloads (Figure 8, 9) perform sequential and stride read workloads with O_DIRECT and 128KB-sized requests on the three filesystems (ext4, f2fs, and btrfs). The current source codes conduct the experiments with Optane SSD and SATA Flash SSD.

To execute, enter the synthetic experiment directory and run the following commands.

Since we also measure the write amount using blktrace, no other applications should run at the same time.
```
cd evaluation/read_benchmark
make
./run_benchmark.sh
```
./run_benchmark.sh for only Optane SSD and Flash SSD takes 94m31.550s and 43m24.246s, respectively, in our machine.

The experiments measure throughput (MB/s), fragmentation state and write amount, after defragmentation.
>- throughput -> $$$_perf_after.result
>- write amount -> $$$_btrace.trace
>- frag. state -> $$$_frag_after.frag

These results will be saved in ./results/workload_name/device_type/filesystem/

Note that if you encouter an error like "./run_benchmark.sh: line 123: kill: (9431) - No such process", you can just ignore this.


To view the results in a nicer way, run the following commands,
```
cd evaluation/synthetic_read
./view_results.sh $workload $device_type
```
> e.g., ./view_result.sh stride Optane ($workload is either sequential or stride)

The results will be displayed like below.

> e.g., Sequential Read benchmark on Optane SSD

```
sequential        baseline_perf     FragPicker-B_perf     FragPicker_perf     Conv_perf     FragPicker-B_write     FragPicker_write     Conv_write     Conv-T_perf     Conv-T_write
ext4                 990.052         |  1758.70         |  1809.15         |  1856.67         |  541976K         |  530900K         |  1057MiB         |
f2fs                 987.095         |  1723.71         |  1723.60         |  1729.02         |  527368K         |  525320K         |  1052MiB         |
btrfs                435.707         |  877.273         |  882.680         |  933.656         |  528720K         |  525172K         |  1101MiB         |  886.660     |  532460K     |
```
Here, $$$_perf means the throughput (MB/s), and $$$_write means the amount of writes.

Conv-T is btrfs.defragment with the optimization. Therefore, ext4 and f2fs do not have the value.



#### 3-2. Write benchmark
The write workloads (Figure 8, 9) perform sequential and stride write workloads with O_DIRECT and 128KB-sized requests on the three filesystems (ext4, f2fs, and btrfs). The current source codes conduct the experiments with Optane SSD and SATA Flash SSD.
To execute, enter the synthetic experiment directory and run the following commands.
Since we also measure the write amount using blktrace, no other applications should run at the same time.
```
cd evaluation/write_benchmark
make
./run_benchmark.sh
```

./run_benchmark.sh for only Optane SSD and Flash SSD takes 94m31.550s and 43m03.371s, respectively, in our machine.

To view the results in a nicer way, run the following commands,
```
cd evaluation/synthetic_read
./view_results.sh $workload $device_type
```
> e.g., ./view_result.sh stride Optane


### Tips for errors

>Error 1: ModuleNotFoundError: No module named 'distutils.core' 
```
sudo apt install python3-distutils
```

>Error 2: ModuleNotFoundError: No module named 'fallocate'
```
apt install python3-pip  
pip3 install fallocate
```

<!--
#### Acknowledgement 
This work was supported by Institute of Information & communications Technology Planning & Evaluation (IITP) grant funded by the Korea government(MSIT) (IITP-2015-0-00284, (SW Starlab) Development of UX Platform Software for Supporting Concurrent Multi-users on Large Displays)-->



