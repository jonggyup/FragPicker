import sys
import subprocess
import os

def defrag_func(targetFile_F, start, end):
    targetFile_f.seek(start, 0)
    size = end-start+1
    data = targetFile_f.read(size)
    targetFile_f.seek(start, 0)
    targetFile_f.write(data)
   
         

filelist_f=open("./traces/filelist.txt", "r+")
filename_lines = filelist_f.readlines()

for filename_line in filename_lines:

    if int(filename_line.split()[1]) < 500 or str(filename_line.split()[0]) == '':
        continue
    
    filename = subprocess.check_output(["find", "/mnt", "-inum", filename_line.split()[0]]).decode('ascii').strip()
    


    filefrag_f=open("./traces/frag_degree.txt", "w+")
    subprocess.check_call(["filefrag", "-v", filename], stdout=filefrag_f)
    subprocess.check_call(["sed","-i","1,3d", "./traces/frag_degree.txt"])
    subprocess.check_call(["sed","-i","$d", "./traces/frag_degree.txt"])
    os.fsync(filefrag_f.fileno())

    filefrag_f.close()

    filefrag_f=open("./traces/frag_degree.txt", "r+")
    filefrag_f.seek(0)
    filefrag_lines = filefrag_f.readlines()
    targetFile_f = open(filename, "rb+")
    targetRange_f = open("./traces/"+filename_line.split()[0]+".merged", "r")
    targetRange = targetRange_f.readline()
    startRange = int(targetRange.split()[0])
    endRange = int(targetRange.split()[1])
    currentOffset = 0

    for filefrag_line in filefrag_lines:
        currentOffset+=int(filefrag_line.split(':')[3])*4096
        if currentOffset < startRange:
            continue
        
        if currentOffset >= startRange and currentOffset < endRange:
            defrag_func(targetFile_f, startRange, endRange)
            targetRange = targetRange_f.readline()
            if targetRange == '':
                break
    
            startRange = int(targetRange.split()[0])
            endRange = int(targetRange.split()[1])
            continue

        if currentOffset >= endRange:
            targetRange = targetRange_f.readline()

            if targetRange == '':
                break

            startRange = int(targetRange.split()[0])
            endRange = int(targetRange.split()[1])

            continue


    os.fsync(targetFile_f.fileno())
    targetFile_f.close()
    filefrag_f.close()


