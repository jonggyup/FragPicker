import sys
import subprocess
import os


trace_file = open("./trace.result", "rb+",0)


def simplecount(filename):
    lines = 0
    for line in open(filename):
        lines += 1
    return lines

lines = trace_file.readlines()
file_list = set()
prevFileNo=0
prevFileEnd=0
readaheadRange=0

for line in lines:
    req_info = line.split() #req_info = [i_no, size, pos]
    fileNo = int(req_info[0])
    size = int(req_info[1])
    start = int(req_info[2])
    end = int(req_info[2]) + int(req_info[1]) - 1
    
    #Sequential Read
    if start == prevFileEnd + 1 and prevFileNo == fileNo:
        prevFileEnd = end

        if readaheadRange >= end:
            continue
        
        if size <= 131072:
            end = start + 131072 - 1

        readaheadRange = end
    else:
        readaheadRange = 0


    prevFileEnd = int(req_info[2]) + int(req_info[1]) - 1
    prevFileNo = fileNo

    f = open("./"+str(req_info[0].decode('utf-8'))+".txt", 'a+')
    f.write(str(start) +" "+ str(end) +" "+ "1" + "\n")
    f.close()
    file_list.add(req_info[0])


filelist_f = open("./filelist.txt", "w+")
for filename in file_list:
    filename = filename.decode("utf-8")
    if int(simplecount("./"+str(filename)+".txt")) < 30:
        subprocess.call(["rm", "./"+str(filename)+".txt"])
        continue

    subprocess.call(["sort", "-g", "./"+str(filename)+".txt"], stdout=open("./tmp.txt", "w+"))
    subprocess.call(["mv", "./tmp.txt", "./"+str(filename)+".txt"])
    filelist_f.write(filename+" "+str(simplecount("./"+str(filename)+".txt")) + "\n")

trace_file.close()

