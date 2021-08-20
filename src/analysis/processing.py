import sys
import subprocess
import os
from pathlib import Path

trace_file = open("./trace.result", "rb+",0)
file_list = set()

#Calculates per-file request counts
def simplecount(filename):
    lines = 0
    for line in open(filename):
        lines += 1
    return lines

perfile_ReqEnd={}
perfile_RAWindow={}
lines = trace_file.readlines()

for line in lines:
    req_info = line.split() #req_info = [i_no, size, pos]
    if req_info[0] == b'=':
        continue
    fileNo = int(req_info[0]) #Extract inode number
    size = int(req_info[1]) #Extract request size
    start = int(req_info[2]) #Extract start offset
    end = int(req_info[2]) + int(req_info[1]) - 1 #Extract end offset
    direct = int(req_info[3]) #Extract whether O_DIRECT or not (if O_DIRECT, direct is 16384)
    RW_type = int(req_info[4])
    
    #Adjust the request with filesystem blocks
    if start % 4096 != 0:
        start -= start % 4096
    if (end + 1) % 4096 != 0:
        end += end % 4096 - 1

    #Check if this is sequential read for the readahead mechanism
    #Check if it is O_DIRECT (Direct = 16384 when O_DIRECT)
    if fileNo in perfile_ReqEnd and start == perfile_ReqEnd[fileNo] + 1 and direct == 0 and RW_type == 0:
        perfile_ReqEnd[fileNo] = end
        
        #If this request is in the readahead window, ignore this one since this range is already absorbed by the readahead mechanism
        if perfile_RAWindow[fileNo] >= end:
            continue

        #Change the request size to readahead size
        if size <= 131072: #Default readahead size = 128KB
            end = start + 131072 - 1
        
        #Adjust the current readahead window
        perfile_RAWindow[fileNo] = end
    else:
        #If the requests are not sequential, turn off the readahead module
        perfile_ReqEnd[fileNo] = end
        perfile_RAWindow[fileNo] = 0
    
    #Store per-file request information
    f = open("./"+str(req_info[0].decode('utf-8'))+".txt", 'a+')
    f.write(str(start) +" "+ str(end) +" "+ "1" + "\n")
    f.close()
    file_list.add(req_info[0])

#Create the per-file metadata such as filename, request count.
filelist_f = open("./filelist.txt", "w+")
for filename in file_list:
    filename = filename.decode("utf-8")
    filepath = subprocess.check_output(["find", "/mnt", "-inum", filename]) #Translate from inode number to filepath
    
    #Ignore directories
    if os.path.isdir(filepath.decode("utf-8").rstrip("\n")) == True or str(filepath) == "b\'\'" or int(simplecount("./"+str(filename)+".txt")) < 0:
        subprocess.call(["rm", "./"+str(filename)+".txt"])
        continue
    
    subprocess.call(["sort", "-g", "./"+str(filename)+".txt"], stdout=open("./tmp.txt", "w+"))
    subprocess.call(["mv", "./tmp.txt", "./"+str(filename)+".txt"])
    filelist_f.write(filename+" "+str(simplecount("./"+str(filename)+".txt")) + "\n") #per-file request counts

trace_file.close()


#if __name__ == "__main__":
    
