import sys
import subprocess
import os


result_file = open("./after_process.result", "w+")
trace_file = open("./trace.result", "rb+",0)


def simplecount(filename):
    lines = 0
    for line in open(filename):
        lines += 1
    return lines

lines = trace_file.readlines()
file_list = set()
for line in lines[:-1]:
    req_info = line.split() #req_info = [i_no, size, pos]
    #filename = subprocess.call(["find", "/mnt", "-inum", req_info[0]])
    start = int(req_info[2])
    end = int(req_info[2]) + int(req_info[1]) - 1
    print(str(start) ,str(end), "1", file=open("./"+str(req_info[0].decode('utf-8'))+".txt", 'a+'))
    file_list.add(req_info[0])


filelist_f = open("./filelist.txt", "w+")
for filename in file_list:
    filename = filename.decode("utf-8")
    subprocess.call(["sort", "-g", "./"+str(filename)+".txt"], stdout=open("./tmp.txt", "w+"))
    subprocess.call(["mv", "./tmp.txt", "./"+str(filename)+".txt"])
    filelist_f.write(filename+" "+str(simplecount("./"+str(filename)+".txt")) + "\n")








result_file.close()
trace_file.close()

